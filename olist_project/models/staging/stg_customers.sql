-- IMPORTANT: In Olist, customer_id is generated per order.
-- customer_unique_id is the true customer identifier across orders.


SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
FROM {{ source('raw', 'olist_customers_dataset') }}
