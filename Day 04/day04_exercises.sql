-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once
--      to create and load the database, if you haven't already.
--   2. See "day04_reading.html" for how subqueries/CTEs/temp tables/views
--      relate to each other.
--
-- Tables available: region, sales_reps, accounts, orders, web_events
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Parch &
--   Posey would actually ask. Write your query directly below each
--   question, then run it to check your answer. Try to solve each one
--   WITHOUT looking at the walkthrough first — use it afterwards only if
--   you get stuck. See day04_exercises_solutions.sql to check your answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES
-- ======================================

-- 1.1 Which order(s) were placed on the very first day Parch & Posey ever
--     received an order? Show every column for those orders.

-- 1.2 Which accounts placed an order for LESS than the company-wide
--     average order amount (total_amt_usd) — these are the "bargain"
--     orders. Show the order id, account id, and total_amt_usd.



-- ======================================
-- SECTION 2 — ROW SUBQUERIES
-- ======================================

-- 2.1 For each account, find their very FIRST web event ever (earliest
--     occurred_at, opposite of the walkthrough's "most recent" version).
--     Show account_id, occurred_at, and channel.



-- ======================================
-- SECTION 3 — DERIVED TABLES
-- ======================================

-- 3.1 What is the average order value, averaged across accounts (i.e. find
--     each account's own average total_amt_usd first, then average THOSE
--     numbers together)? Use a subquery in FROM.



-- ======================================
-- SECTION 4 — CTEs
-- ======================================

-- 4.1 Re-solve 3.1, but using a CTE (WITH ... AS) instead of a derived
--     table in FROM.

-- 4.2 Using a CTE, find the single sales rep with the highest total sales
--     across all their accounts' orders. Show the rep's id, name, and
--     total sales.



-- ======================================
-- SECTION 5 — CHAINED CTEs
-- ======================================

-- 5.1 For that same top sales rep from 4.2, use a second CTE (chained off
--     the first) to show how many accounts they manage and how many total
--     orders those accounts have placed combined.



-- ======================================
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- 6.1 Materialize the top sales rep from 4.2 as a temporary table named
--     top_rep. Then run two SEPARATE queries against it: one showing
--     their total sales, one showing how many accounts they manage
--     (join top_rep to accounts).



-- ======================================
-- SECTION 7 — VIEWS
-- ======================================

-- 7.1 Create a view called top5_sales_reps, ranking reps by total sales
--     across their accounts' orders, top 5 only. Then, using that view,
--     show how many web events came through each channel for accounts
--     belonging to those top 5 reps.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. Generate a company email address (firstname.lastname@accountname.com,
--     all lowercase, no spaces) for every account's point of contact, but
--     ONLY for accounts whose lifetime spend is above the company-wide
--     average account spend. (Combine Day 03's string-building with a
--     subquery filter like Section 1/4.)

-- C2. Using a CTE, find which region has the highest AVERAGE order value
--     per account (not highest total — some regions just have more
--     accounts). Show region name and the average.

-- C3. Take the "top sales rep's account/order counts" question from 5.1
--     and solve it a SECOND way, using a temporary table instead of
--     chained CTEs. Confirm both approaches return the same numbers — this
--     is the same intermediate-result idea, just materialized differently.
