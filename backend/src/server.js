import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import authRoutes from './routes/auth.js';
import rideRoutes from './routes/rides.js';
import paymentRoutes from './routes/payments.js';
import { Server as SocketServer } from 'socket.io';

const app = express();
app.use(cors());
app.use(express.json());

// Health check
app.get('/', (_req, res) => res.json({ status: 'BikeJee API running' }));

// Routes
app.use('/auth', authRoutes);
app.use('/rides', rideRoutes);
app.use('/payments', paymentRoutes);

const server = createServer(app);

// Socket.IO for real-time ride matching + live tracking
const io = new SocketServer(server, { cors: { origin: '*' } });
app.set('io', io); // so routes can emit

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  // Driver publishes location; customers tracking that ride receive updates
  socket.on('driver:location', ({ rideId, lat, lng }) => {
    io.to(`ride:${rideId}`).emit('ride:driverLocation', { lat, lng });
  });

  // Customer joins a ride room to receive live updates
  socket.on('ride:join', ({ rideId }) => {
    socket.join(`ride:${rideId}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  console.log(`BikeJee backend listening on port ${PORT}`);
});
