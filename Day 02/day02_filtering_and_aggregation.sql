USE rawaj;

-- Before analyzing order data, check what columns are actually available to work with
DESCRIBE orders;

-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- Quick sanity check that the client is connected and running queries at all (no FROM clause needed)
SELECT 'Hello World' AS Welcome;

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

-- Which orders were the biggest, in EGP terms?
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

-- COUNT(column) skips NULLs, while COUNT(*) counts every row. Every order has a
-- total_amount, so both give the same answer there — customers.email is the column
-- that actually has gaps, so that's where the difference shows up
SELECT
    COUNT(*) AS All_customers,
    COUNT(email) AS Customers_with_email
FROM customers;

-- What's the smallest order Rawaj has ever received?
SELECT MIN(total_amount) AS MinOrderTotal
FROM orders;

-- What's the average order size, across every order on record?
SELECT AVG(total_amount) AS AvgOrderTotal
FROM orders;

-- Finance wants one summary row: order count, smallest, biggest, average, and total revenue, all at once
SELECT
    COUNT(*) AS OrderCount,                		-- Number of orders
    MIN(total_amount) AS MinTotal,         		-- Lowest order total
    MAX(total_amount) AS MaxTotal,         		-- Highest order total
    ROUND(AVG(total_amount), 2) AS AvgTotal,  	    -- Average order total, to 2 decimal places
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
WHERE order_date < '2024-01-01'
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

-- How many orders has customer 631 placed, and what's their average order size?
SELECT 	COUNT(*) AS No_of_Orders,
		ROUND(AVG(total_amount), 2) AS AvgOrderTotal
FROM orders
WHERE customer_id = 631;

-- Same question, for a different customer (2)
SELECT  COUNT(*) AS Orders_Customer2,
		ROUND(AVG(total_amount), 2) AS AvgOrderTotal
FROM orders
WHERE customer_id = 2;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- Every order EXCEPT those from customer 631 — useful when you want to exclude one customer from a report
SELECT *
FROM orders
WHERE customer_id != 631;

-- Same exclusion, standard SQL spelling (<>)
SELECT *
FROM orders
WHERE customer_id <> 631;

-- Same exclusion again, using the NOT keyword instead
SELECT *
FROM orders
WHERE NOT customer_id = 631;


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- Did customer 631 specifically generate any Facebook traffic?
SELECT *
FROM web_events
WHERE channel = 'facebook'
AND customer_id = 631;

-- Now cast a much wider net: everything Facebook overall, plus everything from customer 631, regardless of channel
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR customer_id = 631;


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

-- Which orders came in during the final two days of 2024 plus New Year's Day — useful for a
-- year-end cutoff report? order_date is a DATETIME, so BETWEEN would be wrong here:
-- BETWEEN '2024-12-30' AND '2025-01-01' stops at 2025-01-01 00:00:00 and silently drops
-- every Jan 1 order placed after midnight. Use >= start AND < the day AFTER the end instead
SELECT *
FROM orders
WHERE order_date >= '2024-12-30'
AND order_date < '2025-01-02';


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

-- LIKE is CASE-INSENSITIVE by default in MySQL, so 'A%' also matches names starting
-- with a lowercase 'a', and '%el%' matches "El-Masry" AND "Abdelrahman". Expect more
-- rows back than a case-sensitive search would give you

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


-- Which channels does customer 631 specifically use most — what are their top 3?
SELECT channel, COUNT(*) AS Cnt
FROM web_events
WHERE customer_id = 631
GROUP BY channel
ORDER BY Cnt DESC
LIMIT 3;

-- How much web activity did each of these three key customers (631, 2, 3) generate?
SELECT customer_id, COUNT(customer_id) AS Cnt
FROM web_events
WHERE customer_id IN (631,2,3)
GROUP BY customer_id
ORDER BY customer_id ASC;


-- For those same three customers, break the activity down by channel too — which channel does each customer favor?
SELECT customer_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE customer_id IN (631,2,3)
GROUP BY customer_id, channel
ORDER BY customer_id ASC;

-- Now narrow that same view to just organic and Google traffic
SELECT customer_id, channel, COUNT(channel) AS Cnt
FROM web_events
WHERE channel IN ('organic', 'google')
AND customer_id IN (631,2,3)
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


-- The same channel breakdown again, laid out one column per line and with a report-ready alias
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
WHERE YEAR(order_date) = 2024
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
WHERE customer_id IN (631,2,3)
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
WHERE YEAR(order_date) = 2024
GROUP BY customer_id
HAVING SUM(total_amount) > 20000
ORDER BY TotalSpent2024 DESC;


-- ======================================
-- SECTION 14 — DATE Functions
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
SELECT DISTINCT YEAR(order_date) AS Years
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

-- Total sales (EGP) per year. 2024 is the biggest year at roughly 11.6M EGP, ahead of
-- 2025 (6.6M) and 2023 (4.8M) — but that gap is mostly a coverage artifact, not growth:
-- the dataset starts in June 2023 and stops in May 2025, so only 2024 is a full year.
-- Never read a yearly trend off these totals without checking the date range first.

-- Using YEAR(), sorted smallest total first
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

-- Which year had the most orders? 2024 again, with 3,003 — against 1,747 in 2025 and
-- 1,250 in 2023. Same caveat as above: the years are not evenly represented, because
-- 2023 only starts in June and 2025 only runs through May.

SELECT YEAR(order_date) ord_year,  COUNT(*) Orders_cnt
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- =======================================================================================================================================

-- Which month had the greatest total sales? Restricting to 2024 — the one complete year —
-- keeps the partial 2023/2025 months from skewing the comparison. March comes out well
-- ahead of every other month, with April second: that's the Ramadan/Eid shopping spike,
-- a real seasonal signal rather than noise.
SELECT
	MONTH(order_date) ord_month,
    SUM(total_amount) total_spent
FROM orders
WHERE order_date >= '2024-01-01'
AND order_date < '2025-01-01'
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
GROUP BY month_name
ORDER BY total_sales DESC;

-- =======================================================================================================================================

-- Which day of the week has the highest total sales?
SELECT
    DAYNAME(order_date) AS day_name,
    SUM(total_amount) total_sales
FROM orders
GROUP BY day_name
ORDER BY total_sales DESC;

-- =======================================================================================================================================

-- In which month of which year did Rawaj's single highest-spending customer spend the most?
-- Two steps, because we don't know yet who that customer is. First, let the data name them:
SELECT customer_id, SUM(total_amount) AS lifetime_spend
FROM orders
GROUP BY customer_id
ORDER BY lifetime_spend DESC
LIMIT 1;

-- That returns customer 971, at just over 61,000 EGP lifetime. Now break their spend down
-- by month and take the biggest one — April 2024, at roughly 19,850 EGP
SELECT DATE_FORMAT(order_date,'%Y-%m') ord_month, SUM(total_amount) tot_spent
FROM orders
WHERE customer_id = 971
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
SELECT DATE_ADD(CURDATE(), INTERVAL 7 DAY) Delivery;
