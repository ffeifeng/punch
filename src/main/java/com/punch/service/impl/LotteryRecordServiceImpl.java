package com.punch.service.impl;

import com.punch.entity.LotteryRecord;
import com.punch.dto.LotteryRecordDTO;
import com.punch.mapper.LotteryRecordMapper;
import com.punch.service.LotteryRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class LotteryRecordServiceImpl implements LotteryRecordService {

    @Autowired
    private LotteryRecordMapper lotteryRecordMapper;

    @Override
    public LotteryRecord getById(Long id) {
        return lotteryRecordMapper.selectById(id);
    }

    @Override
    public List<LotteryRecord> getByStudentId(Long studentId) {
        return lotteryRecordMapper.selectByStudentId(studentId);
    }

    @Override
    public List<LotteryRecordDTO> getByParentId(Long parentId, Long studentId, Integer isRedeemed) {
        return lotteryRecordMapper.selectByParentId(parentId, studentId, isRedeemed);
    }

    @Override
    public int create(LotteryRecord record) {
        record.setLotteryTime(new Date());
        record.setIsRedeemed(0);
        return lotteryRecordMapper.insert(record);
    }

    @Override
    public int redeem(Long id, Long operatorId) {
        LotteryRecord record = lotteryRecordMapper.selectById(id);
        if (record == null) return 0;
        record.setIsRedeemed(1);
        record.setRedeemedTime(new Date());
        record.setRedeemedBy(operatorId);
        return lotteryRecordMapper.update(record);
    }
}
