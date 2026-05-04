-- Key decision: we exclude 'canceled' here so no downstream model needs to worry about it
-- Note: Olist uses 'canceled' (one l) — always check raw data spelling

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::timestamp      AS ordered_at,
    order_delivered_customer_date::timestamp AS delivered_at,
    order_estimated_delivery_date::timestamp AS estimated_delivery_at
FROM {{ source('raw', 'olist_orders_dataset') }}
WHERE order_status != 'canceled'
