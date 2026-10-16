use olist_dw;

drop table if exists dim_products;

create table dim_products(
	product_sk INT AUTO_INCREMENT PRIMARY KEY COMMENT '商品维度代理键 (PK)',
    product_id VARCHAR(64) NOT NULL COMMENT '商品自然业务ID',
    product_category_name_pt VARCHAR(100) COMMENT '品类葡文名',
    product_category_name_en VARCHAR(100) COMMENT '品类英文名',
    product_name_length INT COMMENT '商品名称长度',
    product_description_length INT COMMENT '商品描述长度',
    product_photos_qty INT COMMENT '商品照片数量',
    product_weight_g INT COMMENT '商品重量(克)',
    product_length_cm INT COMMENT '商品长度(cm)',
    product_height_cm INT COMMENT '商品高度(cm)',
    product_width_cm INT COMMENT '商品宽度(cm)',
    etl_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '数仓入库时间',
    UNIQUE KEY uk_product_id (product_id)
)engine=InnoDB default charset=utf8mb4 comment="商品维度表";

insert into dim_products(
	product_id,
    product_category_name_pt,
    product_category_name_en,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
)
select
	p.product_id,
    -- 如果品类为空，清洗为 'unknown'
    COALESCE(p.product_category_name, 'unknown'),
    -- 如果英文翻译匹配不到或为空，同样清洗为 'unknown'
    COALESCE(t.product_category_name_english, 'unknown'),
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
from ods_products p
left join ods_category_translation t 
	on p.product_category_name = t.product_category_name;