-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Rawaj Database
-- ============================================================
-- Answer key for day03_exercises.sql. Some questions have more than one
-- valid way to write them — these are the reference solutions, not the
-- only correct answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- 1.1
SELECT *
FROM web_events
JOIN customers
    ON web_events.customer_id = customers.customer_id;

-- 1.2
SELECT web_events.event_id, web_events.channel, customers.first_name, customers.last_name
FROM web_events
JOIN customers
    ON web_events.customer_id = customers.customer_id;

-- 1.3
SELECT w.channel, w.occurred_at, c.email, c.governorate_id
FROM web_events w
JOIN customers c
    ON w.customer_id = c.customer_id;


-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- 2.1
SELECT w.event_id, w.channel, c.first_name, c.last_name, am.manager_name
FROM web_events w
JOIN customers c
    ON w.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id;

-- 2.2
SELECT am.manager_name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name;

-- 2.3
SELECT c.first_name, c.last_name, o.order_date
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 1;


-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- 3.1
SELECT am.manager_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
ORDER BY total_sales DESC;

-- 3.2
SELECT g.governorate_name, w.channel, COUNT(*) AS occurrences
FROM web_events w
JOIN customers c
    ON w.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
GROUP BY g.governorate_name, w.channel
ORDER BY occurrences DESC;

-- 3.3
SELECT c.first_name, c.last_name, MAX(o.total_amount) AS largest_order
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY largest_order DESC;


-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- 4.1
SELECT s.seller_id, s.seller_name, COUNT(*) AS num_listings
FROM sellers s
JOIN product_listings pl
    ON s.seller_id = pl.seller_id
GROUP BY s.seller_id, s.seller_name
HAVING COUNT(*) >= 3
ORDER BY num_listings DESC;

-- 4.2
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS cod_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.payment_method = 'cash_on_delivery'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 30000
ORDER BY cod_revenue DESC;

-- 4.3
SELECT am.manager_id, am.manager_name, SUM(o.total_amount) AS total_managed_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
HAVING SUM(o.total_amount) < 2500000
ORDER BY total_managed_revenue;


-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- 5.1
SELECT c.customer_id, c.first_name, c.last_name, o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

-- 5.2
-- Same 6,004 rows as 5.1 — RIGHT JOIN customers keeps everything from
-- customers (named second here), exactly what LEFT JOIN did in 5.1.
SELECT c.customer_id, c.first_name, c.last_name, o.order_id
FROM orders o
RIGHT JOIN customers c
    ON o.customer_id = c.customer_id;


-- ======================================
-- SECTION 6 — ANTI-JOINS
-- ======================================

-- 6.1
SELECT COUNT(*) AS customers_never_ordered
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- ======================================
-- SECTION 7 — FULL JOIN (via UNION)
-- ======================================

-- 7.1
SELECT o.customer_id AS ordered_customer, w.customer_id AS browsed_customer
FROM (SELECT DISTINCT customer_id FROM orders WHERE order_date >= '2025-01-01') o
LEFT JOIN (SELECT DISTINCT customer_id FROM web_events WHERE occurred_at >= '2025-01-01') w
    ON o.customer_id = w.customer_id

UNION

SELECT o.customer_id AS ordered_customer, w.customer_id AS browsed_customer
FROM (SELECT DISTINCT customer_id FROM orders WHERE order_date >= '2025-01-01') o
RIGHT JOIN (SELECT DISTINCT customer_id FROM web_events WHERE occurred_at >= '2025-01-01') w
    ON o.customer_id = w.customer_id;


-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- 8.1
SELECT order_id, total_amount,
    CASE
        WHEN total_amount >= 6000 THEN 'Large'
        ELSE 'Small'
    END AS order_tag
FROM orders;

-- 8.2
SELECT order_id,
    CASE
        WHEN subtotal = 0 OR subtotal IS NULL THEN 0
        ELSE ROUND(shipping_fee / subtotal * 100, 2)
    END AS shipping_pct
FROM orders;


-- ======================================
-- SECTION 9 — CASE + GROUP BY
-- ======================================

-- 9.1
SELECT
    CASE
        WHEN total_amount >= 10000 THEN 'At Least 10000'
        WHEN total_amount BETWEEN 4000 AND 9999 THEN 'Between 4000 and 9999'
        ELSE 'Less than 4000'
    END AS order_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- 9.2
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) > 35000 THEN 'gold'
        WHEN SUM(o.total_amount) > 15000 THEN 'silver'
        ELSE 'bronze'
    END AS customer_tier
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 9.3
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) > 35000 THEN 'gold'
        WHEN SUM(o.total_amount) > 15000 THEN 'silver'
        ELSE 'bronze'
    END AS customer_tier
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date > '2024-12-31'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 9.4
SELECT am.manager_name, COUNT(*) AS num_orders,
    CASE
        WHEN COUNT(*) > 1500 THEN 'high-volume'
        ELSE 'standard'
    END AS manager_level
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
ORDER BY num_orders DESC;


-- ======================================
-- SECTION 10 — CASE + HAVING
-- ======================================

-- 10.1
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spend,
    CASE
        WHEN SUM(o.total_amount) = 0 THEN 'ZERO'
        WHEN SUM(o.total_amount) BETWEEN 1 AND 15000 THEN 'Under 15k'
        WHEN SUM(o.total_amount) BETWEEN 15001 AND 30000 THEN '15-30k'
        WHEN SUM(o.total_amount) BETWEEN 30001 AND 45000 THEN '30-45k'
        ELSE '+45k'
    END AS spend_bracket
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) BETWEEN 15001 AND 30000;


-- ======================================
-- SECTION 11 — TRIMMING WHITESPACE
-- ======================================

-- 11.1
SELECT seller_id, TRIM(seller_name) AS trimmed_name
FROM sellers;


-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 12.1
SELECT seller_name, LEFT(seller_name, 3) AS seller_code
FROM sellers;

-- 12.2
SELECT email, SUBSTRING(email, LOCATE('@', email) + 1) AS email_domain
FROM customers
WHERE email IS NOT NULL;

-- 12.3
SELECT email, LOCATE('@', email) AS at_position
FROM customers
WHERE email IS NOT NULL;


-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 13.1
SELECT seller_name, LOWER(REPLACE(seller_name, ' ', '-')) AS slug
FROM sellers;

-- 13.2
-- CHAR_LENGTH counts characters; LENGTH counts bytes (the same number for
-- plain ASCII names, but not once multi-byte characters are involved).
SELECT seller_name, CHAR_LENGTH(seller_name) AS name_length, UPPER(seller_name) AS upper_name
FROM sellers
ORDER BY name_length DESC;


-- ======================================
-- SECTION 14 — COALESCE / IFNULL
-- ======================================

-- 14.1
WITH spend AS (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spend,
        CASE
            WHEN SUM(o.total_amount) BETWEEN 0 AND 20000 THEN 'under 20k'
            WHEN SUM(o.total_amount) BETWEEN 20001 AND 40000 THEN '20k-40k'
        END AS spend_tier
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, first_name, last_name, total_spend, IFNULL(spend_tier, 'unclassified') AS spend_tier
FROM spend;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_revenue,
    CASE
        WHEN SUM(o.total_amount) > 35000 THEN 'gold'
        WHEN SUM(o.total_amount) > 15000 THEN 'silver'
        ELSE 'bronze'
    END AS tier,
    am.manager_name, g.governorate_name
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY c.customer_id, c.first_name, c.last_name, am.manager_name, g.governorate_name
ORDER BY total_revenue DESC
LIMIT 5;

-- C2
SELECT g.governorate_name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
GROUP BY g.governorate_name
ORDER BY total_revenue DESC
LIMIT 1;

-- C3
SELECT s.seller_name,
       COUNT(DISTINCT pl.listing_id) AS num_listings,
       COUNT(DISTINCT sh.shipment_id) AS num_shipments
FROM sellers s
JOIN product_listings pl
    ON s.seller_id = pl.seller_id
JOIN shipments sh
    ON s.seller_id = sh.seller_id
GROUP BY s.seller_id, s.seller_name
HAVING COUNT(DISTINCT pl.listing_id) >= 8
AND COUNT(DISTINCT sh.shipment_id) >= 20;

-- C4
SELECT c.first_name, c.last_name,
    CONCAT(LOWER(c.first_name), '-', LOWER(c.last_name)) AS contact_slug
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 35000;

-- C5
SELECT c.first_name, c.last_name, o.total_amount
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
ORDER BY o.total_amount DESC
LIMIT 1;

-- C6
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_revenue DESC
LIMIT 5;
