-- ==============================================================
-- ods_order_payments：原始数据层（ODS）
-- 来源：olist_order_payments_dataset.csv
-- 说明：本文件为原始 CSV 导入后的表结构，不含加工逻辑；
--       Kaggle 数据按原样导入，时间字段为字符串，类型转换统一在 DWD 层完成。
-- ==============================================================

use olist_dw;

drop table if exists ods_order_payments;

CREATE TABLE ods_order_payments (
      order_id varchar(50) DEFAULT NULL,
      payment_sequential int DEFAULT NULL,
      payment_type varchar(50) DEFAULT NULL,
      payment_installments int DEFAULT NULL,
      payment_value double DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 数据导入（示例）：
-- LOAD DATA LOCAL INFILE 'olist_order_payments_dataset.csv'
-- INTO TABLE ods_order_payments
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES;
