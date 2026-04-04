-- 创建每日打卡事项表
-- 用于存储每个学生每天的打卡事项及其状态
CREATE TABLE `daily_checkin_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `item_id` bigint(20) NOT NULL COMMENT '打卡事项ID',
  `checkin_date` date NOT NULL COMMENT '打卡日期',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态：0-未打卡，1-已打卡，2-已过期',
  `points` int(11) DEFAULT NULL COMMENT '获得积分（打卡后记录）',
  `checkin_time` datetime DEFAULT NULL COMMENT '实际打卡时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_item_date` (`student_id`,`item_id`,`checkin_date`) COMMENT '学生-事项-日期唯一索引',
  KEY `idx_student_date` (`student_id`,`checkin_date`) COMMENT '学生-日期索引',
  KEY `idx_checkin_date` (`checkin_date`) COMMENT '日期索引',
  CONSTRAINT `fk_daily_checkin_student` FOREIGN KEY (`student_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_daily_checkin_item` FOREIGN KEY (`item_id`) REFERENCES `checkin_item` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='每日打卡事项表';
