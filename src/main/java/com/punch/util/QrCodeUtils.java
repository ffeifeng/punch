package com.punch.util;

import java.security.SecureRandom;

/**
 * 二维码工具类
 */
public class QrCodeUtils {
    
    private static final String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();
    
    /**
     * 生成学生二维码标识
     * 格式：STU_随机字符串
     */
    public static String generateStudentQrCode() {
        StringBuilder sb = new StringBuilder("STU_");
        
        // 添加8位随机字符
        for (int i = 0; i < 8; i++) {
            sb.append(CHARACTERS.charAt(RANDOM.nextInt(CHARACTERS.length())));
        }
        
        // 添加时间戳后4位确保唯一性
        String timestamp = String.valueOf(System.currentTimeMillis());
        sb.append("_").append(timestamp.substring(timestamp.length() - 4));
        
        return sb.toString();
    }
    
    /**
     * 生成二维码URL（登录页面）
     * @param qrCode 二维码标识
     * @param baseUrl 基础URL（如：http://localhost:8081）
     * @return 完整的二维码URL
     */
    public static String generateQrCodeUrl(String qrCode, String baseUrl) {
        return baseUrl + "/mobile/login?qr=" + qrCode;
    }
    
    /**
     * 生成二维码预览URL（显示二维码图片的页面）
     * @param qrCode 二维码标识
     * @param baseUrl 基础URL（如：http://localhost:8081）
     * @return 完整的二维码预览URL
     */
    public static String generateQrCodePreviewUrl(String qrCode, String baseUrl) {
        return baseUrl + "/mobile/qrcode?qr=" + qrCode;
    }
    
    /**
     * 验证二维码格式
     */
    public static boolean isValidStudentQrCode(String qrCode) {
        return qrCode != null && qrCode.startsWith("STU_") && qrCode.length() >= 15;
    }
}
