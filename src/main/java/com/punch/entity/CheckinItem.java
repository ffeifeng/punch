package com.punch.entity;

import lombok.Data;
import java.util.Date;
import java.time.LocalTime;

@Data
public class CheckinItem {
    private Long id;
    private Long templateId;
    private String itemName;
    private String description;
    private Integer points;
    private Integer sortOrder;
    private Integer status; // 状态：0-未打卡，1-已打卡，2-禁用
    private LocalTime checkinStartTime; // 打卡开始时间
    private LocalTime checkinEndTime;   // 打卡结束时间
    private Date createTime;
    private Date updateTime;
}
