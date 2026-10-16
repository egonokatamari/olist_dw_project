use olist_dw;
drop table if exists ads_trade_kpi_monthly;

create table ads_trade_kpi_monthly(
	stat_month VARCHAR(7) PRIMARY KEY COMMENT '统计月份 (YYYY-MM)',
    gmv_amount DECIMAL(12, 2) NOT NULL COMMENT '月度总GMV',
    mom_gmv_growth VARCHAR(10) COMMENT 'GMV环比增长率 (较上月)',
    order_cnt INT NOT NULL COMMENT '月度订单总量',
    item_cnt INT NOT NULL COMMENT '月度售出商品件数',
    active_category_cnt INT NOT NULL COMMENT '月度动销类目数',
    avg_order_price DECIMAL(10, 2) NOT NULL COMMENT '平均客单价 (GMV / 订单量)',
    freight_amount DECIMAL(12, 2) NOT NULL COMMENT '月度运费总额',
    freight_rate VARCHAR(10) NOT NULL COMMENT '运费占GMV比例'
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台月度经营核心大盘 (ADS层)';
INSERT INTO ads_trade_kpi_monthly (
    stat_month,
    gmv_amount,
    mom_gmv_growth,
    order_cnt,
    item_cnt,
    active_category_cnt,
    avg_order_price,
    freight_amount,
    freight_rate
)
WITH monthly_base AS (
    -- 1. 汇总每月 GMV、商品件数、类目数和运费
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS stat_month,
        SUM(gmv_amount) AS gmv_amount,
        SUM(item_cnt) AS item_cnt,
        COUNT(DISTINCT category_name) AS active_category_cnt,
        SUM(freight_amount) AS freight_amount
    FROM dws_trade_category_day_summary
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
monthly_orders AS (
    -- 2. 从 DWD 直接计算每月独立订单量
    SELECT
        DATE_FORMAT(
            order_purchase_timestamp, '%Y-%m'
        ) AS stat_month,
        COUNT(DISTINCT order_id) AS order_cnt
    FROM dwd_fact_order_detail
    WHERE order_status <> 'canceled'
    GROUP BY DATE_FORMAT(
        order_purchase_timestamp, '%Y-%m'
    )
),
monthly_joined AS (
    -- 3. 合并月度指标
    SELECT
        b.stat_month,
        b.gmv_amount,
        o.order_cnt,
        b.item_cnt,
        b.active_category_cnt,
        b.freight_amount
    FROM monthly_base b
    LEFT JOIN monthly_orders o
        ON b.stat_month = o.stat_month
),
calc_growth AS (
    -- 4. 计算环比、客单价和运费占比
    SELECT
        stat_month,
        gmv_amount,
        LAG(gmv_amount, 1) OVER (
            ORDER BY stat_month
        ) AS prev_month_gmv,
        order_cnt,
        item_cnt,
        active_category_cnt,
        ROUND(
            gmv_amount / NULLIF(order_cnt, 0), 2
        ) AS avg_order_price,
        freight_amount,
        CONCAT(
            ROUND(
                freight_amount * 100.0
                / NULLIF(gmv_amount, 0), 2
            ),
            '%'
        ) AS freight_rate
    FROM monthly_joined
)
SELECT
    stat_month,
    gmv_amount,
    CASE
        WHEN prev_month_gmv IS NULL
             OR prev_month_gmv = 0 THEN '-'
        ELSE CONCAT(
            ROUND(
                (gmv_amount - prev_month_gmv)
                * 100.0 / prev_month_gmv, 2
            ),
            '%'
        )
    END AS mom_gmv_growth,
    order_cnt,
    item_cnt,
    active_category_cnt,
    avg_order_price,
    freight_amount,
    freight_rate
FROM calc_growth;
	