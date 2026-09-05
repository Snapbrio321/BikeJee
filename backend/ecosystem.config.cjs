/**
 * PM2 cluster configuration.
 *
 * `instances: 'max'` forks one Node process per CPU core. Node is single-
 * threaded, so on a 4-core box this gives ~4x throughput. PM2 load-balances
 * incoming connections across the workers, and because real-time state lives
 * in Redis (Socket.IO adapter) and Postgres, any worker can serve any request.
 *
 * Start:   pm2 start ecosystem.config.cjs
 * Reload:  pm2 reload bikejee   (zero-downtime — workers restart one by one)
 * Logs:    pm2 logs bikejee
 * Monitor: pm2 monit
 */
module.exports = {
  apps: [
    {
      name: 'bikejee',
      script: 'src/server.js',
      instances: process.env.PM2_INSTANCES || 'max',
      exec_mode: 'cluster',
      max_memory_restart: '500M', // restart a worker if it leaks past 500MB
      kill_timeout: 10000,        // give graceful shutdown 10s (matches server.js)
      wait_ready: false,
      autorestart: true,
      env: {
        NODE_ENV: 'production',
      },
      // Log files (PM2 rotates with pm2-logrotate module)
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      merge_logs: true,
      time: true,
    },
  ],
};
