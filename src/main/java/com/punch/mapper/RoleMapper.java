package com.punch.mapper;

import com.punch.entity.Role;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface RoleMapper {
    Role selectById(@Param("id") Long id);
    Role selectByCode(@Param("roleCode") String roleCode);
    int insert(Role role);
    int update(Role role);
    int deleteById(@Param("id") Long id);
    List<Role> selectAll();
}
