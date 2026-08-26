USE parch_and_posey;

-- Preview the orders table's columns and types before querying it
DESCRIBE orders;

-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- Return a literal string (no FROM clause needed)
SELECT "Hello World" AS Welcome;

-- Basic arithmetic in a SELECT
SELECT 10/5;


-- Get every row from the orders table (no LIMIT yet — compare to the versions below)
SELECT *
FROM orders;

-- Skip the first 10 rows, then return the next 2 rows
-- Useful for pagination
SELECT *
FROM orders
LIMIT 2 OFFSET 10;

-- MySQL-style shortcut:
-- LIMIT offset, number_of_rows
-- Skip 10 rows, then return 2 rows
SELECT *
FROM orders
LIMIT 10, 2;

-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- Get unique marketing channels only (no duplicates)
SELECT DISTINCT channel
FROM web_events;

-- Count how many distinct channels exist
SELECT COUNT(DISTINCT channel) AS channels_cnt
FROM web_events;


-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- Sort accounts alphabetically by name (ASC is default)
SELECT *
FROM accounts
ORDER BY name;

-- Sort orders by total_amt_usd
SELECT *
FROM orders
ORDER BY total_amt_usd DESC;

-- Sort by column position instead of name (3 = total_amt_usd)
SELECT id, total, total_amt_usd
FROM orders
ORDER BY 3 DESC;

-- Sort accounts by sales_rep_id, referenced by column position (2 = sales_rep_id)
SELECT name, sales_rep_id, primary_poc
FROM accounts
ORDER BY 2 DESC;


-- Sort by sales_rep_id ascending, and within each rep sort by name descending
SELECT *
FROM accounts
ORDER BY sales_rep_id ASC, name DESC;


-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- Count total number of orders
SELECT COUNT(id) AS Orders_count
FROM orders;

-- Count only non-null order totals (COUNT ignores NULLs, unlike COUNT(*))
SELECT COUNT(total_amt_usd) AS Non_Null_count
FROM orders;

-- Get the smallest order total from the orders table
SELECT MIN(total_amt_usd) AS MinOrderTotal
FROM orders;

-- Get the average order total
SELECT AVG(total_amt_usd) AS AvgOrderTotal
FROM orders;

-- Multiple aggregate calculations in one query
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

-- Get orders worth more than 100,000 USD
SELECT *
FROM orders
WHERE total_amt_usd > 100000
ORDER BY total_amt_usd DESC;

-- Get orders before 2015
SELECT *
FROM orders
WHERE occurred_at < "2015-01-01"
ORDER BY occurred_at;


-- Get all web events that came through Facebook
SELECT *
FROM web_events
WHERE channel = 'facebook';

-- Get all web events that came through direct traffic
SELECT *
FROM web_events
WHERE channel = 'direct';

-- Count number of Facebook web events
SELECT COUNT(*) AS Facebook_cnt
FROM web_events
WHERE channel = 'facebook';

-- Order count and average order total for the Walmart account (account_id = 1001)
SELECT 	COUNT(total_amt_usd) AS No_of_Orders,
		AVG(total_amt_usd) AS AvgOrderTotal
FROM orders
WHERE account_id = 1001;

-- Order count and average order total for account_id = 1011
SELECT  COUNT(total_amt_usd) AS Orders_1011,
		AVG(total_amt_usd) AS AvgOrderTotal
FROM orders
WHERE account_id = 1011;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- All orders except those placed through account_id = 1001
SELECT *
FROM orders
WHERE account_id != 1001;

-- Same as above (<> is standard SQL)
SELECT *
FROM orders
WHERE account_id <> 1001;

-- Same logic using NOT keyword
SELECT *
FROM orders
WHERE NOT account_id = 1001;


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- Facebook web events for account_id = 1001
SELECT *
FROM web_events
WHERE channel = 'facebook' 
AND account_id = 1001;

-- Web events that are Facebook OR for account_id = 1001
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR account_id = 1001;


-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- Orders worth between 500 (inclusive) and 999
SELECT *
FROM orders
WHERE total_amt_usd < 1000
AND total_amt_usd >= 500;

-- Same logic using BETWEEN (inclusive)
SELECT *
FROM orders
WHERE total_amt_usd BETWEEN 500 AND 999;

-- All orders for the last 2 days in 2014
SELECT *
FROM orders
WHERE occurred_at BETWEEN "2014-12-30" AND "2015-01-01";


-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- Using OR (less readable for many values)
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR channel = 'twitter'
OR channel = 'organic';

-- Same logic using IN (recommended)
SELECT *
FROM web_events
WHERE channel IN ('facebook','twitter', 'organic');

-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- Accounts where a primary point of contact is missing
-- (Parch & Posey has no NULLs, so this returns 0 rows — the syntax still applies
--  to any table/column where NULLs do exist)
SELECT *
FROM accounts
WHERE primary_poc IS NULL;

-- Accounts where a primary point of contact is available
-- (returns every row here, since primary_poc is always populated)
SELECT *
FROM accounts
WHERE primary_poc IS NOT NULL;


-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- Account name starts with letter A
SELECT *
FROM accounts
WHERE name LIKE 'A%';

-- % means any number of characters greater than or equal to 0

-- Account name contains letter a anywhere
SELECT *
FROM accounts
WHERE name LIKE '%a%';

-- Account name with a as a second character
SELECT *
FROM accounts
WHERE name LIKE '_a%';

-- _ means only one character

-- Account name exactly 5 characters long, with 'a' as the 2nd character
SELECT *
FROM accounts
WHERE name LIKE '_a___';

-- Web events channels ending with 'ct' (e.g. 'direct')
SELECT *
FROM web_events
WHERE channel LIKE '%ct';


-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- Count web events by channel
SELECT channel, COUNT(channel) AS Cnt
FROM web_events
GROUP BY channel
ORDER BY Cnt DESC;


-- Count web events per channel, for the Walmart account only
SELECT channel, COUNT(*) AS Cnt
FROM web_events
WHERE account_id = 1001
GROUP BY channel
ORDER BY Cnt DESC
LIMIT 3;

-- Number of events for accounts (1001, 1011, 1021)
SELECT account_id, COUNT(account_id) AS Cnt
FROM web_events
WHERE account_id IN (1001,1011,1021)
GROUP BY account_id
ORDER BY account_id ASC;


-- Number of events for accounts (1001, 1011, 1021), per channel
SELECT account_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE account_id IN (1001,1011,1021)
GROUP BY account_id, channel
ORDER BY account_id ASC;

-- Same, but restricted to just the 'organic' and 'adwords' channels
SELECT account_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND account_id IN (1001,1011,1021)
GROUP BY account_id, channel;


-- Count sales reps per region, ordered by count descending
SELECT region_id, COUNT(*) AS Cnt
FROM sales_reps
GROUP BY region_id
ORDER BY Cnt DESC;

-- Same, using COUNT(region_id) instead of COUNT(*), unordered
SELECT region_id, COUNT(region_id) AS Cnt
FROM sales_reps
GROUP BY region_id;

-- Count accounts per sales rep
-- Sorted by count ascending
SELECT sales_rep_id, COUNT(*) AS Cnt
FROM accounts
GROUP BY sales_rep_id
ORDER BY Cnt ASC;


-- Same as the channel count above, written with multi-line formatting
SELECT
    channel,
    COUNT(*) AS EventCount
FROM web_events
GROUP BY channel
ORDER BY EventCount DESC;

-- Order statistics per account, for 2014 orders only
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

-- Total number of orders across all years, for comparison against the 2014-only counts above
SELECT COUNT(*) AS OrderCount
FROM orders;

-- Same order statistics, all years, ordered by column position (3 = AvgTotal)
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

-- Same order statistics, sorted by account_id instead of AvgTotal
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


-- Event count plus first/last event timestamp, per account and channel, for accounts (1001, 1011, 1021)
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

-- Top 10 individual dates with the most orders
SELECT
    DATE(occurred_at) AS order_date,
    COUNT(*) num_orders
FROM orders
GROUP BY order_date
ORDER BY num_orders DESC
LIMIT 10 ;

-- =======================================================================================================================================

-- Break each order's timestamp into year, month, day, and hour components

SELECT
    id,
    occurred_at,
    YEAR(occurred_at) AS 'year',
    MONTH(occurred_at) AS 'month',
    DAY(occurred_at) AS 'day',
    HOUR(occurred_at) AS 'hour'
FROM orders;

-- Unique years in orders
SELECT DISTINCT(YEAR(occurred_at)) Years
FROM orders
ORDER BY Years;

-- Earliest year present in the data
SELECT Min(YEAR(occurred_at)) MIN_Yr
FROM orders;

-- Latest year present in the data
SELECT MAX(YEAR(occurred_at)) MAX_Yr
FROM orders;

-- Earliest and latest order dates
SELECT
	Min(DATE(occurred_at)) MIN_Date,
	MAX(DATE(occurred_at)) MAX_Date
FROM orders;

-- Total revenue per year
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

-- Same, using EXTRACT(YEAR FROM ...) instead of YEAR()
SELECT
	EXTRACT(YEAR FROM occurred_at) ord_year,
	SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Same, using DATE_FORMAT(occurred_at, '%Y') instead of YEAR()
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

-- Distinct months represented per year, to check how evenly the data is spread
SELECT YEAR(occurred_at) ord_year,
		COUNT(DISTINCT MONTH(occurred_at)) No_of_Months
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Distinct days represented per year, to check how evenly the data is spread
SELECT YEAR(occurred_at) ord_year,
		COUNT(DISTINCT DAY(occurred_at)) No_of_Days
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- =======================================================================================================================================

-- Orders in Q1, 2015.

SELECT *
FROM orders
WHERE MONTH(occurred_at) BETWEEN 1 AND 3
AND YEAR(occurred_at) = 2015;

-- =======================================================================================================================================

-- Show total sales per month name.
SELECT 
    MONTHNAME(occurred_at) AS month_name,
    SUM(total_amt_usd) total_sales
FROM orders
GROUP BY month_name;

-- =======================================================================================================================================

-- Which day of week has highest sales?
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

-- Expected delivery date.
SELECT 
    id,
    DATE(occurred_at) order_date,
    DATE_ADD(DATE(occurred_at), INTERVAL 7 DAY) AS expected_delivery
FROM orders;

-- Today's date
SELECT CURDATE();

-- Current date and time
SELECT NOW();

-- Date 7 days from today
SELECT DATE_ADD(CURDATE(), INTERVAL 7 DAY) Delivery
