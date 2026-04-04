package com.punch.mapper;

import com.punch.entity.CheckinTemplate;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CheckinTemplateMapper {
    CheckinTemplate selectById(@Param("id") Long id);
    List<CheckinTemplate> selectByParentId(@Param("parentId") Long parentId);
    int insert(CheckinTemplate template);
    int update(CheckinTemplate template);
    int deleteById(@Param("id") Long id);
    List<CheckinTemplate> selectAll();
}
