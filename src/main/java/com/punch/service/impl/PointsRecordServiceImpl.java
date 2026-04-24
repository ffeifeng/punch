package com.punch.service.impl;

import com.punch.entity.PointsRecord;
import com.punch.dto.PointsRecordDTO;
import com.punch.mapper.PointsRecordMapper;
import com.punch.service.PointsRecordService;
import com.punch.mapper.UserMapper;
import com.punch.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class PointsRecordServiceImpl implements PointsRecordService {
    @Autowired
    private PointsRecordMapper pointsRecordMapper;
    @Autowired
    private UserMapper userMapper;

    @Override
    public PointsRecord getById(Long id) {
        return pointsRecordMapper.selectById(id);
    }

    @Override
    public List<PointsRecord> getByStudentId(Long studentId) {
        return pointsRecordMapper.selectByStudentId(studentId);
    }

    @Override
    public List<PointsRecord> getByCondition(Long studentId, Integer type) {
        return pointsRecordMapper.selectByCondition(studentId, type);
    }

    @Override
    public List<PointsRecord> getByCondition(Long studentId, Integer type, String date) {
        return pointsRecordMapper.selectByConditionWithDate(studentId, type, date);
    }

    @Override
    public int createRecord(PointsRecord record) {
        return pointsRecordMapper.insert(record);
    }

    @Override
    public int updateRecord(PointsRecord record) {
        return pointsRecordMapper.update(record);
    }

    @Override
    public int deleteRecord(Long id) {
        return pointsRecordMapper.deleteById(id);
    }

    @Override
    public int addPoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId) {
        int currentBalance = getCurrentBalance(studentId);
        int newBalance = currentBalance + points;
        
        // 创建积分记录
        PointsRecord pr = new PointsRecord();
        pr.setStudentId(studentId);
        pr.setPoints(points);
        pr.setType(type);
        pr.setBalance(newBalance);
        pr.setOperatorId(operatorId);
        pr.setOperateTime(new Date());
        pr.setRemark(remark);
        pr.setRecordId(recordId);
        
        // 插入积分记录
        int insertResult = pointsRecordMapper.insert(pr);
        if (insertResult <= 0) {
            throw new RuntimeException("积分记录插入失败");
        }
        
        // 更新用户表总积分
        User user = userMapper.selectById(studentId);
        if (user != null) {
            user.setTotalPoints(newBalance);
            int updateResult = userMapper.update(user);
            if (updateResult <= 0) {
                throw new RuntimeException("用户积分更新失败");
            }
        } else {
            throw new RuntimeException("用户不存在，ID: " + studentId);
        }
        
        return newBalance;
    }

    @Override
    public int reducePoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId) {
        int currentBalance = getCurrentBalance(studentId);
        // 安全兜底：实际扣除不超过当前余额，余额最低为0
        int actualDeduct = Math.min(points, currentBalance);
        if (actualDeduct <= 0) return currentBalance;
        int balance = currentBalance - actualDeduct;
        PointsRecord pr = new PointsRecord();
        pr.setStudentId(studentId);
        pr.setPoints(-actualDeduct);
        pr.setType(type);
        pr.setBalance(balance);
        pr.setOperatorId(operatorId);
        pr.setOperateTime(new Date());
        pr.setRemark(remark);
        pr.setRecordId(recordId);
        pointsRecordMapper.insert(pr);
        // 更新user表总积分
        User user = userMapper.selectById(studentId);
        if(user != null) {
            user.setTotalPoints(balance);
            userMapper.update(user);
        }
        return balance;
    }

    @Override
    public int getCurrentBalance(Long studentId) {
        if (studentId == null) {
            return 0;
        }
        
        List<PointsRecord> list = pointsRecordMapper.selectByStudentId(studentId);
        if (list == null || list.isEmpty()) {
            // 如果没有积分记录，检查用户表中的总积分
            User user = userMapper.selectById(studentId);
            if (user != null && user.getTotalPoints() != null) {
                return user.getTotalPoints();
            }
            return 0;
        }
        
        // 返回最新记录的余额
        return list.get(0).getBalance();
    }

    @Override
    public List<PointsRecord> getByParentId(Long parentId, Long studentId, Integer type) {
        if (parentId == null) {
            return new java.util.ArrayList<>();
        }
        return pointsRecordMapper.selectByParentId(parentId, studentId, type);
    }

    @Override
    public List<PointsRecord> getByParentId(Long parentId, Long studentId, Integer type, String date) {
        if (parentId == null) {
            return new java.util.ArrayList<>();
        }
        return pointsRecordMapper.selectByParentIdWithDate(parentId, studentId, type, date);
    }

    @Override
    public List<PointsRecordDTO> getByConditionWithNames(Long studentId, Integer type) {
        return pointsRecordMapper.selectByConditionWithNames(studentId, type);
    }

    @Override
    public List<PointsRecordDTO> getByConditionWithNames(Long studentId, Integer type, String date) {
        return pointsRecordMapper.selectByConditionWithNamesAndDate(studentId, type, date);
    }

    @Override
    public List<PointsRecordDTO> getByParentIdWithNames(Long parentId, Long studentId, Integer type) {
        if (parentId == null) {
            return new java.util.ArrayList<>();
        }
        return pointsRecordMapper.selectByParentIdWithNames(parentId, studentId, type);
    }

    @Override
    public List<PointsRecordDTO> getByParentIdWithNames(Long parentId, Long studentId, Integer type, String date) {
        if (parentId == null) {
            return new java.util.ArrayList<>();
        }
        return pointsRecordMapper.selectByParentIdWithNamesAndDate(parentId, studentId, type, date);
    }
}
