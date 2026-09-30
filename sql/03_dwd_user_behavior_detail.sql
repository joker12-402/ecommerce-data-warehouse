-- 03_dwd_user_behavior_detail.sql
-- DWD 层：用户行为明细清洗表

USE ecommerce_dw;

DROP TABLE IF EXISTS dwd_user_behavior_detail;

CREATE TABLE dwd_user_behavior_detail (
    user_id BIGINT COMMENT '用户ID',
    item_id BIGINT COMMENT '商品ID',
    category_id BIGINT COMMENT '商品类目ID',
    behavior_type VARCHAR(20) COMMENT '行为类型：pv/fav/cart/buy',
    behavior_time DATETIME COMMENT '行为发生时间',
    behavior_date DATE COMMENT '行为日期'
) COMMENT='DWD层-用户行为明细表';

INSERT INTO dwd_user_behavior_detail
(user_id, item_id, category_id, behavior_type, behavior_time, behavior_date)
SELECT
    user_id,
    item_id,
    category_id,
    behavior_type,
    behavior_time,
    DATE(behavior_time) AS behavior_date
FROM ods_user_behavior
WHERE user_id IS NOT NULL
  AND item_id IS NOT NULL
  AND behavior_type IN ('pv', 'fav', 'cart', 'buy')
  AND behavior_time IS NOT NULL;
