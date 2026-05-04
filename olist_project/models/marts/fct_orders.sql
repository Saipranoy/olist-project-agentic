-- One row per order, enriched with customer and financial totals


SELECT
    o.order_id,
    o.ordered_at,
    o.delivered_at,
    o.estimated_delivery_at,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    DATE_TRUNC('month', o.ordered_at)               AS order_month,
    SUM(i.price)                                     AS order_revenue,
    SUM(i.freight_value)                             AS freight_cost,
    COUNT(i.order_item_id)                           AS item_count,
    (o.delivered_at::date - o.ordered_at::date)      AS days_to_deliver,
    CASE
        WHEN o.delivered_at > o.estimated_delivery_at THEN true
        ELSE false
    END AS is_late_delivery
FROM {{ ref('stg_orders') }} o
JOIN {{ ref('stg_customers') }} c USING (customer_id)
JOIN {{ ref('stg_order_items') }} i USING (order_id)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 12, 13
