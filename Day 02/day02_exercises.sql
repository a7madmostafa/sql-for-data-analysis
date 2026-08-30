-- ============================================================
-- SQL PRACTICE EXERCISES — Parch & Posey Database
-- ============================================================
-- Before starting:
--   1. Run "Databases/Parch & Posey Database.sql" once to create and load the database.
--   2. See "day02_reading.html" for
--      the table/column reference and relationships.
--
-- Tables available: region, sales_reps, accounts, orders, web_events
--
-- Instructions:
--   Every question is framed as something a real stakeholder at Parch &
--   Posey (Finance, Marketing, Sales leadership, Compliance...) would
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

USE parch_and_posey;


-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- 1.1 The VP of Sales wants a quick spot-check of the raw order data —
--     show her the first 10 orders, exactly as the table stores them.


-- 1.2 Marketing is auditing accounts in batches of 5. Show them the second
--     batch: skip the first 15 accounts, then return the next 5.


-- 1.3 Using the MySQL shortcut form (LIMIT offset, count), pull "page 5" of
--     web events, if each page holds 5 rows (i.e. rows 21–25).



-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- 2.1 How many regions does the company operate sales reps in? List them
--     by name.

-- 2.2 Marketing wants a list of every acquisition channel that has ever
--     driven a web event — no duplicates.

-- 2.3 Collapse that into a single number: how many distinct channels does
--     the company track?

-- 2.4 HR wants to know: out of everyone with at least one account assigned
--     to them, how many distinct sales reps is that?



-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- 3.1 For a printed client directory, list every account alphabetically by
--     name.

-- 3.2 Finance wants the biggest orders surfaced first — sort every order
--     by total_amt_usd, highest to lowest.

-- 3.3 Show each account's name and website, sorted by website — but refer
--     to the sort column by its POSITION in the SELECT list, not its name.

-- 3.4 Regional directors want a roster: every sales rep grouped by region
--     (region_id ascending), and alphabetical by name within each region.

-- 3.5 Which 5 accounts were added to the system most recently (highest
--     account id)? Show just their id and name, most recent first.



-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- 4.1 Finance needs the total count of orders the company has ever placed.

-- 4.2 What's the range of order sizes we've ever seen — the smallest and
--     largest total_amt_usd — in a single query?

-- 4.3 What's the average order value, rounded to the nearest cent?

-- 4.4 Leadership wants one summary row for a board slide: total number of
--     orders, total units of standard paper sold, and total revenue —
--     all in a single query.



-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- 5.1 Which orders were unusually large — over $2,000?

-- 5.2 Show every web event that came from organic search traffic.

-- 5.3 Pull every account currently assigned to sales rep 321500, so they
--     can review their book of business.

-- 5.4 Twitter ran a campaign last quarter — how many total web events came
--     through that channel?

-- 5.5 Walmart (account_id = 1001) asked for a relationship summary: how
--     many orders have they placed, and what's their average order size?

-- 5.6 Find the total revenue (total_amt_usd) generated from the 'facebook'
--     channel across all of web_events...
--     (hint: this one needs a table with a dollar amount — think about
--      whether web_events can answer this, and if not, explain why in a
--      comment instead of writing a query)

-- 5.7 What's the single largest order account_id 1021 has ever placed?

-- 5.8 Compliance is auditing high-value transactions. Show the 3 largest
--     orders account_id = 1001 has ever placed, biggest first.



-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- The 'direct' channel dominates web_events and drowns out everything
-- else in a quick eyeball scan. Filter it out three different ways:

-- 6.1 Using !=

-- 6.2 Using <>

-- 6.3 Using the NOT keyword



-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- 7.1 Which of Walmart's (account_id = 1001) orders were worth more than
--     $1,000?

-- 7.2 Marketing wants a broad net: any web event that's either on the
--     Twitter channel, OR belongs to account_id = 1011 (regardless of
--     channel).

-- 7.3 Full-basket orders: find every order where the client bought some
--     of every paper type — standard AND gloss AND poster (i.e. all three
--     quantity columns are greater than zero).



-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- 8.1 Marketing defines a "mid-size order" as $1,000–$2,000 inclusive.
--     Find them WITHOUT using BETWEEN.

-- 8.2 Rewrite the query above USING BETWEEN.

-- 8.3 Territory audit: find every account whose sales_rep_id falls between
--     321700 and 321800.

-- 8.4 Show every order placed in the final stretch of 2014 — from
--     December 25 through New Year's Day 2015.



-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- 9.1 List every web event whose channel is 'facebook', 'twitter', or
--     'banner' — using OR.

-- 9.2 Rewrite the query above using IN.

-- 9.3 Compliance wants records for three specific sales reps by id:
--     321500, 321510, 321520. Pull every account they manage, using IN.

-- 9.4 A regional director wants everything EXCEPT three legacy channels —
--     'direct', 'banner', and 'organic'. Use NOT IN to filter them out.



-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- 10.1 Write a query that would return accounts with a missing website.
--      (Run it — how many rows come back, and why?)

-- 10.2 Write a query that returns accounts where primary_poc IS NOT NULL.

-- 10.3 Data-quality check: how many accounts, if any, are missing a
--      primary point of contact?



-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- 11.1 Find every account whose name starts with the letter 'M' — could
--      be a client with several regional divisions.

-- 11.2 Search for potential holding companies: accounts whose name
--      contains the word 'Group' anywhere.

-- 11.3 Data entry flagged a possible duplicate: find any account whose
--      name is exactly 5 characters long, with 'o' as the second letter.

-- 11.4 Find every web event whose channel begins with the letter 'a'.

-- 11.5 Domain audit: how many accounts have '.com' anywhere in their
--      website URL?



-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- 12.1 Marketing wants a channel breakdown: how many web events came
--      through each channel?

-- 12.2 How many accounts does each sales rep manage? This flags who's
--      overloaded and who has room for more clients.

-- 12.3 For Walmart (account_id = 1001) specifically, break down their web
--      events by channel.

-- 12.4 Which region has the most sales reps? Rank every region from most
--      reps to fewest.

-- 12.5 Leadership wants an account-level scorecard: for every account_id,
--      show number of orders, average order value, and total revenue —
--      ranked by total revenue, biggest spenders first.

-- 12.6 For each channel, find the very first event ever recorded and the
--      most recent one — useful for spotting channels that have gone
--      quiet.

-- 12.7 For the three flagship accounts (1001, 1011, 1021), break down web
--      event counts by both account_id and channel — one row per
--      account/channel combination.



-- ======================================
-- SECTION 13 — HAVING
-- ======================================

-- 13.1 Which sales reps currently manage 10 or more accounts?

-- 13.2 Which accounts have placed more than 60 orders — the company's
--      very top repeat buyers?

-- 13.3 Which accounts have spent more than $100,000 total, across every
--      order they've ever placed?

-- 13.4 Looking only at orders placed in 2015, which accounts spent more
--      than $20,000 that year? (Combine WHERE and HAVING in one query.)



-- ======================================
-- SECTION 14 — DATE Functions
-- ======================================

-- 14.1 Show the 5 busiest single calendar dates in company history, by
--      number of orders placed.

-- 14.2 What's the earliest year and the latest year the company has order
--      data for?

-- 14.3 Finance wants total revenue by year, ordered chronologically, to
--      see the company's growth trend.

-- 14.4 Leadership suspects Q4 (Oct–Dec) is the strongest stretch every
--      year. Test that more generally: total revenue by month across all
--      years, ranked highest first.

-- 14.5 Walmart's team wants to know: in which month and year did they
--      spend the most on STANDARD paper specifically? (You'll need a JOIN
--      to get from account name to orders — same pattern used in the
--      walkthrough for their gloss-paper spend.)

-- 14.6 Customer service promises delivery within 7 days of the order date.
--      For the 10 most recent orders, show the order id, order date, and
--      expected delivery date.



-- ======================================
-- CHALLENGE QUESTIONS (combine multiple concepts)
-- ======================================

-- C1. Find the top 5 accounts by total revenue (SUM of total_amt_usd),
--     showing account_id and total revenue, highest first.

-- C2. Which single order is the largest the company has ever received?
--     Show the account_id and the order total.

-- C3. Using a JOIN, answer C2 again — but show the account NAME instead
--     of just its id.

-- C4. Using a JOIN, answer C1 again — but rank the top 5 clients by
--     account NAME instead of account id, ready to drop into an exec
--     presentation.
