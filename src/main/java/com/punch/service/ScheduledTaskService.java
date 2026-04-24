package com.punch.service;

import com.punch.config.PunchProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Calendar;

/**
 * 定时任务服务
 */
@Service
public class ScheduledTaskService {
    
    private static final Logger logger = LoggerFactory.getLogger(ScheduledTaskService.class);
    
    @Autowired
    private DailyCheckinService dailyCheckinService;
    
    @Autowired
    private PunchProperties punchProperties;
    
    /**
     * 每日打卡事项刷新任务
     * 每分钟检查一次，如果到了配置的时间就执行刷新
     */
    @Scheduled(cron = "0 * * * * ?") // 每分钟执行一次
    public void dailyCheckinItemsRefreshTask() {
        try {
            // 检查是否启用定时刷新
            if (!punchProperties.getDailyRefresh().isEnabled()) {
                return;
            }
            
            // 获取配置的刷新时间
            String configTime = punchProperties.getDailyRefresh().getTime();
            
            // 获取当前时间
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
            String currentTime = timeFormat.format(new Date());
            
            // 检查是否到了刷新时间（精确到分钟）
            String configTimeMinute = configTime.substring(0, 5); // HH:mm
            String currentTimeMinute = currentTime.substring(0, 5); // HH:mm
            
            if (configTimeMinute.equals(currentTimeMinute)) {
                logger.info("🚀 开始执行每日打卡事项刷新任务...");
                
                // 获取今天的日期
                Date today = new Date();
                
                // 1. 清理今日的排期数据（避免重复）
                int cleanedCount = dailyCheckinService.cleanDailyItems(today);
                logger.info("🧹 清理今日数据: {} 条", cleanedCount);
                
                // 2. 生成今日的打卡事项（全新生成）
                int generatedCount = dailyCheckinService.generateDailyCheckinItems(today);
                logger.info("➕ 生成新事项: {} 条", generatedCount);
                
                // 3. 标记过期事项（前天及更早的未打卡事项）
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(today);
                calendar.add(Calendar.DAY_OF_MONTH, -2); // 前天之前的未打卡事项标记为过期
                Date beforeYesterday = calendar.getTime();
                int expiredCount = dailyCheckinService.updateExpiredStatus(beforeYesterday);
                logger.info("⏰ 标记过期事项: {} 条", expiredCount);
                
                logger.info("✅ 每日打卡事项刷新任务完成 - 清理: {}, 生成: {}, 过期: {}", cleanedCount, generatedCount, expiredCount);
            }
            
        } catch (Exception e) {
            logger.error("每日打卡事项刷新任务执行失败", e);
        }
    }
    
    /**
     * 手动触发今日打卡事项刷新
     * 提供给管理员手动执行的接口
     */
    public String manualRefreshTodayItems() {
        try {
            logger.info("🔧 手动执行每日打卡事项刷新任务...");
            
            Date today = new Date();
            
            // 1. 清理今日的排期数据（避免重复）
            int cleanedCount = dailyCheckinService.cleanDailyItems(today);
            logger.info("🧹 清理今日数据: {} 条", cleanedCount);
            
            // 2. 生成今日的打卡事项（全新生成）
            int generatedCount = dailyCheckinService.generateDailyCheckinItems(today);
            logger.info("➕ 生成新事项: {} 条", generatedCount);
            
            // 3. 更新过期状态
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(today);
            calendar.add(Calendar.DAY_OF_MONTH, -2);
            Date beforeYesterday = calendar.getTime();
            int expiredCount = dailyCheckinService.updateExpiredStatus(beforeYesterday);
            logger.info("⏰ 标记过期事项: {} 条", expiredCount);
            
            String result = String.format("✅ 刷新完成 - 清理: %d, 生成: %d, 过期: %d", cleanedCount, generatedCount, expiredCount);
            logger.info("手动刷新任务完成: {}", result);
            
            return result;
            
        } catch (Exception e) {
            logger.error("手动刷新任务执行失败", e);
            return "刷新失败: " + e.getMessage();
        }
    }
}
