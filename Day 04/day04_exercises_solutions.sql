-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Parch & Posey Database
-- ============================================================
-- Answer key for day04_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES
-- ======================================

-- 1.1
SELECT *
FROM orders
WHERE DATE(occurred_at) = (SELECT MIN(DATE(occurred_at)) FROM orders);

-- 1.2
SELECT id, account_id, total_amt_usd
FROM orders
WHERE total_amt_usd < (SELECT AVG(total_amt_usd) FROM orders);


-- ======================================
-- SECTION 2 — ROW SUBQUERIES
-- ======================================

-- 2.1
SELECT account_id, occurred_at, channel
FROM web_events
WHERE (account_id, occurred_at) IN (
    SELECT account_id, MIN(occurred_at)
    FROM web_events
    GROUP BY account_id
)
ORDER BY account_id;


-- ======================================
-- SECTION 3 — DERIVED TABLES
-- ======================================

-- 3.1
SELECT AVG(avg_order_value) AS avg_of_account_averages
FROM (
    SELECT account_id, AVG(total_amt_usd) AS avg_order_value
    FROM orders
    GROUP BY account_id
) AS account_averages;


-- ======================================
-- SECTION 4 — CTEs
-- ======================================

-- 4.1
WITH account_averages AS (
    SELECT account_id, AVG(total_amt_usd) AS avg_order_value
    FROM orders
    GROUP BY account_id
)
SELECT AVG(avg_order_value) AS avg_of_account_averages
FROM account_averages;

-- 4.2
WITH rep_totals AS (
    SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    JOIN sales_reps s
        ON a.sales_rep_id = s.id
    GROUP BY s.id, s.name
)
SELECT id, name, total_sales
FROM rep_totals
ORDER BY total_sales DESC
LIMIT 1;


-- ======================================
-- SECTION 5 — CHAINED CTEs
-- ======================================

-- 5.1
WITH rep_totals AS (
    SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    JOIN sales_reps s
        ON a.sales_rep_id = s.id
    GROUP BY s.id, s.name
),
top_rep AS (
    SELECT id, name, total_sales
    FROM rep_totals
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT top_rep.name, COUNT(DISTINCT a.id) AS num_accounts, COUNT(o.id) AS num_orders
FROM top_rep
JOIN accounts a
    ON a.sales_rep_id = top_rep.id
JOIN orders o
    ON o.account_id = a.id
GROUP BY top_rep.name;


-- ======================================
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- 6.1
CREATE TEMPORARY TABLE top_rep
SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
ORDER BY total_sales DESC
LIMIT 1;

SELECT * FROM top_rep;

SELECT top_rep.name, COUNT(*) AS num_accounts
FROM top_rep
JOIN accounts a
    ON a.sales_rep_id = top_rep.id
GROUP BY top_rep.name;


-- ======================================
-- SECTION 7 — VIEWS
-- ======================================

-- 7.1
CREATE VIEW top5_sales_reps AS
SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
ORDER BY total_sales DESC
LIMIT 5;

SELECT w.channel, COUNT(*) AS num_events
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
JOIN top5_sales_reps t
    ON a.sales_rep_id = t.id
GROUP BY w.channel
ORDER BY num_events DESC;


-- ======================================
-- SECTION 8 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 8.1
SELECT occurred_at, poster_qty,
       SUM(poster_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- 8.2
SELECT account_id, occurred_at, gloss_qty,
       SUM(gloss_qty) OVER (PARTITION BY account_id ORDER BY occurred_at) AS account_running_total
FROM orders
ORDER BY account_id, occurred_at
LIMIT 20;


-- ======================================
-- SECTION 9 — RANKING
-- ======================================

-- 9.1
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

-- 9.2
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
-- SECTION 10 — LAG / LEAD
-- ======================================

-- 10.1
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
-- SECTION 11 — STORED PROCEDURES
-- ======================================

-- 11.1
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

-- 11.2
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
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
WITH account_spend AS (
    SELECT a.id, a.name, a.primary_poc, SUM(o.total_amt_usd) AS total_spend
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    GROUP BY a.id, a.name, a.primary_poc
)
SELECT name,
    CONCAT(
        LOWER(LEFT(primary_poc, LOCATE(' ', primary_poc) - 1)), '.',
        LOWER(RIGHT(primary_poc, LENGTH(primary_poc) - LOCATE(' ', primary_poc))), '@',
        LOWER(REPLACE(name, ' ', '')), '.com'
    ) AS email
FROM account_spend
WHERE total_spend > (SELECT AVG(total_spend) FROM account_spend);

-- C2
WITH account_avg AS (
    SELECT a.id, s.region_id, AVG(o.total_amt_usd) AS avg_order_value
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    JOIN sales_reps s
        ON a.sales_rep_id = s.id
    GROUP BY a.id, s.region_id
)
SELECT r.name AS region, AVG(account_avg.avg_order_value) AS avg_order_value
FROM account_avg
JOIN region r
    ON account_avg.region_id = r.id
GROUP BY r.name
ORDER BY avg_order_value DESC
LIMIT 1;

-- C3 (same result as 5.1, materialized as a temp table instead of chained CTEs)
CREATE TEMPORARY TABLE top_rep_c3
SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
GROUP BY s.id, s.name
ORDER BY total_sales DESC
LIMIT 1;

SELECT top_rep_c3.name, COUNT(DISTINCT a.id) AS num_accounts, COUNT(o.id) AS num_orders
FROM top_rep_c3
JOIN accounts a
    ON a.sales_rep_id = top_rep_c3.id
JOIN orders o
    ON o.account_id = a.id
GROUP BY top_rep_c3.name;

-- C4
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
