package com.punch.service.impl;

import com.punch.entity.CheckinRecord;
import com.punch.dto.CheckinRecordDTO;
import com.punch.mapper.CheckinRecordMapper;
import com.punch.service.CheckinRecordService;
import com.punch.service.PointsRecordService;
import com.punch.mapper.CheckinItemMapper;
import com.punch.entity.CheckinItem;
import com.punch.service.OperationLogService;
import com.punch.entity.OperationLog;
import com.punch.mapper.TemplateStudentMapper;
import com.punch.service.DailyCheckinService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;


@Service
public class CheckinRecordServiceImpl implements CheckinRecordService {
    @Autowired
    private CheckinRecordMapper recordMapper;
    @Autowired
    private PointsRecordService pointsRecordService;
    @Autowired
    private CheckinItemMapper checkinItemMapper;
    @Autowired
    private OperationLogService operationLogService;
    @Autowired
    private com.punch.mapper.PointsRecordMapper pointsRecordMapper;
    @Autowired
    private TemplateStudentMapper templateStudentMapper;
    @Autowired
    private DailyCheckinService dailyCheckinService;

    @Override
    public CheckinRecord getById(Long id) {
        return recordMapper.selectById(id);
    }

    @Override
    public List<CheckinRecord> getByStudentId(Long studentId) {
        return recordMapper.selectByStudentId(studentId);
    }

    @Override
    public List<CheckinRecord> getByCondition(Long studentId, Long itemId, Date date, Integer status) {
        return recordMapper.selectByCondition(studentId, itemId, date, status);
    }

    @Override
    public List<CheckinRecordDTO> getByConditionWithItemName(Long studentId, Long itemId, Date date, Integer status) {
        // 获取基础记录
        List<CheckinRecord> records = recordMapper.selectByCondition(studentId, itemId, date, status);
        
        // 转换为DTO并填充事项名称
        return records.stream().map(record -> {
            CheckinRecordDTO dto = new CheckinRecordDTO();
            org.springframework.beans.BeanUtils.copyProperties(record, dto);
            
            // 获取事项名称
            CheckinItem item = checkinItemMapper.selectById(record.getItemId());
            if (item != null) {
                dto.setItemName(item.getItemName());
            }
            
            return dto;
        }).collect(java.util.stream.Collectors.toList());
    }

    @Override
    public List<CheckinRecordDTO> getRecordsByParentId(Long parentId, Long itemId, Date date, Integer status) {
        // 获取该家长下所有孩子的打卡记录
        List<CheckinRecord> records = recordMapper.selectByParentId(parentId, itemId, date, status);
        
        // 转换为DTO并填充事项名称
        return records.stream().map(record -> {
            CheckinRecordDTO dto = new CheckinRecordDTO();
            org.springframework.beans.BeanUtils.copyProperties(record, dto);
            
            // 获取事项名称
            CheckinItem item = checkinItemMapper.selectById(record.getItemId());
            if (item != null) {
                dto.setItemName(item.getItemName());
            }
            
            return dto;
        }).collect(java.util.stream.Collectors.toList());
    }

    @Override
    public int createRecord(CheckinRecord record) {
        return recordMapper.insert(record);
    }

    @Override
    public int updateRecord(CheckinRecord record) {
        return recordMapper.update(record);
    }

    @Override
    public int deleteRecord(Long id) {
        return recordMapper.deleteById(id);
    }

    @Override
    public String doCheckin(Long studentId, Long itemId, Date date, Long operatorId, String clientIp) {
        // 检查是否已存在记录
        List<CheckinRecord> list = recordMapper.selectByCondition(studentId, itemId, date, null);
        
        CheckinRecord record;
        boolean isNewRecord = false;
        
        if (!list.isEmpty()) {
            record = list.get(0);
            // 如果已经是打卡状态，返回已打卡
            if (record.getStatus() == 1) {
                return "already_checked";
            }
            // 如果是撤销状态，更新为打卡状态
            else if (record.getStatus() == 2) {
                record.setStatus(1);
                record.setCheckinTime(new Date());
                record.setUpdateBy(operatorId);
                record.setUpdateTime(new Date());
                record.setCancelTime(null); // 清除撤销时间
                recordMapper.update(record);
            }
        } else {
            // 不存在记录，创建新记录
            record = new CheckinRecord();
            record.setStudentId(studentId);
            record.setItemId(itemId);
            record.setCheckinDate(date);
            record.setStatus(1);
            record.setCheckinTime(new Date());
            record.setCreateBy(operatorId);
            record.setCreateTime(new Date());
            recordMapper.insert(record);
            isNewRecord = true;
        }
        
        // 联动积分
        CheckinItem item = checkinItemMapper.selectById(itemId);
        int actualPoints = 0;
        if(item != null && item.getPoints() != null && item.getPoints() > 0) {
            // 检查是否超时
            actualPoints = calculateActualPoints(item, record.getCheckinTime());
            String pointsRemark = actualPoints == item.getPoints() ? "打卡获得积分" : "超时打卡获得积分(减半)";
            pointsRecordService.addPoints(studentId, actualPoints, 1, operatorId, pointsRemark, record.getId());
        }
        
        // 更新每日打卡事项状态（任务排期表）
        try {
            dailyCheckinService.updateCheckinStatus(studentId, itemId, date, 1, actualPoints);
        } catch (Exception e) {
            // 如果更新每日打卡事项失败，记录日志但不影响主流程
            System.err.println("更新每日打卡事项状态失败: " + e.getMessage());
        }
        
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(operatorId);
        log.setOperation(isNewRecord ? "打卡" : "重新打卡");
        log.setTargetId(record.getId());
        log.setTargetType("CheckinRecord");
        log.setContent("学生ID:" + studentId + ", 事项ID:" + itemId + ", 日期:" + date);
        log.setIp(clientIp);
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        
        return "success";
    }

    @Override
    public String cancelCheckin(Long recordId, Long operatorId) {
        CheckinRecord record = recordMapper.selectById(recordId);
        if (record == null || record.getStatus() != 1) return "fail";
        record.setStatus(2);
        record.setCancelTime(new Date());
        record.setUpdateBy(operatorId);
        record.setUpdateTime(new Date());
        recordMapper.update(record);
        // 联动积分（扣除实际获得的积分，超时打卡可能只有一半，不能直接用 item.getPoints()）
        CheckinItem item = checkinItemMapper.selectById(record.getItemId());
        if(item != null && item.getPoints() != null && item.getPoints() > 0) {
            int actualPointsToDeduct = getActualPointsFromRecord(record.getStudentId(), record.getId());
            if (actualPointsToDeduct > 0) {
                pointsRecordService.reducePoints(record.getStudentId(), actualPointsToDeduct, 2, operatorId, "撤销扣除积分", record.getId());
            }
        }
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(operatorId);
        log.setOperation("撤销打卡");
        log.setTargetId(recordId);
        log.setTargetType("CheckinRecord");
        log.setContent("打卡记录ID:" + recordId);
        log.setIp(null);
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        return "success";
    }

    @Override
    public String revokeTodayCheckin(Long studentId, Long itemId, Date date, Long operatorId, String clientIp) {
        // 查找今日的打卡记录
        List<CheckinRecord> list = recordMapper.selectByCondition(studentId, itemId, date, 1); // 只查找已打卡的记录
        if (list.isEmpty()) {
            return "not_found";
        }
        
        CheckinRecord record = list.get(0);
        // 设置为撤销状态
        record.setStatus(2);
        record.setCancelTime(new Date());
        record.setUpdateBy(operatorId);
        record.setUpdateTime(new Date());
        recordMapper.update(record);
        
        // 联动积分（撤销扣除）
        // 查找对应的积分记录，扣除实际获得的积分
        CheckinItem item = checkinItemMapper.selectById(itemId);
        if(item != null && item.getPoints() != null && item.getPoints() > 0) {
            // 查找与此打卡记录关联的积分记录，获取实际获得的积分
            int actualPointsToDeduct = getActualPointsFromRecord(studentId, record.getId());
            if (actualPointsToDeduct > 0) {
                pointsRecordService.reducePoints(studentId, actualPointsToDeduct, 2, operatorId, "撤销打卡扣除积分", record.getId());
            }
        }
        
        // 更新每日打卡事项状态（任务排期表）
        try {
            dailyCheckinService.updateCheckinStatus(studentId, itemId, date, 0, null);
        } catch (Exception e) {
            // 如果更新每日打卡事项失败，记录日志但不影响主流程
            System.err.println("更新每日打卡事项状态失败: " + e.getMessage());
        }
        
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(operatorId);
        log.setOperation("撤销今日打卡");
        log.setTargetId(record.getId());
        log.setTargetType("CheckinRecord");
        log.setContent("学生ID:" + studentId + ", 事项ID:" + itemId + ", 日期:" + date);
        log.setIp(clientIp);
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        
        return "success";
    }

    @Override
    public String supplementCheckin(Long studentId, Long itemId, Date date, Long operatorId) {
        // 检查是否已存在记录
        List<CheckinRecord> list = recordMapper.selectByCondition(studentId, itemId, date, null);
        
        CheckinRecord record;
        boolean isNewRecord = true;
        
        if (!list.isEmpty()) {
            record = list.get(0);
            if (record.getStatus() == 1) {
                return "already_checked"; // 已经打过卡了
            }
            // 如果存在已撤销的记录，更新它
            record.setStatus(1);
            record.setCheckinTime(new Date());
            recordMapper.update(record);
            isNewRecord = false;
        } else {
            // 如果不存在记录，创建新记录
            record = new CheckinRecord();
            record.setStudentId(studentId);
            record.setItemId(itemId);
            record.setCheckinDate(date);
            record.setStatus(1);
            record.setCheckinTime(new Date());
            record.setCreateBy(operatorId);
            record.setCreateTime(new Date());
            recordMapper.insert(record);
        }
        // 联动积分（补打卡都应该给积分，无论是新记录还是重新激活）
        CheckinItem item = checkinItemMapper.selectById(itemId);
        if(item != null && item.getPoints() != null && item.getPoints() > 0) {
            // 补打卡通常是超时的，所以给一半积分
            int actualPoints = Math.max(1, item.getPoints() / 2);
            String pointsRemark = isNewRecord ? "补打卡获得积分(减半)" : "重新激活打卡获得积分(减半)";
            pointsRecordService.addPoints(studentId, actualPoints, 1, operatorId, pointsRemark, record.getId());
        }
        
        // 更新每日打卡事项状态（任务排期表）
        try {
            if (item != null) {
                dailyCheckinService.updateCheckinStatus(studentId, itemId, date, 1, item.getPoints());
            }
        } catch (Exception e) {
            // 如果更新每日打卡事项失败，记录日志但不影响主流程
            System.err.println("更新每日打卡事项状态失败: " + e.getMessage());
        }
        
        // 日志记录
        OperationLog log = new OperationLog();
        log.setUserId(operatorId);
        log.setOperation(isNewRecord ? "补打卡" : "重新激活打卡记录");
        log.setTargetId(record.getId());
        log.setTargetType("CheckinRecord");
        log.setContent("学生ID:" + studentId + ", 事项ID:" + itemId + ", 日期:" + date);
        log.setIp(null);
        log.setCreateTime(new Date());
        operationLogService.insert(log);
        return "success";
    }

    /**
     * 根据打卡时间计算实际应得积分
     * 提前打卡和正常时间打卡得全分；只有超时打卡才得一半积分
     */
    private int calculateActualPoints(CheckinItem item, Date checkinTime) {
        // 如果没有设置时间限制，直接返回全分
        if (item.getCheckinStartTime() == null && item.getCheckinEndTime() == null) {
            return item.getPoints();
        }
        
        // 获取当前打卡时间的小时和分钟
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(checkinTime);
        int currentHour = cal.get(java.util.Calendar.HOUR_OF_DAY);
        int currentMinute = cal.get(java.util.Calendar.MINUTE);
        int currentTimeMinutes = currentHour * 60 + currentMinute;
        
        // 检查开始时间 - 提前打卡应该得全分
        boolean isLate = false;
        
        if (item.getCheckinStartTime() != null) {
            String startTime = item.getCheckinStartTime().toString(); // 格式：HH:mm:ss
            String[] startParts = startTime.split(":");
            int startTimeMinutes = Integer.parseInt(startParts[0]) * 60 + Integer.parseInt(startParts[1]);
            
            // 提前打卡不做特殊处理，仍然得全分
        }
        
        // 检查结束时间 - 只有超时打卡才扣分
        if (item.getCheckinEndTime() != null) {
            String endTime = item.getCheckinEndTime().toString(); // 格式：HH:mm:ss
            String[] endParts = endTime.split(":");
            int endTimeMinutes = Integer.parseInt(endParts[0]) * 60 + Integer.parseInt(endParts[1]);
            
            if (currentTimeMinutes > endTimeMinutes) {
                isLate = true; // 超时打卡
            }
        }
        
        // 只有超时打卡才给一半积分，提前打卡和正常时间打卡都给全分
        return isLate ? Math.max(1, item.getPoints() / 2) : item.getPoints();
    }

    /**
     * 从积分记录中获取实际获得的积分数
     * 用于撤销时准确扣除积分
     */
    private int getActualPointsFromRecord(Long studentId, Long recordId) {
        try {
            // 直接查找与此打卡记录关联的积分记录，使用更精确的查询
            java.util.List<com.punch.entity.PointsRecord> pointsRecords = pointsRecordMapper.selectByStudentId(studentId);
            
            // 找到与当前打卡记录关联的积分记录（类型为1：打卡获得）
            for (com.punch.entity.PointsRecord pr : pointsRecords) {
                if (pr.getRecordId() != null && pr.getRecordId().equals(recordId) && pr.getType() == 1) {
                    System.out.println("找到关联积分记录: recordId=" + recordId + ", points=" + pr.getPoints());
                    return Math.abs(pr.getPoints()); // 返回绝对值，因为积分记录中是正数
                }
            }
            
            // 如果没有找到关联的积分记录，尝试从打卡记录中获取事项积分
            CheckinRecord record = recordMapper.selectById(recordId);
            if (record != null) {
                CheckinItem item = checkinItemMapper.selectById(record.getItemId());
                if (item != null && item.getPoints() != null && item.getPoints() > 0) {
                    // 计算实际积分（考虑超时减半）
                    int actualPoints = calculateActualPoints(item, record.getCheckinTime());
                    System.out.println("从事项计算积分: itemId=" + item.getId() + ", points=" + actualPoints);
                    return actualPoints;
                }
            }
        } catch (Exception e) {
            System.err.println("获取实际积分失败: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<com.punch.dto.CheckinItemDTO> getTodayCheckinItems(Long studentId) {
        List<com.punch.dto.CheckinItemDTO> result = new java.util.ArrayList<>();
        
        // 1. 获取该学生关联的所有模板ID
        List<Long> templateIds = templateStudentMapper.selectTemplateIdsByStudentId(studentId);
        
        // 2. 获取这些模板下的所有启用的打卡事项
        for (Long templateId : templateIds) {
            List<CheckinItem> templateItems = checkinItemMapper.selectByTemplateId(templateId);
            
            // 为每个事项创建DTO并设置今日打卡状态
            java.util.Date today = new java.util.Date();
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            String todayStr = sdf.format(today);
            
            for (CheckinItem item : templateItems) {
                // 只显示启用的事项（status != 2）
                if (item.getStatus() != null && item.getStatus() == 2) {
                    continue; // 跳过禁用的事项
                }
                
                com.punch.dto.CheckinItemDTO dto = new com.punch.dto.CheckinItemDTO();
                dto.setId(item.getId());
                dto.setTemplateId(item.getTemplateId());
                dto.setItemName(item.getItemName());
                dto.setDescription(item.getDescription());
                dto.setPoints(item.getPoints());
                dto.setSortOrder(item.getSortOrder());
                dto.setCheckinStartTime(item.getCheckinStartTime());
                dto.setCheckinEndTime(item.getCheckinEndTime());
                dto.setCreateTime(item.getCreateTime());
                dto.setUpdateTime(item.getUpdateTime());
                
                // 从历史记录表查询今日是否已打卡（只查找有效的打卡记录，状态为1）
                List<CheckinRecord> todayRecords = recordMapper.selectByCondition(studentId, item.getId(), today, 1);
                
                // 设置今日状态：0-未打卡，1-已打卡
                boolean hasCheckedToday = false;
                for (CheckinRecord record : todayRecords) {
                    String recordDateStr = sdf.format(record.getCheckinTime());
                    if (todayStr.equals(recordDateStr) && record.getStatus() == 1) {
                        hasCheckedToday = true;
                        break;
                    }
                }
                
                dto.setTodayStatus(hasCheckedToday ? 1 : 0);
                result.add(dto);
            }
        }
        
        return result;
    }
}
