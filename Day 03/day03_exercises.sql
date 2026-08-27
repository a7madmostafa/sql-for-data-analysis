-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once
--      to create and load the database, if you haven't already.
--   2. See "day03_reading.html" for how JOIN syntax maps
--      onto the relationship types from Day 01, plus the parch_and_posey
--      schema recap.
--
-- Tables available: region, sales_reps, accounts, orders, web_events
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Parch &
--   Posey would actually ask. Write your query directly below each
--   question, then run it to check your answer. Try to solve each one
--   WITHOUT looking at the walkthrough first — use it afterwards only if
--   you get stuck. See day03_exercises_solutions.sql to check your answers.
--
--   No subqueries or CTEs yet (that's Day 04) — everything here is
--   solvable with JOIN, GROUP BY, HAVING, and CASE alone.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- 1.1 An analyst wants a raw combined view: every order alongside the
--     account that placed it, every column from both tables.

-- 1.2 For a cleaner report, pull just the order id, account name, and
--     order date.

-- 1.3 Using table aliases, pull each account's website and point of
--     contact, plus how many units of standard/gloss/poster paper they
--     ordered, for every order.



-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- 2.1 Sales leadership wants a full picture: for every order, show the
--     order id, the account name, and the name of the sales rep who
--     manages that account.

-- 2.2 Finance wants unit prices: for every order, show the region name,
--     account name, and unit price (total_amt_usd / total — add 0.01 to
--     the denominator to dodge a divide-by-zero on a few zero-total
--     orders).

-- 2.3 Which account placed the very first order in company history? Show
--     the account name and the order date.



-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- 3.1 Rank every account by total lifetime spend, biggest spender first.

-- 3.2 For each sales rep, break down how many web events came through
--     each channel.

-- 3.3 For each account, what was their smallest order ever (by
--     total_amt_usd)? List smallest first.



-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- 4.1 Which sales reps are overloaded — managing more than 5 accounts?

-- 4.2 Flag any account with more than 20 orders — these are your power
--     users.

-- 4.3 Which accounts have spent less than $1,000 total across all their
--     orders? Marketing wants to target these for a re-engagement
--     campaign.



-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- 5.1 Show every account, whether or not they've ever placed an order.

-- 5.2 Show every order, even ones whose account can't be resolved (same
--     idea as 5.1, opposite JOIN direction).



-- ======================================
-- SECTION 6 — ANTI-JOINS
-- ======================================

-- 6.1 Which accounts have NEVER placed a single order? These might be
--     stale leads worth following up on.



-- ======================================
-- SECTION 7 — FULL JOIN (via UNION)
-- ======================================

-- 7.1 MySQL has no FULL JOIN keyword. Using UNION of a LEFT JOIN and a
--     RIGHT JOIN, show every order/account pairing — matches, orders
--     without a resolvable account, and accounts without orders, all in
--     one result.



-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- 8.1 Tag every order as 'Large' (total_amt_usd >= 3000) or 'Small'
--     (under 3000) — Finance wants to see the split. Show the account id,
--     the total, and the tag.

-- 8.2 Compute a safe unit price for standard paper on every order — 0
--     instead of an error whenever standard_qty is 0 or missing.



-- ======================================
-- SECTION 9 — CASE + GROUP BY (binning / tiering)
-- ======================================

-- 9.1 Bucket every order into one of three size categories — 'At Least
--     2000', 'Between 1000 and 2000', or 'Less than 1000' (by the `total`
--     item count) — and count how many orders fall into each.

-- 9.2 Classify every account into a lifetime-value tier: 'top' (over
--     $200,000 total spend), 'middle' (over $100,000), or 'low'. Show
--     account name, total spend, and tier, richest first.

-- 9.3 Repeat 9.2, but counting only spend from 2016 onward. Has anyone's
--     tier changed?

-- 9.4 Flag sales reps as 'top' performers if they've closed more than 200
--     orders, 'not' otherwise. Show rep name, order count, and the flag,
--     busiest reps first.



-- ======================================
-- SECTION 10 — CASE + HAVING
-- ======================================

-- 10.1 Which sales reps fall specifically into the 'Under 5k' total-sales
--      bracket (bracket boundaries: ZERO / Under 5k [1-5000] / 5-10k
--      [5001-10000] / 10-20k [10001-20000] / +20k)? HAVING can filter on
--      the CASE-derived column directly, same as any other aggregate
--      expression.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. For an exec presentation, list the top 5 accounts by total revenue,
--     showing account name, total revenue, their CASE-based tier
--     (top/middle/low, per 9.2's thresholds), the sales rep who manages
--     them, and their region — all in one query.

-- C2. Which single region has generated the most total revenue overall?
--     Show the region name and total revenue.

-- C3. Find sales reps who are BOTH a 'top' performer (more than 200
--     orders, per 9.4) AND managing more than 5 accounts (per 4.1) —
--     show rep name, account count, and order count. (Hint: joining
--     sales_reps to both accounts and orders in one query multiplies
--     rows — COUNT(DISTINCT ...) on the account id avoids overcounting
--     accounts because of that fan-out.)
