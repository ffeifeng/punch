package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class PointsRecord {
    private Long id;
    private Long studentId;
    private Long recordId;
    private Integer points;
    private Integer type;
    private Integer balance;
    private Long operatorId;
    private Date operateTime;
    private String remark;
}
