package com.punch.dto;

import com.punch.entity.PointsRecord;
import lombok.Data;

/**
 * 积分记录DTO，包含学生姓名信息
 */
@Data
public class PointsRecordDTO extends PointsRecord {
    
    /**
     * 学生姓名（操作人）
     */
    private String studentName;
    
    /**
     * 操作员姓名
     */
    private String operatorName;
}
