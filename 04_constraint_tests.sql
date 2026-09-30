-- 04_constraint_tests.sql : each statement below SHOULD FAIL. run_report.py checks that.
-- T1: negative price violates CHECK
INSERT INTO products (name, category_id, price, stock_qty) VALUES ('Bad', 1, -5, 1);
-- T2: duplicate email violates UNIQUE
INSERT INTO customers (full_name, email) VALUES ('Dup', 'aarav.sharma@example.com');
-- T3: missing NOT NULL column
INSERT INTO customers (full_name) VALUES ('No Email');
-- T4: foreign key to a non-existent customer
INSERT INTO orders (customer_id, order_date) VALUES (9999, '2026-09-01');
-- T5: invalid status violates CHECK ... IN (...)
INSERT INTO orders (customer_id, order_date, status) VALUES (1, '2026-09-01', 'LOST');
-- T6: zero quantity violates CHECK (quantity > 0)
INSERT INTO order_items VALUES (1, 24, 0, 299);
-- T7: duplicate composite primary key
INSERT INTO order_items VALUES (1, (SELECT product_id FROM order_items WHERE order_id=1 LIMIT 1), 1, 100);
-- T8: deleting a category still referenced by products violates FK
DELETE FROM categories WHERE category_id = 1;
