-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Rawaj Database
-- ============================================================
-- Answer key for day02_exercises.sql. Some questions have more than one valid
-- way to write them (e.g. Section 8's plain-operator vs BETWEEN pair) —
-- these are the reference solutions, not the only correct answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- 1.1
SELECT *
FROM orders
LIMIT 10;

-- 1.2
SELECT *
FROM customers
LIMIT 5 OFFSET 15;

-- 1.3
SELECT *
FROM web_events
LIMIT 20, 5;


-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- 2.1
SELECT DISTINCT governorate_id
FROM customers;

-- 2.2
SELECT DISTINCT channel
FROM web_events;

-- 2.3
SELECT COUNT(DISTINCT channel) AS channel_cnt
FROM web_events;

-- 2.4
SELECT COUNT(DISTINCT payment_method) AS payment_method_cnt
FROM orders;


-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- 3.1
SELECT *
FROM customers
ORDER BY last_name;

-- 3.2
SELECT *
FROM orders
ORDER BY total_amount DESC;

-- 3.3 (email is column position 2 in this SELECT list)
SELECT first_name, email
FROM customers
ORDER BY 2;

-- 3.4
SELECT *
FROM customers
ORDER BY governorate_id ASC, last_name ASC;

-- 3.5
SELECT customer_id, first_name, last_name
FROM customers
ORDER BY customer_id DESC
LIMIT 5;


-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- 4.1
SELECT COUNT(*) AS order_count
FROM orders;

-- 4.2
SELECT MIN(total_amount) AS min_total,
       MAX(total_amount) AS max_total
FROM orders;

-- 4.3
SELECT ROUND(AVG(total_amount), 2) AS avg_total
FROM orders;

-- 4.4
SELECT COUNT(*) AS order_count,
       SUM(shipping_fee) AS total_shipping,
       SUM(total_amount) AS total_revenue
FROM orders;


-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- 5.1
SELECT *
FROM orders
WHERE total_amount > 8000;

-- 5.2
SELECT *
FROM web_events
WHERE channel = 'organic';

-- 5.3
SELECT *
FROM customers
WHERE governorate_id = 1;

-- 5.4
SELECT COUNT(*) AS instagram_cnt
FROM web_events
WHERE channel = 'instagram';

-- 5.5
SELECT COUNT(*) AS order_count,
       AVG(total_amount) AS avg_total
FROM orders
WHERE customer_id = 1;

-- 5.6
-- Not answerable from web_events: that table only has event_id,
-- customer_id, occurred_at, and channel — no dollar-amount column. Revenue
-- figures (total_amount) live only in `orders`, and there's no shared key
-- that ties one specific web_event row to one specific order row (only the
-- shared customer_id, which would mix all of a customer's orders together
-- regardless of channel). This needs a JOIN to even approximate, and even
-- then it would be an assumption, not a fact — so the correct answer here
-- is "this table can't tell you that," not a query.

-- 5.7
SELECT MAX(total_amount) AS max_total
FROM orders
WHERE customer_id = 2;

-- 5.8
SELECT *
FROM orders
WHERE customer_id = 1
ORDER BY total_amount DESC
LIMIT 3;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- 6.1
SELECT *
FROM web_events
WHERE channel != 'organic';

-- 6.2
SELECT *
FROM web_events
WHERE channel <> 'organic';

-- 6.3
SELECT *
FROM web_events
WHERE NOT channel = 'organic';


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- 7.1
SELECT *
FROM orders
WHERE customer_id = 1
AND total_amount > 3000;

-- 7.2
SELECT *
FROM web_events
WHERE channel = 'instagram'
OR customer_id = 2;

-- 7.3
SELECT *
FROM orders
WHERE payment_method = 'credit_card'
AND status = 'delivered'
AND total_amount > 5000;


-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- 8.1
SELECT *
FROM orders
WHERE total_amount >= 5000
AND total_amount <= 9999;

-- 8.2
SELECT *
FROM orders
WHERE total_amount BETWEEN 5000 AND 9999;

-- 8.3
SELECT *
FROM orders
WHERE discount_amount BETWEEN 100 AND 500;

-- 8.4
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-12-25' AND '2025-01-01';


-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- 9.1
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR channel = 'instagram'
OR channel = 'google';

-- 9.2
SELECT *
FROM web_events
WHERE channel IN ('facebook', 'instagram', 'google');

-- 9.3
SELECT *
FROM orders
WHERE customer_id IN (10, 20, 30);

-- 9.4
SELECT *
FROM web_events
WHERE channel NOT IN ('direct', 'google');


-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- 10.1
SELECT *
FROM customers
WHERE email IS NULL;

-- 10.2
SELECT *
FROM customers
WHERE email IS NOT NULL;

-- 10.3
SELECT COUNT(*) AS missing_email_cnt
FROM customers
WHERE email IS NULL;


-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- 11.1
SELECT *
FROM customers
WHERE first_name LIKE 'M%';

-- 11.2
SELECT *
FROM customers
WHERE last_name LIKE '%El%';

-- 11.3
SELECT *
FROM customers
WHERE first_name LIKE '_a____';

-- 11.4
SELECT *
FROM web_events
WHERE channel LIKE 'o%';

-- 11.5
SELECT COUNT(*) AS gmail_cnt
FROM customers
WHERE email LIKE '%gmail.com%';


-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- 12.1
SELECT channel, COUNT(*) AS cnt
FROM web_events
GROUP BY channel;

-- 12.2
SELECT governorate_id, COUNT(*) AS customer_cnt
FROM customers
GROUP BY governorate_id;

-- 12.3
SELECT channel, COUNT(*) AS cnt
FROM web_events
WHERE customer_id = 1
GROUP BY channel;

-- 12.4
SELECT customer_id, COUNT(*) AS order_cnt
FROM orders
GROUP BY customer_id
ORDER BY order_cnt DESC
LIMIT 5;

-- 12.5
SELECT
    customer_id,
    COUNT(*) AS order_count,
    AVG(total_amount) AS avg_total,
    SUM(total_amount) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- 12.6
SELECT
    channel,
    MIN(occurred_at) AS first_event,
    MAX(occurred_at) AS last_event
FROM web_events
GROUP BY channel;

-- 12.7
SELECT customer_id, channel, COUNT(*) AS event_cnt
FROM web_events
WHERE customer_id IN (1, 2, 3)
GROUP BY customer_id, channel;


-- ======================================
-- SECTION 13 — HAVING
-- ======================================

-- 13.1
SELECT governorate_id, COUNT(*) AS num_customers
FROM customers
GROUP BY governorate_id
HAVING COUNT(*) >= 200
ORDER BY num_customers DESC;

-- 13.2
SELECT customer_id, COUNT(*) AS num_orders
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 8
ORDER BY num_orders DESC;

-- 13.3
SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > 40000
ORDER BY total_spent DESC;

-- 13.4
SELECT customer_id, SUM(total_amount) AS total_spent_2023
FROM orders
WHERE order_date LIKE '2023%'
GROUP BY customer_id
HAVING SUM(total_amount) > 10000
ORDER BY total_spent_2023 DESC;


-- ======================================
-- SECTION 14 — DATE Functions
-- ======================================

-- 14.1
SELECT DATE(order_date) AS order_day, COUNT(*) AS num_orders
FROM orders
GROUP BY order_day
ORDER BY num_orders DESC
LIMIT 5;

-- 14.2
SELECT MIN(YEAR(order_date)) AS earliest_year,
       MAX(YEAR(order_date)) AS latest_year
FROM orders;

-- 14.3
SELECT YEAR(order_date) AS ord_year, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY ord_year
ORDER BY ord_year ASC;

-- 14.4
SELECT MONTH(order_date) AS ord_month, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY ord_month
ORDER BY total_revenue DESC;

-- 14.5
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS ord_month,
       SUM(o.total_amount) AS total_spend
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
WHERE c.first_name = 'Nour' AND c.last_name = 'Fahmy'
GROUP BY ord_month
ORDER BY total_spend DESC
LIMIT 1;

-- 14.6
SELECT order_id,
       DATE(order_date) AS order_day,
       DATE_ADD(DATE(order_date), INTERVAL 7 DAY) AS expected_delivery
FROM orders
ORDER BY order_date DESC
LIMIT 10;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT customer_id, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;

-- C2
SELECT customer_id, total_amount
FROM orders
ORDER BY total_amount DESC
LIMIT 1;

-- C3
SELECT c.first_name, c.last_name, o.total_amount
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
ORDER BY o.total_amount DESC
LIMIT 1;

-- C4
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC
LIMIT 5;
