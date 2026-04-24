package com.punch.mapper;

import com.punch.entity.LotteryItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface LotteryItemMapper {
    LotteryItem selectById(@Param("id") Long id);
    List<LotteryItem> selectByParentId(@Param("parentId") Long parentId);
    List<LotteryItem> selectEnabledByParentId(@Param("parentId") Long parentId);
    /** 查询某家长下已启用的保底奖品列表（pity_threshold > 0） */
    List<LotteryItem> selectEnabledPityByParentId(@Param("parentId") Long parentId);
    int insert(LotteryItem item);
    int update(LotteryItem item);
    int deleteById(@Param("id") Long id);
}
