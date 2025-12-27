-- =====================================================
-- 1. ROW COUNT VALIDATION
-- =====================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.olist_customers
UNION ALL
SELECT 'sellers', COUNT(*) FROM raw.olist_sellers
UNION ALL
SELECT 'products', COUNT(*) FROM raw.olist_products
UNION ALL
SELECT 'orders', COUNT(*) FROM raw.olist_orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM raw.olist_order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM raw.olist_order_payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM raw.olist_order_reviews
UNION ALL
SELECT 'geolocation', COUNT(*) FROM raw.olist_geolocation;


-- =====================================================
-- 2. FOREIGN KEY INTEGRITY CHECKS (ORPHANS)
-- =====================================================

-- Orders without customers
SELECT COUNT(*) AS orphan_orders
FROM raw.olist_orders o
LEFT JOIN raw.olist_customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items without orders
SELECT COUNT(*) AS orphan_order_items
FROM raw.olist_order_items oi
LEFT JOIN raw.olist_orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items without products
SELECT COUNT(*) AS orphan_product_items
FROM raw.olist_order_items oi
LEFT JOIN raw.olist_products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Payments without orders
SELECT COUNT(*) AS orphan_payments
FROM raw.olist_order_payments op
LEFT JOIN raw.olist_orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews without orders
SELECT COUNT(*) AS orphan_reviews
FROM raw.olist_order_reviews r
LEFT JOIN raw.olist_orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- =====================================================
-- 3. NULL / COMPLETENESS CHECKS
-- =====================================================

-- Orders missing critical timestamps
SELECT
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS missing_purchase_time,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS missing_delivery_date
FROM raw.olist_orders;


-- Products missing category
SELECT COUNT(*) AS products_without_category
FROM raw.olist_products
WHERE product_category_name IS NULL;


-- Payments missing value
SELECT COUNT(*) AS payments_without_value
FROM raw.olist_order_payments
WHERE payment_value IS NULL;


-- =====================================================
-- 4. DATE SANITY CHECKS
-- =====================================================

-- Orders delivered before purchase (invalid)
SELECT COUNT(*) AS delivered_before_purchase
FROM raw.olist_orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Extremely long delivery times (> 60 days)
SELECT COUNT(*) AS extreme_delivery_cases
FROM raw.olist_orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date - order_purchase_timestamp > INTERVAL '60 days';


-- =====================================================
-- 5. DUPLICATE BUSINESS KEYS
-- =====================================================

-- Multiple customer_ids mapped to same unique customer
SELECT customer_unique_id, COUNT(DISTINCT customer_id) AS customer_ids
FROM raw.olist_customers
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT customer_id) > 1;


-- Orders with multiple payments
SELECT order_id, COUNT(*) AS payment_count
FROM raw.olist_order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;


-- Multiple reviews per order
SELECT order_id, COUNT(*) AS review_count
FROM raw.olist_order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =====================================================
-- 6. BASIC DISTRIBUTION CHECKS
-- =====================================================

-- Order status distribution
SELECT order_status, COUNT(*) AS orders
FROM raw.olist_orders
GROUP BY order_status
ORDER BY orders DESC;


-- Review score distribution
SELECT review_score, COUNT(*) AS reviews
FROM raw.olist_order_reviews
GROUP BY review_score
ORDER BY review_score;
