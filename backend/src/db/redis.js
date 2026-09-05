import Redis from 'ioredis';

/**
 * Redis client — used for:
 *   - OTP store with automatic TTL expiry (no memory leaks)
 *   - Rate limiting (shared across all app instances)
 *   - Live driver locations (geo sets, fast radius queries)
 *   - Socket.IO pub/sub adapter (see socket.js)
 *
 * At 1 lakh users, Redis handles the high-churn ephemeral data that would
 * otherwise hammer PostgreSQL.
 */
const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

export const redis = new Redis(redisUrl, {
  maxRetriesPerRequest: 3,
  enableReadyCheck: true,
  retryStrategy: (times) => Math.min(times * 200, 2000),
});

// Separate connections are required for the Socket.IO pub/sub adapter.
export const pubClient = new Redis(redisUrl, { maxRetriesPerRequest: null });
export const subClient = pubClient.duplicate();

redis.on('error', (e) => console.error('Redis error:', e.message));
redis.on('connect', () => console.log('✅ Redis connected'));

// ── OTP helpers (TTL-based, auto-expire) ──────────────────────────────────────
const OTP_TTL_SECONDS = 300; // 5 minutes

export async function saveOtp(phone, otp) {
  await redis.set(`otp:${phone}`, otp, 'EX', OTP_TTL_SECONDS);
}

export async function getOtp(phone) {
  return redis.get(`otp:${phone}`);
}

export async function deleteOtp(phone) {
  await redis.del(`otp:${phone}`);
}

// ── Live driver location (Redis GEO — O(log N) radius queries) ────────────────
const DRIVERS_GEO_KEY = 'drivers:geo';
const DRIVER_META_TTL = 60; // driver considered offline if not updated in 60s

export async function updateDriverLocation(driverId, lat, lng) {
  await redis.geoadd(DRIVERS_GEO_KEY, lng, lat, driverId);
  // Heartbeat key — expires so stale drivers drop off automatically
  await redis.set(`driver:online:${driverId}`, '1', 'EX', DRIVER_META_TTL);
}

export async function removeDriver(driverId) {
  await redis.zrem(DRIVERS_GEO_KEY, driverId);
  await redis.del(`driver:online:${driverId}`);
}

/** Returns up to [count] online driver ids within [radiusKm] of a point. */
export async function findNearbyDrivers(lat, lng, radiusKm = 5, count = 10) {
  const results = await redis.georadius(
    DRIVERS_GEO_KEY, lng, lat, radiusKm, 'km', 'ASC', 'COUNT', count
  );
  // Filter to those still online (heartbeat key present)
  const online = [];
  for (const id of results) {
    if (await redis.exists(`driver:online:${id}`)) online.push(id);
  }
  return online;
}
