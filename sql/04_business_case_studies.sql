-- 1. Total Revenue & Order Count
SELECT
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(price + freight_value) AS total_revenue
FROM analytics.fact_order_items;


-- 2. Monthly Revenue Trend
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(i.price + i.freight_value) AS monthly_revenue
FROM analytics.fact_orders o
JOIN analytics.fact_order_items i
    ON o.order_id = i.order_id
GROUP BY month
ORDER BY month;


-- 3. Top 10 Product Categories by Revenue
SELECT
    p.product_category,
    SUM(i.price + i.freight_value) AS revenue
FROM analytics.fact_order_items i
JOIN analytics.dim_products p
    ON i.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue DESC
LIMIT 10;


-- 4. Top 10 Sellers by Revenue
SELECT
    s.seller_id,
    s.seller_state,
    SUM(i.price + i.freight_value) AS revenue
FROM analytics.fact_order_items i
JOIN analytics.dim_sellers s
    ON i.seller_id = s.seller_id
GROUP BY s.seller_id, s.seller_state
ORDER BY revenue DESC
LIMIT 10;


-- 5. Average Delivery Time by Order Status
SELECT
    order_status,
    AVG(delivery_days) AS avg_delivery_days
FROM analytics.fact_orders
WHERE delivery_days IS NOT NULL
GROUP BY order_status;


-- 6. Delivery Delay vs Review Score
SELECT
    r.review_score,
    AVG(o.delivery_days) AS avg_delivery_days
FROM analytics.fact_reviews r
JOIN analytics.fact_orders o
    ON r.order_id = o.order_id
WHERE o.delivery_days IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;


-- 7. Repeat Customers (Customer Lifetime Indicator)
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM analytics.fact_orders o
JOIN analytics.dim_customers c
    ON o.customer_unique_id = c.customer_unique_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY order_count DESC;