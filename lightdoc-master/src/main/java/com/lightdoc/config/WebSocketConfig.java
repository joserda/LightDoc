package com.lightdoc.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.server.standard.ServerEndpointExporter;

/**
 * WebSocket配置类
 *
 * @author lightdoc
 * @since 2025-11-28
 */
@Configuration
public class WebSocketConfig {

    /**
     * ServerEndpointExporter用于扫描和注册所有带有@ServerEndpoint注解的WebSocket端点
     */
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }
}