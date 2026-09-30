-- 01_schema.sql : DDL with constraints (SQLite; notes for MySQL/Postgres in README)
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    full_name     TEXT    NOT NULL,
    email         TEXT    NOT NULL UNIQUE,
    phone         TEXT,                                  -- nullable on purpose
    city          TEXT,                                  -- nullable on purpose
    signup_date   DATE    NOT NULL DEFAULT (DATE('now'))
);

CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    name          TEXT NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    name          TEXT    NOT NULL,
    category_id   INTEGER NOT NULL REFERENCES categories(category_id),
    price         REAL    NOT NULL CHECK (price > 0),
    stock_qty     INTEGER NOT NULL DEFAULT 0 CHECK (stock_qty >= 0)
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date    DATE    NOT NULL,
    status        TEXT    NOT NULL DEFAULT 'PLACED'
                  CHECK (status IN ('PLACED','SHIPPED','DELIVERED','CANCELLED')),
    coupon_code   TEXT                                   -- nullable on purpose
);

CREATE TABLE order_items (
    order_id      INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id    INTEGER NOT NULL REFERENCES products(product_id),
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    REAL    NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE payments (
    payment_id    INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL UNIQUE REFERENCES orders(order_id),
    method        TEXT    NOT NULL CHECK (method IN ('UPI','CARD','COD','NETBANKING')),
    amount        REAL    NOT NULL CHECK (amount >= 0),
    paid_at       DATE                                   -- NULL = unpaid (e.g. COD pending)
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_product   ON order_items(product_id);
