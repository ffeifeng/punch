package com.punch.util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Random;

/**
 * 验证码生成工具类
 */
public class CaptchaUtils {
    
    private static final String CHARS = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";
    private static final int WIDTH = 120;
    private static final int HEIGHT = 40;
    private static final int CODE_LENGTH = 4;
    
    /**
     * 生成验证码图片
     * @return CaptchaResult 包含验证码文本和图片字节数组
     */
    public static CaptchaResult generateCaptcha() {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        
        // 设置抗锯齿
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        // 填充背景
        g.setColor(new Color(240, 248, 255));
        g.fillRect(0, 0, WIDTH, HEIGHT);
        
        // 生成验证码文本
        StringBuilder code = new StringBuilder();
        Random random = new Random();
        
        // 绘制验证码字符
        for (int i = 0; i < CODE_LENGTH; i++) {
            char c = CHARS.charAt(random.nextInt(CHARS.length()));
            code.append(c);
            
            // 设置字体和颜色
            g.setFont(new Font("Arial", Font.BOLD, 20 + random.nextInt(8)));
            g.setColor(new Color(random.nextInt(150), random.nextInt(150), random.nextInt(150)));
            
            // 字符位置
            int x = 20 + i * 20 + random.nextInt(10);
            int y = 25 + random.nextInt(10);
            
            // 字符旋转角度
            double angle = (random.nextDouble() - 0.5) * 0.4;
            g.rotate(angle, x, y);
            g.drawString(String.valueOf(c), x, y);
            g.rotate(-angle, x, y);
        }
        
        // 绘制干扰线
        for (int i = 0; i < 6; i++) {
            g.setColor(new Color(random.nextInt(200), random.nextInt(200), random.nextInt(200)));
            g.drawLine(random.nextInt(WIDTH), random.nextInt(HEIGHT), 
                      random.nextInt(WIDTH), random.nextInt(HEIGHT));
        }
        
        // 绘制干扰点
        for (int i = 0; i < 30; i++) {
            g.setColor(new Color(random.nextInt(255), random.nextInt(255), random.nextInt(255)));
            g.fillOval(random.nextInt(WIDTH), random.nextInt(HEIGHT), 2, 2);
        }
        
        g.dispose();
        
        // 转换为字节数组
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            ImageIO.write(image, "png", baos);
        } catch (IOException e) {
            throw new RuntimeException("生成验证码图片失败", e);
        }
        
        return new CaptchaResult(code.toString(), baos.toByteArray());
    }
    
    /**
     * 验证码结果类
     */
    public static class CaptchaResult {
        private final String code;
        private final byte[] imageBytes;
        
        public CaptchaResult(String code, byte[] imageBytes) {
            this.code = code;
            this.imageBytes = imageBytes;
        }
        
        public String getCode() {
            return code;
        }
        
        public byte[] getImageBytes() {
            return imageBytes;
        }
    }
}
