package com.punch.service;

import com.punch.entity.UserRole;
import java.util.List;

public interface UserRoleService {
    UserRole getById(Long id);
    List<UserRole> getByUserId(Long userId);
    int createUserRole(UserRole userRole);
    int deleteByUserId(Long userId);
    int deleteById(Long id);
}
