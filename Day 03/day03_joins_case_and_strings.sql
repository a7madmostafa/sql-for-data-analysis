USE rawaj;

-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- Finance wants order and customer details together in one view — combine every order with the customer who placed it
SELECT *
FROM orders
JOIN customers
    ON orders.customer_id = customers.customer_id;

-- They only need a few fields, not everything — pick specific columns from each side
SELECT orders.order_id, customers.first_name, customers.last_name, orders.order_date
FROM orders
JOIN customers
    ON orders.customer_id = customers.customer_id;

-- Same request, written with table aliases (AS is optional) since real reports reference these tables constantly
SELECT c.email, c.governorate_id,
       o.status, o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id;

-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- Leadership wants to trace every order all the way back to the account manager responsible for that customer's governorate
SELECT *
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id;

-- Regional leadership wants average order value, broken out by account manager — chain all four tables together
SELECT am.manager_name, g.governorate_name,
       AVG(o.total_amount) AS avg_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_name, g.governorate_name;

-- Which customer placed the very first order Rawaj ever received? (name + date)
SELECT c.first_name, c.last_name, o.order_date
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
ORDER BY o.order_date
LIMIT 1;

-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- Which customers have generated the most total revenue, biggest spender first?
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_sales
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_sales DESC;

-- For each account manager, how many times was each marketing channel used by customers in their governorates?
SELECT am.manager_name, w.channel, COUNT(*) AS occurrences
FROM web_events w
JOIN customers c
    ON w.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_name, w.channel
ORDER BY occurrences DESC;

-- What's the smallest order each customer has ever placed — a per-customer "floor" for order size?
SELECT c.first_name, c.last_name, MIN(o.total_amount) AS smallest_order
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY smallest_order;

-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- HAVING was introduced in Day 02 (filtering aggregates on a single table) —
-- nothing new here syntactically, just applied to a result that now spans a JOIN.

-- Which account managers are responsible for more than 200 customers — are any of them overloaded?
SELECT am.manager_id, am.manager_name, COUNT(*) AS num_customers
FROM customers c
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
HAVING COUNT(*) > 200
ORDER BY num_customers;

-- Which customers have placed more than 8 orders — Rawaj's most active repeat buyers?
SELECT c.customer_id, c.first_name, c.last_name, COUNT(*) AS num_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(*) > 8
ORDER BY num_orders;

-- Which customers have spent less than 2,000 EGP total across all orders — candidates for a re-engagement campaign?
SELECT c.customer_id, c.first_name, c.last_name, SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) < 2000
ORDER BY total_spent;

-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- Which customers exist, whether or not they've ever placed an order? (unmatched order columns come back NULL)
SELECT *
FROM customers
LEFT JOIN orders
    ON orders.customer_id = customers.customer_id;

-- Same idea, mirrored: which orders exist, even if their customer record can no longer be resolved?
SELECT *
FROM orders
RIGHT JOIN customers
    ON orders.customer_id = customers.customer_id;

-- LEFT OUTER JOIN / RIGHT OUTER JOIN — OUTER is optional noise, means exactly the same as LEFT/RIGHT JOIN
SELECT *
FROM customers
LEFT OUTER JOIN orders
    ON orders.customer_id = customers.customer_id;

-- ======================================
-- SECTION 6 — ANTI-JOINS (finding non-matches)
-- ======================================

-- Which customers have NEVER placed a single order — a re-engagement red-flag list for marketing?
SELECT *
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- ======================================
-- SECTION 7 — FULL JOIN (MySQL has no FULL JOIN keyword — emulate with UNION)
-- ======================================

-- Compliance wants a single report: which customers have placed an order, which have
-- generated a web event, and where these two lists diverge — matched, order-only, and
-- browse-only rows, all in one result
SELECT o.customer_id AS ordered_customer, w.customer_id AS browsed_customer
FROM (SELECT DISTINCT customer_id FROM orders) o
LEFT JOIN (SELECT DISTINCT customer_id FROM web_events) w
    ON o.customer_id = w.customer_id

UNION

SELECT o.customer_id AS ordered_customer, w.customer_id AS browsed_customer
FROM (SELECT DISTINCT customer_id FROM orders) o
RIGHT JOIN (SELECT DISTINCT customer_id FROM web_events) w
    ON o.customer_id = w.customer_id;

-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- Flag every order as "Large" or "Small" so a dashboard can color-code them at a glance
SELECT order_id, customer_id, total_amount,
    CASE
        WHEN total_amount > 5000 THEN 'Large'
        ELSE 'Small'
    END AS order_level
FROM orders;

-- Compute a safe discount percentage per order, guarding against division by zero if subtotal were ever 0
SELECT order_id,
    CASE
        WHEN subtotal = 0 OR subtotal IS NULL THEN 0
        ELSE ROUND(discount_amount / subtotal * 100, 2)
    END AS discount_pct
FROM orders
LIMIT 10;

-- ======================================
-- SECTION 9 — CASE + GROUP BY (binning / tiering)
-- ======================================

-- For a reporting dashboard, bucket every order into a size category, then count how many fall in each
SELECT
    CASE
        WHEN total_amount >= 8000 THEN 'At Least 8000'
        WHEN total_amount BETWEEN 3000 AND 7999 THEN 'Between 3000 and 7999'
        ELSE 'Less than 3000'
    END AS order_category,
    COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- Which customers are top / middle / low lifetime-value buyers, based on total spend?
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) > 40000 THEN 'top'
        WHEN SUM(o.total_amount) > 20000 THEN 'middle'
        ELSE 'low'
    END AS customer_level
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Same tiering question, but restricted to spend from 2024 onward only — has anyone's tier shifted recently?
SELECT c.first_name, c.last_name, SUM(o.total_amount) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) > 40000 THEN 'top'
        WHEN SUM(o.total_amount) > 20000 THEN 'middle'
        ELSE 'low'
    END AS customer_level
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date > '2023-12-31'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Which account managers count as "top performers" — governorates whose customers placed more than 1,000 combined orders?
SELECT am.manager_name, COUNT(*) AS num_orders,
    CASE
        WHEN COUNT(*) > 1000 THEN 'top'
        ELSE 'not'
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

-- Which account managers fall specifically in the "2M-3M EGP total revenue" band — a mid-tier group worth a closer look?
SELECT am.manager_name, SUM(o.total_amount) AS total_revenue,
    CASE
        WHEN SUM(o.total_amount) = 0 THEN 'ZERO'
        WHEN SUM(o.total_amount) BETWEEN 1 AND 2000000 THEN 'Under 2M'
        WHEN SUM(o.total_amount) BETWEEN 2000001 AND 3000000 THEN '2-3M'
        ELSE '+3M'
    END AS revenue_band
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN governorates g
    ON c.governorate_id = g.governorate_id
JOIN account_managers am
    ON g.manager_id = am.manager_id
GROUP BY am.manager_id, am.manager_name
HAVING SUM(o.total_amount) BETWEEN 2000001 AND 3000000;

-- ======================================
-- SECTION 11 — TRIMMING WHITESPACE
-- ======================================

-- A CSV export from a legacy CRM padded every seller name with stray
-- spaces — clean it up before the data gets loaded anywhere else
SELECT LTRIM('     Cairo Electronics') AS left_trim;
SELECT RTRIM('Cairo Electronics          ') AS right_trim;
SELECT TRIM('     Cairo Electronics          ') AS trim_both;

-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- Marketing wants a 4-letter seller-code abbreviation for a print report,
-- and needs to know where the first space falls in each seller's name for
-- a later splitting step
SELECT seller_name, LEFT(seller_name, 4) AS seller_code
FROM sellers
LIMIT 5;

-- LOCATE finds the position of a substring (1-indexed) — here, the first space
-- inside a seller's name, which is what SECTION 13 uses to split
-- "Cairo Electronics" into its first word
SELECT seller_name, LOCATE(' ', seller_name) AS space_position
FROM sellers
LIMIT 5;

-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- Sales wants a contact email auto-generated for every seller, from just the
-- first word of their shop name: firstword@rawaj-marketplace.com, all lowercase
WITH first_word AS (
    SELECT
        seller_name,
        LEFT(seller_name, LOCATE(' ', seller_name) - 1) AS first_word
    FROM sellers
)
SELECT seller_name, first_word,
       CONCAT(LOWER(first_word), '@rawaj-marketplace.com') AS contact_email
FROM first_word;

-- Quick contrast: LOWER/UPPER/LENGTH applied directly to a column
SELECT first_name, LOWER(first_name) AS lower_name, UPPER(first_name) AS upper_name, LENGTH(first_name) AS name_length
FROM customers
LIMIT 5;

-- ======================================
-- SECTION 14 — COALESCE / IFNULL (filling in NULLs)
-- ======================================

-- Bucket every order by total amount, but the buckets only cover 0-2000 and
-- 2001-5000 — anything larger falls through as NULL and needs a "5000+" label
WITH total_range AS (
    SELECT
        CASE
            WHEN total_amount BETWEEN 0 AND 2000 THEN '0-2000'
            WHEN total_amount BETWEEN 2001 AND 5000 THEN '2001-5000'
        END AS total_range
    FROM orders
)
SELECT IFNULL(total_range, '5000+') AS total_range
FROM total_range;
