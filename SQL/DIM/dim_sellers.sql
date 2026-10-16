use olist_dw;

drop table if exists  dim_sellers;

create table dim_sellers(
	seller_sk INT AUTO_INCREMENT PRIMARY KEY COMMENT '商家维度代理键 (PK)',
    seller_id VARCHAR(64) NOT NULL COMMENT '商家业务ID (自然键)',
    seller_zip_code_prefix VARCHAR(10) COMMENT '商家邮编前缀',
    seller_city VARCHAR(100) COMMENT '商家所在城市',
    seller_state VARCHAR(10) COMMENT '商家所在联邦州',
    etl_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '数仓入库时间',
    UNIQUE KEY uk_seller_id (seller_id)
)engine=InnoDB default charset=utf8mb4 comment='商家维度表';

insert into dim_sellers(
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
)
select 
	seller_id,
	seller_zip_code_prefix,
	concat(upper(left(seller_city,1)),lower(substring(seller_city,2))),
	upper(seller_state)
from ods_sellers;