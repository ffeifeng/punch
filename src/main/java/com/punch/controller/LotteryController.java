package com.punch.controller;

import com.punch.dto.LotteryRecordDTO;
import com.punch.entity.LotteryItem;
import com.punch.entity.LotteryRecord;
import com.punch.entity.User;
import com.punch.service.LotteryItemService;
import com.punch.service.LotteryRecordService;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.*;

@Controller
@RequestMapping("/lottery")
public class LotteryController {

    @Autowired
    private LotteryItemService lotteryItemService;

    @Autowired
    private LotteryRecordService lotteryRecordService;

    @Autowired
    private UserService userService;

    // ==================== 抽奖项管理 ====================

    @GetMapping("/item/list")
    @ResponseBody
    public List<LotteryItem> itemList(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return Collections.emptyList();
        Long parentId = resolveParentId(user);
        if (parentId == null) return Collections.emptyList();
        return lotteryItemService.getByParentId(parentId);
    }

    @PostMapping("/item/add")
    @ResponseBody
    public Map<String, Object> itemAdd(@RequestBody LotteryItem item, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        Long parentId = resolveParentId(user);
        if (parentId == null) { result.put("success", false); result.put("message", "无权限"); return result; }
        item.setParentId(parentId);
        if (item.getStatus() == null) item.setStatus(1);
        lotteryItemService.create(item);
        result.put("success", true);
        return result;
    }

    @PostMapping("/item/update")
    @ResponseBody
    public Map<String, Object> itemUpdate(@RequestBody LotteryItem item, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        LotteryItem existing = lotteryItemService.getById(item.getId());
        if (existing == null) { result.put("success", false); result.put("message", "记录不存在"); return result; }
        Long parentId = resolveParentId(user);
        if (parentId != null && !parentId.equals(existing.getParentId())) {
            result.put("success", false); result.put("message", "无权操作"); return result;
        }
        lotteryItemService.update(item);
        result.put("success", true);
        return result;
    }

    @PostMapping("/item/delete")
    @ResponseBody
    public Map<String, Object> itemDelete(@RequestParam Long id, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        LotteryItem existing = lotteryItemService.getById(id);
        if (existing == null) { result.put("success", false); result.put("message", "记录不存在"); return result; }
        Long parentId = resolveParentId(user);
        if (parentId != null && !parentId.equals(existing.getParentId())) {
            result.put("success", false); result.put("message", "无权操作"); return result;
        }
        lotteryItemService.delete(id);
        result.put("success", true);
        return result;
    }

    @PostMapping("/item/toggleStatus")
    @ResponseBody
    public Map<String, Object> toggleStatus(@RequestParam Long id, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        LotteryItem item = lotteryItemService.getById(id);
        if (item == null) { result.put("success", false); result.put("message", "记录不存在"); return result; }
        Long parentId = resolveParentId(user);
        if (parentId != null && !parentId.equals(item.getParentId())) {
            result.put("success", false); result.put("message", "无权操作"); return result;
        }
        item.setStatus(item.getStatus() == 1 ? 0 : 1);
        lotteryItemService.update(item);
        result.put("success", true);
        result.put("newStatus", item.getStatus());
        return result;
    }

    // ==================== 抽奖记录管理 ====================

    @GetMapping("/record/list")
    @ResponseBody
    public List<LotteryRecordDTO> recordList(@RequestParam(required = false) Long studentId,
                                              @RequestParam(required = false) Integer isRedeemed,
                                              HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return Collections.emptyList();
        Long parentId = resolveParentId(user);
        if (parentId == null) return Collections.emptyList();
        return lotteryRecordService.getByParentId(parentId, studentId, isRedeemed);
    }

    @PostMapping("/record/redeem")
    @ResponseBody
    public Map<String, Object> redeem(@RequestParam Long id, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }
        // 归属校验
        com.punch.entity.LotteryRecord record = lotteryRecordService.getById(id);
        if (record == null) { result.put("success", false); result.put("message", "记录不存在"); return result; }
        Long parentId = resolveParentId(user);
        if (parentId != null) {
            User student = userService.getById(record.getStudentId());
            if (student == null || !parentId.equals(student.getParentId())) {
                result.put("success", false); result.put("message", "无权操作"); return result;
            }
        }
        int rows = lotteryRecordService.redeem(id, user.getId());
        result.put("success", rows > 0);
        return result;
    }

    @PostMapping("/record/toggleRedeem")
    @ResponseBody
    public Map<String, Object> toggleRedeem(@RequestParam Long id,
                                             @RequestParam int isRedeemed,
                                             HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        // 归属校验
        com.punch.entity.LotteryRecord record = lotteryRecordService.getById(id);
        if (record == null) { result.put("success", false); return result; }
        Long parentId = resolveParentId(user);
        if (parentId != null) {
            User student = userService.getById(record.getStudentId());
            if (student == null || !parentId.equals(student.getParentId())) {
                result.put("success", false); return result;
            }
        }
        int rows = isRedeemed == 1
                ? lotteryRecordService.redeem(id, user.getId())
                : lotteryRecordService.cancelRedeem(id);
        result.put("success", rows > 0);
        return result;
    }

    /** 批量兑奖：按奖品ID列表批量标记为已兑奖 */
    @PostMapping("/record/batchRedeem")
    @ResponseBody
    public Map<String, Object> batchRedeem(@RequestBody java.util.Map<String, Object> body,
                                            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        Long parentId = resolveParentId(user);
        @SuppressWarnings("unchecked")
        java.util.List<Object> rawIds = (java.util.List<Object>) body.get("itemIds");
        Object sidObj = body.get("studentId");
        Long studentId = sidObj != null && !sidObj.toString().isEmpty()
                ? Long.parseLong(sidObj.toString()) : null;
        if (rawIds == null || rawIds.isEmpty()) {
            result.put("success", false); result.put("message", "请选择奖品类型"); return result;
        }
        java.util.List<Long> itemIds = rawIds.stream()
                .map(o -> Long.parseLong(o.toString()))
                .collect(java.util.stream.Collectors.toList());
        int count = lotteryRecordService.batchRedeem(parentId, studentId, itemIds, user.getId());
        result.put("success", true);
        result.put("count", count);
        result.put("message", "批量兑奖完成，共处理 " + count + " 条记录");
        return result;
    }

    /** 查询未兑奖记录按奖品分组统计（用于批量兑奖弹窗） */
    @GetMapping("/record/unredeemedSummary")
    @ResponseBody
    public Map<String, Object> unredeemedSummary(@RequestParam(required = false) Long studentId,
                                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        Long parentId = resolveParentId(user);
        result.put("success", true);
        result.put("list", lotteryRecordService.countUnredeemedGroupByItem(parentId, studentId));
        return result;
    }

    // ==================== 工具方法 ====================

    private Long resolveParentId(User user) {
        if ("admin".equals(user.getUsername())) return null;
        // 家长用户
        if (user.getParentId() == null) return user.getId();
        return null;
    }
}
