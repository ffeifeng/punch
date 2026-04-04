package com.punch.entity;

import lombok.Data;
import java.util.Date;

@Data
public class User {
    private Long id;
    private String username;
    private String password;
    private String realName;
    private String phone;
    private String email;
    private Integer status;
    private String authCode;
    private Date registerTime;
    private Date lastLoginTime;
    private Long parentId;
    private Integer totalPoints;
    private String qrCode;  // 学生二维码标识
    private Integer lotteryCount;  // 剩余抽奖次数
    private Long createBy;
    private Date createTime;
    private Long updateBy;
    private Date updateTime;
}
