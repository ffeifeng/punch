package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.ScheduledTaskService;
import com.punch.service.DailyCheckinService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Date;

/**
 * 管理员功能控制器
 */
@Controller
@RequestMapping("/admin")
public class AdminController {
    
    @Autowired
    private ScheduledTaskService scheduledTaskService;
    
    @Autowired
    private DailyCheckinService dailyCheckinService;
    
    /**
     * 手动刷新今日打卡事项
     */
    @PostMapping("/refreshTodayItems")
    @ResponseBody
    public Map<String, Object> refreshTodayItems(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getUsername())) {
            result.put("success", false);
            result.put("message", "权限不足，只有管理员可以执行此操作");
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
     * 测试用的排期刷新接口（无权限验证）
     */
    @GetMapping("/testRefresh")
    @ResponseBody
    public Map<String, Object> testRefresh() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            String refreshResult = scheduledTaskService.manualRefreshTodayItems();
            result.put("success", true);
            result.put("message", refreshResult);
            result.put("timestamp", System.currentTimeMillis());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "刷新失败: " + e.getMessage());
            result.put("error", e.getClass().getSimpleName());
        }
        
        return result;
    }
    
    /**
     * 查询今日排期数据（调试用）
     */
    @GetMapping("/debugTodayItems")
    @ResponseBody
    public Map<String, Object> debugTodayItems(@RequestParam(required = false) Long studentId) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            Date today = new Date();
            
            // 如果没有指定学生ID，查询所有今日排期数据
            if (studentId == null) {
                // 这里需要添加查询所有今日数据的方法
                result.put("message", "请提供学生ID参数，例如：/admin/debugTodayItems?studentId=4");
                result.put("success", true);
            } else {
                // 查询指定学生的今日排期数据
                List<com.punch.entity.DailyCheckinItem> items = dailyCheckinService.getStudentDailyItems(studentId, today);
                
                result.put("success", true);
                result.put("studentId", studentId);
                result.put("date", today.toString());
                result.put("itemCount", items.size());
                result.put("items", items);
            }
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "查询失败: " + e.getMessage());
            result.put("error", e.getClass().getSimpleName());
            e.printStackTrace();
        }
        
        return result;
    }
}
