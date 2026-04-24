package com.punch.entity;

import lombok.Data;
import java.util.Date;

/**
 * 小红花变更流水
 * type: 1=抽奖获得 2=兑换消耗 3=家长手动调整 4=兑换撤销退还
 */
@Data
public class FlowerRecord {
    private Long id;
    private Long studentId;
    /** 变化数量（正=增加，负=减少） */
    private Integer changeAmount;
    /** 变化后余额 */
    private Integer balance;
    /**
     * 1=抽奖获得  2=兑换消耗
     * 3=家长手动调整  4=兑换撤销退还
     */
    private Integer type;
    /** 来源记录ID（lottery_record_id 或 flower_redemption_id） */
    private Long sourceId;
    private String remark;
    private Long operatorId;
    private Date operateTime;
}
