-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- You've just been given access to the server — before writing any real query,
-- see what data is even available (SCHEMAS and DATABASES are interchangeable in MySQL)
SHOW DATABASES;
SHOW SCHEMAS;

-- Point this session at the rawaj database so every query below runs against it
USE rawaj;

-- See what tables exist inside rawaj before querying any of them
SHOW TABLES;

-- Check the customers table's actual column names and types before you query it
DESCRIBE customers;

-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- Marketing wants a first look at every customer on file, every column, every row
SELECT *
FROM customers;

-- They only care about first_name, last_name, and email for now — trim the columns down
SELECT first_name, last_name, email
FROM customers;

-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- That's too much to scroll through by eye — just show a 5-row sample
SELECT *
FROM customers
LIMIT 5;

-- Same sample, but only the columns marketing actually asked about
SELECT first_name, last_name
FROM customers
LIMIT 5;

-- MySQL shortcut: LIMIT offset, count — show "page 2" of 3-customer pages: skip the first 2, return the next 3
SELECT *
FROM customers
LIMIT 2,3;     -- limit 3 offset 2

-- Same "page 2" request, written the standard SQL way instead of the MySQL shortcut
SELECT *
FROM customers
LIMIT 3 OFFSET 2;

-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- Before segmenting anything by governorate, find out which governorates actually have customers registered
SELECT DISTINCT governorate_id
FROM customers;

-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- How many distinct governorates does Rawaj have customers in?
SELECT COUNT(DISTINCT governorate_id)
FROM customers;

-- Same question, with a result column name a report reader would actually understand
SELECT COUNT(DISTINCT governorate_id) AS governorate_cnt
FROM customers;

-- AS is optional — the alias can follow the expression directly
SELECT COUNT(DISTINCT governorate_id) governorate_cnt
FROM customers;

-- How many customers are in the dataset in total?
SELECT COUNT(*) AS customer_cnt
FROM customers;

-- How many customers actually have an email on file? (COUNT on a column ignores NULLs)
SELECT COUNT(email) AS customers_with_email
FROM customers;

-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- Give the ops team a quick alphabetical reference: the first 5 customers by last name
SELECT first_name, last_name
FROM customers
ORDER BY last_name ASC
LIMIT 5;

-- Which 5 customers signed up earliest — Rawaj's very first adopters?
SELECT first_name, last_name, signup_date
FROM customers
ORDER BY signup_date ASC
LIMIT 5;
