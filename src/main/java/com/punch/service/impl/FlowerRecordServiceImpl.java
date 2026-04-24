package com.punch.service.impl;

import com.punch.entity.FlowerRecord;
import com.punch.entity.User;
import com.punch.mapper.FlowerRecordMapper;
import com.punch.mapper.UserMapper;
import com.punch.service.FlowerRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
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
        User user = userMapper.selectById(studentId);
        return (user != null && user.getFlowerCount() != null) ? user.getFlowerCount() : 0;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int addFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId) {
        // FOR UPDATE 行锁，防止并发读到相同旧余额
        User user = userMapper.selectByIdForUpdate(studentId);
        if (user == null) throw new RuntimeException("用户不存在，ID: " + studentId);
        int newBalance = (user.getFlowerCount() == null ? 0 : user.getFlowerCount()) + amount;
        userMapper.updateFlowerCount(studentId, newBalance);
        insertRecord(studentId, amount, newBalance, type, operatorId, remark, sourceId);
        return newBalance;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int reduceFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId) {
        // FOR UPDATE 行锁
        User user = userMapper.selectByIdForUpdate(studentId);
        if (user == null) return -1;
        int current = user.getFlowerCount() == null ? 0 : user.getFlowerCount();
        if (current < amount) return -1;
        int newBalance = current - amount;
        userMapper.updateFlowerCount(studentId, newBalance);
        insertRecord(studentId, -amount, newBalance, type, operatorId, remark, sourceId);
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
}
