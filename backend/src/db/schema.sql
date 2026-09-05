-- BikeJee PostgreSQL schema — production, indexed for 1 lakh+ users.
-- Run via `npm run migrate` or psql -f schema.sql

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- earthdistance/cube enable fast geo radius queries for driver matching
CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- ── Users ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phone          VARCHAR(15) UNIQUE NOT NULL,
  name           VARCHAR(120) DEFAULT '',
  email          VARCHAR(160),
  role           VARCHAR(12) NOT NULL DEFAULT 'customer', -- customer | driver
  is_verified    BOOLEAN NOT NULL DEFAULT TRUE,
  rating         NUMERIC(2,1) NOT NULL DEFAULT 5.0,
  total_rides    INTEGER NOT NULL DEFAULT 0,
  wallet_balance NUMERIC(10,2) NOT NULL DEFAULT 0,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

-- ── Drivers (extends users where role='driver') ─────────────────────────────
CREATE TABLE IF NOT EXISTS drivers (
  id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  vehicle_name   VARCHAR(80),
  vehicle_number VARCHAR(20),
  is_online      BOOLEAN NOT NULL DEFAULT FALSE,
  lat            DOUBLE PRECISION,
  lng            DOUBLE PRECISION,
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
-- Composite index for "online drivers near a point" queries
CREATE INDEX IF NOT EXISTS idx_drivers_online ON drivers(is_online);
CREATE INDEX IF NOT EXISTS idx_drivers_geo
  ON drivers USING gist (ll_to_earth(lat, lng));

-- ── Rides ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rides (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id    UUID NOT NULL REFERENCES users(id),
  driver_id      UUID REFERENCES users(id),
  service_type   VARCHAR(10) NOT NULL,   -- bike | auto | cab | parcel
  tier           VARCHAR(10) NOT NULL DEFAULT 'go',
  pickup_name    TEXT, pickup_lat DOUBLE PRECISION, pickup_lng DOUBLE PRECISION,
  drop_name      TEXT, drop_lat DOUBLE PRECISION, drop_lng DOUBLE PRECISION,
  distance_km    NUMERIC(6,2) NOT NULL DEFAULT 0,
  fare           INTEGER NOT NULL DEFAULT 0,
  status         VARCHAR(12) NOT NULL DEFAULT 'searching',
  payment_method VARCHAR(20) NOT NULL DEFAULT 'Cash',
  rating         NUMERIC(2,1),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at   TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_rides_customer ON rides(customer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rides_driver   ON rides(driver_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_rides_status   ON rides(status);

-- ── Wallet transactions ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallet_transactions (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id),
  label       VARCHAR(80) NOT NULL,
  amount      INTEGER NOT NULL,           -- +credit / -debit (rupees)
  ride_id     UUID REFERENCES rides(id),
  payment_id  VARCHAR(80),                -- Razorpay payment id
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_wallet_user ON wallet_transactions(user_id, created_at DESC);

-- ── Saved places ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS saved_places (
  id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id  UUID NOT NULL REFERENCES users(id),
  label    VARCHAR(40) NOT NULL,   -- home | work | custom
  name     TEXT NOT NULL,
  address  TEXT,
  lat      DOUBLE PRECISION,
  lng      DOUBLE PRECISION
);
CREATE INDEX IF NOT EXISTS idx_saved_user ON saved_places(user_id);
