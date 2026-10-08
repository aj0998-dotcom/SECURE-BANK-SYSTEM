/**
 * Account Management Routes
 * GET    /api/accounts/:customerId     - List all accounts
 * POST   /api/accounts                 - Create new account
 * GET    /api/accounts/detail/:accountId - Get single account
 * PUT    /api/accounts/:accountId      - Update account info
 * DELETE /api/accounts/:accountId      - Close account
 */

const express = require('express');
const router = express.Router();
const { pool } = require('../db/connection');

// Generate a random 16-digit account number
function generateAccountNumber() {
  let num = '';
  for (let i = 0; i < 16; i++) {
    num += Math.floor(Math.random() * 10).toString();
  }
  return num;
}

// GET /api/accounts/:customerId - List all accounts for a customer
router.get('/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;

    // Verify access
    if (req.user.role !== 'admin' && req.user.customerId !== parseInt(customerId)) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    const [accounts] = await pool.query(
      `SELECT a.account_id, a.account_number, a.account_type, a.balance, 
              a.interest_rate, a.opening_date, a.branch_code, a.status, a.minimum_balance,
              c.first_name, c.last_name
       FROM Account a
       JOIN Customer c ON a.customer_id = c.customer_id
       WHERE a.customer_id = ?
       ORDER BY a.opening_date DESC`,
      [customerId]
    );

    res.json({ accounts });

  } catch (error) {
    console.error('List accounts error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/accounts/detail/:accountId - Get single account details
router.get('/detail/:accountId', async (req, res) => {
  try {
    const { accountId } = req.params;

    const [accounts] = await pool.query(
      `SELECT a.*, c.first_name, c.last_name, c.email, c.phone
       FROM Account a
       JOIN Customer c ON a.customer_id = c.customer_id
       WHERE a.account_id = ?`,
      [accountId]
    );

    if (accounts.length === 0) {
      return res.status(404).json({ error: 'Account not found.' });
    }

    // Verify access
    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    // Get associated cards
    const [cards] = await pool.query(
      `SELECT card_id, card_number, card_type, expiry_date, daily_limit, status, issue_date
       FROM Card WHERE account_id = ?`,
      [accountId]
    );

    res.json({ account: accounts[0], cards });

  } catch (error) {
    console.error('Account detail error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/accounts - Create new account
router.post('/', async (req, res) => {
  try {
    const { customer_id, account_type, branch_code, initial_deposit } = req.body;

    // Verify access
    if (req.user.role !== 'admin' && req.user.customerId !== parseInt(customer_id)) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    // Validate
    if (!customer_id || !account_type) {
      return res.status(400).json({ error: 'Customer ID and account type are required.' });
    }

    const validTypes = ['Savings', 'Current', 'Fixed Deposit'];
    if (!validTypes.includes(account_type)) {
      return res.status(400).json({ error: 'Invalid account type.' });
    }

    // Set interest rate based on type
    let interest_rate = 0.00;
    if (account_type === 'Savings') interest_rate = 4.00;
    if (account_type === 'Fixed Deposit') interest_rate = 6.50;

    const account_number = generateAccountNumber();
    const balance = parseFloat(initial_deposit) || 0.00;
    const opening_date = new Date().toISOString().split('T')[0];

    const [result] = await pool.query(
      `INSERT INTO Account (customer_id, account_number, account_type, balance, interest_rate, opening_date, branch_code)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [customer_id, account_number, account_type, balance, interest_rate, opening_date, branch_code || 'CHN001']
    );

    res.status(201).json({
      message: 'Account created successfully.',
      account: {
        account_id: result.insertId,
        account_number,
        account_type,
        balance,
        interest_rate,
        opening_date,
        branch_code: branch_code || 'CHN001',
        status: 'Active'
      }
    });

  } catch (error) {
    console.error('Create account error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// PUT /api/accounts/:accountId - Update account
router.put('/:accountId', async (req, res) => {
  try {
    const { accountId } = req.params;
    const { branch_code, minimum_balance } = req.body;

    // Verify account exists and user has access
    const [accounts] = await pool.query('SELECT * FROM Account WHERE account_id = ?', [accountId]);
    if (accounts.length === 0) {
      return res.status(404).json({ error: 'Account not found.' });
    }

    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    const updates = [];
    const values = [];

    if (branch_code) { updates.push('branch_code = ?'); values.push(branch_code); }
    if (minimum_balance !== undefined) { updates.push('minimum_balance = ?'); values.push(minimum_balance); }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update.' });
    }

    values.push(accountId);
    await pool.query(`UPDATE Account SET ${updates.join(', ')} WHERE account_id = ?`, values);

    res.json({ message: 'Account updated successfully.' });

  } catch (error) {
    console.error('Update account error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// DELETE /api/accounts/:accountId - Close account
router.delete('/:accountId', async (req, res) => {
  try {
    const { accountId } = req.params;

    const [accounts] = await pool.query('SELECT * FROM Account WHERE account_id = ?', [accountId]);
    if (accounts.length === 0) {
      return res.status(404).json({ error: 'Account not found.' });
    }

    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    if (accounts[0].status === 'Closed') {
      return res.status(400).json({ error: 'Account is already closed.' });
    }

    // Set status to 'Closed' instead of deleting
    await pool.query("UPDATE Account SET status = 'Closed' WHERE account_id = ?", [accountId]);

    res.json({ message: 'Account closed successfully.' });

  } catch (error) {
    console.error('Close account error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
