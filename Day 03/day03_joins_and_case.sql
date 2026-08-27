USE parch_and_posey;

-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- Combine every order with the account that placed it (every column from both tables)
SELECT *
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- Pick specific columns from each side
SELECT orders.id, accounts.name, orders.occurred_at
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- Table aliases (AS is optional) — shortens repeated table references
SELECT a.website, a.primary_poc AS point_of_contact,
       o.standard_qty, o.gloss_qty, o.poster_qty
FROM orders AS o
JOIN accounts AS a
    ON o.account_id = a.id;

-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- Three tables: orders -> accounts -> sales_reps
SELECT *
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id;

-- Four tables: region -> sales_reps -> accounts -> orders, computing a unit price per order
-- (+ 0.01 on the denominator avoids a divide-by-zero on the handful of orders with total = 0)
SELECT r.name AS region, a.name AS account,
       o.total_amt_usd / (o.total + 0.01) AS unit_price
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id
JOIN region r
    ON s.region_id = r.id;

-- Which account placed the earliest order? (name + date)
SELECT a.name AS account_name, o.occurred_at AS order_date
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
ORDER BY order_date
LIMIT 1;

-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- Total sales in USD per account, biggest spender first
SELECT a.name AS account_name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_sales DESC;

-- How many times each channel was used, per sales rep
SELECT s.name, w.channel, COUNT(*) AS occurrences
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY occurrences DESC;

-- The smallest order placed by each account, smallest first
SELECT a.name, MIN(o.total_amt_usd) AS smallest_order
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- HAVING filters on the GROUPED result — WHERE can't do this, since COUNT/SUM don't
-- exist yet at the point WHERE is evaluated.

-- Sales reps who manage more than 5 accounts
SELECT s.id, s.name, COUNT(*) AS num_accounts
FROM accounts a
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

-- Accounts with more than 20 orders
SELECT a.id, a.name, COUNT(*) AS num_orders
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- Accounts that have spent less than $1,000 total across all orders
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

-- Every account, whether or not it has any orders (unmatched order columns come back NULL)
SELECT *
FROM accounts
LEFT JOIN orders
    ON orders.account_id = accounts.id;

-- Same idea, other direction: every order, whether or not its account still resolves
SELECT *
FROM orders
RIGHT JOIN accounts
    ON orders.account_id = accounts.id;

-- LEFT OUTER JOIN / RIGHT OUTER JOIN — OUTER is optional noise, means exactly the same as LEFT/RIGHT JOIN
SELECT *
FROM accounts
LEFT OUTER JOIN orders
    ON orders.account_id = accounts.id;

-- ======================================
-- SECTION 6 — ANTI-JOINS (finding non-matches)
-- ======================================

-- Accounts with NO orders at all — a LEFT JOIN where the right side never matched
SELECT *
FROM accounts a
LEFT JOIN orders o
    ON a.id = o.account_id
WHERE o.id IS NULL;

-- ======================================
-- SECTION 7 — FULL JOIN (MySQL has no FULL JOIN keyword — emulate with UNION)
-- ======================================

-- UNION of a LEFT JOIN and a RIGHT JOIN covers everything: matches, left-only, and right-only rows
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

-- Label each order Large or Small based on total_amt_usd
SELECT id, account_id, total_amt_usd,
    CASE
        WHEN total_amt_usd > 2000 THEN 'Large'
        ELSE 'Small'
    END AS order_level
FROM orders;

-- CASE can guard against bad math too — unit price, but 0 instead of dividing by zero
SELECT account_id,
    CASE
        WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
        ELSE standard_amt_usd / standard_qty
    END AS unit_price
FROM orders
LIMIT 10;

-- ======================================
-- SECTION 9 — CASE + GROUP BY (binning / tiering)
-- ======================================

-- Bucket every order into one of three size categories, then count how many fall in each
SELECT
    CASE
        WHEN total >= 2000 THEN 'At Least 2000'
        WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000'
    END AS order_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- Customer lifetime value tiers: top / middle / low, based on total spend per account
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

-- Same tiering, restricted to 2016+ spend only
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

-- Flag top-performing sales reps: more than 200 orders handled
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

-- HAVING can filter on a CASE-derived column, same as any other aggregate expression
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
