-- ==============================================================
-- ods_category_translation：原始数据层（ODS）
-- 来源：product_category_name_translation.csv
-- 说明：本文件为原始 CSV 导入后的表结构，不含加工逻辑；
--       Kaggle 数据按原样导入，时间字段为字符串，类型转换统一在 DWD 层完成。
-- ==============================================================

use olist_dw;

drop table if exists ods_category_translation;

CREATE TABLE ods_category_translation (
      product_category_name varchar(50) DEFAULT NULL,
      product_category_name_english varchar(50) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 数据导入（示例）：
-- LOAD DATA LOCAL INFILE 'product_category_name_translation.csv'
-- INTO TABLE ods_category_translation
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;
