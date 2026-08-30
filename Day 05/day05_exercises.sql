-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once
--      to create and load the database, if you haven't already.
--   2. See "day05_reading.html" for window functions and DELIMITER syntax
--      for stored procedures.
--
-- Tables available: region, sales_reps, accounts, orders, web_events
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Parch &
--   Posey would actually ask. Write your query directly below each
--   question, then run it to check your answer. Try to solve each one
--   WITHOUT looking at the walkthrough first — use it afterwards only if
--   you get stuck. See day05_exercises_solutions.sql to check your answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 1.1 Marketing wants to see poster-paper order volume build up over
--     time — a running total of poster_qty, ordered chronologically. Show
--     occurred_at, poster_qty, and the running total.

-- 1.2 Same idea, but per account — a running total of gloss_qty that
--     resets for each account instead of accumulating across the whole
--     company.



-- ======================================
-- SECTION 2 — RANKING
-- ======================================

-- 2.1 Leadership wants every account ranked by total lifetime spend. Show
--     account name, total spend, and its RANK(), DENSE_RANK(), and
--     ROW_NUMBER() — all three, so you can compare how they handle any
--     ties.

-- 2.2 For every sales rep, find their single largest managed account by
--     that account's total spend (i.e. rank the rep's accounts by spend,
--     keep only rank 1). Show rep name, account name, and total spend.



-- ======================================
-- SECTION 3 — LAG / LEAD
-- ======================================

-- 3.1 Is the number of web_events per month growing or shrinking? Show
--     month, event count, the previous month's event count, and the
--     change between them.



-- ======================================
-- SECTION 4 — STORED PROCEDURES
-- ======================================

-- 4.1 Create a procedure region_sales_report(IN reg_id INT) that, given a
--     region id, returns the total number of orders and total revenue
--     for every account in that region. Then call it for region 1.
--     (Remember: DELIMITER first.)

-- 4.2 Create a procedure get_account_count(OUT cnt INT) that returns the
--     total number of accounts in the database through an OUT parameter.
--     Call it, then select the result.



-- ======================================
-- CHALLENGE QUESTION
-- ======================================

-- C1. Rank sales reps by total sales into quartile-style tiers using
--     NTILE(4) — a window function not covered in the walkthrough. (Hint:
--     NTILE(4) OVER (ORDER BY total_sales DESC) splits ranked rows into 4
--     roughly-equal buckets, numbered 1 [top] to 4 [bottom].) Show rep
--     name, total sales, and tier.
