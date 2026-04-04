package com.punch.controller;

import com.punch.util.CaptchaUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 验证码控制器
 */
@Controller
@RequestMapping("/captcha")
public class CaptchaController {
    
    /**
     * 生成验证码图片
     */
    @GetMapping("/image")
    public void generateCaptcha(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // 生成验证码
        CaptchaUtils.CaptchaResult captcha = CaptchaUtils.generateCaptcha();
        
        // 将验证码存储到session中
        HttpSession session = request.getSession();
        session.setAttribute("captcha", captcha.getCode().toLowerCase()); // 存储为小写，便于比较
        session.setAttribute("captcha_time", System.currentTimeMillis()); // 存储生成时间
        
        // 设置响应头
        response.setContentType("image/png");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);
        
        // 输出图片
        response.getOutputStream().write(captcha.getImageBytes());
        response.getOutputStream().flush();
    }
    
    /**
     * 验证验证码
     * @param inputCaptcha 用户输入的验证码
     * @param session HttpSession
     * @return 验证结果
     */
    public static boolean verifyCaptcha(String inputCaptcha, HttpSession session) {
        if (inputCaptcha == null || inputCaptcha.trim().isEmpty()) {
            return false;
        }
        
        String sessionCaptcha = (String) session.getAttribute("captcha");
        Long captchaTime = (Long) session.getAttribute("captcha_time");
        
        // 检查验证码是否存在
        if (sessionCaptcha == null || captchaTime == null) {
            return false;
        }
        
        // 检查验证码是否过期（5分钟有效期）
        long currentTime = System.currentTimeMillis();
        if (currentTime - captchaTime > 5 * 60 * 1000) {
            // 清除过期的验证码
            session.removeAttribute("captcha");
            session.removeAttribute("captcha_time");
            return false;
        }
        
        // 验证码比较（不区分大小写）
        boolean isValid = sessionCaptcha.equalsIgnoreCase(inputCaptcha.trim());
        
        // 验证后清除验证码（一次性使用）
        if (isValid) {
            session.removeAttribute("captcha");
            session.removeAttribute("captcha_time");
        }
        
        return isValid;
    }
}
