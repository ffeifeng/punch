package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.FlowerItemService;
import com.punch.service.FlowerRecordService;
import com.punch.service.FlowerRedemptionService;
import com.punch.service.UserService;
import com.punch.entity.FlowerItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * 小红花后台管理接口（家长/管理员）
 * - /flower/item/page、/flower/redemption/page：页面跳转
 * - /flower/manage/...：数据 API
 */
@Controller
public class FlowerManageController {

    // ============================= 页面路由 =============================

    @GetMapping("/flower/item/page")
    public String itemPage() { return "flower_item_manage"; }

    @GetMapping("/flower/redemption/page")
    public String redemptionPage() { return "flower_redemption_manage"; }


    @Autowired private FlowerItemService       flowerItemService;
    @Autowired private FlowerRecordService     flowerRecordService;
    @Autowired private FlowerRedemptionService flowerRedemptionService;
    @Autowired private UserService             userService;

    // ============================= 兑换项目管理 =============================

    @GetMapping("/flower/manage/items")
    @ResponseBody
    public List<FlowerItem> listItems(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return Collections.emptyList();
        Long parentId = user.getParentId() != null ? user.getParentId() : user.getId();
        return flowerItemService.getByParentId(parentId);
    }

    @PostMapping("/flower/manage/item/add")
    @ResponseBody
    public Map<String, Object> addItem(@RequestBody FlowerItem item, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getParentId() != null) {
            result.put("success", false); result.put("message", "无权限"); return result;
        }
        item.setParentId(user.getId());
        if (item.getStatus() == null) item.setStatus(1);
        flowerItemService.create(item);
        result.put("success", true);
        return result;
    }

    @PostMapping("/flower/manage/item/update")
    @ResponseBody
    public Map<String, Object> updateItem(@RequestBody FlowerItem item, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getParentId() != null) {
            result.put("success", false); result.put("message", "无权限"); return result;
        }
        flowerItemService.update(item);
        result.put("success", true);
        return result;
    }

    @PostMapping("/flower/manage/item/delete")
    @ResponseBody
    public Map<String, Object> deleteItem(@RequestParam Long id, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getParentId() != null) {
            result.put("success", false); result.put("message", "无权限"); return result;
        }
        flowerItemService.delete(id);
        result.put("success", true);
        return result;
    }

    @PostMapping("/flower/manage/item/toggleStatus")
    @ResponseBody
    public Map<String, Object> toggleStatus(@RequestParam Long id, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null || user.getParentId() != null) {
            result.put("success", false); result.put("message", "无权限"); return result;
        }
        FlowerItem item = flowerItemService.getById(id);
        if (item == null) { result.put("success", false); result.put("message", "不存在"); return result; }
        item.setStatus(item.getStatus() == 1 ? 0 : 1);
        flowerItemService.update(item);
        result.put("success", true);
        return result;
    }

    // ============================= 兑换申请审批 =============================

    /** 查询所有兑换记录（支持按状态过滤） */
    @GetMapping("/flower/manage/redemptions")
    @ResponseBody
    public Map<String, Object> listRedemptions(
            @RequestParam(required = false) Integer status,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        Long parentId = user.getParentId() != null ? user.getParentId() : user.getId();
        result.put("success", true);
        result.put("list", flowerRedemptionService.getByParentId(parentId, status));
        result.put("pendingCount", flowerRedemptionService.getPendingByParentId(parentId).size());
        return result;
    }

    /** 审批通过 */
    @PostMapping("/flower/manage/redemption/approve")
    @ResponseBody
    public Map<String, Object> approve(@RequestParam Long id, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            Map<String, Object> r = new HashMap<>(); r.put("success", false); return r;
        }
        return flowerRedemptionService.approve(id, user.getId());
    }

    /** 撤销（退还小红花） */
    @PostMapping("/flower/manage/redemption/revoke")
    @ResponseBody
    public Map<String, Object> revoke(@RequestParam Long id, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            Map<String, Object> r = new HashMap<>(); r.put("success", false); return r;
        }
        return flowerRedemptionService.revoke(id, user.getId());
    }

    // ============================= 手动调整小红花 =============================

    /**
     * 手动调整某学生的小红花（delta 为正=增加，为负=减少）
     */
    @PostMapping("/flower/manage/adjust")
    @ResponseBody
    public Map<String, Object> adjust(@RequestParam Long studentId,
                                      @RequestParam int delta,
                                      @RequestParam(required = false) String remark,
                                      HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User operator = (User) session.getAttribute("user");
        if (operator == null) { result.put("success", false); result.put("message", "未登录"); return result; }

        User student = userService.getById(studentId);
        if (student == null) { result.put("success", false); result.put("message", "学生不存在"); return result; }

        String remarkStr = remark != null && !remark.trim().isEmpty() ? remark.trim()
                : (delta > 0 ? "家长手动增加小红花" : "家长手动扣减小红花");

        int newBalance;
        if (delta > 0) {
            newBalance = flowerRecordService.addFlowers(studentId, delta, 3, operator.getId(), remarkStr, null);
        } else if (delta < 0) {
            newBalance = flowerRecordService.reduceFlowers(studentId, -delta, 3, operator.getId(), remarkStr, null);
            if (newBalance == -1) {
                result.put("success", false);
                int cur = flowerRecordService.getCurrentBalance(studentId);
                result.put("message", "小红花不足，当前 " + cur + " 朵，无法减少 " + (-delta) + " 朵");
                return result;
            }
        } else {
            result.put("success", false); result.put("message", "调整数量不能为0"); return result;
        }
        result.put("success", true);
        result.put("newBalance", newBalance);
        result.put("message", "调整成功，当前余量：" + newBalance + " 朵");
        return result;
    }

    /** 查询某学生的小红花流水（后台查看） */
    @GetMapping("/flower/manage/records")
    @ResponseBody
    public Map<String, Object> records(@RequestParam Long studentId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        result.put("success", true);
        result.put("balance", flowerRecordService.getCurrentBalance(studentId));
        result.put("records", flowerRecordService.getByStudentId(studentId));
        return result;
    }
}
