package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class LotteryRecord {
    private Long id;
    private Long studentId;
    private Long itemId;
    private String itemName;
    private Date lotteryTime;
    private Integer isRedeemed;
    private Date redeemedTime;
    private Long redeemedBy;
}
