package com.lightdoc.handler;

import com.alibaba.fastjson2.JSON;
import com.lightdoc.dto.CollaborationMessageDTO;
import com.lightdoc.service.CollaborationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 协同编辑消息处理器
 * 
 * 职责：
 * 1. 消息的解析和验证
 * 2. 不同类型消息的路由和处理
 * 3. 响应消息的构造和发送
 * 4. 异常情况的处理和错误响应
 * 
 * 支持的消息类型：
 * - yjs_update: Yjs文档更新（只验证权限，不处理CRDT）
 * - cursor_update: 光标位置更新（只记录日志）
 * - lock_document/lock_request: 获取编辑锁请求
 * - unlock_document/unlock_request: 释放编辑锁请求
 * - ping: 连接保活
 * - get_document_state: 获取文档状态（由前端处理）
 * 
 * 注意：Yjs的CRDT合并由前端处理，后端只负责权限验证和消息转发
 *
 * @author lightdoc
 * @since 2025-12-29
 */
@Slf4j
@Component
public class CollaborationMessageHandler {

    // ==================== 依赖注入 ====================

    @Autowired
    private CollaborationService collaborationService;

    @Autowired
    private com.lightdoc.service.DocumentService documentService;

    // ==================== 消息处理方法 ====================

    /**
     * 处理协同编辑消息
     *
     * @param message 接收到的消息
     * @param sessionInfo 会话信息
     * @return 处理结果和响应消息
     */
    public MessageHandlerResult handleMessage(String message, SessionInfo sessionInfo) {
        try {
            log.debug("处理协同编辑消息: sessionId={}, userId={}, message={}",
                    sessionInfo.getSessionId(), sessionInfo.getUserId(), message);

            // 1. 解析消息
            CollaborationMessageDTO messageDTO = parseMessage(message, sessionInfo);
            if (messageDTO == null) {
                return createErrorResult(sessionInfo, "消息格式无效");
            }

            // 2. 验证消息
            ValidationResult validation = validateMessage(messageDTO, sessionInfo);
            if (!validation.isValid()) {
                return createErrorResult(sessionInfo, validation.getErrorMessage());
            }

            // 3. 根据消息类型处理
            MessageHandlerResult result = processMessageByType(messageDTO, sessionInfo);

            log.debug("消息处理完成: sessionId={}, type={}, success={}",
                    sessionInfo.getSessionId(), messageDTO.getType(), result.isSuccess());

            return result;

        } catch (Exception e) {
            log.error("处理协同编辑消息异常: sessionId={}, error={}",
                    sessionInfo.getSessionId(), e.getMessage(), e);
            return createErrorResult(sessionInfo, "消息处理异常: " + e.getMessage());
        }
    }

    // ==================== 私有方法 ====================

    /**
     * 解析消息
     *
     * @param message 消息字符串
     * @param sessionInfo 会话信息
     * @return 解析后的消息对象
     */
    private CollaborationMessageDTO parseMessage(String message, SessionInfo sessionInfo) {
        try {
            CollaborationMessageDTO messageDTO = JSON.parseObject(message, CollaborationMessageDTO.class);

            // 设置会话信息
            messageDTO.setUserId(sessionInfo.getUserId());
            messageDTO.setDocumentId(sessionInfo.getDocumentId());
            messageDTO.setTimestamp(System.currentTimeMillis());

            return messageDTO;

        } catch (Exception e) {
            log.error("解析消息失败: sessionId={}, message={}, error={}",
                    sessionInfo.getSessionId(), message, e.getMessage());
            return null;
        }
    }

    /**
     * 验证消息
     *
     * @param message 消息对象
     * @param sessionInfo 会话信息
     * @return 验证结果
     */
    private ValidationResult validateMessage(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            // 1. 验证基本字段
            if (message.getType() == null || message.getType().isEmpty()) {
                return ValidationResult.invalid("消息类型不能为空");
            }

            if (message.getDocumentId() == null || message.getUserId() == null) {
                return ValidationResult.invalid("文档ID或用户ID不能为空");
            }

            // 2. 验证会话一致性
            if (!message.getDocumentId().equals(sessionInfo.getDocumentId()) ||
                !message.getUserId().equals(sessionInfo.getUserId())) {
                return ValidationResult.invalid("消息与会话信息不匹配");
            }

            // 3. 验证消息类型
            if (!isValidMessageType(message.getType())) {
                return ValidationResult.invalid("不支持的消息类型: " + message.getType());
            }

            return ValidationResult.valid();

        } catch (Exception e) {
            log.error("验证消息异常: error={}", e.getMessage(), e);
            return ValidationResult.invalid("消息验证异常: " + e.getMessage());
        }
    }

    /**
     * 根据消息类型处理
     *
     * @param message 消息对象
     * @param sessionInfo 会话信息
     * @return 处理结果
     */
    private MessageHandlerResult processMessageByType(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            String messageType = message.getType();

            switch (messageType) {
                case "sync":
                    // y-websocket发送的同步消息（Yjs更新）
                    return handleSyncMessage(message, sessionInfo);

                case "yjs_update":
                    // 兼容旧格式的Yjs更新消息
                    return handleYjsUpdate(message, sessionInfo);

                case "cursor_update":
                    return handleCursorUpdate(message, sessionInfo);

                case "lock_document":
                case "lock_request":
                    return handleLockRequest(message, sessionInfo);

                case "unlock_document":
                case "unlock_request":
                    return handleUnlockRequest(message, sessionInfo);

                case "ping":
                    return handlePing(message, sessionInfo);

                case "get_document_state":
                    return handleGetDocumentState(message, sessionInfo);

                default:
                    return createErrorResult(sessionInfo, "不支持的消息类型: " + messageType);
            }

        } catch (Exception e) {
            log.error("处理消息异常: type={}, error={}", message.getType(), e.getMessage(), e);
            return createErrorResult(sessionInfo, "消息处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理Yjs更新消息（简化版，只验证权限）
     */
    private MessageHandlerResult handleYjsUpdate(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            // 验证更新数据
            String updateBase64 = (String) message.getData().get("update");
            if (updateBase64 == null || updateBase64.isEmpty()) {
                return createErrorResult(sessionInfo, "Yjs更新数据不能为空");
            }

            // 处理更新（只验证权限，不处理CRDT）
            boolean success = collaborationService.handleCollaborationMessage(message);

            if (success) {
                // 构造广播消息
                CollaborationMessageDTO broadcastMessage = new CollaborationMessageDTO();
                broadcastMessage.setType("yjs_update");
                broadcastMessage.setDocumentId(message.getDocumentId());
                broadcastMessage.setUserId(message.getUserId());
                broadcastMessage.setData(message.getData());
                broadcastMessage.setTimestamp(System.currentTimeMillis());

                return MessageHandlerResult.success(broadcastMessage, true);
            } else {
                return createErrorResult(sessionInfo, "Yjs更新处理失败");
            }

        } catch (Exception e) {
            log.error("处理Yjs更新失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "Yjs更新处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理sync消息（y-websocket发送的Yjs同步消息）
     * 
     * 注意：y-websocket发送的sync消息格式：
     * - type: 'sync'
     * - data: Uint8Array (Yjs更新数据，可能是二进制或Base64编码)
     * 
     * 我们需要：
     * 1. 验证权限
     * 2. 直接转发消息给其他用户
     * 3. 不做任何CRDT处理
     */
    private MessageHandlerResult handleSyncMessage(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            Long documentId = message.getDocumentId();
            Long userId = message.getUserId();

            log.debug("收到sync消息: documentId={}, userId={}", documentId, userId);

            // 1. 验证权限
            if (!collaborationService.hasPermission(documentId, userId, 2)) { // 需要写权限
                log.warn("用户没有编辑权限: documentId={}, userId={}", documentId, userId);
                return createErrorResult(sessionInfo, "没有编辑权限");
            }

            // 2. 检查文档锁
            CollaborationService.LockStatus lockStatus = collaborationService.checkDocumentLock(documentId, userId);
            if (lockStatus.isLocked() && !lockStatus.isOwner()) {
                log.warn(" documentId={}, lockUserId={}, requestUserId={}", 
                        documentId, lockStatus.getLockedBy(), userId);
                return createErrorResult(sessionInfo, "文档被锁定，无法编辑");
            }

            // 3. 直接转发消息给其他用户（不做任何处理）
            // y-websocket的消息格式已经是正确的，直接转发即可
            CollaborationMessageDTO broadcastMessage = new CollaborationMessageDTO();
            broadcastMessage.setType("sync");
            broadcastMessage.setDocumentId(documentId);
            broadcastMessage.setUserId(userId);
            broadcastMessage.setData(message.getData());
            broadcastMessage.setTimestamp(System.currentTimeMillis());

            log.debug("转发sync消息给其他用户: documentId={}, userId={}", documentId, userId);

            return MessageHandlerResult.success(broadcastMessage, true);

        } catch (Exception e) {
            log.error("处理sync消息失败: message={}, error={}", 
                    message, e.getMessage(), e);
            return createErrorResult(sessionInfo, "sync消息处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理光标更新消息（简化版，只记录日志）
     */
    private MessageHandlerResult handleCursorUpdate(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            // 验证光标位置
            Integer position = (Integer) message.getData().get("position");
            if (position == null || position < 0) {
                return createErrorResult(sessionInfo, "光标位置无效");
            }

            // 处理光标更新（只记录日志）
            String selection = (String) message.getData().get("selection");
            collaborationService.handleCursorUpdate(
                message.getDocumentId(),
                message.getUserId(),
                position,
                selection
            );

            // 构造广播消息
            CollaborationMessageDTO broadcastMessage = new CollaborationMessageDTO();
            broadcastMessage.setType("cursor_update");
            broadcastMessage.setDocumentId(message.getDocumentId());
            broadcastMessage.setUserId(message.getUserId());
            broadcastMessage.setData(Map.of(
                "position", position,
                "selection", selection != null ? selection : ""
            ));
            broadcastMessage.setTimestamp(System.currentTimeMillis());

            return MessageHandlerResult.success(broadcastMessage, true);

        } catch (Exception e) {
            log.error("处理光标更新失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "光标更新处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理锁请求消息
     */
    private MessageHandlerResult handleLockRequest(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            boolean success = collaborationService.acquireEditLock(
                message.getDocumentId(),
                message.getUserId()
            );

            CollaborationMessageDTO response = new CollaborationMessageDTO();
            response.setType("lock_response");
            response.setDocumentId(message.getDocumentId());
            response.setUserId(message.getUserId());
            response.setData(Map.of("success", success));
            response.setTimestamp(System.currentTimeMillis());

            return MessageHandlerResult.success(response, false);

        } catch (Exception e) {
            log.error("处理锁请求失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "锁请求处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理解锁请求消息
     */
    private MessageHandlerResult handleUnlockRequest(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            boolean success = collaborationService.releaseEditLock(
                message.getDocumentId(),
                message.getUserId()
            );

            CollaborationMessageDTO response = new CollaborationMessageDTO();
            response.setType("unlock_response");
            response.setDocumentId(message.getDocumentId());
            response.setUserId(message.getUserId());
            response.setData(Map.of("success", success));
            response.setTimestamp(System.currentTimeMillis());

            return MessageHandlerResult.success(response, false);

        } catch (Exception e) {
            log.error("处理解锁请求失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "解锁请求处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理ping消息
     */
    private MessageHandlerResult handlePing(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            CollaborationMessageDTO response = new CollaborationMessageDTO();
            response.setType("pong");
            response.setDocumentId(message.getDocumentId());
            response.setUserId(message.getUserId());
            response.setData(Map.of("timestamp", System.currentTimeMillis()));
            response.setTimestamp(System.currentTimeMillis());

            return MessageHandlerResult.success(response, false);

        } catch (Exception e) {
            log.error("处理ping消息失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "ping消息处理异常: " + e.getMessage());
        }
    }

    /**
     * 处理获取文档状态消息
     */
    private MessageHandlerResult handleGetDocumentState(CollaborationMessageDTO message, SessionInfo sessionInfo) {
        try {
            // 获取文档Yjs状态（由前端管理，后端不再提供）
            byte[] state = collaborationService.getDocumentYjsState(message.getDocumentId());

            CollaborationMessageDTO response = new CollaborationMessageDTO();
            response.setType("get_document_state");
            response.setDocumentId(message.getDocumentId());
            response.setUserId(message.getUserId());

            if (state != null) {
                String stateBase64 = java.util.Base64.getEncoder().encodeToString(state);
                response.setData(Map.of("state", stateBase64, "size", state.length));
            } else {
                // 返回空状态，前端会使用默认空文档
                response.setData(Map.of("state", "", "size", 0));
            }

            response.setTimestamp(System.currentTimeMillis());

            return MessageHandlerResult.success(response, false);

        } catch (Exception e) {
            log.error("处理获取状态消息失败: error={}", e.getMessage(), e);
            return createErrorResult(sessionInfo, "获取状态处理异常: " + e.getMessage());
        }
    }

    /**
     * 验证消息类型是否有效
     */
    private boolean isValidMessageType(String messageType) {
        return messageType != null && (
            "sync".equals(messageType) ||           // y-websocket发送的同步消息
            "yjs_update".equals(messageType) ||       // 兼容旧格式
            "cursor_update".equals(messageType) ||
            "lock_document".equals(messageType) ||
            "lock_request".equals(messageType) ||
            "unlock_document".equals(messageType) ||
            "unlock_request".equals(messageType) ||
            "ping".equals(messageType) ||
            "get_document_state".equals(messageType)
        );
    }

    /**
     * 创建错误结果
     */
    private MessageHandlerResult createErrorResult(SessionInfo sessionInfo, String errorMessage) {
        CollaborationMessageDTO errorResponse = new CollaborationMessageDTO();
        errorResponse.setType("error");
        errorResponse.setDocumentId(sessionInfo.getDocumentId());
        errorResponse.setUserId(sessionInfo.getUserId());
        errorResponse.setData(Map.of("message", errorMessage));
        errorResponse.setTimestamp(System.currentTimeMillis());

        return MessageHandlerResult.error(errorResponse, errorMessage);
    }

    // ==================== 内部类 ====================

    /**
     * 消息处理结果
     */
    public static class MessageHandlerResult {
        private final boolean success;
        private final CollaborationMessageDTO response;
        private final boolean shouldBroadcast;
        private final String errorMessage;

        private MessageHandlerResult(boolean success, CollaborationMessageDTO response,
                                   boolean shouldBroadcast, String errorMessage) {
            this.success = success;
            this.response = response;
            this.shouldBroadcast = shouldBroadcast;
            this.errorMessage = errorMessage;
        }

        public static MessageHandlerResult success(CollaborationMessageDTO response, boolean shouldBroadcast) {
            return new MessageHandlerResult(true, response, shouldBroadcast, null);
        }

        public static MessageHandlerResult error(CollaborationMessageDTO response, String errorMessage) {
            return new MessageHandlerResult(false, response, false, errorMessage);
        }

        public boolean isSuccess() { return success; }
        public CollaborationMessageDTO getResponse() { return response; }
        public boolean shouldBroadcast() { return shouldBroadcast; }
        public String getErrorMessage() { return errorMessage; }
    }

    /**
     * 会话信息
     */
    public static class SessionInfo {
        private final String sessionId;
        private final Long documentId;
        private final Long userId;
        private final String token;
        private final java.time.LocalDateTime connectTime;

        public SessionInfo(String sessionId, Long documentId, Long userId, String token) {
            this.sessionId = sessionId;
            this.documentId = documentId;
            this.userId = userId;
            this.token = token;
            this.connectTime = java.time.LocalDateTime.now();
        }

        public String getSessionId() { return sessionId; }
        public Long getDocumentId() { return documentId; }
        public Long getUserId() { return userId; }
        public String getToken() { return token; }
        public java.time.LocalDateTime getConnectTime() { return connectTime; }
    }

    /**
     * 验证结果
     */
    private static class ValidationResult {
        private final boolean valid;
        private final String errorMessage;

        private ValidationResult(boolean valid, String errorMessage) {
            this.valid = valid;
            this.errorMessage = errorMessage;
        }

        public static ValidationResult valid() {
            return new ValidationResult(true, null);
        }

        public static ValidationResult invalid(String errorMessage) {
            return new ValidationResult(false, errorMessage);
        }

        public boolean isValid() { return valid; }
        public String getErrorMessage() { return errorMessage; }
    }
}