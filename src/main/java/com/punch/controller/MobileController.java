package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.UserService;
import com.punch.service.CheckinItemService;
import com.punch.service.PointsRecordService;
import com.punch.service.LotteryItemService;
import com.punch.service.LotteryRecordService;
import com.punch.service.SystemConfigService;
import com.punch.entity.LotteryItem;
import com.punch.entity.LotteryRecord;
import com.punch.util.QrCodeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * 移动端控制器
 */
@Controller
@RequestMapping("/mobile")
public class MobileController {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CheckinItemService checkinItemService;
    
    @Autowired
    private PointsRecordService pointsRecordService;

    @Autowired
    private LotteryItemService lotteryItemService;

    @Autowired
    private LotteryRecordService lotteryRecordService;

    @Autowired
    private SystemConfigService systemConfigService;

    @Autowired
    private com.punch.mapper.UserPityCountMapper userPityCountMapper;
    
    /**
     * 移动端登录页面
     */
    @GetMapping("/login")
    public String loginPage(@RequestParam(required = false) String qr, Model model) {
        model.addAttribute("qrCode", qr);
        return "mobile/login";
    }
    
    /**
     * 二维码预览页面
     */
    @GetMapping("/qrcode")
    public String qrcodePage(@RequestParam(required = false) String qr, Model model) {
        model.addAttribute("qrCode", qr);
        return "mobile/qrcode";
    }
    
    /**
     * 移动端登录接口（仅限学生）
     */
    @PostMapping("/login")
    @ResponseBody
    public Map<String, Object> login(@RequestParam String password,
                                   @RequestParam(required = false) String qrCode,
                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User user = null;
            
            // 如果有二维码，通过二维码找到对应的学生
            if (qrCode != null && !qrCode.trim().isEmpty()) {
                user = userService.getByQrCode(qrCode);
                if (user == null) {
                    result.put("success", false);
                    result.put("message", "无效的二维码");
                    return result;
                }
                
                // 验证密码
                if (!password.equals(user.getPassword())) {
                    result.put("success", false);
                    result.put("message", "密码错误");
                    return result;
                }
            } else {
                result.put("success", false);
                result.put("message", "缺少二维码参数");
                return result;
            }
            
            // 检查是否为学生用户
            if (user.getParentId() == null) {
                result.put("success", false);
                result.put("message", "此登录方式仅限学生使用");
                return result;
            }
            
            // 检查用户状态
            if (user.getStatus() != 1) {
                result.put("success", false);
                result.put("message", "账号已被禁用，请联系管理员");
                return result;
            }
            
            // 登录成功，保存到session（使用统一的key）
            session.setAttribute("user", user);
            
            result.put("success", true);
            result.put("message", "登录成功");
            result.put("studentId", user.getId());
            result.put("studentName", user.getRealName());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "登录失败：" + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 移动端打卡页面
     */
    @GetMapping("/checkin")
    public String checkinPage(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/mobile/login";
        }
        
        // 获取学生当前总积分
        int totalPoints = pointsRecordService.getCurrentBalance(user.getId());
        
        model.addAttribute("student", user);
        model.addAttribute("totalPoints", totalPoints);
        
        return "mobile/checkin";
    }
    
    /**
     * 移动端退出登录
     */
    @PostMapping("/logout")
    @ResponseBody
    public Map<String, Object> logout(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        session.removeAttribute("user");
        result.put("success", true);
        result.put("message", "退出成功");
        return result;
    }
    
    /**
     * 获取当前登录的移动端用户信息
     */
    @GetMapping("/currentUser")
    @ResponseBody
    public User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    /**
     * 实时获取当前学生积分余额（从数据库查，不走session缓存）
     */
    @GetMapping("/currentPoints")
    @ResponseBody
    public Map<String, Object> getCurrentPoints(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        int balance = pointsRecordService.getCurrentBalance(user.getId());
        result.put("success", true);
        result.put("totalPoints", balance);
        return result;
    }

    /**
     * 获取可用的抽奖项（学生端）
     */
    @GetMapping("/lotteryItems")
    @ResponseBody
    public Map<String, Object> getLotteryItems(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }

        // 通过学生找到家长
        User student = userService.getById(user.getId());
        if (student == null || student.getParentId() == null) {
            result.put("success", false); result.put("message", "无效用户"); return result;
        }
        java.util.List<LotteryItem> items = lotteryItemService.getEnabledByParentId(student.getParentId());
        result.put("success", true);
        result.put("items", items);
        result.put("lotteryCount", student.getLotteryCount() != null ? student.getLotteryCount() : 0);
        return result;
    }

    /**
     * 执行抽奖（学生端）
     * 保底机制：每个保底奖品拥有独立阈值和独立计数器。
     * 若本次抽奖使某个保底奖品的计数器达到阈值，且本次自然中奖不是该奖品，则强制赠送最"逾期"的保底奖品。
     */
    @PostMapping("/doLottery")
    @ResponseBody
    public Map<String, Object> doLottery(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }

        User student = userService.getById(user.getId());
        if (student == null || student.getParentId() == null) {
            result.put("success", false); result.put("message", "无效用户"); return result;
        }

        int remaining = student.getLotteryCount() != null ? student.getLotteryCount() : 0;
        if (remaining <= 0) {
            result.put("success", false);
            result.put("message", "抽奖次数已用完，请联系家长补充次数 😢");
            result.put("remainingCount", 0);
            result.put("errorType", "NO_COUNT");
            return result;
        }

        java.util.List<LotteryItem> items = lotteryItemService.getEnabledByParentId(student.getParentId());
        if (items == null || items.isEmpty()) {
            result.put("success", false);
            result.put("message", "奖品列表已变更，请刷新页面重试 🔄");
            result.put("remainingCount", remaining);
            result.put("errorType", "NO_ITEMS");
            return result;
        }

        // 按概率加权随机抽取
        LotteryItem won = weightedRandom(items);
        if (won == null) {
            result.put("success", false);
            result.put("message", "抽奖失败，请稍后再试");
            result.put("remainingCount", remaining);
            result.put("errorType", "DRAW_FAIL");
            return result;
        }

        // ========== 保底机制（各奖品独立阈值 + 独立计数器）==========
        java.util.List<LotteryItem> pityPrizes =
                lotteryItemService.getEnabledPityPrizesByParentId(student.getParentId());

        // 读取该学生对所有保底奖品的当前计数
        java.util.Map<Long, Integer> pityCountMap = new java.util.HashMap<>();
        if (!pityPrizes.isEmpty()) {
            for (com.punch.entity.UserPityCount c :
                    userPityCountMapper.selectByStudentId(student.getId())) {
                pityCountMap.put(c.getItemId(), c.getCount());
            }
        }

        boolean pityTriggered = false;
        LotteryItem forcedPrize = null;

        if (!pityPrizes.isEmpty()) {
            // 找出本次抽奖后会达到（或超过）各自阈值的保底奖品
            java.util.List<LotteryItem> triggered = new java.util.ArrayList<>();
            for (LotteryItem pityItem : pityPrizes) {
                int cur = pityCountMap.getOrDefault(pityItem.getId(), 0);
                if ((cur + 1) >= pityItem.getPityThreshold()) {
                    triggered.add(pityItem);
                }
            }

            if (!triggered.isEmpty()) {
                // 判断本次自然中奖是否已经命中了某个触发的保底奖品
                final Long naturalWonId = won.getId();
                boolean naturalHitsTriggered = triggered.stream()
                        .anyMatch(t -> t.getId().equals(naturalWonId));

                if (!naturalHitsTriggered) {
                    // 强制赠送"最逾期"的保底奖品：
                    //   优先按 (count+1 - threshold) 降序（欠账最多的先还）；
                    //   相同时按 threshold 升序（阈值最小的优先）
                    triggered.sort((a, b) -> {
                        int overdueA = pityCountMap.getOrDefault(a.getId(), 0) + 1 - a.getPityThreshold();
                        int overdueB = pityCountMap.getOrDefault(b.getId(), 0) + 1 - b.getPityThreshold();
                        if (overdueB != overdueA) return overdueB - overdueA;
                        return a.getPityThreshold() - b.getPityThreshold();
                    });
                    forcedPrize = triggered.get(0);
                    won = forcedPrize;
                    pityTriggered = true;
                }
                // 若自然中了触发列表中的某个保底奖品，视为"自然命中保底"，无需强制
            }
        }

        // 扣减抽奖次数
        student.setLotteryCount(remaining - 1);
        userService.updateUser(student);
        session.setAttribute("user", userService.getById(student.getId()));

        // 更新所有保底奖品的独立计数器
        final Long wonItemId = won.getId();
        for (LotteryItem pityItem : pityPrizes) {
            int newCount = wonItemId.equals(pityItem.getId())
                    ? 0  // 中了（自然或强制），重置
                    : pityCountMap.getOrDefault(pityItem.getId(), 0) + 1;  // 未中，+1
            userPityCountMapper.upsert(student.getId(), pityItem.getId(), newCount);
        }
        // ========== 保底机制结束 ==========

        // 创建抽奖记录
        LotteryRecord record = new LotteryRecord();
        record.setStudentId(student.getId());
        record.setItemId(won.getId());
        record.setItemName(won.getName());
        lotteryRecordService.create(record);

        result.put("success", true);
        result.put("prize", won.getName());
        result.put("remainingCount", remaining - 1);
        result.put("pityTriggered", pityTriggered);
        return result;
    }

    /**
     * 我的抽奖记录（学生端，支持按兑换状态过滤）
     */
    @GetMapping("/myLotteryRecords")
    @ResponseBody
    public Map<String, Object> myLotteryRecords(
            @RequestParam(required = false) Integer isRedeemed,
            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }
        java.util.List<LotteryRecord> records = isRedeemed != null
                ? lotteryRecordService.getByStudentIdAndStatus(user.getId(), isRedeemed)
                : lotteryRecordService.getByStudentId(user.getId());
        result.put("success", true);
        result.put("records", records);
        return result;
    }

    /**
     * 获取当前积分兑换配置（学生端）
     */
    @GetMapping("/exchangeConfig")
    @ResponseBody
    public Map<String, Object> getExchangeConfig(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); return result; }

        User student = userService.getById(user.getId());
        if (student == null || student.getParentId() == null) {
            result.put("success", false); return result;
        }
        int currentPoints = pointsRecordService.getCurrentBalance(student.getId());
        int ratio = systemConfigService.getPointsToLotteryRatio(student.getParentId());
        result.put("success", true);
        result.put("ratio", ratio);
        result.put("currentPoints", currentPoints);
        result.put("enabled", ratio > 0);
        // 当前积分最多能兑换几次
        result.put("maxExchangeable", ratio > 0 ? currentPoints / ratio : 0);
        return result;
    }

    /**
     * 积分兑换抽奖次数（学生端）
     */
    @PostMapping("/exchangePoints")
    @ResponseBody
    public Map<String, Object> exchangePoints(@RequestParam int times, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { result.put("success", false); result.put("message", "未登录"); return result; }

        if (times <= 0) { result.put("success", false); result.put("message", "兑换次数必须大于0"); return result; }

        User student = userService.getById(user.getId());
        if (student == null || student.getParentId() == null) {
            result.put("success", false); result.put("message", "无效用户"); return result;
        }

        int ratio = systemConfigService.getPointsToLotteryRatio(student.getParentId());
        if (ratio <= 0) {
            result.put("success", false); result.put("message", "积分兑换功能未开启"); return result;
        }

        int currentPoints = pointsRecordService.getCurrentBalance(student.getId());
        int maxExchangeable = currentPoints / ratio;
        int needed = ratio * times;

        if (times > maxExchangeable || currentPoints < needed) {
            result.put("success", false);
            result.put("message", "积分不足！当前 " + currentPoints + " 积分最多可兑换 " + maxExchangeable + " 次");
            return result;
        }

        // 扣除积分
        pointsRecordService.reducePoints(student.getId(), needed, 3, student.getId(),
                "积分兑换抽奖 " + times + " 次（每次 " + ratio + " 积分）", null);

        // 重新获取最新学生数据，避免用旧的 totalPoints 覆盖刚才的扣分结果
        student = userService.getById(student.getId());
        int newLotteryCount = (student.getLotteryCount() != null ? student.getLotteryCount() : 0) + times;
        student.setLotteryCount(newLotteryCount);
        userService.updateUser(student);

        // 更新 session
        session.setAttribute("user", userService.getById(student.getId()));

        int newPoints = pointsRecordService.getCurrentBalance(student.getId());
        result.put("success", true);
        result.put("message", "兑换成功！消耗 " + needed + " 积分，获得 " + times + " 次抽奖机会");
        result.put("lotteryCount", newLotteryCount);
        result.put("remainingPoints", newPoints);
        return result;
    }

    /**
     * 按概率加权随机抽取奖品
     */
    private LotteryItem weightedRandom(java.util.List<LotteryItem> items) {
        double total = items.stream()
                .mapToDouble(i -> i.getProbability() != null ? i.getProbability().doubleValue() : 0)
                .sum();
        if (total <= 0) {
            return items.get((int)(Math.random() * items.size()));
        }
        double rand = Math.random() * total;
        double cumulative = 0;
        for (LotteryItem item : items) {
            cumulative += item.getProbability() != null ? item.getProbability().doubleValue() : 0;
            if (rand <= cumulative) return item;
        }
        return items.get(items.size() - 1);
    }
}
