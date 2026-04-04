package com.punch.service.impl;

import com.punch.entity.User;
import com.punch.mapper.UserMapper;
import com.punch.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserMapper userMapper;

    @Override
    public User getById(Long id) {
        return userMapper.selectById(id);
    }

    @Override
    public User getByUsername(String username) {
        return userMapper.selectByUsername(username);
    }

    @Override
    public User getByAuthCode(String authCode) {
        return userMapper.selectByAuthCode(authCode);
    }

    @Override
    public User login(String username, String password) {
        User user = userMapper.selectByUsername(username);
        if (user != null && password.equals(user.getPassword())) {
            return user;
        }
        return null;
    }

    @Override
    public int createUser(User user) {
        return userMapper.insert(user);
    }

    @Override
    public int updateUser(User user) {
        return userMapper.update(user);
    }

    @Override
    public int deleteUser(Long id) {
        return userMapper.deleteById(id);
    }

    @Override
    public List<User> getAllUsers() {
        return userMapper.selectAll();
    }

    @Override
    public List<User> getUsersByCondition(String username, Integer status, String startTime, String endTime) {
        return userMapper.selectByCondition(username, status, startTime, endTime);
    }

    @Override
    public List<User> getUsersByParentId(Long parentId, String username, Integer status, String startTime, String endTime) {
        return userMapper.selectByParentIdAndCondition(parentId, username, status, startTime, endTime);
    }

    @Override
    public List<User> getParentUsers() {
        return userMapper.selectParentUsers();
    }

    @Override
    public List<User> getStudentUsers() {
        return userMapper.selectStudentUsers();
    }

    @Override
    public User getByQrCode(String qrCode) {
        return userMapper.selectByQrCode(qrCode);
    }

    @Override
    public String generateQrCodeForStudent(Long studentId) {
        User student = userMapper.selectById(studentId);
        if (student == null || student.getParentId() == null) {
            throw new RuntimeException("用户不存在或不是学生用户");
        }
        
        // 生成新的二维码
        String qrCode;
        int attempts = 0;
        do {
            qrCode = com.punch.util.QrCodeUtils.generateStudentQrCode();
            attempts++;
            if (attempts > 10) {
                throw new RuntimeException("生成二维码失败，请稍后重试");
            }
        } while (userMapper.selectByQrCode(qrCode) != null); // 确保唯一性
        
        // 更新数据库
        student.setQrCode(qrCode);
        userMapper.update(student);
        
        return qrCode;
    }

    @Override
    public int updateQrCode(Long studentId, String qrCode) {
        User student = userMapper.selectById(studentId);
        if (student == null) {
            return 0;
        }
        student.setQrCode(qrCode);
        return userMapper.update(student);
    }

    @Override
    public List<User> getStudentsByParentId(Long parentId) {
        return userMapper.selectByParentId(parentId);
    }
}
