/**
 * Database Initialization Script
 * Creates UserAuth table if not exists and seeds default accounts
 */

const { pool } = require('./connection');
const bcrypt = require('bcryptjs');

async function initializeDatabase() {
  try {
    try {
      const { execSync } = require('child_process');
      const path = require('path');
      console.log('🔄 Running review 2 migration script...');
      const sqlPath = path.join(__dirname, '../database/review2_migration.sql');
      execSync(`mysql -u ${process.env.DB_USER} -p${process.env.DB_PASSWORD} ${process.env.DB_NAME} -e "source ${sqlPath.replace(/\\/g, '/')}"`);
      console.log('✅ Migration script executed successfully');
    } catch (e) {
      console.error('❌ Migration failed (check if mysql CLI is in PATH):', e.message);
    }

    // Create UserAuth table for authentication
    await pool.query(`
      CREATE TABLE IF NOT EXISTS UserAuth (
        auth_id INT PRIMARY KEY AUTO_INCREMENT,
        customer_id INT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('customer', 'admin') DEFAULT 'customer',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
      )
    `);
    console.log('✅ UserAuth table ready');

    // Check if admin exists
    const [admins] = await pool.query(
      'SELECT * FROM UserAuth WHERE role = ? LIMIT 1',
      ['admin']
    );

    if (admins.length === 0) {
      // Seed default admin account
      const adminHash = await bcrypt.hash('admin123', 10);
      await pool.query(
        'INSERT INTO UserAuth (customer_id, email, password_hash, role) VALUES (?, ?, ?, ?)',
        [null, 'admin@securebank.com', adminHash, 'admin']
      );
      console.log('✅ Default admin account created (admin@securebank.com / admin123)');
    }

    // Seed demo customer passwords for existing customers
    const [customers] = await pool.query('SELECT customer_id, email FROM Customer');
    for (const customer of customers) {
      const [existing] = await pool.query(
        'SELECT * FROM UserAuth WHERE customer_id = ?',
        [customer.customer_id]
      );
      if (existing.length === 0) {
        // Default password: password123
        const hash = await bcrypt.hash('password123', 10);
        await pool.query(
          'INSERT INTO UserAuth (customer_id, email, password_hash, role) VALUES (?, ?, ?, ?)',
          [customer.customer_id, customer.email, hash, 'customer']
        );
      }
    }
    console.log('✅ Demo customer accounts seeded (password: password123)');

  } catch (error) {
    console.error('❌ Database initialization error:', error.message);
    throw error;
  }
}

module.exports = { initializeDatabase };
