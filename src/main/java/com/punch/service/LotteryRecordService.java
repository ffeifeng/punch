package com.punch.service;

import com.punch.entity.LotteryRecord;
import com.punch.dto.LotteryRecordDTO;
import java.util.List;

public interface LotteryRecordService {
    LotteryRecord getById(Long id);
    List<LotteryRecord> getByStudentId(Long studentId);
    List<LotteryRecord> getByStudentIdAndStatus(Long studentId, Integer isRedeemed);
    List<LotteryRecordDTO> getByParentId(Long parentId, Long studentId, Integer isRedeemed);
    int create(LotteryRecord record);
    int redeem(Long id, Long operatorId);
}
