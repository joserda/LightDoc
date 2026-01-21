package com.lightdoc.handler;

import com.alibaba.fastjson2.JSON;
import com.lightdoc.dto.CollaborationMessageDTO;
import com.lightdoc.entity.User;
import com.lightdoc.manager.CollaborationSessionManager;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.DocumentService;
import com.lightdoc.utils.JwtUtil;
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.support.SpringBeanAutowiringSupport;

import java.io.IOException;

/**
 * 协同编辑WebSocket处理器
 * 
 * 职责：
 * 1. 处理WebSocket连接的建立、关闭和消息
 * 2. 验证用户权限和JWT token
 * 3. 委托会话管理器处理具体的业务逻辑
 * 4. 简化的消息转发，不处理CRDT逻辑
 * 
 * 注意：Yjs的CRDT合并由前端处理，后端只负责消息转发和权限验证
 *
 * @author lightdoc
 * @since 2025-11-28
 */
@Slf4j
@Component
@ServerEndpoint("/ws/collaborate/{documentId}")
public class CollaborativeEditorHandler {

    // 由于WebSocket是静态创建的，需要手动注入Spring Bean
    private static DocumentService documentService;
    private static JwtUtil jwtUtil;
    private static UserMapper userMapper;
    private static CollaborationSessionManager sessionManager;

    @Autowired
    public void setDocumentService(DocumentService documentService) {
        CollaborativeEditorHandler.documentService = documentService;
    }
    
    @Autowired
    public void setSessionManager(CollaborationSessionManager sessionManager) {
        CollaborativeEditorHandler.sessionManager = sessionManager;
    }

    @Autowired
    public void setJwtUtil(JwtUtil jwtUtil) {
        CollaborativeEditorHandler.jwtUtil = jwtUtil;
    }

    @Autowired
    public void setUserMapper(UserMapper userMapper) {
        CollaborativeEditorHandler.userMapper = userMapper;
    }

    /**
     * 连接建立成功调用的方法
     */
    @OnOpen
    public void onOpen(Session session, @PathParam("documentId") Long documentId) {
        // 手动注入Spring Bean（WebSocket是静态创建的）
        SpringBeanAutowiringSupport.processInjectionBasedOnCurrentContext(this);

        // 从查询字符串中提取参数
        String queryString = session.getQueryString();
        Long userId = null;
        String token = null;
        
        if (queryString != null) {
            String[] params = queryString.split("&");
            for (String param : params) {
                String[] keyValue = param.split("=", 2);
                if (keyValue.length == 2) {
                    try {
                        String key = keyValue[0];
                        String value = java.net.URLDecoder.decode(keyValue[1], java.nio.charset.StandardCharsets.UTF_8);
                        
                        if ("userId".equals(key)) {
                            try {
                                userId = Long.valueOf(value);
                            } catch (NumberFormatException e) {
                                log.error("解析userId失败: {}", value);
                            }
                        } else if ("token".equals(key)) {
                            token = value;
                        }
                    } catch (Exception e) {
                        log.error("URL解码失败: {}", param, e);
                    }
                }
            }
        }

        try {
            log.info("用户 {} 尝试连接到文档 {} 的协同编辑", userId, documentId);

            // 使用会话管理器创建会话
            if (sessionManager != null) {
                boolean success = sessionManager.createSession(session, documentId, userId, token);
                if (!success) {
                    session.close();
                    log.warn("创建会话失败: documentId={}, userId={}", documentId, userId);
                    return;
                }
                log.info("用户 {} 成功连接到文档 {} 的协同编辑", userId, documentId);
            } else {
                log.error("会话管理器未初始化");
                session.close();
            }

        } catch (Exception e) {
            log.error("用户 {} 连接文档 {} 失败: {}", userId, documentId, e.getMessage(), e);
            try {
                session.close();
            } catch (IOException closeException) {
                log.error("关闭会话失败: {}", closeException.getMessage());
            }
        }
    }

    /**
     * 连接关闭调用的方法
     */
    @OnClose
    public void onClose(Session session, @PathParam("documentId") Long documentId) {
        try {
            log.info("用户从文档 {} 的协同编辑断开连接", documentId);

            // 使用会话管理器关闭会话
            if (sessionManager != null) {
                sessionManager.closeSession(session);
            } else {
                log.error("会话管理器未初始化");
            }

        } catch (Exception e) {
            log.error("用户从文档 {} 断开连接时发生异常: {}", documentId, e.getMessage(), e);
        }
    }

    /**
     * 收到客户端二进制消息时调用的方法
     * 用于处理 y-websocket 的二进制协议消息
     */
    @OnMessage
    public void onBinaryMessage(byte[] message, Session session, @PathParam("documentId") Long documentId) {
        try {
            log.debug("收到二进制消息: documentId={}, length={}", documentId, message.length);

            // 使用会话管理器处理二进制消息
            if (sessionManager != null) {
                sessionManager.handleBinarySessionMessage(session, message);
            } else {
                log.error("会话管理器未初始化");
                session.close();
            }

        } catch (Exception e) {
            log.error("处理二进制消息失败: documentId={}, error={}", documentId, e.getMessage(), e);
            try {
                session.close();
            } catch (IOException closeException) {
                log.error("关闭会话失败: {}", closeException.getMessage());
            }
        }
    }

    /**
     * 收到客户端文本消息时调用的方法
     * 用于处理自定义的文本格式消息
     */
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("documentId") Long documentId) {
        try {
            log.debug("收到文本消息: documentId={}, message={}", documentId, message);

            // 使用会话管理器处理消息
            if (sessionManager != null) {
                sessionManager.handleSessionMessage(session, message);
            } else {
                log.error("会话管理器未初始化");
                
                // 发送错误消息给客户端
                CollaborationMessageDTO errorMessage = new CollaborationMessageDTO();
                errorMessage.setType("error");
                errorMessage.setDocumentId(documentId);
                errorMessage.setTimestamp(System.currentTimeMillis());
                errorMessage.setData(java.util.Collections.singletonMap("message", "会话管理器未初始化"));
                
                sendMessageToSession(session, errorMessage);
            }

        } catch (Exception e) {
            log.error("处理消息失败: documentId={}, error={}", documentId, e.getMessage(), e);

            // 发送错误消息给客户端
            CollaborationMessageDTO errorMessage = new CollaborationMessageDTO();
            errorMessage.setType("error");
            errorMessage.setDocumentId(documentId);
            errorMessage.setTimestamp(System.currentTimeMillis());
            errorMessage.setData(java.util.Collections.singletonMap("message", "消息处理失败: " + e.getMessage()));

            sendMessageToSession(session, errorMessage);
        }
    }

    /**
     * 发生错误时调用的方法
     */
    @OnError
    public void onError(Session session, Throwable error, @PathParam("documentId") Long documentId) {
        log.error("文档 {} 协同编辑发生错误: {}", documentId, error.getMessage(), error);

        try {
            // 发送错误消息给客户端
            CollaborationMessageDTO errorMessage = new CollaborationMessageDTO();
            errorMessage.setType("error");
            errorMessage.setDocumentId(documentId);
            errorMessage.setTimestamp(System.currentTimeMillis());
            errorMessage.setData(java.util.Collections.singletonMap("message", "连接发生错误: " + error.getMessage()));

            sendMessageToSession(session, errorMessage);
        } catch (Exception e) {
            log.error("发送错误消息失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 向特定会话发送消息
     */
    private void sendMessageToSession(Session session, CollaborationMessageDTO message) {
        if (session != null && session.isOpen()) {
            try {
                String messageStr = JSON.toJSONString(message);
                session.getBasicRemote().sendText(messageStr);
            } catch (IOException e) {
                log.error("向会话发送消息失败: {}", e.getMessage(), e);
            }
        }
    }
}
