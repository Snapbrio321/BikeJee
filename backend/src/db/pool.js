import pg from 'pg';
const { Pool } = pg;

/**
 * PostgreSQL connection pool.
 * Pooling is CRITICAL at scale — without it, 1 lakh users would exhaust
 * database connections instantly. Each app instance keeps a small pool
 * and reuses connections.
 */
export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Tune per instance. With 2-4 app instances, keep max modest so total
  // connections stay under the RDS max_connections limit.
  max: parseInt(process.env.PG_POOL_MAX || '20', 10),
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
  // AWS RDS requires SSL in production
  ssl: process.env.PG_SSL === 'true'
    ? { rejectUnauthorized: false }
    : false,
});

pool.on('error', (err) => {
  console.error('Unexpected PG pool error:', err);
});

/** Helper: run a parameterized query. */
export async function query(text, params) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const ms = Date.now() - start;
  if (ms > 500) console.warn(`Slow query (${ms}ms): ${text.slice(0, 80)}`);
  return res;
}

/** Helper: run a transaction. */
export async function withTransaction(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}
