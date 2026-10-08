/**
 * Dashboard Routes
 * GET /api/dashboard/:customerId - Full dashboard data
 */

const express = require('express');
const router = express.Router();
const { pool } = require('../db/connection');

// GET /api/dashboard/:customerId
router.get('/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;

    // Verify the user can only access their own dashboard (unless admin)
    if (req.user.role !== 'admin' && req.user.customerId !== parseInt(customerId)) {
      return res.status(403).json({ error: 'Access denied.' });
    }

    // Get customer details
    const [customers] = await pool.query(
      `SELECT customer_id, first_name, last_name, date_of_birth, email, phone, 
              address, pan_number, aadhar_number, customer_type, registration_date, status 
       FROM Customer WHERE customer_id = ?`,
      [customerId]
    );

    if (customers.length === 0) {
      return res.status(404).json({ error: 'Customer not found.' });
    }

    // Get all accounts
    const [accounts] = await pool.query(
      `SELECT account_id, account_number, account_type, balance, interest_rate, 
              opening_date, branch_code, status, minimum_balance 
       FROM Account WHERE customer_id = ? ORDER BY opening_date DESC`,
      [customerId]
    );

    // Get recent transactions (last 10 across all accounts)
    const accountIds = accounts.map(a => a.account_id);
    let recentTransactions = [];
    if (accountIds.length > 0) {
      const placeholders = accountIds.map(() => '?').join(',');
      const [transactions] = await pool.query(
        `SELECT t.transaction_id, t.account_id, a.account_number, t.transaction_type, 
                t.amount, t.transaction_date, t.description, t.balance_after, 
                t.reference_number, t.status 
         FROM Transaction t 
         JOIN Account a ON t.account_id = a.account_id 
         WHERE t.account_id IN (${placeholders}) 
         ORDER BY t.transaction_date DESC LIMIT 10`,
        accountIds
      );
      recentTransactions = transactions;
    }

    // Get active loans
    const [loans] = await pool.query(
      `SELECT loan_id, loan_type, loan_amount, interest_rate, tenure_months, 
              monthly_emi, outstanding_amount, status 
       FROM Loan WHERE customer_id = ? ORDER BY application_date DESC`,
      [customerId]
    );

    // Calculate totals
    const totalBalance = accounts.reduce((sum, acc) => sum + parseFloat(acc.balance), 0);
    const activeAccounts = accounts.filter(a => a.status === 'Active').length;
    const totalOutstanding = loans.reduce((sum, l) => sum + parseFloat(l.outstanding_amount || 0), 0);

    res.json({
      customer: customers[0],
      accounts,
      recentTransactions,
      loans,
      summary: {
        totalBalance,
        activeAccounts,
        totalAccounts: accounts.length,
        totalLoans: loans.length,
        totalOutstanding
      }
    });

  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
