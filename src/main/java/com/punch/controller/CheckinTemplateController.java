package com.punch.controller;

import com.punch.entity.CheckinTemplate;
import com.punch.entity.CheckinItem;
import com.punch.entity.User;
import com.punch.dto.CheckinItemDTO;
import com.punch.dto.CheckinTemplateDTO;
import com.punch.dto.TodayCheckinItemDTO;
import com.punch.entity.CheckinRecord;
import com.punch.service.CheckinTemplateService;
import com.punch.service.CheckinItemService;
import com.punch.service.CheckinRecordService;
import com.punch.service.TemplateStudentService;
import com.punch.service.DailyCheckinService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.List;

@Controller
@RequestMapping("/checkin")
public class CheckinTemplateController {
    @Autowired
    private CheckinTemplateService templateService;
    @Autowired
    private CheckinItemService itemService;
    @Autowired
    private CheckinRecordService recordService;
    @Autowired
    private TemplateStudentService templateStudentService;
    @Autowired
    private DailyCheckinService dailyCheckinService;

    // 获取模板列表（管理员全部，家长仅自己）
    @GetMapping("/template/list")
    @ResponseBody
    public List<CheckinTemplateDTO> listTemplates(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return null;
        
        // admin可查全部
        if ("admin".equals(user.getUsername())) {
            return templateService.getAllTemplatesWithStudentNames();
        }
        // 家长仅查自己创建的
        else if (user.getParentId() == null) {
            return templateService.getTemplatesWithStudentNames(user.getId());
        }
        // 学生不能查看模板列表
        else {
            return new java.util.ArrayList<>();
        }
    }

    // 新增模板
    @PostMapping("/template/add")
    @ResponseBody
    public String addTemplate(@RequestBody java.util.Map<String, Object> requestData, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "fail";
        if (user.getParentId() != null) return "no_permission";
        
        // 创建模板
        CheckinTemplate template = new CheckinTemplate();
        template.setTemplateName((String) requestData.get("templateName"));
        template.setDescription((String) requestData.get("description"));
        
        // 安全地转换status字段
        Object statusObj = requestData.get("status");
        if (statusObj instanceof String) {
            template.setStatus(Integer.parseInt((String) statusObj));
        } else if (statusObj instanceof Integer) {
            template.setStatus((Integer) statusObj);
        } else {
            template.setStatus(1); // 默认启用
        }

        // 转换lotteryReward字段
        Object lotteryRewardObj = requestData.get("lotteryReward");
        if (lotteryRewardObj instanceof String && !((String) lotteryRewardObj).isEmpty()) {
            template.setLotteryReward(Integer.parseInt((String) lotteryRewardObj));
        } else if (lotteryRewardObj instanceof Integer) {
            template.setLotteryReward((Integer) lotteryRewardObj);
        } else if (lotteryRewardObj instanceof Number) {
            template.setLotteryReward(((Number) lotteryRewardObj).intValue());
        } else {
            template.setLotteryReward(0);
        }

        // 家长只能添加自己模板
        if (user.getParentId() == null) {
            template.setParentId(user.getId());
        }
        template.setCreateBy(user.getId());
        template.setCreateTime(new Date());
        
        int res = templateService.createTemplate(template);
        if (res == -1) return "limit";
        
        // 分配学生
        List<Long> studentIds = convertToLongList(requestData.get("studentIds"));
        if (studentIds != null && !studentIds.isEmpty()) {
            templateStudentService.assignTemplateToStudents(template.getId(), studentIds, user.getId());
        }
        
        return "success";
    }

    // 获取模板分配的学生列表
    @GetMapping("/template/{templateId}/students")
    @ResponseBody
    public List<Long> getTemplateStudents(@PathVariable Long templateId, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return null;
        return templateStudentService.getStudentIdsByTemplateId(templateId);
    }

    // 编辑模板
    @PostMapping("/template/update")
    @ResponseBody
    public String updateTemplate(@RequestBody java.util.Map<String, Object> requestData, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "fail";
        
        // 更新模板基本信息
        CheckinTemplate template = new CheckinTemplate();
        template.setId(Long.valueOf(requestData.get("id").toString()));
        template.setTemplateName((String) requestData.get("templateName"));
        template.setDescription((String) requestData.get("description"));
        
        // 安全地转换status字段
        Object statusObj = requestData.get("status");
        if (statusObj instanceof String) {
            template.setStatus(Integer.parseInt((String) statusObj));
        } else if (statusObj instanceof Integer) {
            template.setStatus((Integer) statusObj);
        } else {
            template.setStatus(1);
        }

        // 转换lotteryReward字段
        Object lotteryRewardObj = requestData.get("lotteryReward");
        if (lotteryRewardObj instanceof String && !((String) lotteryRewardObj).isEmpty()) {
            template.setLotteryReward(Integer.parseInt((String) lotteryRewardObj));
        } else if (lotteryRewardObj instanceof Integer) {
            template.setLotteryReward((Integer) lotteryRewardObj);
        } else if (lotteryRewardObj instanceof Number) {
            template.setLotteryReward(((Number) lotteryRewardObj).intValue());
        } else {
            template.setLotteryReward(0);
        }

        template.setUpdateBy(user.getId());
        template.setUpdateTime(new Date());
        
        templateService.updateTemplate(template);
        
        // 更新学生分配关系
        List<Long> studentIds = convertToLongList(requestData.get("studentIds"));
        if (studentIds != null && !studentIds.isEmpty()) {
            // 先删除原有的分配关系
            templateStudentService.removeAllStudentsFromTemplate(template.getId());
            // 重新分配学生
            templateStudentService.assignTemplateToStudents(template.getId(), studentIds, user.getId());
        }
        
        return "success";
    }

    // 删除模板
    @PostMapping("/template/delete")
    @ResponseBody
    public String deleteTemplate(@RequestParam Long id) {
        templateService.deleteTemplate(id);
        return "success";
    }

    // 获取事项列表
    @GetMapping("/item/list")
    @ResponseBody
    public List<CheckinItemDTO> listItems(@RequestParam(required = false) Long templateId, 
                           @RequestParam(required = false) Boolean forStudent,
                           HttpSession session) {
        if (templateId != null) {
            // 返回指定模板的事项，使用DTO以保持数据格式统一
            return itemService.getByTemplateIdWithTemplate(templateId);
        } else {
            // 如果是学生用户或明确要求学生视图，过滤掉禁用的事项
            if (Boolean.TRUE.equals(forStudent)) {
                return itemService.getActiveItemsWithTemplate(); // 只获取状态不为2的事项
            } else {
                // 检查用户类型
                User user = (User) session.getAttribute("user");
                if (user != null && user.getParentId() != null) {
                    // 学生用户，过滤禁用事项
                    return itemService.getActiveItemsWithTemplate();
                } else if (user != null && "admin".equals(user.getUsername())) {
                    // 管理员用户，显示所有事项
                    return itemService.getAllItemsWithTemplate();
                } else if (user != null && user.getParentId() == null) {
                    // 家长用户，只显示自己创建的模板下的事项
                    return itemService.getItemsByParentId(user.getId());
                } else {
                    return new java.util.ArrayList<>();
                }
            }
        }
    }

    // 获取今日可打卡事项及其状态
    @GetMapping("/item/todayList")
    @ResponseBody
    public List<TodayCheckinItemDTO> getTodayCheckinItems(@RequestParam(required = false) Long studentId, 
                                                          HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return new java.util.ArrayList<>();
        
        // 确定目标学生ID
        Long targetStudentId;
        if (user.getParentId() != null) {
            // 学生只能查看自己的
            targetStudentId = user.getId();
        } else if ("admin".equals(user.getUsername())) {
            // 管理员可以指定学生，如果没指定则返回空
            targetStudentId = studentId;
        } else {
            // 家长可以指定学生（自己的孩子），如果没指定则返回空
            targetStudentId = studentId;
        }
        
        if (targetStudentId == null) {
            return new java.util.ArrayList<>();
        }
        
        // 从任务排期表获取今日打卡数据
        return dailyCheckinService.getTodayCheckinItemsForStudent(targetStudentId)
                .stream()
                .map(dailyItem -> {
                    TodayCheckinItemDTO dto = new TodayCheckinItemDTO();
                    dto.setId(dailyItem.getItemId()); // 使用事项ID，不是daily_checkin_items的ID
                    dto.setItemName(dailyItem.getItemName());
                    dto.setDescription(dailyItem.getItemDescription());
                    dto.setPoints(dailyItem.getItemPoints() != null ? dailyItem.getItemPoints() : dailyItem.getPoints());
                    dto.setSortOrder(dailyItem.getSortOrder());
                    dto.setCheckinStartTime(dailyItem.getCheckinStartTime());
                    dto.setCheckinEndTime(dailyItem.getCheckinEndTime());
                    dto.setTodayStatus(dailyItem.getStatus()); // 0-未打卡，1-已打卡，2-已过期
                    dto.setTemplateId(dailyItem.getTemplateId());
                    return dto;
                })
                .collect(java.util.stream.Collectors.toList());
    }

    // 新增事项
    @PostMapping("/item/add")
    @ResponseBody
    public String addItem(@RequestBody CheckinItem item, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "fail";
        item.setCreateTime(new Date());
        int res = itemService.createItem(item);
        if (res == -1) return "limit";
        return "success";
    }

    // 编辑事项
    @PostMapping("/item/update")
    @ResponseBody
    public String updateItem(@RequestBody CheckinItem item, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "fail";
        item.setUpdateTime(new Date());
        itemService.updateItem(item);
        return "success";
    }

    // 删除事项
    @PostMapping("/item/delete")
    @ResponseBody
    public String deleteItem(@RequestParam Long id) {
        itemService.deleteItem(id);
        return "success";
    }
    
    // 上移事项
    @PostMapping("/item/moveUp")
    @ResponseBody
    public String moveItemUp(@RequestParam Long id) {
        try {
            boolean success = itemService.moveItemUp(id);
            if (success) {
                return "success";
            } else {
                return "first"; // 已经是第一个
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }
    
    // 下移事项
    @PostMapping("/item/moveDown")
    @ResponseBody
    public String moveItemDown(@RequestParam Long id) {
        try {
            boolean success = itemService.moveItemDown(id);
            if (success) {
                return "success";
            } else {
                return "last"; // 已经是最后一个
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "fail";
        }
    }

    
    /**
     * 安全地将Object转换为List<Long>
     * 处理前端传来的数据可能是字符串数组或整数数组的情况
     */
    private List<Long> convertToLongList(Object obj) {
        if (obj == null) {
            return null;
        }
        
        if (obj instanceof List) {
            List<?> list = (List<?>) obj;
            List<Long> result = new java.util.ArrayList<>();
            for (Object item : list) {
                if (item instanceof String) {
                    try {
                        result.add(Long.parseLong((String) item));
                    } catch (NumberFormatException e) {
                        // 忽略无法转换的项
                    }
                } else if (item instanceof Integer) {
                    result.add(((Integer) item).longValue());
                } else if (item instanceof Long) {
                    result.add((Long) item);
                }
            }
            return result;
        }
        
        return null;
    }
}
