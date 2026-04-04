package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.UserService;
import com.punch.service.CheckinItemService;
import com.punch.service.PointsRecordService;
import com.punch.util.QrCodeUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * 移动端控制器
 */
@Controller
@RequestMapping("/mobile")
public class MobileController {
    
    @Autowired
    private UserService userService;
    
    @Autowired
    private CheckinItemService checkinItemService;
    
    @Autowired
    private PointsRecordService pointsRecordService;
    
    /**
     * 移动端登录页面
     */
    @GetMapping("/login")
    public String loginPage(@RequestParam(required = false) String qr, Model model) {
        model.addAttribute("qrCode", qr);
        return "mobile/login";
    }
    
    /**
     * 二维码预览页面
     */
    @GetMapping("/qrcode")
    public String qrcodePage(@RequestParam(required = false) String qr, Model model) {
        model.addAttribute("qrCode", qr);
        return "mobile/qrcode";
    }
    
    /**
     * 移动端登录接口（仅限学生）
     */
    @PostMapping("/login")
    @ResponseBody
    public Map<String, Object> login(@RequestParam String password,
                                   @RequestParam(required = false) String qrCode,
                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User user = null;
            
            // 如果有二维码，通过二维码找到对应的学生
            if (qrCode != null && !qrCode.trim().isEmpty()) {
                user = userService.getByQrCode(qrCode);
                if (user == null) {
                    result.put("success", false);
                    result.put("message", "无效的二维码");
                    return result;
                }
                
                // 验证密码
                if (!password.equals(user.getPassword())) {
                    result.put("success", false);
                    result.put("message", "密码错误");
                    return result;
                }
            } else {
                result.put("success", false);
                result.put("message", "缺少二维码参数");
                return result;
            }
            
            // 检查是否为学生用户
            if (user.getParentId() == null) {
                result.put("success", false);
                result.put("message", "此登录方式仅限学生使用");
                return result;
            }
            
            // 检查用户状态
            if (user.getStatus() != 1) {
                result.put("success", false);
                result.put("message", "账号已被禁用，请联系管理员");
                return result;
            }
            
            // 登录成功，保存到session（使用统一的key）
            session.setAttribute("user", user);
            
            result.put("success", true);
            result.put("message", "登录成功");
            result.put("studentId", user.getId());
            result.put("studentName", user.getRealName());
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "登录失败：" + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 移动端打卡页面
     */
    @GetMapping("/checkin")
    public String checkinPage(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/mobile/login";
        }
        
        // 获取学生当前总积分
        int totalPoints = pointsRecordService.getCurrentBalance(user.getId());
        
        model.addAttribute("student", user);
        model.addAttribute("totalPoints", totalPoints);
        
        return "mobile/checkin";
    }
    
    /**
     * 移动端退出登录
     */
    @PostMapping("/logout")
    @ResponseBody
    public Map<String, Object> logout(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        session.removeAttribute("user");
        result.put("success", true);
        result.put("message", "退出成功");
        return result;
    }
    
    /**
     * 获取当前登录的移动端用户信息
     */
    @GetMapping("/currentUser")
    @ResponseBody
    public User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }
}
