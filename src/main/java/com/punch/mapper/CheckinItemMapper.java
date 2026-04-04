package com.punch.mapper;

import com.punch.entity.CheckinItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface CheckinItemMapper {
    CheckinItem selectById(@Param("id") Long id);
    List<CheckinItem> selectByTemplateId(@Param("templateId") Long templateId);
    List<CheckinItem> selectAll();
    List<CheckinItem> selectActiveItems(); // 查询非禁用事项（status != 2）
    int insert(CheckinItem item);
    int update(CheckinItem item);
    int deleteById(@Param("id") Long id);
    int countByTemplateId(@Param("templateId") Long templateId);
}
