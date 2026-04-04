package com.punch.service;

import com.punch.entity.PointsRecord;
import com.punch.dto.PointsRecordDTO;
import java.util.List;

public interface PointsRecordService {
    PointsRecord getById(Long id);
    List<PointsRecord> getByStudentId(Long studentId);
    List<PointsRecord> getByCondition(Long studentId, Integer type);
    List<PointsRecord> getByCondition(Long studentId, Integer type, String date);
    List<PointsRecord> getByParentId(Long parentId, Long studentId, Integer type);
    List<PointsRecord> getByParentId(Long parentId, Long studentId, Integer type, String date);
    int createRecord(PointsRecord record);
    int updateRecord(PointsRecord record);
    int deleteRecord(Long id);
    int addPoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId);
    int reducePoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId);
    int getCurrentBalance(Long studentId);
    
    // 新增：返回包含学生姓名的DTO方法
    List<PointsRecordDTO> getByConditionWithNames(Long studentId, Integer type);
    List<PointsRecordDTO> getByConditionWithNames(Long studentId, Integer type, String date);
    List<PointsRecordDTO> getByParentIdWithNames(Long parentId, Long studentId, Integer type);
    List<PointsRecordDTO> getByParentIdWithNames(Long parentId, Long studentId, Integer type, String date);
}
