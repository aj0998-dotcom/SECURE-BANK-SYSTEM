/**
 * Secure Bank Management System - Express Server
 * Main entry point
 */
const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();
require('./db/readPpt');

const { testConnection } = require('./db/connection');

const { initializeDatabase } = require('./db/init');
const { authenticateToken } = require('./middleware/auth');

// Import routes
const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
const accountRoutes = require('./routes/accounts');
const transactionRoutes = require('./routes/transactions');
const loanRoutes = require('./routes/loans');
const adminRoutes = require('./routes/admin');
const kycRoutes = require('./routes/kyc');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// PPT extract endpoint
app.get('/api/ppt-extract', (req, res) => {
  try {
    const fs = require('fs');
    const path = require('path');
    const readPpt = require('./db/readPpt');
    readPpt();
    const txtPath = path.join(__dirname, 'ppt_text_output.txt');
    if (fs.existsSync(txtPath)) {
      const content = fs.readFileSync(txtPath, 'utf8');
      return res.type('text/plain').send(content);
    }
    res.status(404).send('PPT output not found');
  } catch (err) {
    res.status(500).send(err.message);
  }
});

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'public')));


// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/dashboard', authenticateToken, dashboardRoutes);
app.use('/api/accounts', authenticateToken, accountRoutes);
app.use('/api/transactions', authenticateToken, transactionRoutes);
app.use('/api/loans', authenticateToken, loanRoutes);
app.use('/api/admin', authenticateToken, adminRoutes);
app.use('/api/kyc', kycRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// PPT extract endpoint
app.get('/api/ppt-extract', (req, res) => {
  try {
    const fs = require('fs');
    const path = require('path');
    const readPpt = require('./db/readPpt');
    readPpt();
    const txtPath = path.join(__dirname, 'ppt_text_output.txt');
    if (fs.existsSync(txtPath)) {
      const content = fs.readFileSync(txtPath, 'utf8');
      return res.type('text/plain').send(content);
    }
    res.status(404).send('PPT output not found');
  } catch (err) {
    res.status(500).send(err.message);
  }
});


// Catch-all: serve index.html for SPA-style navigation
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
async function startServer() {
  const dbConnected = await testConnection();
  if (!dbConnected) {
    console.error('Cannot start server without database connection.');
    process.exit(1);
  }
  await initializeDatabase();
  app.listen(PORT, () => {
    console.log(`\n🏦 Secure Bank Management System`);
    console.log(`   Server running at http://localhost:${PORT}`);
    console.log(`   API base: http://localhost:${PORT}/api\n`);
  });
}

startServer();
