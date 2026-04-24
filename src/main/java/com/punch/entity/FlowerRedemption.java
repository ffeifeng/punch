package com.punch.entity;

import lombok.Data;
import java.util.Date;

/**
 * 小红花兑换申请记录
 * 孩子申请时立即扣花并创建 status=0 记录；家长审批后 status=1；家长撤销后退花并 status=2
 */
@Data
public class FlowerRedemption {
    private Long id;
    private Long studentId;
    private Long itemId;
    /** 项目名称快照，防止后续修改影响历史显示 */
    private String itemName;
    /** 本次消耗小红花数量 */
    private Integer flowerCost;
    /** 本次兑换数量（>1 = 批量兑换） */
    private Integer qty;
    /** 获得时长（分钟），非时间类为 null */
    private Integer timeMinutes;
    /**
     * 0=待审批  1=已审批  2=已撤销
     */
    private Integer status;
    /** 兑换日期（用于每日限额统计） */
    private java.sql.Date redeemDate;
    /** 孩子申请时间 */
    private Date redeemTime;
    /** 家长审批时间 */
    private Date confirmTime;
    /** 审批人ID */
    private Long confirmBy;
    private String remark;
    private Date createTime;
}
