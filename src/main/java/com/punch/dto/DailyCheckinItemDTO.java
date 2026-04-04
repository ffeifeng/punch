package com.punch.dto;

import com.punch.entity.DailyCheckinItem;
import java.util.Date;

/**
 * 每日打卡事项DTO
 * 用于展示包含学生信息的每日打卡事项列表
 */
public class DailyCheckinItemDTO extends DailyCheckinItem {
    
    private String studentName;        // 学生姓名
    private String templateName;       // 模板名称
    private String itemName;           // 事项名称
    private String itemDescription;    // 事项描述
    private String itemCheckinStartTime;   // 事项打卡开始时间
    private String itemCheckinEndTime;     // 事项打卡结束时间
    
    public DailyCheckinItemDTO() {
        super();
    }
    
    /**
     * 从基础实体构造DTO
     */
    public DailyCheckinItemDTO(DailyCheckinItem item) {
        if (item != null) {
            this.setId(item.getId());
            this.setStudentId(item.getStudentId());
            this.setItemId(item.getItemId());
            this.setCheckinDate(item.getCheckinDate());
            this.setStatus(item.getStatus());
            this.setPoints(item.getPoints());
            this.setCheckinTime(item.getCheckinTime());
            this.setCreateTime(item.getCreateTime());
            this.setUpdateTime(item.getUpdateTime());
        }
    }
    
    public String getStudentName() {
        return studentName;
    }
    
    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }
    
    public String getTemplateName() {
        return templateName;
    }
    
    public void setTemplateName(String templateName) {
        this.templateName = templateName;
    }
    
    public String getItemName() {
        return itemName;
    }
    
    public void setItemName(String itemName) {
        this.itemName = itemName;
    }
    
    public String getItemDescription() {
        return itemDescription;
    }
    
    public void setItemDescription(String itemDescription) {
        this.itemDescription = itemDescription;
    }
    
    public String getItemCheckinStartTime() {
        return itemCheckinStartTime;
    }
    
    public void setItemCheckinStartTime(String itemCheckinStartTime) {
        this.itemCheckinStartTime = itemCheckinStartTime;
    }
    
    public String getItemCheckinEndTime() {
        return itemCheckinEndTime;
    }
    
    public void setItemCheckinEndTime(String itemCheckinEndTime) {
        this.itemCheckinEndTime = itemCheckinEndTime;
    }
    
    /**
     * 格式化状态文本
     */
    public String getStatusText() {
        if (this.getStatus() == null) return "未知";
        switch (this.getStatus()) {
            case 0: return "未打卡";
            case 1: return "已打卡";
            case 2: return "已过期";
            default: return "未知";
        }
    }
    
    /**
     * 获取打卡时间范围文本
     */
    public String getCheckinTimeRange() {
        if (itemCheckinStartTime == null && itemCheckinEndTime == null) {
            return "全天";
        }
        String start = itemCheckinStartTime != null ? itemCheckinStartTime : "00:00";
        String end = itemCheckinEndTime != null ? itemCheckinEndTime : "23:59";
        return start + " - " + end;
    }
}
