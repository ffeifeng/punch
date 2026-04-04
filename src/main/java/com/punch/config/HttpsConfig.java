package com.punch.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.apache.catalina.connector.Connector;
import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.servlet.server.ServletWebServerFactory;

/**
 * HTTPS配置类
 * 支持反向代理和安全头配置
 */
@Configuration
public class HttpsConfig implements WebMvcConfigurer {
    
    /**
     * 配置Tomcat以支持反向代理
     */
    @Bean
    public ServletWebServerFactory servletContainer() {
        TomcatServletWebServerFactory tomcat = new TomcatServletWebServerFactory();
        
        // 添加HTTP连接器（用于内部通信）
        tomcat.addAdditionalTomcatConnectors(createHttpConnector());
        
        return tomcat;
    }
    
    /**
     * 创建HTTP连接器
     */
    private Connector createHttpConnector() {
        Connector connector = new Connector(TomcatServletWebServerFactory.DEFAULT_PROTOCOL);
        connector.setScheme("http");
        connector.setPort(8080);
        connector.setSecure(false);
        
        // 支持反向代理
        connector.setProperty("remoteIpHeader", "x-forwarded-for");
        connector.setProperty("protocolHeader", "x-forwarded-proto");
        connector.setProperty("httpsServerPort", "443");
        
        return connector;
    }
}
