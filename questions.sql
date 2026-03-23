-- ============================================================
--        200 SQL PRACTICE QUESTIONS WITH SOLUTIONS
--        Database  : MySQL
--        Dataset   : E-Commerce
--        Tables    : customers, products, orders,
--                    order_items, payments
-- ============================================================

/*
   TABLE STRUCTURE (for reference)
   --------------------------------
   customers  : customer_id, name, city, signup_date
   products   : product_id, product_name, category, price
   orders     : order_id, customer_id, order_date, total_amount
   order_items: order_id, product_id, quantity
   payments   : payment_id, order_id, payment_method,
                payment_status  ('Success' / 'Failed')
*/


-- ================================================================
--                  LEVEL 1 : BASICS   (Q1 to Q30)
-- ================================================================


-- Q1. Select all columns from the customers table.
-- -------------------------------------------------------
SELECT * FROM customers;


-- Q2. Select only customer_id and city from customers.
-- -------------------------------------------------------
SELECT customer_id, city
FROM customers;


-- Q3. Show all customers who belong to Mumbai.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city = 'Mumbai';


-- Q4. Show customers from Delhi who signed up after 2023-01-01.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city = 'Delhi'
  AND signup_date > '2023-01-01';


-- Q5. Show customers who are from Pune OR Jaipur.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city = 'Pune'
   OR city = 'Jaipur';


-- Q6. Show all customers who are NOT from Chennai.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city != 'Chennai';


-- Q7. Show all orders placed between 2023-01-01 and 2023-12-31.
-- -------------------------------------------------------
SELECT *
FROM orders
WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';


-- Q8. Show customers from Delhi, Mumbai, or Bangalore using IN.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city IN ('Delhi', 'Mumbai', 'Bangalore');


-- Q9. Show customers whose name starts with 'Customer_1'.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE name LIKE 'Customer_1%';


-- Q10. Show all orders sorted by order_date from latest to oldest.
-- -------------------------------------------------------
SELECT *
FROM orders
ORDER BY order_date DESC;


-- Q11. Show the top 5 most recent orders.
-- -------------------------------------------------------
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 5;


-- Q12. Count the total number of customers.
-- -------------------------------------------------------
SELECT COUNT(*) AS total_customers
FROM customers;


-- Q13. Count how many distinct cities are present in customers table.
-- -------------------------------------------------------
SELECT COUNT(DISTINCT city) AS total_cities
FROM customers;


-- Q14. Show number of customers in each city.
-- -------------------------------------------------------
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;


-- Q15. Show only those cities that have more than 5000 customers.
-- -------------------------------------------------------
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
HAVING COUNT(*) > 5000;


-- Q16. Find the highest order amount.
-- -------------------------------------------------------
SELECT MAX(total_amount) AS max_order
FROM orders;


-- Q17. Find the cheapest product price.
-- -------------------------------------------------------
SELECT MIN(price) AS min_price
FROM products;


-- Q18. Find the average order value.
-- -------------------------------------------------------
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders;


-- Q19. Find the total revenue from all successful orders.
-- -------------------------------------------------------
SELECT ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_status = 'Success';


-- Q20. Use aliases to rename columns in the output.
-- -------------------------------------------------------
SELECT customer_id AS cust_id,
       name        AS customer_name,
       city        AS customer_city
FROM customers
LIMIT 10;


-- Q21. Combine customer_id and city into one column.
-- -------------------------------------------------------
SELECT CONCAT(customer_id, ' - ', city) AS customer_info
FROM customers
LIMIT 10;


-- Q22. Show payment status as 'Paid' or 'Unpaid' using CASE.
-- -------------------------------------------------------
SELECT order_id,
       payment_status,
       CASE
           WHEN payment_status = 'Success' THEN 'Paid'
           WHEN payment_status = 'Failed'  THEN 'Unpaid'
           ELSE 'Unknown'
       END AS status_label
FROM payments
LIMIT 20;


-- Q23. Find rows where city is NULL.
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE city IS NULL;


-- Q24. Replace NULL city with 'Unknown' using COALESCE.
-- -------------------------------------------------------
SELECT customer_id,
       COALESCE(city, 'Unknown') AS city
FROM customers
LIMIT 10;


-- Q25. Show customers along with their orders using INNER JOIN.
-- -------------------------------------------------------
SELECT c.customer_id,
       c.name,
       c.city,
       o.order_id,
       o.order_date,
       o.total_amount
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
LIMIT 20;


-- Q26. Show all customers even if they have no orders (LEFT JOIN).
-- -------------------------------------------------------
SELECT c.customer_id,
       c.name,
       o.order_id,
       o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LIMIT 20;


-- Q27. Show all orders along with payment info (RIGHT JOIN).
-- -------------------------------------------------------
SELECT o.order_id,
       o.total_amount,
       p.payment_method,
       p.payment_status
FROM payments p
RIGHT JOIN orders o ON p.order_id = o.order_id
LIMIT 20;


-- Q28. Show all products and order items (FULL JOIN using UNION trick in MySQL).
-- -------------------------------------------------------
SELECT p.product_id, p.product_name, oi.order_id, oi.quantity
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id

UNION

SELECT p.product_id, p.product_name, oi.order_id, oi.quantity
FROM products p
RIGHT JOIN order_items oi ON p.product_id = oi.product_id
LIMIT 20;


-- Q29. Show customers who have placed at least one order (subquery in WHERE).
-- -------------------------------------------------------
SELECT *
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
);


-- Q30. Show each customer with their total number of orders (subquery in SELECT).
-- -------------------------------------------------------
SELECT customer_id,
       name,
       (SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id) AS total_orders
FROM customers c
LIMIT 20;


-- ================================================================
--              LEVEL 2 : INTERMEDIATE   (Q31 to Q70)
-- ================================================================


-- Q31. Find duplicate customers who have the same name and city.
-- -------------------------------------------------------
SELECT name, city, COUNT(*) AS duplicate_count
FROM customers
GROUP BY name, city
HAVING COUNT(*) > 1;


-- Q32. Keep only one row per duplicate (remove duplicates using ROW_NUMBER).
-- -------------------------------------------------------
WITH ranked_customers AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY name, city ORDER BY customer_id) AS rn
    FROM customers
)
SELECT customer_id, name, city, signup_date
FROM ranked_customers
WHERE rn = 1;


-- Q33. Find the second highest order amount.
-- -------------------------------------------------------
SELECT MAX(total_amount) AS second_highest_order
FROM orders
WHERE total_amount < (SELECT MAX(total_amount) FROM orders);


-- Q34. Find the 3rd highest product price.
-- -------------------------------------------------------
SELECT DISTINCT price
FROM products
ORDER BY price DESC
LIMIT 1 OFFSET 2;


-- Q35. Show customers whose total spending is above the average order amount.
-- -------------------------------------------------------
SELECT customer_id,
       ROUND(SUM(total_amount), 2) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (SELECT AVG(total_amount) FROM orders)
ORDER BY total_spent DESC;


-- Q36. Using correlated subquery - show customers with more than 5 orders.
-- -------------------------------------------------------
SELECT customer_id, name
FROM customers c
WHERE (
    SELECT COUNT(*)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) > 5;


-- Q37. Show customers who placed an order using EXISTS.
-- -------------------------------------------------------
SELECT customer_id, name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Q38. Label customers as 'High Spender' or 'Low Spender' using CASE + aggregation.
-- -------------------------------------------------------
SELECT customer_id,
       ROUND(SUM(total_amount), 2) AS total_spent,
       CASE
           WHEN SUM(total_amount) >= 50000 THEN 'High Spender'
           ELSE 'Low Spender'
       END AS spender_type
FROM orders
GROUP BY customer_id
ORDER BY total_spent DESC;


-- Q39. Pivot revenue by product category for each year.
-- -------------------------------------------------------
SELECT
    YEAR(o.order_date) AS order_year,
    ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN o.total_amount ELSE 0 END), 2) AS Electronics,
    ROUND(SUM(CASE WHEN p.category = 'Clothing'    THEN o.total_amount ELSE 0 END), 2) AS Clothing,
    ROUND(SUM(CASE WHEN p.category = 'Home'        THEN o.total_amount ELSE 0 END), 2) AS Home,
    ROUND(SUM(CASE WHEN p.category = 'Beauty'      THEN o.total_amount ELSE 0 END), 2) AS Beauty,
    ROUND(SUM(CASE WHEN p.category = 'Sports'      THEN o.total_amount ELSE 0 END), 2) AS Sports,
    ROUND(SUM(CASE WHEN p.category = 'Grocery'     THEN o.total_amount ELSE 0 END), 2) AS Grocery
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
GROUP BY YEAR(o.order_date)
ORDER BY order_year;


-- Q40. Unpivot: convert category columns back to rows using UNION ALL.
-- -------------------------------------------------------
-- (Assuming a summary table or CTE called pivot_data)
WITH pivot_data AS (
    SELECT
        YEAR(o.order_date) AS yr,
        ROUND(SUM(CASE WHEN p.category = 'Electronics' THEN o.total_amount ELSE 0 END), 2) AS Electronics,
        ROUND(SUM(CASE WHEN p.category = 'Clothing'    THEN o.total_amount ELSE 0 END), 2) AS Clothing,
        ROUND(SUM(CASE WHEN p.category = 'Home'        THEN o.total_amount ELSE 0 END), 2) AS Home
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products    p  ON oi.product_id = p.product_id
    GROUP BY YEAR(o.order_date)
)
SELECT yr, 'Electronics' AS category, Electronics AS revenue FROM pivot_data
UNION ALL
SELECT yr, 'Clothing',   Clothing  FROM pivot_data
UNION ALL
SELECT yr, 'Home',       Home      FROM pivot_data
ORDER BY yr, category;


-- Q41. Extract the year from order_date.
-- -------------------------------------------------------
SELECT order_id,
       order_date,
       YEAR(order_date) AS order_year
FROM orders
LIMIT 10;


-- Q42. Extract the month from order_date.
-- -------------------------------------------------------
SELECT order_id,
       order_date,
       MONTH(order_date) AS order_month
FROM orders
LIMIT 10;


-- Q43. Find the number of days between customer signup and their first order.
-- -------------------------------------------------------
SELECT c.customer_id,
       c.signup_date,
       MIN(o.order_date)                             AS first_order_date,
       DATEDIFF(MIN(o.order_date), c.signup_date)   AS days_to_first_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.signup_date
LIMIT 20;


-- Q44. Calculate rolling 7-day revenue for each date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(SUM(daily_rev) OVER (ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7day_revenue
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q45. Find dates in 2023 where no orders were placed (missing dates).
-- -------------------------------------------------------
WITH RECURSIVE all_dates AS (
    SELECT '2023-01-01' AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM all_dates
    WHERE dt < '2023-12-31'
),
order_dates AS (
    SELECT DISTINCT DATE(order_date) AS order_date
    FROM orders
)
SELECT all_dates.dt AS missing_date
FROM all_dates
LEFT JOIN order_dates ON all_dates.dt = order_dates.order_date
WHERE order_dates.order_date IS NULL;


-- Q46. Count successful and failed payments in one query.
-- -------------------------------------------------------
SELECT
    COUNT(CASE WHEN payment_status = 'Success' THEN 1 END) AS successful_payments,
    COUNT(CASE WHEN payment_status = 'Failed'  THEN 1 END) AS failed_payments,
    ROUND(100.0 * COUNT(CASE WHEN payment_status = 'Success' THEN 1 END) / COUNT(*), 2) AS success_rate_pct
FROM payments;


-- Q47. Show each payment method with count of successful payments.
-- -------------------------------------------------------
SELECT payment_method,
       COUNT(*) AS total_payments,
       SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) AS successful,
       ROUND(100.0 * SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) / COUNT(*), 2) AS success_pct
FROM payments
GROUP BY payment_method
ORDER BY successful DESC;


-- Q48. Rank customers by total spending without using window functions.
-- -------------------------------------------------------
SELECT customer_id,
       ROUND(SUM(total_amount), 2) AS total_spent,
       (
           SELECT COUNT(DISTINCT customer_id)
           FROM orders o2
           GROUP BY o2.customer_id
           HAVING SUM(o2.total_amount) > SUM(o1.total_amount)
       ) + 1 AS spending_rank
FROM orders o1
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 20;


-- Q49. Replace NULL in payment_method with 'Unknown'.
-- -------------------------------------------------------
SELECT payment_id,
       order_id,
       COALESCE(payment_method, 'Unknown') AS payment_method,
       payment_status
FROM payments
LIMIT 10;


-- Q50. Update the city of customer_id = 1 to 'Bangalore'.
-- -------------------------------------------------------
UPDATE customers
SET city = 'Bangalore'
WHERE customer_id = 1;

-- Verify the update
SELECT * FROM customers WHERE customer_id = 1;


-- Q51. Delete duplicate orders keeping the one with the lowest order_id.
-- -------------------------------------------------------
DELETE FROM orders
WHERE order_id NOT IN (
    SELECT min_id FROM (
        SELECT MIN(order_id) AS min_id
        FROM orders
        GROUP BY customer_id, order_date, total_amount
    ) AS temp
);


-- Q52. Merge order and payment info into one result set.
-- -------------------------------------------------------
SELECT o.order_id,
       o.customer_id,
       o.order_date,
       o.total_amount,
       p.payment_method,
       p.payment_status
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id
LIMIT 20;


-- Q53. Find gaps in order_id sequence (missing order IDs).
-- -------------------------------------------------------
SELECT o1.order_id + 1 AS missing_order_id
FROM orders o1
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.order_id = o1.order_id + 1
)
AND o1.order_id < (SELECT MAX(order_id) FROM orders)
LIMIT 20;


-- Q54. Calculate cumulative revenue using a correlated subquery.
-- -------------------------------------------------------
WITH daily AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(SUM(daily_rev) OVER (ORDER BY dt), 2) AS cumulative_revenue
FROM daily
ORDER BY dt
LIMIT 30;


-- Q55. Find the first order placed by each customer.
-- -------------------------------------------------------
SELECT customer_id,
       MIN(order_date) AS first_order_date,
       MIN(order_id)   AS first_order_id
FROM orders
GROUP BY customer_id
LIMIT 20;


-- Q56. Find the last (most recent) order placed by each customer.
-- -------------------------------------------------------
SELECT customer_id,
       MAX(order_date) AS last_order_date,
       MAX(order_id)   AS last_order_id
FROM orders
GROUP BY customer_id
LIMIT 20;


-- Q57. Show customers who have never placed any order.
-- -------------------------------------------------------
SELECT c.customer_id, c.name, c.city
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Q58. Anti Join - find customers not present in orders table.
-- -------------------------------------------------------
SELECT customer_id, name
FROM customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
);


-- Q59. Semi Join - find customers who have at least one order.
-- -------------------------------------------------------
SELECT DISTINCT c.customer_id, c.name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);


-- Q60. Combine list of cities from customers table and a manual list using UNION.
-- -------------------------------------------------------
SELECT DISTINCT city FROM customers
UNION
SELECT 'Surat'  AS city
UNION
SELECT 'Indore' AS city;


-- Q61. Show all rows from customers twice using UNION ALL (keeps duplicates).
-- -------------------------------------------------------
SELECT customer_id, city FROM customers
UNION ALL
SELECT customer_id, city FROM customers
LIMIT 20;


-- Q62. INTERSECT logic - customers who ordered in both 2023 and 2024.
-- -------------------------------------------------------
SELECT DISTINCT customer_id
FROM orders
WHERE YEAR(order_date) = 2023
  AND customer_id IN (
      SELECT DISTINCT customer_id
      FROM orders
      WHERE YEAR(order_date) = 2024
  );


-- Q63. EXCEPT logic - customers who ordered in 2023 but NOT in 2024.
-- -------------------------------------------------------
SELECT DISTINCT customer_id
FROM orders
WHERE YEAR(order_date) = 2023
  AND customer_id NOT IN (
      SELECT DISTINCT customer_id
      FROM orders
      WHERE YEAR(order_date) = 2024
  );


-- Q64. Apply string functions on category - UPPER, LOWER, LENGTH.
-- -------------------------------------------------------
SELECT DISTINCT category,
       UPPER(category)  AS upper_category,
       LOWER(category)  AS lower_category,
       LENGTH(category) AS category_length
FROM products;


-- Q65. Trim extra spaces from city names.
-- -------------------------------------------------------
SELECT customer_id,
       TRIM(city) AS cleaned_city
FROM customers
LIMIT 10;


-- Q66. Extract the numeric part from product_name (e.g. 'Product_42' -> 42).
-- -------------------------------------------------------
SELECT product_name,
       CAST(SUBSTRING(product_name, 9) AS UNSIGNED) AS product_number
FROM products
LIMIT 10;


-- Q67. Filter products whose name ends with a 2-digit number using REGEXP.
-- -------------------------------------------------------
SELECT product_name
FROM products
WHERE product_name REGEXP '_[0-9]{2}$'
LIMIT 10;


-- Q68. JSON parsing demo - extract values from a JSON string.
-- -------------------------------------------------------
SELECT
    '{"source":"web","device":"mobile"}' AS sample_json,
    JSON_UNQUOTE(JSON_EXTRACT('{"source":"web","device":"mobile"}', '$.source'))  AS source,
    JSON_UNQUOTE(JSON_EXTRACT('{"source":"web","device":"mobile"}', '$.device'))  AS device;


-- Q69. Assign row numbers to orders sorted by date.
-- -------------------------------------------------------
SELECT order_id,
       customer_id,
       order_date,
       total_amount,
       ROW_NUMBER() OVER (ORDER BY order_date DESC) AS row_num
FROM orders
LIMIT 20;


-- Q70. Rank orders by total amount (RANK gives gaps for ties).
-- -------------------------------------------------------
SELECT order_id,
       total_amount,
       RANK()       OVER (ORDER BY total_amount DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY total_amount DESC) AS rank_no_gaps
FROM orders
LIMIT 20;


-- ================================================================
--               LEVEL 3 : ADVANCED   (Q71 to Q120)
-- ================================================================


-- Q71. Assign a sequence number to each order per customer.
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       total_amount,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM orders
LIMIT 30;


-- Q72. Show difference between RANK and DENSE_RANK on product price.
-- -------------------------------------------------------
SELECT product_id,
       product_name,
       price,
       RANK()       OVER (ORDER BY price DESC) AS rank_value,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank_value
FROM products
ORDER BY price DESC
LIMIT 20;


-- Q73. Find top 3 products by revenue in each category.
-- -------------------------------------------------------
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           ROUND(SUM(oi.quantity * p.price), 2) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_revenue
)
SELECT category, product_name, revenue, rnk
FROM ranked_products
WHERE rnk <= 3
ORDER BY category, rnk;


-- Q74. Find the bottom 2 products by revenue in each category.
-- -------------------------------------------------------
WITH product_revenue AS (
    SELECT p.product_id,
           p.product_name,
           p.category,
           ROUND(SUM(oi.quantity * p.price), 2) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name, p.category
),
ranked_products AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue ASC) AS rnk
    FROM product_revenue
)
SELECT category, product_name, revenue, rnk
FROM ranked_products
WHERE rnk <= 2
ORDER BY category, rnk;


-- Q75. Calculate running total revenue ordered by date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(SUM(daily_rev) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q76. Calculate running average revenue by date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(AVG(daily_rev) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_avg
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q77. Calculate 7-day moving average of daily revenue.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(AVG(daily_rev) OVER (ORDER BY dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7days
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q78. Show each customer's current and previous order amount using LAG.
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       total_amount,
       LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_amount
FROM orders
LIMIT 30;


-- Q79. Show each customer's current and next order amount using LEAD.
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       total_amount,
       LEAD(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_order_amount
FROM orders
LIMIT 30;


-- Q80. Compare current order with previous order and find the change.
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       total_amount,
       LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_amount,
       ROUND(total_amount - LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date), 2) AS change_in_amount
FROM orders
LIMIT 30;


-- Q81. Rank customers by their total spending using DENSE_RANK.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           ROUND(SUM(total_amount), 2) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       total_spent,
       DENSE_RANK() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM customer_spending
ORDER BY spending_rank
LIMIT 20;


-- Q82. Find the number 1 product by revenue in each category.
-- -------------------------------------------------------
WITH product_revenue AS (
    SELECT p.category,
           p.product_name,
           ROUND(SUM(oi.quantity * p.price), 2) AS revenue,
           RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity * p.price) DESC) AS rnk
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, revenue
FROM product_revenue
WHERE rnk = 1;


-- Q83. Show running total of revenue by date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(rev, 2) AS daily_revenue,
       ROUND(SUM(rev) OVER (ORDER BY dt), 2) AS running_total
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q84. Show order sequence number for each customer (1st order, 2nd, 3rd...).
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_number
FROM orders
LIMIT 40;


-- Q85. Find first order of each customer using window function.
-- -------------------------------------------------------
WITH numbered_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM orders
)
SELECT customer_id, order_id, order_date, total_amount
FROM numbered_orders
WHERE rn = 1
LIMIT 20;


-- Q86. Find last order of each customer using window function.
-- -------------------------------------------------------
WITH numbered_orders AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
)
SELECT customer_id, order_id, order_date, total_amount
FROM numbered_orders
WHERE rn = 1
LIMIT 20;


-- Q87. Find number of days between consecutive orders per customer.
-- -------------------------------------------------------
SELECT customer_id,
       order_id,
       order_date,
       LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date,
       DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_between_orders
FROM orders
LIMIT 40;


-- Q88. Find customers who consistently increased their spending across orders.
-- -------------------------------------------------------
WITH order_comparison AS (
    SELECT customer_id,
           order_date,
           total_amount,
           LAG(total_amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_amount
    FROM orders
),
increase_flag AS (
    SELECT customer_id,
           SUM(CASE WHEN total_amount > prev_amount THEN 1 ELSE 0 END) AS increasing_count,
           COUNT(prev_amount) AS total_comparisons
    FROM order_comparison
    WHERE prev_amount IS NOT NULL
    GROUP BY customer_id
)
SELECT customer_id
FROM increase_flag
WHERE increasing_count = total_comparisons
  AND total_comparisons >= 3;


-- Q89. Detect consecutive ordering streaks (3 or more consecutive days).
-- -------------------------------------------------------
WITH daily_orders AS (
    SELECT DISTINCT customer_id, DATE(order_date) AS dt
    FROM orders
),
grouped AS (
    SELECT customer_id,
           dt,
           DATE_SUB(dt, INTERVAL ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY dt) DAY) AS grp_key
    FROM daily_orders
)
SELECT customer_id,
       MIN(dt)  AS streak_start,
       MAX(dt)  AS streak_end,
       COUNT(*) AS streak_length_days
FROM grouped
GROUP BY customer_id, grp_key
HAVING COUNT(*) >= 3
ORDER BY streak_length_days DESC;


-- Q90. Detect gaps in order dates (no order for more than 30 days).
-- -------------------------------------------------------
WITH daily_orders AS (
    SELECT DISTINCT customer_id, DATE(order_date) AS dt
    FROM orders
),
with_next_date AS (
    SELECT customer_id,
           dt,
           LEAD(dt) OVER (PARTITION BY customer_id ORDER BY dt) AS next_dt
    FROM daily_orders
)
SELECT customer_id,
       dt              AS last_order_before_gap,
       next_dt         AS next_order_after_gap,
       DATEDIFF(next_dt, dt) - 1 AS gap_in_days
FROM with_next_date
WHERE DATEDIFF(next_dt, dt) > 30
ORDER BY gap_in_days DESC
LIMIT 20;


-- Q91. Sessionize orders: group each customer's orders into 30-day sessions.
-- -------------------------------------------------------
WITH with_prev AS (
    SELECT customer_id,
           order_id,
           order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_date
    FROM orders
),
session_flags AS (
    SELECT *,
           CASE
               WHEN prev_date IS NULL OR DATEDIFF(order_date, prev_date) > 30
               THEN 1 ELSE 0
           END AS is_new_session
    FROM with_prev
),
sessions AS (
    SELECT *,
           SUM(is_new_session) OVER (PARTITION BY customer_id ORDER BY order_date) AS session_number
    FROM session_flags
)
SELECT customer_id,
       session_number,
       MIN(order_date) AS session_start,
       MAX(order_date) AS session_end,
       COUNT(*)        AS orders_in_session
FROM sessions
GROUP BY customer_id, session_number
ORDER BY customer_id, session_number
LIMIT 30;


-- Q92. Cohort analysis: group customers by their signup month.
-- -------------------------------------------------------
WITH cohort_data AS (
    SELECT c.customer_id,
           DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
           DATE_FORMAT(o.order_date, '%Y-%m')  AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
),
cohort_sizes AS (
    SELECT cohort_month,
           COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_data
    GROUP BY cohort_month
)
SELECT cd.cohort_month,
       cd.order_month,
       COUNT(DISTINCT cd.customer_id)  AS active_customers,
       cs.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT cd.customer_id) / cs.cohort_size, 2) AS retention_pct
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
GROUP BY cd.cohort_month, cd.order_month, cs.cohort_size
ORDER BY cd.cohort_month, cd.order_month
LIMIT 40;


-- Q93. Calculate month-over-month retention rate.
-- -------------------------------------------------------
WITH monthly_active AS (
    SELECT customer_id,
           DATE_FORMAT(order_date, '%Y-%m') AS active_month
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
)
SELECT a.active_month                             AS base_month,
       COUNT(DISTINCT a.customer_id)              AS base_customers,
       COUNT(DISTINCT b.customer_id)              AS retained_next_month,
       ROUND(100.0 * COUNT(DISTINCT b.customer_id) / COUNT(DISTINCT a.customer_id), 2) AS retention_rate_pct
FROM monthly_active a
LEFT JOIN monthly_active b
    ON a.customer_id = b.customer_id
   AND b.active_month = DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(a.active_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
GROUP BY a.active_month
ORDER BY a.active_month;


-- Q94. Detect churned customers: no order in the last 90 days.
-- -------------------------------------------------------
SELECT c.customer_id,
       c.name,
       MAX(o.order_date)                        AS last_order_date,
       DATEDIFF(CURDATE(), MAX(o.order_date))   AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING DATEDIFF(CURDATE(), MAX(o.order_date)) > 90
ORDER BY days_since_last_order DESC
LIMIT 20;


-- Q95. Calculate Customer Lifetime Value (CLV).
-- -------------------------------------------------------
WITH customer_stats AS (
    SELECT customer_id,
           COUNT(*)          AS total_orders,
           SUM(total_amount) AS total_spent,
           MIN(order_date)   AS first_order,
           MAX(order_date)   AS last_order
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       total_orders,
       ROUND(total_spent, 2)                                                AS total_spent,
       ROUND(total_spent / total_orders, 2)                                 AS avg_order_value,
       DATEDIFF(last_order, first_order) + 1                                AS active_days,
       ROUND(total_spent * 365.0 / NULLIF(DATEDIFF(last_order, first_order) + 1, 0), 2) AS estimated_annual_clv
FROM customer_stats
ORDER BY estimated_annual_clv DESC
LIMIT 20;


-- Q96. Find the most frequently purchased product by each customer.
-- -------------------------------------------------------
WITH product_counts AS (
    SELECT o.customer_id,
           oi.product_id,
           SUM(oi.quantity) AS total_qty,
           RANK() OVER (PARTITION BY o.customer_id ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY o.customer_id, oi.product_id
)
SELECT customer_id, product_id, total_qty
FROM product_counts
WHERE rnk = 1
LIMIT 20;


-- Q97. Show each category's revenue and its percentage of total revenue.
-- -------------------------------------------------------
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * p.price) AS cat_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
)
SELECT category,
       ROUND(cat_revenue, 2) AS revenue,
       ROUND(100.0 * cat_revenue / SUM(cat_revenue) OVER (), 2) AS revenue_pct
FROM category_revenue
ORDER BY revenue DESC;


-- Q98. Assign a percentile rank to customers based on their spending.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(total_spent, 2) AS total_spent,
       ROUND(PERCENT_RANK() OVER (ORDER BY total_spent), 4) AS percentile_rank
FROM customer_spending
ORDER BY percentile_rank DESC
LIMIT 20;


-- Q99. Divide customers into 4 equal segments (quartiles) by spending.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(total_spent, 2) AS total_spent,
       NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM customer_spending
ORDER BY spending_quartile, total_spent DESC
LIMIT 40;


-- Q100. Find the median order value.
-- -------------------------------------------------------
WITH ranked_orders AS (
    SELECT total_amount,
           ROW_NUMBER() OVER (ORDER BY total_amount) AS rn,
           COUNT(*) OVER ()                          AS total_count
    FROM orders
)
SELECT ROUND(AVG(total_amount), 2) AS median_order_value
FROM ranked_orders
WHERE rn IN (FLOOR((total_count + 1) / 2), CEIL((total_count + 1) / 2));
-- ================================================================
--               LEVEL 3 CONTINUED   (Q101 to Q120)
-- ================================================================


-- Q101. Find the mode - the most commonly occurring order amount.
-- -------------------------------------------------------
SELECT total_amount,
       COUNT(*) AS frequency
FROM orders
GROUP BY total_amount
ORDER BY frequency DESC
LIMIT 1;


-- Q102. Find the top selling product per day by quantity sold.
-- -------------------------------------------------------
WITH daily_product_sales AS (
    SELECT DATE(o.order_date) AS dt,
           oi.product_id,
           SUM(oi.quantity) AS qty_sold,
           RANK() OVER (PARTITION BY DATE(o.order_date) ORDER BY SUM(oi.quantity) DESC) AS rnk
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY DATE(o.order_date), oi.product_id
)
SELECT dt, product_id, qty_sold
FROM daily_product_sales
WHERE rnk = 1
ORDER BY dt
LIMIT 20;


-- Q103. Show running total of revenue that resets at start of each month.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date)         AS dt,
           YEAR(order_date)         AS yr,
           MONTH(order_date)        AS mo,
           SUM(total_amount)        AS daily_rev
    FROM orders
    GROUP BY DATE(order_date), YEAR(order_date), MONTH(order_date)
)
SELECT dt,
       yr,
       mo,
       ROUND(daily_rev, 2) AS daily_revenue,
       ROUND(SUM(daily_rev) OVER (PARTITION BY yr, mo ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS monthly_running_total
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q104. Show cumulative revenue percentage contribution by date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS daily_rev
    FROM orders
    GROUP BY DATE(order_date)
),
with_cumulative AS (
    SELECT dt,
           daily_rev,
           SUM(daily_rev) OVER (ORDER BY dt)  AS cumulative_rev,
           SUM(daily_rev) OVER ()              AS grand_total
    FROM daily_revenue
)
SELECT dt,
       ROUND(daily_rev, 2)                              AS daily_revenue,
       ROUND(cumulative_rev, 2)                         AS cumulative_revenue,
       ROUND(100.0 * cumulative_rev / grand_total, 2)   AS cumulative_pct
FROM with_cumulative
ORDER BY dt
LIMIT 30;


-- Q105. Find orders that are outliers (amount more than mean + 2 * stddev).
-- -------------------------------------------------------
WITH stats AS (
    SELECT AVG(total_amount)    AS mean_val,
           STDDEV(total_amount) AS std_val
    FROM orders
)
SELECT o.order_id,
       o.customer_id,
       o.total_amount,
       ROUND(s.mean_val, 2) AS mean_value,
       ROUND(s.std_val, 2)  AS std_deviation
FROM orders o, stats s
WHERE o.total_amount > s.mean_val + 2 * s.std_val
ORDER BY o.total_amount DESC
LIMIT 20;


-- Q106. Calculate Z-score for each order amount to spot outliers.
-- -------------------------------------------------------
WITH stats AS (
    SELECT AVG(total_amount)    AS mean_val,
           STDDEV(total_amount) AS std_val
    FROM orders
)
SELECT o.order_id,
       o.total_amount,
       ROUND((o.total_amount - s.mean_val) / NULLIF(s.std_val, 0), 4) AS z_score
FROM orders o, stats s
ORDER BY ABS((o.total_amount - s.mean_val) / NULLIF(s.std_val, 0)) DESC
LIMIT 20;


-- Q107. Rank products by price and show how RANK and DENSE_RANK handle ties.
-- -------------------------------------------------------
SELECT product_id,
       product_name,
       price,
       RANK()       OVER (ORDER BY price DESC) AS rank_with_gaps,
       DENSE_RANK() OVER (ORDER BY price DESC) AS rank_no_gaps
FROM products
ORDER BY price DESC
LIMIT 20;


-- Q108. Use window frame clause to compute different types of sums.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(rev, 2) AS daily_revenue,
       ROUND(SUM(rev) OVER (ORDER BY dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_sum,
       ROUND(SUM(rev) OVER (ORDER BY dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)         AS sum_last_3_rows
FROM daily_revenue
ORDER BY dt
LIMIT 20;


-- Q109. Calculate 30-day sliding window revenue for each date.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE(order_date)
)
SELECT dt,
       ROUND(rev, 2) AS daily_revenue,
       ROUND(SUM(rev) OVER (ORDER BY dt ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS rolling_30day_revenue
FROM daily_revenue
ORDER BY dt
LIMIT 30;


-- Q110. Show running total partitioned by both city and year.
-- -------------------------------------------------------
WITH city_daily AS (
    SELECT c.city,
           YEAR(o.order_date)  AS yr,
           DATE(o.order_date)  AS dt,
           SUM(o.total_amount) AS rev
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.city, YEAR(o.order_date), DATE(o.order_date)
)
SELECT city,
       yr,
       dt,
       ROUND(rev, 2) AS daily_revenue,
       ROUND(SUM(rev) OVER (PARTITION BY city, yr ORDER BY dt), 2) AS running_total_by_city_year
FROM city_daily
ORDER BY city, yr, dt
LIMIT 30;


-- Q111. Chain multiple window functions using CTEs.
-- -------------------------------------------------------
WITH monthly_spend AS (
    SELECT customer_id,
           DATE_FORMAT(order_date, '%Y-%m') AS mo,
           SUM(total_amount) AS monthly_revenue
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
),
with_windows AS (
    SELECT customer_id,
           mo,
           monthly_revenue,
           SUM(monthly_revenue) OVER (PARTITION BY customer_id ORDER BY mo) AS running_total,
           AVG(monthly_revenue) OVER (PARTITION BY customer_id ORDER BY mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3m_avg
    FROM monthly_spend
)
SELECT *
FROM with_windows
ORDER BY customer_id, mo
LIMIT 30;


-- Q112. Compare each customer's spending with their city's average.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id,
           c.city,
           SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.city
)
SELECT customer_id,
       city,
       ROUND(total_spent, 2) AS total_spent,
       ROUND(AVG(total_spent) OVER (PARTITION BY city), 2) AS city_avg_spend,
       ROUND(total_spent - AVG(total_spent) OVER (PARTITION BY city), 2) AS difference_from_city_avg
FROM customer_spending
ORDER BY difference_from_city_avg DESC
LIMIT 20;


-- Q113. Find the top revenue-generating category for each city.
-- -------------------------------------------------------
WITH city_category_revenue AS (
    SELECT c.city,
           p.category,
           ROUND(SUM(oi.quantity * p.price), 2) AS revenue,
           RANK() OVER (PARTITION BY c.city ORDER BY SUM(oi.quantity * p.price) DESC) AS rnk
    FROM customers c
    JOIN orders o      ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN products p    ON oi.product_id  = p.product_id
    GROUP BY c.city, p.category
)
SELECT city, category, revenue
FROM city_category_revenue
WHERE rnk = 1
ORDER BY city;


-- Q114. Calculate month-over-month revenue growth rate.
-- -------------------------------------------------------
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS mo,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT mo,
       ROUND(rev, 2) AS revenue,
       ROUND(LAG(rev) OVER (ORDER BY mo), 2) AS prev_month_revenue,
       ROUND(100.0 * (rev - LAG(rev) OVER (ORDER BY mo)) / NULLIF(LAG(rev) OVER (ORDER BY mo), 0), 2) AS mom_growth_pct
FROM monthly_revenue
ORDER BY mo;


-- Q115. Calculate year-over-year revenue growth.
-- -------------------------------------------------------
WITH yearly_revenue AS (
    SELECT YEAR(order_date) AS yr,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY YEAR(order_date)
)
SELECT yr,
       ROUND(rev, 2) AS revenue,
       ROUND(LAG(rev) OVER (ORDER BY yr), 2) AS prev_year_revenue,
       ROUND(100.0 * (rev - LAG(rev) OVER (ORDER BY yr)) / NULLIF(LAG(rev) OVER (ORDER BY yr), 0), 2) AS yoy_growth_pct
FROM yearly_revenue
ORDER BY yr;


-- Q116. Calculate month-over-month growth separately for each category.
-- -------------------------------------------------------
WITH monthly_cat AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS mo,
           p.category,
           SUM(oi.quantity * p.price)         AS rev
    FROM orders o
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category
)
SELECT mo,
       category,
       ROUND(rev, 2) AS revenue,
       ROUND(LAG(rev) OVER (PARTITION BY category ORDER BY mo), 2) AS prev_month_revenue,
       ROUND(100.0 * (rev - LAG(rev) OVER (PARTITION BY category ORDER BY mo)) / NULLIF(LAG(rev) OVER (PARTITION BY category ORDER BY mo), 0), 2) AS mom_growth_pct
FROM monthly_cat
ORDER BY category, mo
LIMIT 40;


-- Q117. Rank only those orders where payment was done via UPI.
-- -------------------------------------------------------
WITH upi_orders AS (
    SELECT o.order_id,
           o.customer_id,
           o.total_amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_method = 'UPI'
      AND p.payment_status  = 'Success'
)
SELECT order_id,
       customer_id,
       total_amount,
       RANK() OVER (ORDER BY total_amount DESC) AS upi_order_rank
FROM upi_orders
ORDER BY upi_order_rank
LIMIT 20;


-- Q118. Group orders into revenue buckets of 500 rupees.
-- -------------------------------------------------------
SELECT order_id,
       total_amount,
       CONCAT(FLOOR(total_amount / 500) * 500, ' - ', (FLOOR(total_amount / 500) + 1) * 500) AS amount_bucket
FROM orders
ORDER BY total_amount
LIMIT 30;


-- Q119. Perform RFM analysis to segment customers.
-- -------------------------------------------------------
WITH rfm_base AS (
    SELECT customer_id,
           DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
           COUNT(*)                              AS frequency,
           SUM(total_amount)                     AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT customer_id,
           recency,
           frequency,
           ROUND(monetary, 2) AS monetary,
           NTILE(5) OVER (ORDER BY recency    ASC)  AS r_score,
           NTILE(5) OVER (ORDER BY frequency  DESC) AS f_score,
           NTILE(5) OVER (ORDER BY monetary   DESC) AS m_score
    FROM rfm_base
)
SELECT customer_id,
       recency,
       frequency,
       monetary,
       r_score,
       f_score,
       m_score,
       r_score + f_score + m_score AS total_rfm_score
FROM rfm_scores
ORDER BY total_rfm_score DESC
LIMIT 20;


-- Q120. Funnel analysis: from order placed to payment success.
-- -------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM orders)                                       AS step1_total_orders,
    (SELECT COUNT(*) FROM payments)                                      AS step2_payment_attempted,
    (SELECT COUNT(*) FROM payments WHERE payment_status = 'Success')     AS step3_payment_success,
    ROUND(100.0 * (SELECT COUNT(*) FROM payments WHERE payment_status = 'Success') / (SELECT COUNT(*) FROM orders), 2) AS overall_conversion_pct;


-- ================================================================
--               LEVEL 4 : EXPERT   (Q121 to Q160)
-- ================================================================


-- Q121. Advanced cohort retention: show retention % for each month since signup.
-- -------------------------------------------------------
WITH cohort_base AS (
    SELECT c.customer_id,
           DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month
    FROM customers c
    WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
),
activity AS (
    SELECT o.customer_id,
           DATE_FORMAT(o.order_date, '%Y-%m') AS order_month
    FROM orders o
    GROUP BY o.customer_id, DATE_FORMAT(o.order_date, '%Y-%m')
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_base
    GROUP BY cohort_month
)
SELECT cb.cohort_month,
       a.order_month,
       COUNT(DISTINCT cb.customer_id) AS retained_customers,
       cs.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT cb.customer_id) / cs.cohort_size, 2) AS retention_pct
FROM cohort_base cb
JOIN activity a ON cb.customer_id = a.customer_id
JOIN cohort_sizes cs ON cb.cohort_month = cs.cohort_month
GROUP BY cb.cohort_month, a.order_month, cs.cohort_size
ORDER BY cb.cohort_month, a.order_month
LIMIT 40;


-- Q122. Multi-step funnel: total orders → payments attempted → successful payments.
-- -------------------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)                                                    AS step1_orders_placed,
    COUNT(DISTINCT p.order_id)                                                    AS step2_payment_attempted,
    COUNT(DISTINCT CASE WHEN p.payment_status = 'Success' THEN p.order_id END)   AS step3_payment_success,
    ROUND(100.0 * COUNT(DISTINCT p.order_id) / COUNT(DISTINCT o.order_id), 2)                                   AS order_to_payment_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN p.payment_status = 'Success' THEN p.order_id END) / COUNT(DISTINCT o.order_id), 2) AS order_to_success_pct
FROM orders o
LEFT JOIN payments p ON o.order_id = p.order_id;


-- Q123. Track the order journey for each customer (ordered list of orders).
-- -------------------------------------------------------
SELECT customer_id,
       GROUP_CONCAT(order_id ORDER BY order_date SEPARATOR ' -> ') AS order_journey,
       COUNT(*) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 20;


-- Q124. Use a recursive CTE to generate a list of dates (date series).
-- -------------------------------------------------------
WITH RECURSIVE date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS dt
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series
    WHERE dt < '2024-01-31'
)
SELECT dt
FROM date_series;


-- Q125. Recursive CTE for hierarchical data (org tree example).
-- -------------------------------------------------------
-- Note: This uses a hypothetical employees table to show the pattern.
-- CREATE TABLE employees (emp_id INT, name VARCHAR(50), manager_id INT);
WITH RECURSIVE org_tree AS (
    SELECT emp_id, name, manager_id, 1 AS level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.name, e.manager_id, ot.level + 1
    FROM employees e
    JOIN org_tree ot ON e.manager_id = ot.emp_id
)
SELECT emp_id, name, level
FROM org_tree
ORDER BY level, emp_id;


-- Q126. Graph traversal: find customers who bought same products (1 hop).
-- -------------------------------------------------------
SELECT DISTINCT a.customer_id AS customer_1,
                b.customer_id AS customer_2,
                ai.product_id AS shared_product
FROM orders a
JOIN order_items ai ON a.order_id = ai.order_id
JOIN order_items bi ON ai.product_id = bi.product_id
JOIN orders b       ON bi.order_id   = b.order_id
WHERE a.customer_id <> b.customer_id
LIMIT 20;


-- Q127. Path finding using recursion: trace first 4 orders per customer.
-- -------------------------------------------------------
WITH RECURSIVE order_path AS (
    SELECT customer_id,
           order_id,
           order_date,
           CAST(order_id AS CHAR(500)) AS path,
           1 AS depth
    FROM orders
    WHERE (customer_id, order_date) IN (
        SELECT customer_id, MIN(order_date)
        FROM orders
        GROUP BY customer_id
    )
    UNION ALL
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           CONCAT(op.path, ' -> ', o.order_id),
           op.depth + 1
    FROM orders o
    JOIN order_path op ON o.customer_id = op.customer_id
                       AND o.order_date > op.order_date
    WHERE op.depth < 4
)
SELECT customer_id, path, depth
FROM order_path
WHERE depth = 4
LIMIT 10;


-- Q128. Chain window functions: show 3-month rolling average and deviation.
-- -------------------------------------------------------
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS mo,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT mo,
       ROUND(rev, 2) AS monthly_revenue,
       ROUND(AVG(rev) OVER (ORDER BY mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS rolling_3m_avg,
       ROUND(rev - AVG(rev) OVER (ORDER BY mo ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS deviation_from_avg
FROM monthly_revenue
ORDER BY mo;


-- Q129. Apply window function only for a specific condition (UPI + Success).
-- -------------------------------------------------------
WITH filtered_orders AS (
    SELECT o.order_id,
           o.customer_id,
           o.total_amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_method = 'UPI'
      AND p.payment_status  = 'Success'
)
SELECT order_id,
       customer_id,
       total_amount,
       RANK() OVER (ORDER BY total_amount DESC) AS rank_among_upi
FROM filtered_orders
ORDER BY rank_among_upi
LIMIT 20;


-- Q130. Pivot revenue by top categories across months.
-- -------------------------------------------------------
WITH category_monthly AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS mo,
           p.category,
           SUM(oi.quantity * p.price)         AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), p.category
)
SELECT mo,
       ROUND(SUM(CASE WHEN category = 'Electronics' THEN revenue END), 2) AS Electronics,
       ROUND(SUM(CASE WHEN category = 'Clothing'    THEN revenue END), 2) AS Clothing,
       ROUND(SUM(CASE WHEN category = 'Home'        THEN revenue END), 2) AS Home,
       ROUND(SUM(CASE WHEN category = 'Grocery'     THEN revenue END), 2) AS Grocery,
       ROUND(SUM(CASE WHEN category = 'Sports'      THEN revenue END), 2) AS Sports
FROM category_monthly
GROUP BY mo
ORDER BY mo;


-- Q131. Simulate real-time aggregation on the latest 1000 orders.
-- -------------------------------------------------------
WITH latest_orders AS (
    SELECT * FROM orders
    ORDER BY order_date DESC
    LIMIT 1000
)
SELECT COUNT(*)                    AS total_orders,
       ROUND(SUM(total_amount), 2) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value,
       ROUND(MAX(total_amount), 2) AS max_order,
       ROUND(MIN(total_amount), 2) AS min_order
FROM latest_orders;


-- Q132. Streaming-style query: fetch orders from the last 15 minutes.
-- -------------------------------------------------------
SELECT order_id,
       customer_id,
       order_date,
       total_amount
FROM orders
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 15 MINUTE)
ORDER BY order_date DESC;


-- Q133. Feature engineering: build a feature table for ML.
-- -------------------------------------------------------
SELECT c.customer_id,
       c.city,
       DATEDIFF(CURDATE(), c.signup_date)                                             AS tenure_days,
       COUNT(o.order_id)                                                               AS total_orders,
       ROUND(SUM(o.total_amount), 2)                                                   AS total_spent,
       ROUND(AVG(o.total_amount), 2)                                                   AS avg_order_value,
       ROUND(STDDEV(o.total_amount), 2)                                                AS spend_std_dev,
       DATEDIFF(CURDATE(), MAX(o.order_date))                                          AS recency_days,
       SUM(CASE WHEN p.payment_method = 'UPI'    THEN 1 ELSE 0 END)                   AS upi_payment_count,
       ROUND(SUM(CASE WHEN p.payment_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(p.payment_id), 0), 2) AS payment_failure_rate_pct
FROM customers c
LEFT JOIN orders o   ON c.customer_id = o.customer_id
LEFT JOIN payments p ON o.order_id    = p.order_id
GROUP BY c.customer_id, c.city, c.signup_date
LIMIT 20;


-- Q134. Extract time-based features from order_date for ML input.
-- -------------------------------------------------------
SELECT order_id,
       customer_id,
       YEAR(order_date)                                                AS year,
       MONTH(order_date)                                               AS month,
       DAY(order_date)                                                 AS day,
       DAYOFWEEK(order_date)                                           AS day_of_week,
       DAYOFYEAR(order_date)                                           AS day_of_year,
       QUARTER(order_date)                                             AS quarter,
       WEEK(order_date)                                                AS week_number,
       CASE WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 1 ELSE 0 END   AS is_weekend,
       total_amount
FROM orders
LIMIT 20;


-- Q135. Calculate session-level metrics per customer (30-day sessions).
-- -------------------------------------------------------
WITH session_base AS (
    SELECT customer_id,
           order_id,
           order_date,
           total_amount,
           CASE
               WHEN DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) > 30
                    OR LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) IS NULL
               THEN 1 ELSE 0
           END AS is_new_session
    FROM orders
),
sessions AS (
    SELECT customer_id,
           order_id,
           order_date,
           total_amount,
           SUM(is_new_session) OVER (PARTITION BY customer_id ORDER BY order_date) AS session_num
    FROM session_base
)
SELECT customer_id,
       session_num,
       COUNT(*)                   AS orders_in_session,
       ROUND(SUM(total_amount), 2) AS session_revenue,
       MIN(order_date)            AS session_start,
       MAX(order_date)            AS session_end
FROM sessions
GROUP BY customer_id, session_num
ORDER BY customer_id, session_num
LIMIT 30;


-- Q136. Detect anomaly days where revenue was more than 3 standard deviations from mean.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE(order_date)
),
stats AS (
    SELECT AVG(rev) AS mean_rev, STDDEV(rev) AS std_rev
    FROM daily_revenue
)
SELECT d.dt,
       ROUND(d.rev, 2)    AS daily_revenue,
       ROUND(s.mean_rev, 2) AS mean_revenue,
       ROUND((d.rev - s.mean_rev) / NULLIF(s.std_rev, 0), 2) AS z_score
FROM daily_revenue d, stats s
WHERE ABS((d.rev - s.mean_rev) / NULLIF(s.std_rev, 0)) > 3
ORDER BY ABS((d.rev - s.mean_rev) / NULLIF(s.std_rev, 0)) DESC;


-- Q137. Calculate rolling retention: % of cohort still active each month.
-- -------------------------------------------------------
WITH first_order_month AS (
    SELECT customer_id,
           MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT o.customer_id,
           DATE_FORMAT(o.order_date, '%Y-%m') AS active_month,
           f.cohort_month
    FROM orders o
    JOIN first_order_month f ON o.customer_id = f.customer_id
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM first_order_month
    GROUP BY cohort_month
)
SELECT ma.cohort_month,
       ma.active_month,
       COUNT(DISTINCT ma.customer_id) AS active_customers,
       cs.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT ma.customer_id) / cs.cohort_size, 2) AS rolling_retention_pct
FROM monthly_activity ma
JOIN cohort_sizes cs ON ma.cohort_month = cs.cohort_month
GROUP BY ma.cohort_month, ma.active_month, cs.cohort_size
ORDER BY ma.cohort_month, ma.active_month
LIMIT 40;


-- Q138. Survival analysis: what fraction of customers are still ordering at day N.
-- -------------------------------------------------------
WITH customer_span AS (
    SELECT customer_id,
           DATEDIFF(MAX(order_date), MIN(order_date)) AS active_days
    FROM orders
    GROUP BY customer_id
),
buckets AS (
    SELECT FLOOR(active_days / 30) * 30 AS day_bucket,
           COUNT(*) AS customers
    FROM customer_span
    GROUP BY FLOOR(active_days / 30) * 30
)
SELECT day_bucket,
       customers,
       ROUND(100.0 * SUM(customers) OVER (ORDER BY day_bucket DESC) / SUM(customers) OVER (), 2) AS survival_pct
FROM buckets
ORDER BY day_bucket;


-- Q139. A/B test: compare average order value for UPI vs Credit Card.
-- -------------------------------------------------------
SELECT p.payment_method,
       COUNT(o.order_id)                  AS order_count,
       ROUND(AVG(o.total_amount), 2)      AS avg_order_value,
       ROUND(STDDEV(o.total_amount), 2)   AS std_dev,
       ROUND(SUM(o.total_amount), 2)      AS total_revenue
FROM orders o
JOIN payments p ON o.order_id = p.order_id
WHERE p.payment_method IN ('UPI', 'Credit Card')
  AND p.payment_status = 'Success'
GROUP BY p.payment_method;


-- Q140. Calculate t-statistic for UPI vs Credit Card order values.
-- -------------------------------------------------------
WITH group_stats AS (
    SELECT p.payment_method,
           AVG(o.total_amount)   AS mean_val,
           STDDEV(o.total_amount) AS std_val,
           COUNT(o.order_id)      AS n
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_method IN ('UPI', 'Credit Card')
      AND p.payment_status = 'Success'
    GROUP BY p.payment_method
),
upi    AS (SELECT * FROM group_stats WHERE payment_method = 'UPI'),
cc     AS (SELECT * FROM group_stats WHERE payment_method = 'Credit Card')
SELECT
    ROUND(upi.mean_val - cc.mean_val, 2) AS mean_difference,
    ROUND(SQRT((upi.std_val * upi.std_val / upi.n) + (cc.std_val * cc.std_val / cc.n)), 4) AS standard_error,
    ROUND((upi.mean_val - cc.mean_val) / NULLIF(SQRT((upi.std_val * upi.std_val / upi.n) + (cc.std_val * cc.std_val / cc.n)), 0), 4) AS t_statistic
FROM upi, cc;


-- Q141. Calculate 95% confidence interval for average order value.
-- -------------------------------------------------------
WITH stats AS (
    SELECT AVG(total_amount)    AS mean_val,
           STDDEV(total_amount) AS std_val,
           COUNT(*)             AS n
    FROM orders
)
SELECT ROUND(mean_val, 2)                              AS mean_aov,
       ROUND(mean_val - 1.96 * std_val / SQRT(n), 2)  AS lower_bound_95,
       ROUND(mean_val + 1.96 * std_val / SQRT(n), 2)  AS upper_bound_95
FROM stats;


-- Q142. Calculate probability of payment success for each payment method.
-- -------------------------------------------------------
SELECT payment_method,
       COUNT(*)                                                          AS total_attempts,
       SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END)      AS successes,
       ROUND(SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) * 1.0 / COUNT(*), 4) AS probability_of_success
FROM payments
GROUP BY payment_method
ORDER BY probability_of_success DESC;


-- Q143. Forecast next month's revenue using linear trend.
-- -------------------------------------------------------
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS mo,
           SUM(total_amount)                AS rev,
           ROW_NUMBER() OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS t
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
params AS (
    SELECT COUNT(*)     AS n,
           SUM(t)       AS sum_t,
           SUM(rev)     AS sum_y,
           SUM(t * rev) AS sum_ty,
           SUM(t * t)   AS sum_t2
    FROM monthly_revenue
)
SELECT
    ROUND((sum_ty - sum_t * sum_y / n) / (sum_t2 - sum_t * sum_t / n), 2) AS slope,
    ROUND((sum_y / n) - ((sum_ty - sum_t * sum_y / n) / (sum_t2 - sum_t * sum_t / n)) * (sum_t / n), 2) AS intercept,
    ROUND(
        (sum_y / n) - ((sum_ty - sum_t * sum_y / n) / (sum_t2 - sum_t * sum_t / n)) * (sum_t / n)
        + ((sum_ty - sum_t * sum_y / n) / (sum_t2 - sum_t * sum_t / n)) * (n + 1)
    , 2) AS forecasted_next_month_revenue
FROM params;


-- Q144. Incremental data load pattern: only fetch new unprocessed orders.
-- -------------------------------------------------------
-- This simulates an ETL watermark pattern.
-- Assumption: processed_orders is a staging table with max processed order_id.
SELECT *
FROM orders
WHERE order_id > (
    SELECT COALESCE(MAX(order_id), 0)
    FROM processed_orders
)
ORDER BY order_id;


-- Q145. Deduplication: keep only the latest record per customer.
-- -------------------------------------------------------
WITH latest_per_customer AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS rn
    FROM orders
)
SELECT order_id, customer_id, order_date, total_amount
FROM latest_per_customer
WHERE rn = 1
LIMIT 20;


-- Q146. SCD Type 2 pattern: detect and track changes in customer city.
-- -------------------------------------------------------
WITH customer_history AS (
    SELECT customer_id,
           city,
           signup_date AS effective_from,
           LEAD(signup_date) OVER (PARTITION BY customer_id ORDER BY signup_date) AS effective_to
    FROM customers
)
SELECT customer_id,
       city,
       effective_from,
       COALESCE(effective_to, '9999-12-31') AS effective_to,
       CASE WHEN effective_to IS NULL THEN 'Yes' ELSE 'No' END AS is_current_record
FROM customer_history;


-- Q147. Enrich orders with all dimensional info (fact + dimension join).
-- -------------------------------------------------------
SELECT o.order_id,
       c.name              AS customer_name,
       c.city,
       o.order_date,
       o.total_amount,
       p.payment_method,
       p.payment_status,
       pr.product_name,
       pr.category,
       pr.price,
       oi.quantity,
       ROUND(oi.quantity * pr.price, 2) AS line_item_revenue
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN payments    p  ON o.order_id    = p.order_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    pr ON oi.product_id = pr.product_id
LIMIT 20;


-- Q148. Star schema query: revenue by city, category and year.
-- -------------------------------------------------------
SELECT c.city,
       p.category,
       YEAR(o.order_date) AS order_year,
       ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
GROUP BY c.city, p.category, YEAR(o.order_date)
ORDER BY total_revenue DESC
LIMIT 30;


-- Q149. Snowflake schema style query: aggregate at multiple levels.
-- -------------------------------------------------------
WITH product_level AS (
    SELECT p.category,
           p.product_name,
           SUM(oi.quantity)           AS total_qty,
           SUM(oi.quantity * p.price) AS product_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT category,
       COUNT(DISTINCT product_name)      AS total_products,
       SUM(total_qty)                    AS total_units_sold,
       ROUND(SUM(product_revenue), 2)    AS total_revenue,
       ROUND(AVG(product_revenue), 2)    AS avg_revenue_per_product
FROM product_level
GROUP BY category
ORDER BY total_revenue DESC;


-- Q150. Write a single end-to-end executive summary query.
-- -------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM customers)                                       AS total_customers,
    (SELECT COUNT(DISTINCT customer_id) FROM orders)                       AS customers_who_ordered,
    (SELECT COUNT(*) FROM orders)                                          AS total_orders,
    (SELECT ROUND(SUM(total_amount), 2) FROM orders)                       AS gross_revenue,
    (SELECT ROUND(SUM(o.total_amount), 2)
     FROM orders o JOIN payments p ON o.order_id = p.order_id
     WHERE p.payment_status = 'Success')                                   AS net_revenue,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders)                       AS avg_order_value,
    (SELECT COUNT(*) FROM payments WHERE payment_status = 'Failed')        AS failed_payments,
    (SELECT COUNT(DISTINCT category) FROM products)                        AS product_categories;


-- ================================================================
--              LEVEL 5 : REAL WORLD   (Q161 to Q200)
-- ================================================================


-- Q161. Find the top 1% customers by total revenue.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
with_ntile AS (
    SELECT customer_id,
           total_spent,
           NTILE(100) OVER (ORDER BY total_spent ASC) AS pct_tile
    FROM customer_spending
)
SELECT customer_id,
       ROUND(total_spent, 2) AS total_spent
FROM with_ntile
WHERE pct_tile = 100
ORDER BY total_spent DESC;


-- Q162. Find what % of total revenue comes from top 20% customers (Pareto rule).
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
with_quintile AS (
    SELECT customer_id,
           total_spent,
           NTILE(5) OVER (ORDER BY total_spent DESC) AS quintile
    FROM customer_spending
)
SELECT
    ROUND(SUM(CASE WHEN quintile = 1 THEN total_spent END), 2)   AS top_20pct_revenue,
    ROUND(SUM(total_spent), 2)                                    AS total_revenue,
    ROUND(100.0 * SUM(CASE WHEN quintile = 1 THEN total_spent END) / SUM(total_spent), 2) AS pct_from_top_20
FROM with_quintile;


-- Q163. Identify power users: top 5% customers by order frequency.
-- -------------------------------------------------------
WITH order_frequency AS (
    SELECT customer_id,
           COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
),
with_rank AS (
    SELECT customer_id,
           order_count,
           NTILE(20) OVER (ORDER BY order_count ASC) AS freq_tile
    FROM order_frequency
)
SELECT customer_id, order_count
FROM with_rank
WHERE freq_tile = 20
ORDER BY order_count DESC;


-- Q164. Detect suspicious customers with 5 or more orders in a single day.
-- -------------------------------------------------------
SELECT o.customer_id,
       DATE(o.order_date)   AS order_day,
       COUNT(o.order_id)    AS orders_in_day
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id, DATE(o.order_date)
HAVING COUNT(o.order_id) >= 5
ORDER BY orders_in_day DESC
LIMIT 20;


-- Q165. Find customers with more than 2 failed payment attempts.
-- -------------------------------------------------------
SELECT o.customer_id,
       COUNT(CASE WHEN p.payment_status = 'Failed' THEN 1 END) AS failed_count,
       COUNT(*) AS total_attempts,
       ROUND(100.0 * COUNT(CASE WHEN p.payment_status = 'Failed' THEN 1 END) / COUNT(*), 2) AS failure_rate_pct
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY o.customer_id
HAVING failed_count > 2
ORDER BY failed_count DESC
LIMIT 20;


-- Q166. Find the most frequently bought together product pairs.
-- -------------------------------------------------------
SELECT a.product_id  AS product_1,
       b.product_id  AS product_2,
       COUNT(*)      AS times_bought_together
FROM order_items a
JOIN order_items b ON a.order_id    = b.order_id
                   AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY times_bought_together DESC
LIMIT 20;


-- Q167. Market basket analysis: find support and confidence for product pairs.
-- -------------------------------------------------------
WITH total_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total_n
    FROM order_items
),
pairs AS (
    SELECT a.product_id AS p1,
           b.product_id AS p2,
           COUNT(DISTINCT a.order_id) AS co_count
    FROM order_items a
    JOIN order_items b ON a.order_id    = b.order_id
                       AND a.product_id < b.product_id
    GROUP BY a.product_id, b.product_id
),
p1_counts AS (
    SELECT product_id, COUNT(DISTINCT order_id) AS p1_freq
    FROM order_items
    GROUP BY product_id
)
SELECT pr.p1,
       pr.p2,
       pr.co_count AS times_together,
       ROUND(pr.co_count * 1.0 / t.total_n, 4)  AS support,
       ROUND(pr.co_count * 1.0 / pc.p1_freq, 4) AS confidence
FROM pairs pr
JOIN p1_counts pc ON pr.p1 = pc.product_id
CROSS JOIN total_orders t
ORDER BY support DESC
LIMIT 20;


-- Q168. Find cross-sell opportunity: customers who bought Electronics but not Clothing.
-- -------------------------------------------------------
SELECT DISTINCT o.customer_id
FROM orders o
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE p.category = 'Electronics'
  AND o.customer_id NOT IN (
      SELECT DISTINCT o2.customer_id
      FROM orders o2
      JOIN order_items oi2 ON o2.order_id    = oi2.order_id
      JOIN products p2     ON oi2.product_id = p2.product_id
      WHERE p2.category = 'Clothing'
  )
LIMIT 20;


-- Q169. Find customers who switched from one product category to another over time.
-- -------------------------------------------------------
WITH first_category_purchase AS (
    SELECT o.customer_id,
           p.category,
           MIN(o.order_date) AS first_bought_date
    FROM orders o
    JOIN order_items oi ON o.order_id    = oi.order_id
    JOIN products p     ON oi.product_id = p.product_id
    GROUP BY o.customer_id, p.category
)
SELECT a.customer_id,
       a.category  AS from_category,
       b.category  AS to_category,
       a.first_bought_date,
       b.first_bought_date AS switched_on
FROM first_category_purchase a
JOIN first_category_purchase b ON a.customer_id   = b.customer_id
                               AND a.category     <> b.category
                               AND a.first_bought_date < b.first_bought_date
LIMIT 20;


-- Q170. Find products with no sales in the last 30 days (product churn).
-- -------------------------------------------------------
SELECT p.product_id,
       p.product_name,
       p.category,
       MAX(o.order_date)                          AS last_sale_date,
       DATEDIFF(CURDATE(), MAX(o.order_date))     AS days_since_last_sale
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o       ON oi.order_id  = o.order_id
GROUP BY p.product_id, p.product_name, p.category
HAVING DATEDIFF(CURDATE(), MAX(o.order_date)) > 30
ORDER BY days_since_last_sale DESC
LIMIT 20;


-- Q171. Show seasonal revenue trends by quarter for each year.
-- -------------------------------------------------------
SELECT YEAR(order_date)    AS year,
       QUARTER(order_date) AS quarter,
       ROUND(SUM(total_amount), 2) AS quarterly_revenue
FROM orders
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY year, quarter;


-- Q172. Find peak order hours by revenue.
-- -------------------------------------------------------
SELECT HOUR(order_date)            AS hour_of_day,
       COUNT(*)                    AS total_orders,
       ROUND(SUM(total_amount), 2) AS total_revenue
FROM orders
GROUP BY HOUR(order_date)
ORDER BY total_revenue DESC;


-- Q173. Compare revenue on weekdays vs weekends.
-- -------------------------------------------------------
SELECT
    CASE
        WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*)                     AS total_orders,
    ROUND(SUM(total_amount), 2)  AS total_revenue,
    ROUND(AVG(total_amount), 2)  AS avg_order_value
FROM orders
GROUP BY day_type;


-- Q174. Show monthly new customer acquisition trend.
-- -------------------------------------------------------
SELECT DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
       COUNT(*)                          AS new_customers
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY signup_month;


-- Q175. Predict lifetime revenue for next 3 years based on current spend rate.
-- -------------------------------------------------------
WITH customer_stats AS (
    SELECT customer_id,
           DATEDIFF(MAX(order_date), MIN(order_date)) + 1 AS active_days,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(total_spent, 2)                                                 AS total_spent_so_far,
       active_days,
       ROUND(total_spent * 365.0 / NULLIF(active_days, 0), 2)               AS projected_annual_revenue,
       ROUND(total_spent * 365.0 * 3 / NULLIF(active_days, 0), 2)           AS projected_3yr_ltv
FROM customer_stats
ORDER BY projected_3yr_ltv DESC
LIMIT 20;


-- Q176. Calculate retention rate by cohort week.
-- -------------------------------------------------------
WITH cohort_week AS (
    SELECT customer_id,
           YEARWEEK(MIN(order_date)) AS cohort_wk
    FROM orders
    GROUP BY customer_id
),
weekly_activity AS (
    SELECT o.customer_id,
           YEARWEEK(o.order_date) AS active_wk
    FROM orders o
),
cohort_sizes AS (
    SELECT cohort_wk, COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_week
    GROUP BY cohort_wk
)
SELECT cw.cohort_wk,
       wa.active_wk,
       wa.active_wk - cw.cohort_wk              AS weeks_after_cohort,
       COUNT(DISTINCT cw.customer_id)            AS retained_customers,
       cs.cohort_size,
       ROUND(100.0 * COUNT(DISTINCT cw.customer_id) / cs.cohort_size, 2) AS retention_pct
FROM cohort_week cw
JOIN weekly_activity wa ON cw.customer_id = wa.customer_id
JOIN cohort_sizes cs    ON cw.cohort_wk   = cs.cohort_wk
GROUP BY cw.cohort_wk, wa.active_wk, cs.cohort_size
ORDER BY cw.cohort_wk, weeks_after_cohort
LIMIT 40;


-- Q177. Calculate daily active customers (DAC).
-- -------------------------------------------------------
SELECT DATE(order_date)           AS day,
       COUNT(DISTINCT customer_id) AS daily_active_customers
FROM orders
GROUP BY DATE(order_date)
ORDER BY day;


-- Q178. Calculate monthly active users (MAU).
-- -------------------------------------------------------
SELECT DATE_FORMAT(order_date, '%Y-%m')  AS month,
       COUNT(DISTINCT customer_id)       AS monthly_active_users
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;


-- Q179. Calculate DAU/MAU ratio (stickiness metric).
-- -------------------------------------------------------
WITH daily_active AS (
    SELECT DATE(order_date)                AS day,
           DATE_FORMAT(order_date, '%Y-%m') AS month,
           COUNT(DISTINCT customer_id)      AS dau
    FROM orders
    GROUP BY DATE(order_date), DATE_FORMAT(order_date, '%Y-%m')
),
monthly_active AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           COUNT(DISTINCT customer_id)       AS mau
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT da.day,
       da.month,
       da.dau,
       ma.mau,
       ROUND(100.0 * da.dau / ma.mau, 2) AS dau_mau_ratio_pct
FROM daily_active da
JOIN monthly_active ma ON da.month = ma.month
ORDER BY da.day
LIMIT 30;


-- Q180. Calculate an engagement score for each customer.
-- -------------------------------------------------------
WITH customer_metrics AS (
    SELECT customer_id,
           COUNT(*)          AS order_count,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
),
with_percentile AS (
    SELECT customer_id,
           order_count,
           total_spent,
           PERCENT_RANK() OVER (ORDER BY order_count)   AS order_pct_rank,
           PERCENT_RANK() OVER (ORDER BY total_spent)   AS spend_pct_rank
    FROM customer_metrics
)
SELECT customer_id,
       order_count,
       ROUND(total_spent, 2) AS total_spent,
       ROUND(order_pct_rank * 0.4 + spend_pct_rank * 0.6, 4) AS engagement_score
FROM with_percentile
ORDER BY engagement_score DESC
LIMIT 20;


-- Q181. Find long-term inactive customers (no order in 180+ days).
-- -------------------------------------------------------
SELECT c.customer_id,
       c.name,
       c.city,
       MAX(o.order_date)                       AS last_order_date,
       DATEDIFF(CURDATE(), MAX(o.order_date))  AS days_inactive
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
HAVING days_inactive >= 180
ORDER BY days_inactive DESC
LIMIT 20;


-- Q182. Find reactivated customers who came back after 90+ days of inactivity.
-- -------------------------------------------------------
WITH order_gaps AS (
    SELECT customer_id,
           order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date
    FROM orders
)
SELECT DISTINCT customer_id
FROM order_gaps
WHERE DATEDIFF(order_date, prev_order_date) > 90
ORDER BY customer_id
LIMIT 20;


-- Q183. Show order frequency distribution (how many customers placed N orders).
-- -------------------------------------------------------
WITH order_counts AS (
    SELECT customer_id,
           COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT order_count,
       COUNT(*) AS number_of_customers
FROM order_counts
GROUP BY order_count
ORDER BY order_count;


-- Q184. Find the median number of days between orders per customer.
-- -------------------------------------------------------
WITH order_gaps AS (
    SELECT customer_id,
           DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS gap_days
    FROM orders
),
ranked_gaps AS (
    SELECT customer_id,
           gap_days,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY gap_days) AS rn,
           COUNT(*) OVER (PARTITION BY customer_id)                        AS cnt
    FROM order_gaps
    WHERE gap_days IS NOT NULL
)
SELECT customer_id,
       ROUND(AVG(gap_days), 1) AS median_days_between_orders
FROM ranked_gaps
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY customer_id
ORDER BY median_days_between_orders
LIMIT 20;


-- Q185. Find customers with high revenue volatility (coefficient of variation).
-- -------------------------------------------------------
WITH customer_stats AS (
    SELECT customer_id,
           AVG(total_amount)    AS mean_order,
           STDDEV(total_amount) AS std_order,
           COUNT(*)             AS order_count
    FROM orders
    GROUP BY customer_id
    HAVING order_count >= 5
)
SELECT customer_id,
       ROUND(mean_order, 2) AS avg_order_value,
       ROUND(std_order, 2)  AS std_deviation,
       ROUND(100.0 * std_order / NULLIF(mean_order, 0), 2) AS coefficient_of_variation_pct
FROM customer_stats
ORDER BY coefficient_of_variation_pct DESC
LIMIT 20;


-- Q186. Detect days where revenue suddenly dropped below 50% of 7-day average.
-- -------------------------------------------------------
WITH daily_revenue AS (
    SELECT DATE(order_date) AS dt,
           SUM(total_amount) AS rev
    FROM orders
    GROUP BY DATE(order_date)
),
with_moving_avg AS (
    SELECT dt,
           rev,
           AVG(rev) OVER (ORDER BY dt ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS moving_avg_7d
    FROM daily_revenue
)
SELECT dt,
       ROUND(rev, 2)            AS daily_revenue,
       ROUND(moving_avg_7d, 2)  AS seven_day_avg,
       ROUND(100.0 * rev / NULLIF(moving_avg_7d, 0), 2) AS pct_of_avg
FROM with_moving_avg
WHERE rev < 0.5 * moving_avg_7d
ORDER BY pct_of_avg ASC
LIMIT 20;


-- Q187. Show top 20 products by revenue in the last 30 days.
-- -------------------------------------------------------
SELECT p.product_id,
       p.product_name,
       p.category,
       SUM(oi.quantity)                        AS total_units_sold,
       ROUND(SUM(oi.quantity * p.price), 2)    AS revenue_last_30_days
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o       ON oi.order_id  = o.order_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue_last_30_days DESC
LIMIT 20;


-- Q188. Identify customers who upgraded or downgraded their spending over time.
-- -------------------------------------------------------
WITH customer_half_spend AS (
    SELECT customer_id,
           AVG(CASE WHEN order_date < DATE_ADD(MIN(order_date) OVER (PARTITION BY customer_id), INTERVAL 6 MONTH)
                    THEN total_amount END) AS early_avg_spend,
           AVG(CASE WHEN order_date >= DATE_ADD(MIN(order_date) OVER (PARTITION BY customer_id), INTERVAL 6 MONTH)
                    THEN total_amount END) AS late_avg_spend
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(early_avg_spend, 2) AS early_avg_spend,
       ROUND(late_avg_spend, 2)  AS late_avg_spend,
       CASE
           WHEN late_avg_spend > early_avg_spend THEN 'Upgraded'
           WHEN late_avg_spend < early_avg_spend THEN 'Downgraded'
           ELSE 'Stable'
       END AS spending_behavior
FROM customer_half_spend
WHERE early_avg_spend IS NOT NULL
  AND late_avg_spend  IS NOT NULL
ORDER BY spending_behavior
LIMIT 30;


-- Q189. Find loyal customers who placed orders every month for 3+ consecutive months.
-- -------------------------------------------------------
WITH monthly_orders AS (
    SELECT customer_id,
           DATE_FORMAT(order_date, '%Y-%m') AS mo
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
),
grouped_months AS (
    SELECT customer_id,
           mo,
           DATE_SUB(
               STR_TO_DATE(CONCAT(mo, '-01'), '%Y-%m-%d'),
               INTERVAL ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY mo) MONTH
           ) AS group_key
    FROM monthly_orders
),
streaks AS (
    SELECT customer_id,
           group_key,
           COUNT(*) AS consecutive_months
    FROM grouped_months
    GROUP BY customer_id, group_key
)
SELECT DISTINCT customer_id
FROM streaks
WHERE consecutive_months >= 3
ORDER BY customer_id
LIMIT 20;


-- Q190. Find high churn risk customers: order frequency declining for 3+ months.
-- -------------------------------------------------------
WITH monthly_order_counts AS (
    SELECT customer_id,
           DATE_FORMAT(order_date, '%Y-%m') AS mo,
           COUNT(*) AS monthly_orders
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
),
with_mom_change AS (
    SELECT customer_id,
           mo,
           monthly_orders,
           monthly_orders - LAG(monthly_orders) OVER (PARTITION BY customer_id ORDER BY mo) AS mom_change
    FROM monthly_order_counts
)
SELECT customer_id,
       SUM(CASE WHEN mom_change < 0 THEN 1 ELSE 0 END) AS months_declining,
       COUNT(*) AS total_months_tracked
FROM with_mom_change
WHERE mom_change IS NOT NULL
GROUP BY customer_id
HAVING months_declining >= 3
ORDER BY months_declining DESC
LIMIT 20;


-- Q191. Build a composite customer scoring system.
-- -------------------------------------------------------
WITH rfm_base AS (
    SELECT customer_id,
           DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
           COUNT(*)                              AS frequency,
           SUM(total_amount)                     AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT customer_id,
           NTILE(5) OVER (ORDER BY recency   ASC)  AS r_score,
           NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
           NTILE(5) OVER (ORDER BY monetary  DESC) AS m_score
    FROM rfm_base
)
SELECT customer_id,
       r_score AS recency_score,
       f_score AS frequency_score,
       m_score AS monetary_score,
       (r_score * 3 + f_score * 2 + m_score * 5) AS composite_score
FROM rfm_scores
ORDER BY composite_score DESC
LIMIT 20;


-- Q192. Segment customers into Bronze, Silver, Gold, Platinum tiers.
-- -------------------------------------------------------
WITH customer_spending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT customer_id,
       ROUND(total_spent, 2) AS total_spent,
       CASE
           WHEN total_spent >= 100000 THEN 'Platinum'
           WHEN total_spent >=  50000 THEN 'Gold'
           WHEN total_spent >=  20000 THEN 'Silver'
           ELSE 'Bronze'
       END AS customer_tier
FROM customer_spending
ORDER BY total_spent DESC
LIMIT 30;


-- Q193. Detect possible duplicate accounts (same city, signup within 1 day).
-- -------------------------------------------------------
SELECT a.customer_id AS customer_a,
       b.customer_id AS customer_b,
       a.city,
       a.signup_date AS signup_a,
       b.signup_date AS signup_b,
       ABS(DATEDIFF(a.signup_date, b.signup_date)) AS days_apart
FROM customers a
JOIN customers b ON a.city          = b.city
                AND a.customer_id   < b.customer_id
                AND ABS(DATEDIFF(a.signup_date, b.signup_date)) <= 1
ORDER BY days_apart
LIMIT 20;


-- Q194. Merge duplicate customers by reassigning orders to keep the lower ID.
-- -------------------------------------------------------
-- Step 1: Find duplicates (same city + signup_date)
WITH duplicates AS (
    SELECT MIN(customer_id) AS keep_id,
           city,
           signup_date
    FROM customers
    GROUP BY city, signup_date
    HAVING COUNT(*) > 1
)
-- Step 2: Update orders to point to the kept customer_id
UPDATE orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN duplicates d ON c.city = d.city AND c.signup_date = d.signup_date
SET o.customer_id = d.keep_id
WHERE o.customer_id <> d.keep_id;


-- Q195. Revenue attribution: credit revenue to the city where customer first ordered.
-- -------------------------------------------------------
WITH customer_first_order AS (
    SELECT o.customer_id,
           c.city,
           MIN(o.order_date) AS first_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY o.customer_id, c.city
)
SELECT fo.city,
       COUNT(DISTINCT fo.customer_id)        AS customers_acquired,
       ROUND(SUM(o.total_amount), 2)         AS attributed_revenue
FROM customer_first_order fo
JOIN orders o ON fo.customer_id = o.customer_id
GROUP BY fo.city
ORDER BY attributed_revenue DESC;


-- Q196. Campaign performance: revenue and order count per payment channel.
-- -------------------------------------------------------
SELECT p.payment_method                        AS channel,
       COUNT(DISTINCT o.customer_id)           AS unique_customers,
       COUNT(o.order_id)                       AS total_orders,
       ROUND(SUM(o.total_amount), 2)           AS gross_revenue,
       ROUND(AVG(o.total_amount), 2)           AS avg_order_value,
       SUM(CASE WHEN p.payment_status = 'Failed' THEN 1 ELSE 0 END) AS failed_payments
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY p.payment_method
ORDER BY gross_revenue DESC;


-- Q197. Show revenue contribution and share % for each payment channel.
-- -------------------------------------------------------
WITH channel_revenue AS (
    SELECT p.payment_method AS channel,
           SUM(o.total_amount) AS revenue
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_status = 'Success'
    GROUP BY p.payment_method
)
SELECT channel,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct
FROM channel_revenue
ORDER BY revenue DESC;


-- Q198. Calculate ROI for each payment channel using assumed cost per order.
-- -------------------------------------------------------
WITH assumed_costs AS (
    SELECT 'UPI'         AS channel, 5  AS cost_per_order UNION ALL
    SELECT 'Credit Card',            15                   UNION ALL
    SELECT 'Debit Card',             10                   UNION ALL
    SELECT 'Wallet',                  8                   UNION ALL
    SELECT 'NetBanking',             12
),
channel_revenue AS (
    SELECT p.payment_method        AS channel,
           COUNT(o.order_id)       AS total_orders,
           SUM(o.total_amount)     AS total_revenue
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE p.payment_status = 'Success'
    GROUP BY p.payment_method
)
SELECT cr.channel,
       cr.total_orders,
       ROUND(cr.total_revenue, 2)                                               AS revenue,
       cr.total_orders * ac.cost_per_order                                      AS total_cost,
       ROUND(cr.total_revenue - cr.total_orders * ac.cost_per_order, 2)         AS net_profit,
       ROUND(100.0 * (cr.total_revenue - cr.total_orders * ac.cost_per_order) / NULLIF(cr.total_orders * ac.cost_per_order, 0), 2) AS roi_pct
FROM channel_revenue cr
JOIN assumed_costs ac ON cr.channel = ac.channel
ORDER BY roi_pct DESC;


-- Q199. Classify products by lifecycle stage based on recent growth.
-- -------------------------------------------------------
WITH monthly_sales AS (
    SELECT oi.product_id,
           DATE_FORMAT(o.order_date, '%Y-%m') AS mo,
           SUM(oi.quantity) AS qty_sold
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    GROUP BY oi.product_id, DATE_FORMAT(o.order_date, '%Y-%m')
),
with_growth AS (
    SELECT product_id,
           mo,
           qty_sold,
           ROUND(100.0 * (qty_sold - LAG(qty_sold) OVER (PARTITION BY product_id ORDER BY mo)) / NULLIF(LAG(qty_sold) OVER (PARTITION BY product_id ORDER BY mo), 0), 2) AS growth_pct
    FROM monthly_sales
),
latest_growth AS (
    SELECT product_id,
           growth_pct,
           ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY mo DESC) AS rn
    FROM with_growth
    WHERE growth_pct IS NOT NULL
)
SELECT lg.product_id,
       p.product_name,
       p.category,
       lg.growth_pct AS latest_growth_pct,
       CASE
           WHEN lg.growth_pct > 50  THEN 'Introduction / Hypergrowth'
           WHEN lg.growth_pct > 10  THEN 'Growth'
           WHEN lg.growth_pct >= -5 THEN 'Maturity'
           ELSE 'Decline'
       END AS lifecycle_stage
FROM latest_growth lg
JOIN products p ON lg.product_id = p.product_id
WHERE lg.rn = 1
ORDER BY latest_growth_pct DESC
LIMIT 30;


-- Q200. Full Business Dashboard: one query to show all key business metrics.
-- -------------------------------------------------------
WITH revenue_metrics AS (
    SELECT
        COUNT(DISTINCT o.order_id)                                                      AS total_orders,
        COUNT(DISTINCT o.customer_id)                                                   AS active_customers,
        ROUND(SUM(o.total_amount), 2)                                                   AS gross_revenue,
        ROUND(SUM(CASE WHEN p.payment_status = 'Success' THEN o.total_amount END), 2)  AS net_revenue,
        ROUND(AVG(o.total_amount), 2)                                                   AS avg_order_value
    FROM orders o
    LEFT JOIN payments p ON o.order_id = p.order_id
),
payment_metrics AS (
    SELECT
        ROUND(100.0 * SUM(CASE WHEN payment_status = 'Success' THEN 1 END) / COUNT(*), 2) AS payment_success_rate_pct,
        COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END)                              AS total_failed_payments
    FROM payments
),
customer_health AS (
    SELECT
        COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), last_order) <= 30  THEN customer_id END) AS active_last_30_days,
        COUNT(DISTINCT CASE WHEN DATEDIFF(CURDATE(), last_order) > 90   THEN customer_id END) AS churned_90_plus_days
    FROM (
        SELECT customer_id, MAX(order_date) AS last_order
        FROM orders
        GROUP BY customer_id
    ) last_orders
)
SELECT
    rm.total_orders,
    rm.active_customers,
    rm.gross_revenue,
    rm.net_revenue,
    rm.avg_order_value,
    pm.payment_success_rate_pct,
    pm.total_failed_payments,
    ch.active_last_30_days,
    ch.churned_90_plus_days
FROM revenue_metrics rm, payment_metrics pm, customer_health ch;


-- ============================================================
--              END OF FILE - 200 Questions Done!
-- ============================================================