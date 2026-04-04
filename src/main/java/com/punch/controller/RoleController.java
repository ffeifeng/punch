package com.punch.controller;

import com.punch.entity.Role;
import com.punch.service.RoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@Controller
@RequestMapping("/role")
public class RoleController {
    @Autowired
    private RoleService roleService;

    @GetMapping("/list")
    @ResponseBody
    public List<Role> list() {
        return roleService.getAllRoles();
    }

    @PostMapping("/add")
    @ResponseBody
    public String add(@RequestBody Role role) {
        roleService.createRole(role);
        return "success";
    }

    @PostMapping("/update")
    @ResponseBody
    public String update(@RequestBody Role role) {
        roleService.updateRole(role);
        return "success";
    }

    @PostMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam Long id) {
        roleService.deleteRole(id);
        return "success";
    }
}
