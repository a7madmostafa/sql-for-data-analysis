-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once
--      to create and load the database, if you haven't already.
--   2. See "day04_reading.html" for how subqueries/CTEs/temp tables/views
--      relate to each other, and for DELIMITER syntax.
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
-- SECTION 8 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 8.1 Marketing wants to see poster-paper order volume build up over
--     time — a running total of poster_qty, ordered chronologically. Show
--     occurred_at, poster_qty, and the running total.

-- 8.2 Same idea, but per account — a running total of gloss_qty that
--     resets for each account instead of accumulating across the whole
--     company.



-- ======================================
-- SECTION 9 — RANKING
-- ======================================

-- 9.1 Leadership wants every account ranked by total lifetime spend. Show
--     account name, total spend, and its RANK(), DENSE_RANK(), and
--     ROW_NUMBER() — all three, so you can compare how they handle any
--     ties.

-- 9.2 For every sales rep, find their single largest managed account by
--     that account's total spend (i.e. rank the rep's accounts by spend,
--     keep only rank 1). Show rep name, account name, and total spend.



-- ======================================
-- SECTION 10 — LAG / LEAD
-- ======================================

-- 10.1 Is the number of web_events per month growing or shrinking? Show
--      month, event count, the previous month's event count, and the
--      change between them.



-- ======================================
-- SECTION 11 — STORED PROCEDURES
-- ======================================

-- 11.1 Create a procedure region_sales_report(IN reg_id INT) that, given a
--      region id, returns the total number of orders and total revenue
--      for every account in that region. Then call it for region 1.
--      (Remember: DELIMITER first.)

-- 11.2 Create a procedure get_account_count(OUT cnt INT) that returns the
--      total number of accounts in the database through an OUT parameter.
--      Call it, then select the result.



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

-- C4. Rank sales reps by total sales into quartile-style tiers using
--     NTILE(4) — a window function not covered in the walkthrough. (Hint:
--     NTILE(4) OVER (ORDER BY total_sales DESC) splits ranked rows into 4
--     roughly-equal buckets, numbered 1 [top] to 4 [bottom].) Show rep
--     name, total sales, and tier.
