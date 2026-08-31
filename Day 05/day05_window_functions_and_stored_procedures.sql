USE rawaj;

-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: OVER, AND A RUNNING TOTAL
-- ======================================

-- Finance wants to see revenue build up over time — a running total of
-- total_amount, ordered chronologically
SELECT order_date, total_amount,
       SUM(total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date
LIMIT 10;

-- ======================================
-- SECTION 2 — PARTITION BY (resetting the window per group)
-- ======================================

-- Now do the same running total, but per customer — not one company-wide
-- total that mixes every customer together
SELECT customer_id, order_date, total_amount,
       SUM(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS customer_running_total
FROM orders
ORDER BY customer_id, order_date;

-- ======================================
-- SECTION 3 — RANK, DENSE_RANK, ROW_NUMBER
-- ======================================

-- Leadership wants account managers ranked by total sales, and wants to know
-- exactly how ties get handled. The CTE here is the same pattern from
-- Day 04's Section 4 — window functions build on top of it.
WITH manager_totals AS (
    SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN governorates g ON c.governorate_id = g.governorate_id
    JOIN account_managers am ON g.manager_id = am.manager_id
    GROUP BY am.manager_id, am.manager_name
)
SELECT manager_name, total_sales,
       RANK()       OVER (ORDER BY total_sales DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_rank_no_gaps,
       ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num
FROM manager_totals
ORDER BY total_sales DESC;

-- ======================================
-- SECTION 4 — RANKING WITHIN A PARTITION, THEN FILTERING TO ONE PER GROUP
-- ======================================

-- For every customer, what was their single largest order? (Same shape as
-- Day 04's Section 1/4 subquery/CTE question — a window function reaches
-- the same answer more directly)
WITH ranked_orders AS (
    SELECT customer_id, order_id, total_amount,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC) AS order_rank
    FROM orders
)
SELECT customer_id, order_id, total_amount
FROM ranked_orders
WHERE order_rank = 1
ORDER BY customer_id;

-- ======================================
-- SECTION 5 — LAG / LEAD (comparing a row to a neighbor)
-- ======================================

-- Is month-over-month revenue growing or shrinking?
WITH monthly_sales AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS total_sales
    FROM orders
    GROUP BY month
)
SELECT month, total_sales,
       LAG(total_sales)  OVER (ORDER BY month) AS prev_month_sales,
       LEAD(total_sales) OVER (ORDER BY month) AS next_month_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY month) AS change_from_prev_month
FROM monthly_sales
ORDER BY month;

-- ======================================
-- SECTION 6 — STORED PROCEDURES (IN parameters)
-- ======================================

-- Account managers constantly ask for the same report — order count and
-- total revenue for one customer. Save it once as a procedure everyone can call.
--
-- DELIMITER is required here: running this file as a script (the mysql CLI,
-- `source`, or Workbench's "execute script") splits statements on every
-- plain semicolon — without switching the delimiter first, it would try to
-- run "BEGIN ... SELECT ...;" as a complete statement and choke on the very
-- first semicolon inside the procedure body. (This becomes unnecessary in
-- Day 06, once you're sending SQL through a Python driver instead — a
-- Python driver sends the whole block as one request, no client-side
-- statement-splitting involved.)
DROP PROCEDURE IF EXISTS customer_sales_report;

DELIMITER $$

CREATE PROCEDURE customer_sales_report(IN cust_id INT)
BEGIN
    SELECT c.first_name, c.last_name,
           COUNT(o.order_id) AS num_orders,
           SUM(o.total_amount) AS total_sales
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE c.customer_id = cust_id
    GROUP BY c.first_name, c.last_name;
END$$

DELIMITER ;

CALL customer_sales_report(1);

-- ======================================
-- SECTION 7 — STORED PROCEDURES (OUT parameters)
-- ======================================

-- A nightly batch job needs just the single number — total company-wide
-- revenue — captured into a variable it can act on, not a result set
DROP PROCEDURE IF EXISTS get_total_revenue;

DELIMITER $$

CREATE PROCEDURE get_total_revenue(OUT total_revenue DECIMAL(14,2))
BEGIN
    SELECT SUM(total_amount) INTO total_revenue FROM orders;
END$$

DELIMITER ;

CALL get_total_revenue(@rev);
SELECT @rev AS total_revenue;
