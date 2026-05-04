-- One row per unique customer with lifetime metrics

SELECT
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id)                                    AS total_orders,
    SUM(i.price)                                                  AS total_spend,
    AVG(i.price)                                                  AS avg_order_value,
    MIN(o.ordered_at)                                             AS first_order_at,
    MAX(o.ordered_at)                                             AS last_order_at,
    (MAX(o.ordered_at)::date - MIN(o.ordered_at)::date)            AS customer_tenure_days,
    (CURRENT_DATE - MAX(o.ordered_at)::date)                      AS days_since_last_order
FROM {{ ref('stg_customers') }} c
JOIN {{ ref('stg_orders') }}      o USING (customer_id)
JOIN {{ ref('stg_order_items') }} i USING (order_id)
GROUP BY 1, 2, 3
