package com.punch.mapper;

import com.punch.entity.FlowerRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface FlowerRecordMapper {
    int insert(FlowerRecord record);
    List<FlowerRecord> selectByStudentId(@Param("studentId") Long studentId);
    /** 查询最新一条记录（余额用） */
    FlowerRecord selectLatestByStudentId(@Param("studentId") Long studentId);
    /** 回填 source_id */
    int updateSourceId(@Param("id") Long id, @Param("sourceId") Long sourceId);
}
