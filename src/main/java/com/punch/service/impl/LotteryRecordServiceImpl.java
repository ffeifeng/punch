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
    public List<LotteryRecord> getByStudentIdAndStatus(Long studentId, Integer isRedeemed) {
        return lotteryRecordMapper.selectByStudentIdAndStatus(studentId, isRedeemed);
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

    @Override
    public int cancelRedeem(Long id) {
        LotteryRecord record = lotteryRecordMapper.selectById(id);
        if (record == null) return 0;
        record.setIsRedeemed(0);
        record.setRedeemedTime(null);
        record.setRedeemedBy(null);
        return lotteryRecordMapper.update(record);
    }

    @Override
    public int batchRedeem(Long parentId, Long studentId, List<Long> itemIds, Long operatorId) {
        List<LotteryRecord> records = lotteryRecordMapper.selectUnredeemedByItemIds(parentId, studentId, itemIds);
        if (records == null || records.isEmpty()) return 0;
        Date now = new Date();
        int count = 0;
        for (LotteryRecord r : records) {
            r.setIsRedeemed(1);
            r.setRedeemedTime(now);
            r.setRedeemedBy(operatorId);
            lotteryRecordMapper.update(r);
            count++;
        }
        return count;
    }

    @Override
    public List<java.util.Map<String, Object>> countUnredeemedGroupByItem(Long parentId, Long studentId) {
        return lotteryRecordMapper.countUnredeemedGroupByItem(parentId, studentId);
    }
}
