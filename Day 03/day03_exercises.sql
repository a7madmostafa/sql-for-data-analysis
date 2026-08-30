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
--   No real subqueries or CTE syntax yet (that's Day 04) — Section 14 uses a
--   WITH block, but only as a light preview, the same way the walkthrough
--   does. Everything else is solvable with JOIN, GROUP BY, HAVING, CASE, and
--   string functions alone.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- 1.1 Marketing wants a raw combined view: every web event alongside the
--     account it came from, every column from both tables.

-- 1.2 For a cleaner report, pull just the event id, channel, and the
--     account's name.

-- 1.3 Using table aliases, show each event's channel and occurred_at,
--     plus the account's website and primary point of contact.



-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- 2.1 Trace every web event back to the sales rep who owns that
--     account — show the event id, channel, account name, and rep name.

-- 2.2 Regional management wants a per-order gloss-paper unit price,
--     broken out by region — chain all four tables (add 0.01 to the
--     denominator, same divide-by-zero guard as the walkthrough).

-- 2.3 Which account placed the most recent order Parch & Posey has on
--     record? Show the account name and the order date (opposite of the
--     walkthrough's "first order ever").



-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- 3.1 Rank sales reps by total lifetime revenue across every account
--     they manage, biggest earner first.

-- 3.2 For each region, break down web event counts by channel — which
--     region/channel combinations see the most traffic?

-- 3.3 What's the LARGEST order each account has ever placed (by
--     total_amt_usd)? List biggest first.



-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- 4.1 Which sales reps manage 8 or more accounts — are any of them
--     overloaded?

-- 4.2 Which accounts have generated more than $50,000 in gloss-paper
--     revenue alone (SUM of gloss_amt_usd)?

-- 4.3 Which sales reps' TOTAL managed revenue — summed across every
--     account they own — comes in under $50,000? These reps may need
--     extra support.



-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- 5.1 Show every account's id and name, plus the id of each order it's
--     placed (NULL where it's never ordered) — every account should
--     appear, whether or not it has orders.

-- 5.2 Same idea, mirrored: for every order, show its id and
--     total_amt_usd, plus the name of the account it belongs to (same
--     idea as 5.1, opposite JOIN direction).



-- ======================================
-- SECTION 6 — ANTI-JOINS
-- ======================================

-- 6.1 Which accounts have NEVER placed a single order? Show just their
--     id and name — a churn/onboarding red-flag list for the sales team.



-- ======================================
-- SECTION 7 — FULL JOIN (via UNION)
-- ======================================

-- 7.1 MySQL has no FULL JOIN keyword. Using UNION of a LEFT JOIN and a
--     RIGHT JOIN, build one report pairing every account name with an
--     order id — matches, order-only, and account-only rows, all in one
--     result.



-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- 8.1 Tag every order as 'Large' (total_amt_usd >= 3000) or 'Small'
--     (under 3000) — Finance wants to see the split. Show the account id,
--     the total, and the tag.

-- 8.2 Compute a safe unit price for POSTER paper on every order — 0
--     instead of an error whenever poster_qty is 0 or missing.



-- ======================================
-- SECTION 9 — CASE + GROUP BY (binning / tiering)
-- ======================================

-- 9.1 Bucket every order into one of three size categories — 'At Least
--     3000', 'Between 1500 and 3000', or 'Less than 1500' (by the `total`
--     item count) — and count how many orders fall into each.

-- 9.2 Classify every account into a lifetime-value tier: 'gold' (over
--     $150,000 total spend), 'silver' (over $75,000), or 'bronze'. Show
--     account name, total spend, and tier, richest first.

-- 9.3 Repeat 9.2, but counting only spend from 2016 onward. Has anyone's
--     tier changed?

-- 9.4 Flag sales reps as 'high-volume' if they've closed more than 150
--     orders, 'standard' otherwise. Show rep name, order count, and the
--     flag, busiest reps first.



-- ======================================
-- SECTION 10 — CASE + HAVING
-- ======================================

-- 10.1 Which accounts fall specifically into the 'Under 3k' total-sales
--      bracket (bracket boundaries: ZERO / Under 3k [1-3000] / 3-8k
--      [3001-8000] / 8-15k [8001-15000] / +15k)? HAVING can filter on
--      the CASE-derived column directly, same as any other aggregate
--      expression.



-- ======================================
-- SECTION 11 — TRIMMING WHITESPACE
-- ======================================

-- 11.1 A spreadsheet import left extra spaces around some sales rep names.
--      Show every rep's id alongside their name run through TRIM.



-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 12.1 Ops wants a 3-letter account code for a print report — the first 3
--      characters of each account's name.

-- 12.2 Show every account's website alongside just its domain suffix (the
--      last 3 characters, e.g. 'com').

-- 12.3 For every account, show the website and the character position of
--      the first '.' in it.



-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 13.1 IT wants an auto-generated username for every sales rep:
--      firstname.lastname, all lowercase, no spaces (e.g. 'Cara Clarke' ->
--      'cara.clarke'). Assume every name is exactly "First Last".

-- 13.2 For a data-quality audit, show every account's name, its length in
--      characters, and its uppercase version — longest names first.



-- ======================================
-- SECTION 14 — COALESCE / IFNULL
-- ======================================

-- 14.1 A dashboard buckets each account's lifetime spend as 'under $50k'
--      (0 to 50,000) or '$50k-150k' (50,001 to 150,000). Anything spending
--      more than that should show as 'unclassified' instead of blank/NULL.
--      (Hint: CASE only covers the two named buckets, then IFNULL fills
--      the gap — same pattern as the walkthrough's order-total buckets.)



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. For an exec presentation, list the top 5 accounts by total revenue,
--     showing account name, total revenue, their CASE-based tier
--     (gold/silver/bronze, per 9.2's thresholds), the sales rep who
--     manages them, and their region — all in one query.

-- C2. Which single region has generated the most total revenue overall?
--     Show the region name and total revenue.

-- C3. Find sales reps who are BOTH a 'high-volume' performer (more than
--     150 orders, per 9.4) AND managing 8 or more accounts (per 4.1) —
--     show rep name, account count, and order count. (Hint: joining
--     sales_reps to both accounts and orders in one query multiplies
--     rows — COUNT(DISTINCT ...) on the account id avoids overcounting
--     accounts because of that fan-out.)

-- C4. Generate a company email address (firstname.lastname@accountname.com,
--     all lowercase, no spaces) for every account's point of contact, but
--     ONLY for 'gold' tier accounts — total spend over $150,000, same
--     threshold as 9.2's tiering. (Combine Section 13's string-building
--     with a JOIN + HAVING filter on total spend.)
