package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.UserService;
import com.punch.service.UserRoleService;
import com.punch.entity.UserRole;
import com.punch.controller.CaptchaController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.List;

@Controller
public class AuthController {
    @Autowired
    private UserService userService;
    @Autowired
    private UserRoleService userRoleService;

    @PostMapping("/login")
    public ModelAndView login(@RequestParam String username, 
                             @RequestParam String password, 
                             @RequestParam String captcha, 
                             HttpSession session,
                             HttpServletRequest request) {
        // 判断是否为Ajax请求
        String xRequestedWith = request.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(xRequestedWith);
        
        // 1. 验证验证码
        if (!CaptchaController.verifyCaptcha(captcha, session)) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("login");
                mv.addObject("errorMessage", "验证码错误或已过期，请重新输入");
                return mv;
            }
            ModelAndView mv = new ModelAndView("login");
            mv.addObject("error", "验证码错误或已过期，请重新输入");
            return mv;
        }
        
        // 2. 验证用户名密码
        User user = userService.getByUsername(username);
        if (user == null) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("login");
                mv.addObject("errorMessage", "用户名不存在");
                return mv;
            }
            ModelAndView mv = new ModelAndView("login");
            mv.addObject("error", "用户名不存在");
            return mv;
        }
        
        if (user.getStatus() == 0) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("login");
                mv.addObject("errorMessage", "账号已被禁用，请联系管理员");
                return mv;
            }
            ModelAndView mv = new ModelAndView("login");
            mv.addObject("error", "账号已被禁用，请联系管理员");
            return mv;
        }
        
        if (user.getPassword() == null || !user.getPassword().equals(password)) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("login");
                mv.addObject("errorMessage", "密码错误");
                return mv;
            }
            ModelAndView mv = new ModelAndView("login");
            mv.addObject("error", "密码错误");
            return mv;
        }
        
        // 3. 登录成功，写入session
        session.setAttribute("user", user);
        // 跳转到main页面
        return new ModelAndView("redirect:/main");
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    @PostMapping("/register")
    public ModelAndView register(@RequestParam String authCode,
                                 @RequestParam String username,
                                 @RequestParam String password,
                                 @RequestParam String realName,
                                 @RequestParam String phone,
                                 @RequestParam(required = false) String email,
                                 @RequestParam String captcha,
                                 HttpSession session,
                                 HttpServletRequest request) {
        // 判断是否为Ajax请求
        String xRequestedWith = request.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(xRequestedWith);
        
        // 1. 验证验证码
        if (!CaptchaController.verifyCaptcha(captcha, session)) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("register");
                mv.addObject("errorMessage", "验证码错误或已过期，请重新输入");
                return mv;
            }
            ModelAndView mv = new ModelAndView("register");
            mv.addObject("error", "验证码错误或已过期，请重新输入");
            return mv;
        }
        
        // 2. 校验authCode
        User parent = userService.getByAuthCode(authCode);
        if (parent == null) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("register");
                mv.addObject("errorMessage", "授权码不存在或无效");
                return mv;
            }
            ModelAndView mv = new ModelAndView("register");
            mv.addObject("error", "授权码不存在或无效");
            return mv;
        }
        
        if (parent.getStatus() != 2) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("register");
                mv.addObject("errorMessage", "授权码已被注册使用");
                return mv;
            }
            ModelAndView mv = new ModelAndView("register");
            mv.addObject("error", "授权码已被注册使用");
            return mv;
        }
        
        // 3. 检查用户名唯一
        if (userService.getByUsername(username) != null) {
            if (isAjax) {
                ModelAndView mv = new ModelAndView("register");
                mv.addObject("errorMessage", "用户名已存在，请换一个");
                return mv;
            }
            ModelAndView mv = new ModelAndView("register");
            mv.addObject("error", "用户名已存在，请换一个");
            return mv;
        }
        
        // 4. 更新家长信息
        parent.setUsername(username);
        parent.setPassword(password);
        parent.setRealName(realName);
        parent.setPhone(phone);
        parent.setEmail(email);
        parent.setStatus(1);
        parent.setRegisterTime(new Date());
        userService.updateUser(parent);
        
        // 5. 跳转登录
        ModelAndView mv = new ModelAndView("login");
        mv.addObject("msg", "注册成功，请登录");
        return mv;
    }
}
