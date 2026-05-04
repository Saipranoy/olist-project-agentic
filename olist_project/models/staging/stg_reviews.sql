SELECT
    review_id,
    order_id,
    review_score::integer           AS review_score,
    review_creation_date::timestamp AS reviewed_at
FROM {{ source('raw', 'olist_order_reviews_dataset') }}
