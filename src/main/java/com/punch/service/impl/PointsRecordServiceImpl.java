package com.punch.service.impl;

import com.punch.entity.PointsRecord;
import com.punch.dto.PointsRecordDTO;
import com.punch.mapper.PointsRecordMapper;
import com.punch.service.PointsRecordService;
import com.punch.mapper.UserMapper;
import com.punch.entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
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
    @Transactional(rollbackFor = Exception.class)
    public int addPoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId) {
        // FOR UPDATE 行锁：同一用户的并发操作串行执行，避免读脏余额
        User user = userMapper.selectByIdForUpdate(studentId);
        if (user == null) throw new RuntimeException("用户不存在，ID: " + studentId);
        int newBalance = (user.getTotalPoints() == null ? 0 : user.getTotalPoints()) + points;

        // 原子更新 total_points
        userMapper.updateTotalPoints(studentId, newBalance);

        // 插入流水记录
        PointsRecord pr = new PointsRecord();
        pr.setStudentId(studentId);
        pr.setPoints(points);
        pr.setType(type);
        pr.setBalance(newBalance);
        pr.setOperatorId(operatorId);
        pr.setOperateTime(new Date());
        pr.setRemark(remark);
        pr.setRecordId(recordId);
        if (pointsRecordMapper.insert(pr) <= 0) {
            throw new RuntimeException("积分记录插入失败");
        }
        return newBalance;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int reducePoints(Long studentId, int points, int type, Long operatorId, String remark, Long recordId) {
        // FOR UPDATE 行锁
        User user = userMapper.selectByIdForUpdate(studentId);
        if (user == null) return 0;
        int currentBalance = user.getTotalPoints() == null ? 0 : user.getTotalPoints();
        // 安全兜底：实际扣除不超过当前余额，余额最低为 0
        int actualDeduct = Math.min(points, currentBalance);
        if (actualDeduct <= 0) return currentBalance;
        int newBalance = currentBalance - actualDeduct;

        // 原子更新 total_points
        userMapper.updateTotalPoints(studentId, newBalance);

        // 插入流水记录
        PointsRecord pr = new PointsRecord();
        pr.setStudentId(studentId);
        pr.setPoints(-actualDeduct);
        pr.setType(type);
        pr.setBalance(newBalance);
        pr.setOperatorId(operatorId);
        pr.setOperateTime(new Date());
        pr.setRemark(remark);
        pr.setRecordId(recordId);
        pointsRecordMapper.insert(pr);
        return newBalance;
    }

    @Override
    public int getCurrentBalance(Long studentId) {
        if (studentId == null) return 0;
        User user = userMapper.selectById(studentId);
        if (user != null && user.getTotalPoints() != null) {
            return user.getTotalPoints();
        }
        return 0;
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
