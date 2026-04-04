package com.punch.controller;

import com.punch.entity.PointsRecord;
import com.punch.dto.PointsRecordDTO;
import com.punch.entity.User;
import com.punch.service.PointsRecordService;
import com.punch.service.OperationLogService;
import com.punch.entity.OperationLog;
import com.punch.util.IpUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import java.util.List;

@Controller
@RequestMapping("/points")
public class PointsRecordController {
    @Autowired
    private PointsRecordService pointsRecordService;
    @Autowired
    private OperationLogService operationLogService;

    // 查询积分记录（学生只能查自己，家长查名下学生，admin查全部）
    @GetMapping("/list")
    @ResponseBody
    public List<PointsRecordDTO> list(@RequestParam(required = false) Long studentId,
                                      @RequestParam(required = false) Integer type,
                                      @RequestParam(required = false) String date,
                                      HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return null;
        
        // 调试日志
        System.out.println("PointsRecord查询参数 - studentId: " + studentId + ", type: " + type + ", date: " + date);
        
        if (user.getParentId() != null) {
            // 学生只能查自己，支持按日期查询
            if (date != null && !date.trim().isEmpty()) {
                return pointsRecordService.getByConditionWithNames(user.getId(), type, date);
            } else {
                return pointsRecordService.getByConditionWithNames(user.getId(), type);
            }
        } else if ("admin".equals(user.getUsername())) {
            // 管理员可以查看所有或指定学生的积分记录
            if (date != null && !date.trim().isEmpty()) {
                return pointsRecordService.getByConditionWithNames(studentId, type, date);
            } else {
                return pointsRecordService.getByConditionWithNames(studentId, type);
            }
        } else {
            // 家长只能查看自己孩子的积分记录
            if (date != null && !date.trim().isEmpty()) {
                return pointsRecordService.getByParentIdWithNames(user.getId(), studentId, type, date);
            } else {
                return pointsRecordService.getByParentIdWithNames(user.getId(), studentId, type);
            }
        }
    }

    // 增加积分（家长/管理员）
    @PostMapping("/add")
    @ResponseBody
    public String add(@RequestParam Long studentId, @RequestParam int points, @RequestParam String remark, HttpSession session, HttpServletRequest request) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        pointsRecordService.addPoints(studentId, points, 3, user.getId(), remark, null);
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(user.getId());
        log.setOperation("增加积分");
        log.setTargetId(studentId);
        log.setTargetType("User");
        log.setContent("增加" + points + "分, 备注:" + remark);
        log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
        log.setCreateTime(new java.util.Date());
        operationLogService.insert(log);
        return "success";
    }

    // 扣减积分（家长/管理员）
    @PostMapping("/reduce")
    @ResponseBody
    public String reduce(@RequestParam Long studentId, @RequestParam int points, @RequestParam String remark, HttpSession session, HttpServletRequest request) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        pointsRecordService.reducePoints(studentId, points, 3, user.getId(), remark, null);
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(user.getId());
        log.setOperation("扣减积分");
        log.setTargetId(studentId);
        log.setTargetType("User");
        log.setContent("扣减" + points + "分, 备注:" + remark);
        log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
        log.setCreateTime(new java.util.Date());
        operationLogService.insert(log);
        return "success";
    }

    // 删除积分记录（仅管理员）
    @PostMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam Long id, HttpSession session, HttpServletRequest request) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "no_permission";
        pointsRecordService.deleteRecord(id);
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(user.getId());
        log.setOperation("删除积分记录");
        log.setTargetId(id);
        log.setTargetType("PointsRecord");
        log.setContent("积分记录ID:" + id);
        log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
        log.setCreateTime(new java.util.Date());
        operationLogService.insert(log);
        return "success";
    }
}
