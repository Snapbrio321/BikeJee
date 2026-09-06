import express from 'express';
import { query, withTransaction } from '../db/pool.js';
import { requireAuth } from '../middleware/auth.js';

const router = express.Router();

/** Maps a wallet_transactions row to the API shape the app expects. */
function toApiTxn(r) {
  return {
    id: r.id,
    label: r.label,
    amount: r.amount, // +credit / -debit
    time: r.created_at,
  };
}

// GET /wallet — balance + recent transactions for the logged-in user
router.get('/', requireAuth, async (req, res) => {
  try {
    const [balanceRes, txnRes] = await Promise.all([
      query('SELECT wallet_balance FROM users WHERE id = $1', [req.user.id]),
      query(
        `SELECT * FROM wallet_transactions
          WHERE user_id = $1
          ORDER BY created_at DESC
          LIMIT 50`,
        [req.user.id]
      ),
    ]);
    const balance = balanceRes.rows.length
      ? Number(balanceRes.rows[0].wallet_balance)
      : 0;
    return res.json({
      balance,
      transactions: txnRes.rows.map(toApiTxn),
    });
  } catch (e) {
    console.error('wallet load failed:', e.message);
    return res.status(500).json({ error: 'Failed to load wallet' });
  }
});

// POST /wallet/add  { amount, paymentId }
// Records a verified top-up (call AFTER /payments/verify succeeds) and credits
// the balance atomically.
router.post('/add', requireAuth, async (req, res) => {
  const amount = parseInt(req.body.amount, 10);
  const paymentId = req.body.paymentId || null;
  if (!amount || amount <= 0) {
    return res.status(400).json({ error: 'Invalid amount' });
  }
  try {
    const balance = await withTransaction(async (client) => {
      await client.query(
        `INSERT INTO wallet_transactions (user_id, label, amount, payment_id)
         VALUES ($1, 'Added Money', $2, $3)`,
        [req.user.id, amount, paymentId]
      );
      const upd = await client.query(
        `UPDATE users SET wallet_balance = wallet_balance + $1
          WHERE id = $2 RETURNING wallet_balance`,
        [amount, req.user.id]
      );
      return Number(upd.rows[0].wallet_balance);
    });
    return res.json({ balance });
  } catch (e) {
    console.error('wallet add failed:', e.message);
    return res.status(500).json({ error: 'Failed to add money' });
  }
});

export default router;
