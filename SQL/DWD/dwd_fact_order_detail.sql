use olist_dw;

drop table if exists dwd_fact_order_detail;

create table dwd_fact_order_detail(
	order_detail_sk INT AUTO_INCREMENT PRIMARY KEY COMMENT '事实表代理键',
    order_id VARCHAR(64) NOT NULL COMMENT '退化维度: 订单编号',
    order_item_id INT NOT NULL COMMENT '退化维度: 订单明细序号',
    order_status VARCHAR(32) COMMENT '退化维度: 订单状态',
	
    -- 维度代理键 (外键连接线)
    customer_sk INT COMMENT '买家维度代理键 (FK)',
    product_sk INT COMMENT '商品维度代理键 (FK)',
    seller_sk INT COMMENT '商家维度代理键 (FK)',
    -- 关键业务时间戳
    order_purchase_timestamp DATETIME COMMENT '下单时间',
    order_delivered_customer_date DATETIME COMMENT '用户收货时间',
    order_estimated_delivery_date DATETIME COMMENT '预计送达时间',
    
    -- 基础度量指标 (可累加的事实)
    price DECIMAL(10, 2) COMMENT '商品售价',
    freight_value DECIMAL(10, 2) COMMENT '运费金额',
    total_amount DECIMAL(10, 2) COMMENT '商品金额+运费',
    
    etl_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '数仓入库时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细事实表 (DWD层)';

insert into dwd_fact_order_detail(
	order_id,
    order_item_id,
    order_status,
    customer_sk,
    product_sk,
    seller_sk,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    price,
    freight_value,
    total_amount
)
select
	oi.order_id,
    oi.order_item_id,
    o.order_status,
    dc.customer_sk,
    dp.product_sk,
    ds.seller_sk,
    NULLIF(o.order_purchase_timestamp, ''),
    NULLIF(o.order_delivered_customer_date, ''),
    NULLIF(o.order_estimated_delivery_date, ''),
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_amount
from ods_order_items oi
inner join ods_orders o
	on oi.order_id=o.order_id
left join ods_customers c
	on o.customer_id=c.customer_id
left join dim_customers dc
	on c.customer_unique_id=dc.customer_unique_id
left join dim_products dp
	on oi.product_id=dp.product_id
left join dim_sellers ds
	on oi.seller_id=ds.seller_id;


