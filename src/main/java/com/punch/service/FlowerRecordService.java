package com.punch.service;

import com.punch.entity.FlowerRecord;
import java.util.List;

public interface FlowerRecordService {
    /** 当前小红花余量（从流水最新记录取） */
    int getCurrentBalance(Long studentId);

    /** 增加小红花（抽奖获得/家长手动添加） */
    int addFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId);

    /** 扣减小红花，余额不足返回 -1，成功返回新余额 */
    int reduceFlowers(Long studentId, int amount, int type, Long operatorId, String remark, Long sourceId);

    List<FlowerRecord> getByStudentId(Long studentId);
}
