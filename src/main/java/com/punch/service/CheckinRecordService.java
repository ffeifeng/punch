package com.punch.service;

import com.punch.entity.CheckinRecord;
import com.punch.dto.CheckinRecordDTO;
import com.punch.dto.CheckinItemDTO;
import java.util.Date;
import java.util.List;

public interface CheckinRecordService {
    CheckinRecord getById(Long id);
    List<CheckinRecord> getByStudentId(Long studentId);
    List<CheckinRecord> getByCondition(Long studentId, Long itemId, Date date, Integer status);
    List<CheckinRecordDTO> getByConditionWithItemName(Long studentId, Long itemId, Date date, Integer status);
    List<CheckinRecordDTO> getRecordsByParentId(Long parentId, Long itemId, Date date, Integer status);
    int createRecord(CheckinRecord record);
    int updateRecord(CheckinRecord record);
    int deleteRecord(Long id);
    // 打卡、撤销、补打等业务方法
    String doCheckin(Long studentId, Long itemId, Date date, Long operatorId, String clientIp);
    String cancelCheckin(Long recordId, Long operatorId);
    String revokeTodayCheckin(Long studentId, Long itemId, Date date, Long operatorId, String clientIp);
    String supplementCheckin(Long studentId, Long itemId, Date date, Long operatorId);
    // 获取学生今日打卡事项及状态
    List<CheckinItemDTO> getTodayCheckinItems(Long studentId);
}
