package com.punch.mapper;

import com.punch.entity.PointsRecord;
import com.punch.dto.PointsRecordDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface PointsRecordMapper {
    PointsRecord selectById(@Param("id") Long id);
    List<PointsRecord> selectByStudentId(@Param("studentId") Long studentId);
    int insert(PointsRecord record);
    int update(PointsRecord record);
    int deleteById(@Param("id") Long id);
    List<PointsRecord> selectByCondition(@Param("studentId") Long studentId, @Param("type") Integer type);
    List<PointsRecord> selectByConditionWithDate(@Param("studentId") Long studentId, @Param("type") Integer type, @Param("date") String date);
    List<PointsRecord> selectByParentId(@Param("parentId") Long parentId, @Param("studentId") Long studentId, @Param("type") Integer type);
    List<PointsRecord> selectByParentIdWithDate(@Param("parentId") Long parentId, @Param("studentId") Long studentId, @Param("type") Integer type, @Param("date") String date);
    
    // 新增：返回包含学生姓名的DTO方法
    List<PointsRecordDTO> selectByConditionWithNames(@Param("studentId") Long studentId, @Param("type") Integer type);
    List<PointsRecordDTO> selectByConditionWithNamesAndDate(@Param("studentId") Long studentId, @Param("type") Integer type, @Param("date") String date);
    List<PointsRecordDTO> selectByParentIdWithNames(@Param("parentId") Long parentId, @Param("studentId") Long studentId, @Param("type") Integer type);
    List<PointsRecordDTO> selectByParentIdWithNamesAndDate(@Param("parentId") Long parentId, @Param("studentId") Long studentId, @Param("type") Integer type, @Param("date") String date);
}
