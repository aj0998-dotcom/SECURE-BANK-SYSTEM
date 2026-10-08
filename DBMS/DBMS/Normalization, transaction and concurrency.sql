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