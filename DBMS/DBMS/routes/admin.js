/**
 * Admin Routes
 * GET /api/admin/customers    - All customers
 * GET /api/admin/accounts     - All accounts
 * GET /api/admin/transactions - All transactions
 * GET /api/admin/stats        - Aggregate statistics
 */
const express = require('express');
const router = express.Router();
const { pool } = require('../db/connection');
const { requireAdmin } = require('../middleware/auth');

// All admin routes require admin role
router.use(requireAdmin);

// GET /api/admin/customers
router.get('/customers', async (req, res) => {
  try {
    const [customers] = await pool.query(
      `SELECT c.customer_id, c.first_name, c.last_name, c.email, c.phone, c.customer_type,
              c.registration_date, c.status, COUNT(a.account_id) AS account_count,
              COALESCE(SUM(a.balance), 0) AS total_balance
       FROM Customer c LEFT JOIN Account a ON c.customer_id = a.customer_id
       GROUP BY c.customer_id ORDER BY c.customer_id`
    );
    res.json({ customers });
  } catch (error) {
    console.error('Admin customers error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/admin/accounts
router.get('/accounts', async (req, res) => {
  try {
    const [accounts] = await pool.query(
      `SELECT a.account_id, a.account_number, a.account_type, a.balance, a.status,
              a.branch_code, a.opening_date, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
       FROM Account a JOIN Customer c ON a.customer_id = c.customer_id
       ORDER BY a.account_id`
    );
    res.json({ accounts });
  } catch (error) {
    console.error('Admin accounts error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/admin/transactions
router.get('/transactions', async (req, res) => {
  try {
    const [transactions] = await pool.query(
      `SELECT t.transaction_id, t.transaction_type, t.amount, t.transaction_date,
              t.description, t.balance_after, t.reference_number, t.status,
              a.account_number, CONCAT(c.first_name, ' ', c.last_name) AS customer_name
       FROM Transaction t
       JOIN Account a ON t.account_id = a.account_id
       JOIN Customer c ON a.customer_id = c.customer_id
       ORDER BY t.transaction_date DESC LIMIT 100`
    );
    res.json({ transactions });
  } catch (error) {
    console.error('Admin transactions error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/admin/stats
router.get('/stats', async (req, res) => {
  try {
    const [custCount] = await pool.query('SELECT COUNT(*) AS count FROM Customer');
    const [accCount] = await pool.query('SELECT COUNT(*) AS count FROM Account WHERE status = ?', ['Active']);
    const [totalBal] = await pool.query('SELECT COALESCE(SUM(balance), 0) AS total FROM Account WHERE status = ?', ['Active']);
    const [loanCount] = await pool.query('SELECT COUNT(*) AS count FROM Loan WHERE status = ?', ['Disbursed']);
    const [totalLoans] = await pool.query('SELECT COALESCE(SUM(outstanding_amount), 0) AS total FROM Loan WHERE status = ?', ['Disbursed']);
    const [txnCount] = await pool.query('SELECT COUNT(*) AS count FROM Transaction');
    res.json({
      totalCustomers: custCount[0].count,
      activeAccounts: accCount[0].count,
      totalBalance: totalBal[0].total,
      activeLoans: loanCount[0].count,
      totalOutstanding: totalLoans[0].total,
      totalTransactions: txnCount[0].count
    });
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/admin/loans/flag
router.get('/loans/flag', async (req, res) => {
  try {
    const [results] = await pool.query('CALL sp_flag_high_outstanding_loans()');
    res.json({ flaggedLoans: results[0] });
  } catch (error) {
    console.error('Admin flag loans error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/admin/accounts/interest
router.post('/accounts/interest', async (req, res) => {
  try {
    const [results] = await pool.query('CALL sp_calculate_interest_all_accounts()');
    res.json({ interestCalculation: results[0] });
  } catch (error) {
    console.error('Admin calculate interest error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
