package com.punch.controller;

import com.punch.entity.User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import javax.servlet.http.HttpSession;

@Controller
public class HomeController {
    @GetMapping({"/", "/index"})
    public String index(HttpSession session) {
        // 检查用户是否已登录
        Object user = session.getAttribute("user");
        if (user != null) {
            return "redirect:/main";
        } else {
            return "redirect:/login";
        }
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/register")
    public String register() {
        return "register";
    }

    @GetMapping("/main")
    public String main() {
        return "main";
    }
    
    @GetMapping("/checkin_record")
    public String checkinRecord() {
        return "checkin_record";
    }
    
    @GetMapping("/checkin_manage")
    public String checkinManage() {
        return "checkin_manage";
    }
    
    @GetMapping("/user_manage")
    public String userManage() {
        return "user_manage";
    }
    
    @GetMapping("/role_manage")
    public String roleManage(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getUsername())) {
            return "redirect:/main"; // 非admin用户重定向到主页
        }
        return "role_manage";
    }
    
    @GetMapping("/points_manage")
    public String pointsManage() {
        return "points_manage";
    }
    
    @GetMapping("/operation_log")
    public String operationLog(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getUsername())) {
            return "redirect:/main"; // 非admin用户重定向到主页
        }
        return "operation_log";
    }
}
