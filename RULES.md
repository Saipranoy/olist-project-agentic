# Olist Data Rules for Nao

## General rules

- Cancelled orders are excluded from all tables. Never add a filter for cancelled orders manually — they are already removed at the staging layer.
- A customer is always identified by `customer_unique_id`, not `customer_id`. The `customer_id` column is generated per order and is not a true customer identifier.
- All monetary values are in Brazilian Reais (BRL).
- The dataset covers September 2016 to October 2018.

---

## Table: fct_orders

One row per order. The primary table for revenue and delivery analysis.

### Metrics

- **Number of Orders** — COUNT(DISTINCT order_id). Use this for order volume questions.
- **Total Revenue** — SUM(order_revenue). This is the sum of item prices only. It excludes freight. Never add freight_cost to revenue unless the user explicitly asks for total charged amount.
- **Average Order Value** — AVG(order_revenue). Average revenue per order, excluding freight.
- **Total Freight Cost** — SUM(freight_cost). Only use this when the user asks specifically about shipping or freight.
- **Avg Days to Deliver** — AVG(days_to_deliver). Only calculated for delivered orders where days_to_deliver is not null.

### Dimensions (slice and filter by these)

- **order_month** — truncated to month. Use for time series questions. When asked about trends, group by order_month.
- **customer_state** — Brazilian state code (e.g. SP, RJ, MG). Use for geographic questions.
- **is_late_delivery** — boolean. True means the order arrived after the estimated delivery date. Use for delivery performance questions.

---

## Table: rfm_segments

One row per unique customer. Used for customer segmentation and lifetime value analysis.

### Metrics

- **Number of Customers** — COUNT(DISTINCT customer_unique_id). Use for customer count questions.
- **Total Customer Spend** — SUM(total_spend). Total lifetime spend across all customers or a segment.
- **Avg Customer Spend** — AVG(total_spend). Average lifetime spend per customer.
- **Avg Days Since Last Order** — AVG(days_since_last_order). Higher = less recently active.

### Dimensions

- **segment** — RFM segment label. Values are: Champion, Loyal, Potential Loyalist, At Risk, Lost, Needs Attention. Use for customer health questions.

### Segment definitions

- **Champion** — high recency, high frequency. Best customers. Recently ordered and order often.
- **Loyal** — good recency and frequency. Reliable repeat buyers.
- **Potential Loyalist** — recent but low frequency. Could become loyal with nurturing.
- **At Risk** — ordered frequently in the past but not recently. Needs re-engagement.
- **Lost** — very low recency. Have not ordered in a long time.
- **Needs Attention** — low scores across the board. Mid-tier customers going cold.

---

## Table: dim_customers

One row per unique customer with lifetime metrics. Use when the question is about a specific customer or customer attributes.

- `customer_unique_id` is the join key to fct_orders and rfm_segments.
- `total_orders`, `total_spend`, `first_order_at`, `last_order_at` are pre-calculated lifetime metrics.

---

## Table: seller_scorecard

One row per seller. Use for seller or fulfilment performance questions.

- `avg_days_to_deliver` — average delivery time for this seller's orders.
- `late_delivery_pct` — percentage of this seller's orders that arrived late.
- `avg_review_score` — average customer review score (1–5) for this seller.

---

## Table: monthly_revenue

Pre-aggregated monthly revenue trend. Use this for month-on-month growth questions — it already has `mom_growth_pct` calculated. Do not recalculate growth from fct_orders when this table exists.

---

## Common question mappings

- "What is total revenue?" → SUM(order_revenue) FROM fct_orders
- "How many orders?" → COUNT(DISTINCT order_id) FROM fct_orders
- "Which segment has the most customers?" → COUNT(DISTINCT customer_unique_id) FROM rfm_segments GROUP BY segment
- "Which state orders the most?" → COUNT(DISTINCT order_id) FROM fct_orders GROUP BY customer_state
- "What is the late delivery rate?" → SUM(is_late_delivery::int) * 100.0 / COUNT(*) FROM fct_orders
- "Month on month growth?" → SELECT order_month, mom_growth_pct FROM monthly_revenue
