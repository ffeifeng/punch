package com.punch.controller;

import com.punch.entity.User;
import com.punch.service.UserService;
import com.punch.service.OperationLogService;
import com.punch.entity.OperationLog;
import com.punch.util.IpUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

@Controller
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private OperationLogService operationLogService;

    @GetMapping("/list")
    @ResponseBody
    public List<User> list(@RequestParam(required = false) String username,
                           @RequestParam(required = false) Integer status,
                           @RequestParam(required = false) String startTime,
                           @RequestParam(required = false) String endTime,
                           HttpSession session) {
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) return new java.util.ArrayList<>();
        
        // admin可以查看所有用户
        if ("admin".equals(currentUser.getUsername())) {
            return userService.getUsersByCondition(username, status, startTime, endTime);
        }
        // 家长只能查看自己的孩子
        else if (currentUser.getParentId() == null) {
            return userService.getUsersByParentId(currentUser.getId(), username, status, startTime, endTime);
        }
        // 学生不能查看用户列表
        else {
            return new java.util.ArrayList<>();
        }
    }

    @GetMapping("/currentUser")
    @ResponseBody
    public User currentUser(HttpSession session) {
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return null;
        }
        
        // 从数据库获取最新的用户信息，确保积分等信息是最新的
        User latestUser = userService.getById(sessionUser.getId());
        if (latestUser != null) {
            // 更新session中的用户信息
            session.setAttribute("user", latestUser);
            return latestUser;
        }
        
        return sessionUser;
    }

    @GetMapping("/parentList")
    @ResponseBody
    public List<User> parentList(HttpSession session) {
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return new ArrayList<>();
        }
        
        // 只有管理员可以查看家长列表
        if ("admin".equals(sessionUser.getUsername())) {
            return userService.getParentUsers();
        } else {
            // 非管理员用户不能查看家长列表
            return new ArrayList<>();
        }
    }

    @GetMapping("/studentList")
    @ResponseBody
    public List<User> studentList(HttpSession session) {
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return new ArrayList<>();
        }
        
        // 根据用户角色返回相应的学生列表
        if ("admin".equals(sessionUser.getUsername())) {
            // 管理员可以看到所有学生
            return userService.getStudentUsers();
        } else if (sessionUser.getParentId() == null) {
            // 家长只能看到自己的孩子
            return userService.getStudentsByParentId(sessionUser.getId());
        } else {
            // 学生用户不能查看学生列表
            return new ArrayList<>();
        }
    }

    @GetMapping("/getStudentList")
    @ResponseBody
    public List<User> getStudentList(HttpSession session) {
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            return new ArrayList<>();
        }
        
        // 根据用户角色返回相应的学生列表
        if ("admin".equals(sessionUser.getUsername())) {
            // 管理员可以看到所有学生
            return userService.getStudentUsers();
        } else if (sessionUser.getParentId() == null) {
            // 家长只能看到自己的孩子
            return userService.getStudentsByParentId(sessionUser.getId());
        } else {
            // 学生用户不能操作积分
            return new ArrayList<>();
        }
    }

    @PostMapping("/add")
    @ResponseBody
    public String add(@RequestBody Map<String, Object> requestData, HttpSession session, HttpServletRequest request) {
        String userType = (String) requestData.get("userType");
        
        if ("parent".equals(userType)) {
            // 家长用户：只创建注册码记录，不创建完整用户
            String authCode = (String) requestData.get("authCode");
            if (authCode == null || authCode.trim().isEmpty()) {
                return "注册码不能为空";
            }
            
            // 检查注册码是否已存在
            User existingUser = userService.getByAuthCode(authCode);
            if (existingUser != null) {
                return "注册码已存在";
            }
            
            // 创建只包含注册码的临时记录
            User parentUser = new User();
            parentUser.setAuthCode(authCode);
            parentUser.setStatus(2); // 状态2表示待注册
            parentUser.setCreateTime(new Date());
            // 设置临时用户名，避免数据库约束
            parentUser.setUsername("TEMP_" + authCode);
            parentUser.setRealName("待注册家长");
            parentUser.setPassword("TEMP_PASSWORD");
            
            userService.createUser(parentUser);
            
            // 日志记录
            User opUser = (User) session.getAttribute("user");
            OperationLog log = new OperationLog();
            log.setUserId(opUser != null ? opUser.getId() : null);
            log.setOperation("生成家长注册码");
            log.setTargetId(parentUser.getId());
            log.setTargetType("User");
            log.setContent("注册码:" + authCode);
            log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
            log.setCreateTime(new Date());
            operationLogService.insert(log);
            
            return "success";
        } else {
            // 学生用户：创建完整用户记录
            User user = new User();
            user.setUsername((String) requestData.get("username"));
            user.setRealName((String) requestData.get("realName"));
            user.setPassword((String) requestData.get("password"));
            user.setPhone((String) requestData.get("phone"));
            user.setEmail((String) requestData.get("email"));
            
            Object parentIdObj = requestData.get("parentId");
            if (parentIdObj != null) {
                user.setParentId(Long.valueOf(parentIdObj.toString()));
            } else {
                // 如果没有提供parentId，说明是家长用户添加学生，自动设置为当前用户ID
                User currentUser = (User) session.getAttribute("user");
                if (currentUser != null && currentUser.getParentId() == null && !"admin".equals(currentUser.getUsername())) {
                    user.setParentId(currentUser.getId());
                }
            }
            
            user.setCreateTime(new Date());
            user.setStatus(1);
            userService.createUser(user);
            
            // 日志记录
            User opUser = (User) session.getAttribute("user");
            OperationLog log = new OperationLog();
            log.setUserId(opUser != null ? opUser.getId() : null);
            log.setOperation("新增学生用户");
            log.setTargetId(user.getId());
            log.setTargetType("User");
            log.setContent("用户名:" + user.getUsername());
            log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
            log.setCreateTime(new Date());
            operationLogService.insert(log);
            
            return "success";
        }
    }

    @PostMapping("/update")
    @ResponseBody
    public String update(@RequestBody User user, HttpSession session, HttpServletRequest request) {
        // 获取原用户信息，确保不会覆盖重要字段
        User existingUser = userService.getById(user.getId());
        if (existingUser == null) {
            return "用户不存在";
        }
        
        // 保留原有的重要字段，只更新允许修改的字段
        if (user.getStatus() == null) {
            user.setStatus(existingUser.getStatus());
        }
        if (user.getParentId() == null) {
            user.setParentId(existingUser.getParentId());
        }
        if (user.getTotalPoints() == null) {
            user.setTotalPoints(existingUser.getTotalPoints());
        }
        if (user.getCreateTime() == null) {
            user.setCreateTime(existingUser.getCreateTime());
        }
        if (user.getCreateBy() == null) {
            user.setCreateBy(existingUser.getCreateBy());
        }
        if (user.getRegisterTime() == null) {
            user.setRegisterTime(existingUser.getRegisterTime());
        }
        
        user.setUpdateTime(new Date());
        userService.updateUser(user);
        // 日志记录
        User opUser = (User) session.getAttribute("user");
        OperationLog log = new OperationLog();
        log.setUserId(opUser != null ? opUser.getId() : null);
        log.setOperation("修改用户");
        log.setTargetId(user.getId());
        log.setTargetType("User");
        log.setContent("用户名:" + user.getUsername());
        log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        return "success";
    }

    @PostMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam Long id, HttpSession session, HttpServletRequest request) {
        userService.deleteUser(id);
        // 日志记录
        User opUser = (User) session.getAttribute("user");
        OperationLog log = new OperationLog();
        log.setUserId(opUser != null ? opUser.getId() : null);
        log.setOperation("删除用户");
        log.setTargetId(id);
        log.setTargetType("User");
        log.setContent("用户ID:" + id);
        log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        return "success";
    }

    @PostMapping("/resetPassword")
    @ResponseBody
    public String resetPassword(@RequestParam Long id, @RequestParam String newPassword, HttpSession session, HttpServletRequest request) {
        User user = userService.getById(id);
        if (user != null) {
            user.setPassword(newPassword);
            userService.updateUser(user);
            // 日志记录
            User opUser = (User) session.getAttribute("user");
            OperationLog log = new OperationLog();
            log.setUserId(opUser != null ? opUser.getId() : null);
            log.setOperation("重置密码");
            log.setTargetId(id);
            log.setTargetType("User");
            log.setContent("用户ID:" + id);
            log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
            log.setCreateTime(new Date());
            operationLogService.insert(log);
            return "success";
        }
        return "fail";
    }

    @PostMapping("/changeStatus")
    @ResponseBody
    public String changeStatus(@RequestParam Long id, @RequestParam Integer status, HttpSession session, HttpServletRequest request) {
        User user = userService.getById(id);
        if (user != null) {
            user.setStatus(status);
            userService.updateUser(user);
            // 日志记录
            User opUser = (User) session.getAttribute("user");
            OperationLog log = new OperationLog();
            log.setUserId(opUser != null ? opUser.getId() : null);
            log.setOperation(status == 1 ? "启用用户" : "禁用用户");
            log.setTargetId(id);
            log.setTargetType("User");
            log.setContent("用户ID:" + id);
            log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
            log.setCreateTime(new Date());
            operationLogService.insert(log);
            return "success";
        }
        return "fail";
    }
    
    /**
     * 为学生生成二维码
     */
    @PostMapping("/generateQrCode")
    @ResponseBody
    public Map<String, Object> generateQrCode(@RequestParam Long studentId, HttpSession session, HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User user = (User) session.getAttribute("user");
            if (user == null) {
                result.put("success", false);
                result.put("message", "请先登录");
                return result;
            }
            
            // 检查权限：只有管理员和家长可以为学生生成二维码
            User student = userService.getById(studentId);
            if (student == null || student.getParentId() == null) {
                result.put("success", false);
                result.put("message", "学生不存在");
                return result;
            }
            
            // 权限检查
            if (!"admin".equals(user.getUsername()) && !studentId.equals(user.getId()) && 
                (student.getParentId() == null || !student.getParentId().equals(user.getId()))) {
                result.put("success", false);
                result.put("message", "没有权限为此学生生成二维码");
                return result;
            }
            
            String qrCode = userService.generateQrCodeForStudent(studentId);
            
            // 生成二维码URL
            String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
            String qrUrl = com.punch.util.QrCodeUtils.generateQrCodeUrl(qrCode, baseUrl);
            String qrPreviewUrl = com.punch.util.QrCodeUtils.generateQrCodePreviewUrl(qrCode, baseUrl);
            
            result.put("success", true);
            result.put("qrCode", qrCode);
            result.put("qrUrl", qrUrl);
            result.put("qrPreviewUrl", qrPreviewUrl);
            result.put("message", "二维码生成成功");
            
            // 日志记录
            OperationLog log = new OperationLog();
            log.setUserId(user.getId());
            log.setOperation("生成学生二维码");
            log.setTargetId(studentId);
            log.setTargetType("User");
            log.setContent("为学生 " + student.getRealName() + " 生成二维码: " + qrCode);
            log.setIp(IpUtils.getClientIpAddressWithLocalDetection(request));
            log.setCreateTime(new Date());
            operationLogService.insert(log);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "生成二维码失败: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 获取学生的二维码信息
     */
    @GetMapping("/getQrCode")
    @ResponseBody
    public Map<String, Object> getQrCode(@RequestParam Long studentId, HttpSession session, HttpServletRequest request) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User user = (User) session.getAttribute("user");
            if (user == null) {
                result.put("success", false);
                result.put("message", "请先登录");
                return result;
            }
            
            User student = userService.getById(studentId);
            if (student == null || student.getParentId() == null) {
                result.put("success", false);
                result.put("message", "学生不存在");
                return result;
            }
            
            // 权限检查
            if (!"admin".equals(user.getUsername()) && !studentId.equals(user.getId()) && 
                (student.getParentId() == null || !student.getParentId().equals(user.getId()))) {
                result.put("success", false);
                result.put("message", "没有权限查看此学生的二维码");
                return result;
            }
            
            if (student.getQrCode() != null && !student.getQrCode().trim().isEmpty()) {
                String baseUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort();
                String qrUrl = com.punch.util.QrCodeUtils.generateQrCodeUrl(student.getQrCode(), baseUrl);
                String qrPreviewUrl = com.punch.util.QrCodeUtils.generateQrCodePreviewUrl(student.getQrCode(), baseUrl);
                
                result.put("success", true);
                result.put("qrCode", student.getQrCode());
                result.put("qrUrl", qrUrl);
                result.put("qrPreviewUrl", qrPreviewUrl);
                result.put("hasQrCode", true);
            } else {
                result.put("success", true);
                result.put("hasQrCode", false);
                result.put("message", "该学生还没有二维码");
            }
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取二维码失败: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * 根据二维码获取学生信息（用于二维码预览页面）
     */
    @GetMapping("/getStudentByQrCode")
    @ResponseBody
    public Map<String, Object> getStudentByQrCode(@RequestParam String qrCode) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            User student = userService.getByQrCode(qrCode);
            if (student == null) {
                result.put("success", false);
                result.put("message", "无效的二维码");
                return result;
            }
            
            // 检查是否为学生用户
            if (student.getParentId() == null) {
                result.put("success", false);
                result.put("message", "此二维码不属于学生用户");
                return result;
            }
            
            // 检查用户状态
            if (student.getStatus() != 1) {
                result.put("success", false);
                result.put("message", "该学生账号已被禁用");
                return result;
            }
            
            result.put("success", true);
            result.put("student", student);
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "获取学生信息失败: " + e.getMessage());
        }
        
        return result;
    }
}
