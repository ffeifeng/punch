package com.punch.dto;

import lombok.Data;
import java.util.Date;
import java.time.LocalTime;

@Data
public class CheckinItemDTO {
    private Long id;
    private Long templateId;
    private String templateName; // 模板名称，用于前端显示
    private String itemName;
    private String description;
    private Integer points;
    private Integer sortOrder;
    private Integer status; // 状态：0-未打卡，1-已打卡，2-禁用
    private LocalTime checkinStartTime; // 打卡开始时间
    private LocalTime checkinEndTime;   // 打卡结束时间
    private Date createTime;
    private Date updateTime;
    private Integer todayStatus; // 今日打卡状态：0-未打卡，1-已打卡
}
