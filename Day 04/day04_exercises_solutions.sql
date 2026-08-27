-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Parch & Posey Database
-- ============================================================
-- Answer key for day04_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — TRIMMING WHITESPACE
-- ======================================

-- 1.1
SELECT id, TRIM(name) AS trimmed_name
FROM sales_reps;


-- ======================================
-- SECTION 2 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 2.1
SELECT name, LEFT(name, 3) AS account_code
FROM accounts;

-- 2.2
SELECT website, RIGHT(website, 3) AS domain_suffix
FROM accounts;

-- 2.3
SELECT website, LOCATE('.', website) AS dot_position
FROM accounts;


-- ======================================
-- SECTION 3 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 3.1
SELECT name,
    CONCAT(
        LOWER(LEFT(name, LOCATE(' ', name) - 1)), '.',
        LOWER(RIGHT(name, LENGTH(name) - LOCATE(' ', name)))
    ) AS username
FROM sales_reps;

-- 3.2
SELECT name, LENGTH(name) AS name_length, UPPER(name) AS upper_name
FROM accounts
ORDER BY name_length DESC;


-- ======================================
-- SECTION 4 — COALESCE / IFNULL
-- ======================================

-- 4.1
WITH spend AS (
    SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spend
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    GROUP BY a.id, a.name
),
tier AS (
    SELECT id, name, total_spend,
        CASE
            WHEN total_spend BETWEEN 0 AND 50000 THEN 'under $50k'
            WHEN total_spend BETWEEN 50001 AND 150000 THEN '$50k-150k'
        END AS spend_tier
    FROM spend
)
SELECT id, name, total_spend, IFNULL(spend_tier, 'unclassified') AS spend_tier
FROM tier;


-- ======================================
-- SECTION 5 — SCALAR SUBQUERIES
-- ======================================

-- 5.1
SELECT *
FROM orders
WHERE DATE(occurred_at) = (SELECT MIN(DATE(occurred_at)) FROM orders);

-- 5.2
SELECT id, account_id, total_amt_usd
FROM orders
WHERE total_amt_usd < (SELECT AVG(total_amt_usd) FROM orders);


-- ======================================
-- SECTION 6 — ROW SUBQUERIES
-- ======================================

-- 6.1
SELECT account_id, occurred_at, channel
FROM web_events
WHERE (account_id, occurred_at) IN (
    SELECT account_id, MIN(occurred_at)
    FROM web_events
    GROUP BY account_id
)
ORDER BY account_id;


-- ======================================
-- SECTION 7 — DERIVED TABLES
-- ======================================

-- 7.1
SELECT AVG(avg_order_value) AS avg_of_account_averages
FROM (
    SELECT account_id, AVG(total_amt_usd) AS avg_order_value
    FROM orders
    GROUP BY account_id
) AS account_averages;


-- ======================================
-- SECTION 8 — CTEs
-- ======================================

-- 8.1
WITH account_averages AS (
    SELECT account_id, AVG(total_amt_usd) AS avg_order_value
    FROM orders
    GROUP BY account_id
)
SELECT AVG(avg_order_value) AS avg_of_account_averages
FROM account_averages;

-- 8.2
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
-- SECTION 9 — CHAINED CTEs
-- ======================================

-- 9.1
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
-- SECTION 10 — TEMPORARY TABLES
-- ======================================

-- 10.1
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
-- SECTION 11 — VIEWS
-- ======================================

-- 11.1
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

-- C3 (same result as 9.1, materialized as a temp table instead of chained CTEs)
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
