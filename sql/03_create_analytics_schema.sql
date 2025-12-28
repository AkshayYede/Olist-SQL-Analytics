-- Create analytics schema if it does not exist
CREATE SCHEMA IF NOT EXISTS analytics;

-- Fact table: one row per order
CREATE TABLE analytics.fact_orders (
    order_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    order_status TEXT,
    order_date DATE,
    delivery_date DATE,
    delivery_days INTEGER
);

INSERT INTO analytics.fact_orders (
    order_id,
    customer_unique_id,
    order_status,
    order_date,
    delivery_date,
    delivery_days
)
SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp::date AS order_date,
    o.order_delivered_customer_date::date AS delivery_date,
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN (o.order_delivered_customer_date::date
              - o.order_purchase_timestamp::date)
        ELSE NULL
    END AS delivery_days
FROM raw.olist_orders o
JOIN raw.olist_customers c
    ON o.customer_id = c.customer_id;


-- Fact table: one row per order item
CREATE TABLE analytics.fact_order_items (
    order_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    item_sequence INTEGER,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

INSERT INTO analytics.fact_order_items (
    order_id,
    product_id,
    seller_id,
    item_sequence,
    price,
    freight_value
)
SELECT
    order_id,
    product_id,
    seller_id,
    order_item_id AS item_sequence,
    price,
    freight_value
FROM raw.olist_order_items;


-- Fact table: one row per order (latest review only)
CREATE TABLE analytics.fact_reviews (
    order_id TEXT,
    review_score INTEGER,
    review_creation_date DATE
);

INSERT INTO analytics.fact_reviews (
    order_id,
    review_score,
    review_creation_date
)
SELECT
    r.order_id,
    r.review_score,
    r.review_creation_date::date
FROM raw.olist_order_reviews r
JOIN (
    SELECT
        order_id,
        MAX(review_creation_date) AS latest_review_date
    FROM raw.olist_order_reviews
    GROUP BY order_id
) latest
ON r.order_id = latest.order_id
AND r.review_creation_date = latest.latest_review_date;



-- Dimension table: one row per product
CREATE TABLE analytics.dim_products (
    product_id TEXT PRIMARY KEY,
    product_category TEXT,
    product_weight_g INTEGER
);

INSERT INTO analytics.dim_products (
    product_id,
    product_category,
    product_weight_g
)
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category,
    p.product_weight_g
FROM raw.olist_products p
LEFT JOIN raw.product_category_translation t
    ON p.product_category_name = t.product_category_name;


-- Dimension table: one row per unique customer
CREATE TABLE analytics.dim_customers (
    customer_unique_id TEXT PRIMARY KEY,
    customer_city TEXT,
    customer_state TEXT
);

INSERT INTO analytics.dim_customers (
    customer_unique_id,
    customer_city,
    customer_state
)
SELECT
    customer_unique_id,
    MAX(customer_city) AS customer_city,
    MAX(customer_state) AS customer_state
FROM raw.olist_customers
GROUP BY customer_unique_id;


-- Dimension table: one row per seller
CREATE TABLE analytics.dim_sellers (
    seller_id TEXT PRIMARY KEY,
    seller_city TEXT,
    seller_state TEXT
);

INSERT INTO analytics.dim_sellers (
    seller_id,
    seller_city,
    seller_state
)
SELECT
    seller_id,
    seller_city,
    seller_state
FROM raw.olist_sellers;