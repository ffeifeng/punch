package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class CheckinTemplate {
    private Long id;
    private String templateName;
    private String description;
    private Long parentId;
    private Integer status;
    private Integer lotteryReward; // 全部打卡完成后赠送的抽奖次数
    private Long createBy;
    private Date createTime;
    private Long updateBy;
    private Date updateTime;
}
