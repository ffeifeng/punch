package com.punch.controller;

import com.punch.entity.DailyCheckinItem;
import com.punch.entity.User;
import com.punch.service.DailyCheckinService;
import com.punch.service.ScheduledTaskService;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 每日打卡控制器
 */
@Controller
@RequestMapping("/dailyCheckin")
public class DailyCheckinController {
    
    @Autowired
    private DailyCheckinService dailyCheckinService;
    
    @Autowired
    private ScheduledTaskService scheduledTaskService;
    
    @Autowired
    private UserService userService;
    
    /**
     * 获取学生今日打卡事项
     */
    @GetMapping("/todayItems")
    @ResponseBody
    public List<DailyCheckinItem> getTodayItems(@RequestParam(required = false) Long studentId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return new java.util.ArrayList<>();
        }
        
        Long targetStudentId;
        // 学生只能查看自己的事项
        if (user.getParentId() != null) {
            targetStudentId = user.getId();
        } 
        // admin可以查看指定学生的事项
        else {
            targetStudentId = (studentId != null) ? studentId : user.getId();
        }
        
        // 获取今天的日期
        Date today = new Date();
        
        // 获取学生今日的打卡事项
        return dailyCheckinService.getStudentDailyItems(targetStudentId, today);
    }
    
    /**
     * 手动刷新今日打卡事项（管理员功能）
     */
    @PostMapping("/refreshToday")
    @ResponseBody
    public Map<String, Object> refreshTodayItems(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getUsername())) {
            result.put("success", false);
            result.put("message", "权限不足");
            return result;
        }
        
        try {
            String refreshResult = scheduledTaskService.manualRefreshTodayItems();
            result.put("success", true);
            result.put("message", refreshResult);
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "刷新失败: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 为指定学生生成今日打卡事项
     */
    @PostMapping("/generateForStudent")
    @ResponseBody
    public Map<String, Object> generateForStudent(@RequestParam Long studentId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null) {
            result.put("success", false);
            result.put("message", "请先登录");
            return result;
        }
        
        // 权限检查：admin可以为任何学生生成，家长只能为自己的孩子生成
        if (!"admin".equals(user.getUsername())) {
            if (user.getParentId() != null) {
                // 学生无权操作
                result.put("success", false); result.put("message", "权限不足"); return result;
            }
            // 家长：验证 studentId 是否属于自己
            User student = userService.getById(studentId);
            if (student == null || !user.getId().equals(student.getParentId())) {
                result.put("success", false); result.put("message", "无权为该学生操作"); return result;
            }
        }
        
        try {
            Date today = new Date();
            int count = dailyCheckinService.generateDailyCheckinItemsForStudent(studentId, today);
            result.put("success", true);
            result.put("message", "生成成功，共生成 " + count + " 个打卡事项");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "生成失败: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 家长刷新自己孩子的今日打卡事项
     */
    @PostMapping("/refreshStudentItems")
    @ResponseBody
    public Map<String, Object> refreshStudentItems(@RequestParam(required = false) Long studentId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null) {
            result.put("success", false);
            result.put("message", "请先登录");
            return result;
        }
        
        try {
            // 获取今天的日期（只包含年月日，不包含时分秒）
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.set(java.util.Calendar.HOUR_OF_DAY, 0);
            cal.set(java.util.Calendar.MINUTE, 0);
            cal.set(java.util.Calendar.SECOND, 0);
            cal.set(java.util.Calendar.MILLISECOND, 0);
            Date today = cal.getTime();
            
            System.out.println("同步打卡事项 - 目标日期: " + new SimpleDateFormat("yyyy-MM-dd").format(today));
            
            int totalCount = 0;
            
            if ("admin".equals(user.getUsername())) {
                // 管理员：可以刷新指定学生或所有学生
                if (studentId != null) {
                    int count = dailyCheckinService.generateDailyCheckinItemsForStudent(studentId, today);
                    totalCount = count;
                    result.put("message", "已为学生刷新 " + count + " 个打卡事项");
                } else {
                    String refreshResult = scheduledTaskService.manualRefreshTodayItems();
                    result.put("message", refreshResult);
                }
            } else if (user.getParentId() == null) {
                // 家长：只能刷新自己孩子的打卡事项
                List<User> children = userService.getStudentsByParentId(user.getId());
                if (children.isEmpty()) {
                    result.put("success", false);
                    result.put("message", "您还没有孩子的账号");
                    return result;
                }
                
                // 如果指定了学生ID，检查是否是自己的孩子
                if (studentId != null) {
                    boolean isMyChild = children.stream().anyMatch(child -> child.getId().equals(studentId));
                    if (!isMyChild) {
                        result.put("success", false);
                        result.put("message", "您只能刷新自己孩子的打卡事项");
                        return result;
                    }
                    // 同步指定孩子的打卡事项
                    Map<String, Integer> syncResult = dailyCheckinService.syncDailyCheckinItemsForStudent(studentId, today);
                    totalCount = syncResult.get("added") + syncResult.get("updated");
                    result.put("message", "同步完成！新增" + syncResult.get("added") + 
                             "项，更新" + syncResult.get("updated") + 
                             "项，删除" + syncResult.get("deleted") + "项");
                } else {
                    // 同步所有孩子的打卡事项
                    StringBuilder messageBuilder = new StringBuilder();
                    for (User child : children) {
                        Map<String, Integer> syncResult = dailyCheckinService.syncDailyCheckinItemsForStudent(child.getId(), today);
                        int childTotal = syncResult.get("added") + syncResult.get("updated");
                        totalCount += childTotal;
                        
                        if (messageBuilder.length() > 0) {
                            messageBuilder.append("；");
                        }
                        messageBuilder.append(child.getRealName())
                                     .append("：新增").append(syncResult.get("added"))
                                     .append("项，更新").append(syncResult.get("updated"))
                                     .append("项，删除").append(syncResult.get("deleted")).append("项");
                    }
                    result.put("message", "同步完成！" + messageBuilder.toString());
                }
            } else {
                // 学生：不允许刷新
                result.put("success", false);
                result.put("message", "学生用户无权限执行此操作");
                return result;
            }
            
            result.put("success", true);
            result.put("count", totalCount);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "刷新失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
    
    /**
     * 管理员专用：清理未来日期的打卡事项数据
     */
    @PostMapping("/cleanFutureData")
    @ResponseBody
    public Map<String, Object> cleanFutureData(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getUsername())) {
            result.put("success", false);
            result.put("message", "权限不足，只有管理员可以执行此操作");
            return result;
        }
        
        try {
            // 获取今天的日期
            Date today = new Date();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdf.format(today);
            
            System.out.println("开始清理未来日期的数据，今天是: " + todayStr);
            
            // 这里需要在Service中添加清理方法
            // int deletedCount = dailyCheckinService.cleanFutureData(today);
            
            result.put("success", true);
            result.put("message", "数据清理功能正在开发中，请联系技术人员手动清理数据库");
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "清理失败: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
}
