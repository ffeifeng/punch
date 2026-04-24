package com.punch.service.impl;

import com.punch.entity.FlowerRecord;
import com.punch.entity.User;
import com.punch.mapper.FlowerRecordMapper;
import com.punch.mapper.UserMapper;
import com.punch.service.FlowerRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class FlowerRecordServiceImpl implements FlowerRecordService {

    @Autowired
    private FlowerRecordMapper flowerRecordMapper;
    @Autowired
    private UserMapper userMapper;

    @Override
    public int getCurrentBalance(Long studentId) {
        if (studentId == null) return 0;
        FlowerRecord latest = flowerRecordMapper.selectLatestByStudentId(studentId);
        if (latest != null) return latest.getBalance();
        User user = userMapper.selectById(studentId);
        return (user != null && user.getFlowerCount() != null) ? user.getFlowerCount() : 0;
    }

    @Override
    public int addFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId) {
        int newBalance = getCurrentBalance(studentId) + amount;
        insertRecord(studentId, amount, newBalance, type, operatorId, remark, sourceId);
        syncUserField(studentId, newBalance);
        return newBalance;
    }

    @Override
    public int reduceFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId) {
        int current = getCurrentBalance(studentId);
        if (current < amount) return -1;
        int newBalance = current - amount;
        insertRecord(studentId, -amount, newBalance, type, operatorId, remark, sourceId);
        syncUserField(studentId, newBalance);
        return newBalance;
    }

    @Override
    public List<FlowerRecord> getByStudentId(Long studentId) {
        return flowerRecordMapper.selectByStudentId(studentId);
    }

    private void insertRecord(Long studentId, int change, int balance, int type,
                              Long operatorId, String remark, Long sourceId) {
        FlowerRecord r = new FlowerRecord();
        r.setStudentId(studentId);
        r.setChangeAmount(change);
        r.setBalance(balance);
        r.setType(type);
        r.setOperatorId(operatorId);
        r.setRemark(remark);
        r.setSourceId(sourceId);
        r.setOperateTime(new Date());
        flowerRecordMapper.insert(r);
    }

    /** 将最新余额同步到 user 表的 flower_count 字段（用于快速展示） */
    private void syncUserField(Long studentId, int balance) {
        User user = userMapper.selectById(studentId);
        if (user != null) {
            user.setFlowerCount(balance);
            userMapper.update(user);
        }
    }
}
