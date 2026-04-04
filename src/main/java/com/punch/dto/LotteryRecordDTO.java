package com.punch.dto;

import lombok.Data;
import java.util.Date;

@Data
public class LotteryRecordDTO {
    private Long id;
    private Long studentId;
    private String studentName;
    private Long itemId;
    private String itemName;
    private Date lotteryTime;
    private Integer isRedeemed;
    private Date redeemedTime;
    private String redeemedByName;
}
