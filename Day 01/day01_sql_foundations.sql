-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- List all databases on this server (SCHEMAS and DATABASES are interchangeable in MySQL)
SHOW DATABASES;
SHOW SCHEMAS;

-- Switch to the world database
USE world;

-- List all tables in the current database
SHOW TABLES;

-- Show the country table's column names and types
DESCRIBE country;

-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- Select all columns, all rows from the country table
SELECT *
FROM country;

-- Select specific columns (all rows) from the country table
SELECT Region, Continent, Name
FROM country;

-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- Limit the result to the first 5 rows
SELECT *
FROM country
LIMIT 5;

-- LIMIT also works with a specific column list, not just SELECT *
SELECT Region, Continent
FROM country
LIMIT 5;

-- MySQL shortcut: LIMIT offset, count — skip 2 rows, then return 3
SELECT *
FROM country
LIMIT 2,3;     -- limit 3 offset 2

-- Same thing, standard SQL form
SELECT *
FROM country
LIMIT 3 OFFSET 2;

-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- List of unique regions (no duplicates)
SELECT DISTINCT Region
FROM country;

-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- Number of unique regions
SELECT COUNT(DISTINCT Region)
FROM country;

-- Aliasing the result column with AS
SELECT COUNT(DISTINCT Region) AS Regions_CNT
FROM country;

-- AS is optional — the alias can follow the expression directly
SELECT COUNT(DISTINCT Region) Regions_CNT
FROM country;

-- Total number of countries (every row)
SELECT COUNT(*) AS CNTRY_CNT
FROM country;

-- COUNT on a specific column only counts non-null values
SELECT COUNT(Code) no_of_countries
FROM country;

-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- Alphabetic order: first 5 countries by name
SELECT Name, Population
FROM country
ORDER BY Name ASC
LIMIT 5;

-- Numeric order: top 5 countries by population
SELECT Name, Population
FROM country
ORDER BY Population DESC
LIMIT 5;
