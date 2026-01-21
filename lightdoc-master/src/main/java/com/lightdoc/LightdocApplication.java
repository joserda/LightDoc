package com.lightdoc;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.lightdoc.mapper")
public class LightdocApplication {
    public static void main(String[] args) {
        SpringApplication.run(LightdocApplication.class, args);
    }
}