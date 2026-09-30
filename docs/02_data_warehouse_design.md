# 数据仓库设计说明

## 1. 数仓分层架构

本项目采用经典的数据仓库分层设计：

```text
ODS 原始层
  ↓
DWD 明细清洗层
  ↓
DWS 汇总层
  ↓
ADS 应用层
```

各层职责如下：

| 层级 | 英文名称 | 主要职责 |
| --- | --- | --- |
| ODS | Operational Data Store | 存储原始业务数据 |
| DWD | Data Warehouse Detail | 清洗、标准化明细数据 |
| DWS | Data Warehouse Summary | 按主题进行汇总 |
| ADS | Application Data Service | 面向业务应用和报表 |

---

## 2. ODS 层设计

### 2.1 表名

```text
ods_user_behavior
```

### 2.2 表定位

ODS 层用于存储用户行为原始数据，尽量保持数据的原始形态。

### 2.3 字段设计

| 字段名 | 类型 | 含义 |
| --- | --- | --- |
| user_id | BIGINT | 用户 ID |
| item_id | BIGINT | 商品 ID |
| category_id | BIGINT | 商品类目 ID |
| behavior_type | VARCHAR(20) | 行为类型 |
| behavior_time | DATETIME | 行为发生时间 |

### 2.4 示例数据

| user_id | item_id | category_id | behavior_type | behavior_time |
| ---: | ---: | ---: | --- | --- |
| 1001 | 2001 | 3001 | pv | 2024-01-01 10:01:00 |
| 1001 | 2001 | 3001 | cart | 2024-01-01 10:05:00 |
| 1001 | 2001 | 3001 | buy | 2024-01-01 10:10:00 |

---

## 3. DWD 层设计

### 3.1 表名

```text
dwd_user_behavior_detail
```

### 3.2 表定位

DWD 层用于对 ODS 原始数据进行清洗和标准化，形成可直接分析的明细行为表。

### 3.3 清洗规则

| 规则 | 说明 |
| --- | --- |
| 过滤空用户 | user_id 不能为空 |
| 过滤空商品 | item_id 不能为空 |
| 过滤非法行为 | behavior_type 必须属于 pv、fav、cart、buy |
| 过滤空时间 | behavior_time 不能为空 |
| 提取日期 | 从 behavior_time 中提取 behavior_date |

### 3.4 字段设计

| 字段名 | 类型 | 含义 |
| --- | --- | --- |
| user_id | BIGINT | 用户 ID |
| item_id | BIGINT | 商品 ID |
| category_id | BIGINT | 商品类目 ID |
| behavior_type | VARCHAR(20) | 行为类型 |
| behavior_time | DATETIME | 行为发生时间 |
| behavior_date | DATE | 行为日期 |

---

## 4. DWS 层设计

### 4.1 表名

```text
dws_user_behavior_daily
```

### 4.2 表定位

DWS 层用于按照用户和日期粒度汇总用户每日行为。

### 4.3 汇总粒度

```text
behavior_date + user_id
```

### 4.4 指标设计

| 指标名 | 含义 | 计算逻辑 |
| --- | --- | --- |
| pv_cnt | 浏览次数 | behavior_type = pv 的次数 |
| fav_cnt | 收藏次数 | behavior_type = fav 的次数 |
| cart_cnt | 加购次数 | behavior_type = cart 的次数 |
| buy_cnt | 购买次数 | behavior_type = buy 的次数 |

### 4.5 核心 SQL

```sql
SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS pv_cnt
```

---

## 5. ADS 层设计

ADS 层面向业务分析和报表展示。

当前设计两张 ADS 表：

```text
ads_daily_overview
ads_top_items_daily
```

---

## 6. ADS 每日经营概览表

### 6.1 表名

```text
ads_daily_overview
```

### 6.2 表定位

用于分析平台每日整体经营情况。

### 6.3 指标设计

| 指标名 | 含义 | 计算逻辑 |
| --- | --- | --- |
| pv_cnt | 浏览次数 | 汇总每日 pv_cnt |
| uv | 访问用户数 | 每日去重 user_id |
| cart_cnt | 加购次数 | 汇总每日 cart_cnt |
| fav_cnt | 收藏次数 | 汇总每日 fav_cnt |
| buy_cnt | 购买次数 | 汇总每日 buy_cnt |
| buyer_cnt | 购买用户数 | buy_cnt 大于 0 的去重用户数 |
| buy_rate | 购买转化率 | 购买用户数 / 访问用户数 |
| buy_per_buyer | 人均购买次数 | 购买次数 / 购买用户数 |

---

## 7. ADS 每日热门商品排行表

### 7.1 表名

```text
ads_top_items_daily
```

### 7.2 表定位

用于统计每日商品热度排行。

### 7.3 排名逻辑

按日期分组，在每一天内部对商品进行排名。

排序规则：

1. 浏览次数越多，排名越靠前
2. 购买次数越多，排名越靠前
3. 商品 ID 越小，排名越靠前

### 7.4 核心 SQL

```sql
ROW_NUMBER() OVER (
    PARTITION BY behavior_date
    ORDER BY 
        SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) DESC,
        SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) DESC,
        item_id ASC
) AS item_rank
```

---

## 8. 指标口径说明

### 8.1 PV

PV 表示浏览次数。  
同一用户多次浏览同一商品，会计算多次。

### 8.2 UV

UV 表示访问用户数。  
同一天内同一用户出现多次，只计算一次。

### 8.3 购买转化率

购买转化率表示访问用户中发生购买行为的比例。

```text
buy_rate = buyer_cnt / uv
```

### 8.4 人均购买次数

人均购买次数表示每个购买用户平均购买了多少次。

```text
buy_per_buyer = buy_cnt / buyer_cnt
```

---

## 9. 可扩展设计

后续可以继续扩展：

| 扩展方向 | 示例 |
| --- | --- |
| 维度建模 | 用户维表、商品维表、类目维表 |
| 更多指标 | GMV、客单价、复购率、留存率 |
| 调度系统 | Airflow、DolphinScheduler |
| 大数据迁移 | Hive、Spark |
| 可视化 | Superset、Metabase、Tableau |
