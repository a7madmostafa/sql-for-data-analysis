-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Parch & Posey Database
-- ============================================================
-- Answer key for day03_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- 1.1
SELECT *
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- 1.2
SELECT orders.id, accounts.name, orders.occurred_at
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- 1.3
SELECT a.website, a.primary_poc,
       o.standard_qty, o.gloss_qty, o.poster_qty
FROM orders o
JOIN accounts a
    ON o.account_id = a.id;


-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- 2.1
SELECT o.id, a.name AS account_name, s.name AS sales_rep_name
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id;

-- 2.2
SELECT r.name AS region, a.name AS account,
       o.total_amt_usd / (o.total + 0.01) AS unit_price
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id;

-- 2.3
SELECT a.name AS account_name, o.occurred_at AS order_date
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
ORDER BY order_date
LIMIT 1;


-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- 3.1
SELECT a.name AS account_name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_sales DESC;

-- 3.2
SELECT s.name, w.channel, COUNT(*) AS occurrences
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY occurrences DESC;

-- 3.3
SELECT a.name, MIN(o.total_amt_usd) AS smallest_order
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;


-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- 4.1
SELECT s.id, s.name, COUNT(*) AS num_accounts
FROM accounts a
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

-- 4.2
SELECT a.id, a.name, COUNT(*) AS num_orders
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- 4.3
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spent
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;


-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- 5.1
SELECT *
FROM accounts
LEFT JOIN orders
    ON orders.account_id = accounts.id;

-- 5.2
SELECT *
FROM orders
RIGHT JOIN accounts
    ON orders.account_id = accounts.id;


-- ======================================
-- SECTION 6 — ANTI-JOINS
-- ======================================

-- 6.1
SELECT *
FROM accounts a
LEFT JOIN orders o
    ON a.id = o.account_id
WHERE o.id IS NULL;


-- ======================================
-- SECTION 7 — FULL JOIN (via UNION)
-- ======================================

-- 7.1
SELECT *
FROM orders
LEFT JOIN accounts
    ON orders.account_id = accounts.id

UNION

SELECT *
FROM orders
RIGHT JOIN accounts
    ON orders.account_id = accounts.id;


-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- 8.1
SELECT account_id, total_amt_usd,
    CASE
        WHEN total_amt_usd >= 3000 THEN 'Large'
        ELSE 'Small'
    END AS order_tag
FROM orders;

-- 8.2
SELECT account_id,
    CASE
        WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
        ELSE standard_amt_usd / standard_qty
    END AS unit_price
FROM orders;


-- ======================================
-- SECTION 9 — CASE + GROUP BY
-- ======================================

-- 9.1
SELECT
    CASE
        WHEN total >= 2000 THEN 'At Least 2000'
        WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000'
    END AS order_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- 9.2
SELECT a.name, SUM(o.total_amt_usd) AS total_spent,
    CASE
        WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low'
    END AS customer_level
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_spent DESC;

-- 9.3
SELECT a.name, SUM(o.total_amt_usd) AS total_spent,
    CASE
        WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low'
    END AS customer_level
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
WHERE o.occurred_at > '2015-12-31'
GROUP BY a.name
ORDER BY total_spent DESC;

-- 9.4
SELECT s.name, COUNT(*) AS num_orders,
    CASE
        WHEN COUNT(*) > 200 THEN 'top'
        ELSE 'not'
    END AS sales_rep_level
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY num_orders DESC;


-- ======================================
-- SECTION 10 — CASE + HAVING
-- ======================================

-- 10.1
SELECT s.name, SUM(o.total_amt_usd) AS total_sales,
    CASE
        WHEN SUM(o.total_amt_usd) = 0 THEN 'ZERO'
        WHEN SUM(o.total_amt_usd) BETWEEN 1 AND 5000 THEN 'Under 5k'
        WHEN SUM(o.total_amt_usd) BETWEEN 5001 AND 10000 THEN '5-10k'
        WHEN SUM(o.total_amt_usd) BETWEEN 10001 AND 20000 THEN '10-20k'
        ELSE '+20k'
    END AS sales_category
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY a.id, a.sales_rep_id, s.name
HAVING SUM(o.total_amt_usd) BETWEEN 1 AND 5000;


-- ======================================
-- SECTION 11 — TRIMMING WHITESPACE
-- ======================================

-- 11.1
SELECT id, TRIM(name) AS trimmed_name
FROM sales_reps;


-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 12.1
SELECT name, LEFT(name, 3) AS account_code
FROM accounts;

-- 12.2
SELECT website, RIGHT(website, 3) AS domain_suffix
FROM accounts;

-- 12.3
SELECT website, LOCATE('.', website) AS dot_position
FROM accounts;


-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 13.1
SELECT name,
    CONCAT(
        LOWER(LEFT(name, LOCATE(' ', name) - 1)), '.',
        LOWER(RIGHT(name, LENGTH(name) - LOCATE(' ', name)))
    ) AS username
FROM sales_reps;

-- 13.2
SELECT name, LENGTH(name) AS name_length, UPPER(name) AS upper_name
FROM accounts
ORDER BY name_length DESC;


-- ======================================
-- SECTION 14 — COALESCE / IFNULL
-- ======================================

-- 14.1
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
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT a.name AS account, SUM(o.total_amt_usd) AS total_revenue,
    CASE
        WHEN SUM(o.total_amt_usd) > 200000 THEN 'top'
        WHEN SUM(o.total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low'
    END AS tier,
    s.name AS sales_rep, r.name AS region
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
GROUP BY a.name, s.name, r.name
ORDER BY total_revenue DESC
LIMIT 5;

-- C2
SELECT r.name AS region, SUM(o.total_amt_usd) AS total_revenue
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id
GROUP BY r.name
ORDER BY total_revenue DESC
LIMIT 1;

-- C3
SELECT s.name, COUNT(DISTINCT a.id) AS num_accounts, COUNT(o.id) AS num_orders
FROM sales_reps s
JOIN accounts a
    ON s.id = a.sales_rep_id
JOIN orders o
    ON a.id = o.account_id
GROUP BY s.name
HAVING COUNT(DISTINCT a.id) > 5
AND COUNT(o.id) > 200;

-- C4
SELECT a.name,
    CONCAT(
        LOWER(LEFT(a.primary_poc, LOCATE(' ', a.primary_poc) - 1)), '.',
        LOWER(RIGHT(a.primary_poc, LENGTH(a.primary_poc) - LOCATE(' ', a.primary_poc))), '@',
        LOWER(REPLACE(a.name, ' ', '')), '.com'
    ) AS email
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name, a.primary_poc
HAVING SUM(o.total_amt_usd) > 200000;
