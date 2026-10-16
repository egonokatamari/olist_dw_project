# Olist 电商数据仓库建设与经营分析平台

## 一、项目简介

本项目基于 Olist 巴西电商公开数据集，使用 MySQL 和 SQL 对电商业务数据进行整理、建模和分析。

项目围绕订单、客户、商品、商家及物流等业务数据，在 DBeaver 中完成 ODS、DIM、DWD、DWS、ADS 数据表的建设，并使用 SQL 完成数据关联、数据处理及业务指标计算。

在此基础上，使用 FineBI 搭建经营分析、用户价值、商品销售和物流效率等主题的可视化看板，并结合分析结果制作经营分析 PPT。

项目形成了：

**业务数据 → 数据处理与建模 → 指标计算 → BI 可视化 → 业务分析**

的完整分析流程。

---

# 二、项目背景

Olist 电商数据包含订单、客户、商品、商家、支付、评价及物流等多类业务数据。

通过对这些数据进行整理和分析，可以从不同业务角度了解：

- 整体经营情况如何？
- 哪些商品类别贡献了较多销售额？
- 不同用户的消费价值有什么差异？
- 不同地区的物流效率和运费水平如何？

因此，本项目围绕经营、用户、商品和物流四个主题，对 Olist 电商数据进行分析，为经营情况判断和业务分析提供数据支持。

---

# 三、技术栈

| 技术 | 主要用途 |
|---|---|
| MySQL | 数据存储及数据表建设 |
| SQL | 数据关联、数据处理、汇总及指标计算 |
| DBeaver | 数据库开发与管理 |
| FineBI | 数据可视化及分析看板制作 |

---

# 四、数仓架构

```text
Olist 原始数据集
       ↓
ODS 原始数据层
       ↓
DIM 公共维度层 + DWD 明细事实层
       ↓
DWS 业务汇总层
       ↓
ADS 指标应用层
       ↓
FineBI 可视化分析
       ↓
经营分析 PPT
```

项目按照数据仓库分层思想组织数据，通过不同层级的数据表逐步完成从明细数据到业务分析指标的处理。

---

# 五、数据分层设计

## 1. ODS 原始数据层

ODS 层用于保存从 Olist 数据集中整理导入的原始业务数据，为后续数据处理和分析提供基础数据。

主要业务表包括：

### 订单相关

- `ods_orders`
- `ods_order_items`
- `ods_order_payments`
- `ods_order_reviews`

### 主数据

- `ods_customers`
- `ods_products`
- `ods_sellers`
- `ods_geolocation`
- `ods_category_translation`

---

## 2. DIM 公共维度层

根据业务分析需要建立公共维度表，为不同主题的数据分析提供统一的分析维度。

主要维度表：

- `dim_customers`：客户维度
- `dim_products`：商品维度
- `dim_sellers`：商家维度
- `dim_date`：日期维度

主要用于支持按照客户、商品、商家和日期等维度进行数据分析。

---

## 3. DWD 明细事实层

核心事实表：

```text
dwd_fact_order_detail
```

**设计粒度：**

```text
order_id + order_item_id
```

主要处理：

- 多业务表关联
- 数据清洗与字段整理
- 订单商品明细整合
- 统一分析粒度

该层为后续交易、商品及用户相关指标分析提供明细数据基础。

---

# 六、DWS 业务主题汇总层

## 1. 商品交易主题

数据表：

```text
dws_trade_category_day_summary
```

主要指标：

- GMV
- 订单数量
- 商品销量
- 运费金额

主要分析维度：

- 日期
- 商品类别

用于支持商品类别销售表现及趋势分析。

---

## 2. 用户消费主题

数据表：

```text
dws_customer_user_summary
```

主要指标：

- 用户订单次数
- 消费金额
- 平均客单价
- 最大消费金额
- 复购情况

用于支持用户消费行为及用户价值分析。

---

# 七、ADS 指标应用层

## 1. 经营分析主题

数据表：

```text
ads_trade_kpi_monthly
```

主要指标：

- 月度 GMV
- 订单量
- 商品数量
- 平均客单价
- GMV 环比变化

用于分析整体经营规模及月度变化趋势。

---

## 2. 用户 RFM 分析主题

数据表：

```text
ads_customer_rfm_summary
```

基于 RFM 模型分析用户消费行为：

| 指标 | 含义 |
|---|---|
| R（Recency） | 距离最近一次消费的时间 |
| F（Frequency） | 消费频次 |
| M（Monetary） | 消费金额 |

本项目采用基于整体客户均值的简化评分方式：

- R 小于整体客户平均值，记为 1 分；
- F 大于整体客户平均值，记为 1 分；
- M 大于整体客户平均值，记为 1 分。

根据 R、F、M 三项得分组合，对用户进行价值分层。

客户类型包括：

- 重要价值客户
- 重要唤回客户
- 重要发展客户
- 重要挽留客户
- 一般保持客户
- 一般维持客户
- 新客户
- 流失客户

用于识别不同消费特征的客户群体，为用户价值分析提供数据支持。

---

## 3. 商品销售分析主题

数据表：

```text
ads_category_sales_summary
```

主要分析：

- TOP10 商品类别
- 类目 GMV
- 销售占比

用于识别主要销售品类及其销售贡献。

---

## 4. 物流效率分析主题

数据表：

```text
ads_logistics_state_summary
```

主要分析：

- 各州平均配送周期
- 平均运费水平

用于比较不同地区的物流效率和运输成本表现。

---

# 八、BI 可视化分析

使用 FineBI 根据前面处理得到的业务指标搭建分析看板。

## 1. 经营分析驾驶舱

展示：

![经营分析驾驶舱](https://cdn.jsdmirror.com/gh/egonokatamari/img@main/jyfx.png)

- 累计 GMV
- 订单数量
- 商品数量
- 平均客单价
- 月度 GMV 趋势
- TOP 商品类别

---

## 2. 用户价值分析

展示：

![用户价值分析](https://cdn.jsdmirror.com/gh/egonokatamari/img@main/yhjz.png)

- 用户数量
- 用户消费贡献
- RFM 客户分层

---

## 3. 商品销售分析

展示：

![商品销售分析](https://cdn.jsdmirror.com/gh/egonokatamari/img@main/spfx.png)

- TOP10 商品类别
- 类目销售贡献

---

## 4. 物流效率分析

展示：

![物流效率分析](https://cdn.jsdmirror.com/gh/egonokatamari/img@main/wlxl.png)

- 各州平均配送时间
- 平均运费

---

# 九、经营分析

基于 SQL 计算结果和 FineBI 看板，对经营、用户、商品和物流等主题进行进一步分析，并制作经营分析 PPT。

主要分析方向包括：

### 1. 整体经营分析

通过 GMV、订单量、商品数量及客单价等指标观察整体经营规模和变化趋势。

### 2. 商品销售分析

通过商品类别 GMV、销售占比及排名，分析主要销售品类及其贡献。

### 3. 用户价值分析

通过 RFM 模型对客户进行分层，分析不同客户群体的消费特征。

### 4. 物流效率分析

通过地区配送周期和平均运费，对不同地区的物流表现进行比较。

---

# 十、项目亮点

## 1. 按照数据仓库分层思想组织数据

基于 Olist 电商数据，建设 ODS、DIM、DWD、DWS、ADS 数据表，形成从明细数据处理到业务指标分析的数据处理结构。

## 2. 基于维度建模思想设计数据模型

建设客户、商品、商家和日期等公共维度，并结合订单商品明细事实表，为后续业务分析提供数据基础。

## 3. 使用 SQL 完成业务数据处理

使用 SQL 完成：

- 多表 JOIN
- 聚合计算
- 子查询
- CTE
- 业务指标计算
- 用户 RFM 分层

## 4. 将数据处理与业务分析结合

围绕经营、用户、商品和物流四个主题，将 SQL 数据处理结果应用于 FineBI 看板，并结合分析结果制作经营分析 PPT。

---

# 十一、项目目录

```text
olist_dw_project
├── ODS
│   ├── ods_orders.sql
│   ├── ods_customers.sql
│   ├── ods_geolocation.sql
│   ├── ods_order_items.sql
│   ├── ods_order_payments.sql
│   ├── ods_order_reviews.sql
│   ├── ods_products.sql
│   ├── ods_sellers.sql
│   └── ods_category_translation.sql
├── DIM
│   ├── dim_customers.sql
│   ├── dim_products.sql
│   ├── dim_sellers.sql
│   └── dim_date.sql
├── DWD
│   └── dwd_fact_order_detail.sql
├── DWS
│   ├── dws_trade_category_day_summary.sql
│   └── dws_customer_user_summary.sql
├── ADS
│   ├── ads_trade_kpi_monthly.sql
│   ├── ads_customer_rfm_summary.sql
│   ├── ads_category_sales_summary.sql
│   └── ads_logistics_state_summary.sql
└── README.md
```

---

# 十二、项目总结

通过本项目完成了从 Olist 电商业务数据理解、数据表建设、SQL 数据处理、业务指标计算，到 FineBI 可视化和经营分析的实践。

项目主要涉及：

- 数据仓库分层思想
- 维度与事实表设计
- SQL 数据处理与指标计算
- RFM 用户价值分析
- FineBI 数据可视化
- 电商经营业务分析

最终形成：

**业务数据 → 数据处理与建模 → 指标体系 → BI 可视化 → 业务分析**

的完整数据分析链路。