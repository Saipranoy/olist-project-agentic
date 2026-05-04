-- One row per product with sales and review performance

SELECT
    p.product_id,
    p.product_category_name,
    COUNT(DISTINCT i.order_id) AS total_orders,
    SUM(i.price)               AS total_revenue,
    AVG(i.price)               AS avg_price,
    AVG(r.review_score)        AS avg_review_score
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_order_items') }} i USING (product_id)
LEFT JOIN {{ ref('stg_reviews') }}     r USING (order_id)
GROUP BY 1, 2
