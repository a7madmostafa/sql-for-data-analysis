-- ============================================================
-- SQL PRACTICE EXERCISES — Rawaj Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/rawaj_db.sql" once to create and load the database,
--      if you haven't already.
--   2. See "day05_reading.html" for window functions and DELIMITER syntax
--      for stored procedures.
--
-- Tables available: account_managers, governorates, sellers, brands,
-- categories, products, product_listings, customers, orders, order_items,
-- web_events, reviews, delivery_partners, shipments
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Rawaj
--   would actually ask. Write your query directly below each question,
--   then run it to check your answer. Try to solve each one WITHOUT
--   looking at the walkthrough first — use it afterwards only if you get
--   stuck. See day05_exercises_solutions.sql to check your answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — WINDOW FUNCTIONS: RUNNING TOTALS
-- ======================================

-- 1.1 Marketing wants to see cumulative discounts given out over time — a
--     running total of discount_amount, ordered chronologically. Show
--     order_date, discount_amount, and the running total.

-- 1.2 Same idea, but per customer — a running total of subtotal that
--     resets for each customer instead of accumulating across the whole
--     company.



-- ======================================
-- SECTION 2 — RANKING
-- ======================================

-- 2.1 Leadership wants every customer ranked by total lifetime spend. Show
--     customer name, total spend, and its RANK(), DENSE_RANK(), and
--     ROW_NUMBER() — all three, so you can compare how they handle any
--     ties.

-- 2.2 For every account manager, find their single largest customer by
--     that customer's total spend (i.e. rank the manager's customers by
--     spend, keep only rank 1). Show manager name, customer name, and
--     total spend.



-- ======================================
-- SECTION 3 — LAG / LEAD
-- ======================================

-- 3.1 Is the number of web_events per month growing or shrinking? Show
--     month, event count, the previous month's event count, and the
--     change between them.



-- ======================================
-- SECTION 4 — STORED PROCEDURES
-- ======================================

-- 4.1 Create a procedure governorate_sales_report(IN gov_id INT) that,
--     given a governorate id, returns the total number of orders and total
--     revenue for every customer in that governorate. Then call it for
--     governorate 1. (Remember: DELIMITER first.)

-- 4.2 Create a procedure get_customer_count(OUT cnt INT) that returns the
--     total number of customers in the database through an OUT parameter.
--     Call it, then select the result.



-- ======================================
-- CHALLENGE QUESTION
-- ======================================

-- C1. Rank account managers by total sales into quartile-style tiers using
--     NTILE(4) — a window function not covered in the walkthrough. (Hint:
--     NTILE(4) OVER (ORDER BY total_sales DESC) splits ranked rows into 4
--     roughly-equal buckets, numbered 1 [top] to 4 [bottom].) Show manager
--     name, total sales, and tier.
