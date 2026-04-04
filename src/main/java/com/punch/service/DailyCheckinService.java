package com.punch.service;

import com.punch.entity.DailyCheckinItem;
import com.punch.dto.DailyCheckinItemDTO;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 每日打卡服务接口
 */
public interface DailyCheckinService {
    
    /**
     * 为所有学生生成指定日期的打卡事项
     * @param date 日期
     * @return 生成的事项数量
     */
    int generateDailyCheckinItems(Date date);
    
    /**
     * 为指定学生生成指定日期的打卡事项
     * @param studentId 学生ID
     * @param date 日期
     * @return 生成的事项数量
     */
    int generateDailyCheckinItemsForStudent(Long studentId, Date date);
    
    /**
     * 获取学生指定日期的打卡事项
     * @param studentId 学生ID
     * @param date 日期
     * @return 打卡事项列表
     */
    List<DailyCheckinItem> getStudentDailyItems(Long studentId, Date date);
    
    /**
     * 更新打卡状态
     * @param studentId 学生ID
     * @param itemId 事项ID
     * @param date 日期
     * @param status 状态：0-未打卡，1-已打卡，2-已过期
     * @param points 积分（已弃用，保持兼容性）
     * @return 更新结果
     */
    boolean updateCheckinStatus(Long studentId, Long itemId, Date date, Integer status, Integer points);
    
    /**
     * 更新过期状态
     * @param beforeDate 指定日期之前的未打卡事项标记为过期
     * @return 更新数量
     */
    int updateExpiredStatus(Date beforeDate);
    
    /**
     * 清理指定日期的打卡事项
     * @param date 日期
     * @return 清理数量
     */
    int cleanDailyItems(Date date);
    
    /**
     * 获取学生今日打卡事项（带详细信息）
     * @param studentId 学生ID
     * @return 打卡事项DTO列表
     */
    List<DailyCheckinItem> getTodayCheckinItemsForStudent(Long studentId);
    
    /**
     * 同步模板事项变更到排期表
     * @param templateId 模板ID
     * @param date 日期
     * @return 同步结果
     */
    boolean syncTemplateItemsToSchedule(Long templateId, Date date);
    
    /**
     * 重置所有学生的排期数据到指定日期
     * @param date 目标日期
     * @return 重置的记录数
     */
    int resetAllSchedulesToDate(Date date);
    
    /**
     * 重置指定学生的排期数据到指定日期
     * @param studentId 学生ID
     * @param date 目标日期
     * @return 重置的记录数
     */
    int resetStudentScheduleToDate(Long studentId, Date date);
    
    /**
     * 智能同步学生的每日打卡事项
     * 不会重复生成已存在的事项，只会：
     * 1. 新增缺失的事项
     * 2. 更新已有事项的信息（积分、名称、时间等）
     * 3. 删除不再需要的事项
     * @param studentId 学生ID
     * @param date 日期
     * @return 同步结果统计：added, updated, deleted
     */
    Map<String, Integer> syncDailyCheckinItemsForStudent(Long studentId, Date date);
    
    /**
     * 查询每日打卡事项列表（带学生信息和搜索条件）
     * @param studentName 学生姓名（模糊搜索）
     * @param templateName 模板名称（模糊搜索）
     * @param status 状态（精确匹配）
     * @param checkinDate 打卡日期
     * @param parentId 家长ID（权限控制，如果为null则查询所有）
     * @return 包含学生信息的每日打卡事项列表
     */
    List<DailyCheckinItemDTO> getDailyItemsWithDetails(
        String studentName, String templateName, Integer status, Date checkinDate, Long parentId
    );
}
