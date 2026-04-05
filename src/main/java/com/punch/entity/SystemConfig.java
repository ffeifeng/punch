package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class SystemConfig {
    private Long id;
    private String configKey;
    private String configValue;
    private String configName;
    private String description;
    private Long parentId;
    private Date createTime;
    private Date updateTime;
}
