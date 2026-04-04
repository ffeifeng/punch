package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class OperationLog {
    private Long id;
    private Long userId;
    private String operation;
    private Long targetId;
    private String targetType;
    private String content;
    private String ip;
    private Date createTime;
}
