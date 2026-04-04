package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class CheckinRecord {
    private Long id;
    private Long studentId;
    private Long itemId;
    private Date checkinDate;
    private Integer status;
    private Date checkinTime;
    private Date cancelTime;
    private Long createBy;
    private Date createTime;
    private Long updateBy;
    private Date updateTime;
    private String remark;
}
