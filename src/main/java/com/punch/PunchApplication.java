package com.punch;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
@MapperScan("com.punch.mapper")
public class PunchApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        SpringApplication.run(PunchApplication.class, args);
    }
}
