package com.punch.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.util.Date;

@Data
public class LotteryItem {
    private Long id;
    private Long parentId;
    private String name;
    private BigDecimal probability;
    private Integer status;
    /**
     * 保底阈值：null=普通奖品；>0=保底奖品，连续未中达到该次数后自动赠送此奖品。
     * 每个保底奖品可独立设置不同阈值（如A奖品10次保底、B奖品20次保底）。
     */
    private Integer pityThreshold;
    /**
     * 抽中此奖品时自动赠送的小红花数量，0=不赠送。
     * 例：设置为 3，孩子抽中后立即获得 3 朵小红花。
     */
    private Integer flowerReward;
    private Date createTime;
    private Date updateTime;
}
