package com.punch.entity;

import java.util.Date;

/**
 * 每日打卡事项实体
 */
public class DailyCheckinItem {
    
    private Long id;
    private Long studentId;
    private Long itemId;
    private Date checkinDate;
    private Integer status; // 0-未打卡，1-已打卡，2-已过期
    private Integer points;
    private Date checkinTime;
    private Date createTime;
    private Date updateTime;
    
    // 关联字段（用于查询显示）
    private String itemName;
    private String itemDescription;
    private Integer itemPoints;
    private Integer sortOrder;
    private Long templateId;
    private java.time.LocalTime checkinStartTime;
    private java.time.LocalTime checkinEndTime;
    private String studentName;
    
    public DailyCheckinItem() {}
    
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getStudentId() {
        return studentId;
    }
    
    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }
    
    public Long getItemId() {
        return itemId;
    }
    
    public void setItemId(Long itemId) {
        this.itemId = itemId;
    }
    
    public Date getCheckinDate() {
        return checkinDate;
    }
    
    public void setCheckinDate(Date checkinDate) {
        this.checkinDate = checkinDate;
    }
    
    public Integer getStatus() {
        return status;
    }
    
    public void setStatus(Integer status) {
        this.status = status;
    }
    
    public Integer getPoints() {
        return points;
    }
    
    public void setPoints(Integer points) {
        this.points = points;
    }
    
    public Date getCheckinTime() {
        return checkinTime;
    }
    
    public void setCheckinTime(Date checkinTime) {
        this.checkinTime = checkinTime;
    }
    
    public Date getCreateTime() {
        return createTime;
    }
    
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
    
    public Date getUpdateTime() {
        return updateTime;
    }
    
    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
    
    // 关联字段的getter和setter
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
    
    public Integer getItemPoints() {
        return itemPoints;
    }
    
    public void setItemPoints(Integer itemPoints) {
        this.itemPoints = itemPoints;
    }
    
    public Integer getSortOrder() {
        return sortOrder;
    }
    
    public void setSortOrder(Integer sortOrder) {
        this.sortOrder = sortOrder;
    }
    
    public Long getTemplateId() {
        return templateId;
    }
    
    public void setTemplateId(Long templateId) {
        this.templateId = templateId;
    }
    
    public java.time.LocalTime getCheckinStartTime() {
        return checkinStartTime;
    }
    
    public void setCheckinStartTime(java.time.LocalTime checkinStartTime) {
        this.checkinStartTime = checkinStartTime;
    }
    
    public java.time.LocalTime getCheckinEndTime() {
        return checkinEndTime;
    }
    
    public void setCheckinEndTime(java.time.LocalTime checkinEndTime) {
        this.checkinEndTime = checkinEndTime;
    }
    
    public String getStudentName() {
        return studentName;
    }
    
    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }
    
    // 便捷方法，兼容旧接口
    public String getDescription() {
        return itemDescription;
    }
}
