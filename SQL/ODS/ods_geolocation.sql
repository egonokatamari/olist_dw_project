-- ==============================================================
-- ods_geolocation：原始数据层（ODS）
-- 来源：olist_geolocation_dataset.csv
-- 说明：本文件为原始 CSV 导入后的表结构，不含加工逻辑；
--       Kaggle 数据按原样导入，时间字段为字符串，类型转换统一在 DWD 层完成。
-- ==============================================================

use olist_dw;

drop table if exists ods_geolocation;

CREATE TABLE ods_geolocation (
      geolocation_zip_code_prefix int DEFAULT NULL,
      geolocation_lat double DEFAULT NULL,
      geolocation_lng double DEFAULT NULL,
      geolocation_city varchar(50) DEFAULT NULL,
      geolocation_state varchar(50) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 数据导入（示例）：
-- LOAD DATA LOCAL INFILE 'olist_geolocation_dataset.csv'
-- INTO TABLE ods_geolocation
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;
