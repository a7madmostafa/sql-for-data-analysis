USE parch_and_posey;

-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES (a subquery that returns one value)
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
-- SECTION 2 — ROW SUBQUERIES (matching a tuple of values)
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
-- SECTION 3 — DERIVED TABLES (a subquery standing in for a table, in FROM)
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
-- SECTION 4 — CTEs (WITH ... AS)
-- ======================================

-- Same question as Section 3, rewritten with a CTE — the derived table gets a
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
-- SECTION 5 — CHAINED CTEs (one CTE referencing another)
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
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- Same top-customer question as Section 4, but materialized as a real table —
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
-- SECTION 7 — VIEWS
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
