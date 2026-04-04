package com.punch.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * 打卡系统配置属性
 */
@Component
@ConfigurationProperties(prefix = "punch")
public class PunchProperties {
    
    private DailyRefresh dailyRefresh = new DailyRefresh();
    
    public DailyRefresh getDailyRefresh() {
        return dailyRefresh;
    }
    
    public void setDailyRefresh(DailyRefresh dailyRefresh) {
        this.dailyRefresh = dailyRefresh;
    }
    
    /**
     * 每日刷新配置
     */
    public static class DailyRefresh {
        /**
         * 刷新时间，格式：HH:mm:ss
         */
        private String time = "06:00:00";
        
        /**
         * 是否启用定时刷新
         */
        private boolean enabled = true;
        
        /**
         * 时区
         */
        private String timezone = "Asia/Shanghai";
        
        public String getTime() {
            return time;
        }
        
        public void setTime(String time) {
            this.time = time;
        }
        
        public boolean isEnabled() {
            return enabled;
        }
        
        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }
        
        public String getTimezone() {
            return timezone;
        }
        
        public void setTimezone(String timezone) {
            this.timezone = timezone;
        }
    }
}
