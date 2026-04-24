package com.punch.entity;

import lombok.Data;

/**
 * 用户各保底奖品的独立计数器
 * 记录某学生对某保底奖品连续未中的次数
 */
@Data
public class UserPityCount {
    private Long studentId;
    private Long itemId;
    private Integer count;
}
