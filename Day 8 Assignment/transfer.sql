-- SET 1: BANK FUNDS TRANSFER
-- File name: transfer.sql
-- MySQL 8.4

CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;

-- Creating account table
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT PRIMARY KEY,
    account_name VARCHAR(50),
    balance DECIMAL(10,2),
    status VARCHAR(20)
) ENGINE=InnoDB;

-- Creating transaction table
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10),
    amount DECIMAL(10,2),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
) ENGINE=InnoDB;

-- Sample records
INSERT INTO accounts VALUES
(1, 'Arun', 10000.00, 'ACTIVE'),
(2, 'Bala', 5000.00, 'ACTIVE')
ON DUPLICATE KEY UPDATE
account_name = VALUES(account_name),
balance = VALUES(balance),
status = VALUES(status);

-- TASK 1: Funds transfer using transaction
DROP PROCEDURE IF EXISTS transfer_money;
DELIMITER $$

CREATE PROCEDURE transfer_money(
    IN sender INT,
    IN receiver INT,
    IN transfer_amount DECIMAL(10,2)
)
BEGIN
    DECLARE sender_balance DECIMAL(10,2);
    DECLARE sender_status VARCHAR(20);
    DECLARE receiver_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Lock the account rows while transferring
    SELECT balance, status
    INTO sender_balance, sender_status
    FROM accounts
    WHERE account_id = sender
    FOR UPDATE;

    SELECT status INTO receiver_status
    FROM accounts
    WHERE account_id = receiver
    FOR UPDATE;

    -- Checking account status and balance
    IF sender_status <> 'ACTIVE' OR receiver_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Both accounts must be active';
    ELSEIF transfer_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Amount must be greater than zero';
    ELSEIF sender_balance < transfer_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    ELSE
        UPDATE accounts
        SET balance = balance - transfer_amount
        WHERE account_id = sender;

        UPDATE accounts
        SET balance = balance + transfer_amount
        WHERE account_id = receiver;

        INSERT INTO transactions(account_id, transaction_type, amount)
        VALUES(sender, 'DEBIT', transfer_amount);

        INSERT INTO transactions(account_id, transaction_type, amount)
        VALUES(receiver, 'CREDIT', transfer_amount);

        COMMIT;
    END IF;
END$$
DELIMITER ;

-- Successful transfer: Arun sends 1000 to Bala
CALL transfer_money(1, 2, 1000.00);

SELECT * FROM accounts;

-- TASK 2: Demonstrating ROLLBACK
-- Check balances before failure
SELECT * FROM accounts;

START TRANSACTION;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1;

-- The debit has happened inside the transaction.
SELECT * FROM accounts;

-- Deliberately cancel the transaction to demonstrate rollback.
ROLLBACK;

-- Evidence: balances are restored to the values before this transaction.
SELECT * FROM accounts;

-- TASK 3: SAVEPOINT
START TRANSACTION;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 1 AND balance >= 200;

UPDATE accounts
SET balance = balance + 200
WHERE account_id = 2;

-- Save the successful transfer before posting the fee
SAVEPOINT transfer_done;

INSERT INTO transactions(account_id, transaction_type, amount)
VALUES(1, 'FEE', 25.00);

-- Undo only the fee insert; transfer updates are retained
ROLLBACK TO SAVEPOINT transfer_done;

COMMIT;

SELECT * FROM accounts;
SELECT * FROM transactions;
