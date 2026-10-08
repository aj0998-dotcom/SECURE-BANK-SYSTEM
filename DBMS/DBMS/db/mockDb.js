/**
 * In-Memory Demo Database Engine
 * Fallback when MySQL is not running locally.
 * Provides full CRUD operations matching MySQL query output structures.
 */

const bcrypt = require('bcryptjs');

class MockDatabase {
  constructor() {
    this.reset();
  }

  reset() {
    const passwordHash = bcrypt.hashSync('password123', 10);
    const adminHash = bcrypt.hashSync('admin123', 10);

    this.tables = {
      Customer: [
        { customer_id: 1, first_name: 'Rajesh', last_name: 'Kumar', date_of_birth: '1985-06-15', email: 'rajesh.kumar@email.com', phone: '9876543210', address: '123 MG Road, Chennai', pan_number: 'ABCDE1234F', aadhar_number: '123456789012', customer_type: 'Individual', registration_date: '2020-01-15 10:00:00', status: 'Active' },
        { customer_id: 2, first_name: 'Priya', last_name: 'Sharma', date_of_birth: '1990-03-22', email: 'priya.sharma@email.com', phone: '9876543211', address: '456 Anna Nagar, Chennai', pan_number: 'FGHIJ5678K', aadhar_number: '234567890123', customer_type: 'Individual', registration_date: '2019-05-20 10:00:00', status: 'Active' },
        { customer_id: 3, first_name: 'Vikram', last_name: 'Reddy', date_of_birth: '1982-11-08', email: 'vikram.reddy@email.com', phone: '9876543212', address: '789 T Nagar, Chennai', pan_number: 'LMNOP9012Q', aadhar_number: '345678901234', customer_type: 'Individual', registration_date: '2018-08-10 10:00:00', status: 'Active' },
        { customer_id: 4, first_name: 'Anjali', last_name: 'Patel', date_of_birth: '1995-07-30', email: 'anjali.patel@email.com', phone: '9876543213', address: '321 Adyar, Chennai', pan_number: 'RSTUV3456W', aadhar_number: '456789012345', customer_type: 'Individual', registration_date: '2021-03-25 10:00:00', status: 'Active' },
        { customer_id: 5, first_name: 'TechCorp Solutions', last_name: 'Pvt Ltd', date_of_birth: '2010-01-01', email: 'info@techcorp.com', phone: '9876543214', address: '555 IT Park, Chennai', pan_number: 'XYZAB7890C', aadhar_number: '567890123456', customer_type: 'Business', registration_date: '2015-11-05 10:00:00', status: 'Active' }
      ],
      UserAuth: [
        { auth_id: 1, customer_id: null, email: 'admin@securebank.com', password_hash: adminHash, role: 'admin', created_at: new Date().toISOString() },
        { auth_id: 2, customer_id: 1, email: 'rajesh.kumar@email.com', password_hash: passwordHash, role: 'customer', created_at: new Date().toISOString() },
        { auth_id: 3, customer_id: 2, email: 'priya.sharma@email.com', password_hash: passwordHash, role: 'customer', created_at: new Date().toISOString() },
        { auth_id: 4, customer_id: 3, email: 'vikram.reddy@email.com', password_hash: passwordHash, role: 'customer', created_at: new Date().toISOString() },
        { auth_id: 5, customer_id: 4, email: 'anjali.patel@email.com', password_hash: passwordHash, role: 'customer', created_at: new Date().toISOString() },
        { auth_id: 6, customer_id: 5, email: 'info@techcorp.com', password_hash: passwordHash, role: 'customer', created_at: new Date().toISOString() }
      ],
      Account: [
        { account_id: 1, customer_id: 1, account_number: '1234567890123456', account_type: 'Savings', balance: 50000.00, interest_rate: 4.00, opening_date: '2020-01-15', branch_code: 'CHN001', status: 'Active', minimum_balance: 1000.00 },
        { account_id: 2, customer_id: 2, account_number: '2345678901234567', account_type: 'Savings', balance: 75000.00, interest_rate: 4.00, opening_date: '2019-05-20', branch_code: 'CHN001', status: 'Active', minimum_balance: 1000.00 },
        { account_id: 3, customer_id: 3, account_number: '3456789012345678', account_type: 'Current', balance: 120000.00, interest_rate: 0.00, opening_date: '2018-08-10', branch_code: 'CHN002', status: 'Active', minimum_balance: 1000.00 },
        { account_id: 4, customer_id: 4, account_number: '4567890123456789', account_type: 'Savings', balance: 35000.00, interest_rate: 4.00, opening_date: '2021-03-25', branch_code: 'CHN001', status: 'Active', minimum_balance: 1000.00 },
        { account_id: 5, customer_id: 5, account_number: '5678901234567890', account_type: 'Current', balance: 500000.00, interest_rate: 0.00, opening_date: '2015-11-05', branch_code: 'CHN002', status: 'Active', minimum_balance: 1000.00 },
        { account_id: 6, customer_id: 1, account_number: '6789012345678901', account_type: 'Fixed Deposit', balance: 200000.00, interest_rate: 6.50, opening_date: '2022-06-01', branch_code: 'CHN001', status: 'Active', minimum_balance: 1000.00 }
      ],
      Transaction: [
        { transaction_id: 1, account_id: 1, transaction_type: 'Deposit', amount: 10000.00, transaction_date: '2024-01-10 10:00:00', description: 'Cash Deposit', balance_after: 60000.00, reference_number: 'TXN001234567890', status: 'Completed' },
        { transaction_id: 2, account_id: 1, transaction_type: 'Withdrawal', amount: 5000.00, transaction_date: '2024-01-12 14:30:00', description: 'ATM Withdrawal', balance_after: 55000.00, reference_number: 'TXN001234567891', status: 'Completed' },
        { transaction_id: 3, account_id: 2, transaction_type: 'Deposit', amount: 25000.00, transaction_date: '2024-01-15 09:00:00', description: 'Salary Credit', balance_after: 100000.00, reference_number: 'TXN001234567892', status: 'Completed' },
        { transaction_id: 4, account_id: 3, transaction_type: 'Withdrawal', amount: 20000.00, transaction_date: '2024-01-18 16:15:00', description: 'Business Payment', balance_after: 100000.00, reference_number: 'TXN001234567893', status: 'Completed' },
        { transaction_id: 5, account_id: 4, transaction_type: 'Deposit', amount: 15000.00, transaction_date: '2024-01-20 11:45:00', description: 'Cash Deposit', balance_after: 50000.00, reference_number: 'TXN001234567894', status: 'Completed' },
        { transaction_id: 6, account_id: 5, transaction_type: 'Deposit', amount: 100000.00, transaction_date: '2024-01-22 15:20:00', description: 'Business Receipt', balance_after: 600000.00, reference_number: 'TXN001234567895', status: 'Completed' }
      ],
      Fund_Transfer: [
        { transfer_id: 1, from_account_id: 1, to_account_id: 2, amount: 5000.00, transfer_date: '2024-01-10 10:05:00', transfer_type: 'Internal', reference_number: 'TRF001234567890', remarks: 'Payment to Priya', status: 'Completed' },
        { transfer_id: 2, from_account_id: 3, to_account_id: 4, amount: 10000.00, transfer_date: '2024-01-12 11:20:00', transfer_type: 'NEFT', reference_number: 'TRF001234567891', remarks: 'Vendor Payment', status: 'Completed' },
        { transfer_id: 3, from_account_id: 5, to_account_id: 1, amount: 25000.00, transfer_date: '2024-01-15 12:00:00', transfer_type: 'RTGS', reference_number: 'TRF001234567892', remarks: 'Salary Payment', status: 'Completed' },
        { transfer_id: 4, from_account_id: 2, to_account_id: 3, amount: 8000.00, transfer_date: '2024-01-18 17:00:00', transfer_type: 'IMPS', reference_number: 'TRF001234567893', remarks: 'Service Payment', status: 'Completed' }
      ],
      Loan: [
        { loan_id: 1, customer_id: 1, loan_type: 'Personal', loan_amount: 200000.00, interest_rate: 10.50, tenure_months: 24, monthly_emi: 9266.00, outstanding_amount: 200000.00, application_date: '2023-01-10', approval_date: '2023-01-15', disbursement_date: '2023-01-20', status: 'Disbursed' },
        { loan_id: 2, customer_id: 2, loan_type: 'Home', loan_amount: 5000000.00, interest_rate: 8.50, tenure_months: 240, monthly_emi: 43391.00, outstanding_amount: 5000000.00, application_date: '2022-06-01', approval_date: '2022-06-10', disbursement_date: '2022-07-01', status: 'Disbursed' },
        { loan_id: 3, customer_id: 3, loan_type: 'Vehicle', loan_amount: 800000.00, interest_rate: 9.00, tenure_months: 60, monthly_emi: 16574.00, outstanding_amount: 800000.00, application_date: '2023-03-15', approval_date: '2023-03-20', disbursement_date: '2023-03-25', status: 'Disbursed' },
        { loan_id: 4, customer_id: 4, loan_type: 'Education', loan_amount: 300000.00, interest_rate: 7.50, tenure_months: 48, monthly_emi: 7234.00, outstanding_amount: 300000.00, application_date: '2023-02-01', approval_date: '2023-02-05', disbursement_date: '2023-02-10', status: 'Disbursed' }
      ],
      Loan_Payment: [
        { payment_id: 1, loan_id: 1, payment_date: '2023-02-20', amount_paid: 9266.00, principal_amount: 7516.00, interest_amount: 1750.00, payment_method: 'Auto Debit', transaction_id: null },
        { payment_id: 2, loan_id: 1, payment_date: '2023-03-20', amount_paid: 9266.00, principal_amount: 7582.00, interest_amount: 1684.00, payment_method: 'Auto Debit', transaction_id: null },
        { payment_id: 3, loan_id: 2, payment_date: '2023-02-01', amount_paid: 43391.00, principal_amount: 8058.00, interest_amount: 35333.00, payment_method: 'Auto Debit', transaction_id: null },
        { payment_id: 4, loan_id: 3, payment_date: '2023-04-25', amount_paid: 16574.00, principal_amount: 10574.00, interest_amount: 6000.00, payment_method: 'Auto Debit', transaction_id: null },
        { payment_id: 5, loan_id: 4, payment_date: '2023-03-10', amount_paid: 7234.00, principal_amount: 5359.00, interest_amount: 1875.00, payment_method: 'Online', transaction_id: null }
      ],
      Card: [
        { card_id: 1, account_id: 1, card_number: '4532123456789012', card_type: 'Debit', expiry_date: '2026-12-31', cvv: '123', daily_limit: 50000.00, status: 'Active', issue_date: '2020-01-20' },
        { card_id: 2, account_id: 2, card_number: '4532234567890123', card_type: 'Debit', expiry_date: '2027-05-31', cvv: '456', daily_limit: 50000.00, status: 'Active', issue_date: '2019-05-25' },
        { card_id: 3, account_id: 3, card_number: '4532345678901234', card_type: 'Debit', expiry_date: '2026-08-31', cvv: '789', daily_limit: 100000.00, status: 'Active', issue_date: '2018-08-15' },
        { card_id: 4, account_id: 4, card_number: '4532456789012345', card_type: 'Debit', expiry_date: '2028-03-31', cvv: '234', daily_limit: 30000.00, status: 'Active', issue_date: '2021-03-30' },
        { card_id: 5, account_id: 5, card_number: '4532567890123456', card_type: 'Debit', expiry_date: '2025-11-30', cvv: '567', daily_limit: 200000.00, status: 'Active', issue_date: '2015-11-10' }
      ]
    };
  }

  async query(sql, params = []) {
    const cleanSql = sql.trim().replace(/\s+/g, ' ');

    // 1. CREATE TABLE IF NOT EXISTS UserAuth
    if (/CREATE TABLE/i.test(cleanSql)) {
      return [{}, []];
    }

    // 2. UserAuth lookup for Admin check on seed
    if (/SELECT \* FROM UserAuth WHERE role = \? LIMIT 1/i.test(cleanSql)) {
      const match = this.tables.UserAuth.filter(u => u.role === params[0]);
      return [match.slice(0, 1), []];
    }

    // 3. UserAuth lookup by email
    if (/SELECT \* FROM UserAuth WHERE email = \?/i.test(cleanSql)) {
      const match = this.tables.UserAuth.filter(u => u.email === params[0]);
      return [match, []];
    }

    // 4. UserAuth lookup by customer_id
    if (/SELECT \* FROM UserAuth WHERE customer_id = \?/i.test(cleanSql)) {
      const match = this.tables.UserAuth.filter(u => u.customer_id === parseInt(params[0]));
      return [match, []];
    }

    // 5. INSERT INTO UserAuth
    if (/INSERT INTO UserAuth/i.test(cleanSql)) {
      const [customer_id, email, password_hash, role] = params;
      const newAuth = {
        auth_id: this.tables.UserAuth.length + 1,
        customer_id: customer_id ? parseInt(customer_id) : null,
        email,
        password_hash,
        role: role || 'customer',
        created_at: new Date().toISOString()
      };
      this.tables.UserAuth.push(newAuth);
      return [{ insertId: newAuth.auth_id }, []];
    }

    // 6. SELECT customer_id, email FROM Customer
    if (/SELECT customer_id, email FROM Customer/i.test(cleanSql)) {
      const res = this.tables.Customer.map(c => ({ customer_id: c.customer_id, email: c.email }));
      return [res, []];
    }

    // 7. Customer lookup by ID
    if (/SELECT .* FROM Customer WHERE customer_id = \?/i.test(cleanSql)) {
      const custId = parseInt(params[0]);
      const match = this.tables.Customer.filter(c => c.customer_id === custId);
      return [match, []];
    }

    // 8. INSERT INTO Customer
    if (/INSERT INTO Customer/i.test(cleanSql)) {
      const [first_name, last_name, date_of_birth, email, phone, address, pan_number, aadhar_number, customer_type] = params;
      const newCust = {
        customer_id: this.tables.Customer.length + 1,
        first_name, last_name, date_of_birth, email, phone, address, pan_number, aadhar_number,
        customer_type: customer_type || 'Individual',
        registration_date: new Date().toISOString(),
        status: 'Active'
      };
      this.tables.Customer.push(newCust);
      return [{ insertId: newCust.customer_id }, []];
    }

    // 9. Accounts for a customer
    if (/SELECT .* FROM Account WHERE customer_id = \?/i.test(cleanSql) && !/JOIN/i.test(cleanSql)) {
      const custId = parseInt(params[0]);
      const res = this.tables.Account.filter(a => a.customer_id === custId);
      return [res, []];
    }

    // 10. Accounts with customer JOIN
    if (/FROM Account a JOIN Customer c ON/i.test(cleanSql) || /FROM Account a JOIN Customer c/i.test(cleanSql)) {
      if (/WHERE a.customer_id = \?/i.test(cleanSql)) {
        const custId = parseInt(params[0]);
        const res = this.tables.Account
          .filter(a => a.customer_id === custId)
          .map(a => {
            const c = this.tables.Customer.find(cust => cust.customer_id === a.customer_id) || {};
            return { ...a, first_name: c.first_name, last_name: c.last_name };
          });
        return [res, []];
      }
      if (/WHERE a.account_id = \?/i.test(cleanSql)) {
        const accId = parseInt(params[0]);
        const a = this.tables.Account.find(acc => acc.account_id === accId);
        if (!a) return [[], []];
        const c = this.tables.Customer.find(cust => cust.customer_id === a.customer_id) || {};
        return [[{ ...a, first_name: c.first_name, last_name: c.last_name, email: c.email, phone: c.phone }], []];
      }
      // Admin list all accounts
      const res = this.tables.Account.map(a => {
        const c = this.tables.Customer.find(cust => cust.customer_id === a.customer_id) || {};
        return {
          account_id: a.account_id,
          account_number: a.account_number,
          account_type: a.account_type,
          balance: a.balance,
          status: a.status,
          branch_code: a.branch_code,
          opening_date: a.opening_date,
          customer_name: `${c.first_name || ''} ${c.last_name || ''}`.trim()
        };
      });
      return [res, []];
    }

    // 11. Single Account lookup without JOIN
    if (/SELECT \* FROM Account WHERE account_id = \?/i.test(cleanSql)) {
      const accId = parseInt(params[0]);
      let res = this.tables.Account.filter(a => a.account_id === accId);
      if (params.length > 1 && params[1]) {
        res = res.filter(a => a.status === params[1]);
      }
      return [res, []];
    }

    // 12. Account lookup by account_number
    if (/SELECT \* FROM Account WHERE account_number = \?/i.test(cleanSql)) {
      const accNum = params[0];
      let res = this.tables.Account.filter(a => a.account_number === accNum);
      if (params.length > 1 && params[1]) {
        res = res.filter(a => a.status === params[1]);
      }
      return [res, []];
    }

    // 13. Cards for an account
    if (/SELECT .* FROM Card WHERE account_id = \?/i.test(cleanSql)) {
      const accId = parseInt(params[0]);
      const res = this.tables.Card.filter(c => c.account_id === accId);
      return [res, []];
    }

    // 14. INSERT INTO Account
    if (/INSERT INTO Account/i.test(cleanSql)) {
      const [customer_id, account_number, account_type, balance, interest_rate, opening_date, branch_code] = params;
      const newAcc = {
        account_id: this.tables.Account.length + 1,
        customer_id: parseInt(customer_id),
        account_number,
        account_type,
        balance: parseFloat(balance) || 0.0,
        interest_rate: parseFloat(interest_rate) || 0.0,
        opening_date,
        branch_code: branch_code || 'CHN001',
        status: 'Active',
        minimum_balance: 1000.00
      };
      this.tables.Account.push(newAcc);
      return [{ insertId: newAcc.account_id }, []];
    }

    // 15. UPDATE Account
    if (/UPDATE Account SET/i.test(cleanSql)) {
      if (/SET status = 'Closed'/i.test(cleanSql)) {
        const accId = parseInt(params[0]);
        const acc = this.tables.Account.find(a => a.account_id === accId);
        if (acc) acc.status = 'Closed';
        return [{ affectedRows: 1 }, []];
      }
      if (/SET balance = \?/i.test(cleanSql)) {
        const balance = parseFloat(params[0]);
        const accId = parseInt(params[1]);
        const acc = this.tables.Account.find(a => a.account_id === accId);
        if (acc) acc.balance = balance;
        return [{ affectedRows: 1 }, []];
      }
      // Dynamic update
      const accId = parseInt(params[params.length - 1]);
      const acc = this.tables.Account.find(a => a.account_id === accId);
      if (acc) {
        if (/branch_code = \?/i.test(cleanSql)) acc.branch_code = params[0];
        if (/minimum_balance = \?/i.test(cleanSql)) acc.minimum_balance = parseFloat(params[params.length - 2]);
      }
      return [{ affectedRows: 1 }, []];
    }

    // 16. Recent Transactions with account IDs IN (...)
    if (/FROM Transaction t JOIN Account a ON/i.test(cleanSql) && /WHERE t.account_id IN/i.test(cleanSql)) {
      const accIds = params.map(id => parseInt(id));
      const txns = this.tables.Transaction
        .filter(t => accIds.includes(t.account_id))
        .map(t => {
          const a = this.tables.Account.find(acc => acc.account_id === t.account_id) || {};
          return { ...t, account_number: a.account_number };
        })
        .sort((a, b) => new Date(b.transaction_date) - new Date(a.transaction_date))
        .slice(0, 10);
      return [txns, []];
    }

    // 17. Admin list transactions with Account & Customer JOIN
    if (/FROM Transaction t JOIN Account a ON t.account_id = a.account_id JOIN Customer c ON/i.test(cleanSql)) {
      const txns = this.tables.Transaction
        .map(t => {
          const a = this.tables.Account.find(acc => acc.account_id === t.account_id) || {};
          const c = this.tables.Customer.find(cust => cust.customer_id === a.customer_id) || {};
          return {
            transaction_id: t.transaction_id,
            transaction_type: t.transaction_type,
            amount: t.amount,
            transaction_date: t.transaction_date,
            description: t.description,
            balance_after: t.balance_after,
            reference_number: t.reference_number,
            status: t.status,
            account_number: a.account_number,
            customer_name: `${c.first_name || ''} ${c.last_name || ''}`.trim()
          };
        })
        .sort((a, b) => new Date(b.transaction_date) - new Date(a.transaction_date))
        .slice(0, 100);
      return [txns, []];
    }

    // 18. Transactions history for single account
    if (/SELECT .* FROM Transaction WHERE account_id = \?/i.test(cleanSql)) {
      const accId = parseInt(params[0]);
      const txns = this.tables.Transaction
        .filter(t => t.account_id === accId)
        .sort((a, b) => new Date(b.transaction_date) - new Date(a.transaction_date));
      return [txns, []];
    }

    // 19. INSERT INTO Transaction
    if (/INSERT INTO Transaction/i.test(cleanSql)) {
      const [account_id, amount, description, balance_after, reference_number] = params;
      const typeMatch = cleanSql.match(/'(Deposit|Withdrawal|Transfer)'/i);
      const transaction_type = typeMatch ? typeMatch[1] : 'Deposit';
      const newTxn = {
        transaction_id: this.tables.Transaction.length + 1,
        account_id: parseInt(account_id),
        transaction_type,
        amount: parseFloat(amount),
        transaction_date: new Date().toISOString().replace('T', ' ').substring(0, 19),
        description: description || '',
        balance_after: parseFloat(balance_after),
        reference_number,
        status: 'Completed'
      };
      this.tables.Transaction.push(newTxn);
      return [{ insertId: newTxn.transaction_id }, []];
    }

    // 20. INSERT INTO Fund_Transfer
    if (/INSERT INTO Fund_Transfer/i.test(cleanSql)) {
      const [from_account_id, to_account_id, amount, transfer_type, reference_number, remarks] = params;
      const newTrf = {
        transfer_id: this.tables.Fund_Transfer.length + 1,
        from_account_id: parseInt(from_account_id),
        to_account_id: parseInt(to_account_id),
        amount: parseFloat(amount),
        transfer_date: new Date().toISOString().replace('T', ' ').substring(0, 19),
        transfer_type: transfer_type || 'Internal',
        reference_number,
        remarks: remarks || '',
        status: 'Completed'
      };
      this.tables.Fund_Transfer.push(newTrf);
      return [{ insertId: newTrf.transfer_id }, []];
    }

    // 21. Loans for customer
    if (/SELECT .* FROM Loan WHERE customer_id = \?/i.test(cleanSql)) {
      const custId = parseInt(params[0]);
      const res = this.tables.Loan.filter(l => l.customer_id === custId);
      return [res, []];
    }

    // 22. Single Loan lookup
    if (/SELECT \* FROM Loan WHERE loan_id = \?/i.test(cleanSql)) {
      const loanId = parseInt(params[0]);
      const res = this.tables.Loan.filter(l => l.loan_id === loanId);
      return [res, []];
    }

    // 23. Loan Payments
    if (/SELECT .* FROM Loan_Payment WHERE loan_id = \?/i.test(cleanSql)) {
      const loanId = parseInt(params[0]);
      const res = this.tables.Loan_Payment.filter(lp => lp.loan_id === loanId);
      return [res, []];
    }

    // 24. Admin Customers list with JOIN
    if (/FROM Customer c LEFT JOIN Account a ON c.customer_id = a.customer_id/i.test(cleanSql)) {
      const res = this.tables.Customer.map(c => {
        const userAccs = this.tables.Account.filter(a => a.customer_id === c.customer_id && a.status === 'Active');
        const total_balance = userAccs.reduce((sum, a) => sum + parseFloat(a.balance), 0);
        return {
          customer_id: c.customer_id,
          first_name: c.first_name,
          last_name: c.last_name,
          email: c.email,
          phone: c.phone,
          customer_type: c.customer_type,
          registration_date: c.registration_date,
          status: c.status,
          account_count: userAccs.length,
          total_balance
        };
      });
      return [res, []];
    }

    // 25. Admin aggregate stats queries
    if (/SELECT COUNT\(\*\) AS count FROM Customer/i.test(cleanSql)) {
      return [[{ count: this.tables.Customer.length }], []];
    }
    if (/SELECT COUNT\(\*\) AS count FROM Account WHERE status = \?/i.test(cleanSql)) {
      const count = this.tables.Account.filter(a => a.status === params[0]).length;
      return [[{ count }], []];
    }
    if (/SELECT COALESCE\(SUM\(balance\), 0\) AS total FROM Account WHERE status = \?/i.test(cleanSql)) {
      const total = this.tables.Account.filter(a => a.status === params[0]).reduce((s, a) => s + parseFloat(a.balance), 0);
      return [[{ total }], []];
    }
    if (/SELECT COUNT\(\*\) AS count FROM Loan WHERE status = \?/i.test(cleanSql)) {
      const count = this.tables.Loan.filter(l => l.status === params[0]).length;
      return [[{ count }], []];
    }
    if (/SELECT COALESCE\(SUM\(outstanding_amount\), 0\) AS total FROM Loan WHERE status = \?/i.test(cleanSql)) {
      const total = this.tables.Loan.filter(l => l.status === params[0]).reduce((s, l) => s + parseFloat(l.outstanding_amount || 0), 0);
      return [[{ total }], []];
    }
    if (/SELECT COUNT\(\*\) AS count FROM Transaction/i.test(cleanSql)) {
      return [[{ count: this.tables.Transaction.length }], []];
    }

    // Fallback: empty array
    return [[], []];
  }

  async getConnection() {
    return {
      beginTransaction: async () => {},
      query: async (sql, params) => this.query(sql, params),
      commit: async () => {},
      rollback: async () => {},
      release: () => {}
    };
  }
}

const mockDb = new MockDatabase();
module.exports = mockDb;
