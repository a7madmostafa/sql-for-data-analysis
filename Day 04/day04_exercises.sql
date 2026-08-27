-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once
--      to create and load the database, if you haven't already.
--   2. See "day04_reading.html" for string function syntax, and how
--      subqueries/CTEs/temp tables/views relate to each other.
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
-- SECTION 1 — TRIMMING WHITESPACE
-- ======================================

-- 1.1 A spreadsheet import left extra spaces around some sales rep names.
--     Show every rep's id alongside their name run through TRIM.



-- ======================================
-- SECTION 2 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 2.1 Ops wants a 3-letter account code for a print report — the first 3
--     characters of each account's name.

-- 2.2 Show every account's website alongside just its domain suffix (the
--     last 3 characters, e.g. 'com').

-- 2.3 For every account, show the website and the character position of
--     the first '.' in it (this is what SECTION 2.2's-style suffix
--     extraction would need if the suffix length varied).



-- ======================================
-- SECTION 3 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 3.1 IT wants an auto-generated username for every sales rep:
--     firstname.lastname, all lowercase, no spaces (e.g. 'Cara Clarke' ->
--     'cara.clarke'). Assume every name is exactly "First Last".

-- 3.2 For a data-quality audit, show every account's name, its length in
--     characters, and its uppercase version — longest names first.



-- ======================================
-- SECTION 4 — COALESCE / IFNULL
-- ======================================

-- 4.1 A dashboard buckets each account's lifetime spend as 'under $50k' (0
--     to 50,000) or '$50k-150k' (50,001 to 150,000). Anything spending
--     more than that should show as 'unclassified' instead of blank/NULL.
--     (Hint: CASE only covers the two named buckets, then IFNULL fills the
--     gap — same pattern as the walkthrough's order-total buckets.)



-- ======================================
-- SECTION 5 — SCALAR SUBQUERIES
-- ======================================

-- 5.1 Which order(s) were placed on the very first day Parch & Posey ever
--     received an order? Show every column for those orders.

-- 5.2 Which accounts placed an order for LESS than the company-wide
--     average order amount (total_amt_usd) — these are the "bargain"
--     orders. Show the order id, account id, and total_amt_usd.



-- ======================================
-- SECTION 6 — ROW SUBQUERIES
-- ======================================

-- 6.1 For each account, find their very FIRST web event ever (earliest
--     occurred_at, opposite of the walkthrough's "most recent" version).
--     Show account_id, occurred_at, and channel.



-- ======================================
-- SECTION 7 — DERIVED TABLES
-- ======================================

-- 7.1 What is the average order value, averaged across accounts (i.e. find
--     each account's own average total_amt_usd first, then average THOSE
--     numbers together)? Use a subquery in FROM.



-- ======================================
-- SECTION 8 — CTEs
-- ======================================

-- 8.1 Re-solve 7.1, but using a CTE (WITH ... AS) instead of a derived
--     table in FROM.

-- 8.2 Using a CTE, find the single sales rep with the highest total sales
--     across all their accounts' orders. Show the rep's id, name, and
--     total sales.



-- ======================================
-- SECTION 9 — CHAINED CTEs
-- ======================================

-- 9.1 For that same top sales rep from 8.2, use a second CTE (chained off
--     the first) to show how many accounts they manage and how many total
--     orders those accounts have placed combined.



-- ======================================
-- SECTION 10 — TEMPORARY TABLES
-- ======================================

-- 10.1 Materialize the top sales rep from 8.2 as a temporary table named
--      top_rep. Then run two SEPARATE queries against it: one showing
--      their total sales, one showing how many accounts they manage
--      (join top_rep to accounts).



-- ======================================
-- SECTION 11 — VIEWS
-- ======================================

-- 11.1 Create a view called top5_sales_reps, ranking reps by total sales
--      across their accounts' orders, top 5 only. Then, using that view,
--      show how many web events came through each channel for accounts
--      belonging to those top 5 reps.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. Generate a company email address (firstname.lastname@accountname.com,
--     all lowercase, no spaces) for every account's point of contact, but
--     ONLY for accounts whose lifetime spend is above the company-wide
--     average account spend. (Combine Section 3's string-building with a
--     subquery filter like Section 5/8.)

-- C2. Using a CTE, find which region has the highest AVERAGE order value
--     per account (not highest total — some regions just have more
--     accounts). Show region name and the average.

-- C3. Take the "top sales rep's account/order counts" question from 9.1
--     and solve it a SECOND way, using a temporary table instead of
--     chained CTEs. Confirm both approaches return the same numbers — this
--     is the same intermediate-result idea, just materialized differently.
