-- ============================================================
-- SQL PRACTICE EXERCISES — Rawaj Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/rawaj_db.sql" once to create and load the database,
--      if you haven't already.
--   2. See "day03_reading.html" for how JOIN syntax maps onto the
--      relationship types from Day 01, plus the full rawaj schema recap.
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
--   stuck. See day03_exercises_solutions.sql to check your answers.
--
--   No real subqueries or CTE syntax yet (that's Day 04) — Section 14 uses
--   a WITH block, but only as a light preview, the same way the walkthrough
--   does. Everything else is solvable with JOIN, GROUP BY, HAVING, CASE,
--   and string functions alone.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — INNER JOIN BASICS
-- ======================================

-- 1.1 Marketing wants a raw combined view: every web event alongside the
--     customer it came from, every column from both tables.

-- 1.2 For a cleaner report, pull just the event id, channel, and the
--     customer's first and last name.

-- 1.3 Using table aliases, show each event's channel and occurred_at, plus
--     the customer's email and governorate_id.



-- ======================================
-- SECTION 2 — MULTI-TABLE JOINS
-- ======================================

-- 2.1 Trace every web event back to the account manager responsible for
--     that customer's governorate — show the event id, channel, customer
--     name, and manager name.

-- 2.2 Regional leadership wants TOTAL revenue (not average), broken out by
--     account manager — chain all four tables together.

-- 2.3 Which customer placed the most recent order Rawaj has on record?
--     Show the customer's name and the order date (opposite of the
--     walkthrough's "first order ever").



-- ======================================
-- SECTION 3 — JOIN + GROUP BY
-- ======================================

-- 3.1 Rank account managers by total lifetime revenue across every
--     customer in their governorates, biggest earner first.

-- 3.2 For each governorate, break down web event counts by channel — which
--     governorate/channel combinations see the most traffic?

-- 3.3 What's the LARGEST order each customer has ever placed? List biggest
--     first.



-- ======================================
-- SECTION 4 — JOIN + HAVING
-- ======================================

-- 4.1 Which sellers have 3 or more product listings — worth flagging for a
--     "trusted multi-product seller" badge?

-- 4.2 Which customers have generated more than 30,000 EGP in revenue from
--     cash-on-delivery orders alone?

-- 4.3 Which account managers' TOTAL managed revenue — summed across every
--     customer in their governorates — comes in under 2,500,000 EGP? These
--     managers may need extra support.



-- ======================================
-- SECTION 5 — LEFT / RIGHT JOIN
-- ======================================

-- 5.1 Show every customer's id and name, plus the id of each order they've
--     placed (NULL where they've never ordered) — every customer should
--     appear, whether or not they have orders.

-- 5.2 Same idea, mirrored: for every order, show its id and total_amount,
--     plus the name of the customer it belongs to (same idea as 5.1,
--     opposite JOIN direction).



-- ======================================
-- SECTION 6 — ANTI-JOINS
-- ======================================

-- 6.1 How many customers have NEVER placed a single order? (Same anti-join
--     shape as the walkthrough — but return a single COUNT, not the full
--     list.)



-- ======================================
-- SECTION 7 — FULL JOIN (via UNION)
-- ======================================

-- 7.1 MySQL has no FULL JOIN keyword. Using UNION of a LEFT JOIN and a
--     RIGHT JOIN over two DISTINCT customer_id lists, build one report
--     pairing "placed an order" against "generated a web event" — matched,
--     order-only, and browse-only rows, all in one result. (Same shape as
--     the walkthrough — build it again yourself, from scratch.)



-- ======================================
-- SECTION 8 — CASE (basic)
-- ======================================

-- 8.1 Tag every order as 'Large' (total_amount >= 6000) or 'Small' (under
--     6000) — Finance wants to see the split. Show the order id, the
--     total, and the tag.

-- 8.2 Compute a safe shipping-fee percentage of subtotal for every order
--     (shipping_fee / subtotal * 100) — 0 instead of an error whenever
--     subtotal is 0 or missing.



-- ======================================
-- SECTION 9 — CASE + GROUP BY (binning / tiering)
-- ======================================

-- 9.1 Bucket every order into one of three size categories — 'At Least
--     10000', 'Between 4000 and 9999', or 'Less than 4000' (by
--     total_amount) — and count how many orders fall into each.

-- 9.2 Classify every customer into a lifetime-value tier: 'gold' (over
--     35,000 EGP total spend), 'silver' (over 15,000), or 'bronze'. Show
--     customer name, total spend, and tier, richest first.

-- 9.3 Repeat 9.2, but counting only spend from 2025 onward. Has anyone's
--     tier changed?

-- 9.4 Flag account managers as 'high-volume' if their governorates'
--     customers have placed more than 1,500 combined orders, 'standard'
--     otherwise. Show manager name, order count, and the flag, busiest
--     managers first.



-- ======================================
-- SECTION 10 — CASE + HAVING
-- ======================================

-- 10.1 Which customers fall specifically into the '15-30k' total-spend
--      bracket (bracket boundaries: ZERO / Under 15k [1-15000] / 15-30k
--      [15001-30000] / 30-45k [30001-45000] / +45k)? HAVING can filter on
--      the CASE-derived column directly, same as any other aggregate
--      expression.



-- ======================================
-- SECTION 11 — TRIMMING WHITESPACE
-- ======================================

-- 11.1 A spreadsheet import left extra spaces around some seller names.
--      Show every seller's id alongside their name run through TRIM.



-- ======================================
-- SECTION 12 — EXTRACTING PARTS OF A STRING
-- ======================================

-- 12.1 Ops wants a 3-letter seller code for a print report — the first 3
--      characters of each seller's name.

-- 12.2 Show every customer's email alongside just the domain part —
--      everything after the '@'.

-- 12.3 For every customer with an email, show the email and the character
--      position of the '@' symbol.



-- ======================================
-- SECTION 13 — BUILDING AND CLEANING STRINGS
-- ======================================

-- 13.1 Generate a simple URL slug for every seller: their shop name,
--      lowercased, with every space replaced by a hyphen (e.g. 'Cairo
--      Electronics' -> 'cairo-electronics').

-- 13.2 For a data-quality audit, show every seller's name, its length in
--      characters, and its uppercase version — longest names first.



-- ======================================
-- SECTION 14 — COALESCE / IFNULL
-- ======================================

-- 14.1 A dashboard buckets each customer's lifetime spend as 'under 20k'
--      (0 to 20,000) or '20k-40k' (20,001 to 40,000). Anything spending
--      more than that should show as 'unclassified' instead of blank/NULL.
--      (Hint: CASE only covers the two named buckets, then IFNULL fills
--      the gap — same pattern as the walkthrough's order-total buckets.)



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. For an exec presentation, list the top 5 customers by total
--     revenue, showing customer name, total revenue, their CASE-based tier
--     (gold/silver/bronze, per 9.2's thresholds), the account manager
--     responsible for them, and their governorate — all in one query.

-- C2. Which single governorate has generated the most total revenue
--     overall? Show the governorate name and total revenue.

-- C3. Find sellers who are BOTH a "high-catalog" seller (8 or more product
--     listings) AND have received at least 20 shipments — show
--     seller_name, listing count, and shipment count. (Hint: joining
--     sellers to both product_listings and shipments in one query
--     multiplies rows — COUNT(DISTINCT ...) on the listing id avoids
--     overcounting listings because of that fan-out.)

-- C4. Generate a contact slug (firstname-lastname, all lowercase) for
--     every "gold" tier customer — total spend over 35,000 EGP, same
--     threshold as 9.2's tiering. (Combine Section 13's string-building
--     with a JOIN + HAVING filter on total spend.)
