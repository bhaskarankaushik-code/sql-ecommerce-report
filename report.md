# SQL E-commerce Report

_38 queries executed successfully._

## Q1. All products, most expensive first
```sql
SELECT product_id, name, price FROM products ORDER BY price DESC;
```
| product_id | name | price |
|---|---|---|
| 9 | Air Fryer | 5499.0 |
| 3 | Smartwatch | 4999.0 |
| 18 | Cricket Bat | 3499.0 |
| 10 | Mixer Grinder | 3299.0 |
| 13 | Running Shoes | 2999.0 |
| 17 | Dumbbell Set | 2599.0 |
| 2 | Bluetooth Speaker | 2499.0 |
| 14 | Denim Jacket | 2199.0 |
| 1 | Wireless Earbuds | 1999.0 |
| 11 | Non-stick Pan Set | 1799.0 |
| 21 | Trimmer | 1599.0 |
| 4 | USB-C Hub | 1299.0 |
| 23 | Laptop Stand | 1199.0 |
| 22 | Desk Lamp | 999.0 |
| 7 | Data Science Handbook | 899.0 |
| 19 | Face Serum | 899.0 |
| 16 | Yoga Mat | 799.0 |
| 6 | SQL Cookbook | 749.0 |
| 5 | Python Crash Course | 599.0 |
| 8 | Atomic Habits | 499.0 |
| 15 | Cotton T-Shirt | 499.0 |
| 20 | Sunscreen SPF50 | 449.0 |
| 12 | Water Bottle | 349.0 |
| 24 | Notebook Pack | 299.0 |

## Q2. Products priced between 500 and 2000
```sql
SELECT name, price FROM products WHERE price BETWEEN 500 AND 2000 ORDER BY price;
```
| name | price |
|---|---|
| Python Crash Course | 599.0 |
| SQL Cookbook | 749.0 |
| Yoga Mat | 799.0 |
| Data Science Handbook | 899.0 |
| Face Serum | 899.0 |
| Desk Lamp | 999.0 |
| Laptop Stand | 1199.0 |
| USB-C Hub | 1299.0 |
| Trimmer | 1599.0 |
| Non-stick Pan Set | 1799.0 |
| Wireless Earbuds | 1999.0 |

## Q3. Out-of-stock products
```sql
SELECT product_id, name FROM products WHERE stock_qty = 0;
```
| product_id | name |
|---|---|
| 6 | SQL Cookbook |
| 18 | Cricket Bat |

## Q4. Total, average, min and max product price
```sql
SELECT COUNT(*) AS n_products, ROUND(AVG(price),2) AS avg_price, MIN(price) AS min_price, MAX(price) AS max_price FROM products;
```
| n_products | avg_price | min_price | max_price |
|---|---|---|---|
| 24 | 1771.92 | 299.0 | 5499.0 |

## Q5. Number of customers per city (NULL city shown as 'Unknown')
```sql
SELECT COALESCE(city,'Unknown') AS city, COUNT(*) AS customers
FROM customers GROUP BY COALESCE(city,'Unknown') ORDER BY customers DESC;
```
| city | customers |
|---|---|
| Unknown | 6 |
| Mumbai | 4 |
| Chennai | 3 |
| Pune | 2 |
| Hyderabad | 2 |
| Bengaluru | 2 |
| Mysuru | 1 |

## Q6. Order count by status
```sql
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY orders DESC;
```
| status | orders |
|---|---|
| DELIVERED | 40 |
| PLACED | 8 |
| SHIPPED | 7 |
| CANCELLED | 5 |

## Q7. Monthly order volume in 2026
```sql
SELECT STRFTIME('%Y-%m', order_date) AS month, COUNT(*) AS orders
FROM orders GROUP BY month ORDER BY month;
```
| month | orders |
|---|---|
| 2026-01 | 7 |
| 2026-02 | 7 |
| 2026-03 | 6 |
| 2026-04 | 12 |
| 2026-05 | 6 |
| 2026-06 | 3 |
| 2026-07 | 5 |
| 2026-08 | 7 |
| 2026-09 | 7 |

## Q8. Top 5 products by units sold (excluding cancelled orders)
```sql
SELECT p.name, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id ORDER BY units_sold DESC LIMIT 5;
```
| name | units_sold |
|---|---|
| Notebook Pack | 23 |
| Denim Jacket | 23 |
| Desk Lamp | 19 |
| Smartwatch | 19 |
| Cricket Bat | 18 |

## Q9. Top 5 products by revenue
```sql
SELECT p.name, ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_id ORDER BY revenue DESC LIMIT 5;
```
| name | revenue |
|---|---|
| Smartwatch | 94981.0 |
| Cricket Bat | 62982.0 |
| Air Fryer | 54990.0 |
| Denim Jacket | 50577.0 |
| Running Shoes | 47984.0 |

## Q10. Revenue by category
```sql
SELECT c.name AS category, ROUND(SUM(oi.quantity*oi.unit_price),2) AS revenue
FROM order_items oi
JOIN orders o     ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
JOIN products p   ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY c.category_id ORDER BY revenue DESC;
```
| category | revenue |
|---|---|
| Electronics | 153845.0 |
| Home & Kitchen | 133190.0 |
| Fashion | 107044.0 |
| Sports | 92967.0 |
| Books | 29093.0 |
| Beauty | 20681.0 |

## Q11. Best-selling product within each category (window function)
```sql
SELECT category, name, units_sold FROM (
  SELECT c.name AS category, p.name, SUM(oi.quantity) AS units_sold,
         RANK() OVER (PARTITION BY c.category_id ORDER BY SUM(oi.quantity) DESC) AS rnk
  FROM order_items oi
  JOIN orders o     ON o.order_id = oi.order_id AND o.status <> 'CANCELLED'
  JOIN products p   ON p.product_id = oi.product_id
  JOIN categories c ON c.category_id = p.category_id
  GROUP BY c.category_id, p.product_id
) WHERE rnk = 1;
```
| category | name | units_sold |
|---|---|---|
| Electronics | Smartwatch | 19 |
| Books | Notebook Pack | 23 |
| Home & Kitchen | Desk Lamp | 19 |
| Fashion | Denim Jacket | 23 |
| Sports | Cricket Bat | 18 |
| Beauty | Trimmer | 9 |

## Q12. Products that were never ordered (LEFT JOIN + IS NULL)
```sql
SELECT p.product_id, p.name
FROM products p LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_id IS NULL;
```
| product_id | name |
|---|---|

## Q13. Products ordered in more than 10 distinct orders
```sql
SELECT p.name, COUNT(DISTINCT oi.order_id) AS orders_containing
FROM products p JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id HAVING orders_containing > 10 ORDER BY orders_containing DESC;
```
| name | orders_containing |
|---|---|

## Q14. Low-stock but high-demand products (stock < 30 and units sold > 15)
```sql
SELECT p.name, p.stock_qty, SUM(oi.quantity) AS units_sold
FROM products p JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id HAVING p.stock_qty < 30 AND units_sold > 15;
```
| name | stock_qty | units_sold |
|---|---|---|
| Smartwatch | 8 | 21 |
| Cricket Bat | 0 | 18 |
| Desk Lamp | 16 | 21 |

## Q15. Price-band distribution using CASE
```sql
SELECT CASE WHEN price < 500 THEN 'Budget (<500)'
            WHEN price < 2000 THEN 'Mid (500-1999)'
            ELSE 'Premium (2000+)' END AS band,
       COUNT(*) AS products
FROM products GROUP BY band;
```
| band | products |
|---|---|
| Budget (<500) | 5 |
| Mid (500-1999) | 11 |
| Premium (2000+) | 8 |

## Q16. Top 5 customers by lifetime spend
```sql
SELECT cu.full_name, ROUND(SUM(oi.quantity*oi.unit_price),2) AS lifetime_spend
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id ORDER BY lifetime_spend DESC LIMIT 5;
```
| full_name | lifetime_spend |
|---|---|
| Nikhil Joshi | 71410.0 |
| Vikram Singh | 67364.0 |
| Rohan Iyer | 55374.0 |
| Rahul Verma | 49224.0 |
| Aarav Sharma | 44834.0 |

## Q17. Average order value (AOV) per customer
```sql
SELECT cu.full_name, COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(oi.quantity*oi.unit_price)*1.0/COUNT(DISTINCT o.order_id),2) AS aov
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id ORDER BY aov DESC;
```
| full_name | orders | aov |
|---|---|---|
| Riya Patel | 1 | 23292.0 |
| Rahul Verma | 3 | 16408.0 |
| Arjun Menon | 2 | 14996.0 |
| Aarav Sharma | 3 | 14944.67 |
| Ishita Gupta | 3 | 11911.67 |
| Nikhil Joshi | 6 | 11901.67 |
| Vikram Singh | 6 | 11227.33 |
| Rohan Iyer | 5 | 11074.8 |
| Sanjay Kumar | 2 | 9544.5 |
| Sneha Reddy | 4 | 9334.25 |
| Diya Nair | 4 | 7896.0 |
| Meera Pillai | 4 | 7345.25 |
| Neha Kulkarni | 3 | 6477.33 |
| Pooja Hegde | 2 | 6220.0 |
| Karthik Rao | 1 | 3396.0 |
| Aditya Bhat | 2 | 1796.5 |
| Kavya Shetty | 3 | 914.67 |
| Ananya Das | 1 | 599.0 |

## Q18. Customers who never placed an order (LEFT JOIN anti-join)
```sql
SELECT cu.customer_id, cu.full_name
FROM customers cu LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;
```
| customer_id | full_name |
|---|---|
| 19 | Manoj Naidu |
| 20 | Tanvi Desai |

## Q19. Same as Q18 using NOT EXISTS
```sql
SELECT full_name FROM customers cu
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = cu.customer_id);
```
| full_name |
|---|
| Manoj Naidu |
| Tanvi Desai |

## Q20. Repeat customers (3+ non-cancelled orders)
```sql
SELECT cu.full_name, COUNT(*) AS orders
FROM customers cu JOIN orders o ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
GROUP BY cu.customer_id HAVING COUNT(*) >= 3 ORDER BY orders DESC;
```
| full_name | orders |
|---|---|
| Vikram Singh | 6 |
| Nikhil Joshi | 6 |
| Rohan Iyer | 5 |
| Diya Nair | 4 |
| Sneha Reddy | 4 |
| Meera Pillai | 4 |
| Aarav Sharma | 3 |
| Ishita Gupta | 3 |
| Rahul Verma | 3 |
| Kavya Shetty | 3 |
| Neha Kulkarni | 3 |

## Q21. Customer spend segmentation (Gold / Silver / Bronze)
```sql
WITH spend AS (
  SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY o.customer_id)
SELECT cu.full_name, ROUND(COALESCE(s.total,0),2) AS total,
       CASE WHEN s.total >= 30000 THEN 'Gold' WHEN s.total >= 10000 THEN 'Silver' ELSE 'Bronze' END AS tier
FROM customers cu LEFT JOIN spend s ON s.customer_id = cu.customer_id
ORDER BY total DESC;
```
| full_name | total | tier |
|---|---|---|
| Nikhil Joshi | 71410.0 | Gold |
| Vikram Singh | 67364.0 | Gold |
| Rohan Iyer | 55374.0 | Gold |
| Rahul Verma | 49224.0 | Gold |
| Aarav Sharma | 44834.0 | Gold |
| Sneha Reddy | 37337.0 | Gold |
| Ishita Gupta | 35735.0 | Gold |
| Diya Nair | 31584.0 | Gold |
| Arjun Menon | 29992.0 | Silver |
| Meera Pillai | 29381.0 | Silver |
| Riya Patel | 23292.0 | Silver |
| Neha Kulkarni | 19432.0 | Silver |
| Sanjay Kumar | 19089.0 | Silver |
| Pooja Hegde | 12440.0 | Silver |
| Aditya Bhat | 3593.0 | Bronze |
| Karthik Rao | 3396.0 | Bronze |
| Kavya Shetty | 2744.0 | Bronze |
| Ananya Das | 599.0 | Bronze |
| Manoj Naidu | 0.0 | Bronze |
| Tanvi Desai | 0.0 | Bronze |

## Q22. Each customer's first and most recent order date
```sql
SELECT cu.full_name, MIN(o.order_date) AS first_order, MAX(o.order_date) AS last_order
FROM customers cu JOIN orders o ON o.customer_id = cu.customer_id GROUP BY cu.customer_id;
```
| full_name | first_order | last_order |
|---|---|---|
| Aarav Sharma | 2026-02-12 | 2026-07-16 |
| Diya Nair | 2026-02-20 | 2026-09-03 |
| Rohan Iyer | 2026-01-15 | 2026-08-27 |
| Sneha Reddy | 2026-02-23 | 2026-06-25 |
| Karthik Rao | 2026-04-05 | 2026-04-05 |
| Meera Pillai | 2026-01-09 | 2026-09-21 |
| Arjun Menon | 2026-01-19 | 2026-07-22 |
| Ishita Gupta | 2026-01-03 | 2026-06-10 |
| Vikram Singh | 2026-01-01 | 2026-09-28 |
| Ananya Das | 2026-04-09 | 2026-04-09 |
| Rahul Verma | 2026-02-10 | 2026-08-15 |
| Pooja Hegde | 2026-02-17 | 2026-04-21 |
| Nikhil Joshi | 2026-03-23 | 2026-08-05 |
| Kavya Shetty | 2026-03-02 | 2026-08-16 |
| Sanjay Kumar | 2026-04-25 | 2026-09-15 |
| Neha Kulkarni | 2026-04-09 | 2026-09-17 |
| Aditya Bhat | 2026-04-05 | 2026-04-09 |
| Riya Patel | 2026-04-23 | 2026-04-23 |

## Q23. Running total of spend per customer over time (window function)
```sql
SELECT cu.full_name, o.order_date,
       ROUND(SUM(SUM(oi.quantity*oi.unit_price)) OVER (PARTITION BY cu.customer_id ORDER BY o.order_date, o.order_id),2) AS running_spend
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id AND o.status <> 'CANCELLED'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY cu.customer_id, o.order_id ORDER BY cu.full_name, o.order_date LIMIT 20;
```
| full_name | order_date | running_spend |
|---|---|---|
| Aarav Sharma | 2026-02-12 | 1497.0 |
| Aarav Sharma | 2026-03-24 | 18743.0 |
| Aarav Sharma | 2026-07-16 | 44834.0 |
| Aditya Bhat | 2026-04-05 | 898.0 |
| Aditya Bhat | 2026-04-09 | 3593.0 |
| Ananya Das | 2026-04-09 | 599.0 |
| Arjun Menon | 2026-05-17 | 14997.0 |
| Arjun Menon | 2026-07-22 | 29992.0 |
| Diya Nair | 2026-02-20 | 10894.0 |
| Diya Nair | 2026-07-24 | 16191.0 |
| Diya Nair | 2026-08-08 | 30585.0 |
| Diya Nair | 2026-09-03 | 31584.0 |
| Ishita Gupta | 2026-01-03 | 4998.0 |
| Ishita Gupta | 2026-01-26 | 22692.0 |
| Ishita Gupta | 2026-06-10 | 35735.0 |
| Karthik Rao | 2026-04-05 | 3396.0 |
| Kavya Shetty | 2026-03-02 | 349.0 |
| Kavya Shetty | 2026-05-27 | 1246.0 |
| Kavya Shetty | 2026-08-16 | 2744.0 |
| Meera Pillai | 2026-01-09 | 4596.0 |

## Q24. Customers who spend above the overall average (subquery)
```sql
WITH t AS (
  SELECT o.customer_id, SUM(oi.quantity*oi.unit_price) AS total
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY o.customer_id)
SELECT cu.full_name, ROUND(t.total,2) AS total
FROM t JOIN customers cu ON cu.customer_id = t.customer_id
WHERE t.total > (SELECT AVG(total) FROM t) ORDER BY t.total DESC;
```
| full_name | total |
|---|---|
| Nikhil Joshi | 71410.0 |
| Vikram Singh | 67364.0 |
| Rohan Iyer | 55374.0 |
| Rahul Verma | 49224.0 |
| Aarav Sharma | 44834.0 |
| Sneha Reddy | 37337.0 |
| Ishita Gupta | 35735.0 |
| Diya Nair | 31584.0 |
| Arjun Menon | 29992.0 |

## Q25. Customers with missing phone numbers (IS NULL, never = NULL)
```sql
SELECT customer_id, full_name FROM customers WHERE phone IS NULL;
```
| customer_id | full_name |
|---|---|
| 4 | Sneha Reddy |
| 8 | Ishita Gupta |
| 12 | Pooja Hegde |
| 16 | Neha Kulkarni |
| 20 | Tanvi Desai |

## Q26. Customers with missing city OR phone
```sql
SELECT customer_id, full_name, phone, city FROM customers WHERE phone IS NULL OR city IS NULL;
```
| customer_id | full_name | phone | city |
|---|---|---|---|
| 4 | Sneha Reddy | NULL | Mumbai |
| 5 | Karthik Rao | 9810872248 | NULL |
| 7 | Arjun Menon | 9838898923 | NULL |
| 8 | Ishita Gupta | NULL | Bengaluru |
| 9 | Vikram Singh | 9858181396 | NULL |
| 10 | Ananya Das | 9845503389 | NULL |
| 12 | Pooja Hegde | NULL | Bengaluru |
| 16 | Neha Kulkarni | NULL | NULL |
| 18 | Riya Patel | 9895320121 | NULL |
| 20 | Tanvi Desai | NULL | Chennai |

## Q27. COALESCE to display friendly defaults
```sql
SELECT full_name, COALESCE(phone,'N/A') AS phone, COALESCE(city,'Unknown') AS city FROM customers;
```
| full_name | phone | city |
|---|---|---|
| Aarav Sharma | 9877827638 | Mumbai |
| Diya Nair | 9836687537 | Pune |
| Rohan Iyer | 9883140807 | Hyderabad |
| Sneha Reddy | N/A | Mumbai |
| Karthik Rao | 9810872248 | Unknown |
| Meera Pillai | 9866722344 | Chennai |
| Arjun Menon | 9838898923 | Unknown |
| Ishita Gupta | N/A | Bengaluru |
| Vikram Singh | 9858181396 | Unknown |
| Ananya Das | 9845503389 | Unknown |
| Rahul Verma | 9871662963 | Mumbai |
| Pooja Hegde | N/A | Bengaluru |
| Nikhil Joshi | 9894374605 | Mumbai |
| Kavya Shetty | 9835808537 | Pune |
| Sanjay Kumar | 9898753260 | Mysuru |
| Neha Kulkarni | N/A | Unknown |
| Aditya Bhat | 9823556182 | Hyderabad |
| Riya Patel | 9895320121 | Unknown |
| Manoj Naidu | 9859684848 | Chennai |
| Tanvi Desai | N/A | Chennai |

## Q28. Orders with no coupon vs with coupon
```sql
SELECT CASE WHEN coupon_code IS NULL THEN 'No coupon' ELSE 'Coupon used' END AS coupon_usage,
       COUNT(*) AS orders FROM orders GROUP BY coupon_usage;
```
| coupon_usage | orders |
|---|---|
| Coupon used | 28 |
| No coupon | 32 |

## Q29. COUNT(*) vs COUNT(column) shows how NULLs are skipped
```sql
SELECT COUNT(*) AS all_rows, COUNT(phone) AS with_phone, COUNT(city) AS with_city FROM customers;
```
| all_rows | with_phone | with_city |
|---|---|---|
| 20 | 15 | 14 |

## Q30. Unpaid orders (paid_at IS NULL) that are not cancelled
```sql
SELECT o.order_id, o.status, p.method, p.amount
FROM orders o JOIN payments p ON p.order_id = o.order_id WHERE p.paid_at IS NULL;
```
| order_id | status | method | amount |
|---|---|---|---|
| 5 | PLACED | COD | 15493.0 |
| 6 | SHIPPED | COD | 16192.0 |
| 10 | SHIPPED | COD | 12295.0 |
| 13 | PLACED | CARD | 2695.0 |
| 18 | PLACED | COD | 8693.0 |
| 26 | PLACED | NETBANKING | 14997.0 |
| 35 | SHIPPED | COD | 6946.0 |
| 38 | PLACED | COD | 20839.0 |
| 49 | SHIPPED | COD | 4596.0 |
| 52 | PLACED | CARD | 3396.0 |
| 57 | PLACED | COD | 8693.0 |
| 59 | PLACED | COD | 23292.0 |

## Q31. Non-cancelled orders that have NO payment row at all (LEFT JOIN + NULL)
```sql
SELECT o.order_id, o.status FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_id IS NULL AND o.status <> 'CANCELLED';
```
| order_id | status |
|---|---|

## Q32. NULLIF avoids divide-by-zero: coupon-order share of all orders
```sql
SELECT ROUND(100.0 * SUM(coupon_code IS NOT NULL) / NULLIF(COUNT(*),0), 1) AS pct_orders_with_coupon FROM orders;
```
| pct_orders_with_coupon |
|---|
| 46.7 |

## Q33. Full order line report (5-table join)
```sql
SELECT o.order_id, cu.full_name, o.order_date, p.name AS product, c.name AS category,
       oi.quantity, oi.unit_price, oi.quantity*oi.unit_price AS line_total
FROM orders o
JOIN customers cu   ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
JOIN categories c   ON c.category_id = p.category_id
ORDER BY o.order_id LIMIT 15;
```
| order_id | full_name | order_date | product | category | quantity | unit_price | line_total |
|---|---|---|---|---|---|---|---|
| 1 | Rohan Iyer | 2026-03-18 | Running Shoes | Fashion | 3 | 2999.0 | 8997.0 |
| 1 | Rohan Iyer | 2026-03-18 | Air Fryer | Home & Kitchen | 1 | 5499.0 | 5499.0 |
| 1 | Rohan Iyer | 2026-03-18 | Trimmer | Beauty | 3 | 1599.0 | 4797.0 |
| 1 | Rohan Iyer | 2026-03-18 | Laptop Stand | Electronics | 2 | 1199.0 | 2398.0 |
| 2 | Ishita Gupta | 2026-01-26 | Smartwatch | Electronics | 3 | 4999.0 | 14997.0 |
| 2 | Ishita Gupta | 2026-01-26 | Data Science Handbook | Books | 2 | 899.0 | 1798.0 |
| 2 | Ishita Gupta | 2026-01-26 | Face Serum | Beauty | 1 | 899.0 | 899.0 |
| 3 | Nikhil Joshi | 2026-08-05 | Notebook Pack | Books | 3 | 299.0 | 897.0 |
| 3 | Nikhil Joshi | 2026-08-05 | Cricket Bat | Sports | 2 | 3499.0 | 6998.0 |
| 4 | Nikhil Joshi | 2026-06-08 | Smartwatch | Electronics | 3 | 4999.0 | 14997.0 |
| 4 | Nikhil Joshi | 2026-06-08 | Bluetooth Speaker | Electronics | 1 | 2499.0 | 2499.0 |
| 4 | Nikhil Joshi | 2026-06-08 | USB-C Hub | Electronics | 3 | 1299.0 | 3897.0 |
| 4 | Nikhil Joshi | 2026-06-08 | Python Crash Course | Books | 2 | 599.0 | 1198.0 |
| 5 | Nikhil Joshi | 2026-07-20 | Cricket Bat | Sports | 3 | 3499.0 | 10497.0 |
| 5 | Nikhil Joshi | 2026-07-20 | Wireless Earbuds | Electronics | 1 | 1999.0 | 1999.0 |

## Q34. Payment method mix with revenue
```sql
SELECT method, COUNT(*) AS payments, ROUND(SUM(amount),2) AS total_amount FROM payments GROUP BY method ORDER BY total_amount DESC;
```
| method | payments | total_amount |
|---|---|---|
| COD | 17 | 207746.0 |
| NETBANKING | 15 | 143188.0 |
| CARD | 13 | 105136.0 |
| UPI | 10 | 80750.0 |

## Q35. Pairs of products bought together (self join on order_items)
```sql
SELECT p1.name AS product_a, p2.name AS product_b, COUNT(*) AS times_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN products p1 ON p1.product_id = a.product_id
JOIN products p2 ON p2.product_id = b.product_id
GROUP BY a.product_id, b.product_id ORDER BY times_together DESC LIMIT 5;
```
| product_a | product_b | times_together |
|---|---|---|
| Wireless Earbuds | Cricket Bat | 3 |
| Wireless Earbuds | Desk Lamp | 3 |
| Water Bottle | Denim Jacket | 3 |
| Denim Jacket | Cotton T-Shirt | 3 |
| Cotton T-Shirt | Notebook Pack | 3 |

## Q36. Customers in the same city as another customer (self join)
```sql
SELECT a.full_name, b.full_name AS neighbour, a.city
FROM customers a JOIN customers b ON a.city = b.city AND a.customer_id < b.customer_id
ORDER BY a.city LIMIT 10;
```
| full_name | neighbour | city |
|---|---|---|
| Ishita Gupta | Pooja Hegde | Bengaluru |
| Meera Pillai | Manoj Naidu | Chennai |
| Meera Pillai | Tanvi Desai | Chennai |
| Manoj Naidu | Tanvi Desai | Chennai |
| Rohan Iyer | Aditya Bhat | Hyderabad |
| Aarav Sharma | Nikhil Joshi | Mumbai |
| Aarav Sharma | Rahul Verma | Mumbai |
| Aarav Sharma | Sneha Reddy | Mumbai |
| Sneha Reddy | Nikhil Joshi | Mumbai |
| Sneha Reddy | Rahul Verma | Mumbai |

## Q37. Month-over-month revenue growth (CTE + LAG)
```sql
WITH m AS (
  SELECT STRFTIME('%Y-%m', o.order_date) AS month, SUM(oi.quantity*oi.unit_price) AS revenue
  FROM orders o JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status <> 'CANCELLED' GROUP BY month)
SELECT month, ROUND(revenue,2) AS revenue,
       ROUND(100.0*(revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month),1) AS mom_pct
FROM m ORDER BY month;
```
| month | revenue | mom_pct |
|---|---|---|
| 2026-01 | 51973.0 | NULL |
| 2026-02 | 69557.0 | 33.8 |
| 2026-03 | 79673.0 | 14.5 |
| 2026-04 | 73502.0 | -7.7 |
| 2026-05 | 56476.0 | -23.2 |
| 2026-06 | 35634.0 | -36.9 |
| 2026-07 | 71216.0 | 99.9 |
| 2026-08 | 62114.0 | -12.8 |
| 2026-09 | 36675.0 | -41.0 |

## Q38. Cancellation rate by category (orders containing that category)
```sql
SELECT c.name AS category,
       ROUND(100.0*SUM(o.status='CANCELLED')/COUNT(DISTINCT o.order_id),1) AS cancel_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
JOIN categories c   ON c.category_id = p.category_id
GROUP BY c.category_id ORDER BY cancel_pct DESC;
```
| category | cancel_pct |
|---|---|
| Beauty | 16.7 |
| Sports | 11.8 |
| Electronics | 11.5 |
| Books | 11.1 |
| Home & Kitchen | 6.7 |
| Fashion | 5.0 |

## Constraint tests (all must be rejected)

- **T1** negative price violates CHECK: ✅ rejected — CHECK constraint failed: price > 0
- **T2** duplicate email violates UNIQUE: ✅ rejected — UNIQUE constraint failed: customers.email
- **T3** missing NOT NULL column: ✅ rejected — NOT NULL constraint failed: customers.email
- **T4** foreign key to a non-existent customer: ✅ rejected — FOREIGN KEY constraint failed
- **T5** invalid status violates CHECK ... IN (...): ✅ rejected — CHECK constraint failed: status IN ('PLACED','SHIPPED','DELIVERED','CANCELLED')
- **T6** zero quantity violates CHECK (quantity > 0): ✅ rejected — CHECK constraint failed: quantity > 0
- **T7** duplicate composite primary key: ✅ rejected — UNIQUE constraint failed: order_items.order_id, order_items.product_id
- **T8** deleting a category still referenced by products violates FK: ✅ rejected — FOREIGN KEY constraint failed

8/8 constraints enforced.
