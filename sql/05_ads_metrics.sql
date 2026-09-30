-- 05_ads_metrics.sql
-- ADS 层：应用指标表

USE ecommerce_dw;

-- 每日经营概览指标表
DROP TABLE IF EXISTS ads_daily_overview;

CREATE TABLE ads_daily_overview (
    behavior_date DATE COMMENT '行为日期',
    pv_cnt BIGINT COMMENT '浏览次数',
    uv BIGINT COMMENT '访问用户数',
    cart_cnt BIGINT COMMENT '加购次数',
    fav_cnt BIGINT COMMENT '收藏次数',
    buy_cnt BIGINT COMMENT '购买次数',
    buyer_cnt BIGINT COMMENT '购买用户数',
    buy_rate DECIMAL(10,4) COMMENT '购买转化率：购买用户数/访问用户数',
    buy_per_buyer DECIMAL(10,4) COMMENT '人均购买次数：购买次数/购买用户数'
) COMMENT='ADS层-每日经营概览指标表';

INSERT INTO ads_daily_overview
(behavior_date, pv_cnt, uv, cart_cnt, fav_cnt, buy_cnt, buyer_cnt, buy_rate, buy_per_buyer)
SELECT
    behavior_date,
    SUM(pv_cnt) AS pv_cnt,
    COUNT(DISTINCT user_id) AS uv,
    SUM(cart_cnt) AS cart_cnt,
    SUM(fav_cnt) AS fav_cnt,
    SUM(buy_cnt) AS buy_cnt,
    COUNT(DISTINCT CASE WHEN buy_cnt > 0 THEN user_id END) AS buyer_cnt,
    ROUND(
        COUNT(DISTINCT CASE WHEN buy_cnt > 0 THEN user_id END) / COUNT(DISTINCT user_id),
        4
    ) AS buy_rate,
    ROUND(
        SUM(buy_cnt) / NULLIF(COUNT(DISTINCT CASE WHEN buy_cnt > 0 THEN user_id END), 0),
        4
    ) AS buy_per_buyer
FROM dws_user_behavior_daily
GROUP BY behavior_date;


-- 每日热门商品排行表
DROP TABLE IF EXISTS ads_top_items_daily;

CREATE TABLE ads_top_items_daily (
    behavior_date DATE COMMENT '行为日期',
    item_id BIGINT COMMENT '商品ID',
    pv_cnt BIGINT COMMENT '浏览次数',
    buy_cnt BIGINT COMMENT '购买次数',
    item_rank BIGINT COMMENT '商品排名'
) COMMENT='ADS层-每日热门商品排行表';

INSERT INTO ads_top_items_daily
(behavior_date, item_id, pv_cnt, buy_cnt, item_rank)
SELECT
    behavior_date,
    item_id,
    pv_cnt,
    buy_cnt,
    item_rank
FROM (
    SELECT
        behavior_date,
        item_id,
        SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS pv_cnt,
        SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_cnt,
        ROW_NUMBER() OVER (
            PARTITION BY behavior_date
            ORDER BY 
                SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) DESC,
                SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) DESC,
                item_id ASC
        ) AS item_rank
    FROM dwd_user_behavior_detail
    GROUP BY behavior_date, item_id
) t
WHERE item_rank <= 10;
