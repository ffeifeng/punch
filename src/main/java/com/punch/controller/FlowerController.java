package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.FlowerItemService;
import com.punch.service.FlowerRecordService;
import com.punch.service.FlowerRedemptionService;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.*;
/**
 * 小红花移动端接口
 */
@Controller
@RequestMapping("/flower")
public class FlowerController {

    @Autowired private FlowerItemService       flowerItemService;
    @Autowired private FlowerRecordService     flowerRecordService;
    @Autowired private FlowerRedemptionService flowerRedemptionService;
    @Autowired private UserService             userService;

    /** 获取小红花总览信息：当前余量 + 可兑换项目列表（含今日已兑/每日上限） */
    @GetMapping("/info")
    @ResponseBody
    public Map<String, Object> info(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }

        User student = userService.getById(user.getId());
        if (student == null || student.getParentId() == null) {
            result.put("success", false); result.put("message", "无效用户"); return result;
        }

        int balance = flowerRecordService.getCurrentBalance(student.getId());
        java.util.List<com.punch.entity.FlowerItem> items =
                flowerItemService.getEnabledByParentId(student.getParentId());

        result.put("success", true);
        result.put("balance", balance);
        result.put("items", items);
        return result;
    }

    /** 孩子申请兑换 */
    @PostMapping("/redeem")
    @ResponseBody
    public Map<String, Object> redeem(@RequestParam Long itemId,
                                      @RequestParam(defaultValue = "1") int qty,
                                      HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            Map<String, Object> r = new HashMap<>(); r.put("success", false); r.put("message", "未登录"); return r;
        }
        Map<String, Object> result = flowerRedemptionService.redeem(user.getId(), itemId, qty, user.getId());
        if (Boolean.TRUE.equals(result.get("success"))) {
            session.setAttribute("user", userService.getById(user.getId()));
        }
        return result;
    }

    /** 获取小红花变更流水 */
    @GetMapping("/records")
    @ResponseBody
    public Map<String, Object> records(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        result.put("success", true);
        result.put("records", flowerRecordService.getByStudentId(user.getId()));
        return result;
    }

    /** 获取孩子自己的兑换申请记录 */
    @GetMapping("/myRedemptions")
    @ResponseBody
    public Map<String, Object> myRedemptions(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        result.put("success", true);
        result.put("redemptions", flowerRedemptionService.getByStudentId(user.getId()));
        return result;
    }
}
