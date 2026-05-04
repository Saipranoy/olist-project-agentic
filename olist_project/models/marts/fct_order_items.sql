-- One row per line item, with product and seller context
-- Wolf equivalent: Cin7 order lines joined to product catalogue

SELECT
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value,
    p.product_category_name,
    s.seller_city,
    s.seller_state,
    o.ordered_at,
    DATE_TRUNC('month', o.ordered_at) AS order_month
FROM {{ ref('stg_order_items') }} i
JOIN {{ ref('stg_orders') }}   o USING (order_id)
JOIN {{ ref('stg_products') }} p USING (product_id)
JOIN {{ ref('stg_sellers') }}  s USING (seller_id)
