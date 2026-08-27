USE parch_and_posey;

-- ======================================
-- SECTION 1 — TRIMMING WHITESPACE
-- ======================================

-- A CSV export from a legacy CRM padded every point-of-contact name with stray
-- spaces — clean it up before the data gets loaded anywhere else
SELECT LTRIM('     Alexander Freberg') AS left_trim;
SELECT RTRIM('Alexander Freberg          ') AS right_trim;
SELECT TRIM('     Alexander Freberg          ') AS trim_both;

-- ======================================
-- SECTION 2 — EXTRACTING PARTS OF A STRING
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
-- inside a point-of-contact's full name, which is what SECTION 3 uses to split
-- "Sherrie Ballenger" into first/last name
SELECT primary_poc, LOCATE(' ', primary_poc) AS space_position
FROM accounts
LIMIT 5;

-- ======================================
-- SECTION 3 — BUILDING AND CLEANING STRINGS
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
-- SECTION 4 — COALESCE / IFNULL (filling in NULLs)
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

-- ======================================
-- SECTION 5 — SCALAR SUBQUERIES (a subquery that returns one value)
-- ======================================

-- Leadership wants total sales for the single most recent day orders were placed
SELECT MAX(DATE(occurred_at)) AS last_day
FROM orders;

-- hardcoding that date works once, but breaks the moment new orders come in
SELECT SUM(total_amt_usd) AS total_sales
FROM orders
WHERE DATE(occurred_at) = '2017-01-02';

-- a scalar subquery keeps it correct automatically, no matter when this runs
SELECT SUM(total_amt_usd) AS total_sales
FROM orders
WHERE DATE(occurred_at) = (SELECT MAX(DATE(occurred_at)) FROM orders);

-- Finance wants every order that sold for more than the company-wide average
SELECT AVG(total_amt_usd) AS avg_order
FROM orders;

SELECT *
FROM orders
WHERE total_amt_usd > (SELECT AVG(total_amt_usd) FROM orders);

-- ======================================
-- SECTION 6 — ROW SUBQUERIES (matching a tuple of values)
-- ======================================

-- The web team wants each account's single most recent web event — comparing
-- (account_id, occurred_at) as a pair is what makes this "most recent PER account"
SELECT account_id, occurred_at, channel
FROM web_events
WHERE (account_id, occurred_at) IN (
    SELECT account_id, MAX(occurred_at)
    FROM web_events
    GROUP BY account_id
)
ORDER BY account_id;

-- ======================================
-- SECTION 7 — DERIVED TABLES (a subquery standing in for a table, in FROM)
-- ======================================

-- Marketing wants the average number of daily events per channel, across the
-- whole dataset — that needs two passes of aggregation, so one becomes a
-- derived table the outer query then aggregates again
SELECT channel, DATE(occurred_at) AS day, COUNT(*) AS events
FROM web_events
GROUP BY day, channel;

SELECT channel, AVG(events) AS avg_events_per_day
FROM (
    SELECT channel, DATE(occurred_at) AS day, COUNT(*) AS events
    FROM web_events
    GROUP BY day, channel
) AS daily_channel_events
GROUP BY channel;

-- ======================================
-- SECTION 8 — CTEs (WITH ... AS)
-- ======================================

-- Same question as Section 7, rewritten with a CTE — the derived table gets a
-- name up front instead of being buried inside FROM
WITH daily_channel_events AS (
    SELECT DATE(occurred_at) AS day, channel, COUNT(*) AS events
    FROM web_events
    GROUP BY day, channel
)
SELECT channel, AVG(events) AS avg_events_per_day
FROM daily_channel_events
GROUP BY channel;

-- Who is Parch & Posey's single highest lifetime-spend customer?
WITH top_customer AS (
    SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    GROUP BY a.id, a.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT * FROM top_customer;

-- ======================================
-- SECTION 9 — CHAINED CTEs (one CTE referencing another)
-- ======================================

-- For that same top customer, how many web events came through each channel?
WITH top_customer AS (
    SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    GROUP BY a.id, a.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT a.name, w.channel, COUNT(*) AS num_events
FROM accounts a
JOIN web_events w
    ON a.id = w.account_id
JOIN top_customer
    ON a.id = top_customer.id
GROUP BY a.name, w.channel
ORDER BY num_events DESC;

-- A second CTE can reference the first one directly — is any account's total
-- spend above the company-wide average account spend?
WITH account_totals AS (
    SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_spend
    FROM orders o
    JOIN accounts a
        ON o.account_id = a.id
    GROUP BY a.id, a.name
),
avg_total AS (
    SELECT AVG(total_spend) AS avg_total_spend
    FROM account_totals
)
SELECT *
FROM account_totals
WHERE total_spend > (SELECT avg_total_spend FROM avg_total);

-- ======================================
-- SECTION 10 — TEMPORARY TABLES
-- ======================================

-- Same top-customer question as Section 8, but materialized as a real table —
-- useful when several separate queries need to reuse the same intermediate result
CREATE TEMPORARY TABLE top_customer
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_sales DESC
LIMIT 1;

SELECT * FROM top_customer;

SELECT a.name, w.channel, COUNT(*) AS num_events
FROM accounts a
JOIN web_events w
    ON a.id = w.account_id
JOIN top_customer
    ON a.id = top_customer.id
GROUP BY a.name, w.channel
ORDER BY num_events DESC;

-- DROP TEMPORARY TABLE top_customer;  -- optional: temp tables auto-drop when the session ends

-- ======================================
-- SECTION 11 — VIEWS
-- ======================================

-- Sales asks for a "top 10 customers" leaderboard they can query repeatedly,
-- from any session, without re-writing the ranking logic every time
CREATE VIEW top10_customers AS
SELECT a.id, a.name, SUM(o.total_amt_usd) AS total_sales
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.id, a.name
ORDER BY total_sales DESC
LIMIT 10;

SELECT * FROM top10_customers;

-- the view behaves exactly like a table in any query — join straight to it
SELECT w.channel, COUNT(*) AS num_events
FROM web_events w
JOIN top10_customers t
    ON w.account_id = t.id
GROUP BY w.channel
ORDER BY num_events DESC;

-- DROP VIEW top10_customers;  -- optional cleanup, if you're just practicing
