USE ecommerce_dw;

-- =====================================================
-- 数据质量检查脚本
-- 目标：
-- 1. 检查 ODS 层关键字段空值
-- 2. 检查行为类型是否合法
-- 3. 检查重复记录
-- 4. 检查 DWD 层清洗结果
-- 5. 检查 ADS 层核心指标是否异常
-- =====================================================

-- 1. ODS 层关键字段空值检查
SELECT
    'ods_null_check' AS check_name,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id_cnt,
    SUM(CASE WHEN item_id IS NULL THEN 1 ELSE 0 END) AS null_item_id_cnt,
    SUM(CASE WHEN behavior_type IS NULL THEN 1 ELSE 0 END) AS null_behavior_type_cnt,
    SUM(CASE WHEN behavior_time IS NULL THEN 1 ELSE 0 END) AS null_behavior_time_cnt
FROM ods_user_behavior;

-- 2. ODS 层行为类型合法性检查
SELECT
    'ods_behavior_type_check' AS check_name,
    behavior_type,
    COUNT(*) AS cnt
FROM ods_user_behavior
WHERE behavior_type NOT IN ('pv', 'fav', 'cart', 'buy')
   OR behavior_type IS NULL
GROUP BY behavior_type;

-- 3. ODS 层重复记录检查
SELECT
    'ods_duplicate_check' AS check_name,
    user_id,
    item_id,
    category_id,
    behavior_type,
    behavior_time,
    COUNT(*) AS duplicate_cnt
FROM ods_user_behavior
GROUP BY
    user_id,
    item_id,
    category_id,
    behavior_type,
    behavior_time
HAVING COUNT(*) > 1;

-- 4. DWD 层清洗后关键字段空值检查
SELECT
    'dwd_null_check' AS check_name,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id_cnt,
    SUM(CASE WHEN item_id IS NULL THEN 1 ELSE 0 END) AS null_item_id_cnt,
    SUM(CASE WHEN behavior_type IS NULL THEN 1 ELSE 0 END) AS null_behavior_type_cnt,
    SUM(CASE WHEN behavior_time IS NULL THEN 1 ELSE 0 END) AS null_behavior_time_cnt,
    SUM(CASE WHEN behavior_date IS NULL THEN 1 ELSE 0 END) AS null_behavior_date_cnt
FROM dwd_user_behavior_detail;

-- 5. DWD 层行为类型合法性检查
SELECT
    'dwd_behavior_type_check' AS check_name,
    behavior_type,
    COUNT(*) AS cnt
FROM dwd_user_behavior_detail
WHERE behavior_type NOT IN ('pv', 'fav', 'cart', 'buy')
   OR behavior_type IS NULL
GROUP BY behavior_type;

-- 6. ADS 每日经营指标异常检查
SELECT
    'ads_daily_overview_check' AS check_name,
    behavior_date,
    pv_cnt,
    uv,
    cart_cnt,
    fav_cnt,
    buy_cnt,
    buyer_cnt,
    buy_rate,
    buy_per_buyer
FROM ads_daily_overview
WHERE pv_cnt < 0
   OR uv < 0
   OR cart_cnt < 0
   OR fav_cnt < 0
   OR buy_cnt < 0
   OR buyer_cnt < 0
   OR buy_rate < 0
   OR buy_rate > 1
   OR buy_per_buyer < 0;

-- 7. ADS 商品排行指标异常检查
SELECT
    'ads_top_items_daily_check' AS check_name,
    behavior_date,
    item_id,
    pv_cnt,
    buy_cnt,
    item_rank
FROM ads_top_items_daily
WHERE pv_cnt < 0
   OR buy_cnt < 0
   OR item_rank <= 0;
