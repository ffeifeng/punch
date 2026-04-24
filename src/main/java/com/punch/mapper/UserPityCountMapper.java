package com.punch.mapper;

import com.punch.entity.UserPityCount;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserPityCountMapper {

    /** 查询某学生所有保底奖品的计数器 */
    List<UserPityCount> selectByStudentId(@Param("studentId") Long studentId);

    /** 设置某学生对某奖品的计数器（不存在则插入，存在则更新） */
    int upsert(@Param("studentId") Long studentId,
               @Param("itemId") Long itemId,
               @Param("count") int count);
}
