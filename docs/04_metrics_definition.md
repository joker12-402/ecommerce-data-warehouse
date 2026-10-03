# 指标口径说明

本文档用于说明电商用户行为离线数仓项目中核心指标的统计口径、统计粒度和数据来源。

---

## 1. 指标总览

| 指标名称 | 英文字段 | 统计口径 | 统计粒度 | 数据来源 |
|---|---|---|---|---|
| 浏览次数 | pv_cnt | behavior_type = 'pv' 的行为次数 | 日期 | DWD / DWS |
| 访问用户数 | uv | 当日发生行为的去重用户数 | 日期 | DWD / DWS |
| 收藏次数 | fav_cnt | behavior_type = 'fav' 的行为次数 | 日期 | DWD / DWS |
| 加购次数 | cart_cnt | behavior_type = 'cart' 的行为次数 | 日期 | DWD / DWS |
| 购买次数 | buy_cnt | behavior_type = 'buy' 的行为次数 | 日期 | DWD / DWS |
| 购买用户数 | buyer_cnt | 当日发生购买行为的去重 user_id 数 | 日期 | DWD / DWS |
| 购买转化率 | buy_rate | 购买用户数 / 访问用户数 | 日期 | ADS |
| 人均购买次数 | buy_per_buyer | 购买次数 / 购买用户数 | 日期 | ADS |
| 商品浏览次数 | item_pv_cnt | 某商品当日 behavior_type = 'pv' 的行为次数 | 日期 + 商品 | DWD |
| 商品购买次数 | item_buy_cnt | 某商品当日 behavior_type = 'buy' 的行为次数 | 日期 + 商品 | DWD |
| 商品排名 | item_rank | 按商品浏览次数和购买次数排序生成排名 | 日期 + 商品 | ADS |

---

## 2. 核心指标说明

### 2.1 PV

PV 即页面浏览次数。

统计口径：

- 统计 behavior_type = 'pv' 的行为记录数。
- 同一用户多次浏览会被重复统计。

---

### 2.2 UV

UV 即访问用户数。

统计口径：

- 按 behavior_date 统计去重 user_id 数。
- 同一用户同一天发生多次行为，只统计为 1 个访问用户。

---

### 2.3 收藏次数

收藏次数统计用户收藏商品的行为次数。

统计口径：

- 统计 behavior_type = 'fav' 的行为记录数。

---

### 2.4 加购次数

加购次数统计用户将商品加入购物车的行为次数。

统计口径：

- 统计 behavior_type = 'cart' 的行为记录数。

---

### 2.5 购买次数

购买次数统计购买行为发生的次数。

统计口径：

- 统计 behavior_type = 'buy' 的行为记录数。
- 同一用户同一天多次购买会被统计多次。

---

### 2.6 购买用户数

购买用户数统计当日发生购买行为的去重用户数。

统计口径：

- 当日 buy_cnt > 0 的去重 user_id 数。
- 同一用户同一天多次购买，只统计为 1 个购买用户。

---

### 2.7 购买转化率

购买转化率用于衡量访问用户中最终发生购买的比例。

计算公式：

buy_rate = buyer_cnt / uv

说明：

- buyer_cnt 表示购买用户数。
- uv 表示访问用户数。
- SQL 中使用 NULLIF 避免除数为 0。
- 当前项目中结果保留 4 位小数。

---

### 2.8 人均购买次数

人均购买次数用于衡量购买用户的平均购买频次。

计算公式：

buy_per_buyer = buy_cnt / buyer_cnt

说明：

- buy_cnt 表示购买次数。
- buyer_cnt 表示购买用户数。
- SQL 中使用 NULLIF 避免除数为 0。
- 当前项目中结果保留 4 位小数。

---

## 3. 表粒度说明

| 表名 | 所属层级 | 表粒度 |
|---|---|---|
| ods_user_behavior | ODS | 一条原始用户行为记录 |
| dwd_user_behavior_detail | DWD | 一条清洗后的用户行为明细 |
| dws_user_behavior_daily | DWS | 一个用户在一天内的行为汇总 |
| ads_daily_overview | ADS | 一天的平台整体经营指标 |
| ads_top_items_daily | ADS | 一天内一个商品的热度指标和排名 |

---

## 4. 注意事项

1. 本项目中购买转化率定义为：购买用户数 / 访问用户数。
2. UV 使用 user_id 去重统计。
3. 商品排行按照浏览次数和购买次数排序。
4. 当前项目为本地 MySQL 离线数仓示例，主要用于展示数仓分层、指标建模和 SQL 实现能力。
