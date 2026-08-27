-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — world database
-- ============================================================
-- Answer key for day01_exercises.sql. Some questions have more than one valid
-- way to write them — these are the reference solutions, not the only
-- correct answers.
-- ============================================================

USE world;


-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- 1.1
SHOW TABLES;

-- 1.2
DESCRIBE city;


-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- 2.1
SELECT *
FROM country;

-- 2.2
SELECT Name, Continent, Region
FROM country;

-- 2.3
SELECT Name, Population
FROM city;


-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- 3.1
SELECT *
FROM city
LIMIT 10;

-- 3.2
SELECT *
FROM country
LIMIT 10 OFFSET 20;

-- 3.3
SELECT *
FROM countrylanguage
LIMIT 5, 5;


-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- 4.1
SELECT DISTINCT Continent
FROM country;

-- 4.2
SELECT DISTINCT GovernmentForm
FROM country;

-- 4.3
SELECT DISTINCT District
FROM city;


-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- 5.1
SELECT COUNT(*) AS country_count
FROM country;

-- 5.2
SELECT COUNT(IndepYear) AS countries_with_indep_year
FROM country;

-- 5.3
SELECT COUNT(DISTINCT Language) AS distinct_languages
FROM countrylanguage;

-- 5.4
SELECT
    COUNT(*) AS country_count,
    COUNT(DISTINCT Continent) AS continent_count,
    COUNT(DISTINCT Region) AS region_count
FROM country;


-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- 6.1
SELECT Name, Population
FROM city
ORDER BY Population DESC
LIMIT 5;

-- 6.2
SELECT Name, LifeExpectancy
FROM country
ORDER BY LifeExpectancy ASC
LIMIT 5;

-- 6.3
SELECT Name, LocalName
FROM country
ORDER BY LocalName;

-- 6.4
SELECT Name, SurfaceArea
FROM country
ORDER BY SurfaceArea DESC
LIMIT 5 OFFSET 3;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT Name, Region, Population
FROM country
ORDER BY Population DESC
LIMIT 10;

-- C2
SELECT COUNT(*) - COUNT(LifeExpectancy) AS missing_life_expectancy
FROM country;
