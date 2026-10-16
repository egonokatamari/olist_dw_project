use olist_dw;
DROP TABLE IF EXISTS ads_logistics_state_summary;

CREATE TABLE ads_logistics_state_summary AS
SELECT 
    c.customer_state,
    -- 明确口径：妥投订单量（避免与大盘全量订单混淆）
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    -- 妥投平均耗时（天）
    ROUND(AVG(
        TIMESTAMPDIFF(
            DAY, 
            STR_TO_DATE(NULLIF(o.order_purchase_timestamp, ''), '%Y-%m-%d %H:%i:%s'), 
            STR_TO_DATE(NULLIF(o.order_delivered_customer_date, ''), '%Y-%m-%d %H:%i:%s')
        )
    ), 1) AS avg_delivery_days,
    -- 妥投平均运费
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_amount
FROM ods_orders o
JOIN ods_customers c ON o.customer_id = c.customer_id
JOIN ods_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL 
  AND o.order_delivered_customer_date != ''
  AND o.order_purchase_timestamp IS NOT NULL
  AND o.order_purchase_timestamp != ''
  AND o.order_delivered_customer_date > o.order_purchase_timestamp
GROUP BY c.customer_state;