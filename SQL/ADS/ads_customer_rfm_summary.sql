use olist_dw;

drop table if exists ads_customer_rfm_summary;

create table ads_customer_rfm_summary(
	customer_unique_id VARCHAR(50) PRIMARY KEY COMMENT '唯一买家ID',
    customer_state VARCHAR(10) NOT NULL COMMENT '买家所在省份',
    recency_days INT NOT NULL COMMENT '距离最后一天下单天数 (越小越好)',
    frequency_cnt INT NOT NULL COMMENT '消费频次 (总订单数)',
    monetary_amt DECIMAL(10, 2) NOT NULL COMMENT '消费总金额',
    r_score TINYINT NOT NULL COMMENT 'R指标打分 (1=优于均值, 0=劣于均值)',
    f_score TINYINT NOT NULL COMMENT 'F指标打分 (1=优于均值, 0=劣于均值)',
    m_score TINYINT NOT NULL COMMENT 'M指标打分 (1=优于均值, 0=劣于均值)',
    rfm_segment VARCHAR(20) NOT NULL COMMENT 'RFM客户分群标签'
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='RFM用户价值分层模型 (ADS层)';

insert into ads_customer_rfm_summary(
	customer_unique_id,
    customer_state,
    recency_days,
    frequency_cnt,
    monetary_amt,
    r_score,
    f_score,
    m_score,
    rfm_segment
)
with base_data as (
	select customer_unique_id,
        customer_state,
        DATEDIFF(
            (SELECT MAX(last_order_time) FROM dws_customer_user_summary), 
            last_order_time
        ) AS recency_days,
        total_order_cnt AS frequency_cnt,
        total_spend_amount AS monetary_amt
    FROM dws_customer_user_summary
),
benchmarks as (
	SELECT 
        AVG(recency_days) AS avg_r,
        AVG(frequency_cnt) AS avg_f,
        AVG(monetary_amt) AS avg_m
    FROM base_data
),
scored_data as (
	select b.customer_unique_id,
        b.customer_state,
        b.recency_days,
        b.frequency_cnt,
        b.monetary_amt,
        -- R 越小说明最近越活跃，小于均值代表表现优秀，打 1 分
        CASE WHEN b.recency_days < m.avg_r THEN 1 ELSE 0 END AS r_score,
        -- F 和 M 越大越好，大于均值打 1 分
        CASE WHEN b.frequency_cnt > m.avg_f THEN 1 ELSE 0 END AS f_score,
        CASE WHEN b.monetary_amt > m.avg_m THEN 1 ELSE 0 END AS m_score
    FROM base_data b
    CROSS JOIN benchmarks m
)
SELECT 
    customer_unique_id,
    customer_state,
    recency_days,
    frequency_cnt,
    monetary_amt,
    r_score,
    f_score,
    m_score,
    CASE 
        WHEN r_score = 1 AND f_score = 1 AND m_score = 1 THEN '重要价值客户'
        WHEN r_score = 0 AND f_score = 1 AND m_score = 1 THEN '重要唤回客户'
        WHEN r_score = 1 AND f_score = 0 AND m_score = 1 THEN '重要发展客户'
        WHEN r_score = 0 AND f_score = 0 AND m_score = 1 THEN '重要挽留客户'
        WHEN r_score = 1 AND f_score = 1 AND m_score = 0 THEN '一般保持客户'
        WHEN r_score = 0 AND f_score = 1 AND m_score = 0 THEN '一般维持客户'
        WHEN r_score = 1 AND f_score = 0 AND m_score = 0 THEN '新客户'
        ELSE '流失客户'
    END AS rfm_segment
FROM scored_data;