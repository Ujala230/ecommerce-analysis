CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
SELECT COUNT(*) FROM ecommerce;
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    SUM(revenue) AS total_revenue
FROM ecommerce;
SELECT 
    customer_id,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    SUM(revenue) AS total_revenue,
    AVG(time_on_site_sec) AS avg_time_on_site
FROM ecommerce
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    customer_id,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(time_on_site_sec), 2) AS avg_time_on_site,
    ROUND(AVG(pages_viewed), 2) AS avg_pages_viewed
FROM ecommerce
GROUP BY customer_id
HAVING SUM(purchased) > 0
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    CASE
        WHEN SUM(purchased) > 1 THEN 'Repeat Customer'
        ELSE 'One-time Customer'
    END AS customer_type,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
GROUP BY customer_id;
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    SUM(total_orders) AS total_orders,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM (
    SELECT
        customer_id,
        CASE
            WHEN SUM(purchased) > 1 THEN 'Repeat Customer'
            ELSE 'One-time Customer'
        END AS customer_type,
        SUM(purchased) AS total_orders,
        SUM(revenue) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
) AS customer_summary
GROUP BY customer_type;
SELECT
    CASE
        WHEN purchased = 1 THEN 'Purchased'
        ELSE 'Not Purchased'
    END AS purchase_status,
    COUNT(*) AS total_sessions,
    ROUND(AVG(time_on_site_sec), 2) AS avg_time_on_site,
    ROUND(AVG(pages_viewed), 2) AS avg_pages_viewed
FROM ecommerce
GROUP BY purchase_status;
SELECT
    customer_id,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(time_on_site_sec), 2) AS avg_time_on_site
FROM ecommerce
GROUP BY customer_id
HAVING SUM(purchased) > 0
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    CASE
        WHEN total_revenue >= 10000 THEN 'High Value'
        WHEN total_revenue >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(AVG(total_revenue), 2) AS avg_customer_revenue
FROM (
    SELECT
        customer_id,
        SUM(revenue) AS total_revenue
    FROM ecommerce
    GROUP BY customer_id
) AS customer_value
GROUP BY customer_segment
ORDER BY total_revenue DESC;
SELECT
    marketing_channel,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_session
FROM ecommerce
GROUP BY marketing_channel
ORDER BY total_revenue DESC;
SELECT
    device_type,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(time_on_site_sec), 2) AS avg_time_on_site
FROM ecommerce
GROUP BY device_type
ORDER BY total_revenue DESC;
SELECT
    product_category,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_session
FROM ecommerce
GROUP BY product_category
ORDER BY total_revenue DESC;
SELECT
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_purchases,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM ecommerce;
SELECT
    COUNT(*) AS total_sessions,
    SUM(added_to_cart) AS cart_sessions,
    SUM(cart_abandoned) AS abandoned_carts,
    ROUND(
        SUM(cart_abandoned) * 100.0 / NULLIF(SUM(added_to_cart), 0),
        2
    ) AS cart_abandonment_rate
FROM ecommerce;
SELECT
    marketing_channel,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
GROUP BY marketing_channel
ORDER BY conversion_rate DESC;
SELECT
    location,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
GROUP BY location
ORDER BY total_revenue DESC;
WITH customer_revenue AS (
    SELECT
        location,
        customer_id,
        ROUND(SUM(revenue), 2) AS total_revenue
    FROM ecommerce
    WHERE purchased = 1
    GROUP BY location, customer_id
),
ranked_customers AS (
    SELECT
        location,
        customer_id,
        total_revenue,
        RANK() OVER (
            PARTITION BY location
            ORDER BY total_revenue DESC
        ) AS customer_rank
    FROM customer_revenue
)
SELECT
    location,
    customer_id,
    total_revenue,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY location, customer_rank;
SELECT visit_date
FROM ecommerce
LIMIT 10;
SELECT
    YEAR(STR_TO_DATE(visit_date, '%d-%m-%Y')) AS visit_year,
    MONTH(STR_TO_DATE(visit_date, '%d-%m-%Y')) AS visit_month,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE purchased = 1
GROUP BY
    YEAR(STR_TO_DATE(visit_date, '%d-%m-%Y')),
    MONTH(STR_TO_DATE(visit_date, '%d-%m-%Y'))
ORDER BY
    visit_year,
    visit_month;
    SELECT
    visit_weekday,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
GROUP BY visit_weekday
ORDER BY conversion_rate DESC;
SELECT
    payment_method,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(
        SUM(purchased) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate
FROM ecommerce
GROUP BY payment_method
ORDER BY total_revenue DESC;
SELECT
    CASE
        WHEN discount_percent = 0 THEN 'No Discount'
        WHEN discount_percent <= 10 THEN 'Low Discount'
        ELSE 'High Discount'
    END AS discount_group,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM ecommerce
GROUP BY discount_group
ORDER BY conversion_rate DESC;
SELECT
    rating,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(
        SUM(purchased) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE rating IS NOT NULL
GROUP BY rating
ORDER BY rating;
SELECT
    purchase_frequency,
    COUNT(*) AS total_customers
FROM (
    SELECT
        customer_id,
        SUM(purchased) AS purchase_frequency
    FROM ecommerce
    GROUP BY customer_id
) AS customer_purchase
GROUP BY purchase_frequency
ORDER BY purchase_frequency;
SELECT
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2) AS average_order_value
FROM ecommerce
WHERE purchased = 1;
SELECT
    product_id,
    product_category,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE purchased = 1
GROUP BY product_id, product_category
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    product_id,
    product_category,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE purchased = 1
GROUP BY product_id, product_category
ORDER BY total_units_sold DESC
LIMIT 10;
SELECT
    product_category,
    SUM(quantity) AS total_units_sold,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE purchased = 1
GROUP BY product_category
ORDER BY total_revenue DESC;
SELECT
    customer_id,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM ecommerce
WHERE purchased = 1
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;
SELECT
    customer_type,
    COUNT(*) AS total_customers,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(
        SUM(total_revenue) * 100.0 /
        (SELECT SUM(total_revenue) FROM (
            SELECT customer_id, SUM(revenue) AS total_revenue
            FROM ecommerce
            WHERE purchased = 1
            GROUP BY customer_id
        ) AS all_customers),
        2
    ) AS revenue_contribution_percent
FROM (
    SELECT
        customer_id,
        CASE
            WHEN SUM(purchased) > 1 THEN 'Repeat Customer'
            ELSE 'One-time Customer'
        END AS customer_type,
        SUM(revenue) AS total_revenue
    FROM ecommerce
    WHERE purchased = 1
    GROUP BY customer_id
) AS customer_data
GROUP BY customer_type;
SELECT
    COUNT(*) AS total_sessions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(purchased) AS total_orders,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(CASE WHEN purchased = 1 THEN revenue END), 2) AS avg_order_value,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate,
    ROUND(SUM(cart_abandoned) * 100.0 / NULLIF(SUM(added_to_cart), 0), 2) AS cart_abandonment_rate
FROM ecommerce;