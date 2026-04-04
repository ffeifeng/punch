package com.punch.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewResolverRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    @Override
    public void configureViewResolvers(ViewResolverRegistry registry) {
        registry.jsp("/WEB-INF/jsp/", ".jsp");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 静态资源映射
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/", "/static/")
                .setCachePeriod(3600);
        
        // 确保不被拦截器拦截
        registry.addResourceHandler("/**")
                .addResourceLocations("classpath:/static/", "/static/")
                .setCachePeriod(3600);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoginInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/", "/index", "/login", "/register", "/static/**", "/css/**", "/js/**", "/images/**", 
                                   "/WEB-INF/jsp/login.jsp", "/WEB-INF/jsp/register.jsp",
                                   "/admin/testRefresh", "/admin/debugTodayItems", "/mobile/login", "/mobile/qrcode",
                                   "/captcha/**", "/test", "/test-login", "/test-jsp",
                                   "*.css", "*.js", "*.png", "*.jpg", "*.gif", "*.ico");
    }
}
