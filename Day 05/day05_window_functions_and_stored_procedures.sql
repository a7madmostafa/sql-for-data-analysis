USE parch_and_posey;

-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: OVER, AND A RUNNING TOTAL
-- ======================================

-- Finance wants to see paper-order volume build up over time — a running
-- total of standard_qty, ordered chronologically
SELECT occurred_at, standard_qty,
       SUM(standard_qty) OVER (ORDER BY occurred_at) AS running_total
FROM orders
ORDER BY occurred_at
LIMIT 10;

-- ======================================
-- SECTION 2 — PARTITION BY (resetting the window per group)
-- ======================================

-- Now do the same running total, but per account — not one company-wide
-- total that mixes every customer together
SELECT account_id, occurred_at, total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY occurred_at) AS account_running_total
FROM orders
ORDER BY account_id, occurred_at;

-- ======================================
-- SECTION 3 — RANK, DENSE_RANK, ROW_NUMBER
-- ======================================

-- Leadership wants sales reps ranked by total sales, and wants to know
-- exactly how ties get handled. The CTE here is the same pattern from
-- Day 04's Section 4 — window functions build on top of it.
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
-- SECTION 4 — RANKING WITHIN A PARTITION, THEN FILTERING TO ONE PER GROUP
-- ======================================

-- For every account, what was their single largest order? (Same shape as
-- Day 04's Section 1/4 subquery/CTE question — a window function reaches
-- the same answer more directly)
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
-- SECTION 5 — LAG / LEAD (comparing a row to a neighbor)
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
-- SECTION 6 — STORED PROCEDURES (IN parameters)
-- ======================================

-- Sales reps constantly ask for the same report — order count and total
-- revenue for one account. Save it once as a procedure everyone can call.
--
-- DELIMITER is required here: running this file as a script (the mysql CLI,
-- `source`, or Workbench's "execute script") splits statements on every
-- plain semicolon — without switching the delimiter first, it would try to
-- run "BEGIN ... SELECT ...;" as a complete statement and choke on the very
-- first semicolon inside the procedure body. (This becomes unnecessary in
-- Day 06, once you're sending SQL through a Python driver instead — a
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
-- SECTION 7 — STORED PROCEDURES (OUT parameters)
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
