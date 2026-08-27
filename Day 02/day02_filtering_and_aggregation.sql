USE parch_and_posey;

-- Before analyzing order data, check what columns are actually available to work with
DESCRIBE orders;

-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- Quick sanity check that the client is connected and running queries at all (no FROM clause needed)
SELECT "Hello World" AS Welcome;

-- Confirm basic arithmetic works in a SELECT before trusting it inside a real calculation
SELECT 10/5;

-- Pull every order on file, no filtering yet — see the full shape of the raw data (compare to the versions below)
SELECT *
FROM orders;

-- The sales team only wants to preview "page 2" of results — skip the first 10 orders, show the next 2
SELECT *
FROM orders
LIMIT 2 OFFSET 10;

-- Same "page 2" request, MySQL-style shortcut:
-- LIMIT offset, number_of_rows — skip 10 rows, then return 2 rows
SELECT *
FROM orders
LIMIT 10, 2;

-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- Marketing wants to know which channels actually drive traffic — list every unique channel
SELECT DISTINCT channel
FROM web_events;

-- And in total, how many different channels are being used?
SELECT COUNT(DISTINCT channel) AS channels_cnt
FROM web_events;


-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- Give the sales team an alphabetical account directory
SELECT *
FROM accounts
ORDER BY name;

-- Which orders were the biggest, in dollar terms?
SELECT *
FROM orders
ORDER BY total_amt_usd DESC;

-- Same "biggest orders first" question, referenced by column position instead of name (3 = total_amt_usd)
SELECT id, total, total_amt_usd
FROM orders
ORDER BY 3 DESC;

-- Group the account list by sales rep, highest rep ID first, for a quick rep-assignment review (2 = sales_rep_id)
SELECT name, sales_rep_id, primary_poc
FROM accounts
ORDER BY 2 DESC;


-- Organize accounts by sales rep, and alphabetize (reverse) within each rep's book of accounts
SELECT *
FROM accounts
ORDER BY sales_rep_id ASC, name DESC;


-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- How many orders has Parch & Posey processed in total?
SELECT COUNT(id) AS Orders_count
FROM orders;

-- How many of those orders actually have a recorded dollar total? (COUNT ignores NULLs, unlike COUNT(*))
SELECT COUNT(total_amt_usd) AS Non_Null_count
FROM orders;

-- What's the smallest order Parch & Posey has ever received?
SELECT MIN(total_amt_usd) AS MinOrderTotal
FROM orders;

-- What's the average order size, across every order on record?
SELECT AVG(total_amt_usd) AS AvgOrderTotal
FROM orders;

-- Finance wants one summary row: order count, smallest, biggest, average, and total revenue, all at once
SELECT
    COUNT(total_amt_usd) AS OrderCount,     		-- Number of non-null order totals
    MIN(total_amt_usd) AS MinTotal,         		-- Lowest order total
    MAX(total_amt_usd) AS MaxTotal,         		-- Highest order total
    ROUND(AVG(total_amt_usd), 2) AS AvgTotal,  	    -- Rounded average order total
    SUM(total_amt_usd) AS TotalRevenue        		-- Total revenue
FROM orders;


-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- Which orders were worth more than $100,000 — the company's biggest deals?
SELECT *
FROM orders
WHERE total_amt_usd > 100000
ORDER BY total_amt_usd DESC;

-- Pull every order placed before 2015, for a look back at the company's earliest years
SELECT *
FROM orders
WHERE occurred_at < "2015-01-01"
ORDER BY occurred_at;


-- Which web events came in through Facebook specifically?
SELECT *
FROM web_events
WHERE channel = 'facebook';

-- Which web events came in through direct traffic (no referral) instead?
SELECT *
FROM web_events
WHERE channel = 'direct';

-- How many web events, in total, came through Facebook?
SELECT COUNT(*) AS Facebook_cnt
FROM web_events
WHERE channel = 'facebook';

-- How many orders has Walmart (account 1001) placed, and what's their average order size?
SELECT 	COUNT(total_amt_usd) AS No_of_Orders,
		AVG(total_amt_usd) AS AvgOrderTotal
FROM orders
WHERE account_id = 1001;

-- Same question, for a different account (1011)
SELECT  COUNT(total_amt_usd) AS Orders_1011,
		AVG(total_amt_usd) AS AvgOrderTotal
FROM orders
WHERE account_id = 1011;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- Every order EXCEPT those from Walmart (account 1001) — useful when you want to exclude one big customer from a report
SELECT *
FROM orders
WHERE account_id != 1001;

-- Same exclusion, standard SQL spelling (<>)
SELECT *
FROM orders
WHERE account_id <> 1001;

-- Same exclusion again, using the NOT keyword instead
SELECT *
FROM orders
WHERE NOT account_id = 1001;


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- Did Walmart specifically generate any Facebook traffic?
SELECT *
FROM web_events
WHERE channel = 'facebook'
AND account_id = 1001;

-- Now cast a much wider net: everything Facebook overall, plus everything from Walmart, regardless of channel
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR account_id = 1001;


-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- Which orders fall in the mid-size $500-$999 range, written with plain AND logic?
SELECT *
FROM orders
WHERE total_amt_usd < 1000
AND total_amt_usd >= 500;

-- Same $500-$999 question, written the shorter way with BETWEEN (inclusive on both ends)
SELECT *
FROM orders
WHERE total_amt_usd BETWEEN 500 AND 999;

-- Which orders came in during the final two days of 2014 — useful for a year-end cutoff report?
SELECT *
FROM orders
WHERE occurred_at BETWEEN "2014-12-30" AND "2015-01-01";


-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- Marketing wants every event from Facebook, Twitter, or organic search — written the long way with OR
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR channel = 'twitter'
OR channel = 'organic';

-- Same three-channel question, written the cleaner way with IN
SELECT *
FROM web_events
WHERE channel IN ('facebook','twitter', 'organic');

-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- Compliance wants a list of accounts missing a primary point of contact
-- (Parch & Posey has no NULLs, so this returns 0 rows — the syntax still applies
--  to any table/column where NULLs do exist)
SELECT *
FROM accounts
WHERE primary_poc IS NULL;

-- And the opposite: accounts that DO have a point of contact on file
-- (returns every row here, since primary_poc is always populated)
SELECT *
FROM accounts
WHERE primary_poc IS NOT NULL;


-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- Which accounts have a name starting with the letter A — useful for an alphabetized client directory page?
SELECT *
FROM accounts
WHERE name LIKE 'A%';

-- % means any number of characters, zero or more

-- Which accounts have the letter 'a' anywhere in their name?
SELECT *
FROM accounts
WHERE name LIKE '%a%';

-- Which accounts have 'a' as the second letter of their name?
SELECT *
FROM accounts
WHERE name LIKE '_a%';

-- _ means exactly one character

-- Which accounts have a 5-character name with 'a' as the second letter — a narrower pattern-matching example?
SELECT *
FROM accounts
WHERE name LIKE '_a___';

-- Which web traffic channels have names ending in 'ct' (like 'direct')?
SELECT *
FROM web_events
WHERE channel LIKE '%ct';


-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- Which marketing channel drives the most web traffic overall?
SELECT channel, COUNT(channel) AS Cnt
FROM web_events
GROUP BY channel
ORDER BY Cnt DESC;


-- Which channels does Walmart specifically use most — what are their top 3?
SELECT channel, COUNT(*) AS Cnt
FROM web_events
WHERE account_id = 1001
GROUP BY channel
ORDER BY Cnt DESC
LIMIT 3;

-- How much web activity did each of these three key accounts (1001, 1011, 1021) generate?
SELECT account_id, COUNT(account_id) AS Cnt
FROM web_events
WHERE account_id IN (1001,1011,1021)
GROUP BY account_id
ORDER BY account_id ASC;


-- For those same three accounts, break the activity down by channel too — which channel does each account favor?
SELECT account_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE account_id IN (1001,1011,1021)
GROUP BY account_id, channel
ORDER BY account_id ASC;

-- Now narrow that same view to just organic and paid-search (adwords) traffic
SELECT account_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND account_id IN (1001,1011,1021)
GROUP BY account_id, channel;


-- How many sales reps are assigned to each region, most-staffed region first?
SELECT region_id, COUNT(*) AS Cnt
FROM sales_reps
GROUP BY region_id
ORDER BY Cnt DESC;

-- Same headcount-per-region question, using COUNT(region_id) instead of COUNT(*), unordered
SELECT region_id, COUNT(region_id) AS Cnt
FROM sales_reps
GROUP BY region_id;

-- How many accounts does each sales rep manage, lightest workload first?
SELECT sales_rep_id, COUNT(*) AS Cnt
FROM accounts
GROUP BY sales_rep_id
ORDER BY Cnt ASC;


-- Same channel-traffic question as Section 12's first query, just reformatted for a shared report
SELECT
    channel,
    COUNT(*) AS EventCount
FROM web_events
GROUP BY channel
ORDER BY EventCount DESC;

-- For 2014 specifically, which accounts ordered the most, and what did their orders look like on average?
SELECT
    account_id,
    COUNT(*) AS OrderCount,
    AVG(total_amt_usd) AS AvgTotal,
    SUM(total_amt_usd) AS SumTotal,
    MIN(total_amt_usd) AS MinTotal,
    MAX(total_amt_usd) AS MaxTotal
FROM orders
WHERE occurred_at LIKE "2014%"
GROUP BY account_id
ORDER BY OrderCount DESC;

-- For comparison, how many orders exist across ALL years combined, not just 2014?
SELECT COUNT(*) AS OrderCount
FROM orders;

-- Same per-account order stats as above, but across every year, sorted by average order size (3 = AvgTotal)
SELECT
    account_id,
    COUNT(*) AS OrderCount,
    AVG(total_amt_usd) AS AvgTotal,
    SUM(total_amt_usd) AS SumTotal,
    MIN(total_amt_usd) AS MinTotal,
    MAX(total_amt_usd) AS MaxTotal
FROM orders
GROUP BY account_id
ORDER BY 3 DESC;

-- Same stats again, resorted by account ID instead of average size, for a tidy lookup table
SELECT
	account_id,
    COUNT(*) AS OrderCount,
    AVG(total_amt_usd) AS AvgTotal,
    SUM(total_amt_usd) AS SumTotal,
    MIN(total_amt_usd) AS MinTotal,
    MAX(total_amt_usd) AS MaxTotal
FROM orders
GROUP BY account_id
ORDER BY account_id;


-- For those three key accounts, when was each channel first and last used, and how often?
SELECT
	account_id, channel,
    COUNT(*) AS EventCount,
    MIN(occurred_at) AS FirstEvent,
    MAX(occurred_at) AS LastEvent
FROM web_events
WHERE account_id IN (1001,1011,1021)
GROUP BY account_id, channel
ORDER BY account_id;


-- ======================================
-- SECTION 13 — DATE Functions
-- for REF : https://www.w3schools.com/sql/func_mysql_date.asp
-- ======================================

-- Which single dates had the most orders — were there any spike days worth investigating?
SELECT
    DATE(occurred_at) AS order_date,
    COUNT(*) num_orders
FROM orders
GROUP BY order_date
ORDER BY num_orders DESC
LIMIT 10 ;

-- =======================================================================================================================================

-- Ops wants every order's timestamp broken into year, month, day, and hour for a custom reporting tool

SELECT
    id,
    occurred_at,
    YEAR(occurred_at) AS 'year',
    MONTH(occurred_at) AS 'month',
    DAY(occurred_at) AS 'day',
    HOUR(occurred_at) AS 'hour'
FROM orders;

-- Which years does this dataset actually cover?
SELECT DISTINCT(YEAR(occurred_at)) Years
FROM orders
ORDER BY Years;

-- What's the very first year of data on record?
SELECT Min(YEAR(occurred_at)) MIN_Yr
FROM orders;

-- What's the most recent year of data on record?
SELECT MAX(YEAR(occurred_at)) MAX_Yr
FROM orders;

-- What are the exact earliest and latest order dates in the dataset?
SELECT
	Min(DATE(occurred_at)) MIN_Date,
	MAX(DATE(occurred_at)) MAX_Date
FROM orders;

-- How has total revenue trended year over year?
SELECT
    year(occurred_at) AS OrderYear,
    SUM(total_amt_usd) TOTALRev
FROM orders
GROUP BY OrderYear
ORDER BY TOTALRev ;

-- =======================================================================================================================================

-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
-- Do you notice any trends in the yearly sales totals?

-- Using YEAR() — note: ordered ascending here, opposite of the two variants below
SELECT YEAR(occurred_at) ord_year,
		SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 ASC;

-- Same question, using EXTRACT(YEAR FROM ...) instead of YEAR()
SELECT
	EXTRACT(YEAR FROM occurred_at) ord_year,
	SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Same question again, using DATE_FORMAT(occurred_at, '%Y') instead of YEAR()
SELECT
	DATE_FORMAT(occurred_at,'%Y') ord_year,
    SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- =======================================================================================================================================

-- Which year did Parch & Posey have the greatest sales in terms of total number of orders?
-- Are all years evenly represented by the dataset?

SELECT YEAR(occurred_at) ord_year,  COUNT(*) Orders_cnt
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- =======================================================================================================================================

-- Which month did Parch & Posey have the greatest sales in terms of total dollars?
-- Are all months evenly represented by the dataset?

-- Filtered to 2014–2016 (excludes the partial 2013/2017 data) to avoid skewing the month totals
SELECT
	MONTH(occurred_at) ord_month,
    SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

-- How evenly is the data actually spread across each year — are some months missing entirely?
SELECT YEAR(occurred_at) ord_year,
		COUNT(DISTINCT MONTH(occurred_at)) No_of_Months
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Same evenness check, at the day level instead of month
SELECT YEAR(occurred_at) ord_year,
		COUNT(DISTINCT DAY(occurred_at)) No_of_Days
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- =======================================================================================================================================

-- Pull every order from Q1 2015 specifically, for a quarterly review

SELECT *
FROM orders
WHERE MONTH(occurred_at) BETWEEN 1 AND 3
AND YEAR(occurred_at) = 2015;

-- =======================================================================================================================================

-- Which calendar month (Jan, Feb, ...) generates the most total sales, combined across every year?
SELECT
    MONTHNAME(occurred_at) AS month_name,
    SUM(total_amt_usd) total_sales
FROM orders
GROUP BY month_name;

-- =======================================================================================================================================

-- Which day of the week has the highest total sales?
SELECT
    DAYNAME(occurred_at) AS day_name,
    SUM(total_amt_usd) total_sales
FROM orders
GROUP BY day_name
ORDER BY total_sales DESC;

-- =======================================================================================================================================

--  In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
--  (first JOIN in this script — links orders to accounts to filter by name)

SELECT DATE_FORMAT(occurred_at,'%Y-%m') ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o
JOIN accounts a
	ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- =======================================================================================================================================

-- Ops needs an expected delivery date for every order — 7 days after it was placed
SELECT
    id,
    DATE(occurred_at) order_date,
    DATE_ADD(DATE(occurred_at), INTERVAL 7 DAY) AS expected_delivery
FROM orders;

-- Quick reference: what does MySQL consider "today" on this server?
SELECT CURDATE();

-- Quick reference: current date and time, for timestamping something happening right now
SELECT NOW();

-- If an order were placed today, what would its 7-day delivery date be?
SELECT DATE_ADD(CURDATE(), INTERVAL 7 DAY) Delivery
