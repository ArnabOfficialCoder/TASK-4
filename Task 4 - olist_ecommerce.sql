-- Table Creation

CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);

CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id INT,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

CREATE TABLE order_payments (
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value NUMERIC
);

CREATE TABLE order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE products (
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE category_translation (
    product_category_name VARCHAR,
    product_category_name_english VARCHAR
);


-- Quick Import Check for All Tables

SELECT 'orders', COUNT(*) AS rows FROM orders
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;


-- (a) SELECT, WHERE, ORDER BY, GROUP BY

--Example 1: Top 5 delivered orders

SELECT order_id, customer_id, order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered'
ORDER BY order_purchase_timestamp DESC
LIMIT 5;

--Example 2: Orders per customer

SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;


--(b) JOINS (INNER, LEFT, RIGHT)

--INNER JOIN: Orders with customer details

SELECT o.order_id, c.customer_unique_id, o.order_status
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;

--LEFT JOIN: Orders with payments (show all orders even if payment missing)

SELECT o.order_id, p.payment_type, p.payment_value
FROM orders o
LEFT JOIN order_payments p
ON o.order_id = p.order_id;

--RIGHT JOIN: All sellers with their sold products (even if no sales)

SELECT s.seller_id, oi.product_id
FROM sellers s
RIGHT JOIN order_items oi
ON s.seller_id = oi.seller_id;


--(c) Subqueries

--Customers with more than 5 orders

SELECT customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 5;

--Top 5 highest payment orders

SELECT order_id, payment_value
FROM order_payments
WHERE payment_value IN (
    SELECT DISTINCT payment_value
    FROM order_payments
    ORDER BY payment_value DESC
    LIMIT 5
);


--(d) Aggregate Functions (SUM, AVG)

--Total sales and average payment

SELECT SUM(payment_value) AS total_sales,
       AVG(payment_value) AS avg_payment
FROM order_payments;

--Average product price per category

SELECT p.product_category_name, AVG(oi.price) AS avg_price
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name;


--(e) Create Views for Analysis

--Delivered orders view

CREATE VIEW delivered_orders AS
SELECT *
FROM orders
WHERE order_status = 'delivered';

--Check the view

SELECT * FROM delivered_orders LIMIT 10;


--(f) Optimize Queries with Indexes

--Index on customer_id in orders table

CREATE INDEX idx_customer_id ON orders(customer_id);

--Index on purchase date in orders table

CREATE INDEX idx_order_date ON orders(order_purchase_timestamp);
