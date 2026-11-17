-- SET 1: MONTHLY BANK STATEMENT
-- File name: statement_cte.sql
-- MySQL 8.4

USE bank_db;

-- Display each transaction with its row number and previous balance.
-- Change the account ID and month when required.

SET @account_id = 1;
SET @month_start = '2026-11-01';

WITH monthly_data AS (
    SELECT
        t.transaction_id,
        t.account_id,
        t.transaction_date,
        t.transaction_type,
        t.amount,
        a.balance AS current_balance
    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id
    WHERE t.account_id = @account_id
      AND t.transaction_date >= @month_start
      AND t.transaction_date < DATE_ADD(@month_start, INTERVAL 1 MONTH)
),
statement AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY transaction_date, transaction_id
        ) AS row_number,
        transaction_id,
        account_id,
        transaction_date,
        transaction_type,
        amount,
        LAG(current_balance) OVER (
            ORDER BY transaction_date, transaction_id
        ) AS previous_balance,
        current_balance
    FROM monthly_data
)
SELECT *
FROM statement
ORDER BY transaction_date, transaction_id;
