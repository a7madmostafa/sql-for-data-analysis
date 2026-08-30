-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Parch & Posey Database
-- ============================================================
-- Answer key for day05_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 1.1
SELECT occurred_at, poster_qty,
       SUM(poster_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- 1.2
SELECT account_id, occurred_at, gloss_qty,
       SUM(gloss_qty) OVER (PARTITION BY account_id ORDER BY occurred_at) AS account_running_total
FROM orders
ORDER BY account_id, occurred_at
LIMIT 20;


-- ======================================
-- SECTION 2 — RANKING
-- ======================================

-- 2.1
WITH account_totals AS (
    SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spend
    FROM orders o
    JOIN accounts a ON o.account_id = a.id
    GROUP BY a.id, a.name
)
SELECT name, total_spend,
       RANK()       OVER (ORDER BY total_spend DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY total_spend DESC) AS dense_rank_no_gaps,
       ROW_NUMBER() OVER (ORDER BY total_spend DESC) AS row_num
FROM account_totals
ORDER BY total_spend DESC
LIMIT 10;

-- 2.2
WITH account_totals AS (
    SELECT a.id, a.name AS account_name, s.name AS rep_name,
           SUM(o.total_amt_usd) AS total_spend
    FROM orders o
    JOIN accounts a ON o.account_id = a.id
    JOIN sales_reps s ON a.sales_rep_id = s.id
    GROUP BY a.id, a.name, s.name
),
ranked AS (
    SELECT rep_name, account_name, total_spend,
           ROW_NUMBER() OVER (PARTITION BY rep_name ORDER BY total_spend DESC) AS acct_rank
    FROM account_totals
)
SELECT rep_name, account_name, total_spend
FROM ranked
WHERE acct_rank = 1
ORDER BY rep_name;


-- ======================================
-- SECTION 3 — LAG / LEAD
-- ======================================

-- 3.1
WITH monthly_events AS (
    SELECT DATE_FORMAT(occurred_at, '%Y-%m') AS month, COUNT(*) AS num_events
    FROM web_events
    GROUP BY month
)
SELECT month, num_events,
       LAG(num_events) OVER (ORDER BY month) AS prev_month_events,
       num_events - LAG(num_events) OVER (ORDER BY month) AS change_from_prev_month
FROM monthly_events
ORDER BY month;


-- ======================================
-- SECTION 4 — STORED PROCEDURES
-- ======================================

-- 4.1
DROP PROCEDURE IF EXISTS region_sales_report;

DELIMITER $$

CREATE PROCEDURE region_sales_report(IN reg_id INT)
BEGIN
    SELECT r.name AS region_name,
           COUNT(o.id) AS num_orders,
           SUM(o.total_amt_usd) AS total_revenue
    FROM region r
    JOIN sales_reps s ON s.region_id = r.id
    JOIN accounts a ON a.sales_rep_id = s.id
    JOIN orders o ON o.account_id = a.id
    WHERE r.id = reg_id
    GROUP BY r.name;
END$$

DELIMITER ;

CALL region_sales_report(1);

-- 4.2
DROP PROCEDURE IF EXISTS get_account_count;

DELIMITER $$

CREATE PROCEDURE get_account_count(OUT cnt INT)
BEGIN
    SELECT COUNT(*) INTO cnt FROM accounts;
END$$

DELIMITER ;

CALL get_account_count(@n);
SELECT @n AS account_count;


-- ======================================
-- CHALLENGE QUESTION
-- ======================================

-- C1
WITH rep_totals AS (
    SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a ON o.account_id = a.id
    JOIN sales_reps s ON a.sales_rep_id = s.id
    GROUP BY s.id, s.name
)
SELECT name, total_sales,
       NTILE(4) OVER (ORDER BY total_sales DESC) AS sales_tier
FROM rep_totals
ORDER BY total_sales DESC;
