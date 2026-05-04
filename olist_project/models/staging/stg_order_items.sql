-- An order can have multiple items — this is the grain to remember
-- Cancelled orders excluded to match stg_orders filter

SELECT
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value
FROM {{ source('raw', 'olist_order_items_dataset') }} i
WHERE i.order_id IN (
    SELECT order_id
    FROM {{ source('raw', 'olist_orders_dataset') }}
    WHERE order_status != 'canceled'
)
