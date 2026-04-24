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
    int cancelRedeem(Long id);
    /** 按奖品ID列表批量兑奖，返回处理条数 */
    int batchRedeem(Long parentId, Long studentId, List<Long> itemIds, Long operatorId);
    /** 查询未兑奖记录按奖品分组统计（基于lottery_item配置） */
    List<java.util.Map<String, Object>> countUnredeemedGroupByItem(Long parentId, Long studentId);
}
