import express from 'express';
import jwt from 'jsonwebtoken';
import { sendSms } from '../services/sms.js';

const router = express.Router();

// In-memory OTP store. For production, use Redis with TTL instead.
const otpStore = new Map(); // phone -> { otp, expiresAt, verificationId }

// In-memory user store. For production, use PostgreSQL/DynamoDB.
const users = new Map(); // phone -> user object

function generateOtp() {
  return Math.floor(1000 + Math.random() * 9000).toString(); // 4-digit
}

// POST /auth/send-otp  { phone }
router.post('/send-otp', async (req, res) => {
  const { phone } = req.body;
  if (!phone || phone.length !== 10) {
    return res.status(400).json({ error: 'Invalid phone number' });
  }

  const otp = generateOtp();
  const verificationId = `${phone}-${Date.now()}`;
  otpStore.set(phone, {
    otp,
    verificationId,
    expiresAt: Date.now() + 5 * 60 * 1000, // 5 minutes
  });

  try {
    await sendSms(phone, `Your BikeJee OTP is ${otp}. Valid for 5 minutes.`);
    return res.json({ verificationId });
  } catch (e) {
    return res.status(500).json({ error: 'Failed to send OTP' });
  }
});

// POST /auth/verify-otp  { phone, otp, role, verificationId }
router.post('/verify-otp', (req, res) => {
  const { phone, otp, role } = req.body;
  const record = otpStore.get(phone);

  if (!record) {
    return res.status(400).json({ error: 'OTP not requested' });
  }
  if (Date.now() > record.expiresAt) {
    otpStore.delete(phone);
    return res.status(400).json({ error: 'OTP expired' });
  }
  if (record.otp !== otp) {
    return res.status(400).json({ error: 'Invalid OTP' });
  }

  otpStore.delete(phone);

  // Create or fetch the user
  let user = users.get(phone);
  if (!user) {
    user = {
      id: `u_${Date.now()}`,
      name: '',
      phone,
      role: role || 'customer',
      isVerified: true,
      rating: 5.0,
      totalRides: 0,
      walletBalance: 0,
      createdAt: new Date().toISOString(),
    };
    users.set(phone, user);
  }

  const token = jwt.sign(
    { id: user.id, phone: user.phone, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );

  return res.json({ token, user });
});

export default router;
