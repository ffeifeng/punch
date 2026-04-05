package com.punch.controller;


import com.punch.dto.CheckinRecordDTO;
import com.punch.entity.CheckinCompleteReward;
import com.punch.entity.CheckinTemplate;
import com.punch.entity.DailyCheckinItem;
import com.punch.entity.User;
import com.punch.mapper.CheckinCompleteRewardMapper;
import com.punch.mapper.CheckinTemplateMapper;
import com.punch.mapper.DailyCheckinItemMapper;
import com.punch.service.CheckinRecordService;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import java.text.SimpleDateFormat;
import java.util.*;

@Controller
@RequestMapping("/checkinRecord")
public class CheckinRecordController {
    @Autowired
    private CheckinRecordService recordService;
    @Autowired
    private DailyCheckinItemMapper dailyCheckinItemMapper;
    @Autowired
    private CheckinTemplateMapper checkinTemplateMapper;
    @Autowired
    private CheckinCompleteRewardMapper checkinCompleteRewardMapper;
    @Autowired
    private UserService userService;

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
    public Map<String, Object> doCheckin(@RequestParam Long itemId,
                                         @RequestParam(required = false) Long studentId,
                                         HttpSession session,
                                         HttpServletRequest request) {
        Map<String, Object> resp = new HashMap<>();
        User user = (User) session.getAttribute("user");
        if (user == null) { resp.put("result", "no_permission"); return resp; }

        Long targetStudentId;
        if (user.getParentId() != null) {
            targetStudentId = user.getId();
        } else {
            targetStudentId = (studentId != null) ? studentId : user.getId();
        }

        Date today = new Date();
        String clientIp = com.punch.util.IpUtils.getClientIpAddressWithLocalDetection(request);
        String checkinResult = recordService.doCheckin(targetStudentId, itemId, today, user.getId(), clientIp);
        resp.put("result", checkinResult);

        // 打卡成功后检查是否全部完成，判断是否赠送抽奖次数
        if ("success".equals(checkinResult)) {
            tryGrantLotteryReward(targetStudentId, today, session, resp);
        }
        return resp;
    }

    /**
     * 检查学生今日是否全部打卡完成，若是则赠送模板配置的抽奖次数（每日每模板只赠送一次）
     */
    private void tryGrantLotteryReward(Long studentId, Date today, HttpSession session, Map<String, Object> resp) {
        try {
            // 使用带详情的查询，确保能取到 templateId
            List<DailyCheckinItem> items = dailyCheckinItemMapper.selectByStudentAndDateWithDetails(studentId, today);
            if (items == null || items.isEmpty()) return;

            // 全部完成条件：没有 status==0（待打卡）的事项，且至少有一项已完成（status==1）
            boolean hasPending = items.stream().anyMatch(i -> Integer.valueOf(0).equals(i.getStatus()));
            boolean hasCompleted = items.stream().anyMatch(i -> Integer.valueOf(1).equals(i.getStatus()));
            if (hasPending || !hasCompleted) return;

            // 取模板ID（同一学生今日事项属于同一模板）
            Long templateId = items.stream()
                    .map(DailyCheckinItem::getTemplateId)
                    .filter(id -> id != null)
                    .findFirst().orElse(null);
            if (templateId == null) return;

            // 检查今日是否已经赠送过
            int alreadyRewarded = checkinCompleteRewardMapper.countByStudentTemplateDate(studentId, templateId, today);
            if (alreadyRewarded > 0) return;

            // 获取模板配置的奖励次数
            CheckinTemplate template = checkinTemplateMapper.selectById(templateId);
            if (template == null) return;
            int reward = template.getLotteryReward() != null ? template.getLotteryReward() : 0;
            if (reward <= 0) return;

            // 赠送抽奖次数
            User student = userService.getById(studentId);
            if (student == null) return;
            int newCount = (student.getLotteryCount() != null ? student.getLotteryCount() : 0) + reward;
            student.setLotteryCount(newCount);
            userService.updateUser(student);

            // 记录奖励，防止重复发放
            CheckinCompleteReward record = new CheckinCompleteReward();
            record.setStudentId(studentId);
            record.setTemplateId(templateId);
            record.setRewardDate(today);
            record.setLotteryCount(reward);
            checkinCompleteRewardMapper.insert(record);

            // 更新 session 中的用户信息
            session.setAttribute("user", userService.getById(studentId));

            resp.put("lotteryRewarded", true);
            resp.put("lotteryRewardCount", reward);
            resp.put("lotteryCount", newCount);
        } catch (Exception e) {
            // 奖励失败不影响打卡结果
        }
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
