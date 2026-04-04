package com.punch.dto;

import com.punch.entity.CheckinRecord;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class CheckinRecordDTO extends CheckinRecord {
    private String itemName; // 事项名称，用于显示
}
