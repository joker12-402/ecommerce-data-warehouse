# 电商用户行为数据仓库项目

## 1. 项目简介

本项目是一个基于 MySQL 的电商用户行为数据仓库项目，模拟电商平台中的用户浏览、收藏、加购、购买等行为数据，并按照数仓分层思想完成从原始数据到应用指标的完整建模流程。

项目采用经典数仓分层架构：

```text
ODS 原始层
  ↓
DWD 明细清洗层
  ↓
DWS 汇总层
  ↓
ADS 应用层
```

通过该项目可以完成以下目标：

- 理解数据仓库分层建模思想
- 掌握 MySQL 中的建表、清洗、聚合和指标计算
- 使用 SQL 实现电商常见经营指标
- 将 SQL 脚本整理为可复现的本地项目
- 为后续迁移到 Hive、Spark、Airflow 等大数据技术栈打基础

---

## 2. 技术栈

- 操作系统：macOS
- 数据库：MySQL
- 开发工具：VS Code
- 脚本语言：SQL
- 版本管理：Git / GitHub

---

## 3. 项目目录结构

```text
ecommerce-data-warehouse/
├── README.md
├── data/
│   └── sample_user_behavior.csv
├── docs/
│   ├── 01_project_overview.md
│   ├── 02_data_warehouse_design.md
│   └── 03_mysql_run_guide.md
└── sql/
    ├── 01_create_database.sql
    ├── 02_ods_user_behavior.sql
    ├── 03_dwd_user_behavior_detail.sql
    ├── 04_dws_user_behavior_daily.sql
    └── 05_ads_metrics.sql
```

---

## 4. 数仓分层设计

### 4.1 ODS 层：原始数据层

表名：

```text
ods_user_behavior
```

用途：

- 存储用户行为原始数据
- 尽量保持数据原貌
- 包含用户、商品、类目、行为类型、行为时间等字段

---

### 4.2 DWD 层：明细清洗层

表名：

```text
dwd_user_behavior_detail
```

用途：

- 对 ODS 层数据进行清洗
- 过滤无效用户、无效商品、非法行为类型、空时间
- 从行为时间中提取行为日期
- 形成标准化明细数据

---

### 4.3 DWS 层：汇总层

表名：

```text
dws_user_behavior_daily
```

用途：

- 按日期和用户粒度汇总每日行为
- 计算用户每日浏览、收藏、加购、购买次数

---

### 4.4 ADS 层：应用指标层

当前包含两张应用层指标表：

```text
ads_daily_overview
ads_top_items_daily
```

`ads_daily_overview` 用于每日经营概览分析。

核心指标包括：

- 浏览次数 pv_cnt
- 访问用户数 uv
- 加购次数 cart_cnt
- 收藏次数 fav_cnt
- 购买次数 buy_cnt
- 购买用户数 buyer_cnt
- 购买转化率 buy_rate
- 人均购买次数 buy_per_buyer

`ads_top_items_daily` 用于每日热门商品排行分析。

---

## 5. 快速运行

进入项目目录：

```bash
cd ~/ecommerce-data-warehouse
```

按顺序执行 SQL 脚本：

```bash
mysql -u root < sql/01_create_database.sql
mysql -u root < sql/02_ods_user_behavior.sql
mysql -u root < sql/03_dwd_user_behavior_detail.sql
mysql -u root < sql/04_dws_user_behavior_daily.sql
mysql -u root < sql/05_ads_metrics.sql
```

查询 ADS 层结果：

```bash
mysql -u root -e "USE ecommerce_dw; SELECT * FROM ads_daily_overview; SELECT * FROM ads_top_items_daily;"
```

---

## 6. 查询结果示例

### 6.1 每日经营概览

| behavior_date | pv_cnt | uv | cart_cnt | fav_cnt | buy_cnt | buyer_cnt | buy_rate | buy_per_buyer |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2024-01-01 | 3 | 3 | 1 | 1 | 1 | 1 | 0.3333 | 1.0000 |
| 2024-01-02 | 1 | 1 | 0 | 0 | 1 | 1 | 1.0000 | 1.0000 |

### 6.2 每日热门商品排行

| behavior_date | item_id | pv_cnt | buy_cnt | item_rank |
| --- | ---: | ---: | ---: | ---: |
| 2024-01-01 | 2001 | 1 | 1 | 1 |
| 2024-01-01 | 2002 | 1 | 0 | 2 |
| 2024-01-01 | 2003 | 1 | 0 | 3 |
| 2024-01-02 | 2004 | 1 | 1 | 1 |

---

## 7. 核心 SQL 技术点

本项目涉及以下 SQL 技术点：

- 建库建表
- 数据插入
- 数据清洗
- 日期字段提取
- 条件聚合
- 去重计数
- 转化率计算
- 空值保护
- 窗口函数
- 分层建模
- 脚本化执行

示例 SQL：

```sql
SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS pv_cnt
```

```sql
ROW_NUMBER() OVER (
    PARTITION BY behavior_date
    ORDER BY 
        SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) DESC,
        SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) DESC
) AS item_rank
```

---

## 8. 项目价值

通过本项目，可以展示以下能力：

- 具备数据仓库分层建模思维
- 能够基于业务需求设计指标体系
- 能够使用 SQL 完成数据清洗、汇总和分析
- 能够将零散 SQL 整理为可复现项目
- 具备继续学习 Hive、Spark、Airflow 等大数据技术的基础

---

## 9. 后续优化方向

后续可以继续扩展：

- 增加用户维表、商品维表、类目维表
- 增加 GMV、复购率、留存率等指标
- 使用 Python 自动调度 SQL 脚本
- 使用 Airflow 编排数仓任务
- 将 MySQL 版本迁移到 Hive 或 Spark
- 使用 Superset 或 Metabase 做可视化看板
