-- =====================================================================
-- 小红花系统 DDL
-- 执行前提：已执行 pity_system_v2.sql
-- =====================================================================

-- 1. user 表：加小红花余量字段
ALTER TABLE user
    ADD COLUMN flower_count INT NOT NULL DEFAULT 0 COMMENT '小红花当前余量';

-- 2. lottery_item 表：加小红花奖励字段
--    抽到该奖品时，自动给孩子增加对应数量的小红花（0 = 不赠送）
ALTER TABLE lottery_item
    ADD COLUMN flower_reward INT NOT NULL DEFAULT 0 COMMENT '抽中此奖品自动赠送的小红花数量，0=不赠送';

-- 3. 小红花兑换项目配置表（家长端配置）
CREATE TABLE flower_item (
    id          BIGINT      PRIMARY KEY AUTO_INCREMENT,
    parent_id   BIGINT      NOT NULL COMMENT '所属家长ID',
    name        VARCHAR(100) NOT NULL COMMENT '兑换项目名称，如：看电视、玩游戏、零食',
    description VARCHAR(500) DEFAULT NULL COMMENT '详细说明',
    flower_cost INT         NOT NULL DEFAULT 1 COMMENT '每次兑换消耗的小红花数量',
    time_minutes INT        DEFAULT NULL COMMENT '每次兑换对应的时长（分钟），NULL=非时间类奖励',
    daily_limit INT         DEFAULT NULL COMMENT '每日最多可兑换次数，NULL=不限制',
    status      TINYINT     NOT NULL DEFAULT 1 COMMENT '1=启用 0=禁用',
    sort_order  INT         NOT NULL DEFAULT 0 COMMENT '展示排序，越小越靠前',
    create_time DATETIME    DEFAULT NULL,
    update_time DATETIME    DEFAULT NULL
) COMMENT = '小红花兑换项目配置';

-- 4. 小红花变更流水表
CREATE TABLE flower_record (
    id            BIGINT   PRIMARY KEY AUTO_INCREMENT,
    student_id    BIGINT   NOT NULL COMMENT '学生ID',
    change_amount INT      NOT NULL COMMENT '变化数量（正=增加，负=减少）',
    balance       INT      NOT NULL COMMENT '变化后余额',
    type          TINYINT  NOT NULL COMMENT '1=抽奖获得 2=兑换消耗 3=家长手动调整 4=兑换撤销退还',
    source_id     BIGINT   DEFAULT NULL COMMENT '来源记录ID（lottery_record_id 或 flower_redemption_id）',
    remark        VARCHAR(500) DEFAULT NULL,
    operator_id   BIGINT   DEFAULT NULL COMMENT '操作人',
    operate_time  DATETIME DEFAULT NULL
) COMMENT = '小红花变更流水';

-- 5. 小红花兑换申请记录表
CREATE TABLE flower_redemption (
    id           BIGINT      PRIMARY KEY AUTO_INCREMENT,
    student_id   BIGINT      NOT NULL COMMENT '学生ID',
    item_id      BIGINT      NOT NULL COMMENT '兑换项目ID',
    item_name    VARCHAR(100) NOT NULL COMMENT '项目名称快照（防止后续修改影响历史记录）',
    flower_cost  INT         NOT NULL COMMENT '本次消耗小红花数量',
    time_minutes INT         DEFAULT NULL COMMENT '获得时长（分钟），非时间类为NULL',
    status       TINYINT     NOT NULL DEFAULT 0 COMMENT '0=待审批 1=已审批 2=已撤销',
    redeem_date  DATE        NOT NULL COMMENT '兑换日期（用于每日限额统计）',
    redeem_time  DATETIME    NOT NULL COMMENT '孩子申请时间',
    confirm_time DATETIME    DEFAULT NULL COMMENT '家长审批时间',
    confirm_by   BIGINT      DEFAULT NULL COMMENT '审批人ID',
    remark       VARCHAR(500) DEFAULT NULL COMMENT '备注',
    create_time  DATETIME    DEFAULT NULL
) COMMENT = '小红花兑换申请记录';
