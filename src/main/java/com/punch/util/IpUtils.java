package com.punch.util;

import javax.servlet.http.HttpServletRequest;

/**
 * IP地址获取工具类
 */
public class IpUtils {
    
    private static final String UNKNOWN = "unknown";
    private static final String LOCALHOST_IPV4 = "127.0.0.1";
    private static final String LOCALHOST_IPV6 = "0:0:0:0:0:0:0:1";
    
    /**
     * 获取客户端真实IP地址
     * 
     * @param request HttpServletRequest对象
     * @return 客户端IP地址
     */
    public static String getClientIpAddress(HttpServletRequest request) {
        if (request == null) {
            return UNKNOWN;
        }
        
        // 1. 检查X-Forwarded-For头（经过代理服务器时使用）
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && ip.length() != 0 && !UNKNOWN.equalsIgnoreCase(ip)) {
            // 多次反向代理后会有多个IP值，第一个IP才是真实IP
            if (ip.indexOf(",") != -1) {
                ip = ip.split(",")[0];
            }
        }
        
        // 2. 检查X-Real-IP头（Nginx代理常用）
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("X-Real-IP");
        }
        
        // 3. 检查Proxy-Client-IP头（Apache服务器代理）
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        
        // 4. 检查WL-Proxy-Client-IP头（WebLogic服务器代理）
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        
        // 5. 检查HTTP_CLIENT_IP头
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        
        // 6. 检查HTTP_X_FORWARDED_FOR头
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        
        // 7. 最后使用getRemoteAddr()方法获取
        if (ip == null || ip.length() == 0 || UNKNOWN.equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        
        // 8. 处理本地回环地址
        if (LOCALHOST_IPV6.equals(ip)) {
            ip = LOCALHOST_IPV4;
        }
        
        return ip != null ? ip.trim() : UNKNOWN;
    }
    
    /**
     * 获取客户端真实IP地址（带本地IP检测）
     * 在本地开发环境中，尝试获取本机的局域网IP
     * 
     * @param request HttpServletRequest对象
     * @return 客户端IP地址
     */
    public static String getClientIpAddressWithLocalDetection(HttpServletRequest request) {
        String ip = getClientIpAddress(request);
        
        // 如果是本地回环地址，尝试获取本机局域网IP
        if (LOCALHOST_IPV4.equals(ip) || LOCALHOST_IPV6.equals(ip)) {
            try {
                java.net.InetAddress addr = java.net.InetAddress.getLocalHost();
                String localIp = addr.getHostAddress();
                if (localIp != null && !LOCALHOST_IPV4.equals(localIp)) {
                    return localIp + " (本机IP)";
                }
            } catch (Exception e) {
                // 获取失败，使用原IP
            }
        }
        
        return ip;
    }
}
