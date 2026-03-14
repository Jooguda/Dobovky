const { Pool } = require('pg');

// PostgreSQL connection pool setup
const pool = new Pool({
  user: 'your_user', // replace with your database user
  host: 'localhost',
  database: 'blog',
  password: 'your_password', // replace with your database password
  port: 5432,
});

module.exports = pool;