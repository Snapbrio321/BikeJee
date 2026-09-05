import express from 'express';
import crypto from 'crypto';

const router = express.Router();

// Razorpay keys from env
const KEY_ID = process.env.RAZORPAY_KEY_ID || '';
const KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || '';

// POST /payments/create-order  { amount (paise), currency, description }
router.post('/create-order', async (req, res) => {
  const { amount, currency = 'INR' } = req.body;

  if (!KEY_ID || !KEY_SECRET) {
    // No keys configured — return a mock order for testing
    return res.json({ orderId: `mock_order_${Date.now()}`, amount, currency });
  }

  try {
    // Razorpay Orders API
    const auth = Buffer.from(`${KEY_ID}:${KEY_SECRET}`).toString('base64');
    const r = await fetch('https://api.razorpay.com/v1/orders', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${auth}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ amount, currency, receipt: `rcpt_${Date.now()}` }),
    });
    const order = await r.json();
    if (order.error) return res.status(400).json({ error: order.error });
    res.json({ orderId: order.id, amount: order.amount, currency });
  } catch (e) {
    res.status(500).json({ error: 'Failed to create order' });
  }
});

// POST /payments/verify  { orderId, paymentId, signature }
router.post('/verify', (req, res) => {
  const { orderId, paymentId, signature } = req.body;

  if (!KEY_SECRET) {
    // Mock mode — accept
    return res.json({ verified: true });
  }

  // Razorpay signature = HMAC_SHA256(orderId + "|" + paymentId, KEY_SECRET)
  const expected = crypto
    .createHmac('sha256', KEY_SECRET)
    .update(`${orderId}|${paymentId}`)
    .digest('hex');

  res.json({ verified: expected === signature });
});

export default router;
