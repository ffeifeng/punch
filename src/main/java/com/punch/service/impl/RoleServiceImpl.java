package com.punch.service.impl;

import com.punch.entity.Role;
import com.punch.mapper.RoleMapper;
import com.punch.service.RoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class RoleServiceImpl implements RoleService {
    @Autowired
    private RoleMapper roleMapper;

    @Override
    public Role getById(Long id) {
        return roleMapper.selectById(id);
    }

    @Override
    public Role getByCode(String roleCode) {
        return roleMapper.selectByCode(roleCode);
    }

    @Override
    public int createRole(Role role) {
        return roleMapper.insert(role);
    }

    @Override
    public int updateRole(Role role) {
        return roleMapper.update(role);
    }

    @Override
    public int deleteRole(Long id) {
        return roleMapper.deleteById(id);
    }

    @Override
    public List<Role> getAllRoles() {
        return roleMapper.selectAll();
    }
}
