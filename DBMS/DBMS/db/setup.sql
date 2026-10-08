USE securebank;

-- Re-create core tables if they don't exist
CREATE TABLE IF NOT EXISTS Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address TEXT,
    pan_number VARCHAR(10) UNIQUE NOT NULL,
    aadhar_number VARCHAR(12) UNIQUE NOT NULL,
    customer_type ENUM('Individual', 'Business') DEFAULT 'Individual',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Active', 'Inactive', 'Blocked') DEFAULT 'Active'
);

CREATE TABLE IF NOT EXISTS Account (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    account_number VARCHAR(16) UNIQUE NOT NULL,
    account_type ENUM('Savings', 'Current', 'Fixed Deposit') NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    interest_rate DECIMAL(5,2),
    opening_date DATE NOT NULL,
    branch_code VARCHAR(10),
    status ENUM('Active', 'Frozen', 'Closed') DEFAULT 'Active',
    minimum_balance DECIMAL(10,2) DEFAULT 1000.00,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE IF NOT EXISTS Transaction (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_type ENUM('Deposit', 'Withdrawal', 'Transfer', 'Interest Credit', 'Fee Debit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    balance_after DECIMAL(15,2),
    reference_number VARCHAR(20) UNIQUE,
    status ENUM('Pending', 'Completed', 'Failed', 'Reversed') DEFAULT 'Completed',
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

CREATE TABLE IF NOT EXISTS Fund_Transfer (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account_id INT NOT NULL,
    to_account_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transfer_type ENUM('NEFT', 'RTGS', 'IMPS', 'Internal') NOT NULL,
    reference_number VARCHAR(20) UNIQUE,
    remarks VARCHAR(255),
    status ENUM('Initiated', 'Processing', 'Completed', 'Failed') DEFAULT 'Completed',
    FOREIGN KEY (from_account_id) REFERENCES Account(account_id),
    FOREIGN KEY (to_account_id) REFERENCES Account(account_id)
);

CREATE TABLE IF NOT EXISTS Loan (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    loan_type ENUM('Home', 'Personal', 'Vehicle', 'Education', 'Business') NOT NULL,
    loan_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    monthly_emi DECIMAL(10,2),
    outstanding_amount DECIMAL(15,2),
    application_date DATE NOT NULL,
    approval_date DATE,
    disbursement_date DATE,
    status ENUM('Applied', 'Approved', 'Disbursed', 'Rejected', 'Closed') DEFAULT 'Applied',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE IF NOT EXISTS Loan_Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    principal_amount DECIMAL(10,2),
    interest_amount DECIMAL(10,2),
    payment_method ENUM('Auto Debit', 'Manual', 'Online') DEFAULT 'Auto Debit',
    transaction_id INT,
    FOREIGN KEY (loan_id) REFERENCES Loan(loan_id),
    FOREIGN KEY (transaction_id) REFERENCES Transaction(transaction_id)
);

CREATE TABLE IF NOT EXISTS Beneficiary (
    beneficiary_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    beneficiary_name VARCHAR(100) NOT NULL,
    beneficiary_account VARCHAR(16) NOT NULL,
    bank_name VARCHAR(100),
    ifsc_code VARCHAR(11),
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Active', 'Deleted') DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE IF NOT EXISTS Card (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    card_number VARCHAR(16) UNIQUE NOT NULL,
    card_type ENUM('Debit', 'Credit') NOT NULL,
    expiry_date DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    daily_limit DECIMAL(10,2) DEFAULT 50000.00,
    status ENUM('Active', 'Blocked', 'Expired') DEFAULT 'Active',
    issue_date DATE NOT NULL,
    FOREIGN KEY (account_id) REFERENCES Account(account_id)
);

-- Insert sample data only if Customer table is empty
INSERT IGNORE INTO Customer (customer_id, first_name, last_name, date_of_birth, email, phone, address, pan_number, aadhar_number, customer_type) VALUES
(1, 'Rajesh', 'Kumar', '1985-06-15', 'rajesh.kumar@email.com', '9876543210', '123 MG Road, Chennai', 'ABCDE1234F', '123456789012', 'Individual'),
(2, 'Priya', 'Sharma', '1990-03-22', 'priya.sharma@email.com', '9876543211', '456 Anna Nagar, Chennai', 'FGHIJ5678K', '234567890123', 'Individual'),
(3, 'Vikram', 'Reddy', '1982-11-08', 'vikram.reddy@email.com', '9876543212', '789 T Nagar, Chennai', 'LMNOP9012Q', '345678901234', 'Individual'),
(4, 'Anjali', 'Patel', '1995-07-30', 'anjali.patel@email.com', '9876543213', '321 Adyar, Chennai', 'RSTUV3456W', '456789012345', 'Individual'),
(5, 'TechCorp Solutions', 'Pvt Ltd', '2010-01-01', 'info@techcorp.com', '9876543214', '555 IT Park, Chennai', 'XYZAB7890C', '567890123456', 'Business');

INSERT IGNORE INTO Account (account_id, customer_id, account_number, account_type, balance, interest_rate, opening_date, branch_code) VALUES
(1, 1, '1234567890123456', 'Savings', 50000.00, 4.00, '2020-01-15', 'CHN001'),
(2, 2, '2345678901234567', 'Savings', 75000.00, 4.00, '2019-05-20', 'CHN001'),
(3, 3, '3456789012345678', 'Current', 120000.00, 0.00, '2018-08-10', 'CHN002'),
(4, 4, '4567890123456789', 'Savings', 35000.00, 4.00, '2021-03-25', 'CHN001'),
(5, 5, '5678901234567890', 'Current', 500000.00, 0.00, '2015-11-05', 'CHN002'),
(6, 1, '6789012345678901', 'Fixed Deposit', 200000.00, 6.50, '2022-06-01', 'CHN001');

INSERT IGNORE INTO Transaction (transaction_id, account_id, transaction_type, amount, description, balance_after, reference_number) VALUES
(1, 1, 'Deposit', 10000.00, 'Cash Deposit', 60000.00, 'TXN001234567890'),
(2, 1, 'Withdrawal', 5000.00, 'ATM Withdrawal', 55000.00, 'TXN001234567891'),
(3, 2, 'Deposit', 25000.00, 'Salary Credit', 100000.00, 'TXN001234567892'),
(4, 3, 'Withdrawal', 20000.00, 'Business Payment', 100000.00, 'TXN001234567893'),
(5, 4, 'Deposit', 15000.00, 'Cash Deposit', 50000.00, 'TXN001234567894'),
(6, 5, 'Deposit', 100000.00, 'Business Receipt', 600000.00, 'TXN001234567895');

INSERT IGNORE INTO Fund_Transfer (transfer_id, from_account_id, to_account_id, amount, transfer_type, reference_number, remarks) VALUES
(1, 1, 2, 5000.00, 'Internal', 'TRF001234567890', 'Payment to Priya'),
(2, 3, 4, 10000.00, 'NEFT', 'TRF001234567891', 'Vendor Payment'),
(3, 5, 1, 25000.00, 'RTGS', 'TRF001234567892', 'Salary Payment'),
(4, 2, 3, 8000.00, 'IMPS', 'TRF001234567893', 'Service Payment');

INSERT IGNORE INTO Loan (loan_id, customer_id, loan_type, loan_amount, interest_rate, tenure_months, monthly_emi, outstanding_amount, application_date, approval_date, disbursement_date, status) VALUES
(1, 1, 'Personal', 200000.00, 10.50, 24, 9266.00, 200000.00, '2023-01-10', '2023-01-15', '2023-01-20', 'Disbursed'),
(2, 2, 'Home', 5000000.00, 8.50, 240, 43391.00, 5000000.00, '2022-06-01', '2022-06-10', '2022-07-01', 'Disbursed'),
(3, 3, 'Vehicle', 800000.00, 9.00, 60, 16574.00, 800000.00, '2023-03-15', '2023-03-20', '2023-03-25', 'Disbursed'),
(4, 4, 'Education', 300000.00, 7.50, 48, 7234.00, 300000.00, '2023-02-01', '2023-02-05', '2023-02-10', 'Disbursed');

INSERT IGNORE INTO Loan_Payment (payment_id, loan_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method) VALUES
(1, 1, '2023-02-20', 9266.00, 7516.00, 1750.00, 'Auto Debit'),
(2, 1, '2023-03-20', 9266.00, 7582.00, 1684.00, 'Auto Debit'),
(3, 2, '2023-02-01', 43391.00, 8058.00, 35333.00, 'Auto Debit'),
(4, 3, '2023-04-25', 16574.00, 10574.00, 6000.00, 'Auto Debit'),
(5, 4, '2023-03-10', 7234.00, 5359.00, 1875.00, 'Online');

INSERT IGNORE INTO Beneficiary (beneficiary_id, customer_id, beneficiary_name, beneficiary_account, bank_name, ifsc_code) VALUES
(1, 1, 'Priya Sharma', '2345678901234567', 'SecureBank', 'SECB0001234'),
(2, 1, 'Mother', '9876543210123456', 'State Bank', 'SBIN0005678'),
(3, 2, 'Rajesh Kumar', '1234567890123456', 'SecureBank', 'SECB0001234'),
(4, 3, 'Supplier Corp', '5555666677778888', 'HDFC Bank', 'HDFC0001111'),
(5, 4, 'College Fund', '7777888899990000', 'ICICI Bank', 'ICIC0002222');

INSERT IGNORE INTO Card (card_id, account_id, card_number, card_type, expiry_date, cvv, daily_limit, issue_date) VALUES
(1, 1, '4532123456789012', 'Debit', '2026-12-31', '123', 50000.00, '2020-01-20'),
(2, 2, '4532234567890123', 'Debit', '2027-05-31', '456', 50000.00, '2019-05-25'),
(3, 3, '4532345678901234', 'Debit', '2026-08-31', '789', 100000.00, '2018-08-15'),
(4, 4, '4532456789012345', 'Debit', '2028-03-31', '234', 30000.00, '2021-03-30'),
(5, 5, '4532567890123456', 'Debit', '2025-11-30', '567', 200000.00, '2015-11-10');
