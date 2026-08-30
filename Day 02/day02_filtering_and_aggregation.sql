USE rawaj;

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

-- Give the ops team an alphabetical customer directory
SELECT *
FROM customers
ORDER BY last_name, first_name;

-- Which orders were the biggest, in dollar terms?
SELECT *
FROM orders
ORDER BY total_amount DESC;

-- Same "biggest orders first" question, referenced by column position instead of name (3 = total_amount)
SELECT order_id, subtotal, total_amount
FROM orders
ORDER BY 3 DESC;

-- Group the customer list by governorate, highest governorate ID first, for a quick regional review (3 = governorate_id)
SELECT first_name, last_name, governorate_id
FROM customers
ORDER BY 3 DESC;


-- Organize customers by governorate, and alphabetize (reverse) within each governorate
SELECT *
FROM customers
ORDER BY governorate_id ASC, last_name DESC;


-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- How many orders has Rawaj processed in total?
SELECT COUNT(order_id) AS Orders_count
FROM orders;

-- How many of those orders actually have a recorded dollar total? (COUNT ignores NULLs, unlike COUNT(*))
SELECT COUNT(total_amount) AS Non_Null_count
FROM orders;

-- What's the smallest order Rawaj has ever received?
SELECT MIN(total_amount) AS MinOrderTotal
FROM orders;

-- What's the average order size, across every order on record?
SELECT AVG(total_amount) AS AvgOrderTotal
FROM orders;

-- Finance wants one summary row: order count, smallest, biggest, average, and total revenue, all at once
SELECT
    COUNT(total_amount) AS OrderCount,     		-- Number of non-null order totals
    MIN(total_amount) AS MinTotal,         		-- Lowest order total
    MAX(total_amount) AS MaxTotal,         		-- Highest order total
    ROUND(AVG(total_amount), 2) AS AvgTotal,  	    -- Rounded average order total
    SUM(total_amount) AS TotalRevenue        		-- Total revenue
FROM orders;


-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- Which orders were worth more than 10,000 EGP — the company's biggest single sales?
SELECT *
FROM orders
WHERE total_amount > 10000
ORDER BY total_amount DESC;

-- Pull every order placed before 2024, for a look back at Rawaj's earliest months
SELECT *
FROM orders
WHERE order_date < "2024-01-01"
ORDER BY order_date;


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

-- How many orders has customer 1 placed, and what's their average order size?
SELECT 	COUNT(total_amount) AS No_of_Orders,
		AVG(total_amount) AS AvgOrderTotal
FROM orders
WHERE customer_id = 1;

-- Same question, for a different customer (2)
SELECT  COUNT(total_amount) AS Orders_Customer2,
		AVG(total_amount) AS AvgOrderTotal
FROM orders
WHERE customer_id = 2;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- Every order EXCEPT those from customer 1 — useful when you want to exclude one high-volume customer from a report
SELECT *
FROM orders
WHERE customer_id != 1;

-- Same exclusion, standard SQL spelling (<>)
SELECT *
FROM orders
WHERE customer_id <> 1;

-- Same exclusion again, using the NOT keyword instead
SELECT *
FROM orders
WHERE NOT customer_id = 1;


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- Did customer 1 specifically generate any Facebook traffic?
SELECT *
FROM web_events
WHERE channel = 'facebook'
AND customer_id = 1;

-- Now cast a much wider net: everything Facebook overall, plus everything from customer 1, regardless of channel
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR customer_id = 1;


-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- Which orders fall in the 2,000–4,999 EGP mid-size range, written with plain AND logic?
SELECT *
FROM orders
WHERE total_amount < 5000
AND total_amount >= 2000;

-- Same 2,000–4,999 question, written the shorter way with BETWEEN (inclusive on both ends)
SELECT *
FROM orders
WHERE total_amount BETWEEN 2000 AND 4999;

-- Which orders came in during the final two days of 2024 — useful for a year-end cutoff report?
SELECT *
FROM orders
WHERE order_date BETWEEN "2024-12-30" AND "2025-01-01";


-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- Marketing wants every event from Facebook, Instagram, or organic search — written the long way with OR
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR channel = 'instagram'
OR channel = 'organic';

-- Same three-channel question, written the cleaner way with IN
SELECT *
FROM web_events
WHERE channel IN ('facebook','instagram', 'organic');

-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- Compliance wants a list of customers missing an email on file (checked out as a guest)
SELECT *
FROM customers
WHERE email IS NULL;

-- And the opposite: customers who DID leave an email on file
SELECT *
FROM customers
WHERE email IS NOT NULL;


-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- Which customers have a first name starting with the letter A — useful for an alphabetized outreach list?
SELECT *
FROM customers
WHERE first_name LIKE 'A%';

-- % means any number of characters, zero or more

-- Which customers have the letter 'a' anywhere in their first name?
SELECT *
FROM customers
WHERE first_name LIKE '%a%';

-- Which customers have 'a' as the second letter of their first name?
SELECT *
FROM customers
WHERE first_name LIKE '_a%';

-- _ means exactly one character

-- Which customers have a 5-character first name with 'a' as the second letter — a narrower pattern-matching example?
SELECT *
FROM customers
WHERE first_name LIKE '_a___';

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


-- Which channels does customer 1 specifically use most — what are their top 3?
SELECT channel, COUNT(*) AS Cnt
FROM web_events
WHERE customer_id = 1
GROUP BY channel
ORDER BY Cnt DESC
LIMIT 3;

-- How much web activity did each of these three key customers (1, 2, 3) generate?
SELECT customer_id, COUNT(customer_id) AS Cnt
FROM web_events
WHERE customer_id IN (1,2,3)
GROUP BY customer_id
ORDER BY customer_id ASC;


-- For those same three customers, break the activity down by channel too — which channel does each customer favor?
SELECT customer_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE customer_id IN (1,2,3)
GROUP BY customer_id, channel
ORDER BY customer_id ASC;

-- Now narrow that same view to just organic and Google traffic
SELECT customer_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE channel IN ('organic', 'google')
AND customer_id IN (1,2,3)
GROUP BY customer_id, channel;


-- How many customers are registered in each governorate, most-populated governorate first?
SELECT governorate_id, COUNT(*) AS Cnt
FROM customers
GROUP BY governorate_id
ORDER BY Cnt DESC;

-- Same headcount-per-governorate question, using COUNT(governorate_id) instead of COUNT(*), unordered
SELECT governorate_id, COUNT(governorate_id) AS Cnt
FROM customers
GROUP BY governorate_id;

-- How many orders has each customer placed, lightest first?
SELECT customer_id, COUNT(*) AS Cnt
FROM orders
GROUP BY customer_id
ORDER BY Cnt ASC;


-- Same channel-traffic question as Section 12's first query, just reformatted for a shared report
SELECT
    channel,
    COUNT(*) AS EventCount
FROM web_events
GROUP BY channel
ORDER BY EventCount DESC;

-- For 2024 specifically, which customers ordered the most, and what did their orders look like on average?
SELECT
    customer_id,
    COUNT(*) AS OrderCount,
    AVG(total_amount) AS AvgTotal,
    SUM(total_amount) AS SumTotal,
    MIN(total_amount) AS MinTotal,
    MAX(total_amount) AS MaxTotal
FROM orders
WHERE order_date LIKE "2024%"
GROUP BY customer_id
ORDER BY OrderCount DESC;

-- For comparison, how many orders exist across ALL years combined, not just 2024?
SELECT COUNT(*) AS OrderCount
FROM orders;

-- Same per-customer order stats as above, but across every year, sorted by average order size (3 = AvgTotal)
SELECT
    customer_id,
    COUNT(*) AS OrderCount,
    AVG(total_amount) AS AvgTotal,
    SUM(total_amount) AS SumTotal,
    MIN(total_amount) AS MinTotal,
    MAX(total_amount) AS MaxTotal
FROM orders
GROUP BY customer_id
ORDER BY 3 DESC;

-- Same stats again, resorted by customer ID instead of average size, for a tidy lookup table
SELECT
	customer_id,
    COUNT(*) AS OrderCount,
    AVG(total_amount) AS AvgTotal,
    SUM(total_amount) AS SumTotal,
    MIN(total_amount) AS MinTotal,
    MAX(total_amount) AS MaxTotal
FROM orders
GROUP BY customer_id
ORDER BY customer_id;


-- For those three key customers, when was each channel first and last used, and how often?
SELECT
	customer_id, channel,
    COUNT(*) AS EventCount,
    MIN(occurred_at) AS FirstEvent,
    MAX(occurred_at) AS LastEvent
FROM web_events
WHERE customer_id IN (1,2,3)
GROUP BY customer_id, channel
ORDER BY customer_id;


-- ======================================
-- SECTION 13 — HAVING (filtering grouped results)
-- ======================================

-- WHERE filters rows BEFORE grouping; HAVING filters groups AFTER
-- aggregation runs — COUNT(*)/SUM(...) don't exist yet at the point WHERE
-- is evaluated, so only HAVING can filter on them.

-- Marketing only wants channels that actually moved the needle — more than 2,000 web events
SELECT channel, COUNT(*) AS Cnt
FROM web_events
GROUP BY channel
HAVING COUNT(*) > 2000
ORDER BY Cnt DESC;

-- WHERE COUNT(*) > 2000 here would be a syntax error —
-- COUNT(*) doesn't exist yet at the point WHERE runs

-- Which customers have placed more than 10 orders — repeat buyers worth flagging for a loyalty program?
SELECT customer_id, COUNT(*) AS Cnt
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 10
ORDER BY Cnt DESC;

-- Which customers have spent less than 2,000 EGP total — candidates for a re-engagement email?
SELECT customer_id, SUM(total_amount) AS TotalSpent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) < 2000
ORDER BY TotalSpent;

-- HAVING stacks with WHERE: restrict to 2024 orders first, then keep only
-- the customers whose 2024 total topped 20,000 EGP
SELECT customer_id, SUM(total_amount) AS TotalSpent2024
FROM orders
WHERE order_date LIKE "2024%"
GROUP BY customer_id
HAVING SUM(total_amount) > 20000
ORDER BY TotalSpent2024 DESC;


-- ======================================
-- SECTION 14 — DATE Functions
-- for REF : https://www.w3schools.com/sql/func_mysql_date.asp
-- ======================================

-- Which single dates had the most orders — were there any spike days worth investigating?
SELECT
    DATE(order_date) AS order_day,
    COUNT(*) num_orders
FROM orders
GROUP BY order_day
ORDER BY num_orders DESC
LIMIT 10 ;

-- =======================================================================================================================================

-- Ops wants every order's timestamp broken into year, month, day, and hour for a custom reporting tool

SELECT
    order_id,
    order_date,
    YEAR(order_date) AS 'year',
    MONTH(order_date) AS 'month',
    DAY(order_date) AS 'day',
    HOUR(order_date) AS 'hour'
FROM orders;

-- Which years does this dataset actually cover?
SELECT DISTINCT(YEAR(order_date)) Years
FROM orders
ORDER BY Years;

-- What's the very first year of data on record?
SELECT Min(YEAR(order_date)) MIN_Yr
FROM orders;

-- What's the most recent year of data on record?
SELECT MAX(YEAR(order_date)) MAX_Yr
FROM orders;

-- What are the exact earliest and latest order dates in the dataset?
SELECT
	Min(DATE(order_date)) MIN_Date,
	MAX(DATE(order_date)) MAX_Date
FROM orders;

-- How has total revenue trended year over year?
SELECT
    year(order_date) AS OrderYear,
    SUM(total_amount) TOTALRev
FROM orders
GROUP BY OrderYear
ORDER BY TOTALRev ;

-- =======================================================================================================================================

-- Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least.
-- Do you notice any trends in the yearly sales totals?

-- Using YEAR() — note: ordered ascending here, opposite of the two variants below
SELECT YEAR(order_date) ord_year,
		SUM(total_amount) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 ASC;

-- Same question, using EXTRACT(YEAR FROM ...) instead of YEAR()
SELECT
	EXTRACT(YEAR FROM order_date) ord_year,
	SUM(total_amount) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Same question again, using DATE_FORMAT(order_date, '%Y') instead of YEAR()
SELECT
	DATE_FORMAT(order_date,'%Y') ord_year,
    SUM(total_amount) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- =======================================================================================================================================

-- Which year did Rawaj have the greatest sales in terms of total number of orders?
-- Are all years evenly represented by the dataset?

SELECT YEAR(order_date) ord_year,  COUNT(*) Orders_cnt
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- =======================================================================================================================================

-- Which month did Rawaj have the greatest sales in terms of total dollars?
-- Are all months evenly represented by the dataset?

-- Filtered to full-year 2024 (excludes the partial 2023/2025 data) to avoid skewing the month totals
SELECT
	MONTH(order_date) ord_month,
    SUM(total_amount) total_spent
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2025-01-01'
GROUP BY 1
ORDER BY 2 DESC;

-- How evenly is the data actually spread across each year — are some months missing entirely?
SELECT YEAR(order_date) ord_year,
		COUNT(DISTINCT MONTH(order_date)) No_of_Months
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Same evenness check, at the day level instead of month
SELECT YEAR(order_date) ord_year,
		COUNT(DISTINCT DAY(order_date)) No_of_Days
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- =======================================================================================================================================

-- Pull every order from Q1 2024 specifically, for a quarterly review

SELECT *
FROM orders
WHERE MONTH(order_date) BETWEEN 1 AND 3
AND YEAR(order_date) = 2024;

-- =======================================================================================================================================

-- Which calendar month (Jan, Feb, ...) generates the most total sales, combined across every year?
SELECT
    MONTHNAME(order_date) AS month_name,
    SUM(total_amount) total_sales
FROM orders
GROUP BY month_name;

-- =======================================================================================================================================

-- Which day of the week has the highest total sales?
SELECT
    DAYNAME(order_date) AS day_name,
    SUM(total_amount) total_sales
FROM orders
GROUP BY day_name
ORDER BY total_sales DESC;

-- =======================================================================================================================================

--  In which month of which year did our single highest-spending customer, Mohamed Abdelrahman, spend the most?
--  (first JOIN in this script — links orders to customers to filter by name)

SELECT DATE_FORMAT(order_date,'%Y-%m') ord_date, SUM(o.total_amount) tot_spent
FROM orders o
JOIN customers c
	ON c.customer_id = o.customer_id
WHERE c.first_name = 'Mohamed' AND c.last_name = 'Abdelrahman'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- =======================================================================================================================================

-- Ops needs an expected delivery date for every order — 7 days after it was placed
SELECT
    order_id,
    DATE(order_date) order_day,
    DATE_ADD(DATE(order_date), INTERVAL 7 DAY) AS expected_delivery
FROM orders;

-- Quick reference: what does MySQL consider "today" on this server?
SELECT CURDATE();

-- Quick reference: current date and time, for timestamping something happening right now
SELECT NOW();

-- If an order were placed today, what would its 7-day delivery date be?
SELECT DATE_ADD(CURDATE(), INTERVAL 7 DAY) Delivery
