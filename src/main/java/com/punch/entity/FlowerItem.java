package com.punch.entity;

import lombok.Data;
import java.util.Date;

/**
 * 小红花兑换项目配置（家长端配置，每个项目可独立设置花费/时长/每日上限）
 */
@Data
public class FlowerItem {
    private Long id;
    private Long parentId;
    /** 项目名称，如：看电视、玩游戏、零食 */
    private String name;
    private String description;
    /** 每次兑换消耗小红花数量 */
    private Integer flowerCost;
    /** 每次兑换对应时长（分钟），null=非时间类奖励 */
    private Integer timeMinutes;
    /** 每日最多兑换次数，null=不限制 */
    private Integer dailyLimit;
    /** 1=启用 0=禁用 */
    private Integer status;
    /** 展示排序，越小越靠前 */
    private Integer sortOrder;
    private Date createTime;
    private Date updateTime;
}
