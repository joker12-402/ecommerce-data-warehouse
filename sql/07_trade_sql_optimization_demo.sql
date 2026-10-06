-- =========================================================
-- 07_trade_sql_optimization_demo.sql
-- 交易场景 SQL 性能优化与指标准确性示例
--
-- 说明：
-- 当前项目以电商用户行为数仓为主，本文件用于补充交易数仓场景下的
-- SQL 优化思路，不纳入 run_all.sh 主链路执行。
-- =========================================================

-- 1. 退款表先聚合到订单粒度，再与支付表关联
-- 避免一笔订单多次退款导致支付金额被重复放大

WITH pay_detail AS (
    SELECT
        order_id,
        user_id,
        pay_amount,
        dt
    FROM dwd_trade_pay_detail
    WHERE dt = '2024-01-01'
      AND pay_status = 'success'
      AND order_id IS NOT NULL
      AND user_id IS NOT NULL
),

refund_order AS (
    SELECT
        order_id,
        SUM(refund_amount) AS refund_amount
    FROM dwd_trade_refund_detail
    WHERE dt = '2024-01-01'
      AND refund_status = 'success'
      AND order_id IS NOT NULL
    GROUP BY order_id
)

SELECT
    p.dt,
    COUNT(DISTINCT p.order_id) AS pay_order_cnt,
    COUNT(DISTINCT p.user_id) AS pay_user_cnt,
    SUM(p.pay_amount) AS pay_amount,
    SUM(COALESCE(r.refund_amount, 0)) AS refund_amount
FROM pay_detail p
LEFT JOIN refund_order r
    ON p.order_id = r.order_id
GROUP BY p.dt;


-- 2. DWS 用户日粒度汇总表设计示例
-- 粒度：dt + user_id
-- 一行表示一个用户一天内的交易行为
-- ADS 层可基于该表统计支付用户数，减少 COUNT DISTINCT 开销

CREATE TABLE IF NOT EXISTS dws_trade_user_1d (
    dt                VARCHAR(20) COMMENT '统计日期',
    user_id           BIGINT COMMENT '用户ID',
    pay_order_cnt     BIGINT COMMENT '支付订单数',
    pay_amount        DECIMAL(16,2) COMMENT '支付金额',
    refund_order_cnt  BIGINT COMMENT '退款订单数',
    refund_amount     DECIMAL(16,2) COMMENT '退款金额',
    is_pay_user       TINYINT COMMENT '是否支付用户',
    is_refund_user    TINYINT COMMENT '是否退款用户'
);


-- 3. ADS 层基于用户日汇总表统计支付用户数
-- 不再直接从 DWD 明细表中反复 COUNT DISTINCT user_id

SELECT
    dt,
    COUNT(*) AS pay_user_cnt,
    SUM(pay_order_cnt) AS pay_order_cnt,
    SUM(pay_amount) AS pay_amount,
    SUM(refund_order_cnt) AS refund_order_cnt,
    SUM(refund_amount) AS refund_amount
FROM dws_trade_user_1d
WHERE dt = '2024-01-01'
  AND is_pay_user = 1
GROUP BY dt;
