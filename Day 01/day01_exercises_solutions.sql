-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — rawaj database
-- ============================================================
-- Answer key for day01_exercises.sql. Some questions have more than one valid
-- way to write them — these are the reference solutions, not the only
-- correct answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- 1.1
SHOW TABLES;

-- 1.2
DESCRIBE governorates;


-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- 2.1
SELECT *
FROM customers;

-- 2.2
SELECT first_name, last_name, email
FROM customers;

-- 2.3
SELECT governorate_name
FROM governorates;


-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- 3.1
SELECT *
FROM customers
LIMIT 10;

-- 3.2
SELECT *
FROM customers
LIMIT 10 OFFSET 20;

-- 3.3
SELECT *
FROM customers
LIMIT 5, 5;


-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- 4.1
SELECT DISTINCT governorate_id
FROM customers;

-- 4.2
SELECT DISTINCT manager_id
FROM governorates;


-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- 5.1
SELECT COUNT(*) AS customer_count
FROM customers;

-- 5.2
SELECT COUNT(email) AS customers_with_email
FROM customers;

-- 5.3
SELECT COUNT(DISTINCT governorate_id) AS governorate_count
FROM customers;

-- 5.4
SELECT
    COUNT(*) AS customer_count,
    COUNT(DISTINCT governorate_id) AS governorate_count
FROM customers;


-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- 6.1
SELECT first_name, last_name, signup_date
FROM customers
ORDER BY signup_date ASC
LIMIT 5;

-- 6.2
SELECT first_name, last_name, signup_date
FROM customers
ORDER BY signup_date DESC
LIMIT 5;

-- 6.3
SELECT first_name, last_name
FROM customers
ORDER BY last_name;

-- 6.4
SELECT first_name, last_name, signup_date
FROM customers
ORDER BY signup_date ASC
LIMIT 5 OFFSET 3;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT first_name, last_name, governorate_id, signup_date
FROM customers
ORDER BY signup_date ASC
LIMIT 10;

-- C2
SELECT COUNT(*) - COUNT(email) AS missing_email
FROM customers;
