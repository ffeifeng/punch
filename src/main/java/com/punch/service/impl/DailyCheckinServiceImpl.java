package com.punch.service.impl;

import com.punch.entity.DailyCheckinItem;
import com.punch.entity.User;
import com.punch.entity.CheckinItem;
import com.punch.dto.DailyCheckinItemDTO;
import com.punch.mapper.DailyCheckinItemMapper;
import com.punch.mapper.UserMapper;
import com.punch.mapper.TemplateStudentMapper;
import com.punch.mapper.CheckinItemMapper;
import com.punch.service.DailyCheckinService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

@Service
public class DailyCheckinServiceImpl implements DailyCheckinService {
    
    @Autowired
    private DailyCheckinItemMapper dailyCheckinItemMapper;
    
    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private TemplateStudentMapper templateStudentMapper;
    
    @Autowired
    private CheckinItemMapper checkinItemMapper;
    
    @Override
    @Transactional
    public int generateDailyCheckinItems(Date date) {
        int totalGenerated = 0;
        
        // 获取所有学生
        List<User> students = userMapper.selectStudentUsers();
        
        for (User student : students) {
            totalGenerated += generateDailyCheckinItemsForStudent(student.getId(), date);
        }
        
        return totalGenerated;
    }
    
    @Override
    @Transactional
    public int generateDailyCheckinItemsForStudent(Long studentId, Date date) {
        // 先清理该学生当日的旧数据
        dailyCheckinItemMapper.deleteByStudentAndDate(studentId, date);
        
        List<DailyCheckinItem> dailyItems = new ArrayList<>();
        
        // 获取学生关联的所有模板ID
        List<Long> templateIds = templateStudentMapper.selectTemplateIdsByStudentId(studentId);
        
        for (Long templateId : templateIds) {
            // 获取模板下的所有启用的打卡事项
            List<CheckinItem> items = checkinItemMapper.selectByTemplateId(templateId);
            
            for (CheckinItem item : items) {
                // 只处理启用的事项（status != 2）
                if (item.getStatus() != null && item.getStatus() == 2) {
                    continue; // 跳过禁用的事项
                }
                
                // 检查星期限制：当天不适用则跳过
                if (!isItemApplicableForDate(item, date)) {
                    continue;
                }
                
                // 检查是否已存在
                int existCount = dailyCheckinItemMapper.countByStudentItemAndDate(studentId, item.getId(), date);
                if (existCount > 0) {
                    continue; // 已存在，跳过
                }
                
                // 创建每日打卡事项
                DailyCheckinItem dailyItem = new DailyCheckinItem();
                dailyItem.setStudentId(studentId);
                dailyItem.setItemId(item.getId());
                dailyItem.setCheckinDate(date);
                dailyItem.setStatus(0); // 未打卡
                dailyItem.setPoints(item.getPoints()); // 设置积分
                
                dailyItems.add(dailyItem);
            }
        }
        
        // 批量插入
        if (!dailyItems.isEmpty()) {
            dailyCheckinItemMapper.batchInsert(dailyItems);
        }
        
        return dailyItems.size();
    }
    
    @Override
    public List<DailyCheckinItem> getStudentDailyItems(Long studentId, Date date) {
        return dailyCheckinItemMapper.selectByStudentAndDateWithDetails(studentId, date);
    }
    
    @Override
    @Transactional
    public boolean updateCheckinStatus(Long studentId, Long itemId, Date date, Integer status, Integer points) {
        // 查找对应的每日打卡事项
        List<DailyCheckinItem> items = dailyCheckinItemMapper.selectByStudentAndDate(studentId, date);
        
        for (DailyCheckinItem item : items) {
            if (item.getItemId().equals(itemId)) {
                item.setStatus(status);
                // 注意：不更新points字段，它应该保持原始的事项积分值
                if (status == 1) { // 已打卡
                    item.setCheckinTime(new Date());
                } else if (status == 0) { // 撤销打卡
                    item.setCheckinTime(null);
                    // 注意：撤销时也不清空points字段
                }
                
                int result = dailyCheckinItemMapper.update(item);
                return result > 0;
            }
        }
        
        return false;
    }
    
    @Override
    public int updateExpiredStatus(Date beforeDate) {
        return dailyCheckinItemMapper.updateExpiredStatus(beforeDate);
    }
    
    @Override
    @Transactional
    public int cleanDailyItems(Date date) {
        return dailyCheckinItemMapper.deleteByDate(date);
    }
    
    @Override
    public List<DailyCheckinItem> getTodayCheckinItemsForStudent(Long studentId) {
        Date today = new Date();
        return getStudentDailyItems(studentId, today);
    }
    
    @Override
    @Transactional
    public boolean syncTemplateItemsToSchedule(Long templateId, Date date) {
        try {
            // 1. 获取该模板关联的所有学生
            List<Long> studentIds = templateStudentMapper.selectStudentIdsByTemplateId(templateId);
            
            // 2. 获取该模板的所有启用事项（并按今日星期过滤）
            List<CheckinItem> templateItems = checkinItemMapper.selectByTemplateId(templateId);
            List<CheckinItem> activeItems = templateItems.stream()
                    .filter(item -> item.getStatus() == null || item.getStatus() != 2)
                    .filter(item -> isItemApplicableForDate(item, date))
                    .collect(java.util.stream.Collectors.toList());
            
            // 3. 为每个学生同步事项
            for (Long studentId : studentIds) {
                // 删除该模板在指定日期的旧排期记录
                dailyCheckinItemMapper.deleteByTemplateAndDate(templateId, date);
                
                // 为该学生生成新的排期记录
                for (CheckinItem item : activeItems) {
                    // 检查是否已存在
                    int existCount = dailyCheckinItemMapper.countByStudentItemAndDate(studentId, item.getId(), date);
                    if (existCount == 0) {
                        DailyCheckinItem dailyItem = new DailyCheckinItem();
                        dailyItem.setStudentId(studentId);
                        dailyItem.setItemId(item.getId());
                        dailyItem.setCheckinDate(date);
                        dailyItem.setStatus(0); // 未打卡
                        dailyItem.setPoints(item.getPoints());
                        
                        dailyCheckinItemMapper.insert(dailyItem);
                    }
                }
            }
            
            return true;
        } catch (Exception e) {
            System.err.println("同步模板事项到排期表失败: " + e.getMessage());
            return false;
        }
    }
    
    @Override
    @Transactional
    public int resetAllSchedulesToDate(Date date) {
        return dailyCheckinItemMapper.resetScheduleToDate(date);
    }
    
    @Override
    @Transactional
    public int resetStudentScheduleToDate(Long studentId, Date date) {
        return dailyCheckinItemMapper.resetStudentScheduleToDate(studentId, date);
    }
    
    @Override
    @Transactional
    public Map<String, Integer> syncDailyCheckinItemsForStudent(Long studentId, Date date) {
        Map<String, Integer> result = new HashMap<>();
        int addedCount = 0;
        int updatedCount = 0;
        int deletedCount = 0;
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        System.out.println("=== 同步学生打卡事项 ===");
        System.out.println("学生ID: " + studentId);
        System.out.println("目标日期: " + sdf.format(date));
        
        // 1. 获取学生关联的所有启用模板的打卡事项
        List<Long> templateIds = templateStudentMapper.selectTemplateIdsByStudentId(studentId);
        List<CheckinItem> currentTemplateItems = new ArrayList<>();
        
        for (Long templateId : templateIds) {
            List<CheckinItem> items = checkinItemMapper.selectByTemplateId(templateId);
            for (CheckinItem item : items) {
                // 只处理启用的事项（status != 2），并过滤不适用今日的事项
                if (item.getStatus() == null || item.getStatus() != 2) {
                    if (isItemApplicableForDate(item, date)) {
                        currentTemplateItems.add(item);
                    }
                }
            }
        }
        
        // 2. 获取该学生所有的打卡事项（不限制日期，根据item_id匹配）
        List<DailyCheckinItem> allExistingItems = dailyCheckinItemMapper.selectByStudentId(studentId);
        System.out.println("当前模板事项数量: " + currentTemplateItems.size());
        System.out.println("学生所有已存在事项数量: " + allExistingItems.size());
        
        // 打印已存在的事项详情
        for (DailyCheckinItem existing : allExistingItems) {
            System.out.println("已存在事项 - ID: " + existing.getId() + 
                             ", ItemID: " + existing.getItemId() + 
                             ", Date: " + sdf.format(existing.getCheckinDate()) +
                             ", Status: " + existing.getStatus());
        }
        
        // 3. 根据item_id更新或新增打卡事项
        for (CheckinItem templateItem : currentTemplateItems) {
            // 查找是否已存在该item_id且为当天的记录
            DailyCheckinItem existingTodayItem = allExistingItems.stream()
                .filter(daily -> daily.getItemId().equals(templateItem.getId()) 
                              && isSameDay(daily.getCheckinDate(), date))
                .findFirst()
                .orElse(null);
                
            if (existingTodayItem == null) {
                // 检查是否存在其他日期的相同事项
                DailyCheckinItem existingOtherDayItem = allExistingItems.stream()
                    .filter(daily -> daily.getItemId().equals(templateItem.getId()))
                    .findFirst()
                    .orElse(null);
                    
                if (existingOtherDayItem != null) {
                    // 存在其他日期的记录，但今天没有记录，需要为今天新增
                    System.out.println("为今天新增事项 - TemplateItemID: " + templateItem.getId() + 
                                     ", Name: " + templateItem.getItemName());
                    DailyCheckinItem newDailyItem = new DailyCheckinItem();
                    newDailyItem.setStudentId(studentId);
                    newDailyItem.setItemId(templateItem.getId());
                    newDailyItem.setCheckinDate(date); // 当天日期
                    newDailyItem.setStatus(0); // 未打卡
                    newDailyItem.setPoints(templateItem.getPoints());
                    newDailyItem.setCheckinTime(null);
                    
                    dailyCheckinItemMapper.insert(newDailyItem);
                    addedCount++;
                } else {
                    // 完全新的事项
                    System.out.println("新增全新事项 - TemplateItemID: " + templateItem.getId() + 
                                     ", Name: " + templateItem.getItemName());
                    DailyCheckinItem newDailyItem = new DailyCheckinItem();
                    newDailyItem.setStudentId(studentId);
                    newDailyItem.setItemId(templateItem.getId());
                    newDailyItem.setCheckinDate(date); // 当天日期
                    newDailyItem.setStatus(0); // 未打卡
                    newDailyItem.setPoints(templateItem.getPoints());
                    newDailyItem.setCheckinTime(null);
                    
                    dailyCheckinItemMapper.insert(newDailyItem);
                    addedCount++;
                }
            } else {
                // 今天已存在该事项，只更新积分等信息，但保护打卡状态
                boolean needUpdate = false;
                Integer originalStatus = existingTodayItem.getStatus();
                Date originalCheckinTime = existingTodayItem.getCheckinTime();
                
                System.out.println("检查今天已存在事项 - ExistingID: " + existingTodayItem.getId() + 
                                 ", ItemID: " + existingTodayItem.getItemId() + 
                                 ", 当前状态: " + originalStatus + 
                                 ", 打卡时间: " + (originalCheckinTime != null ? sdf.format(originalCheckinTime) : "未打卡"));
                
                // 只有积分发生变化时才更新
                if (!templateItem.getPoints().equals(existingTodayItem.getPoints())) {
                    existingTodayItem.setPoints(templateItem.getPoints());
                    needUpdate = true;
                    System.out.println("更新积分：" + existingTodayItem.getPoints() + " -> " + templateItem.getPoints());
                }
                
                if (needUpdate) {
                    // 保持原有的打卡状态和时间不变
                    existingTodayItem.setStatus(originalStatus);
                    existingTodayItem.setCheckinTime(originalCheckinTime);
                    existingTodayItem.setUpdateTime(new Date());
                    
                    dailyCheckinItemMapper.update(existingTodayItem);
                    updatedCount++;
                    System.out.println("已更新事项信息，保持打卡状态不变");
                } else {
                    System.out.println("事项信息无变化，跳过更新");
                }
            }
        }
        
        // 4. 处理删除（只删除今天模板中已不存在的事项，保留历史记录）
        for (DailyCheckinItem existingItem : allExistingItems) {
            // 只处理今天的记录
            if (isSameDay(existingItem.getCheckinDate(), date)) {
                boolean stillExists = currentTemplateItems.stream()
                    .anyMatch(template -> template.getId().equals(existingItem.getItemId()));
                    
                if (!stillExists) {
                    // 删除今天模板中不存在的事项
                    System.out.println("删除今天的过期事项 - ExistingID: " + existingItem.getId() + 
                                     ", ItemID: " + existingItem.getItemId() + 
                                     ", 日期: " + sdf.format(existingItem.getCheckinDate()) +
                                     ", 原因: 模板中已不存在此事项");
                    dailyCheckinItemMapper.deleteById(existingItem.getId());
                    deletedCount++;
                }
            }
        }
        
        result.put("added", addedCount);
        result.put("updated", updatedCount);
        result.put("deleted", deletedCount);
        
        System.out.println("同步结果 - 新增: " + addedCount + ", 更新: " + updatedCount + ", 删除: " + deletedCount);
        System.out.println("=== 同步完成 ===");
        
        return result;
    }
    
    @Override
    public List<DailyCheckinItemDTO> getDailyItemsWithDetails(
            String studentName, String templateName, Integer status, Date checkinDate, Long parentId) {
        return dailyCheckinItemMapper.selectDailyItemsWithDetails(
            studentName, templateName, status, checkinDate, parentId
        );
    }
    
    /**
     * 判断打卡事项是否适用于指定日期（根据 weekDays 位掩码）
     * 位定义：1=周一, 2=周二, 4=周三, 8=周四, 16=周五, 32=周六, 64=周日, 127=每天
     */
    private boolean isItemApplicableForDate(CheckinItem item, Date date) {
        Integer weekDays = item.getWeekDays();
        if (weekDays == null || weekDays == 0 || weekDays == 127) {
            return true;
        }
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        // Calendar.SUNDAY=1, MONDAY=2, ..., SATURDAY=7
        int[] calDayToBit = {0, 64, 1, 2, 4, 8, 16, 32};
        int todayBit = calDayToBit[cal.get(Calendar.DAY_OF_WEEK)];
        return (weekDays & todayBit) != 0;
    }

    /**
     * 判断两个日期是否为同一天（忽略时分秒）
     */
    private boolean isSameDay(Date date1, Date date2) {
        if (date1 == null || date2 == null) {
            return false;
        }
        
        Calendar cal1 = Calendar.getInstance();
        cal1.setTime(date1);
        
        Calendar cal2 = Calendar.getInstance();
        cal2.setTime(date2);
        
        return cal1.get(Calendar.YEAR) == cal2.get(Calendar.YEAR) &&
               cal1.get(Calendar.MONTH) == cal2.get(Calendar.MONTH) &&
               cal1.get(Calendar.DAY_OF_MONTH) == cal2.get(Calendar.DAY_OF_MONTH);
    }
}
