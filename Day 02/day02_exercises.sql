-- ============================================================
-- SQL PRACTICE EXERCISES — Rawaj Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/rawaj_db.sql" once to create and load the database.
--   2. See "day02_reading.html" for
--      the table/column reference and relationships.
--
-- Tables available: customers, governorates, orders, web_events
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Rawaj
--   (Finance, Marketing, Growth leadership, Compliance...) would
--   actually ask. Translate the ask into a query yourself — the wording
--   won't hand you table/column names as directly as
--   day02_filtering_and_aggregation.sql did. Questions
--   get harder as sections progress, and later sections
--   deliberately combine techniques from earlier ones (WHERE + GROUP BY,
--   ORDER BY + LIMIT, etc.) — that's intentional, not a typo.
--
--   Write your query directly below each question, then run it to check
--   your answer. Try to solve each one WITHOUT looking at the walkthrough
--   first — use it afterwards only if you get stuck.
--
-- This is a practice bank, not a checklist — you are not expected to finish
-- every question in one sitting. Work through as many as time allows during
-- the session, then keep going on your own afterward. See
-- day02_exercises_solutions.sql to check your answers.
--
-- Section numbers below match the walkthrough exactly.
-- ============================================================

USE rawaj;


-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- 1.1 The VP of Growth wants a quick spot-check of the raw order data —
--     show her the first 10 orders, exactly as the table stores them.


-- 1.2 Marketing is auditing customers in batches of 5. Show them the second
--     batch: skip the first 15 customers, then return the next 5.


-- 1.3 Using the MySQL shortcut form (LIMIT offset, count), pull "page 5" of
--     web events, if each page holds 5 rows (i.e. rows 21–25).



-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- 2.1 How many governorates does Rawaj currently have customers in? List
--     them by ID.

-- 2.2 Marketing wants a list of every acquisition channel that has ever
--     driven a web event — no duplicates.

-- 2.3 Collapse that into a single number: how many distinct channels does
--     Rawaj track?

-- 2.4 Finance wants to know: how many distinct payment methods have ever
--     been used across all orders?



-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- 3.1 For a printed customer directory, list every customer alphabetically
--     by last name.

-- 3.2 Finance wants the biggest orders surfaced first — sort every order
--     by total_amount, highest to lowest.

-- 3.3 Show each customer's first_name and email, sorted by email — but
--     refer to the sort column by its POSITION in the SELECT list, not its
--     name.

-- 3.4 The growth team wants a roster: every customer grouped by
--     governorate (governorate_id ascending), and alphabetical by last
--     name within each governorate.

-- 3.5 Which 5 customers were added to the system most recently (highest
--     customer_id)? Show just their id and name, most recent first.



-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- 4.1 Finance needs the total count of orders Rawaj has ever placed.

-- 4.2 What's the range of order sizes we've ever seen — the smallest and
--     largest total_amount — in a single query?

-- 4.3 What's the average order value, rounded to the nearest cent?

-- 4.4 Leadership wants one summary row for a board slide: total number of
--     orders, total shipping fees collected, and total revenue — all in a
--     single query.



-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- 5.1 Which orders were unusually large — over 8,000 EGP?

-- 5.2 Show every web event that came from organic search traffic.

-- 5.3 Pull every customer registered in governorate 1, so ops can review
--     that region's customer base.

-- 5.4 Instagram ran a campaign last quarter — how many total web events
--     came through that channel?

-- 5.5 Customer 1 asked for a relationship summary: how many orders have
--     they placed, and what's their average order size?

-- 5.6 Find the total revenue (total_amount) generated from the 'facebook'
--     channel across all of web_events...
--     (hint: this one needs a table with a dollar amount — think about
--      whether web_events can answer this, and if not, explain why in a
--      comment instead of writing a query)

-- 5.7 What's the single largest order customer 2 has ever placed?

-- 5.8 Compliance is auditing high-value transactions. Show the 3 largest
--     orders customer 1 has ever placed, biggest first.



-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- The 'organic' channel dominates web_events and drowns out everything
-- else in a quick eyeball scan. Filter it out three different ways:

-- 6.1 Using !=

-- 6.2 Using <>

-- 6.3 Using the NOT keyword



-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- 7.1 Which of customer 1's orders were worth more than 3,000 EGP?

-- 7.2 Marketing wants a broad net: any web event that's either on the
--     Instagram channel, OR belongs to customer_id = 2 (regardless of
--     channel).

-- 7.3 Finance wants a "clean, high-value, card-paid" order segment: find
--     every order that was paid by credit card, AND was delivered, AND was
--     worth more than 5,000 EGP.



-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- 8.1 Marketing defines a "mid-size order" as 5,000–9,999 EGP inclusive.
--     Find them WITHOUT using BETWEEN.

-- 8.2 Rewrite the query above USING BETWEEN.

-- 8.3 Finance is auditing discounted orders: find every order whose
--     discount_amount falls between 100 and 500 EGP.

-- 8.4 Show every order placed in the final stretch of 2024 — from
--     December 25 through New Year's Day 2025.



-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- 9.1 List every web event whose channel is 'facebook', 'instagram', or
--     'google' — using OR.

-- 9.2 Rewrite the query above using IN.

-- 9.3 Compliance wants records for three specific customers by id: 10, 20,
--     30. Pull every order they've placed, using IN.

-- 9.4 A regional director wants everything EXCEPT two legacy channels —
--     'direct' and 'google'. Use NOT IN to filter them out.



-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- 10.1 Write a query that returns customers with a missing email — these
--      are the ones we can't send an order receipt to automatically.

-- 10.2 Write a query that returns customers where email IS NOT NULL.

-- 10.3 Data-quality check: how many customers, if any, are missing an
--      email?



-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- 11.1 Find every customer whose first name starts with the letter 'M'.

-- 11.2 Search for a specific family-name pattern: customers whose last
--      name contains 'El' anywhere.

-- 11.3 Data entry flagged a possible duplicate: find any customer whose
--      first name is exactly 6 characters long, with 'a' as the second
--      letter.

-- 11.4 Find every web event whose channel begins with the letter 'o'.

-- 11.5 Domain audit: how many customers have a Gmail address specifically?



-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- 12.1 Marketing wants a channel breakdown: how many web events came
--      through each channel?

-- 12.2 How many customers are registered in each governorate? This flags
--      which regions to prioritize for new sellers.

-- 12.3 For customer 1 specifically, break down their web events by
--      channel.

-- 12.4 Which 5 customers have placed the most orders? Rank them, most
--      orders first.

-- 12.5 Leadership wants a customer-level scorecard: for every customer_id,
--      show number of orders, average order value, and total revenue —
--      ranked by total revenue, biggest spenders first.

-- 12.6 For each channel, find the very first event ever recorded and the
--      most recent one — useful for spotting channels that have gone
--      quiet.

-- 12.7 For three specific customers (1, 2, 3), break down web event counts
--      by both customer_id and channel — one row per customer/channel
--      combination.



-- ======================================
-- SECTION 13 — HAVING
-- ======================================

-- 13.1 Which governorates have 200 or more registered customers?

-- 13.2 Which customers have placed more than 8 orders — Rawaj's very top
--      repeat buyers?

-- 13.3 Which customers have spent more than 40,000 EGP total, across every
--      order they've ever placed?

-- 13.4 Looking only at orders placed in 2023, which customers spent more
--      than 10,000 EGP that year? (Combine WHERE and HAVING in one query.)



-- ======================================
-- SECTION 14 — DATE Functions
-- ======================================

-- 14.1 Show the 5 busiest single calendar dates in Rawaj's history, by
--      number of orders placed.

-- 14.2 What's the earliest year and the latest year Rawaj has order data
--      for?

-- 14.3 Finance wants total revenue by year, ordered chronologically, to
--      see the company's growth trend.

-- 14.4 Leadership suspects Ramadan is the strongest stretch every year.
--      Test that more generally: total revenue by month across all years,
--      ranked highest first.

-- 14.5 Customer service wants to know: in which month and year did our
--      second-highest-spending customer, Nour Fahmy, spend the most, in
--      total dollar terms? (You'll need a JOIN to get from customer name
--      to orders — same pattern used in the walkthrough.)

-- 14.6 Customer service promises delivery within 7 days of the order date.
--      For the 10 most recent orders, show the order id, order date, and
--      expected delivery date.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. Find the top 5 customers by total revenue (SUM of total_amount),
--     showing customer_id and total revenue, highest first.

-- C2. Which single order is the largest Rawaj has ever received? Show the
--     customer_id and the order total.

-- C3. Using a JOIN, answer C2 again — but show the customer's first and
--     last NAME instead of just their id.

-- C4. Using a JOIN, answer C1 again — but rank the top 5 customers by name
--     instead of customer id, ready to drop into an exec presentation.
