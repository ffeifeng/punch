package com.punch.mapper;

import com.punch.entity.CheckinRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.Date;
import java.util.List;

@Mapper
public interface CheckinRecordMapper {
    CheckinRecord selectById(@Param("id") Long id);
    List<CheckinRecord> selectByStudentId(@Param("studentId") Long studentId);
    List<CheckinRecord> selectByCondition(@Param("studentId") Long studentId, @Param("itemId") Long itemId, @Param("date") Date date, @Param("status") Integer status);
    List<CheckinRecord> selectByParentId(@Param("parentId") Long parentId, @Param("itemId") Long itemId, @Param("date") Date date, @Param("status") Integer status);
    int insert(CheckinRecord record);
    int update(CheckinRecord record);
    int deleteById(@Param("id") Long id);
}
