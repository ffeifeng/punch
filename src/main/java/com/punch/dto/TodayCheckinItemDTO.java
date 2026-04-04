package com.punch.dto;

import com.punch.entity.CheckinItem;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class TodayCheckinItemDTO extends CheckinItem {
    private String templateName; // 模板名称，用于显示
    private Integer todayStatus; // 今日打卡状态：0-未打卡，1-已打卡
}
