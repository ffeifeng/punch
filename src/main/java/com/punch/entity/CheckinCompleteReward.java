package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class CheckinCompleteReward {
    private Long id;
    private Long studentId;
    private Long templateId;
    private Date rewardDate;
    private Integer lotteryCount;
    private Date createTime;
}
