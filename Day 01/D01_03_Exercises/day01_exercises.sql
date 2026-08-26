-- ============================================================
-- SQL PRACTICE EXERCISES — world database
-- ============================================================
-- Before starting:
--   1. Run "D01_01_Materials/world_db.sql" once to create and load the database.
--   2. Tables available: country, city, countrylanguage — see
--      D01_01_Materials/day01_reading.md for what each one holds.
--
-- Instructions:
--   Every question is framed as something a real stakeholder would ask.
--   Write your query directly below each question, then run it to check
--   your answer. Try to solve each one WITHOUT looking at
--   D01_02_Walkthrough/day01_sql_foundations.sql first — use it afterwards
--   only if you get stuck. See day01_exercises_solutions.sql to check your answers.
--
--   Day 01 only covers SELECT, LIMIT/OFFSET, DISTINCT, ORDER BY, and
--   COUNT — none of these need a WHERE clause (that's Day 02).
-- ============================================================

USE world;


-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- 1.1 A new analyst wants to see what tables exist in the `world` database
--     before writing any queries. Show them the list.

-- 1.2 They also want to see what columns the `city` table has before
--     querying it.



-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- 2.1 Show every column for every row in `country` — a raw dump for a
--     quick sanity check.

-- 2.2 For a country fact sheet, pull just the name, continent, and region
--     for every country.

-- 2.3 Pull just the city name and population for every row in `city`.



-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- 3.1 Preview the first 10 rows of `city`, exactly as stored.

-- 3.2 An analyst is paging through `country` in batches of 10. Show them
--     batch 3 (skip the first 20 rows, then return the next 10).

-- 3.3 Using the MySQL shortcut form (LIMIT offset, count), return rows
--     6–10 of `countrylanguage`.



-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- 4.1 List every distinct continent represented in `country`.

-- 4.2 List every distinct government form (e.g. 'Republic', 'Monarchy')
--     recorded in `country`.

-- 4.3 List every distinct district recorded in the `city` table.



-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- 5.1 How many countries total are stored in `country`?

-- 5.2 `IndepYear` isn't filled in for every country. How many countries
--     DO have a recorded independence year?

-- 5.3 How many distinct languages are tracked across all countries in
--     `countrylanguage`?

-- 5.4 Leadership wants one summary row: total number of countries, and
--     how many distinct continents and regions those countries span —
--     all in a single query.



-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- 6.1 List the 5 most populous cities in the world — name and population
--     only.

-- 6.2 List the 5 countries with the lowest life expectancy — name and
--     life expectancy only.

-- 6.3 List every country's name and local name (`LocalName`), sorted
--     alphabetically by the local name.

-- 6.4 Excluding the 3 largest countries by surface area, show the next 5
--     largest — i.e. ranked 4th through 8th by surface area.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. For a quick country-size leaderboard, list the top 10 countries by
--     population, showing name, region, and population, most populous
--     first.

-- C2. How many countries in `country` have never had a life expectancy
--     value recorded? (Hint: compare COUNT(*) to COUNT of the column —
--     no WHERE clause needed.)
