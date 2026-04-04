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
    private Date createTime;
    private Date updateTime;
}
