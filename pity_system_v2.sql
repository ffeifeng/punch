-- =====================================================================
-- 保底机制 v2 迁移脚本
-- 升级内容：每个保底奖品拥有独立阈值，每个学生对每个保底奖品有独立计数器
-- =====================================================================

-- 1. lottery_item 表：添加 pity_threshold 字段（替代 is_pity_prize）
--    NULL  = 普通奖品（非保底）
--    > 0   = 保底奖品，连续未中达到该次数后自动赠送
ALTER TABLE lottery_item
    ADD COLUMN pity_threshold INT DEFAULT NULL
    COMMENT '保底阈值：NULL=非保底奖品；>0=连续未中X次后必得此奖品';

-- 2. 迁移旧数据：原来 is_pity_prize=1 的奖品，默认保底阈值设为 10
UPDATE lottery_item SET pity_threshold = 10 WHERE is_pity_prize = 1;

-- 3. 新增 user_pity_count 表：每个学生对每个保底奖品的独立计数器
CREATE TABLE IF NOT EXISTS user_pity_count (
    student_id  BIGINT NOT NULL COMMENT '学生ID',
    item_id     BIGINT NOT NULL COMMENT '保底奖品ID',
    count       INT    NOT NULL DEFAULT 0 COMMENT '连续未中该奖品的抽奖次数，触发保底或自然中奖后归零',
    PRIMARY KEY (student_id, item_id)
) COMMENT = '用户各保底奖品的独立计数器（v2）';

-- 4. 旧字段保留，不强制删除（可选，确认稳定后手动执行）
-- ALTER TABLE lottery_item DROP COLUMN is_pity_prize;
-- ALTER TABLE user DROP COLUMN pity_count;
