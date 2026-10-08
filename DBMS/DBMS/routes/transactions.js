/**
 * Transaction Routes
 * POST /api/transactions/deposit   - Deposit money
 * POST /api/transactions/withdraw  - Withdraw money
 * POST /api/transactions/transfer  - Transfer between accounts
 * GET  /api/transactions/:accountId - Transaction history
 */
const express = require('express');
const router = express.Router();
const { pool } = require('../db/connection');

function generateRefNumber(prefix = 'TXN') {
  const ts = Date.now().toString().slice(-10);
  const r = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `${prefix}${ts}${r}`;
}

// POST /api/transactions/deposit
router.post('/deposit', async (req, res) => {
  try {
    const { account_id, amount, description } = req.body;
    if (!account_id || !amount || amount <= 0) {
      return res.status(400).json({ error: 'Valid account ID and positive amount required.' });
    }
    const [accounts] = await pool.query('SELECT * FROM Account WHERE account_id = ? AND status = ?', [account_id, 'Active']);
    if (accounts.length === 0) return res.status(404).json({ error: 'Active account not found.' });
    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }
    const newBalance = parseFloat(accounts[0].balance) + parseFloat(amount);
    const refNumber = generateRefNumber('TXN');
    const [result] = await pool.query(
      `INSERT INTO Transaction (account_id, transaction_type, amount, description, balance_after, reference_number, status) VALUES (?, 'Deposit', ?, ?, ?, ?, 'Completed')`,
      [account_id, amount, description || 'Cash Deposit', newBalance, refNumber]
    );
    await pool.query('UPDATE Account SET balance = ? WHERE account_id = ?', [newBalance, account_id]);
    res.json({ message: 'Deposit successful.', transaction: { transaction_id: result.insertId, type: 'Deposit', amount: parseFloat(amount), balance_after: newBalance, reference_number: refNumber } });
  } catch (error) {
    console.error('Deposit error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/transactions/withdraw
router.post('/withdraw', async (req, res) => {
  try {
    const { account_id, amount, description } = req.body;
    if (!account_id || !amount || amount <= 0) {
      return res.status(400).json({ error: 'Valid account ID and positive amount required.' });
    }
    const [accounts] = await pool.query('SELECT * FROM Account WHERE account_id = ? AND status = ?', [account_id, 'Active']);
    if (accounts.length === 0) return res.status(404).json({ error: 'Active account not found.' });
    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }
    const currentBalance = parseFloat(accounts[0].balance);
    const minBalance = parseFloat(accounts[0].minimum_balance);
    if (currentBalance - parseFloat(amount) < minBalance) {
      return res.status(400).json({ error: `Insufficient funds. Min balance ₹${minBalance} required.` });
    }
    const newBalance = currentBalance - parseFloat(amount);
    const refNumber = generateRefNumber('TXN');
    const [result] = await pool.query(
      `INSERT INTO Transaction (account_id, transaction_type, amount, description, balance_after, reference_number, status) VALUES (?, 'Withdrawal', ?, ?, ?, ?, 'Completed')`,
      [account_id, amount, description || 'Withdrawal', newBalance, refNumber]
    );
    await pool.query('UPDATE Account SET balance = ? WHERE account_id = ?', [newBalance, account_id]);
    res.json({ message: 'Withdrawal successful.', transaction: { transaction_id: result.insertId, type: 'Withdrawal', amount: parseFloat(amount), balance_after: newBalance, reference_number: refNumber } });
  } catch (error) {
    console.error('Withdrawal error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// POST /api/transactions/transfer
router.post('/transfer', async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { from_account_id, to_account_number, amount, transfer_type, remarks } = req.body;
    if (!from_account_id || !to_account_number || !amount || amount <= 0) {
      connection.release();
      return res.status(400).json({ error: 'From account, to account number, and positive amount required.' });
    }
    await connection.beginTransaction();
    const [fromAccs] = await connection.query('SELECT * FROM Account WHERE account_id = ? AND status = ?', [from_account_id, 'Active']);
    if (fromAccs.length === 0) { await connection.rollback(); connection.release(); return res.status(404).json({ error: 'Source account not found.' }); }
    if (req.user.role !== 'admin' && req.user.customerId !== fromAccs[0].customer_id) { await connection.rollback(); connection.release(); return res.status(403).json({ error: 'Access denied.' }); }
    const [toAccs] = await connection.query('SELECT * FROM Account WHERE account_number = ? AND status = ?', [to_account_number, 'Active']);
    if (toAccs.length === 0) { await connection.rollback(); connection.release(); return res.status(404).json({ error: 'Destination account not found.' }); }
    const fromBal = parseFloat(fromAccs[0].balance);
    const minBal = parseFloat(fromAccs[0].minimum_balance);
    const amt = parseFloat(amount);
    if (fromBal - amt < minBal) { await connection.rollback(); connection.release(); return res.status(400).json({ error: `Insufficient funds. Min balance ₹${minBal} required.` }); }
    const newFromBal = fromBal - amt;
    const newToBal = parseFloat(toAccs[0].balance) + amt;
    const txnRef1 = generateRefNumber('TXN');
    const txnRef2 = generateRefNumber('TXN');
    const trfRef = generateRefNumber('TRF');
    await connection.query(`INSERT INTO Transaction (account_id, transaction_type, amount, description, balance_after, reference_number, status) VALUES (?, 'Transfer', ?, ?, ?, ?, 'Completed')`, [from_account_id, amt, `Transfer to ${to_account_number}`, newFromBal, txnRef1]);
    await connection.query(`INSERT INTO Transaction (account_id, transaction_type, amount, description, balance_after, reference_number, status) VALUES (?, 'Deposit', ?, ?, ?, ?, 'Completed')`, [toAccs[0].account_id, amt, `Transfer from ${fromAccs[0].account_number}`, newToBal, txnRef2]);
    await connection.query(`INSERT INTO Fund_Transfer (from_account_id, to_account_id, amount, transfer_type, reference_number, remarks, status) VALUES (?, ?, ?, ?, ?, ?, 'Completed')`, [from_account_id, toAccs[0].account_id, amt, transfer_type || 'Internal', trfRef, remarks || '']);
    await connection.query('UPDATE Account SET balance = ? WHERE account_id = ?', [newFromBal, from_account_id]);
    await connection.query('UPDATE Account SET balance = ? WHERE account_id = ?', [newToBal, toAccs[0].account_id]);
    await connection.commit();
    connection.release();
    res.json({ message: 'Transfer successful.', transfer: { from_account: fromAccs[0].account_number, to_account: to_account_number, amount: amt, reference_number: trfRef, from_balance_after: newFromBal } });
  } catch (error) {
    await connection.rollback();
    connection.release();
    console.error('Transfer error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

// GET /api/transactions/:accountId
router.get('/:accountId', async (req, res) => {
  try {
    const { accountId } = req.params;
    const [accounts] = await pool.query('SELECT * FROM Account WHERE account_id = ?', [accountId]);
    if (accounts.length === 0) return res.status(404).json({ error: 'Account not found.' });
    if (req.user.role !== 'admin' && req.user.customerId !== accounts[0].customer_id) {
      return res.status(403).json({ error: 'Access denied.' });
    }
    const [transactions] = await pool.query(
      `SELECT transaction_id, transaction_type, amount, transaction_date, description, balance_after, reference_number, status FROM Transaction WHERE account_id = ? ORDER BY transaction_date DESC`,
      [accountId]
    );
    res.json({ transactions, account: accounts[0] });
  } catch (error) {
    console.error('Transaction history error:', error);
    res.status(500).json({ error: 'Internal server error.' });
  }
});

module.exports = router;
