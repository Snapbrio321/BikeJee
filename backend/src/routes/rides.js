import express from 'express';

const router = express.Router();

// In-memory ride store. For production use PostgreSQL/DynamoDB.
const rides = new Map(); // rideId -> ride

// Simulated online drivers pool. In production these come from live driver GPS.
const drivers = [
  { id: 'd_1', name: 'Arjun Kumar', phone: '+91 98765-43210',
    vehicleName: 'Honda Activa', vehicleNumber: 'KA 03 JE 1234', rating: 4.8 },
  { id: 'd_2', name: 'Ravi Sharma', phone: '+91 91234-56789',
    vehicleName: 'TVS Jupiter', vehicleNumber: 'KA 05 MN 4321', rating: 4.6 },
];

// POST /rides — create a ride and (mock) match a nearby driver
router.post('/', (req, res) => {
  const ride = req.body;
  ride.id = ride.id || `r_${Date.now()}`;
  ride.status = 'searching';
  ride.createdAt = new Date().toISOString();
  rides.set(ride.id, ride);

  // Match a driver after a short delay (simulated). Real: geo-query nearest.
  setTimeout(() => {
    const driver = drivers[Math.floor(Math.random() * drivers.length)];
    ride.driverId = driver.id;
    ride.status = 'accepted';
    ride.driver = driver;
    rides.set(ride.id, ride);
    // Socket layer (server.js) emits ride:status to the ride room.
    req.app.get('io')?.to(`ride:${ride.id}`).emit('ride:status', {
      status: 'accepted', driver,
    });
  }, 3000);

  res.json({ ride });
});

// GET /rides/:id
router.get('/:id', (req, res) => {
  const ride = rides.get(req.params.id);
  if (!ride) return res.status(404).json({ error: 'Ride not found' });
  res.json({ ride });
});

// POST /rides/:id/cancel
router.post('/:id/cancel', (req, res) => {
  const ride = rides.get(req.params.id);
  if (ride) {
    ride.status = 'cancelled';
    rides.set(ride.id, ride);
    req.app.get('io')?.to(`ride:${ride.id}`).emit('ride:status', {
      status: 'cancelled',
    });
  }
  res.json({ ok: true });
});

export default router;
