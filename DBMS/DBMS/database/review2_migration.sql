-- ============================================================================
-- SECUREBANK - ADVANCED SQL / ASQL REVIEW 2 - MIGRATION
-- ============================================================================
-- Safe to run many times (idempotent). It NEVER drops the database, tables or
-- existing rows. It only adds what is missing:
--   * tables, columns, indexes, FOREIGN KEY / CHECK constraints
--   * views, triggers, stored procedures (re-created with the final logic)
--
-- Run it either:
--   mysql -u root -p securebank < database/review2_migration.sql
--   (MySQL Workbench: open this file and run it)  OR
--   npm run migrate            (Node runner, understands DELIMITER)
--   (the server also runs it automatically on start unless AUTO_MIGRATE=false)
--
-- NOTE FOR THE NODE RUNNER: keep statements free of trailing "-- comments"
-- after the terminating ; or // (full-line comments are fine).
-- ============================================================================

USE securebank;

SET SQL_SAFE_UPDATES = 0;

-- ----------------------------------------------------------------------------
-- Helper: r2_try(sql) runs one DDL statement and silently ignores ONLY the
-- "already exists" class of errors, which makes ALTER TABLE ... ADD idempotent
-- on MySQL 8 (it has no ADD COLUMN IF NOT EXISTS).
--   1060 duplicate column | 1061 duplicate key name | 1826 duplicate FK name
--   3822 duplicate CHECK name | 1050 table exists | 1091 cannot drop | 1243 stmt
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS r2_try;

DELIMITER //

CREATE PROCEDURE r2_try(IN p_sql TEXT)
BEGIN
  DECLARE CONTINUE HANDLER FOR 1060, 1061, 1826, 3822, 1050, 1091, 1243 BEGIN END;
  SET @r2_sql = p_sql;
  PREPARE r2_stmt FROM @r2_sql;
  EXECUTE r2_stmt;
  DEALLOCATE PREPARE r2_stmt;
END//

DELIMITER ;

-- ============================================================================
-- 0. AUTH TABLE (created by the Node app too; IF NOT EXISTS keeps this standalone)
-- ============================================================================
CREATE TABLE IF NOT EXISTS UserAuth (
    auth_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('customer', 'admin') DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- ============================================================================
-- MODULE 2 - BANK, BRANCH, ACCOUNT TYPE
-- ============================================================================
CREATE TABLE IF NOT EXISTS Bank (
    bank_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_code VARCHAR(10) NOT NULL UNIQUE,
    bank_name VARCHAR(100) NOT NULL UNIQUE,
    head_office VARCHAR(150),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Bank (bank_code, bank_name, head_office)
SELECT 'SECB', 'SecureBank', 'Chennai, Tamil Nadu'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM Bank WHERE bank_code = 'SECB');

CREATE TABLE IF NOT EXISTS Branch (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    bank_id INT NOT NULL,
    branch_code VARCHAR(10) NOT NULL UNIQUE,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    contact VARCHAR(15),
    ifsc_code VARCHAR(11) UNIQUE,
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_branch_bank FOREIGN KEY (bank_id) REFERENCES Bank(bank_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

INSERT IGNORE INTO Branch (bank_id, branch_code, branch_name, address, city, state, contact, ifsc_code)
SELECT b.bank_id, v.branch_code, v.branch_name, v.address, v.city, v.state, v.contact, v.ifsc_code
FROM Bank b
JOIN (
    SELECT 'CHN001' AS branch_code, 'T Nagar Main Branch' AS branch_name, '12 Usman Road, T Nagar' AS address, 'Chennai' AS city, 'Tamil Nadu' AS state, '04412345601' AS contact, 'SECB0000001' AS ifsc_code
    UNION ALL SELECT 'CHN002', 'Anna Nagar Branch', '45 Second Avenue, Anna Nagar', 'Chennai', 'Tamil Nadu', '04412345602', 'SECB0000002'
    UNION ALL SELECT 'MUM001', 'Bandra Branch', '22 Linking Road, Bandra West', 'Mumbai', 'Maharashtra', '02212345601', 'SECB0000003'
    UNION ALL SELECT 'BLR001', 'Indiranagar Branch', '100 Feet Road, Indiranagar', 'Bengaluru', 'Karnataka', '08012345601', 'SECB0000004'
) v
WHERE b.bank_code = 'SECB';

-- Any legacy branch code already used by an account but unknown above gets a placeholder branch
INSERT IGNORE INTO Branch (bank_id, branch_code, branch_name, city, state)
SELECT (SELECT bank_id FROM Bank WHERE bank_code = 'SECB'), x.branch_code, CONCAT('Branch ', x.branch_code), 'Chennai', 'Tamil Nadu'
FROM (SELECT DISTINCT branch_code FROM Account WHERE branch_code IS NOT NULL AND branch_code <> '') x;

CREATE TABLE IF NOT EXISTS Account_Type (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(20) NOT NULL UNIQUE,
    interest_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    minimum_balance DECIMAL(10,2) NOT NULL DEFAULT 1000.00,
    description VARCHAR(255),
    CONSTRAINT chk_account_type_rate CHECK (interest_rate >= 0 AND interest_rate <= 100)
);

INSERT IGNORE INTO Account_Type (type_name, interest_rate, minimum_balance, description) VALUES
('Savings', 4.00, 1000.00, 'Savings account - 4.00% p.a. interest'),
('Current', 0.00, 1000.00, 'Business / current account - no interest'),
('Fixed Deposit', 6.50, 1000.00, 'Fixed deposit - 6.50% p.a. interest');

-- Account: branch becomes a real FK to Branch(branch_code) (natural key, e.g. CHN001)
-- and account_type a real FK to Account_Type(type_name). Existing rows are kept.
UPDATE Account SET branch_code = 'CHN001' WHERE branch_code IS NULL OR branch_code = '';

ALTER TABLE Account MODIFY branch_code VARCHAR(10) NOT NULL DEFAULT 'CHN001';

ALTER TABLE Account MODIFY account_type VARCHAR(20) NOT NULL;

CALL r2_try('ALTER TABLE Account ADD CONSTRAINT fk_account_branch FOREIGN KEY (branch_code) REFERENCES Branch(branch_code) ON UPDATE CASCADE ON DELETE RESTRICT');

CALL r2_try('ALTER TABLE Account ADD CONSTRAINT fk_account_type FOREIGN KEY (account_type) REFERENCES Account_Type(type_name) ON UPDATE CASCADE ON DELETE RESTRICT');

CALL r2_try('ALTER TABLE Account ADD CONSTRAINT chk_balance CHECK (balance >= 0)');

CALL r2_try('ALTER TABLE Account ADD CONSTRAINT chk_min_balance_non_negative CHECK (minimum_balance >= 0)');

-- ============================================================================
-- MODULE 3 / 4 - integrity constraints on money tables
-- ============================================================================
CALL r2_try('ALTER TABLE `Transaction` ADD CONSTRAINT chk_txn_amount CHECK (amount > 0)');

CALL r2_try('ALTER TABLE `Transaction` ADD INDEX idx_txn_account_date (account_id, transaction_date)');

CALL r2_try('ALTER TABLE Fund_Transfer ADD CONSTRAINT chk_ft_amount CHECK (amount > 0)');

CALL r2_try('ALTER TABLE Fund_Transfer ADD CONSTRAINT chk_ft_distinct_accounts CHECK (from_account_id <> to_account_id)');

CALL r2_try('ALTER TABLE Loan ADD CONSTRAINT chk_loan_amount CHECK (loan_amount > 0)');

CALL r2_try('ALTER TABLE Loan ADD CONSTRAINT chk_loan_outstanding CHECK (outstanding_amount IS NULL OR outstanding_amount >= 0)');

CALL r2_try('ALTER TABLE Loan_Payment ADD COLUMN remaining_amount DECIMAL(15,2) NULL');

CALL r2_try('ALTER TABLE Loan_Payment ADD CONSTRAINT chk_lp_amount_paid CHECK (amount_paid > 0)');

-- ============================================================================
-- MODULE 1 - CUSTOMER: Aadhaar stored ENCRYPTED (never plaintext)
--   aadhaar_encrypted   = AES-256-GCM value (decryptable only by the server key)
--   aadhaar_fingerprint = HMAC-SHA256 (non-reversible, duplicate detection only)
--   aadhaar_last4       = last 4 digits for masked display
-- The legacy plaintext column aadhar_number becomes NULLable; the Node startup
-- step (db/hardening.js) encrypts existing values and then sets it to NULL.
-- ============================================================================
CALL r2_try('ALTER TABLE Customer ADD COLUMN aadhaar_encrypted VARCHAR(512) NULL');

CALL r2_try('ALTER TABLE Customer ADD COLUMN aadhaar_fingerprint CHAR(64) NULL');

CALL r2_try('ALTER TABLE Customer ADD COLUMN aadhaar_last4 CHAR(4) NULL');

CALL r2_try('ALTER TABLE Customer ADD UNIQUE INDEX uq_customer_aadhaar_fp (aadhaar_fingerprint)');

ALTER TABLE Customer MODIFY aadhar_number VARCHAR(12) NULL;

UPDATE Customer SET aadhaar_last4 = RIGHT(aadhar_number, 4)
WHERE aadhaar_last4 IS NULL AND aadhar_number IS NOT NULL;

-- ============================================================================
-- MODULE 1 - KYC_Document (structured metadata + encrypted binary payload)
-- ============================================================================
CREATE TABLE IF NOT EXISTS KYC_Document (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    document_type ENUM('AADHAAR') NOT NULL DEFAULT 'AADHAAR',
    storage_name CHAR(32) NOT NULL UNIQUE,
    encrypted_document LONGBLOB NOT NULL,
    encryption_iv VARBINARY(16) NOT NULL,
    encryption_auth_tag VARBINARY(16) NOT NULL,
    original_file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size INT UNSIGNED NOT NULL,
    document_hash CHAR(64) NOT NULL,
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') NOT NULL DEFAULT 'PENDING',
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP NULL,
    verified_by INT NULL,
    rejection_reason VARCHAR(255) NULL,
    CONSTRAINT fk_kyc_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_kyc_verified_by FOREIGN KEY (verified_by) REFERENCES UserAuth(auth_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_kyc_file_size CHECK (file_size > 0 AND file_size <= 5242880),
    INDEX idx_kyc_customer_status (customer_id, verification_status)
);

-- ============================================================================
-- MODULE 1 - Customer_Status_Audit + Audit_Log
-- ============================================================================
CREATE TABLE IF NOT EXISTS Customer_Status_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    customer_name VARCHAR(100),
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CALL r2_try('ALTER TABLE Customer_Status_Audit ADD CONSTRAINT fk_csa_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE RESTRICT');

CREATE TABLE IF NOT EXISTS Audit_Log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NULL,
    actor_auth_id INT NULL,
    actor_role VARCHAR(30) NULL,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(30) NULL,
    entity_id VARCHAR(40) NULL,
    details VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE RESTRICT,
    INDEX idx_audit_action (action),
    INDEX idx_audit_customer_time (customer_id, created_at)
);

-- ============================================================================
-- MODULE 2 - CARD (link to customer, masked display, protected PAN / CVV)
--   card_number holds an AES-256-GCM value ("enc:v1:...") after hardening
--   cvv holds a bcrypt hash (the CVV itself is never stored or returned)
-- ============================================================================
CALL r2_try('ALTER TABLE Card ADD COLUMN customer_id INT NULL');

CALL r2_try('ALTER TABLE Card ADD COLUMN last_four_digits CHAR(4) NULL');

UPDATE Card c JOIN Account a ON a.account_id = c.account_id
SET c.customer_id = a.customer_id
WHERE c.customer_id IS NULL;

UPDATE Card SET last_four_digits = RIGHT(card_number, 4)
WHERE last_four_digits IS NULL AND card_number REGEXP '^[0-9]{16}$';

ALTER TABLE Card MODIFY card_number VARCHAR(255) NOT NULL;

ALTER TABLE Card MODIFY cvv VARCHAR(255) NULL;

CALL r2_try('ALTER TABLE Card ADD CONSTRAINT fk_card_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE RESTRICT');

ALTER TABLE Card MODIFY customer_id INT NOT NULL;

CALL r2_try('ALTER TABLE Card ADD CONSTRAINT chk_card_daily_limit CHECK (daily_limit > 0)');

-- ============================================================================
-- MODULE 2 - BENEFICIARY (a customer cannot list the same payee twice)
-- ============================================================================
CALL r2_try('ALTER TABLE Beneficiary ADD UNIQUE INDEX uq_beneficiary_customer_account (customer_id, beneficiary_account)');

-- ============================================================================
-- DEMO DATA (synthetic) so that every risk class / loan type can be demonstrated
-- ============================================================================
INSERT INTO Loan (customer_id, loan_type, loan_amount, interest_rate, tenure_months, monthly_emi, outstanding_amount, application_date, approval_date, disbursement_date, status)
SELECT c.customer_id, 'Business', 1000000.00, 11.00, 36, 32737.00, 920000.00, '2023-06-01', '2023-06-05', '2023-06-10', 'Disbursed'
FROM Customer c
WHERE c.email = 'info@techcorp.com'
  AND NOT EXISTS (SELECT 1 FROM Loan l WHERE l.customer_id = c.customer_id AND l.loan_type = 'Business' AND l.loan_amount = 1000000.00);

INSERT INTO Loan (customer_id, loan_type, loan_amount, interest_rate, tenure_months, monthly_emi, outstanding_amount, application_date, approval_date, disbursement_date, status)
SELECT c.customer_id, 'Personal', 150000.00, 12.00, 24, 7061.00, 60000.00, '2023-04-01', '2023-04-04', '2023-04-08', 'Disbursed'
FROM Customer c
WHERE c.email = 'priya.sharma@email.com'
  AND NOT EXISTS (SELECT 1 FROM Loan l WHERE l.customer_id = c.customer_id AND l.loan_type = 'Personal' AND l.loan_amount = 150000.00);

INSERT INTO Loan_Payment (loan_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method, remaining_amount)
SELECT l.loan_id, '2023-09-10', 90000.00, 80000.00, 10000.00, 'Online', 920000.00
FROM Loan l JOIN Customer c ON c.customer_id = l.customer_id
WHERE c.email = 'info@techcorp.com' AND l.loan_type = 'Business' AND l.loan_amount = 1000000.00
  AND NOT EXISTS (SELECT 1 FROM Loan_Payment p WHERE p.loan_id = l.loan_id);

INSERT INTO Loan_Payment (loan_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method, remaining_amount)
SELECT l.loan_id, '2023-10-08', 99000.00, 90000.00, 9000.00, 'Online', 60000.00
FROM Loan l JOIN Customer c ON c.customer_id = l.customer_id
WHERE c.email = 'priya.sharma@email.com' AND l.loan_type = 'Personal' AND l.loan_amount = 150000.00
  AND NOT EXISTS (SELECT 1 FROM Loan_Payment p WHERE p.loan_id = l.loan_id);

-- ============================================================================
-- VIEWS
-- ============================================================================
CREATE OR REPLACE VIEW customer_account_summary AS
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       a.account_id,
       a.account_number,
       a.account_type,
       aty.interest_rate AS type_interest_rate,
       a.balance,
       a.minimum_balance,
       a.status AS account_status,
       br.branch_code,
       br.branch_name,
       br.city AS branch_city
FROM Customer c
JOIN Account a ON a.customer_id = c.customer_id
JOIN Account_Type aty ON aty.type_name = a.account_type
JOIN Branch br ON br.branch_code = a.branch_code;

CREATE OR REPLACE VIEW transaction_history_view AS
SELECT t.transaction_id,
       t.account_id,
       a.account_number,
       c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       t.transaction_type,
       CASE WHEN t.transaction_type IN ('Deposit', 'Interest Credit') THEN 'CREDIT' ELSE 'DEBIT' END AS direction,
       t.amount,
       t.balance_after,
       t.transaction_date,
       t.description,
       t.reference_number,
       t.status
FROM `Transaction` t
JOIN Account a ON a.account_id = t.account_id
JOIN Customer c ON c.customer_id = a.customer_id;

-- FIX: the original view joined Account and Loan side by side, so loan debt was
-- multiplied by the number of accounts. Each side is now aggregated first.
CREATE OR REPLACE VIEW vw_customer_financial_profile AS
SELECT c.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       c.status AS customer_status,
       COALESCE(a.total_accounts, 0) AS total_accounts,
       COALESCE(a.total_balance, 0) AS total_balance,
       COALESCE(l.total_loans, 0) AS total_loans,
       COALESCE(l.total_debt, 0) AS total_debt,
       COALESCE(a.total_balance, 0) - COALESCE(l.total_debt, 0) AS net_worth
FROM Customer c
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS total_accounts, SUM(balance) AS total_balance
    FROM Account WHERE status = 'Active' GROUP BY customer_id
) a ON a.customer_id = c.customer_id
LEFT JOIN (
    SELECT customer_id, COUNT(*) AS total_loans, SUM(outstanding_amount) AS total_debt
    FROM Loan WHERE status = 'Disbursed' GROUP BY customer_id
) l ON l.customer_id = c.customer_id;

CREATE OR REPLACE VIEW vw_loan_payment_tracker AS
SELECT l.loan_id,
       l.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       l.loan_type,
       l.loan_amount,
       l.monthly_emi,
       l.tenure_months,
       l.status AS loan_status,
       l.outstanding_amount,
       l.loan_amount - l.outstanding_amount AS amount_paid_so_far,
       COALESCE(p.payments_made, 0) AS payments_made,
       COALESCE(p.total_paid, 0) AS total_paid,
       COALESCE(p.total_principal_paid, 0) AS total_principal_paid,
       COALESCE(p.total_interest_paid, 0) AS total_interest_paid,
       l.outstanding_amount AS outstanding_principal,
       GREATEST(ROUND(COALESCE(l.monthly_emi, 0) * GREATEST(l.tenure_months - COALESCE(p.payments_made, 0), 0) - l.outstanding_amount, 2), 0) AS outstanding_interest,
       ROUND((l.outstanding_amount / l.loan_amount) * 100, 2) AS percent_remaining,
       CASE
           WHEN l.status = 'Closed' OR l.outstanding_amount <= 0 THEN 'Paid Off'
           WHEN COALESCE(p.payments_made, 0) = 0 THEN 'No Payments Yet'
           ELSE 'In Repayment'
       END AS payment_status
FROM Loan l
JOIN Customer c ON c.customer_id = l.customer_id
LEFT JOIN (
    SELECT loan_id,
           COUNT(*) AS payments_made,
           SUM(amount_paid) AS total_paid,
           SUM(principal_amount) AS total_principal_paid,
           SUM(interest_amount) AS total_interest_paid
    FROM Loan_Payment GROUP BY loan_id
) p ON p.loan_id = l.loan_id
WHERE l.status IN ('Disbursed', 'Closed');

CREATE OR REPLACE VIEW vw_branch_summary AS
SELECT br.branch_id,
       br.branch_code,
       br.branch_name,
       br.city,
       br.state,
       COUNT(DISTINCT a.customer_id) AS total_customers,
       COUNT(a.account_id) AS total_accounts,
       COALESCE(SUM(a.balance), 0) AS total_balance
FROM Branch br
LEFT JOIN Account a ON a.branch_code = br.branch_code AND a.status = 'Active'
GROUP BY br.branch_id, br.branch_code, br.branch_name, br.city, br.state;

-- Cards without PAN or CVV: the only card view the application uses
CREATE OR REPLACE VIEW vw_card_masked AS
SELECT cd.card_id,
       cd.customer_id,
       cd.account_id,
       cd.card_type,
       CONCAT('**** **** **** ', cd.last_four_digits) AS masked_card_number,
       cd.last_four_digits,
       cd.expiry_date,
       cd.status AS card_status,
       cd.daily_limit,
       cd.issue_date
FROM Card cd;

-- KYC metadata for admins: deliberately excludes the encrypted payload column
CREATE OR REPLACE VIEW vw_kyc_overview AS
SELECT k.document_id,
       k.customer_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       c.email,
       c.aadhaar_last4,
       c.status AS customer_status,
       k.document_type,
       k.original_file_name,
       k.mime_type,
       k.file_size,
       k.verification_status,
       k.uploaded_at,
       k.verified_at,
       k.verified_by,
       k.rejection_reason
FROM KYC_Document k
JOIN Customer c ON c.customer_id = k.customer_id;

-- ============================================================================
-- TRIGGERS
-- ============================================================================
-- Remove the broken legacy trigger from the old script (it wrote to the
-- non-existent table Customer_Status) and all objects we are about to rebuild.
DROP TRIGGER IF EXISTS trg_log_customer;
DROP TRIGGER IF EXISTS trg_log_customer_status_change;
DROP TRIGGER IF EXISTS trg_set_balance_after;
DROP TRIGGER IF EXISTS trg_check_minimum_balance;
DROP TRIGGER IF EXISTS trg_update_balance_after_txn;
DROP TRIGGER IF EXISTS trg_card_customer_consistency;
DROP TRIGGER IF EXISTS trg_audit_log_no_update;
DROP TRIGGER IF EXISTS trg_audit_log_no_delete;

DELIMITER //

-- MODULE 1: every customer status change is recorded automatically
CREATE TRIGGER trg_log_customer_status_change
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    IF NOT (OLD.status <=> NEW.status) THEN
        INSERT INTO Customer_Status_Audit (customer_id, customer_name, old_status, new_status)
        VALUES (NEW.customer_id, CONCAT(NEW.first_name, ' ', NEW.last_name), OLD.status, NEW.status);

        INSERT INTO Audit_Log (customer_id, actor_role, action, entity_type, entity_id, details)
        VALUES (NEW.customer_id, 'DB_TRIGGER', 'CUSTOMER_STATUS_CHANGED', 'Customer', NEW.customer_id,
                CONCAT(OLD.status, ' -> ', NEW.status));
    END IF;
END//

-- MODULE 3: BEFORE INSERT guard. Withdrawals and outgoing transfers may not
-- leave the account below its minimum balance. The row is locked (FOR UPDATE)
-- so the balance cannot change between this check and the insert.
CREATE TRIGGER trg_check_minimum_balance
BEFORE INSERT ON `Transaction`
FOR EACH ROW
BEGIN
    DECLARE v_current_balance DECIMAL(15,2);
    DECLARE v_min_balance DECIMAL(10,2);

    IF NEW.transaction_type IN ('Withdrawal', 'Transfer') AND NEW.status = 'Completed' THEN
        SELECT balance, minimum_balance
        INTO v_current_balance, v_min_balance
        FROM Account
        WHERE account_id = NEW.account_id
        FOR UPDATE;

        IF (v_current_balance - NEW.amount) < v_min_balance THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Withdrawal denied: Balance would fall below minimum balance';
        END IF;
    END IF;
END//

-- MODULE 3: the ledger row always carries the balance after the operation
CREATE TRIGGER trg_set_balance_after
BEFORE INSERT ON `Transaction`
FOR EACH ROW
FOLLOWS trg_check_minimum_balance
BEGIN
    DECLARE v_current_balance DECIMAL(15,2);

    IF NEW.status = 'Completed' THEN
        SELECT balance INTO v_current_balance
        FROM Account
        WHERE account_id = NEW.account_id
        FOR UPDATE;

        IF NEW.transaction_type IN ('Deposit', 'Interest Credit') THEN
            SET NEW.balance_after = v_current_balance + NEW.amount;
        ELSE
            SET NEW.balance_after = v_current_balance - NEW.amount;
        END IF;
    END IF;
END//

-- MODULE 3: THE ONE AND ONLY balance-update mechanism. The application never
-- runs UPDATE Account SET balance for deposits / withdrawals / transfers.
CREATE TRIGGER trg_update_balance_after_txn
AFTER INSERT ON `Transaction`
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' THEN
        IF NEW.transaction_type IN ('Deposit', 'Interest Credit') THEN
            UPDATE Account SET balance = balance + NEW.amount WHERE account_id = NEW.account_id;
        ELSEIF NEW.transaction_type IN ('Withdrawal', 'Fee Debit', 'Transfer') THEN
            UPDATE Account SET balance = balance - NEW.amount WHERE account_id = NEW.account_id;
        END IF;
    END IF;
END//

-- MODULE 2: a card may only be linked to an account of the same customer
CREATE TRIGGER trg_card_customer_consistency
BEFORE INSERT ON Card
FOR EACH ROW
BEGIN
    DECLARE v_owner INT;

    SELECT customer_id INTO v_owner FROM Account WHERE account_id = NEW.account_id;
    IF v_owner IS NULL OR v_owner <> NEW.customer_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Card customer must be the owner of the linked account';
    END IF;
END//

-- MODULE 1: the audit trail is append-only (tamper evidence)
CREATE TRIGGER trg_audit_log_no_update
BEFORE UPDATE ON Audit_Log
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Audit_Log is append-only: updates are not permitted';
END//

CREATE TRIGGER trg_audit_log_no_delete
BEFORE DELETE ON Audit_Log
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Audit_Log is append-only: deletes are not permitted';
END//

DELIMITER ;

-- ============================================================================
-- STORED PROCEDURES (with real cursors)
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_calculate_interest_all_accounts;
DROP PROCEDURE IF EXISTS sp_flag_high_outstanding_loans;
DROP PROCEDURE IF EXISTS sp_make_loan_payment;

DELIMITER //

-- MODULE 4: savings_cursor walks every ACTIVE savings account and uses the
-- interest rate configured in Account_Type.
CREATE PROCEDURE sp_calculate_interest_all_accounts()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_account_id INT;
    DECLARE v_account_number VARCHAR(16);
    DECLARE v_customer_name VARCHAR(101);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_rate DECIMAL(5,2);
    DECLARE v_annual_interest DECIMAL(15,2);
    DECLARE v_monthly_interest DECIMAL(15,2);

    DECLARE savings_cursor CURSOR FOR
        SELECT a.account_id, a.account_number, CONCAT(c.first_name, ' ', c.last_name), a.balance, t.interest_rate
        FROM Account a
        JOIN Account_Type t ON t.type_name = a.account_type
        JOIN Customer c ON c.customer_id = a.customer_id
        WHERE a.account_type = 'Savings' AND a.status = 'Active'
        ORDER BY a.account_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS temp_interest_calc;
    CREATE TEMPORARY TABLE temp_interest_calc (
        account_id INT,
        account_number VARCHAR(16),
        customer_name VARCHAR(101),
        current_balance DECIMAL(15,2),
        interest_rate DECIMAL(5,2),
        monthly_interest DECIMAL(15,2),
        annual_interest DECIMAL(15,2)
    );

    OPEN savings_cursor;

    calc_loop: LOOP
        FETCH savings_cursor INTO v_account_id, v_account_number, v_customer_name, v_balance, v_rate;
        IF done THEN
            LEAVE calc_loop;
        END IF;

        SET v_annual_interest = ROUND(v_balance * v_rate / 100, 2);
        SET v_monthly_interest = ROUND(v_annual_interest / 12, 2);

        INSERT INTO temp_interest_calc
        VALUES (v_account_id, v_account_number, v_customer_name, v_balance, v_rate, v_monthly_interest, v_annual_interest);
    END LOOP;

    CLOSE savings_cursor;

    SELECT * FROM temp_interest_calc ORDER BY annual_interest DESC;
    DROP TEMPORARY TABLE temp_interest_calc;
END//

-- MODULE 4: loan_cursor walks every DISBURSED loan and classifies the risk.
--   > 95 % still outstanding  -> CRITICAL
--   > 90 % still outstanding  -> HIGH RISK
--   otherwise                 -> NORMAL
CREATE PROCEDURE sp_flag_high_outstanding_loans()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_loan_id INT;
    DECLARE v_customer_id INT;
    DECLARE v_customer_name VARCHAR(101);
    DECLARE v_loan_type VARCHAR(20);
    DECLARE v_loan_amount DECIMAL(15,2);
    DECLARE v_outstanding DECIMAL(15,2);
    DECLARE v_percent DECIMAL(6,2);
    DECLARE v_flag VARCHAR(20);

    DECLARE loan_cursor CURSOR FOR
        SELECT l.loan_id, l.customer_id, CONCAT(c.first_name, ' ', c.last_name),
               l.loan_type, l.loan_amount, COALESCE(l.outstanding_amount, 0)
        FROM Loan l
        INNER JOIN Customer c ON c.customer_id = l.customer_id
        WHERE l.status = 'Disbursed'
        ORDER BY l.loan_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS temp_loan_flags;
    CREATE TEMPORARY TABLE temp_loan_flags (
        loan_id INT,
        customer_id INT,
        customer_name VARCHAR(101),
        loan_type VARCHAR(20),
        loan_amount DECIMAL(15,2),
        outstanding_amount DECIMAL(15,2),
        percent_outstanding DECIMAL(6,2),
        risk_flag VARCHAR(20)
    );

    OPEN loan_cursor;

    flag_loop: LOOP
        FETCH loan_cursor INTO v_loan_id, v_customer_id, v_customer_name, v_loan_type, v_loan_amount, v_outstanding;
        IF done THEN
            LEAVE flag_loop;
        END IF;

        SET v_percent = ROUND((v_outstanding / v_loan_amount) * 100, 2);

        IF v_percent > 95 THEN
            SET v_flag = 'CRITICAL';
        ELSEIF v_percent > 90 THEN
            SET v_flag = 'HIGH RISK';
        ELSE
            SET v_flag = 'NORMAL';
        END IF;

        INSERT INTO temp_loan_flags
        VALUES (v_loan_id, v_customer_id, v_customer_name, v_loan_type, v_loan_amount, v_outstanding, v_percent, v_flag);
    END LOOP;

    CLOSE loan_cursor;

    SELECT * FROM temp_loan_flags ORDER BY percent_outstanding DESC, loan_id;
    DROP TEMPORARY TABLE temp_loan_flags;
END//

-- MODULE 4 / 5: one ACID unit of work. Lock order: Loan row, then Account row.
-- Any error (including the minimum-balance trigger) triggers ROLLBACK, so the
-- debit, the Loan_Payment row and the new outstanding amount stay consistent.
CREATE PROCEDURE sp_make_loan_payment(
    IN p_loan_id INT,
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_actor_auth_id INT,
    IN p_actor_role VARCHAR(30)
)
BEGIN
    DECLARE v_loan_customer INT;
    DECLARE v_outstanding DECIMAL(15,2);
    DECLARE v_rate DECIMAL(5,2);
    DECLARE v_loan_status VARCHAR(20);
    DECLARE v_acc_customer INT;
    DECLARE v_acc_status VARCHAR(20);
    DECLARE v_interest_due DECIMAL(15,2);
    DECLARE v_principal DECIMAL(15,2);
    DECLARE v_interest_paid DECIMAL(15,2);
    DECLARE v_remaining DECIMAL(15,2);
    DECLARE v_ref VARCHAR(20);
    DECLARE v_txn_id INT;
    DECLARE v_payment_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT customer_id, outstanding_amount, interest_rate, status
    INTO v_loan_customer, v_outstanding, v_rate, v_loan_status
    FROM Loan WHERE loan_id = p_loan_id FOR UPDATE;

    IF v_loan_customer IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan not found';
    END IF;
    IF v_loan_status <> 'Disbursed' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loan is not open for repayment';
    END IF;

    SELECT customer_id, status
    INTO v_acc_customer, v_acc_status
    FROM Account WHERE account_id = p_account_id FOR UPDATE;

    IF v_acc_customer IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment account not found';
    END IF;
    IF v_acc_customer <> v_loan_customer THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment account must belong to the loan holder';
    END IF;
    IF v_acc_status <> 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment account is not active';
    END IF;

    SET v_outstanding = COALESCE(v_outstanding, 0);
    SET v_interest_due = ROUND(v_outstanding * v_rate / 1200, 2);

    IF p_amount > v_outstanding + v_interest_due THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment exceeds the total amount due';
    END IF;

    SET v_principal = GREATEST(p_amount - v_interest_due, 0);
    IF v_principal > v_outstanding THEN
        SET v_principal = v_outstanding;
    END IF;
    SET v_interest_paid = p_amount - v_principal;
    SET v_remaining = v_outstanding - v_principal;
    SET v_ref = CONCAT('LPY', RIGHT(UUID_SHORT(), 15));

    INSERT INTO `Transaction` (account_id, transaction_type, amount, description, reference_number, status)
    VALUES (p_account_id, 'Withdrawal', p_amount, CONCAT('Loan EMI payment - Loan #', p_loan_id), v_ref, 'Completed');
    SET v_txn_id = LAST_INSERT_ID();

    INSERT INTO Loan_Payment (loan_id, payment_date, amount_paid, principal_amount, interest_amount, payment_method, transaction_id, remaining_amount)
    VALUES (p_loan_id, CURDATE(), p_amount, v_principal, v_interest_paid, 'Manual', v_txn_id, v_remaining);
    SET v_payment_id = LAST_INSERT_ID();

    UPDATE Loan
    SET outstanding_amount = v_remaining,
        status = IF(v_remaining <= 0, 'Closed', 'Disbursed')
    WHERE loan_id = p_loan_id;

    INSERT INTO Audit_Log (customer_id, actor_auth_id, actor_role, action, entity_type, entity_id, details)
    VALUES (v_loan_customer, p_actor_auth_id, p_actor_role, 'LOAN_PAYMENT', 'Loan', p_loan_id,
            CONCAT('amount=', p_amount, ' principal=', v_principal, ' interest=', v_interest_paid, ' remaining=', v_remaining));

    COMMIT;

    SELECT v_payment_id AS payment_id,
           v_txn_id AS transaction_id,
           v_ref AS reference_number,
           p_amount AS amount_paid,
           v_principal AS principal_paid,
           v_interest_paid AS interest_paid,
           v_remaining AS remaining_amount;
END//

DELIMITER ;

-- ----------------------------------------------------------------------------
-- cleanup helper
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS r2_try;
