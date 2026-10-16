use olist_dw;

drop table if exists dws_trade_category_day_summary;

create table dws_trade_category_day_summary(
	order_date DATE NOT NULL COMMENT '统计日期',
    category_name VARCHAR(100) NOT NULL COMMENT '商品类目名称',
    order_cnt INT NOT NULL COMMENT '成交订单量',
    item_cnt INT NOT NULL COMMENT '销售商品件数',
    product_cnt INT NOT NULL COMMENT '动销商品款数',
    seller_cnt INT NOT NULL COMMENT '动销活跃卖家数',
    gmv_amount DECIMAL(12, 2) NOT NULL COMMENT '成交总GMV (售价+运费)',
    pure_sales_amount DECIMAL(12, 2) NOT NULL COMMENT '商品成交总额 (不含运费)',
    freight_amount DECIMAL(12, 2) NOT NULL COMMENT '运费总额',
    avg_item_price DECIMAL(10, 2) NOT NULL COMMENT '商品件均价',
    PRIMARY KEY (order_date, category_name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品类目销售日汇总宽表 (DWS层)';

insert into dws_trade_category_day_summary(
	order_date,
    category_name,
    order_cnt,
    item_cnt,
    product_cnt,
    seller_cnt,
    gmv_amount,
    pure_sales_amount,
    freight_amount,
    avg_item_price
)
select
	CAST(f.order_purchase_timestamp AS DATE) AS order_date,
    COALESCE(p.product_category_name_en, 'other') AS category_name,
    COUNT(DISTINCT f.order_id) AS order_cnt,
    COUNT(f.order_item_id) AS item_cnt,
    COUNT(DISTINCT f.product_sk) AS product_cnt,
    COUNT(DISTINCT f.seller_sk) AS seller_cnt,
    ROUND(SUM(f.total_amount), 2) AS gmv_amount,
    ROUND(SUM(f.price), 2) AS pure_sales_amount,
    ROUND(SUM(f.freight_value), 2) AS freight_amount,
    ROUND(SUM(f.price) / COUNT(f.order_item_id), 2) AS avg_item_price
from dwd_fact_order_detail f
left join dim_products p
	on f.product_sk = p.product_sk
where f.order_status <> 'canceled'
group by 
	CAST(f.order_purchase_timestamp AS DATE),
    COALESCE(p.product_category_name_en, 'other');
