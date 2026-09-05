import rateLimit from 'express-rate-limit';
import { RedisStore } from 'rate-limit-redis';
import { redis } from '../db/redis.js';

/**
 * Redis-backed rate limiters. Using Redis (not in-memory) means limits are
 * enforced ACROSS all app instances — critical when running a cluster / ASG
 * behind a load balancer. In-memory limits would reset per process and be
 * trivially bypassed by hitting different instances.
 */
function makeLimiter({ windowMs, max, prefix, message }) {
  return rateLimit({
    windowMs,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: message },
    store: new RedisStore({
      sendCommand: (...args) => redis.call(...args),
      prefix,
    }),
  });
}

// OTP requests: expensive (SMS costs money + abuse vector). Tight limit per IP.
export const otpLimiter = makeLimiter({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 5,                   // 5 OTP requests / 15 min / IP
  prefix: 'rl:otp:',
  message: 'Too many OTP requests. Please try again later.',
});

// OTP verification: prevent brute-forcing the 4-digit code.
export const verifyLimiter = makeLimiter({
  windowMs: 15 * 60 * 1000,
  max: 10,
  prefix: 'rl:verify:',
  message: 'Too many verification attempts. Please try again later.',
});

// General API limiter — generous, protects against runaway clients.
export const apiLimiter = makeLimiter({
  windowMs: 60 * 1000, // 1 min
  max: 120,            // 120 req/min/IP
  prefix: 'rl:api:',
  message: 'Too many requests. Slow down.',
});
