/**
 * Database Connection Module
 * Primary: MySQL Connection Pool
 * Fallback: Embedded In-Memory Demo Database Engine (Zero Setup)
 */

const mysql = require('mysql2/promise');
require('dotenv').config();
const mockDb = require('./mockDb');

let useMock = false;

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'securebank',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  multipleStatements: false
});

// Proxy pool for seamless query redirection
const dbProxy = {
  async query(sql, params) {
    if (useMock) {
      return mockDb.query(sql, params);
    }
    try {
      return await pool.query(sql, params);
    } catch (err) {
      console.warn('⚠️  MySQL Query failed, falling back to Demo Database:', err.message);
      useMock = true;
      return mockDb.query(sql, params);
    }
  },

  async getConnection() {
    if (useMock) {
      return mockDb.getConnection();
    }
    try {
      return await pool.getConnection();
    } catch (err) {
      console.warn('⚠️  MySQL Connection failed, falling back to Demo Database:', err.message);
      useMock = true;
      return mockDb.getConnection();
    }
  }
};

// Test connection on startup
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ MySQL Database connected successfully (Live MySQL Mode)');
    connection.release();
    useMock = false;
    return true;
  } catch (error) {
    console.log('ℹ️  MySQL not detected on localhost. Activating In-Memory Demo Database Engine.');
    console.log('✅ In-Memory Demo Database Engine ready (Zero-Setup Mode)');
    useMock = true;
    return true; // Return true so server continues seamlessly!
  }
}

module.exports = { pool: dbProxy, testConnection };

