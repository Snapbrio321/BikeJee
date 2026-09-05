import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import jwt from 'jsonwebtoken';

import authRoutes from './routes/auth.js';
import rideRoutes from './routes/rides.js';
import paymentRoutes from './routes/payments.js';
import { apiLimiter } from './middleware/rateLimit.js';
import { pool } from './db/pool.js';
import {
  redis, pubClient, subClient,
  updateDriverLocation, removeDriver,
} from './db/redis.js';

const app = express();

// ── Security & performance middleware ─────────────────────────────────────────
app.set('trust proxy', 1);            // behind ALB/Nginx — needed for correct IPs
app.use(helmet());                    // secure headers
app.use(compression());               // gzip responses
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json({ limit: '1mb' }));

// ── Health checks (used by ALB target group / PM2 / Docker) ───────────────────
app.get('/', (_req, res) => res.json({ status: 'BikeJee API running' }));
app.get('/health', async (_req, res) => {
  try {
    await pool.query('SELECT 1');
    await redis.ping();
    res.json({ status: 'ok', db: 'up', redis: 'up', pid: process.pid });
  } catch (e) {
    res.status(503).json({ status: 'degraded', error: e.message });
  }
});

// ── API routes (rate-limited) ─────────────────────────────────────────────────
app.use('/auth', authRoutes);          // auth has its own tighter limiters
app.use('/rides', apiLimiter, rideRoutes);
app.use('/payments', apiLimiter, paymentRoutes);

const server = createServer(app);

// ── Socket.IO with Redis adapter (multi-instance real-time) ───────────────────
// The Redis adapter broadcasts events across every app instance, so a customer
// connected to instance A receives updates emitted from instance B. Without it,
// clustering would break real-time tracking.
const io = new SocketServer(server, {
  cors: { origin: process.env.CORS_ORIGIN || '*' },
});
io.adapter(createAdapter(pubClient, subClient));
app.set('io', io);

// Authenticate sockets with the same JWT as the REST API.
io.use((socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) return next(); // allow anonymous for public tracking rooms
  try {
    socket.user = jwt.verify(token, process.env.JWT_SECRET);
  } catch { /* ignore invalid token, stay anonymous */ }
  next();
});

io.on('connection', (socket) => {
  // Drivers join their personal room so matchDriver can push new jobs
  if (socket.user?.role === 'driver') {
    socket.join(`driver:${socket.user.id}`);
  }

  // Customer joins a ride room to receive live updates
  socket.on('ride:join', ({ rideId }) => {
    socket.join(`ride:${rideId}`);
  });

  // Driver publishes GPS — update Redis GEO + fan out to the ride room
  socket.on('driver:location', async ({ rideId, lat, lng }) => {
    if (socket.user?.role === 'driver') {
      try { await updateDriverLocation(socket.user.id, lat, lng); } catch { /* noop */ }
    }
    if (rideId) io.to(`ride:${rideId}`).emit('ride:driverLocation', { lat, lng });
  });

  // Driver goes online without an active ride (so they appear in matching)
  socket.on('driver:online', async ({ lat, lng }) => {
    if (socket.user?.role === 'driver') {
      try { await updateDriverLocation(socket.user.id, lat, lng); } catch { /* noop */ }
    }
  });

  socket.on('driver:offline', async () => {
    if (socket.user?.role === 'driver') {
      try { await removeDriver(socket.user.id); } catch { /* noop */ }
    }
  });

  socket.on('disconnect', () => {
    if (socket.user?.role === 'driver') {
      removeDriver(socket.user.id).catch(() => {});
    }
  });
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`BikeJee backend listening on ${PORT} (pid ${process.pid})`);
});

// ── Graceful shutdown (SIGTERM from PM2/Docker/ASG) ───────────────────────────
async function shutdown(signal) {
  console.log(`${signal} received — shutting down gracefully...`);
  server.close(async () => {
    try {
      await pool.end();
      await redis.quit();
      await pubClient.quit();
      await subClient.quit();
    } catch (e) {
      console.error('Error during shutdown:', e.message);
    }
    process.exit(0);
  });
  // Force-exit if connections hang
  setTimeout(() => process.exit(1), 10000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

export { app, server, io };
