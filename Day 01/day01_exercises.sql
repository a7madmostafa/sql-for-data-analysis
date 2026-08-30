-- ============================================================
-- SQL PRACTICE EXERCISES — rawaj database
-- ============================================================
-- Before starting:
--   1. Run "Databases/rawaj_db.sql" once to create and load the database.
--   2. Tables available: customers, governorates — see
--      day01_reading.html for what each one holds.
--
-- Instructions:
--   Every question is framed as something a real stakeholder would ask.
--   Write your query directly below each question, then run it to check
--   your answer. Try to solve each one WITHOUT looking at
--   day01_sql_foundations.sql first — use it afterwards
--   only if you get stuck. See day01_exercises_solutions.sql to check your answers.
--
--   Day 01 only covers SELECT, LIMIT/OFFSET, DISTINCT, ORDER BY, and
--   COUNT — none of these need a WHERE clause (that's Day 02).
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — EXPLORING THE SERVER
-- ======================================

-- 1.1 A new analyst wants to see what tables exist in the `rawaj` database
--     before writing any queries. Show them the list.

-- 1.2 They also want to see what columns the `governorates` table has before
--     querying it.



-- ======================================
-- SECTION 2 — SELECT
-- ======================================

-- 2.1 Show every column for every row in `customers` — a raw dump for a
--     quick sanity check.

-- 2.2 For a customer contact sheet, pull just the first_name, last_name,
--     and email for every customer.

-- 2.3 Pull just the governorate_name for every row in `governorates`.



-- ======================================
-- SECTION 3 — LIMIT & OFFSET
-- ======================================

-- 3.1 Preview the first 10 rows of `customers`, exactly as stored.

-- 3.2 An analyst is paging through `customers` in batches of 10. Show them
--     batch 3 (skip the first 20 rows, then return the next 10).

-- 3.3 Using the MySQL shortcut form (LIMIT offset, count), return rows
--     6–10 of `customers`.



-- ======================================
-- SECTION 4 — DISTINCT
-- ======================================

-- 4.1 List every distinct governorate_id represented in `customers`.

-- 4.2 List every distinct manager_id assigned across `governorates`
--     (including any governorate with none assigned yet).



-- ======================================
-- SECTION 5 — AGGREGATION (COUNT)
-- ======================================

-- 5.1 How many customers total are stored in `customers`?

-- 5.2 `email` isn't filled in for every customer. How many customers DO
--     have an email on file?

-- 5.3 How many distinct governorates are customers registered in?

-- 5.4 Leadership wants one summary row: total number of customers, and how
--     many distinct governorates those customers span — all in a single
--     query.



-- ======================================
-- SECTION 6 — ORDER BY
-- ======================================

-- 6.1 List the 5 earliest customer signups — first_name, last_name, and
--     signup_date only.

-- 6.2 List the 5 MOST RECENT customer signups — same columns, sorted the
--     other direction.

-- 6.3 List every customer's first_name and last_name, sorted alphabetically
--     by last_name.

-- 6.4 Excluding the 3 earliest signups, show the next 5 — i.e. customers
--     ranked 4th through 8th by signup_date.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. For a "founding customers" leaderboard, list the top 10 earliest-
--     signed-up customers, showing first_name, last_name, governorate_id,
--     and signup_date, earliest first.

-- C2. How many customers in `customers` have never had an email recorded?
--     (Hint: compare COUNT(*) to COUNT of the column — no WHERE clause
--     needed.)
