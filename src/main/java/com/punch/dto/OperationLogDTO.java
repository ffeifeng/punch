package com.punch.dto;

import com.punch.entity.OperationLog;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
public class OperationLogDTO extends OperationLog {
    private String userName; // 操作人姓名，用于显示
}
