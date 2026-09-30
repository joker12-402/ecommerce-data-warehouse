-- 02_ods_user_behavior.sql
-- ODS 层：用户行为原始数据表

USE ecommerce_dw;

DROP TABLE IF EXISTS ods_user_behavior;

CREATE TABLE ods_user_behavior (
    user_id BIGINT COMMENT '用户ID',
    item_id BIGINT COMMENT '商品ID',
    category_id BIGINT COMMENT '商品类目ID',
    behavior_type VARCHAR(20) COMMENT '行为类型：pv/fav/cart/buy',
    behavior_time DATETIME COMMENT '行为发生时间'
) COMMENT='ODS层-用户行为原始表';

-- 插入样例数据
INSERT INTO ods_user_behavior
(user_id, item_id, category_id, behavior_type, behavior_time)
VALUES
(1001, 2001, 3001, 'pv',   '2024-01-01 10:01:00'),
(1001, 2001, 3001, 'cart', '2024-01-01 10:05:00'),
(1001, 2001, 3001, 'buy',  '2024-01-01 10:10:00'),
(1002, 2002, 3002, 'pv',   '2024-01-01 11:00:00'),
(1002, 2002, 3002, 'fav',  '2024-01-01 11:05:00'),
(1003, 2003, 3003, 'pv',   '2024-01-01 12:00:00'),
(1004, 2004, 3001, 'pv',   '2024-01-02 09:00:00'),
(1004, 2004, 3001, 'buy',  '2024-01-02 09:15:00');
