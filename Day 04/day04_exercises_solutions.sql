-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Rawaj Database
-- ============================================================
-- Answer key for day04_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES
-- ======================================

-- 1.1
SELECT *
FROM orders
WHERE DATE(order_date) = (SELECT MIN(DATE(order_date)) FROM orders);

-- 1.2
SELECT order_id, customer_id, total_amount
FROM orders
WHERE total_amount < (SELECT AVG(total_amount) FROM orders);

-- 1.3
SELECT listing_id, product_id, price
FROM product_listings
WHERE price > (SELECT AVG(price) FROM product_listings);


-- ======================================
-- SECTION 2 — ROW SUBQUERIES
-- ======================================

-- 2.1
SELECT customer_id, occurred_at, channel
FROM web_events
WHERE (customer_id, occurred_at) IN (
    SELECT customer_id, MIN(occurred_at)
    FROM web_events
    GROUP BY customer_id
)
ORDER BY customer_id;


-- ======================================
-- SECTION 3 — DERIVED TABLES
-- ======================================

-- 3.1
SELECT AVG(avg_order_value) AS avg_of_customer_averages
FROM (
    SELECT customer_id, AVG(total_amount) AS avg_order_value
    FROM orders
    GROUP BY customer_id
) AS customer_averages;

-- 3.2
SELECT AVG(item_count) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS order_item_counts;


-- ======================================
-- SECTION 4 — CTEs
-- ======================================

-- 4.1
WITH customer_averages AS (
    SELECT customer_id, AVG(total_amount) AS avg_order_value
    FROM orders
    GROUP BY customer_id
)
SELECT AVG(avg_order_value) AS avg_of_customer_averages
FROM customer_averages;

-- 4.2
WITH manager_totals AS (
    SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN governorates g
        ON c.governorate_id = g.governorate_id
    JOIN account_managers am
        ON g.manager_id = am.manager_id
    GROUP BY am.manager_id, am.manager_name
)
SELECT manager_id, manager_name, total_sales
FROM manager_totals
ORDER BY total_sales DESC
LIMIT 1;

-- 4.3
WITH seller_ratings AS (
    SELECT s.seller_id, AVG(r.rating) AS avg_rating
    FROM sellers s
    JOIN product_listings pl ON s.seller_id = pl.seller_id
    JOIN order_items oi ON oi.listing_id = pl.listing_id
    JOIN reviews r ON r.order_item_id = oi.order_item_id
    GROUP BY s.seller_id
)
SELECT seller_id, avg_rating
FROM seller_ratings
WHERE avg_rating < (SELECT AVG(rating) FROM reviews);


-- ======================================
-- SECTION 5 — CHAINED CTEs
-- ======================================

-- 5.1
WITH manager_totals AS (
    SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN governorates g
        ON c.governorate_id = g.governorate_id
    JOIN account_managers am
        ON g.manager_id = am.manager_id
    GROUP BY am.manager_id, am.manager_name
),
top_manager AS (
    SELECT manager_id, manager_name, total_sales
    FROM manager_totals
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT top_manager.manager_name, COUNT(DISTINCT c.customer_id) AS num_customers, COUNT(o.order_id) AS num_orders
FROM top_manager
JOIN governorates g
    ON g.manager_id = top_manager.manager_id
JOIN customers c
    ON c.governorate_id = g.governorate_id
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY top_manager.manager_name;


-- ======================================
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- 6.1
DROP TEMPORARY TABLE IF EXISTS top_manager;

CREATE TEMPORARY TABLE top_manager
SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
ORDER BY total_sales DESC
LIMIT 1;

SELECT * FROM top_manager;

SELECT top_manager.manager_name, COUNT(*) AS num_customers
FROM top_manager
JOIN governorates g
    ON g.manager_id = top_manager.manager_id
JOIN customers c
    ON c.governorate_id = g.governorate_id
GROUP BY top_manager.manager_name;


-- ======================================
-- SECTION 7 — VIEWS
-- ======================================

-- 7.1
CREATE OR REPLACE VIEW top5_managers AS
SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
ORDER BY total_sales DESC
LIMIT 5;

SELECT w.channel, COUNT(*) AS num_events
FROM web_events w
JOIN customers c
    ON w.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN top5_managers t
    ON g.manager_id = t.manager_id
GROUP BY w.channel
ORDER BY num_events DESC;

-- 7.2
CREATE OR REPLACE VIEW active_listings AS
SELECT pl.listing_id, pl.price, pl.stock_quantity,
       s.seller_name, cat.category_name
FROM product_listings pl
JOIN sellers s ON pl.seller_id = s.seller_id
JOIN products p ON pl.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE pl.status = 'active';

SELECT category_name, COUNT(*) AS num_active_listings
FROM active_listings
GROUP BY category_name
ORDER BY num_active_listings DESC;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
WITH customer_spend AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spend
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT first_name, last_name,
    CONCAT(LOWER(first_name), '-', LOWER(last_name)) AS contact_slug
FROM customer_spend
WHERE total_spend > (SELECT AVG(total_spend) FROM customer_spend);

-- C2
WITH customer_avg AS (
    SELECT c.customer_id, c.governorate_id, AVG(o.total_amount) AS avg_order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.governorate_id
)
SELECT g.governorate_name, AVG(customer_avg.avg_order_value) AS avg_order_value
FROM customer_avg
JOIN governorates g
    ON customer_avg.governorate_id = g.governorate_id
GROUP BY g.governorate_name
ORDER BY avg_order_value DESC
LIMIT 1;

-- C3 (same result as 5.1, materialized as a temp table instead of chained CTEs)
DROP TEMPORARY TABLE IF EXISTS top_manager_c3;

CREATE TEMPORARY TABLE top_manager_c3
SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
ORDER BY total_sales DESC
LIMIT 1;

SELECT top_manager_c3.manager_name, COUNT(DISTINCT c.customer_id) AS num_customers, COUNT(o.order_id) AS num_orders
FROM top_manager_c3
JOIN governorates g
    ON g.manager_id = top_manager_c3.manager_id
JOIN customers c
    ON c.governorate_id = g.governorate_id
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY top_manager_c3.manager_name;
