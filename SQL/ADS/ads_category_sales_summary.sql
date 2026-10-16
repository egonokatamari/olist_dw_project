USE olist_dw;

DROP TABLE IF EXISTS ads_category_sales_summary;

CREATE TABLE ads_category_sales_summary(
    category_name VARCHAR(100) PRIMARY KEY COMMENT '商品类目',
    order_cnt INT NOT NULL COMMENT '独立订单数',
    item_cnt INT NOT NULL COMMENT '售出商品件数',
    active_product_cnt INT NOT NULL COMMENT '去重动销商品款数',
    active_seller_cnt INT NOT NULL COMMENT '去重活跃卖家数',
    gmv_amount DECIMAL(12,2) NOT NULL COMMENT '累计GMV',
    gmv_rate VARCHAR(10) COMMENT 'GMV占比',
    avg_item_price DECIMAL(10,2) COMMENT '件均价'
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COMMENT='商品类目经营分析ADS表';
INSERT INTO ads_category_sales_summary
(
    category_name,
    order_cnt,
    item_cnt,
    active_product_cnt,
    active_seller_cnt,
    gmv_amount,
    gmv_rate,
    avg_item_price
)

WITH category_data AS
(
    SELECT
        COALESCE(p.product_category_name_en,'unknown') AS category_name,
        COUNT(DISTINCT f.order_id) AS order_cnt,
        COUNT(f.order_item_id) AS item_cnt,
        COUNT(DISTINCT f.product_sk) AS active_product_cnt,
        COUNT(DISTINCT f.seller_sk) AS active_seller_cnt,
        SUM(f.total_amount) AS gmv_amount,
        SUM(f.price) AS pure_sales_amount
    FROM dwd_fact_order_detail f
    LEFT JOIN dim_products p
        ON f.product_sk = p.product_sk

    WHERE f.order_status <> 'canceled'

    GROUP BY
        COALESCE(p.product_category_name_en,'unknown')
),

total_gmv AS
(
    SELECT
        SUM(gmv_amount) AS total_gmv
    FROM category_data
)

SELECT
    c.category_name,
    c.order_cnt,
    c.item_cnt,
    c.active_product_cnt,
    c.active_seller_cnt,
    ROUND(c.gmv_amount,2),
    CONCAT(
        ROUND(
            c.gmv_amount * 100 / t.total_gmv,
            2
        ),
        '%'
    ),

    ROUND(
        c.pure_sales_amount / c.item_cnt,
        2
    )
FROM category_data c
CROSS JOIN total_gmv t;