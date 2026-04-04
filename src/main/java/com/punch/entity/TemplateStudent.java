package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class TemplateStudent {
    private Long id;
    private Long templateId;
    private Long studentId;
    private Long createBy;
    private Date createTime;
}
