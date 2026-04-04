package com.punch.controller;


import com.punch.dto.CheckinRecordDTO;
import com.punch.entity.User;
import com.punch.service.CheckinRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping("/checkinRecord")
public class CheckinRecordController {
    @Autowired
    private CheckinRecordService recordService;

    // 查询打卡记录（按角色）
    @GetMapping("/list")
    @ResponseBody
    public List<CheckinRecordDTO> list(@RequestParam(required = false) Long studentId,
                                       @RequestParam(required = false) Long itemId,
                                       @RequestParam(required = false) String date,
                                       @RequestParam(required = false) Integer status,
                                       HttpSession session) throws Exception {
        User user = (User) session.getAttribute("user");
        if (user == null) return new java.util.ArrayList<>();
        
        Date d = null;
        if (date != null && !date.isEmpty()) {
            d = new SimpleDateFormat("yyyy-MM-dd").parse(date);
        }
        
        // admin可查全部
        if ("admin".equals(user.getUsername())) {
            Long sid = studentId; // admin可以指定学生ID查询
            return recordService.getByConditionWithItemName(sid, itemId, d, status);
        }
        // 学生只能查自己
        else if (user.getParentId() != null) {
            Long sid = user.getId();
            return recordService.getByConditionWithItemName(sid, itemId, d, status);
        }
        // 家长只能查自己孩子的记录
        else {
            return recordService.getRecordsByParentId(user.getId(), itemId, d, status);
        }
    }

    // 学生打卡
    @PostMapping("/doCheckin")
    @ResponseBody
    public String doCheckin(@RequestParam Long itemId, 
                           @RequestParam(required = false) Long studentId, 
                           HttpSession session, 
                           HttpServletRequest request) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        
        Long targetStudentId;
        // 学生只能给自己打卡
        if (user.getParentId() != null) {
            targetStudentId = user.getId();
        } 
        // admin可以给任何学生打卡，如果没指定学生ID则给自己打卡
        else {
            targetStudentId = (studentId != null) ? studentId : user.getId();
        }
        
        Date today = new Date();
        String clientIp = com.punch.util.IpUtils.getClientIpAddressWithLocalDetection(request);
        return recordService.doCheckin(targetStudentId, itemId, today, user.getId(), clientIp);
    }

    // 撤销打卡
    @PostMapping("/cancel")
    @ResponseBody
    public String cancel(@RequestParam Long recordId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        return recordService.cancelCheckin(recordId, user.getId());
    }

    // 撤销今日打卡（根据学生ID和事项ID）
    @PostMapping("/revokeToday")
    @ResponseBody
    public String revokeToday(@RequestParam Long itemId, 
                             @RequestParam(required = false) Long studentId, 
                             HttpSession session, 
                             HttpServletRequest request) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        
        Long targetStudentId;
        // 学生只能撤销自己的打卡
        if (user.getParentId() != null) {
            targetStudentId = user.getId();
        } 
        // admin和家长可以撤销指定学生的打卡
        else {
            targetStudentId = (studentId != null) ? studentId : user.getId();
        }
        
        Date today = new Date();
        String clientIp = com.punch.util.IpUtils.getClientIpAddressWithLocalDetection(request);
        return recordService.revokeTodayCheckin(targetStudentId, itemId, today, user.getId(), clientIp);
    }

    // 补打卡（家长/管理员）
    @PostMapping("/supplement")
    @ResponseBody
    public String supplement(@RequestParam Long studentId, @RequestParam Long itemId, @RequestParam String date, HttpSession session) throws Exception {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        Date d = new SimpleDateFormat("yyyy-MM-dd").parse(date);
        return recordService.supplementCheckin(studentId, itemId, d, user.getId());
    }

    // 获取今日可打卡事项（移动端专用）
    @GetMapping("/todayItems")
    @ResponseBody
    public List<com.punch.dto.CheckinItemDTO> getTodayItems(@RequestParam(required = false) Long studentId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return new java.util.ArrayList<>();
        
        Long targetStudentId;
        // 学生只能查看自己的事项
        if (user.getParentId() != null) {
            targetStudentId = user.getId();
        } 
        // admin可以查看指定学生的事项
        else {
            targetStudentId = (studentId != null) ? studentId : user.getId();
        }
        
        // 获取该学生今日的打卡事项及状态
        return recordService.getTodayCheckinItems(targetStudentId);
    }
}
