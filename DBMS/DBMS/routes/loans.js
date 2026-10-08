/**
 * Loan Routes
 * GET /api/loans/:customerId       - All loans for customer
 * GET /api/loans/payments/:loanId  - Payment history for a loan
 */
const express = require('express');
const router = express.Router();
const { pool } = require('../db/connection');

// GET /api/loans/:customerId
router.get('/:customerId', async (req, res) => {
  try {
    const { customerId } = req.params;
    if (req.user.role !== 'admin' && req.user.customerId !== parseInt(customerId)) {
      return res.status(403).json({ error: 'Access denied.' });
    }
    const [loans] = await pool.query(
      `SELECT loan_id, loan_type, loan_amount, interest_rate, tenure_months, monthly_emi,
              outstanding_amount, application_date, approval_date, disbursement_date, status
       FROM Loan WHERE customer_id = ? ORDER BY application_date DESC`,
      [customerId]
    );
    res.json({ loans });
  } catch (error) {
    console.error('Loans error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/loans/payments/:loanId
router.get('/payments/:loanId', async (req, res) => {
  try {
    const { loanId } = req.params;
    const [loan] = await pool.query('SELECT * FROM Loan WHERE loan_id = ?', [loanId]);
    if (loan.length === 0) return res.status(404).json({ error: 'Loan not found.' });
    if (req.user.role !== 'admin' && req.user.customerId !== loan[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }
    const [payments] = await pool.query(
      `SELECT payment_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method
       FROM Loan_Payment WHERE loan_id = ? ORDER BY payment_date DESC`,
      [loanId]
    );
    res.json({ loan: loan[0], payments });
  } catch (error) {
    console.error('Loan payments error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/loans/pay
router.post('/pay', async (req, res) => {
  try {
    const { loanId, accountId, amount } = req.body;
    
    if (!loanId || !accountId || !amount) {
      return res.status(400).json({ error: 'loanId, accountId, and amount are required.' });
    }
    
    // Call the stored procedure sp_make_loan_payment
    const [result] = await pool.query(
      'CALL sp_make_loan_payment(?, ?, ?, ?, ?)',
      [loanId, accountId, amount, req.user.authId, req.user.role]
    );
    
    const paymentResult = result[0][0];
    res.json({ message: 'Payment successful', result: paymentResult });
  } catch (error) {
    console.error('Loan payment error:', error);
    if (error.sqlState === '45000') {
      return res.status(400).json({ error: error.message });
    }
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
