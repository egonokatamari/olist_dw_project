use olist_dw;

drop table if exists dim_date;
create table dim_date(
	date_id INT PRIMARY KEY COMMENT '日期代理键 (YYYYMMDD)',
    full_date DATE NOT NULL UNIQUE COMMENT '完整日期',
    year INT NOT NULL COMMENT '年份',
    quarter INT NOT NULL COMMENT '季度 (1-4)',
    year_quarter VARCHAR(10) NOT NULL COMMENT '年季 (例: 2018-Q1)',
    month INT NOT NULL COMMENT '月份 (1-12)',
    `year_month` VARCHAR(10) NOT NULL COMMENT '年月 (例: 2018-08)',
    `day_of_month` INT NOT NULL COMMENT '月中天数 (1-31)',
    `day_of_week` INT NOT NULL COMMENT '星期序号 (1=周日, 7=周六)',
    `day_name` VARCHAR(15) NOT NULL COMMENT '星期英文名',
    `is_weekend` TINYINT NOT NULL COMMENT '是否周末 (1=是, 0=否)'
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='日期维度表';

set session cte_max_recursion_depth=5000;

insert into dim_date(
	date_id,
    full_date,
    `year`,
    `quarter`,
    year_quarter,
    `month`,
    `year_month`,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
)
with recursive date_series as (
	select cast('2016-01-01' as date) as cur_date
	union all
	
	select date_add(cur_date,interval 1 day)
	from date_series
	where cur_date<'2019-12-31'
)
select 
	CAST(DATE_FORMAT(cur_date, '%Y%m%d') AS UNSIGNED) AS date_id,
    cur_date AS full_date,
    YEAR(cur_date) AS year,
    QUARTER(cur_date) AS quarter,
    CONCAT(YEAR(cur_date), '-Q', QUARTER(cur_date)) AS year_quarter,
    MONTH(cur_date) AS `month`,
    DATE_FORMAT(cur_date, '%Y-%m') AS `year_month`,
    DAY(cur_date) AS day_of_month,
    DAYOFWEEK(cur_date) AS day_of_week,
    DAYNAME(cur_date) AS day_name,
    CASE WHEN DAYOFWEEK(cur_date) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
from date_series;