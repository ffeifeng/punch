package com.punch.dto;

import com.punch.entity.CheckinTemplate;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = true)
@Data
public class CheckinTemplateDTO extends CheckinTemplate {
    private String studentNames; // 分配的学生姓名，多个用逗号分隔
}
