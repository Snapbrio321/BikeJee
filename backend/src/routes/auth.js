import express from 'express';
import jwt from 'jsonwebtoken';
import { sendSms } from '../services/sms.js';
import { query, withTransaction } from '../db/pool.js';
import { saveOtp, getOtp, deleteOtp } from '../db/redis.js';
import { otpLimiter, verifyLimiter } from '../middleware/rateLimit.js';

const router = express.Router();

function generateOtp() {
  return Math.floor(1000 + Math.random() * 9000).toString(); // 4-digit
}

/** Maps a DB user row (snake_case) to the API shape (camelCase). */
function toApiUser(row) {
  return {
    id: row.id,
    name: row.name,
    phone: row.phone,
    email: row.email,
    role: row.role,
    isVerified: row.is_verified,
    rating: Number(row.rating),
    totalRides: row.total_rides,
    walletBalance: Number(row.wallet_balance),
    createdAt: row.created_at,
  };
}

// POST /auth/send-otp  { phone }
router.post('/send-otp', otpLimiter, async (req, res) => {
  const { phone } = req.body;
  if (!phone || phone.length !== 10) {
    return res.status(400).json({ error: 'Invalid phone number' });
  }

  const otp = generateOtp();
  try {
    // Redis stores the OTP with a 5-min TTL — auto-expires, no memory leak,
    // and shared across every app instance in the cluster.
    await saveOtp(phone, otp);
    await sendSms(phone, `Your BikeJee OTP is ${otp}. Valid for 5 minutes.`);
    return res.json({ verificationId: `${phone}-${Date.now()}` });
  } catch (e) {
    console.error('send-otp failed:', e.message);
    return res.status(500).json({ error: 'Failed to send OTP' });
  }
});

// POST /auth/verify-otp  { phone, otp, role }
router.post('/verify-otp', verifyLimiter, async (req, res) => {
  const { phone, otp, role } = req.body;
  if (!phone || !otp) {
    return res.status(400).json({ error: 'phone and otp are required' });
  }

  try {
    const stored = await getOtp(phone);
    if (!stored) return res.status(400).json({ error: 'OTP expired or not requested' });
    if (stored !== otp) return res.status(400).json({ error: 'Invalid OTP' });

    await deleteOtp(phone);

    // Upsert the user in Postgres. Transaction ensures the driver row is
    // created atomically alongside the user when role='driver'.
    const user = await withTransaction(async (client) => {
      const existing = await client.query('SELECT * FROM users WHERE phone = $1', [phone]);
      if (existing.rows.length) return existing.rows[0];

      const inserted = await client.query(
        `INSERT INTO users (phone, role, is_verified)
         VALUES ($1, $2, TRUE) RETURNING *`,
        [phone, role || 'customer']
      );
      const row = inserted.rows[0];
      if ((role || 'customer') === 'driver') {
        await client.query('INSERT INTO drivers (id) VALUES ($1)', [row.id]);
      }
      return row;
    });

    const token = jwt.sign(
      { id: user.id, phone: user.phone, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    return res.json({ token, user: toApiUser(user) });
  } catch (e) {
    console.error('verify-otp failed:', e.message);
    return res.status(500).json({ error: 'Verification failed' });
  }
});

// GET /auth/me — returns the current user (requires token)
router.get('/me', async (req, res) => {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: 'Missing token' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const { rows } = await query('SELECT * FROM users WHERE id = $1', [payload.id]);
    if (!rows.length) return res.status(404).json({ error: 'User not found' });
    return res.json({ user: toApiUser(rows[0]) });
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
});

export default router;
