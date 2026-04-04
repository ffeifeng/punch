package com.punch.controller;

import com.punch.dto.DailyCheckinItemDTO;
import com.punch.dto.CheckinRecordDTO;
import com.punch.entity.User;
import com.punch.service.DailyCheckinService;
import com.punch.service.CheckinRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

/**
 * 每日打卡事项管理控制器
 */
@Controller
@RequestMapping("/dailyCheckinItem")
public class DailyCheckinItemController {
    
    @Autowired
    private DailyCheckinService dailyCheckinService;
    
    @Autowired
    private CheckinRecordService checkinRecordService;
    
    /**
     * 查询每日打卡事项列表（带搜索条件）
     */
    @GetMapping("/list")
    @ResponseBody
    public Map<String, Object> list(
            @RequestParam(required = false) String studentName,
            @RequestParam(required = false) String templateName,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String checkinDate,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int rows,
            HttpSession session) {
        
        Map<String, Object> result = new HashMap<>();
        
        User user = (User) session.getAttribute("user");
        if (user == null) {
            result.put("total", 0);
            result.put("rows", new java.util.ArrayList<>());
            return result;
        }
        
        // 解析日期
        Date date = null;
        if (checkinDate != null && !checkinDate.trim().isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                date = sdf.parse(checkinDate);
                System.out.println("解析日期成功: " + checkinDate + " -> " + date);
            } catch (ParseException e) {
                System.out.println("日期解析失败: " + checkinDate + ", 使用今天日期");
                // 日期解析失败，使用今天
                date = new Date();
            }
        } else {
            // 默认查询今天
            date = new Date();
            System.out.println("使用默认日期（今天）: " + date);
        }
        
        // 权限控制
        Long parentId = null;
        if ("admin".equals(user.getUsername())) {
            // 管理员可以查看所有
            parentId = null;
        } else if (user.getParentId() == null) {
            // 家长只能查看自己孩子的
            parentId = user.getId();
        } else {
            // 学生用户不能查看这个列表
            result.put("total", 0);
            result.put("rows", new java.util.ArrayList<>());
            return result;
        }
        
        // 检查是否查询未来日期
        Date today = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String todayStr = sdf.format(today);
        String queryDateStr = sdf.format(date);
        
        // 调试信息
        System.out.println("=== 日期查询调试信息 ===");
        System.out.println("原始日期参数: " + checkinDate);
        System.out.println("解析后日期: " + date);
        System.out.println("查询参数: studentName=" + studentName + ", templateName=" + templateName + 
                         ", status=" + status + ", date=" + queryDateStr + ", parentId=" + parentId);
        System.out.println("今天日期: " + todayStr + ", 查询日期: " + queryDateStr);
        System.out.println("日期比较结果: " + queryDateStr + ".compareTo(" + todayStr + ") = " + queryDateStr.compareTo(todayStr));
        System.out.println("用户角色: " + user.getUsername());
        System.out.println("========================");
        
        // 如果查询的是未来日期，返回空结果（除非是管理员）
        // 只比较日期部分，不比较时间
        if (queryDateStr.compareTo(todayStr) > 0 && !"admin".equals(user.getUsername())) {
            System.out.println("查询未来日期（" + queryDateStr + " > " + todayStr + "），返回空结果");
            result.put("total", 0);
            result.put("rows", new java.util.ArrayList<>());
            return result;
        }
        
        List<DailyCheckinItemDTO> items;
        
        // 根据查询日期决定数据源
        if (queryDateStr.equals(todayStr)) {
            // 查询今天的数据：从 daily_checkin_items 表查询（未完成的打卡事项）
            System.out.println("查询今天数据，从 daily_checkin_items 表查询");
            items = dailyCheckinService.getDailyItemsWithDetails(
                studentName, templateName, status, date, parentId
            );
        } else {
            // 查询历史数据：从 checkin_record 表查询（已完成的打卡记录）
            System.out.println("查询历史数据，从 checkin_record 表查询");
            items = getHistoricalCheckinData(studentName, templateName, status, date, parentId, user);
        }
        
        // 手动分页
        int total = items.size();
        int fromIndex = (page - 1) * rows;
        int toIndex = Math.min(fromIndex + rows, total);
        
        List<DailyCheckinItemDTO> paginatedItems;
        if (fromIndex < total) {
            paginatedItems = items.subList(fromIndex, toIndex);
        } else {
            paginatedItems = new java.util.ArrayList<>();
        }
        
        System.out.println("查询结果总数: " + total + ", 分页: " + page + "/" + rows + ", 返回: " + paginatedItems.size());
        
        result.put("total", total);
        result.put("rows", paginatedItems);
        return result;
    }
    
    /**
     * 获取历史打卡数据（从 checkin_record 表查询）
     */
    private List<DailyCheckinItemDTO> getHistoricalCheckinData(String studentName, String templateName, 
                                                              Integer status, Date date, Long parentId, User user) {
        try {
            List<CheckinRecordDTO> records;
            
            if ("admin".equals(user.getUsername())) {
                // 管理员可以查看所有记录
                records = checkinRecordService.getByConditionWithItemName(null, null, date, status);
            } else if (user.getParentId() == null) {
                // 家长只能查看自己孩子的记录
                records = checkinRecordService.getRecordsByParentId(user.getId(), null, date, status);
            } else {
                // 学生只能查看自己的记录
                records = checkinRecordService.getByConditionWithItemName(user.getId(), null, date, status);
            }
            
            // 转换为 DailyCheckinItemDTO 格式
            List<DailyCheckinItemDTO> items = new java.util.ArrayList<>();
            for (CheckinRecordDTO record : records) {
                DailyCheckinItemDTO item = new DailyCheckinItemDTO();
                
                // 基础字段映射
                item.setId(record.getId());
                item.setStudentId(record.getStudentId());
                item.setItemId(record.getItemId());
                item.setCheckinDate(record.getCheckinDate());
                item.setStatus(record.getStatus());
                item.setPoints(0); // 历史记录的积分需要从其他地方获取
                item.setCheckinTime(record.getCheckinTime());
                item.setCreateTime(record.getCreateTime());
                item.setUpdateTime(record.getUpdateTime());
                
                // 扩展字段（CheckinRecordDTO 只有 itemName）
                item.setStudentName(""); // 需要从用户表获取
                item.setTemplateName(""); // 需要从模板表获取
                item.setItemName(record.getItemName() != null ? record.getItemName() : "");
                item.setItemDescription(""); // 需要从事项表获取
                
                // 暂时添加所有记录，搜索过滤功能需要在Service层实现
                // TODO: 在Service层实现完整的搜索过滤功能
                items.add(item);
            }
            
            System.out.println("历史数据查询结果: " + items.size() + " 条记录");
            return items;
            
        } catch (Exception e) {
            System.err.println("查询历史数据失败: " + e.getMessage());
            e.printStackTrace();
            return new java.util.ArrayList<>();
        }
    }
}
