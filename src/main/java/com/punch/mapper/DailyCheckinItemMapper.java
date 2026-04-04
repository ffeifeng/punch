package com.punch.mapper;

import com.punch.entity.DailyCheckinItem;
import com.punch.dto.DailyCheckinItemDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.Date;
import java.util.List;

@Mapper
public interface DailyCheckinItemMapper {
    
    /**
     * 插入每日打卡事项
     */
    int insert(DailyCheckinItem dailyCheckinItem);
    
    /**
     * 批量插入每日打卡事项
     */
    int batchInsert(@Param("items") List<DailyCheckinItem> items);
    
    /**
     * 更新每日打卡事项
     */
    int update(DailyCheckinItem dailyCheckinItem);
    
    /**
     * 根据ID查询
     */
    DailyCheckinItem selectById(@Param("id") Long id);
    
    /**
     * 查询学生某日的打卡事项
     */
    List<DailyCheckinItem> selectByStudentAndDate(@Param("studentId") Long studentId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 查询学生所有的打卡事项（不限制日期）
     */
    List<DailyCheckinItem> selectByStudentId(@Param("studentId") Long studentId);
    
    /**
     * 查询学生某日的打卡事项（带事项详情）
     */
    List<DailyCheckinItem> selectByStudentAndDateWithDetails(@Param("studentId") Long studentId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 查询某日期的所有打卡事项
     */
    List<DailyCheckinItem> selectByDate(@Param("checkinDate") Date checkinDate);
    
    /**
     * 删除某日期的所有打卡事项
     */
    int deleteByDate(@Param("checkinDate") Date checkinDate);
    
    /**
     * 删除学生某日的打卡事项
     */
    int deleteByStudentAndDate(@Param("studentId") Long studentId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 检查学生某日某事项是否已存在
     */
    int countByStudentItemAndDate(@Param("studentId") Long studentId, @Param("itemId") Long itemId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 更新过期状态
     */
    int updateExpiredStatus(@Param("checkinDate") Date checkinDate);
    
    /**
     * 根据模板ID和日期删除排期记录
     */
    int deleteByTemplateAndDate(@Param("templateId") Long templateId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 重置排期数据到指定日期（更新日期和状态）
     */
    int resetScheduleToDate(@Param("checkinDate") Date checkinDate);
    
    /**
     * 重置指定学生的排期数据到指定日期
     */
    int resetStudentScheduleToDate(@Param("studentId") Long studentId, @Param("checkinDate") Date checkinDate);
    
    /**
     * 根据学生ID和事项ID查询排期记录
     */
    List<DailyCheckinItem> selectByStudentAndItem(@Param("studentId") Long studentId, @Param("itemId") Long itemId);
    
    /**
     * 根据ID删除记录
     */
    int deleteById(@Param("id") Long id);
    
    /**
     * 查询每日打卡事项列表（带学生信息和搜索条件）
     * @param studentName 学生姓名（模糊搜索）
     * @param templateName 模板名称（模糊搜索）
     * @param status 状态（精确匹配）
     * @param checkinDate 打卡日期
     * @param parentId 家长ID（权限控制，如果为null则查询所有）
     * @return 包含学生信息的每日打卡事项列表
     */
    List<DailyCheckinItemDTO> selectDailyItemsWithDetails(
        @Param("studentName") String studentName,
        @Param("templateName") String templateName,
        @Param("status") Integer status,
        @Param("checkinDate") Date checkinDate,
        @Param("parentId") Long parentId
    );
}
