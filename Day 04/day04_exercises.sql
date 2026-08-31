-- ============================================================
-- SQL PRACTICE EXERCISES — Rawaj Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/rawaj_db.sql" once to create and load the database,
--      if you haven't already.
--   2. See "day04_reading.html" for how subqueries/CTEs/temp tables/views
--      relate to each other.
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
--   stuck. See day04_exercises_solutions.sql to check your answers.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — SCALAR SUBQUERIES
-- ======================================

-- 1.1 Which order(s) were placed on the very first day Rawaj ever received
--     an order? Show every column for those orders.

-- 1.2 Which orders sold for LESS than the company-wide average order
--     amount (total_amount) — these are the "bargain" orders. Show the
--     order id, customer id, and total_amount.

-- 1.3 Merchandising wants every product listing priced ABOVE the
--     marketplace-wide average listing price — candidates for a "premium"
--     badge. Show listing_id, product_id, and price.



-- ======================================
-- SECTION 2 — ROW SUBQUERIES
-- ======================================

-- 2.1 For each customer, find their very FIRST web event ever (earliest
--     occurred_at, opposite of the walkthrough's "most recent" version).
--     Show customer_id, occurred_at, and channel.



-- ======================================
-- SECTION 3 — DERIVED TABLES
-- ======================================

-- 3.1 What is the average order value, averaged across customers (i.e.
--     find each customer's own average total_amount first, then average
--     THOSE numbers together)? Use a subquery in FROM.

-- 3.2 Operations wants to know the average number of line items per order
--     (i.e. find each order's item count first, then average THOSE
--     numbers). Use a derived table in FROM, same pattern as 3.1.



-- ======================================
-- SECTION 4 — CTEs
-- ======================================

-- 4.1 Re-solve 3.1, but using a CTE (WITH ... AS) instead of a derived
--     table in FROM.

-- 4.2 Using a CTE, find the single account manager with the highest total
--     sales across every customer in their governorates. Show the
--     manager's id, name, and total sales.

-- 4.3 Using a CTE, find every seller whose average review rating (across
--     all their sold products) is BELOW the marketplace-wide average
--     rating — worth flagging for a quality check. Show seller_id and
--     their average rating.



-- ======================================
-- SECTION 5 — CHAINED CTEs
-- ======================================

-- 5.1 For that same top manager from 4.2, use a second CTE (chained off
--     the first) to show how many customers live in their governorates and
--     how many total orders those customers have placed combined.



-- ======================================
-- SECTION 6 — TEMPORARY TABLES
-- ======================================

-- 6.1 Materialize the top manager from 4.2 as a temporary table named
--     top_manager. Then run two SEPARATE queries against it: one showing
--     their total sales, one showing how many customers live in their
--     governorates (join top_manager to governorates to customers).



-- ======================================
-- SECTION 7 — VIEWS
-- ======================================

-- 7.1 Create a view called top5_managers, ranking account managers by
--     total sales across their governorates' customers, top 5 only. Then,
--     using that view, show how many web events came through each channel
--     for customers belonging to those top 5 managers' governorates.

-- 7.2 Create a view called active_listings, showing every product_listings
--     row with status = 'active', joined out to the seller's name and the
--     product's category name. Then query the view for a count of active
--     listings per category.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. Generate a contact slug (firstname-lastname, all lowercase) for
--     every customer whose lifetime spend is above the company-wide
--     average customer spend. (Combine Day 03's string-building with a
--     subquery filter like Section 1/4.)

-- C2. Using a CTE, find which governorate has the highest AVERAGE order
--     value per customer (not highest total — some governorates just have
--     more customers). Show governorate name and the average.

-- C3. Take the "top manager's customer/order counts" question from 5.1
--     and solve it a SECOND way, using a temporary table instead of
--     chained CTEs. Confirm both approaches return the same numbers — this
--     is the same intermediate-result idea, just materialized differently.
