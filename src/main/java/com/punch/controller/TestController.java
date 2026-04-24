package com.punch.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * 测试控制器 - 用于调试重定向问题
 */
@Controller
public class TestController {
    
    @GetMapping("/test")
    @ResponseBody
    public String test(HttpServletRequest request, HttpSession session) {
        // 仅 admin 可访问，生产环境应删除此接口
        Object user = session.getAttribute("user");
        if (!(user instanceof com.punch.entity.User)
                || !"admin".equals(((com.punch.entity.User) user).getUsername())) {
            return "Access denied";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("URI: ").append(request.getRequestURI()).append("\n");
        sb.append("Session ID: ").append(session.getId()).append("\n");
        sb.append("User in session: ").append(user).append("\n");
        sb.append("Request Method: ").append(request.getMethod()).append("\n");
        return sb.toString();
    }
    
    @GetMapping("/test-login")
    @ResponseBody
    public String testLogin() {
        return "Test login page - no redirect";
    }
    
    @GetMapping("/test-jsp")
    public String testJsp() {
        return "login";  // 测试JSP视图解析
    }
}
