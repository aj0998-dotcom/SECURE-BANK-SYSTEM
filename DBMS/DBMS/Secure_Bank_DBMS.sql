DROP DATABASE securebank;
CREATE DATABASE securebank;
USE securebank;
CREATE TABLE Customer (
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
CREATE TABLE Account (
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
CREATE TABLE Transaction (
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
CREATE TABLE Fund_Transfer (
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
CREATE TABLE Loan (
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
CREATE TABLE Loan_Payment (
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
CREATE TABLE Beneficiary (
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
CREATE TABLE Card (
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
INSERT INTO Customer (first_name, last_name, date_of_birth, email, phone, address, pan_number, aadhar_number, customer_type)
VALUES 
('Rajesh', 'Kumar', '1985-06-15', 'rajesh.kumar@email.com', '9876543210', '123 MG Road, Chennai', 'ABCDE1234F', '123456789012', 'Individual'),
('Priya', 'Sharma', '1990-03-22', 'priya.sharma@email.com', '9876543211', '456 Anna Nagar, Chennai', 'FGHIJ5678K', '234567890123', 'Individual'),
('Vikram', 'Reddy', '1982-11-08', 'vikram.reddy@email.com', '9876543212', '789 T Nagar, Chennai', 'LMNOP9012Q', '345678901234', 'Individual'),
('Anjali', 'Patel', '1995-07-30', 'anjali.patel@email.com', '9876543213', '321 Adyar, Chennai', 'RSTUV3456W', '456789012345', 'Individual'),
('TechCorp Solutions', 'Pvt Ltd', '2010-01-01', 'info@techcorp.com', '9876543214', '555 IT Park, Chennai', 'XYZAB7890C', '567890123456', 'Business');
INSERT INTO Account (customer_id, account_number, account_type, balance, interest_rate, opening_date, branch_code)
VALUES 
(1, '1234567890123456', 'Savings', 50000.00, 4.00, '2020-01-15', 'CHN001'),
(2, '2345678901234567', 'Savings', 75000.00, 4.00, '2019-05-20', 'CHN001'),
(3, '3456789012345678', 'Current', 120000.00, 0.00, '2018-08-10', 'CHN002'),
(4, '4567890123456789', 'Savings', 35000.00, 4.00, '2021-03-25', 'CHN001'),
(5, '5678901234567890', 'Current', 500000.00, 0.00, '2015-11-05', 'CHN002'),
(1, '6789012345678901', 'Fixed Deposit', 200000.00, 6.50, '2022-06-01', 'CHN001');
INSERT INTO Transaction (account_id, transaction_type, amount, description, balance_after, reference_number)
VALUES 
(1, 'Deposit', 10000.00, 'Cash Deposit', 60000.00, 'TXN001234567890'),
(1, 'Withdrawal', 5000.00, 'ATM Withdrawal', 55000.00, 'TXN001234567891'),
(2, 'Deposit', 25000.00, 'Salary Credit', 100000.00, 'TXN001234567892'),
(3, 'Withdrawal', 20000.00, 'Business Payment', 100000.00, 'TXN001234567893'),
(4, 'Deposit', 15000.00, 'Cash Deposit', 50000.00, 'TXN001234567894'),
(5, 'Deposit', 100000.00, 'Business Receipt', 600000.00, 'TXN001234567895');
INSERT INTO Fund_Transfer (from_account_id, to_account_id, amount, transfer_type, reference_number, remarks)
VALUES 
(1, 2, 5000.00, 'Internal', 'TRF001234567890', 'Payment to Priya'),
(3, 4, 10000.00, 'NEFT', 'TRF001234567891', 'Vendor Payment'),
(5, 1, 25000.00, 'RTGS', 'TRF001234567892', 'Salary Payment'),
(2, 3, 8000.00, 'IMPS', 'TRF001234567893', 'Service Payment');
INSERT INTO Loan (customer_id, loan_type, loan_amount, interest_rate, tenure_months, monthly_emi, outstanding_amount, application_date, approval_date, disbursement_date, status)
VALUES 
(1, 'Personal', 200000.00, 10.50, 24, 9266.00, 200000.00, '2023-01-10', '2023-01-15', '2023-01-20', 'Disbursed'),
(2, 'Home', 5000000.00, 8.50, 240, 43391.00, 5000000.00, '2022-06-01', '2022-06-10', '2022-07-01', 'Disbursed'),
(3, 'Vehicle', 800000.00, 9.00, 60, 16574.00, 800000.00, '2023-03-15', '2023-03-20', '2023-03-25', 'Disbursed'),
(4, 'Education', 300000.00, 7.50, 48, 7234.00, 300000.00, '2023-02-01', '2023-02-05', '2023-02-10', 'Disbursed');
INSERT INTO Loan_Payment (loan_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method)
VALUES 
(1, '2023-02-20', 9266.00, 7516.00, 1750.00, 'Auto Debit'),
(1, '2023-03-20', 9266.00, 7582.00, 1684.00, 'Auto Debit'),
(2, '2023-02-01', 43391.00, 8058.00, 35333.00, 'Auto Debit'),
(3, '2023-04-25', 16574.00, 10574.00, 6000.00, 'Auto Debit'),
(4, '2023-03-10', 7234.00, 5359.00, 1875.00, 'Online');
INSERT INTO Beneficiary (customer_id, beneficiary_name, beneficiary_account, bank_name, ifsc_code)
VALUES 
(1, 'Priya Sharma', '2345678901234567', 'SecureBank', 'SECB0001234'),
(1, 'Mother', '9876543210123456', 'State Bank', 'SBIN0005678'),
(2, 'Rajesh Kumar', '1234567890123456', 'SecureBank', 'SECB0001234'),
(3, 'Supplier Corp', '5555666677778888', 'HDFC Bank', 'HDFC0001111'),
(4, 'College Fund', '7777888899990000', 'ICICI Bank', 'ICIC0002222');
INSERT INTO Card (account_id, card_number, card_type, expiry_date, cvv, daily_limit, issue_date)
VALUES 
(1, '4532123456789012', 'Debit', '2026-12-31', '123', 50000.00, '2020-01-20'),
(2, '4532234567890123', 'Debit', '2027-05-31', '456', 50000.00, '2019-05-25'),
(3, '4532345678901234', 'Debit', '2026-08-31', '789', 100000.00, '2018-08-15'),
(4, '4532456789012345', 'Debit', '2028-03-31', '234', 30000.00, '2021-03-30'),
(5, '4532567890123456', 'Debit', '2025-11-30', '567', 200000.00, '2015-11-10');
ALTER TABLE Account
ADD CONSTRAINT chk_balance CHECK (balance >= 0);
INSERT INTO Account (customer_id, account_number, account_type, 
balance, opening_date, branch_code)
VALUES (1, '1111222233334444', 'Savings', 5000.00, '2024-01-01', 'CHN001');
SELECT account_id, account_number, balance 
FROM Account 
WHERE account_number = '1111222ALTER TABLE Transaction
ADD CONSTRAINT uq_reference UNIQUE (reference_number);
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_NAME = 'Transaction'
AND TABLE_SCHEMA = 'SecureBank';233334444';

ALTER TABLE Account
MODIFY branch_code VARCHAR(10) NOT NULL DEFAULT 'CHN001';
SELECT account_id, account_number, account_type, 
       balance, branch_code
FROM Account
ORDER BY branch_code;
SELECT 
    account_type,
    COUNT(*) AS total_accounts,
    SUM(balance) AS total_balance,
    ROUND(AVG(balance), 2) AS average_balance,
    MIN(balance) AS minimum_balance,
    MAX(balance) AS maximum_balance
FROM Account
WHERE status = 'Active'
GROUP BY account_type
ORDER BY total_balance DESC;
SELECT 
    loan_type,
    COUNT(*) AS total_loans,
    SUM(loan_amount) AS total_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(monthly_emi), 2) AS avg_emi,
    SUM(outstanding_amount) AS total_outstanding
FROM Loan
WHERE status = 'Disbursed'
GROUP BY loan_type
HAVING SUM(loan_amount) > 500000
ORDER BY total_loan_amount DESC;
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(a.account_id) AS number_of_accounts,
    SUM(a.balance) AS total_balance,
    ROUND(AVG(a.balance), 2) AS avg_per_account
FROM Customer c
INNER JOIN Account a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(a.balance) > (SELECT AVG(balance) FROM Account)
ORDER BY total_balance DESC;
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    'Has Savings Account' AS category
FROM Customer c
INNER JOIN Account a ON c.customer_id = a.customer_id
WHERE a.account_type = 'Savings'

UNION

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    'Has Active Loan' AS category
FROM Customer c
INNER JOIN Loan l ON c.customer_id = l.customer_id
WHERE l.status = 'Disbursed'
ORDER BY customer_id;
SELECT 
    'Direct Deposit' AS source,
    account_id,
    amount,
    transaction_date AS date,
    description AS remarks
FROM Transaction
WHERE transaction_type = 'Deposit'

UNION ALL

SELECT 
    'Fund Transfer' AS source,
    to_account_id AS account_id,
    amount,
    transfer_date AS date,
    remarks
FROM Fund_Transfer
WHERE status = 'Completed'
ORDER BY date DESC;
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.balance) AS total_balance
FROM Customer c
INNER JOIN Account a ON c.customer_id = a.customer_id
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM Loan
)
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_balance DESC;SELECT 
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM Account a
INNER JOIN Customer c ON a.customer_id = c.customer_id
WHERE a.balance > (
    SELECT AVG(a2.balance)
    FROM Account a2
    WHERE a2.account_type = a.account_type
)
ORDER BY a.account_type, a.balance DESC;
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.loan_type,
    l.loan_amount,
    l.monthly_emi,
    ROUND((
        SELECT AVG(l2.monthly_emi) 
        FROM Loan l2 
        WHERE l2.loan_type = l.loan_type
    ), 2) AS avg_emi_for_type
FROM Loan l
INNER JOIN Customer c ON l.customer_id = c.customer_id
WHERE l.monthly_emi > (
    SELECT AVG(l3.monthly_emi)
    FROM Loan l3
    WHERE l3.loan_type = l.loan_type
)
ORDER BY l.monthly_emi DESC;
SELECT 
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    (SELECT COUNT(*) 
     FROM Fund_Transfer ft 
     WHERE ft.to_account_id = a.account_id) AS transfers_received
FROM Account a
INNER JOIN Customer c ON a.customer_id = c.customer_id
WHERE EXISTS (
    SELECT 1 FROM Fund_Transfer ft
    WHERE ft.to_account_id = a.account_id
)
AND a.balance < 100000
ORDER BY a.balance DESC;
SELECT 
    t.transaction_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_number,
    a.account_type,
    t.transaction_type,
    t.amount,
    t.balance_after,
    t.transaction_date,
    t.description
FROM Transaction t
INNER JOIN Account a ON t.account_id = a.account_id
INNER JOIN Customer c ON a.customer_id = c.customer_id
ORDER BY t.transaction_date DESC;
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(l.loan_id) AS total_loans,
    COALESCE(SUM(l.outstanding_amount), 0) AS total_outstanding,
    COALESCE(SUM(l.monthly_emi), 0) AS total_monthly_emi,
    CASE 
        WHEN COUNT(l.loan_id) = 0 THEN 'No Loans'
        WHEN SUM(l.outstanding_amount) > 1000000 THEN 'High Debt'
        ELSE 'Manageable Debt'
    END AS debt_status
FROM Customer c
LEFT JOIN Loan l ON c.customer_id = l.customer_id 
    AND l.status = 'Disbursed'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY total_outstanding DESC;
SELECT 
    ft.transfer_id,
    CONCAT(c1.first_name, ' ', c1.last_name) AS sender_name,
    a1.account_number AS from_account,
    a1.account_type AS from_type,
    CONCAT(c2.first_name, ' ', c2.last_name) AS receiver_name,
    a2.account_number AS to_account,
    a2.account_type AS to_type,
    ft.amount,
    ft.transfer_type,
    ft.transfer_date,
    ft.status
FROM Fund_Transfer ft
INNER JOIN Account a1 ON ft.from_account_id = a1.account_id
INNER JOIN Customer c1 ON a1.customer_id = c1.customer_id
INNER JOIN Account a2 ON ft.to_account_id = a2.account_id
INNER JOIN Customer c2 ON a2.customer_id = c2.customer_id
ORDER BY ft.transfer_date DESC;
CREATE VIEW vw_customer_financial_profile AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    COALESCE(SUM(a.balance), 0) AS total_balance,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    COALESCE(SUM(l.outstanding_amount), 0) AS total_debt,
    COALESCE(SUM(a.balance), 0) - COALESCE(SUM(l.outstanding_amount), 0) AS net_worth
FROM Customer c
LEFT JOIN Account a ON c.customer_id = a.customer_id AND a.status = 'Active'
LEFT JOIN Loan l ON c.customer_id = l.customer_id AND l.status = 'Disbursed'
WHERE c.status = 'Active'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
SELECT * FROM vw_customer_financial_profile
ORDER BY net_worth DESC;
CREATE VIEW vw_loan_payment_tracker AS
SELECT 
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.loan_type,
    l.loan_amount,
    l.outstanding_amount,
    l.loan_amount - l.outstanding_amount AS amount_paid_so_far,
    COUNT(lp.payment_id) AS payments_made,
    COALESCE(SUM(lp.principal_amount), 0) AS total_principal_paid,
    COALESCE(SUM(lp.interest_amount), 0) AS total_interest_paid,
    ROUND((l.outstanding_amount / l.loan_amount) * 100, 2) AS percent_remaining
FROM Loan l
INNER JOIN Customer c ON l.customer_id = c.customer_id
LEFT JOIN Loan_Payment lp ON l.loan_id = lp.loan_id
WHERE l.status = 'Disbursed'
GROUP BY l.loan_id, c.first_name, c.last_name, 
         l.loan_type, l.loan_amount, l.outstanding_amount;
SELECT * FROM vw_loan_payment_tracker
ORDER BY total_interest_paid DESC;
CREATE VIEW vw_account_activity_report AS
SELECT 
    a.account_id,
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    a.account_type,
    a.balance,
    a.branch_code,
    COUNT(t.transaction_id) AS transaction_count,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Deposit' 
              THEN t.amount ELSE 0 END), 0) AS total_deposited,
    COALESCE(SUM(CASE WHEN t.transaction_type = 'Withdrawal' 
              THEN t.amount ELSE 0 END), 0) AS total_withdrawn,
    MAX(t.transaction_date) AS last_transaction_date
FROM Account a
INNER JOIN Customer c ON a.customer_id = c.customer_id
LEFT JOIN Transaction t ON a.account_id = t.account_id
WHERE a.status = 'Active'
GROUP BY a.account_id, a.account_number, c.first_name, 
         c.last_name, a.account_type, a.balance, a.branch_code;
         SHOW FULL TABLES WHERE Table_type = 'VIEW';
         SELECT 
    account_number,
    customer_name,
    account_type,
    balance,
    transaction_count,
    last_transaction_date
FROM vw_account_activity_report
WHERE transaction_count < 2
ORDER BY transaction_count ASC;
DELIMITER //
CREATE TRIGGER trg_update_balance_after_txn
AFTER INSERT ON Transaction
FOR EACH ROW
BEGIN
    IF NEW.transaction_type IN ('Deposit', 'Interest Credit') THEN
        UPDATE Account 
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
        
    ELSEIF NEW.transaction_type IN ('Withdrawal', 'Fee Debit') THEN
        UPDATE Account 
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END//
DELIMITER ;
SELECT balance FROM Account WHERE account_id = 1;

INSERT INTO Transaction (account_id, transaction_type, amount, description)
VALUES (1, 'Deposit', 2000.00, 'Test Trigger Deposit');

SELECT balance FROM Account WHERE account_id = 1;
SHOW TRIGGERS;
SELECT account_id, balance 
FROM Account 
WHERE account_id = 1;
INSERT INTO Transaction 
(account_id, transaction_type, amount, description, reference_number)
VALUES 
(1, 'Deposit', 2000.00, 'Test Trigger Deposit', 'TXN999999999999');
SELECT account_id, balance 
FROM Account 
WHERE account_id = 1;
DELIMITER //
CREATE TRIGGER trg_check_minimum_balance
BEFORE INSERT ON Transaction
FOR EACH ROW
BEGIN
    DECLARE v_current_balance DECIMAL(15,2);
    DECLARE v_min_balance DECIMAL(10,2);
    
    IF NEW.transaction_type = 'Withdrawal' THEN
        SELECT balance, minimum_balance 
        INTO v_current_balance, v_min_balance
        FROM Account 
        WHERE account_id = NEW.account_id;
        
        IF (v_current_balance - NEW.amount) < v_min_balance THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Withdrawal denied: Balance would fall below minimum balance';
        END IF;
        END IF;
END//
DELIMITER ;
INSERT INTO Transaction (account_id, transaction_type, amount, description)
VALUES (4, 'Withdrawal', 35000.00, 'Large withdrawal test');
CREATE TABLE IF NOT EXISTS Customer_Status_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    customer_name VARCHAR(100),
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
CREATE TRIGGER trg_log_customer_status_change
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO Customer_Status_Audit 
            (customer_id, customer_name, old_status, new_status)
        VALUES (
            NEW.customer_id,
            CONCAT(NEW.first_name, ' ', NEW.last_name),
            OLD.status,
            NEW.status
        );
    END IF;
END//
DELIMITER ;
UPDATE Customer SET status = 'Blocked' WHERE customer_id = 3;
UPDATE Customer SET status = 'Active' WHERE customer_id = 3;

SELECT * FROM Customer_Status_Audit;
SHOW TRIGGERS;
UPDATE Customer SET status = 'Blocked' WHERE customer_id = 3;
UPDATE Customer SET status = 'Active' WHERE customer_id = 3;
SELECT * FROM Customer_Status_Audit;
DELIMITER //
CREATE PROCEDURE sp_calculate_interest_all_accounts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_account_id INT;
    DECLARE v_account_number VARCHAR(16);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_rate DECIMAL(5,2);
    DECLARE v_monthly_interest DECIMAL(15,2);
    DECLARE v_annual_interest DECIMAL(15,2);
    
    DECLARE savings_cursor CURSOR FOR
        SELECT account_id, account_number, balance, interest_rate
        FROM Account
        WHERE account_type = 'Savings' AND status = 'Active';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_interest_calc (
        account_number VARCHAR(16),
        current_balance DECIMAL(15,2),
        interest_rate DECIMAL(5,2),
        monthly_interest DECIMAL(15,2),
        annual_interest DECIMAL(15,2)
    );
    
    DELETE FROM temp_interest_calc;
    
    OPEN savings_cursor;
    
    calc_loop: LOOP
        FETCH savings_cursor INTO v_account_id, v_account_number, 
                                  v_balance, v_rate;
        IF done THEN
            LEAVE calc_loop;
        END IF;
         SET v_monthly_interest = ROUND((v_balance * v_rate / 100) / 12, 2);
        SET v_annual_interest = ROUND(v_balance * v_rate / 100, 2);
        
        INSERT INTO temp_interest_calc VALUES (
            v_account_number, v_balance, v_rate, 
            v_monthly_interest, v_annual_interest
        );
    END LOOP;
    
    CLOSE savings_cursor;
    
    SELECT * FROM temp_interest_calc ORDER BY annual_interest DESC;
    DROP TEMPORARY TABLE temp_interest_calc;
END//
DELIMITER ;
CALL sp_calculate_interest_all_accounts();
SET SQL_SAFE_UPDATES = 0;
CALL sp_calculate_interest_all_accounts();
DELIMITER //
CREATE PROCEDURE sp_flag_high_outstanding_loans()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_loan_id INT;
    DECLARE v_customer_name VARCHAR(100);
    DECLARE v_loan_type VARCHAR(20);
    DECLARE v_loan_amount DECIMAL(15,2);
    DECLARE v_outstanding DECIMAL(15,2);
    DECLARE v_percent_outstanding DECIMAL(5,2);
    DECLARE v_flag VARCHAR(20);
     DECLARE loan_cursor CURSOR FOR
        SELECT l.loan_id, 
               CONCAT(c.first_name, ' ', c.last_name),
               l.loan_type,
               l.loan_amount,
               l.outstanding_amount
        FROM Loan l
        INNER JOIN Customer c ON l.customer_id = c.customer_id
        WHERE l.status = 'Disbursed';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_loan_flags (
        loan_id INT,
        customer_name VARCHAR(100),
        loan_type VARCHAR(20),
        loan_amount DECIMAL(15,2),
        outstanding_amount DECIMAL(15,2),
        percent_outstanding DECIMAL(5,2),
        risk_flag VARCHAR(20)
         );
    
    DELETE FROM temp_loan_flags;
    OPEN loan_cursor;
    
    flag_loop: LOOP
        FETCH loan_cursor INTO v_loan_id, v_customer_name, 
                               v_loan_type, v_loan_amount, v_outstanding;
        IF done THEN LEAVE flag_loop; END IF;
        
        SET v_percent_outstanding = ROUND((v_outstanding / v_loan_amount) * 100, 2);
        
        IF v_percent_outstanding > 95 THEN
            SET v_flag = 'CRITICAL';
        ELSEIF v_percent_outstanding > 90 THEN
            SET v_flag = 'HIGH RISK';
        ELSE
            SET v_flag = 'NORMAL';
        END IF;
         INSERT INTO temp_loan_flags VALUES (
            v_loan_id, v_customer_name, v_loan_type,
            v_loan_amount, v_outstanding, v_percent_outstanding, v_flag
        );
    END LOOP;
    
    CLOSE loan_cursor;
    SELECT * FROM temp_loan_flags ORDER BY percent_outstanding DESC;
    DROP TEMPORARY TABLE temp_loan_flags;
END//
DELIMITER ;
CALL sp_flag_high_outstanding_loans();
DELIMITER //
CREATE PROCEDURE sp_branch_wise_report()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_branch VARCHAR(10);
    DECLARE v_total_accounts INT;
    DECLARE v_total_balance DECIMAL(15,2);
    DECLARE v_avg_balance DECIMAL(15,2);
    DECLARE v_savings_count INT;
    DECLARE v_current_count INT;
    
    DECLARE branch_cursor CURSOR FOR
        SELECT DISTINCT branch_code FROM Account 
        WHERE status = 'Active'
        ORDER BY branch_code;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_branch_report (
        branch_code VARCHAR(10),
        total_accounts INT,
        savings_accounts INT,
        current_accounts INT,
        total_balance DECIMAL(15,2),
        average_balance DECIMAL(15,2)
    );
    
    DELETE FROM temp_branch_report;
    OPEN branch_cursor;
    
    branch_loop: LOOP
        FETCH branch_cursor INTO v_branch;
        IF done THEN LEAVE branch_loop; END IF;
        SELECT 
            COUNT(*),
            SUM(balance),
            AVG(balance),
            SUM(CASE WHEN account_type = 'Savings' THEN 1 ELSE 0 END),
            SUM(CASE WHEN account_type = 'Current' THEN 1 ELSE 0 END)
        INTO v_total_accounts, v_total_balance, v_avg_balance,
             v_savings_count, v_current_count
        FROM Account
        WHERE branch_code = v_branch AND status = 'Active';
        
        INSERT INTO temp_branch_report VALUES (
            v_branch, v_total_accounts, v_savings_count,
            v_current_count, v_total_balance, ROUND(v_avg_balance, 2)
        );
    END LOOP;
    CLOSE branch_cursor;
    SELECT * FROM temp_branch_report ORDER BY total_balance DESC;
    DROP TEMPORARY TABLE temp_branch_report;
END//
DELIMITER ;
CALL sp_branch_wise_report();
DELIMITER //
CREATE TRIGGER trg_log_customer
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO Customer_Status
            (customer_id, customer_name, old_status, new_status)
        VALUES (
            NEW.customer_id,
            CONCAT(NEW.first_name, ' ', NEW.last_name),
            OLD.status,
            NEW.status
        );
        END IF;
        END //
        DELIMITER ;

        

SELECT * FROM Customer_Status_Audit;
SHOW TRIGGERS;

-- REVIEW 3 work start
USE securebank;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS CustomerUnnormalized;
DROP TABLE IF EXISTS Loan_5NF;
DROP TABLE IF EXISTS Account_5NF;
DROP TABLE IF EXISTS Customer_5NF;
DROP TABLE IF EXISTS CustomerLoan_4NF;
DROP TABLE IF EXISTS CustomerPhone_4NF;
DROP TABLE IF EXISTS Customer_4NF;
DROP TABLE IF EXISTS Branch_BCNF;
DROP TABLE IF EXISTS Bank_BCNF;
DROP TABLE IF EXISTS Branch_3NF;
DROP TABLE IF EXISTS Customer_3NF;
DROP TABLE IF EXISTS Account_2NF;
DROP TABLE IF EXISTS Customer_2NF;
DROP TABLE IF EXISTS Loan_1NF;
DROP TABLE IF EXISTS Account_1NF;
DROP TABLE IF EXISTS Customer_1NF;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- UNNORMALIZED TABLE (Before Normalization)
-- =============================================
CREATE TABLE CustomerUnnormalized (
    AccountNo   INT,
    Name        VARCHAR(100),
    Phone       VARCHAR(15),
    LoanType    VARCHAR(50)
);

INSERT INTO CustomerUnnormalized VALUES
(1001, 'Arjun Kumar',  '9876543210', 'Home Loan'),
(1001, 'Arjun Kumar',  '9876543210', 'Car Loan'),
(1002, 'Priya Sharma', '9845612370', 'Personal Loan'),
(1003, 'Ravi Menon',   '9123456780', 'Home Loan'),
(1003, 'Ravi Menon',   '9123456780', 'Education Loan');

SELECT * FROM CustomerUnnormalized;

-- =============================================
-- AFTER 1NF
-- =============================================
CREATE TABLE Customer_1NF (
    CustomerID  INT PRIMARY KEY,
    Name        VARCHAR(100),
    Phone       VARCHAR(15)
);

CREATE TABLE Account_1NF (
    AccountNo   INT PRIMARY KEY,
    CustomerID  INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer_1NF(CustomerID)
);

CREATE TABLE Loan_1NF (
    LoanID      INT PRIMARY KEY,
    CustomerID  INT,
    LoanType    VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customer_1NF(CustomerID)
);

INSERT INTO Customer_1NF VALUES
(1, 'Arjun Kumar',  '9876543210'),
(2, 'Priya Sharma', '9845612370'),
(3, 'Ravi Menon',   '9123456780');

INSERT INTO Account_1NF VALUES
(1001, 1),
(1002, 2),
(1003, 3);

INSERT INTO Loan_1NF VALUES
(201, 1, 'Home Loan'),
(202, 1, 'Car Loan'),
(203, 2, 'Personal Loan'),
(204, 3, 'Home Loan'),
(205, 3, 'Education Loan');

SELECT * FROM Customer_1NF;
SELECT * FROM Account_1NF;
SELECT * FROM Loan_1NF;

-- =============================================
-- AFTER 2NF
-- =============================================
CREATE TABLE Customer_2NF (
    CustomerID  INT PRIMARY KEY,
    Name        VARCHAR(100)
);

CREATE TABLE Account_2NF (
    AccountNo   INT PRIMARY KEY,
    CustomerID  INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer_2NF(CustomerID)
);

INSERT INTO Customer_2NF VALUES
(1, 'Arjun Kumar'),
(2, 'Priya Sharma'),
(3, 'Ravi Menon');

INSERT INTO Account_2NF VALUES
(1001, 1),
(1002, 2),
(1003, 3);

SELECT * FROM Customer_2NF;
SELECT * FROM Account_2NF;

-- =============================================
-- AFTER 3NF
-- =============================================
CREATE TABLE Branch_3NF (
    BranchID    INT PRIMARY KEY,
    City        VARCHAR(100)
);

CREATE TABLE Customer_3NF (
    CustomerID  INT PRIMARY KEY,
    Name        VARCHAR(100),
    BranchID    INT,
    FOREIGN KEY (BranchID) REFERENCES Branch_3NF(BranchID)
);

INSERT INTO Branch_3NF VALUES
(10, 'Chennai'),
(11, 'Mumbai'),
(12, 'Delhi');

INSERT INTO Customer_3NF VALUES
(1, 'Arjun Kumar',  10),
(2, 'Priya Sharma', 11),
(3, 'Ravi Menon',   12);

SELECT * FROM Branch_3NF;
SELECT * FROM Customer_3NF;

-- =============================================
-- AFTER BCNF
-- =============================================
CREATE TABLE Bank_BCNF (
    BankCode    VARCHAR(10) PRIMARY KEY,
    BankName    VARCHAR(100)
);

CREATE TABLE Branch_BCNF (
    BranchID    INT PRIMARY KEY,
    BankCode    VARCHAR(10),
    City        VARCHAR(100),
    FOREIGN KEY (BankCode) REFERENCES Bank_BCNF(BankCode)
);

INSERT INTO Bank_BCNF VALUES
('SBI01', 'State Bank of India'),
('HDFC1', 'HDFC Bank'),
('ICIC1', 'ICICI Bank');

INSERT INTO Branch_BCNF VALUES
(10, 'SBI01', 'Chennai'),
(11, 'HDFC1', 'Mumbai'),
(12, 'ICIC1', 'Delhi');

SELECT * FROM Bank_BCNF;
SELECT * FROM Branch_BCNF;

-- =============================================
-- AFTER 4NF
-- =============================================
CREATE TABLE Customer_4NF (
    CustomerID  INT PRIMARY KEY
);

CREATE TABLE CustomerPhone_4NF (
    CustomerID  INT,
    Phone       VARCHAR(15),
    PRIMARY KEY (CustomerID, Phone),
    FOREIGN KEY (CustomerID) REFERENCES Customer_4NF(CustomerID)
);

CREATE TABLE CustomerLoan_4NF (
    CustomerID  INT,
    LoanType    VARCHAR(50),
    PRIMARY KEY (CustomerID, LoanType),
    FOREIGN KEY (CustomerID) REFERENCES Customer_4NF(CustomerID)
);

INSERT INTO Customer_4NF VALUES (1), (2), (3);

INSERT INTO CustomerPhone_4NF VALUES
(1, '9876543210'),
(2, '9845612370'),
(3, '9123456780');

INSERT INTO CustomerLoan_4NF VALUES
(1, 'Home Loan'),
(1, 'Car Loan'),
(2, 'Personal Loan'),
(3, 'Home Loan');

SELECT * FROM Customer_4NF;
SELECT * FROM CustomerPhone_4NF;
SELECT * FROM CustomerLoan_4NF;

-- =============================================
-- AFTER 5NF
-- =============================================
CREATE TABLE Customer_5NF (
    CustomerID  INT PRIMARY KEY,
    Name        VARCHAR(100)
);

CREATE TABLE Account_5NF (
    AccountNo   INT PRIMARY KEY,
    CustomerID  INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer_5NF(CustomerID)
);

CREATE TABLE Loan_5NF (
    LoanID      INT PRIMARY KEY,
    CustomerID  INT,
    LoanType    VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customer_5NF(CustomerID)
);

INSERT INTO Customer_5NF VALUES
(1, 'Arjun Kumar'),
(2, 'Priya Sharma'),
(3, 'Ravi Menon');

INSERT INTO Account_5NF VALUES
(1001, 1),
(1002, 2),
(1003, 3);

INSERT INTO Loan_5NF VALUES
(201, 1, 'Home Loan'),
(202, 2, 'Personal Loan'),
(203, 3, 'Education Loan');

SELECT * FROM Customer_5NF;
SELECT * FROM Account_5NF;
SELECT * FROM Loan_5NF;


-- =============================================
-- BASE TABLE SETUP FOR TRANSACTIONS
-- =============================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Loan_txn;
DROP TABLE IF EXISTS Account_txn;
DROP TABLE IF EXISTS Customer_txn;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Customer_txn (
    CustomerID   INT PRIMARY KEY,
    Name         VARCHAR(100)
);

CREATE TABLE Account_txn (
    account_id   INT PRIMARY KEY,
    CustomerID   INT,
    balance      DECIMAL(12,2),
    account_type VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer_txn(CustomerID)
);

CREATE TABLE Loan_txn (
    loan_id            INT PRIMARY KEY,
    CustomerID         INT,
    loan_type          VARCHAR(50),
    outstanding_amount DECIMAL(12,2),
    FOREIGN KEY (CustomerID) REFERENCES Customer_txn(CustomerID)
);

INSERT INTO Customer_txn VALUES
(1, 'Arjun Kumar'),
(2, 'Priya Sharma'),
(3, 'Ravi Menon'),
(4, 'Sneha Raj'),
(5, 'Karthik V');

INSERT INTO Account_txn VALUES
(1, 1, 50000.00, 'Savings'),
(2, 2, 30000.00, 'Current'),
(3, 3, 75000.00, 'Savings'),
(4, 4, 20000.00, 'Savings'),
(5, 5, 90000.00, 'Current');

INSERT INTO Loan_txn VALUES
(1, 1, 'Home Loan',      200000.00),
(2, 2, 'Car Loan',        80000.00),
(3, 3, 'Personal Loan',   50000.00),
(4, 4, 'Education Loan', 120000.00),
(5, 5, 'Home Loan',      300000.00);

-- View initial state
SELECT * FROM Account_txn;
SELECT * FROM Loan_txn;

-- =============================================
-- TRANSACTION 1: Deposit with Savepoint
-- =============================================
START TRANSACTION;

UPDATE Account_txn SET balance = balance + 5000 WHERE account_id = 1;

SAVEPOINT sp1;

UPDATE Account_txn SET balance = balance + 2000 WHERE account_id = 2;

ROLLBACK TO sp1;  -- Undoes Account 2 update only

COMMIT;           -- Saves Account 1 deposit

SELECT * FROM Account_txn WHERE account_id IN (1,2);

-- =============================================
-- TRANSACTION 2: Withdrawal
-- =============================================
START TRANSACTION;

UPDATE Account_txn SET balance = balance - 3000 WHERE account_id = 1;

COMMIT;

SELECT * FROM Account_txn WHERE account_id = 1;

-- =============================================
-- TRANSACTION 3: Fund Transfer
-- =============================================
START TRANSACTION;

UPDATE Account_txn SET balance = balance - 5000 WHERE account_id = 1;
UPDATE Account_txn SET balance = balance + 5000 WHERE account_id = 2;

COMMIT;

SELECT * FROM Account_txn WHERE account_id IN (1,2);

-- =============================================
-- TRANSACTION 4: Loan Payment
-- =============================================
START TRANSACTION;

UPDATE Loan_txn
SET outstanding_amount = outstanding_amount - 5000
WHERE loan_id = 1;

COMMIT;

SELECT * FROM Loan_txn WHERE loan_id = 1;

-- =============================================
-- TRANSACTION 5: Rollback Example
-- =============================================
START TRANSACTION;

UPDATE Account_txn SET balance = balance - 100000 WHERE account_id = 1;

ROLLBACK;  -- Entire transaction undone

SELECT * FROM Account_txn WHERE account_id = 1;

-- Final state of all accounts
SELECT * FROM Account_txn;
SELECT * FROM Loan_txn;

USE securebank;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Loan_cc;
DROP TABLE IF EXISTS Account_cc;
DROP TABLE IF EXISTS Customer_cc;
DROP TABLE IF EXISTS ConcurrencyLog;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Customer_cc (
    CustomerID   INT PRIMARY KEY,
    Name         VARCHAR(100)
);

CREATE TABLE Account_cc (
    account_id   INT PRIMARY KEY,
    CustomerID   INT,
    balance      DECIMAL(12,2),
    account_type VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customer_cc(CustomerID)
);

CREATE TABLE Loan_cc (
    loan_id            INT PRIMARY KEY,
    CustomerID         INT,
    loan_type          VARCHAR(50),
    outstanding_amount DECIMAL(12,2),
    FOREIGN KEY (CustomerID) REFERENCES Customer_cc(CustomerID)
);

CREATE TABLE ConcurrencyLog (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50),
    account_id  INT,
    amount      DECIMAL(12,2),
    lock_mode   VARCHAR(30),
    status      VARCHAR(20),
    log_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Customer_cc VALUES
(1, 'Arjun Kumar'),
(2, 'Priya Sharma'),
(3, 'Ravi Menon'),
(4, 'Sneha Raj'),
(5, 'Karthik V');

INSERT INTO Account_cc VALUES
(1, 1, 50000.00, 'Savings'),
(2, 2, 30000.00, 'Current'),
(3, 3, 75000.00, 'Savings'),
(4, 4, 20000.00, 'Savings'),
(5, 5, 90000.00, 'Current');

INSERT INTO Loan_cc VALUES
(1, 1, 'Home Loan',      200000.00),
(2, 2, 'Car Loan',        80000.00),
(3, 3, 'Personal Loan',   50000.00);

SELECT * FROM Account_cc;

START TRANSACTION;

SELECT * FROM Account_cc
WHERE account_id = 1 FOR UPDATE;  -- Row-level exclusive lock

UPDATE Account_cc
SET balance = balance - 2000
WHERE account_id = 1;

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Withdrawal', 1, 2000.00, 'ROW EXCLUSIVE', 'COMMITTED');

COMMIT;

SELECT * FROM Account_cc WHERE account_id = 1;

-- =============================================
-- CONCURRENCY 2: Shared Lock (Read Lock)
-- Multiple users can read, no modification
-- =============================================
START TRANSACTION;

SELECT * FROM Account_cc
WHERE account_id = 2 LOCK IN SHARE MODE;  -- Shared read lock

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Balance Check', 2, 0.00, 'ROW SHARE', 'COMMITTED');

COMMIT;

SELECT * FROM Account_cc WHERE account_id = 2;

-- =============================================
-- CONCURRENCY 3: Table-Level Lock (WRITE)
-- Locks entire table for modification
-- =============================================
LOCK TABLE Account_cc WRITE;

UPDATE Account_cc
SET balance = balance + 1000
WHERE account_id = 3;

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Deposit', 3, 1000.00, 'TABLE EXCLUSIVE', 'COMMITTED');

UNLOCK TABLES;

SELECT * FROM Account_cc WHERE account_id = 3;

-- =============================================
-- CONCURRENCY 4: Table-Level Lock (READ)
-- All users can read, none can write
-- =============================================
LOCK TABLE Account_cc READ;

SELECT * FROM Account_cc;  -- Read allowed

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Read All', 0, 0.00, 'TABLE SHARE', 'COMMITTED');

UNLOCK TABLES;

-- =============================================
-- CONCURRENCY 5: Prevent Double Withdrawal
-- Row lock ensures only one withdrawal at a time
-- =============================================
START TRANSACTION;

SELECT * FROM Account_cc
WHERE account_id = 4 FOR UPDATE;  -- Locks row, blocks other sessions

UPDATE Account_cc
SET balance = balance - 5000
WHERE account_id = 4
AND balance >= 5000;               -- Prevents negative balance

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Safe Withdrawal', 4, 5000.00, 'ROW EXCLUSIVE', 'COMMITTED');

COMMIT;

SELECT * FROM Account_cc WHERE account_id = 4;

-- =============================================
-- CONCURRENCY 6: Deadlock Prevention
-- Always lock in same order to avoid deadlock
-- =============================================
START TRANSACTION;

SELECT * FROM Account_cc WHERE account_id = 1 FOR UPDATE;
SELECT * FROM Account_cc WHERE account_id = 2 FOR UPDATE;

UPDATE Account_cc SET balance = balance - 3000 WHERE account_id = 1;
UPDATE Account_cc SET balance = balance + 3000 WHERE account_id = 2;

INSERT INTO ConcurrencyLog(action_type, account_id, amount, lock_mode, status)
VALUES ('Transfer A1->A2', 1, 3000.00, 'ROW EXCLUSIVE', 'COMMITTED');

COMMIT;

SELECT * FROM Account_cc WHERE account_id IN (1,2);

-- =============================================
-- VIEW FULL CONCURRENCY LOG
-- =============================================
SELECT * FROM ConcurrencyLog;

-- =============================================
-- LOCK MODE REFERENCE TABLE
-- =============================================
SELECT 'ROW SHARE'      AS Lock_Mode, 'Allows concurrent reads, no modification'     AS Description UNION ALL
SELECT 'ROW EXCLUSIVE',               'Default for UPDATE/DELETE, blocks writes'                    UNION ALL
SELECT 'SHARE',                       'Read only, blocks all writes'                                UNION ALL
SELECT 'EXCLUSIVE',                   'Full lock, blocks all reads and writes'                      UNION ALL
SELECT 'TABLE READ',                  'All sessions can read, none can write'                       UNION ALL
SELECT 'TABLE WRITE',                 'Only locking session can read and write';

