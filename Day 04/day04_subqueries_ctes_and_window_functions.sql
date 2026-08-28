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

-- ======================================
-- SECTION 8 — WINDOW FUNCTIONS: OVER, AND A RUNNING TOTAL
-- ======================================

-- Finance wants to see paper-order volume build up over time — a running
-- total of standard_qty, ordered chronologically
SELECT occurred_at, standard_qty,
       SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- ======================================
-- SECTION 9 — PARTITION BY (resetting the window per group)
-- ======================================

-- Now do the same running total, but per account — not one company-wide
-- total that mixes every customer together
SELECT account_id, occurred_at, total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY occurred_at) AS account_running_total
FROM orders
ORDER BY account_id, occurred_at;

-- ======================================
-- SECTION 10 — RANK, DENSE_RANK, ROW_NUMBER
-- ======================================

-- Leadership wants sales reps ranked by total sales, and wants to know
-- exactly how ties get handled
WITH rep_totals AS (
    SELECT s.id, s.name, SUM(o.total_amt_usd) AS total_sales
    FROM orders o
    JOIN accounts a ON o.account_id = a.id
    JOIN sales_reps s ON a.sales_rep_id = s.id
    GROUP BY s.id, s.name
)
SELECT name, total_sales,
       RANK()       OVER (ORDER BY total_sales DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_rank_no_gaps,
       ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num
FROM rep_totals
ORDER BY total_sales DESC;

-- ======================================
-- SECTION 11 — RANKING WITHIN A PARTITION, THEN FILTERING TO ONE PER GROUP
-- ======================================

-- For every account, what was their single largest order? (Same shape as a
-- Section 1/4 subquery/CTE question — a window function reaches the same
-- answer more directly)
WITH ranked_orders AS (
    SELECT account_id, id AS order_id, total_amt_usd,
           RANK() OVER (PARTITION BY account_id ORDER BY total_amt_usd DESC) AS order_rank
    FROM orders
)
SELECT account_id, order_id, total_amt_usd
FROM ranked_orders
WHERE order_rank = 1
ORDER BY account_id;

-- ======================================
-- SECTION 12 — LAG / LEAD (comparing a row to a neighbor)
-- ======================================

-- Is month-over-month revenue growing or shrinking?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(occurred_at, '%Y-%m') AS month, SUM(total_amt_usd) AS total_sales
    FROM orders
    GROUP BY month
)
SELECT month, total_sales,
       LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY month) AS change_from_prev_month
FROM monthly_sales
ORDER BY month;

-- ======================================
-- SECTION 13 — STORED PROCEDURES (IN parameters)
-- ======================================

-- Sales reps constantly ask for the same report — order count and total
-- revenue for one account. Save it once as a procedure everyone can call.
--
-- DELIMITER is required here: running this file as a script (the mysql CLI,
-- `source`, or Workbench's "execute script") splits statements on every
-- plain semicolon — without switching the delimiter first, it would try to
-- run "BEGIN ... SELECT ...;" as a complete statement and choke on the very
-- first semicolon inside the procedure body. (This becomes unnecessary in
-- Day 05, once you're sending SQL through a Python driver instead — a
-- Python driver sends the whole block as one request, no client-side
-- statement-splitting involved.)
DROP PROCEDURE IF EXISTS account_sales_report;

DELIMITER $$

CREATE PROCEDURE account_sales_report(IN acct_id INT)
BEGIN
    SELECT a.name AS account_name,
           COUNT(o.id) AS num_orders,
           SUM(o.total_amt_usd) AS total_sales
    FROM accounts a
    JOIN orders o ON o.account_id = a.id
    WHERE a.id = acct_id
    GROUP BY a.name;
END$$

DELIMITER ;

CALL account_sales_report(1001);

-- ======================================
-- SECTION 14 — STORED PROCEDURES (OUT parameters)
-- ======================================

-- A nightly batch job needs just the single number — total company-wide
-- revenue — captured into a variable it can act on, not a result set
DROP PROCEDURE IF EXISTS get_total_revenue;

DELIMITER $$

CREATE PROCEDURE get_total_revenue(OUT total_revenue DECIMAL(14,2))
BEGIN
    SELECT SUM(total_amt_usd) INTO total_revenue FROM orders;
END$$

DELIMITER ;

CALL get_total_revenue(@rev);
SELECT @rev AS total_revenue;
