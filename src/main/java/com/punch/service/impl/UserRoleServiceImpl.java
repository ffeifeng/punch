package com.punch.service.impl;

import com.punch.entity.UserRole;
import com.punch.mapper.UserRoleMapper;
import com.punch.service.UserRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserRoleServiceImpl implements UserRoleService {
    @Autowired
    private UserRoleMapper userRoleMapper;

    @Override
    public UserRole getById(Long id) {
        return userRoleMapper.selectById(id);
    }

    @Override
    public List<UserRole> getByUserId(Long userId) {
        return userRoleMapper.selectByUserId(userId);
    }

    @Override
    public int createUserRole(UserRole userRole) {
        return userRoleMapper.insert(userRole);
    }

    @Override
    public int deleteByUserId(Long userId) {
        return userRoleMapper.deleteByUserId(userId);
    }

    @Override
    public int deleteById(Long id) {
        return userRoleMapper.deleteById(id);
    }
}
