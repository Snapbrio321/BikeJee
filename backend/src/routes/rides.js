import express from 'express';
import { query, withTransaction } from '../db/pool.js';
import { findNearbyDrivers } from '../db/redis.js';
import { requireAuth } from '../middleware/auth.js';

const router = express.Router();

/** Maps a rides row (snake_case) to the API ride shape (camelCase). */
function toApiRide(r, driver) {
  return {
    id: r.id,
    customerId: r.customer_id,
    driverId: r.driver_id,
    serviceType: r.service_type,
    tier: r.tier,
    pickup: { name: r.pickup_name, lat: r.pickup_lat, lng: r.pickup_lng },
    drop: { name: r.drop_name, lat: r.drop_lat, lng: r.drop_lng },
    distanceKm: Number(r.distance_km),
    fare: r.fare,
    status: r.status,
    paymentMethod: r.payment_method,
    rating: r.rating != null ? Number(r.rating) : null,
    createdAt: r.created_at,
    completedAt: r.completed_at,
    driver: driver || undefined,
  };
}

/** Fetches a driver's public profile (user + vehicle) for the customer. */
async function fetchDriverProfile(driverId) {
  const { rows } = await query(
    `SELECT u.id, u.name, u.phone, u.rating,
            d.vehicle_name, d.vehicle_number
       FROM users u JOIN drivers d ON d.id = u.id
      WHERE u.id = $1`,
    [driverId]
  );
  if (!rows.length) return null;
  const d = rows[0];
  return {
    id: d.id, name: d.name, phone: d.phone, rating: Number(d.rating),
    vehicleName: d.vehicle_name, vehicleNumber: d.vehicle_number,
  };
}

/**
 * Assigns the nearest online driver to a ride using Redis GEO (O(log N)).
 * Tries candidates in ascending distance until one is free. Emits ride:status.
 */
async function matchDriver(io, ride) {
  const candidates = await findNearbyDrivers(
    ride.pickup_lat, ride.pickup_lng, 5, 10
  );

  for (const driverId of candidates) {
    // Atomically claim the ride for this driver only if still searching.
    const claimed = await query(
      `UPDATE rides SET driver_id = $1, status = 'accepted'
        WHERE id = $2 AND status = 'searching' AND driver_id IS NULL
        RETURNING *`,
      [driverId, ride.id]
    );
    if (claimed.rows.length) {
      const driver = await fetchDriverProfile(driverId);
      io?.to(`ride:${ride.id}`).emit('ride:status', { status: 'accepted', driver });
      // Notify the specific driver of the new job
      io?.to(`driver:${driverId}`).emit('ride:new', toApiRide(claimed.rows[0], driver));
      return driver;
    }
  }

  // No driver found — mark and inform the customer so the app can retry/expand.
  await query(
    `UPDATE rides SET status = 'no_drivers' WHERE id = $1 AND status = 'searching'`,
    [ride.id]
  );
  io?.to(`ride:${ride.id}`).emit('ride:status', { status: 'no_drivers' });
  return null;
}

// POST /rides — create a ride, then match a nearby online driver
router.post('/', requireAuth, async (req, res) => {
  const b = req.body || {};
  try {
    const { rows } = await query(
      `INSERT INTO rides
        (customer_id, service_type, tier,
         pickup_name, pickup_lat, pickup_lng,
         drop_name, drop_lat, drop_lng,
         distance_km, fare, payment_method, status)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,'searching')
       RETURNING *`,
      [
        req.user.id,
        b.serviceType || 'bike',
        b.tier || 'go',
        b.pickup?.name, b.pickup?.lat, b.pickup?.lng,
        b.drop?.name, b.drop?.lat, b.drop?.lng,
        b.distanceKm || 0, b.fare || 0, b.paymentMethod || 'Cash',
      ]
    );
    const ride = rows[0];

    // Kick off matching asynchronously so the client gets an immediate response
    // and receives the match via socket. Errors are logged, not thrown to client.
    const io = req.app.get('io');
    matchDriver(io, ride).catch((e) => console.error('matchDriver failed:', e.message));

    return res.json({ ride: toApiRide(ride) });
  } catch (e) {
    console.error('create ride failed:', e.message);
    return res.status(500).json({ error: 'Failed to create ride' });
  }
});

// GET /rides/history — current user's past rides (paginated)
router.get('/history', requireAuth, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit || '20', 10), 50);
  const offset = parseInt(req.query.offset || '0', 10);
  try {
    const { rows } = await query(
      `SELECT * FROM rides
        WHERE customer_id = $1
        ORDER BY created_at DESC
        LIMIT $2 OFFSET $3`,
      [req.user.id, limit, offset]
    );
    return res.json({ rides: rows.map((r) => toApiRide(r)) });
  } catch (e) {
    console.error('history failed:', e.message);
    return res.status(500).json({ error: 'Failed to load history' });
  }
});

// GET /rides/:id
router.get('/:id', requireAuth, async (req, res) => {
  try {
    const { rows } = await query('SELECT * FROM rides WHERE id = $1', [req.params.id]);
    if (!rows.length) return res.status(404).json({ error: 'Ride not found' });
    const ride = rows[0];
    const driver = ride.driver_id ? await fetchDriverProfile(ride.driver_id) : null;
    return res.json({ ride: toApiRide(ride, driver) });
  } catch (e) {
    console.error('get ride failed:', e.message);
    return res.status(500).json({ error: 'Failed to load ride' });
  }
});

// POST /rides/:id/complete — finalize fare, bump counters, wallet entry
router.post('/:id/complete', requireAuth, async (req, res) => {
  try {
    const ride = await withTransaction(async (client) => {
      const { rows } = await client.query(
        `UPDATE rides SET status = 'completed', completed_at = NOW()
          WHERE id = $1 AND status NOT IN ('completed','cancelled')
          RETURNING *`,
        [req.params.id]
      );
      if (!rows.length) throw new Error('Ride not completable');
      const r = rows[0];

      // Increment ride counters for both parties
      await client.query('UPDATE users SET total_rides = total_rides + 1 WHERE id = $1', [r.customer_id]);
      if (r.driver_id) {
        await client.query('UPDATE users SET total_rides = total_rides + 1 WHERE id = $1', [r.driver_id]);
      }
      return r;
    });

    req.app.get('io')?.to(`ride:${ride.id}`).emit('ride:status', { status: 'completed' });
    return res.json({ ride: toApiRide(ride) });
  } catch (e) {
    console.error('complete ride failed:', e.message);
    return res.status(400).json({ error: e.message });
  }
});

// POST /rides/:id/cancel
router.post('/:id/cancel', requireAuth, async (req, res) => {
  try {
    const { rows } = await query(
      `UPDATE rides SET status = 'cancelled'
        WHERE id = $1 AND status NOT IN ('completed','cancelled')
        RETURNING *`,
      [req.params.id]
    );
    if (rows.length) {
      req.app.get('io')?.to(`ride:${rows[0].id}`).emit('ride:status', { status: 'cancelled' });
    }
    return res.json({ ok: true });
  } catch (e) {
    console.error('cancel ride failed:', e.message);
    return res.status(500).json({ error: 'Failed to cancel ride' });
  }
});

export default router;
