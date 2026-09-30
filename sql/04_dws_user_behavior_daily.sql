-- 04_dws_user_behavior_daily.sql
-- DWS 层：用户每日行为汇总表

USE ecommerce_dw;

DROP TABLE IF EXISTS dws_user_behavior_daily;

CREATE TABLE dws_user_behavior_daily (
    behavior_date DATE COMMENT '行为日期',
    user_id BIGINT COMMENT '用户ID',
    pv_cnt BIGINT COMMENT '浏览次数',
    fav_cnt BIGINT COMMENT '收藏次数',
    cart_cnt BIGINT COMMENT '加购次数',
    buy_cnt BIGINT COMMENT '购买次数'
) COMMENT='DWS层-用户每日行为汇总表';

INSERT INTO dws_user_behavior_daily
(behavior_date, user_id, pv_cnt, fav_cnt, cart_cnt, buy_cnt)
SELECT
    behavior_date,
    user_id,
    SUM(CASE WHEN behavior_type = 'pv' THEN 1 ELSE 0 END) AS pv_cnt,
    SUM(CASE WHEN behavior_type = 'fav' THEN 1 ELSE 0 END) AS fav_cnt,
    SUM(CASE WHEN behavior_type = 'cart' THEN 1 ELSE 0 END) AS cart_cnt,
    SUM(CASE WHEN behavior_type = 'buy' THEN 1 ELSE 0 END) AS buy_cnt
FROM dwd_user_behavior_detail
GROUP BY behavior_date, user_id;
