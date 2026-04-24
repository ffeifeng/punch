-- ============================================================
-- 更新生产库 模板ID=2 和 模板ID=3 的打卡项（不指定ID，避免主键冲突）
-- ============================================================

SET NAMES utf8mb4;

-- 1. 同步模板的 lottery_reward 字段
UPDATE checkin_template SET lottery_reward = 2 WHERE id = 2;
UPDATE checkin_template SET lottery_reward = 2 WHERE id = 3;

-- 2. 清空这两个模板的旧打卡项
DELETE FROM checkin_item WHERE template_id IN (2, 3);

-- 3. 插入模板2（每日打卡-唐宇轩）的打卡项（不指定id，自动生成）
INSERT INTO checkin_item (template_id, item_name, description, points, sort_order, status, checkin_start_time, checkin_end_time, week_days, create_time, update_time) VALUES
(2, '每日跑步',  '', 10, 1,  0, '06:30:00', '06:45:00', 31,  NOW(), NOW()),
(2, '记忆(早上)','', 5,  2,  0, '06:45:00', '07:30:00', 127, NOW(), NOW()),
(2, '早读',      '', 20, 3,  0, '06:45:00', '07:30:00', 31,  NOW(), NOW()),
(2, '学校作业',  '', 15, 4,  0, '16:00:00', '18:00:00', 31,  NOW(), NOW()),
(2, '下午记忆',  '', 10, 5,  0, '16:00:00', '18:15:00', 127, NOW(), NOW()),
(2, '练字',      '', 15, 6,  0, '18:00:00', '18:50:00', 31,  NOW(), NOW()),
(2, '晚上洗漱',  '', 10, 7,  0, '20:00:00', '20:30:00', 127, NOW(), NOW()),
(2, '口算乘法',  '', 15, 8,  0, '17:00:00', '18:00:00', 127, NOW(), NOW()),
(2, '口算乘法',  '', 15, 9,  0, '08:30:00', '10:00:00', 96,  NOW(), NOW()),
(2, '任务抽查',  '', 10, 10, 0, '08:00:00', '08:30:00', 31,  NOW(), NOW()),
(2, '练字',      '', 15, 11, 0, '10:00:00', '10:30:00', 96,  NOW(), NOW());

-- 4. 插入模板3（每日打卡-唐语晴）的打卡项（不指定id，自动生成）
INSERT INTO checkin_item (template_id, item_name, description, points, sort_order, status, checkin_start_time, checkin_end_time, week_days, create_time, update_time) VALUES
(3, '每日跑步',  '', 10, 1,  0, '06:30:00', '07:00:00', 127, NOW(), NOW()),
(3, '记忆(早上)','', 15, 2,  0, '06:50:00', '07:20:00', 127, NOW(), NOW()),
(3, '数学口算',  '', 20, 3,  0, '09:00:00', '09:30:00', 96,  NOW(), NOW()),
(3, '晨读',      '', 15, 4,  0, '06:45:00', '07:20:00', 127, NOW(), NOW()),
(3, '练字',      '', 20, 5,  0, '09:30:00', '10:30:00', 96,  NOW(), NOW()),
(3, '记忆(下午)','', 15, 7,  0, '16:30:00', '17:00:00', 127, NOW(), NOW()),
(3, '任务抽查',  '', 15, 8,  0, '20:00:00', '20:30:00', 31,  NOW(), NOW()),
(3, '晚上洗漱',  '', 15, 9,  0, '20:00:00', '20:30:00', 127, NOW(), NOW()),
(3, '数学口算',  '', 20, 10, 0, '17:00:00', '18:00:00', 31,  NOW(), NOW()),
(3, '学校作业',  '', 20, 11, 0, '16:00:00', '18:00:00', 31,  NOW(), NOW());

-- 执行完后验证（确认每个模板的打卡项数量）
SELECT t.id, t.template_name, COUNT(i.id) AS item_count
FROM checkin_template t
LEFT JOIN checkin_item i ON t.id = i.template_id
WHERE t.id IN (2, 3)
GROUP BY t.id, t.template_name;
