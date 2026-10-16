use olist_dw;

drop table if exists dws_customer_user_summary;

create table dws_customer_user_summary(
	customer_unique_id VARCHAR(50) PRIMARY KEY COMMENT '唯一买家ID (一人一行)',
    customer_state VARCHAR(10) NOT NULL COMMENT '买家所在州/省',
    customer_city VARCHAR(50) NOT NULL COMMENT '买家所在城市',
    first_order_time DATETIME NOT NULL COMMENT '首次下单时间',
    last_order_time DATETIME NOT NULL COMMENT '末次下单时间',
    total_order_cnt INT NOT NULL COMMENT '总购买单量',
    total_item_cnt INT NOT NULL COMMENT '总购买件数',
    total_spend_amount DECIMAL(10, 2) NOT NULL COMMENT '累计消费总额',
    avg_order_amount DECIMAL(10, 2) NOT NULL COMMENT '平均客单价',
    max_order_amount DECIMAL(10, 2) NOT NULL COMMENT '单笔最高消费额',
    is_repurchase TINYINT NOT NULL COMMENT '是否复购买家 (1=是, 0=否)'
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='买家全景轻度汇总宽表';

insert into dws_customer_user_summary(
	customer_unique_id,
    customer_state,
    customer_city,
    first_order_time,
    last_order_time,
    total_order_cnt,
    total_item_cnt,
    total_spend_amount,
    avg_order_amount,
    max_order_amount,
    is_repurchase
)
select 
	c.customer_unique_id,
    MAX(c.customer_state) AS customer_state,
    MAX(c.customer_city) AS customer_city,
    MIN(f.order_purchase_timestamp) AS first_order_time,
    MAX(f.order_purchase_timestamp) AS last_order_time,
    COUNT(DISTINCT f.order_id) AS total_order_cnt,
    COUNT(f.order_item_id) AS total_item_cnt,
    ROUND(SUM(f.total_amount), 2) AS total_spend_amount,
    ROUND(SUM(f.total_amount) / COUNT(DISTINCT f.order_id), 2) AS avg_order_amount,
    ROUND(MAX(f.total_amount), 2) AS max_order_amount,
    CASE WHEN COUNT(DISTINCT f.order_id) > 1 THEN 1 ELSE 0 END AS is_repurchase
from dwd_fact_order_detail f
inner join dim_customers c
	on f.customer_sk=c.customer_sk
where f.order_status <> 'canceled'
group by c.customer_unique_id;

SELECT 
    COUNT(*) AS total_customers,
    SUM(is_repurchase) AS repurchase_customers,
    CONCAT(ROUND(AVG(is_repurchase) * 100, 2), '%') AS repurchase_rate
FROM dws_customer_user_summary;