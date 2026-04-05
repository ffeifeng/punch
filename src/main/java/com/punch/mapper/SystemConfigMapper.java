package com.punch.mapper;

import com.punch.entity.SystemConfig;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SystemConfigMapper {

    SystemConfig selectByKeyAndParent(@Param("configKey") String configKey, @Param("parentId") Long parentId);

    int insertOrUpdate(SystemConfig config);

    int update(SystemConfig config);
}
