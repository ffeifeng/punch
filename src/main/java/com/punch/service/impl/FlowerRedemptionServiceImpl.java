package com.punch.service.impl;

import com.punch.entity.FlowerItem;
import com.punch.entity.FlowerRecord;
import com.punch.entity.FlowerRedemption;
import com.punch.mapper.FlowerItemMapper;
import com.punch.mapper.FlowerRecordMapper;
import com.punch.mapper.FlowerRedemptionMapper;
import com.punch.service.FlowerRecordService;
import com.punch.service.FlowerRedemptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class FlowerRedemptionServiceImpl implements FlowerRedemptionService {

    @Autowired private FlowerRedemptionMapper redemptionMapper;
    @Autowired private FlowerItemMapper       itemMapper;
    @Autowired private FlowerRecordService    flowerRecordService;
    @Autowired private FlowerRecordMapper     flowerRecordMapper;

    @Override
    public Map<String, Object> redeem(Long studentId, Long itemId, int qty, Long operatorId) {
        Map<String, Object> result = new HashMap<>();
        if (qty < 1) {
            result.put("success", false); result.put("message", "兑换数量至少为 1"); return result;
        }
        FlowerItem item = itemMapper.selectById(itemId);
        if (item == null || item.getStatus() != 1) {
            result.put("success", false); result.put("message", "兑换项目不存在或已禁用"); return result;
        }
        // 每日限额检查（按数量）
        if (item.getDailyLimit() != null && item.getDailyLimit() > 0) {
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            int todayUsed = redemptionMapper.countTodayByStudentAndItem(studentId, itemId, today);
            int remaining = item.getDailyLimit() - todayUsed;
            if (remaining <= 0) {
                result.put("success", false);
                result.put("message", "今天「" + item.getName() + "」已达每日上限 " + item.getDailyLimit() + " 朵");
                return result;
            }
            if (qty > remaining) {
                result.put("success", false);
                result.put("message", "今天「" + item.getName() + "」还可兑换 " + remaining
                        + " 朵，本次申请 " + qty + " 朵超出限制");
                result.put("maxQty", remaining);
                return result;
            }
        }
        int totalCost = item.getFlowerCost() * qty;
        // 余额检查 + 扣花
        int newBalance = flowerRecordService.reduceFlowers(
                studentId, totalCost, 2, operatorId,
                "兑换「" + item.getName() + "」×" + qty + " 消耗小红花", null);
        if (newBalance == -1) {
            result.put("success", false);
            result.put("message", "小红花不足，需要 " + totalCost + " 朵，余量不足");
            return result;
        }
        // 创建兑换记录（单条，qty 记录数量）
        FlowerRedemption redemption = new FlowerRedemption();
        redemption.setStudentId(studentId);
        redemption.setItemId(itemId);
        redemption.setItemName(item.getName() + (qty > 1 ? " ×" + qty : ""));
        redemption.setFlowerCost(totalCost);
        redemption.setQty(qty);
        redemption.setTimeMinutes(item.getTimeMinutes() != null ? item.getTimeMinutes() * qty : null);
        redemption.setStatus(0);
        redemption.setRedeemDate(new java.sql.Date(System.currentTimeMillis()));
        redemption.setRedeemTime(new Date());
        redemption.setCreateTime(new Date());
        redemptionMapper.insert(redemption);

        // 回填流水的 source_id
        com.punch.entity.FlowerRecord latestRecord = flowerRecordMapper.selectLatestByStudentId(studentId);
        if (latestRecord != null && latestRecord.getSourceId() == null) {
            flowerRecordMapper.updateSourceId(latestRecord.getId(), redemption.getId());
        }

        String timeDesc = redemption.getTimeMinutes() != null ? "，获得 " + redemption.getTimeMinutes() + " 分钟" : "";
        result.put("success", true);
        result.put("message", "申请成功！扣除 " + totalCost + " 朵小红花" + timeDesc + "，等待家长确认 🌸");
        result.put("newBalance", newBalance);
        result.put("redemptionId", redemption.getId());
        return result;
    }

    @Override
    public Map<String, Object> approve(Long redemptionId, Long operatorId) {
        Map<String, Object> result = new HashMap<>();
        FlowerRedemption redemption = redemptionMapper.selectById(redemptionId);
        if (redemption == null || redemption.getStatus() != 0) {
            result.put("success", false); result.put("message", "记录不存在或不是待审批状态"); return result;
        }
        redemption.setStatus(1);
        redemption.setConfirmTime(new Date());
        redemption.setConfirmBy(operatorId);
        redemptionMapper.update(redemption);
        result.put("success", true);
        result.put("message", "已审批通过");
        return result;
    }

    @Override
    public Map<String, Object> revoke(Long redemptionId, Long operatorId) {
        Map<String, Object> result = new HashMap<>();
        FlowerRedemption redemption = redemptionMapper.selectById(redemptionId);
        if (redemption == null || redemption.getStatus() == 2) {
            result.put("success", false); result.put("message", "记录不存在或已撤销"); return result;
        }
        // 退还小红花
        flowerRecordService.addFlowers(
                redemption.getStudentId(), redemption.getFlowerCost(), 4, operatorId,
                "撤销兑换「" + redemption.getItemName() + "」退还小红花", redemption.getId());
        redemption.setStatus(2);
        redemption.setConfirmTime(new Date());
        redemption.setConfirmBy(operatorId);
        redemptionMapper.update(redemption);
        int newBalance = flowerRecordService.getCurrentBalance(redemption.getStudentId());
        result.put("success", true);
        result.put("message", "已撤销，退还 " + redemption.getFlowerCost() + " 朵小红花");
        result.put("newBalance", newBalance);
        return result;
    }

    @Override public List<FlowerRedemption> getByStudentId(Long studentId) {
        return redemptionMapper.selectByStudentId(studentId);
    }
    @Override public List<FlowerRedemption> getPendingByParentId(Long parentId) {
        return redemptionMapper.selectPendingByParentId(parentId);
    }
    @Override public List<FlowerRedemption> getByParentId(Long parentId, Integer status) {
        return redemptionMapper.selectByParentId(parentId, status);
    }
}
