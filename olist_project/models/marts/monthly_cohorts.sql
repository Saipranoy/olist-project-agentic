-- Retention analysis by acquisition month
-- Wolf equivalent: which account cohorts are still ordering 6 months later

WITH cohorts AS (
    SELECT
        customer_unique_id,
        DATE_TRUNC('month', first_order_at) AS cohort_month
    FROM {{ ref('dim_customers') }}
),
orders AS (
    SELECT
        c.customer_unique_id,
        co.cohort_month,
        DATE_TRUNC('month', o.ordered_at)                                      AS order_month,
        ((EXTRACT(YEAR FROM DATE_TRUNC('month', o.ordered_at)) - EXTRACT(YEAR FROM co.cohort_month)) * 12
         + (EXTRACT(MONTH FROM DATE_TRUNC('month', o.ordered_at)) - EXTRACT(MONTH FROM co.cohort_month)))::int  AS months_since_first
    FROM {{ ref('stg_orders') }} o
    JOIN {{ ref('stg_customers') }} c  USING (customer_id)
    JOIN cohorts co                    USING (customer_unique_id)
)
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2
