package com.punch.service;

import com.punch.entity.Role;
import java.util.List;

public interface RoleService {
    Role getById(Long id);
    Role getByCode(String roleCode);
    int createRole(Role role);
    int updateRole(Role role);
    int deleteRole(Long id);
    List<Role> getAllRoles();
}
