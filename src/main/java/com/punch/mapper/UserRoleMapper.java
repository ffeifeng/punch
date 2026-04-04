package com.punch.mapper;

import com.punch.entity.UserRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface UserRoleMapper {
    UserRole selectById(@Param("id") Long id);
    List<UserRole> selectByUserId(@Param("userId") Long userId);
    int insert(UserRole userRole);
    int deleteByUserId(@Param("userId") Long userId);
    int deleteById(@Param("id") Long id);
}
