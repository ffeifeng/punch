package com.punch.mapper;

import com.punch.entity.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface UserMapper {
    User selectById(@Param("id") Long id);
    User selectByUsername(@Param("username") String username);
    User selectByAuthCode(@Param("authCode") String authCode);
    User selectByQrCode(@Param("qrCode") String qrCode);
    int insert(User user);
    int update(User user);
    int deleteById(@Param("id") Long id);
    List<User> selectAll();
    List<User> selectByCondition(@Param("username") String username, @Param("status") Integer status, @Param("startTime") String startTime, @Param("endTime") String endTime);
    List<User> selectByParentIdAndCondition(@Param("parentId") Long parentId, @Param("username") String username, @Param("status") Integer status, @Param("startTime") String startTime, @Param("endTime") String endTime);
    List<User> selectByParentId(@Param("parentId") Long parentId);
    List<User> selectParentUsers();
    List<User> selectStudentUsers();
}
