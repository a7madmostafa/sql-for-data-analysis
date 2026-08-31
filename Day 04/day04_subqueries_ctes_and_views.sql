USE rawaj;

-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES (a subquery that returns one value)
-- ======================================

-- Leadership wants total sales for the single most recent day orders were placed
SELECT MAX(DATE(order_date)) AS last_day
FROM orders;

-- hardcoding that date works once, but breaks the moment new orders come in
SELECT SUM(total_amount) AS total_sales
FROM orders
WHERE DATE(order_date) = '2025-05-31';

-- a scalar subquery keeps it correct automatically, no matter when this runs
SELECT SUM(total_amount) AS total_sales
FROM orders
WHERE DATE(order_date) = (SELECT MAX(DATE(order_date)) FROM orders);

-- Finance wants every order that sold for more than the company-wide average
SELECT AVG(total_amount) AS avg_order
FROM orders;

SELECT *
FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- ======================================
-- SECTION 2 — ROW SUBQUERIES (matching a tuple of values)
-- ======================================

-- Customer support wants every customer who has left at least one 1-star
-- review — the everyday, single-column form: WHERE column IN (subquery)
SELECT customer_id, first_name, last_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM reviews WHERE rating = 1);

-- Now a case one column can't handle. The web team wants each customer's
-- single most recent web event — comparing
-- (customer_id, occurred_at) as a pair is what makes this "most recent PER customer"
SELECT customer_id, occurred_at, channel
FROM web_events
WHERE (customer_id, occurred_at) IN (
    SELECT customer_id, MAX(occurred_at)
    FROM web_events
    GROUP BY customer_id
)
ORDER BY customer_id;

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

-- Who is Rawaj's single highest lifetime-spend customer?
WITH top_customer AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT * FROM top_customer;

-- A CTE can be joined like any other table — for that same top customer,
-- how many web events came through each channel?
WITH top_customer AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.first_name, c.last_name, w.channel, COUNT(*) AS num_events
FROM customers c
JOIN web_events w
    ON c.customer_id = w.customer_id
JOIN top_customer
    ON c.customer_id = top_customer.customer_id
GROUP BY c.first_name, c.last_name, w.channel
ORDER BY num_events DESC;

-- ======================================
-- SECTION 5 — CHAINED CTEs (one CTE referencing another)
-- ======================================

-- A second CTE can reference the first one directly — which customers spend
-- more than the company-wide average customer spend? (530 of 1,196 customers
-- with orders — a minority, since spend is right-skewed by a handful of big
-- spenders pulling the average up)
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spend
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
),
avg_total AS (
    SELECT AVG(total_spend) AS avg_total_spend
    FROM customer_totals
)
SELECT *
FROM customer_totals
WHERE total_spend > (SELECT avg_total_spend FROM avg_total);

-- ======================================
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- Same top-customer question as Section 4, but materialized as a real table —
-- useful when several separate queries need to reuse the same intermediate result
DROP TEMPORARY TABLE IF EXISTS top_customer;

CREATE TEMPORARY TABLE top_customer
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales DESC
LIMIT 1;

SELECT * FROM top_customer;

SELECT c.first_name, c.last_name, w.channel, COUNT(*) AS num_events
FROM customers c
JOIN web_events w
    ON c.customer_id = w.customer_id
JOIN top_customer
    ON c.customer_id = top_customer.customer_id
GROUP BY c.first_name, c.last_name, w.channel
ORDER BY num_events DESC;

-- DROP TEMPORARY TABLE top_customer;  -- optional: temp tables auto-drop when the session ends

-- ======================================
-- SECTION 7 — VIEWS
-- ======================================

-- Sales asks for a "top 10 customers" leaderboard they can query repeatedly,
-- from any session, without re-writing the ranking logic every time.
-- CREATE OR REPLACE VIEW makes this safe to re-run — plain CREATE VIEW errors
-- with "table already exists" the second time
CREATE OR REPLACE VIEW top10_customers AS
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales DESC
LIMIT 10;

SELECT * FROM top10_customers;

-- the view behaves exactly like a table in any query — join straight to it
SELECT w.channel, COUNT(*) AS num_events
FROM web_events w
JOIN top10_customers t
    ON w.customer_id = t.customer_id
GROUP BY w.channel
ORDER BY num_events DESC;

-- DROP VIEW top10_customers;  -- optional cleanup, if you're just practicing
