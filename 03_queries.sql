-- 03_queries.sql : 38 queries. Each starts with "-- Qn:" so run_report.py can split them.

-- ===== A. BASICS: filtering, sorting, aggregates =====
-- Q1: All products, most expensive first
SELECT product_id, name, price FROM products ORDER BY price DESC;

-- Q2: Products priced between 500 and 2000
SELECT name, price FROM products WHERE price BETWEEN 500 AND 2000 ORDER BY price;

-- Q3: Out-of-stock products
SELECT product_id, name FROM products WHERE stock_qty = 0;

-- Q4: Total, average, min and max product price
SELECT COUNT(*) AS n_products, ROUND(AVG(price),2) AS avg_price, MIN(price) AS min_price, MAX(price) AS max_price FROM products;

-- Q5: Number of customers per city (NULL city shown as 'Unknown')
SELECT COALESCE(city,'Unknown') AS city, COUNT(*) AS customers
FROM customers GROUP BY COALESCE(city,'Unknown') ORDER BY customers DESC;

-- Q6: Order count by status
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY orders DESC;

-- Q7: Monthly order volume in 2026
SELECT STRFTIME('%Y-%m', order_date) AS month, COUNT(*) AS orders
FROM orders GROUP BY month ORDER BY month;

-- ===== B. TOP PRODUCTS =====
-- Q8: Top 5 products by units sold (excluding cancelled orders)
SELECT p.name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id ORDER BY units_sold DESC LIMIT 5;

-- Q9: Top 5 products by revenue
SELECT p.name, ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id ORDER BY revenue DESC LIMIT 5;

-- Q10: Revenue by category
SELECT c.name AS category, ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM order_items oi
JOIN orders o     ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p   ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_id ORDER BY revenue DESC;

-- Q11: Best-selling product within each category (window function)
SELECT category, name, units_sold FROM (
  SELECT c.name AS category, p.name, SUM(oi.quantity) AS units_sold,
         RANK() OVER (PARTITION BY c.category_id ORDER BY SUM(oi.quantity) DESC) AS rnk
  FROM order_items oi
  JOIN orders o     ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
  JOIN products p   ON p.product_id = oi.product_id
  JOIN categories c ON c.category_id = p.category_id
  GROUP BY c.category_id, p.product_id
) WHERE rnk = 1;

-- Q12: Products that were never ordered (LEFT JOIN + IS NULL)
SELECT p.product_id, p.name
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_id IS NULL;

-- Q13: Products ordered in more than 10 distinct orders
SELECT p.name, COUNT(DISTINCT oi.order_id) AS orders_containing
FROM products p JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id HAVING orders_containing > 10 ORDER BY orders_containing DESC;

-- Q14: Low-stock but high-demand products (stock < 30 and units sold > 15)
SELECT p.name, p.stock_qty, SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id HAVING p.stock_qty < 30 AND units_sold > 15;

-- Q15: Price-band distribution using CASE
SELECT CASE WHEN price < 500 THEN 'Budget (<500)'
            WHEN price < 2000 THEN 'Mid (500-1999)'
            ELSE 'Premium (2000+)' END AS band,
       COUNT(*) AS products
FROM products GROUP BY band;

-- ===== C. CUSTOMER SPEND =====
-- Q16: Top 5 customers by lifetime spend
SELECT cu.full_name, ROUND(SUM(oi.quantity*oi.unit_price),2) AS lifetime_spend
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id ORDER BY lifetime_spend DESC LIMIT 5;

-- Q17: Average order value (AOV) per customer
SELECT cu.full_name, COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.quantity*oi.unit_price)*1.0/COUNT(DISTINCT o.order_id),2) AS aov
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id ORDER BY aov DESC;

-- Q18: Customers who never placed an order (LEFT JOIN anti-join)
SELECT cu.customer_id, cu.full_name
FROM customers cu LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;

-- Q19: Same as Q18 using NOT EXISTS
SELECT full_name FROM customers cu
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = cu.customer_id);

-- Q20: Repeat customers (3+ non-cancelled orders)
SELECT cu.full_name, COUNT(*) AS orders
FROM customers cu JOIN orders o ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
GROUP BY cu.customer_id HAVING COUNT(*) >= 3 ORDER BY orders DESC;

-- Q21: Customer spend segmentation (Gold / Silver / Bronze)
WITH spend AS (
  SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY o.customer_id)
SELECT cu.full_name, ROUND(COALESCE(s.total,0),2) AS total,
       CASE WHEN s.total >= 30000 THEN 'Gold' WHEN s.total >= 10000 THEN 'Silver' ELSE 'Bronze' END AS tier
FROM customers cu LEFT JOIN spend s ON s.customer_id = cu.customer_id
ORDER BY total DESC;

-- Q22: Each customer's first and most recent order date
SELECT cu.full_name, MIN(o.order_date) AS first_order, MAX(o.order_date) AS last_order
FROM customers cu JOIN orders o ON o.customer_id = cu.customer_id GROUP BY cu.customer_id;

-- Q23: Running total of spend per customer over time (window function)
SELECT cu.full_name, o.order_date,
       ROUND(SUM(SUM(oi.quantity*oi.unit_price)) OVER (PARTITION BY cu.customer_id ORDER BY o.order_date, o.order_id),2) AS running_spend
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id, o.order_id ORDER BY cu.full_name, o.order_date LIMIT 20;

-- Q24: Customers who spend above the overall average (subquery)
WITH t AS (
  SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY o.customer_id)
SELECT cu.full_name, ROUND(t.total,2) AS total
FROM t JOIN customers cu ON cu.customer_id = t.customer_id
WHERE t.total > (SELECT AVG(total) FROM t) ORDER BY t.total DESC;

-- ===== D. NULL HANDLING =====
-- Q25: Customers with missing phone numbers (IS NULL, never = NULL)
SELECT customer_id, full_name FROM customers WHERE phone IS NULL;

-- Q26: Customers with missing city OR phone
SELECT customer_id, full_name, phone, city FROM customers WHERE phone IS NULL OR city IS NULL;

-- Q27: COALESCE to display friendly defaults
SELECT full_name, COALESCE(phone,'N/A') AS phone, COALESCE(city,'Unknown') AS city FROM customers;

-- Q28: Orders with no coupon vs with coupon
SELECT CASE WHEN coupon_code IS NULL THEN 'No coupon' ELSE 'Coupon used' END AS coupon_usage,
       COUNT(*) AS orders FROM orders GROUP BY coupon_usage;

-- Q29: COUNT(*) vs COUNT(column) shows how NULLs are skipped
SELECT COUNT(*) AS all_rows, COUNT(phone) AS with_phone, COUNT(city) AS with_city FROM customers;

-- Q30: Unpaid orders (paid_at IS NULL) that are not cancelled
SELECT o.order_id, o.status, p.method, p.amount
FROM orders o JOIN payments p ON p.order_id = o.order_id WHERE p.paid_at IS NULL;

-- Q31: Non-cancelled orders that have NO payment row at all (LEFT JOIN + NULL)
SELECT o.order_id, o.status FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL AND o.status <> 'CANCELLED';

-- Q32: NULLIF avoids divide-by-zero: coupon-order share of all orders
SELECT ROUND(100.0 * SUM(coupon_code IS NOT NULL) / NULLIF(COUNT(*),0), 1) AS pct_orders_with_coupon FROM orders;

-- ===== E. JOINS (multi-table, self, anti, cross) =====
-- Q33: Full order line report (5-table join)
SELECT o.order_id, cu.full_name, o.order_date, p.name AS product, c.name AS category,
       oi.quantity, oi.unit_price, oi.quantity*oi.unit_price AS line_total
FROM orders o
JOIN customers cu   ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
JOIN categories c   ON c.category_id = p.category_id
ORDER BY o.order_id LIMIT 15;

-- Q34: Payment method mix with revenue
SELECT method, COUNT(*) AS payments, ROUND(SUM(amount),2) AS total_amount FROM payments GROUP BY method ORDER BY total_amount DESC;

-- Q35: Pairs of products bought together (self join on order_items)
SELECT p1.name AS product_a, p2.name AS product_b, COUNT(*) AS times_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON p1.product_id = a.product_id
JOIN products p2 ON p2.product_id = b.product_id
GROUP BY a.product_id, b.product_id ORDER BY times_together DESC LIMIT 5;

-- Q36: Customers in the same city as another customer (self join)
SELECT a.full_name, b.full_name AS neighbour, a.city
FROM customers a JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id
ORDER BY a.city LIMIT 10;

-- Q37: Month-over-month revenue growth (CTE + LAG)
WITH m AS (
  SELECT STRFTIME('%Y-%m', o.order_date) AS month, SUM(oi.quantity*oi.unit_price) AS revenue
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY month)
SELECT month, ROUND(revenue,2) AS revenue,
       ROUND(100.0*(revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month),1) AS mom_pct
FROM m ORDER BY month;

-- Q38: Cancellation rate by category (orders containing that category)
SELECT c.name AS category,
       ROUND(100.0*SUM(o.status='CANCELLED')/COUNT(DISTINCT o.order_id),1) AS cancel_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
JOIN categories c   ON c.category_id = p.category_id
GROUP BY c.category_id ORDER BY cancel_pct DESC;
