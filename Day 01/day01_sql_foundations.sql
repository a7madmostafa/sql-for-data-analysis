-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- You've just been given access to the server — before writing any real query,
-- see what data is even available (SCHEMAS and DATABASES are interchangeable in MySQL)
SHOW DATABASES;
SHOW SCHEMAS;

-- Point this session at the world database so every query below runs against it
USE world;

-- See what tables exist inside world before querying any of them
SHOW TABLES;

-- Check the country table's actual column names and types before you query it
DESCRIBE country;

-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- Leadership wants a first look at every country on file, every column, every row
SELECT *
FROM country;

-- They only care about region, continent, and name for now — trim the columns down
SELECT Region, Continent, Name
FROM country;

-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- That's too much to scroll through by eye — just show a 5-row sample
SELECT *
FROM country
LIMIT 5;

-- Same sample, but only the columns leadership actually asked about
SELECT Region, Continent
FROM country
LIMIT 5;

-- MySQL shortcut: LIMIT offset, count — show "page 2" of 3-country pages: skip the first 2, return the next 3
SELECT *
FROM country
LIMIT 2,3;     -- limit 3 offset 2

-- Same "page 2" request, written the standard SQL way instead of the MySQL shortcut
SELECT *
FROM country
LIMIT 3 OFFSET 2;

-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- Before segmenting anything by region, find out what regions actually exist in the data
SELECT DISTINCT Region
FROM country;

-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- How many distinct regions does the world dataset cover?
SELECT COUNT(DISTINCT Region)
FROM country;

-- Same question, with a result column name a report reader would actually understand
SELECT COUNT(DISTINCT Region) AS Regions_CNT
FROM country;

-- AS is optional — the alias can follow the expression directly
SELECT COUNT(DISTINCT Region) Regions_CNT
FROM country;

-- How many countries are in the dataset in total?
SELECT COUNT(*) AS CNTRY_CNT
FROM country;

-- How many countries actually have a country code on file? (COUNT on a column ignores NULLs)
SELECT COUNT(Code) no_of_countries
FROM country;

-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- Give the ops team a quick alphabetical reference: the first 5 countries by name
SELECT Name, Population
FROM country
ORDER BY Name ASC
LIMIT 5;

-- Which 5 countries have the largest population — the obvious first candidates for a market-entry priority list?
SELECT Name, Population
FROM country
ORDER BY Population DESC
LIMIT 5;
