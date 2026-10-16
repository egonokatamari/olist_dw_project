use olist_dw;
drop table if exists dim_customers;

create table dim_customers(
	customer_sk INT AUTO_INCREMENT PRIMARY KEY COMMENT '客户维度代理键',
    customer_unique_id VARCHAR(64) NOT NULL COMMENT '客户真实自然人唯一ID (业务键)',
    customer_zip_code_prefix VARCHAR(10) COMMENT '最新邮编前缀',
    customer_city VARCHAR(100) COMMENT '城市',
    customer_state VARCHAR(10) COMMENT '联邦州',
    etl_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '数仓入库时间',
    UNIQUE KEY uk_customer_unique (customer_unique_id)
)engine=InnoDB default charset=utf8mb4 comment="买家维度表";

insert into dim_customers(
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
)
with ranked_customers as (
	select
		customer_unique_id,
		customer_zip_code_prefix,
		customer_city,
		customer_state,
		row_number() over(
			partition by customer_unique_id
			order by customer_id
		)as rn
	from ods_customers
)

select 
	customer_unique_id,
	customer_zip_code_prefix,
	concat(upper(left(customer_city,1)),lower(substring(customer_city,2))),
	upper(customer_state)
from ranked_customers
where rn=1;
