-- =====================================================
-- DATABASE
-- =====================================================
CREATE DATABASE olist_db

-- =====================================================
-- SCHEMA
-- =====================================================
CREATE SCHEMA IF NOT EXISTS raw;

-- =====================================================
-- CUSTOMERS
-- =====================================================
CREATE TABLE raw.olist_customers (
    customer_id              TEXT PRIMARY KEY,
    customer_unique_id       TEXT NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city            TEXT,
    customer_state           TEXT
);

-- =====================================================
-- SELLERS
-- =====================================================
CREATE TABLE raw.olist_sellers (
    seller_id              TEXT PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city            TEXT,
    seller_state           TEXT
);

-- =====================================================
-- PRODUCTS
-- =====================================================
CREATE TABLE raw.olist_products (
    product_id                 TEXT PRIMARY KEY,
    product_category_name      TEXT,
    product_name_lenght        INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty         INTEGER,
    product_weight_g           INTEGER,
    product_length_cm          INTEGER,
    product_height_cm          INTEGER,
    product_width_cm           INTEGER
);

-- =====================================================
-- PRODUCT CATEGORY TRANSLATION
-- =====================================================
CREATE TABLE raw.product_category_translation (
    product_category_name          TEXT PRIMARY KEY,
    product_category_name_english  TEXT
);

-- =====================================================
-- GEOLOCATION (NO PK BY DESIGN)
-- =====================================================
CREATE TABLE raw.olist_geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat             NUMERIC(9,6),
    geolocation_lng             NUMERIC(9,6),
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

-- =====================================================
-- ORDERS
-- =====================================================
CREATE TABLE raw.olist_orders (
    order_id                      TEXT PRIMARY KEY,
    customer_id                   TEXT NOT NULL,
    order_status                  TEXT,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES raw.olist_customers(customer_id)
);

-- =====================================================
-- ORDER ITEMS
-- =====================================================
CREATE TABLE raw.olist_order_items (
    order_id            TEXT NOT NULL,
    order_item_id       INTEGER NOT NULL,
    product_id          TEXT NOT NULL,
    seller_id           TEXT NOT NULL,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2),
    CONSTRAINT pk_order_items
        PRIMARY KEY (order_id, order_item_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES raw.olist_orders(order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES raw.olist_products(product_id),
    CONSTRAINT fk_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES raw.olist_sellers(seller_id)
);

-- =====================================================
-- ORDER PAYMENTS
-- =====================================================
CREATE TABLE raw.olist_order_payments (
    order_id             TEXT NOT NULL,
    payment_sequential   INTEGER NOT NULL,
    payment_type         TEXT,
    payment_installments INTEGER,
    payment_value        NUMERIC(10,2),
    CONSTRAINT pk_order_payments
        PRIMARY KEY (order_id, payment_sequential),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES raw.olist_orders(order_id)
);

-- =====================================================
-- ORDER REVIEWS
-- =====================================================
CREATE TABLE raw.olist_order_reviews (
    review_id               TEXT,
    order_id                TEXT NOT NULL,
    review_score            INTEGER,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    CONSTRAINT pk_order_reviews
        PRIMARY KEY (review_id, order_id),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES raw.olist_orders(order_id)
);


