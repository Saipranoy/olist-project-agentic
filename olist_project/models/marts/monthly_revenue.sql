-- Revenue trend with month-on-month growth using LAG()
-- Wolf equivalent: the monthly revenue trend for board meetings

WITH monthly AS (
    SELECT
        order_month,
        SUM(order_revenue)  AS revenue,
        COUNT(order_id)     AS order_count,
        AVG(order_revenue)  AS avg_order_value
    FROM {{ ref('fct_orders') }}
    GROUP BY 1
)
SELECT
    order_month,
    revenue,
    order_count,
    avg_order_value,
    LAG(revenue) OVER (ORDER BY order_month)  AS prev_month_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0) * 100)::numeric
    , 2)                                       AS mom_growth_pct
FROM monthly
ORDER BY order_month
