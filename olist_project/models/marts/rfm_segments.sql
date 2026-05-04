-- Score customers on Recency, Frequency, Monetary value using NTILE()


WITH scores AS (
    SELECT
        customer_unique_id,
        customer_state,
        total_orders,
        total_spend,
        last_order_at,
        days_since_last_order,
        NTILE(5) OVER (ORDER BY last_order_at DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY total_orders)       AS frequency_score,
        NTILE(5) OVER (ORDER BY total_spend)        AS monetary_score
    FROM {{ ref('dim_customers') }}
)
SELECT
    customer_unique_id,
    customer_state,
    total_orders,
    total_spend,
    last_order_at,
    days_since_last_order,
    recency_score,
    frequency_score,
    monetary_score,
    recency_score + frequency_score + monetary_score AS rfm_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 THEN 'Champion'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal'
        WHEN recency_score >= 3 AND frequency_score <= 2 THEN 'Potential Loyalist'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score = 1  AND frequency_score >= 3 THEN 'Cant Lose Them'
        WHEN recency_score = 1                           THEN 'Lost'
        ELSE 'Needs Attention'
    END AS segment
FROM scores
