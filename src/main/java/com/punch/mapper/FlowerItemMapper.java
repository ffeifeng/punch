package com.punch.mapper;

import com.punch.entity.FlowerItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface FlowerItemMapper {
    FlowerItem selectById(@Param("id") Long id);
    List<FlowerItem> selectByParentId(@Param("parentId") Long parentId);
    List<FlowerItem> selectEnabledByParentId(@Param("parentId") Long parentId);
    int insert(FlowerItem item);
    int update(FlowerItem item);
    int deleteById(@Param("id") Long id);
}
