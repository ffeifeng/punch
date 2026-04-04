package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 初始化控制器
 * 用于系统初始化操作，如为现有学生生成二维码
 */
@Controller
@RequestMapping("/init")
public class InitController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 为所有学生生成二维码
     * 注意：这是一次性操作，生产环境中应该有适当的权限控制
     */
    @GetMapping("/generateQrCodes")
    @ResponseBody
    public Map<String, Object> generateQrCodes() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            List<User> students = userService.getStudentUsers();
            int successCount = 0;
            int skipCount = 0;
            
            for (User student : students) {
                if (student.getQrCode() == null || student.getQrCode().trim().isEmpty()) {
                    try {
                        String qrCode = userService.generateQrCodeForStudent(student.getId());
                        System.out.println("为学生 " + student.getRealName() + " 生成二维码: " + qrCode);
                        successCount++;
                    } catch (Exception e) {
                        System.err.println("为学生 " + student.getRealName() + " 生成二维码失败: " + e.getMessage());
                    }
                } else {
                    System.out.println("学生 " + student.getRealName() + " 已有二维码: " + student.getQrCode());
                    skipCount++;
                }
            }
            
            result.put("success", true);
            result.put("message", "二维码生成完成");
            result.put("totalStudents", students.size());
            result.put("successCount", successCount);
            result.put("skipCount", skipCount);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "生成二维码失败: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 查看所有学生的二维码信息
     */
    @GetMapping("/listQrCodes")
    @ResponseBody
    public Map<String, Object> listQrCodes() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            List<User> students = userService.getStudentUsers();
            result.put("success", true);
            result.put("students", students);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "查询失败: " + e.getMessage());
        }
        
        return result;
    }
}
