package com.punch.service;

import com.punch.entity.User;
import java.util.List;

public interface UserService {
    User getById(Long id);
    User getByUsername(String username);
    User getByAuthCode(String authCode);
    User login(String username, String password);
    int createUser(User user);
    int updateUser(User user);
    int deleteUser(Long id);
    List<User> getAllUsers();
    List<User> getUsersByCondition(String username, Integer status, String startTime, String endTime);
    List<User> getUsersByParentId(Long parentId, String username, Integer status, String startTime, String endTime);
    List<User> getParentUsers();
    List<User> getStudentUsers();
    List<User> getStudentsByParentId(Long parentId);
    User getByQrCode(String qrCode);
    String generateQrCodeForStudent(Long studentId);
    int updateQrCode(Long studentId, String qrCode);
}
