package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.SystemConfigService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/config")
public class SystemConfigController {

    @Autowired
    private SystemConfigService systemConfigService;

    /** 获取当前登录家长的积分兑换比例配置 */
    @GetMapping("/pointsRatio")
    @ResponseBody
    public Map<String, Object> getPointsRatio(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }

        Long parentId = user.getParentId() != null ? user.getParentId() : user.getId();
        int ratio = systemConfigService.getPointsToLotteryRatio(parentId);
        result.put("success", true);
        result.put("ratio", ratio);
        return result;
    }

    /** 保存积分兑换比例配置 */
    @PostMapping("/savePointsRatio")
    @ResponseBody
    public Map<String, Object> savePointsRatio(
            @RequestParam int ratio,
            @RequestParam(required = false) String description,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        if (user.getParentId() != null) { result.put("success", false); result.put("message", "无权限"); return result; }

        if (ratio < 0) { result.put("success", false); result.put("message", "比例不能为负数"); return result; }

        systemConfigService.savePointsToLotteryRatio(user.getId(), ratio,
                "积分兑换抽奖比例",
                description != null ? description : "每消耗" + ratio + "积分可兑换1次抽奖机会");
        result.put("success", true);
        result.put("message", ratio == 0 ? "已关闭积分兑换功能" : "配置已保存，" + ratio + " 积分 = 1 次抽奖");
        return result;
    }
}
