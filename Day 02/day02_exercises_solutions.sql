-- ============================================================
-- SQL PRACTICE EXERCISES — SOLUTIONS — Parch & Posey Database
-- ============================================================
-- Answer key for day02_exercises.sql. Some questions have more than one valid
-- way to write them (e.g. Section 8's plain-operator vs BETWEEN pair) —
-- these are the reference solutions, not the only correct answers.
-- ============================================================

USE parch_and_posey;


-- ======================================
-- SECTION 1 — LIMIT & OFFSET
-- ======================================

-- 1.1
SELECT *
FROM orders
LIMIT 10;

-- 1.2
SELECT *
FROM accounts
LIMIT 5 OFFSET 15;

-- 1.3
SELECT *
FROM web_events
LIMIT 20, 5;


-- ======================================
-- SECTION 2 — DISTINCT
-- ======================================

-- 2.1
SELECT DISTINCT name
FROM region;

-- 2.2
SELECT DISTINCT channel
FROM web_events;

-- 2.3
SELECT COUNT(DISTINCT channel) AS channel_cnt
FROM web_events;

-- 2.4
SELECT COUNT(DISTINCT sales_rep_id) AS reps_with_accounts
FROM accounts;


-- ======================================
-- SECTION 3 — ORDER BY
-- ======================================

-- 3.1
SELECT *
FROM accounts
ORDER BY name;

-- 3.2
SELECT *
FROM orders
ORDER BY total_amt_usd DESC;

-- 3.3 (website is column position 2 in this SELECT list)
SELECT name, website
FROM accounts
ORDER BY 2;

-- 3.4
SELECT *
FROM sales_reps
ORDER BY region_id ASC, name ASC;

-- 3.5
SELECT id, name
FROM accounts
ORDER BY id DESC
LIMIT 5;


-- ======================================
-- SECTION 4 — AGGREGATION FUNCTIONS
-- ======================================

-- 4.1
SELECT COUNT(*) AS order_count
FROM orders;

-- 4.2
SELECT MIN(total_amt_usd) AS min_total,
       MAX(total_amt_usd) AS max_total
FROM orders;

-- 4.3
SELECT ROUND(AVG(total_amt_usd), 2) AS avg_total
FROM orders;

-- 4.4
SELECT COUNT(*) AS order_count,
       SUM(standard_qty) AS total_standard_qty,
       SUM(total_amt_usd) AS total_revenue
FROM orders;


-- ======================================
-- SECTION 5 — WHERE CONDITIONS
-- ======================================

-- 5.1
SELECT *
FROM orders
WHERE total_amt_usd > 2000;

-- 5.2
SELECT *
FROM web_events
WHERE channel = 'organic';

-- 5.3
SELECT *
FROM accounts
WHERE sales_rep_id = 321500;

-- 5.4
SELECT COUNT(*) AS twitter_cnt
FROM web_events
WHERE channel = 'twitter';

-- 5.5
SELECT COUNT(*) AS order_count,
       AVG(total_amt_usd) AS avg_total
FROM orders
WHERE account_id = 1001;

-- 5.6
-- Not answerable from web_events: that table only has id, account_id,
-- occurred_at, and channel — no dollar-amount column. Revenue figures
-- (total_amt_usd) live only in `orders`, and there's no shared key that
-- ties one specific web_event row to one specific order row (only the
-- shared account_id, which would mix all of an account's orders together
-- regardless of channel). This needs a JOIN to even approximate, and even
-- then it would be an assumption, not a fact — so the correct answer here
-- is "this table can't tell you that," not a query.

-- 5.7
SELECT MAX(total_amt_usd) AS max_total
FROM orders
WHERE account_id = 1021;

-- 5.8
SELECT *
FROM orders
WHERE account_id = 1001
ORDER BY total_amt_usd DESC
LIMIT 3;


-- ======================================
-- SECTION 6 — NOT EQUAL CONDITIONS
-- ======================================

-- 6.1
SELECT *
FROM web_events
WHERE channel != 'direct';

-- 6.2
SELECT *
FROM web_events
WHERE channel <> 'direct';

-- 6.3
SELECT *
FROM web_events
WHERE NOT channel = 'direct';


-- ======================================
-- SECTION 7 — AND / OR CONDITIONS
-- ======================================

-- 7.1
SELECT *
FROM orders
WHERE account_id = 1001
AND total_amt_usd > 1000;

-- 7.2
SELECT *
FROM web_events
WHERE channel = 'twitter'
OR account_id = 1011;

-- 7.3
SELECT *
FROM orders
WHERE standard_qty > 0
AND gloss_qty > 0
AND poster_qty > 0;


-- ======================================
-- SECTION 8 — RANGE FILTERING (BETWEEN)
-- ======================================

-- 8.1
SELECT *
FROM orders
WHERE total_amt_usd >= 1000
AND total_amt_usd <= 2000;

-- 8.2
SELECT *
FROM orders
WHERE total_amt_usd BETWEEN 1000 AND 2000;

-- 8.3
SELECT *
FROM accounts
WHERE sales_rep_id BETWEEN 321700 AND 321800;

-- 8.4
SELECT *
FROM orders
WHERE occurred_at BETWEEN '2014-12-25' AND '2015-01-01';


-- ======================================
-- SECTION 9 — IN vs OR
-- ======================================

-- 9.1
SELECT *
FROM web_events
WHERE channel = 'facebook'
OR channel = 'twitter'
OR channel = 'banner';

-- 9.2
SELECT *
FROM web_events
WHERE channel IN ('facebook', 'twitter', 'banner');

-- 9.3
SELECT *
FROM accounts
WHERE sales_rep_id IN (321500, 321510, 321520);

-- 9.4
SELECT *
FROM web_events
WHERE channel NOT IN ('direct', 'banner', 'organic');


-- ======================================
-- SECTION 10 — NULL CHECKS
-- ======================================

-- 10.1
SELECT *
FROM accounts
WHERE website IS NULL;
-- Returns 0 rows: Parch & Posey has no NULL values in any column, in any
-- table. The query is valid syntax, it just has nothing to find here.

-- 10.2
SELECT *
FROM accounts
WHERE primary_poc IS NOT NULL;
-- Returns every row, for the same reason.

-- 10.3
SELECT COUNT(*) AS missing_poc_cnt
FROM accounts
WHERE primary_poc IS NULL;
-- 0, for the same reason as 10.1.


-- ======================================
-- SECTION 11 — LIKE (Pattern Matching)
-- ======================================

-- 11.1
SELECT *
FROM accounts
WHERE name LIKE 'M%';

-- 11.2
SELECT *
FROM accounts
WHERE name LIKE '%Group%';

-- 11.3
SELECT *
FROM accounts
WHERE name LIKE '_o___';

-- 11.4
SELECT *
FROM web_events
WHERE channel LIKE 'a%';

-- 11.5
SELECT COUNT(*) AS dot_com_cnt
FROM accounts
WHERE website LIKE '%.com%';


-- ======================================
-- SECTION 12 — GROUP BY
-- ======================================

-- 12.1
SELECT channel, COUNT(*) AS cnt
FROM web_events
GROUP BY channel;

-- 12.2
SELECT sales_rep_id, COUNT(*) AS account_cnt
FROM accounts
GROUP BY sales_rep_id;

-- 12.3
SELECT channel, COUNT(*) AS cnt
FROM web_events
WHERE account_id = 1001
GROUP BY channel;

-- 12.4
SELECT region_id, COUNT(*) AS rep_cnt
FROM sales_reps
GROUP BY region_id
ORDER BY rep_cnt DESC;

-- 12.5
SELECT
    account_id,
    COUNT(*) AS order_count,
    AVG(total_amt_usd) AS avg_total,
    SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY account_id
ORDER BY total_revenue DESC;

-- 12.6
SELECT
    channel,
    MIN(occurred_at) AS first_event,
    MAX(occurred_at) AS last_event
FROM web_events
GROUP BY channel;

-- 12.7
SELECT account_id, channel, COUNT(*) AS event_cnt
FROM web_events
WHERE account_id IN (1001, 1011, 1021)
GROUP BY account_id, channel;


-- ======================================
-- SECTION 13 — HAVING
-- ======================================

-- 13.1
SELECT sales_rep_id, COUNT(*) AS num_accounts
FROM accounts
GROUP BY sales_rep_id
HAVING COUNT(*) >= 10
ORDER BY num_accounts DESC;

-- 13.2
SELECT account_id, COUNT(*) AS num_orders
FROM orders
GROUP BY account_id
HAVING COUNT(*) > 60
ORDER BY num_orders DESC;

-- 13.3
SELECT account_id, SUM(total_amt_usd) AS total_spent
FROM orders
GROUP BY account_id
HAVING SUM(total_amt_usd) > 100000
ORDER BY total_spent DESC;

-- 13.4
SELECT account_id, SUM(total_amt_usd) AS total_spent_2015
FROM orders
WHERE occurred_at LIKE '2015%'
GROUP BY account_id
HAVING SUM(total_amt_usd) > 20000
ORDER BY total_spent_2015 DESC;


-- ======================================
-- SECTION 14 — DATE Functions
-- ======================================

-- 14.1
SELECT DATE(occurred_at) AS order_date, COUNT(*) AS num_orders
FROM orders
GROUP BY order_date
ORDER BY num_orders DESC
LIMIT 5;

-- 14.2
SELECT MIN(YEAR(occurred_at)) AS earliest_year,
       MAX(YEAR(occurred_at)) AS latest_year
FROM orders;

-- 14.3
SELECT YEAR(occurred_at) AS ord_year, SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY ord_year
ORDER BY ord_year ASC;

-- 14.4
SELECT MONTH(occurred_at) AS ord_month, SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY ord_month
ORDER BY total_revenue DESC;

-- 14.5
SELECT DATE_FORMAT(o.occurred_at, '%Y-%m') AS ord_month,
       SUM(o.standard_amt_usd) AS standard_spend
FROM orders o
JOIN accounts a
    ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY ord_month
ORDER BY standard_spend DESC
LIMIT 1;

-- 14.6
SELECT id,
       DATE(occurred_at) AS order_date,
       DATE_ADD(DATE(occurred_at), INTERVAL 7 DAY) AS expected_delivery
FROM orders
ORDER BY occurred_at DESC
LIMIT 10;


-- ======================================
-- CHALLENGE QUESTIONS
-- ======================================

-- C1
SELECT account_id, SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY account_id
ORDER BY total_revenue DESC
LIMIT 5;

-- C2
SELECT account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC
LIMIT 1;

-- C3
SELECT a.name, o.total_amt_usd
FROM orders o
JOIN accounts a
    ON a.id = o.account_id
ORDER BY o.total_amt_usd DESC
LIMIT 1;

-- C4
SELECT a.name, SUM(o.total_amt_usd) AS total_revenue
FROM orders o
JOIN accounts a
    ON a.id = o.account_id
GROUP BY a.name
ORDER BY total_revenue DESC
LIMIT 5;
