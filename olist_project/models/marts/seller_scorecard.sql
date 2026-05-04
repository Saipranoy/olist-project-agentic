-- Performance ranking per seller with late delivery rate
-- Wolf equivalent: sales rep performance dashboard

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT i.order_id)                                              AS total_orders,
    SUM(i.price)                                                            AS total_revenue,
    ROUND(AVG(r.review_score), 2)                                           AS avg_review_score,
    ROUND(AVG((o.delivered_at::date - o.ordered_at::date)), 1)              AS avg_days_to_deliver,
    ROUND(
        SUM(CASE WHEN o.delivered_at > o.estimated_delivery_at THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100
    , 2)                                                                    AS late_delivery_pct
FROM {{ ref('stg_sellers') }} s
JOIN {{ ref('stg_order_items') }} i USING (seller_id)
JOIN {{ ref('stg_orders') }}      o USING (order_id)
LEFT JOIN {{ ref('stg_reviews') }} r USING (order_id)
GROUP BY 1, 2, 3
