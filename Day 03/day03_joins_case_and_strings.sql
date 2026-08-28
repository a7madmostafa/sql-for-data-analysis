USE parch_and_posey;

-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- Finance wants order and account details together in one view — combine every order with the account that placed it
SELECT *
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- They only need a few fields, not everything — pick specific columns from each side
SELECT orders.id, accounts.name, orders.occurred_at
FROM orders
JOIN accounts
    ON orders.account_id = accounts.id;

-- Same request, written with table aliases (AS is optional) since real reports reference these tables constantly
SELECT a.website, a.primary_poc AS point_of_contact,
       o.standard_qty, o.gloss_qty, o.poster_qty
FROM orders AS o
JOIN accounts AS a
    ON o.account_id = a.id;

-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- Leadership wants to trace every order all the way back to the sales rep who owns that account
SELECT *
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
JOIN sales_reps s
    ON a.sales_rep_id = s.id;

-- Regional management wants a per-order unit price, broken out by region — chain all four tables together
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

-- Which account placed the very first order Parch & Posey ever received? (name + date)
SELECT a.name AS account_name, o.occurred_at AS order_date
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
ORDER BY order_date
LIMIT 1;

-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- Which accounts have generated the most total revenue, biggest spender first?
SELECT a.name AS account_name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name
ORDER BY total_sales DESC;

-- For each sales rep, how many times was each marketing channel used by their accounts?
SELECT s.name, w.channel, COUNT(*) AS occurrences
FROM web_events w
JOIN accounts a
    ON w.account_id = a.id
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY occurrences DESC;

-- What's the smallest order each account has ever placed — a per-account "floor" for order size?
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

-- Which sales reps manage more than 5 accounts — are any of them overloaded?
SELECT s.id, s.name, COUNT(*) AS num_accounts
FROM accounts a
JOIN sales_reps s
    ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

-- Which accounts have placed more than 20 orders — the company's most active repeat customers?
SELECT a.id, a.name, COUNT(*) AS num_orders
FROM accounts a
JOIN orders o
    ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- Which accounts have spent less than $1,000 total across all orders — candidates for a re-engagement campaign?
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

-- Which accounts exist, whether or not they've ever placed an order? (unmatched order columns come back NULL)
SELECT *
FROM accounts
LEFT JOIN orders
    ON orders.account_id = accounts.id;

-- Same idea, mirrored: which orders exist, even if their account record can no longer be resolved?
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

-- Which accounts have NEVER placed a single order — a churn/onboarding red-flag list for the sales team?
SELECT *
FROM accounts a
LEFT JOIN orders o
    ON a.id = o.account_id
WHERE o.id IS NULL;

-- ======================================
-- SECTION 7 — FULL JOIN (MySQL has no FULL JOIN keyword — emulate with UNION)
-- ======================================

-- Compliance wants a single report covering every order-account relationship: matched, order-only, and account-only rows
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

-- Flag every order as "Large" or "Small" so a dashboard can color-code them at a glance
SELECT id, account_id, total_amt_usd,
    CASE
        WHEN total_amt_usd > 2000 THEN 'Large'
        ELSE 'Small'
    END AS order_level
FROM orders;

-- Compute a safe per-unit price for standard paper, without crashing on the handful of zero-quantity orders
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

-- For a reporting dashboard, bucket every order into a size category, then count how many fall in each
SELECT
    CASE
        WHEN total >= 2000 THEN 'At Least 2000'
        WHEN total BETWEEN 1000 AND 2000 THEN 'Between 1000 and 2000'
        ELSE 'Less than 1000'
    END AS order_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- Which accounts are top / middle / low lifetime-value customers, based on total spend?
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

-- Same tiering question, but restricted to spend from 2016 onward only — has anyone's tier shifted recently?
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

-- Which sales reps count as "top performers" — more than 200 orders handled?
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

-- Which sales reps fall specifically in the "under $5k total sales" category — reps who may need extra support?
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

-- A CSV export from a legacy CRM padded every point-of-contact name with stray
-- spaces — clean it up before the data gets loaded anywhere else
SELECT LTRIM('     Alexander Freberg') AS left_trim;
SELECT RTRIM('Alexander Freberg          ') AS right_trim;
SELECT TRIM('     Alexander Freberg          ') AS trim_both;

-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- Marketing wants a 4-letter account-code abbreviation for a print report,
-- and a data-quality check that every account's website follows the
-- expected "www.company.com" pattern (i.e. starts with "www")
SELECT name, LEFT(name, 4) AS account_code
FROM accounts
LIMIT 5;

SELECT website, SUBSTRING(website, 1, LOCATE('.', website) - 1) AS website_prefix
FROM accounts
LIMIT 5;

-- LOCATE finds the position of a substring (1-indexed) — here, the first space
-- inside a point-of-contact's full name, which is what SECTION 13 uses to split
-- "Sherrie Ballenger" into first/last name
SELECT primary_poc, LOCATE(' ', primary_poc) AS space_position
FROM accounts
LIMIT 5;

-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- Sales wants a company email address auto-generated for every point of
-- contact: firstname.lastname@accountname.com, all lowercase, no spaces
WITH name_split AS (
    SELECT
        REPLACE(name, ' ', '') AS clean_account_name,
        LEFT(primary_poc, LOCATE(' ', primary_poc) - 1) AS first_name,
        RIGHT(primary_poc, LENGTH(primary_poc) - LOCATE(' ', primary_poc)) AS last_name
    FROM accounts
)
SELECT first_name, last_name,
       CONCAT(LOWER(first_name), '.', LOWER(last_name), '@', LOWER(clean_account_name), '.com') AS email
FROM name_split;

-- Quick contrast: LOWER/UPPER/LENGTH applied directly to a column
SELECT name, LOWER(name) AS lower_name, UPPER(name) AS upper_name, LENGTH(name) AS name_length
FROM sales_reps
LIMIT 5;

-- ======================================
-- SECTION 14 — COALESCE / IFNULL (filling in NULLs)
-- ======================================

-- Bucket every order by item count, but the buckets only cover 0-100 and
-- 101-200 — anything larger falls through as NULL and needs a "200+" label
WITH total_range AS (
    SELECT
        CASE
            WHEN total BETWEEN 0 AND 100 THEN '0-100'
            WHEN total BETWEEN 101 AND 200 THEN '101-200'
        END AS total_range
    FROM orders
)
SELECT IFNULL(total_range, '200+') AS total_range
FROM total_range;
