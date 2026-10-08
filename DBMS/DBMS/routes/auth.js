/**
 * Authentication Routes
 * POST /api/login  - Customer/Admin login
 * POST /api/register - New customer registration
 */

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { pool } = require('../db/connection');
const { generateToken } = require('../middleware/auth');
const cryptoUtils = require('../utils/crypto');

// POST /api/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    // Find user by email
    const [users] = await pool.query(
      'SELECT * FROM UserAuth WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const user = users[0];

    // Compare password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    // Get customer details if not admin
    let customerData = null;
    if (user.role === 'customer' && user.customer_id) {
      const [customers] = await pool.query(
        'SELECT customer_id, first_name, last_name, email, phone, customer_type, status FROM Customer WHERE customer_id = ?',
        [user.customer_id]
      );
      if (customers.length > 0) {
        customerData = customers[0];
      }
    }

    // Generate JWT token
    const token = generateToken(user);

    res.json({
      message: 'Login successful',
      token,
      user: {
        authId: user.auth_id,
        customerId: user.customer_id,
        email: user.email,
        role: user.role,
        customer: customerData
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/register
router.post('/register', async (req, res) => {
  try {
    const {
      first_name, last_name, date_of_birth, email, phone,
      address, pan_number, aadhar_number, customer_type, password
    } = req.body;

    // Validate required fields
    if (!first_name || !last_name || !date_of_birth || !email || !phone || !pan_number || !aadhar_number || !password) {
      return res.status(400).json({ error: 'All required fields must be provided.' });
    }

    // Check if email already exists
    const [existing] = await pool.query(
      'SELECT * FROM UserAuth WHERE email = ?',
      [email]
    );
    if (existing.length > 0) {
      return res.status(409).json({ error: 'Email already registered.' });
    }

    // Encrypt Aadhaar Data
    const aadhaar_encrypted = cryptoUtils.encrypt(aadhar_number);
    const aadhaar_fingerprint = cryptoUtils.generateFingerprint(aadhar_number);
    const aadhaar_last4 = aadhar_number ? aadhar_number.slice(-4) : null;

    // Create customer record
    const [customerResult] = await pool.query(
      `INSERT INTO Customer (first_name, last_name, date_of_birth, email, phone, address, pan_number, aadhar_number, aadhaar_encrypted, aadhaar_fingerprint, aadhaar_last4, customer_type) 
       VALUES (?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, ?, ?)`,
      [first_name, last_name, date_of_birth, email, phone, address || null, pan_number, aadhaar_encrypted, aadhaar_fingerprint, aadhaar_last4, customer_type || 'Individual']
    );

    const customerId = customerResult.insertId;

    // Create auth record
    const passwordHash = await bcrypt.hash(password, 10);
    await pool.query(
      'INSERT INTO UserAuth (customer_id, email, password_hash, role) VALUES (?, ?, ?, ?)',
      [customerId, email, passwordHash, 'customer']
    );

    res.status(201).json({
      message: 'Registration successful. Please login.',
      customerId
    });

  } catch (error) {
    console.error('Registration error:', error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({ error: 'Email, PAN, or Aadhar already exists.' });
    }
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
