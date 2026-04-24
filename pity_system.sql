-- 保底机制（Pity System）数据库迁移脚本
-- 执行前请备份数据库

-- 1. lottery_item 表：添加「是否保底奖品」标记
ALTER TABLE lottery_item
    ADD COLUMN is_pity_prize TINYINT(1) NOT NULL DEFAULT 0
    COMMENT '是否为保底奖品（连续未中时自动赠送），0=否，1=是';

-- 2. user 表：添加保底计数器
ALTER TABLE user
    ADD COLUMN pity_count INT NOT NULL DEFAULT 0
    COMMENT '保底计数器：连续未中保底奖品的抽奖次数，触发保底后重置为0';

-- 3. 将已知的小红花奖品（id=7,8,9）标记为保底奖品（按实际情况调整）
UPDATE lottery_item SET is_pity_prize = 1 WHERE id IN (7, 8, 9);
