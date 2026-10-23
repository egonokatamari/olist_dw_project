-- ==============================================================
-- ods_products：原始数据层（ODS）
-- 来源：olist_products_dataset.csv
-- 说明：本文件为原始 CSV 导入后的表结构，不含加工逻辑；
--       Kaggle 数据按原样导入，时间字段为字符串，类型转换统一在 DWD 层完成。
-- ==============================================================

use olist_dw;

drop table if exists ods_products;

CREATE TABLE ods_products (
      product_id varchar(50) DEFAULT NULL,
      product_category_name varchar(50) DEFAULT NULL,
      product_name_lenght int DEFAULT NULL,
      product_description_lenght int DEFAULT NULL,
      product_photos_qty int DEFAULT NULL,
      product_weight_g int DEFAULT NULL,
      product_length_cm int DEFAULT NULL,
      product_height_cm int DEFAULT NULL,
      product_width_cm int DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 数据导入（示例）：
-- LOAD DATA LOCAL INFILE 'olist_products_dataset.csv'
-- INTO TABLE ods_products
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;
