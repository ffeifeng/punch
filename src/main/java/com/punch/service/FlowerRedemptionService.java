package com.punch.service;

import com.punch.entity.FlowerRedemption;
import java.util.List;
import java.util.Map;

public interface FlowerRedemptionService {
    /**
     * 孩子申请兑换：立即扣花，创建 status=0 记录
     * qty: 本次兑换数量（>=1）
     * 返回 Map：success, message, newBalance, redemptionId
     */
    Map<String, Object> redeem(Long studentId, Long itemId, int qty, Long operatorId);

    /** 家长审批通过 */
    Map<String, Object> approve(Long redemptionId, Long operatorId);

    /** 家长撤销（退还小红花） */
    Map<String, Object> revoke(Long redemptionId, Long operatorId);

    List<FlowerRedemption> getByStudentId(Long studentId);
    List<FlowerRedemption> getPendingByParentId(Long parentId);
    List<FlowerRedemption> getByParentId(Long parentId, Integer status);
}
