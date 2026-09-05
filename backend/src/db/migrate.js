import 'dotenv/config';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { pool } from './pool.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

/** Runs schema.sql against the configured database. */
async function migrate() {
  const sql = readFileSync(join(__dirname, 'schema.sql'), 'utf-8');
  console.log('Running migrations...');
  try {
    await pool.query(sql);
    console.log('✅ Migrations applied successfully.');
  } catch (e) {
    console.error('❌ Migration failed:', e.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

migrate();
