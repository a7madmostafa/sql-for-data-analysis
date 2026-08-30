-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Rawaj Database
-- ============================================================
-- Answer key for day05_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 1.1
SELECT order_date, discount_amount,
       SUM(discount_amount) OVER (ORDER BY order_date) AS running_total
FROM orders
ORDER BY order_date
LIMIT 10;

-- 1.2
SELECT customer_id, order_date, subtotal,
       SUM(subtotal) OVER (PARTITION BY customer_id ORDER BY order_date) AS customer_running_total
FROM orders
ORDER BY customer_id, order_date
LIMIT 20;


-- ======================================
-- SECTION 2 — RANKING
-- ======================================

-- 2.1
WITH customer_totals AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spend
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT first_name, last_name, total_spend,
       RANK()       OVER (ORDER BY total_spend DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY total_spend DESC) AS dense_rank_no_gaps,
       ROW_NUMBER() OVER (ORDER BY total_spend DESC) AS row_num
FROM customer_totals
ORDER BY total_spend DESC
LIMIT 10;

-- 2.2
WITH customer_totals AS (
    SELECT am.manager_name, c.customer_id, c.first_name, c.last_name,
           SUM(o.total_amount) AS total_spend
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN governorates g ON c.governorate_id = g.governorate_id
    JOIN account_managers am ON g.manager_id = am.manager_id
    GROUP BY am.manager_name, c.customer_id, c.first_name, c.last_name
),
ranked AS (
    SELECT manager_name, first_name, last_name, total_spend,
           ROW_NUMBER() OVER (PARTITION BY manager_name ORDER BY total_spend DESC) AS cust_rank
    FROM customer_totals
)
SELECT manager_name, first_name, last_name, total_spend
FROM ranked
WHERE cust_rank = 1
ORDER BY manager_name;


-- ======================================
-- SECTION 3 — LAG / LEAD
-- ======================================

-- 3.1
WITH monthly_events AS (
    SELECT DATE_FORMAT(occurred_at, '%Y-%m') AS month, COUNT(*) AS num_events
    FROM web_events
    GROUP BY month
)
SELECT month, num_events,
       LAG(num_events) OVER (ORDER BY month) AS prev_month_events,
       num_events - LAG(num_events) OVER (ORDER BY month) AS change_from_prev_month
FROM monthly_events
ORDER BY month;


-- ======================================
-- SECTION 4 — STORED PROCEDURES
-- ======================================

-- 4.1
DROP PROCEDURE IF EXISTS governorate_sales_report;

DELIMITER $$

CREATE PROCEDURE governorate_sales_report(IN gov_id INT)
BEGIN
    SELECT g.governorate_name,
           COUNT(o.order_id) AS num_orders,
           SUM(o.total_amount) AS total_revenue
    FROM governorates g
    JOIN customers c ON c.governorate_id = g.governorate_id
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE g.governorate_id = gov_id
    GROUP BY g.governorate_name;
END$$

DELIMITER ;

CALL governorate_sales_report(1);

-- 4.2
DROP PROCEDURE IF EXISTS get_customer_count;

DELIMITER $$

CREATE PROCEDURE get_customer_count(OUT cnt INT)
BEGIN
    SELECT COUNT(*) INTO cnt FROM customers;
END$$

DELIMITER ;

CALL get_customer_count(@n);
SELECT @n AS customer_count;


-- ======================================
-- CHALLENGE QUESTION
-- ======================================

-- C1
WITH manager_totals AS (
    SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN governorates g ON c.governorate_id = g.governorate_id
    JOIN account_managers am ON g.manager_id = am.manager_id
    GROUP BY am.manager_id, am.manager_name
)
SELECT manager_name, total_sales,
       NTILE(4) OVER (ORDER BY total_sales DESC) AS sales_tier
FROM manager_totals
ORDER BY total_sales DESC;
