package com.lightdoc.manager;

import com.alibaba.fastjson2.JSON;
import com.lightdoc.dto.CollaborationMessageDTO;
import com.lightdoc.handler.CollaborationMessageHandler;
import com.lightdoc.service.CollaborationService;
import com.lightdoc.utils.YjsDocumentManager;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jakarta.websocket.*;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 协同编辑会话管理器
 * 
 * 负责管理WebSocket连接会话，提供以下功能：
 * 1. WebSocket会话的创建、维护和清理
 * 2. 用户连接的权限验证和状态管理
 * 3. 消息的广播和路由
 * 4. 在线用户的统计和管理
 * 5. 连接健康检查和自动重连
 * 6. 会话数据的持久化和恢复
 * 
 * 主要特性：
 * - 线程安全的会话管理
 * - 自动清理过期连接
 * - 支持集群部署的会话同步
 * - 完善的异常处理和日志记录
 * 
 * @author lightdoc
 * @since 2025-12-29
 */
@Slf4j
@Component
public class CollaborationSessionManager {
    
    // ==================== 配置参数 ====================
    
    /** 最大连接数 */
    private static final int MAX_CONNECTIONS = 1000;
    
    /** 最大每文档连接数 */
    private static final int MAX_CONNECTIONS_PER_DOCUMENT = 50;
    
    /** 会话超时时间（分钟） */
    private static final int SESSION_TIMEOUT_MINUTES = 30;
    
    /** 心跳间隔（秒） */
    private static final int HEARTBEAT_INTERVAL_SECONDS = 30;

    // ==================== Yjs 协议常量 ====================
    private static final int MESSAGE_SYNC = 0;
    private static final int MESSAGE_AWARENESS = 1;
    
    private static final int SYNC_STEP_1 = 0;
    private static final int SYNC_STEP_2 = 1;
    private static final int SYNC_UPDATE = 2;
    
    // ==================== 依赖注入 ====================
    
    @Autowired
    private CollaborationService collaborationService;
    
    @Autowired
    private CollaborationMessageHandler messageHandler;

    @Autowired
    private YjsDocumentManager yjsDocumentManager;
    
    // ==================== 会话存储 ====================
    
    /** 文档会话映射：documentId -> sessionId -> Session */
    private final ConcurrentHashMap<Long, ConcurrentHashMap<String, Session>> documentSessions = new ConcurrentHashMap<>();
    
    /** 用户会话映射：userId -> sessionId -> Session */
    private final ConcurrentHashMap<Long, ConcurrentHashMap<String, Session>> userSessions = new ConcurrentHashMap<>();
    
    /** 会话信息映射：sessionId -> SessionInfo */
    private final ConcurrentHashMap<String, SessionInfo> sessionInfos = new ConcurrentHashMap<>();
    
    /** 会话最后活动时间：sessionId -> timestamp */
    private final ConcurrentHashMap<String, Long> sessionLastActivity = new ConcurrentHashMap<>();
    
    // ==================== 定时任务 ====================
    
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);
    
    /**
     * 初始化定时任务
     */
    public CollaborationSessionManager() {
        // 会话清理任务（每5分钟执行一次）
        scheduler.scheduleAtFixedRate(this::cleanupExpiredSessions, 5, 5, TimeUnit.MINUTES);
        
        // 心跳检查任务（每30秒执行一次）
        scheduler.scheduleAtFixedRate(this::sendHeartbeat, 30, 30, TimeUnit.SECONDS);
    }
    
    // ==================== 核心方法 ====================
    
    /**
     * 创建会话
     * 
     * @param session WebSocket会话
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param token JWT令牌
     * @return 是否创建成功
     */
    public boolean createSession(Session session, Long documentId, Long userId, String token) {
        try {
            String sessionId = getSessionId(session);
            
            log.info("创建协同编辑会话: sessionId={}, documentId={}, userId={}", 
                    sessionId, documentId, userId);
            
            // 1. 验证权限
            if (!collaborationService.validateCollaborationPermission(documentId, userId, token)) {
                log.warn("用户权限验证失败: documentId={}, userId={}", documentId, userId);
                sendErrorMessage(session, "权限验证失败");
                return false;
            }
            
            // 2. 检查连接数限制
            if (!checkConnectionLimits(documentId, userId)) {
                log.warn("连接数超限: documentId={}, userId={}", documentId, userId);
                sendErrorMessage(session, "连接数超限");
                return false;
            }
            
            // 3. 检查是否已存在会话
            if (sessionInfos.containsKey(sessionId)) {
                log.warn("会话已存在: sessionId={}", sessionId);
                closeSession(session);
                return false;
            }
            
            // 4. 创建会话信息
            SessionInfo sessionInfo = new SessionInfo(sessionId, documentId, userId, token);
            
            // 5. 添加到各个映射
            addSessionToMappings(session, sessionInfo);
            
            // 6. 加入协同编辑
            if (!collaborationService.joinCollaboration(documentId, userId, sessionId)) {
                log.warn("加入协同编辑失败: documentId={}, userId={}", documentId, userId);
                removeSessionFromMappings(sessionId);
                sendErrorMessage(session, "加入协同编辑失败");
                return false;
            }
            
            // 7. 发送连接成功消息
            sendConnectionSuccessMessage(session, sessionInfo);
            
            // 8. 广播用户加入消息
            broadcastUserJoined(documentId, userId, sessionId);
            
            // 9. 发送在线用户列表
            sendOnlineUsersList(documentId);
            
            // 10. [Yjs] 发送初始文档状态 (SyncStep2)
            // 即使前端有 HTTP 预加载，这里作为双重保障，符合 Yjs 协议规范
            sendInitialState(session, documentId);
            
            log.info("会话创建成功: sessionId={}, documentId={}, userId={}", 
                    sessionId, documentId, userId);
            return true;
            
        } catch (Exception e) {
            log.error("创建会话失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            sendErrorMessage(session, "会话创建失败");
            return false;
        }
    }
    
    /**
     * 关闭会话
     * 
     * @param session WebSocket会话
     */
    public void closeSession(Session session) {
        try {
            String sessionId = getSessionId(session);
            SessionInfo sessionInfo = sessionInfos.get(sessionId);
            
            if (sessionInfo != null) {
                log.info("关闭协同编辑会话: sessionId={}, documentId={}, userId={}", 
                        sessionId, sessionInfo.getDocumentId(), sessionInfo.getUserId());
                
                // 1. 离开协同编辑
                collaborationService.leaveCollaboration(
                    sessionInfo.getDocumentId(), 
                    sessionInfo.getUserId(), 
                    sessionId
                );
                
                // 2. 广播用户离开消息
                broadcastUserLeft(sessionInfo.getDocumentId(), sessionInfo.getUserId(), sessionId);
                
                // 3. 更新在线用户列表
                sendOnlineUsersList(sessionInfo.getDocumentId());
            }
            
            // 4. 从映射中移除
            removeSessionFromMappings(sessionId);
            
            // 5. 关闭WebSocket连接
            if (session.isOpen()) {
                try {
                    session.close(new CloseReason(CloseReason.CloseCodes.NORMAL_CLOSURE, "会话关闭"));
                } catch (IOException e) {
                    log.warn("关闭WebSocket连接失败: sessionId={}, error={}", sessionId, e.getMessage());
                }
            }
            
            log.info("会话关闭完成: sessionId={}", sessionId);
            
        } catch (Exception e) {
            log.error("关闭会话失败: sessionId={}, error={}", getSessionId(session), e.getMessage(), e);
        }
    }
    
    /**
     * 处理会话消息（文本格式）
     * 
     * @param session WebSocket会话
     * @param message 消息内容
     */
    public void handleSessionMessage(Session session, String message) {
        try {
            String sessionId = getSessionId(session);
            SessionInfo sessionInfo = sessionInfos.get(sessionId);
            
            if (sessionInfo == null) {
                log.warn("会话信息不存在: sessionId={}", sessionId);
                sendErrorMessage(session, "会话信息不存在");
                return;
            }
            
            // 更新会话活动时间
            sessionLastActivity.put(sessionId, System.currentTimeMillis());
            
            // 处理消息
            CollaborationMessageHandler.SessionInfo handlerSessionInfo = 
                new CollaborationMessageHandler.SessionInfo(
                    sessionInfo.getSessionId(), 
                    sessionInfo.getDocumentId(), 
                    sessionInfo.getUserId(), 
                    sessionInfo.getToken()
                );
            CollaborationMessageHandler.MessageHandlerResult result = 
                messageHandler.handleMessage(message, handlerSessionInfo);
            
            // 发送响应
            if (result.getResponse() != null) {
                sendMessageToSession(session, result.getResponse());
            }
            
            // 广播消息
            if (result.shouldBroadcast()) {
                broadcastToDocument(sessionInfo.getDocumentId(), result.getResponse(), session);
            }
            
        } catch (Exception e) {
            log.error("处理会话消息失败: sessionId={}, error={}", getSessionId(session), e.getMessage(), e);
            sendErrorMessage(session, "消息处理失败");
        }
    }

    /**
     * 处理会话消息（二进制格式）
     * 用于 y-websocket 的二进制协议消息
     * 
     * @param session WebSocket会话
     * @param message 二进制消息内容
     */
    public void handleBinarySessionMessage(Session session, byte[] message) {
        try {
            String sessionId = getSessionId(session);
            SessionInfo sessionInfo = sessionInfos.get(sessionId);
            
            if (sessionInfo == null) {
                log.warn("会话信息不存在: sessionId={}", sessionId);
                return;
            }
            
            // 更新会话活动时间
            sessionLastActivity.put(sessionId, System.currentTimeMillis());
            
            Long documentId = sessionInfo.getDocumentId();
            Long userId = sessionInfo.getUserId();
            
            if (message.length == 0) return;

            // 解析 Yjs 消息类型
            byte messageType = message[0];
            
            // 1. 处理 Sync 消息 (Type = 0)
            if (messageType == MESSAGE_SYNC) {
                if (message.length > 1) {
                    byte syncType = message[1];
                    // 如果是 SyncStep1 (0)，客户端请求数据
                    if (syncType == SYNC_STEP_1) {
                         log.debug("收到 SyncStep1 请求: documentId={}, userId={}", documentId, userId);
                         // 1. 服务端优先响应快照 (SyncStep2)
                         sendInitialState(session, documentId);
                         return;
                    }
                }
            }
            
            // 2. 验证写权限
            boolean requiresWrite = false;
            if (messageType == MESSAGE_SYNC) {
                // SyncStep1 (请求同步) 不需要写权限
                // SyncStep2 (发送数据) 和 Update (发送更新) 需要写权限
                if (message.length > 1 && message[1] != SYNC_STEP_1) {
                    requiresWrite = true;
                }
            }
            
            if (messageType == MESSAGE_AWARENESS) requiresWrite = false; // Awareness 只是光标移动，无需文档写权限
            
            if (requiresWrite) {
                 if (!collaborationService.hasPermission(documentId, userId, 2)) {
                     log.warn("用户没有编辑权限，拒绝转发 Sync 消息: documentId={}, userId={}", documentId, userId);
                     return;
                 }
                 
                 // 检查文档锁
                 CollaborationService.LockStatus lockStatus = collaborationService.checkDocumentLock(documentId, userId);
                 if (lockStatus.isLocked() && !lockStatus.isOwner()) {
                     log.warn("文档被锁定，拒绝转发消息: documentId={}, lockUserId={}", documentId, lockStatus.getLockedBy());
                     return;
                 }
            }
            
            // 3. 广播消息
            // 无论是 SyncStep2, Update 还是 Awareness，都直接广播给其他客户端
            broadcastBinaryToDocument(documentId, message, session);
            
            // 如果是更新消息，异步保存到 MinIO
            if (messageType == MESSAGE_SYNC && message.length > 1 && (message[1] == SYNC_STEP_2 || message[1] == SYNC_UPDATE)) {
                try {
                    byte[] updateData = readVarUint8Array(message, 2);
                    if (updateData != null && updateData.length > 0) {
                        yjsDocumentManager.saveYjsUpdate(documentId, updateData);
                    }
                } catch (Exception e) {
                    log.debug("解析Yjs更新失败，跳过持久化: documentId={}, userId={}, error={}", documentId, userId, e.getMessage());
                }
            }
            
            log.debug("二进制消息转发成功: documentId={}, userId={}, type={}", documentId, userId, messageType);
            
        } catch (Exception e) {
            log.error("处理二进制消息失败: sessionId={}, error={}", getSessionId(session), e.getMessage(), e);
        }
    }

    /**
     * 发送初始文档状态 (SyncStep2)
     * 
     * @param session WebSocket会话
     * @param documentId 文档ID
     */
    private void sendInitialState(Session session, Long documentId) {
        try {
            // 1. 加载 Yjs 状态 (Base64)
            String base64State = yjsDocumentManager.loadYjsState(documentId);
            byte[] state;
            
            if (base64State == null || base64State.isEmpty()) {
                // 如果没有存储的状态，发送一个空的更新（最小的合法 Yjs Update），
                // 这样客户端就不会一直等待或者报错 "Unexpected end of array"
                // 最小的 update 是一个包含 0 的字节数组，表示没有任何更新
                state = new byte[]{0, 0}; 
            } else {
                // 2. 解码
                try {
                    state = Base64.getDecoder().decode(base64State);
                } catch (IllegalArgumentException e) {
                    log.error("Base64解码失败: documentId={}, value={}", documentId, base64State);
                    state = new byte[]{0, 0};
                }
            }
            
            // 双重保险：确保 state 不为空且长度合法（最小的合法 Yjs Update 是 [0, 0]，长度为 2）
            if (state == null || state.length < 2) {
                if (state != null && state.length > 0) {
                    log.warn("检测到无效的 Yjs 状态数据 (长度 < 2)，已重置: documentId={}", documentId);
                }
                state = new byte[]{0, 0};
            }
            
            sendSyncUpdate(session, SYNC_STEP_2, state);

            List<byte[]> recentUpdates = yjsDocumentManager.getRecentUpdates(documentId);
            for (byte[] update : recentUpdates) {
                if (update == null || update.length == 0) continue;
                sendSyncUpdate(session, SYNC_UPDATE, update);
            }

            log.info("已发送初始 Yjs 状态 (SyncStep2): documentId={}, size={}", documentId, state.length);
            
        } catch (Exception e) {
            log.error("发送初始 Yjs 状态失败: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }

    private void sendSyncUpdate(Session session, int syncType, byte[] update) throws IOException {
        ByteArrayOutputStream out = new ByteArrayOutputStream((update != null ? update.length : 0) + 16);
        out.write((byte) MESSAGE_SYNC);
        out.write((byte) syncType);
        writeVarUint(out, update != null ? update.length : 0);
        if (update != null && update.length > 0) {
            out.write(update);
        }
        session.getBasicRemote().sendBinary(ByteBuffer.wrap(out.toByteArray()));
    }

    private static void writeVarUint(ByteArrayOutputStream out, int value) {
        long num = value & 0xFFFFFFFFL;
        while (num > 0x7FL) {
            out.write((int) ((num & 0x7FL) | 0x80L));
            num >>>= 7;
        }
        out.write((int) num);
    }

    private static long readVarUint(byte[] data, int[] offset) {
        long num = 0;
        int shift = 0;
        while (true) {
            if (offset[0] >= data.length) {
                throw new IllegalArgumentException("Unexpected end of varUint");
            }
            int b = data[offset[0]++] & 0xFF;
            num |= (long) (b & 0x7F) << shift;
            if ((b & 0x80) == 0) break;
            shift += 7;
            if (shift > 63) {
                throw new IllegalArgumentException("varUint too long");
            }
        }
        return num;
    }

    private static byte[] readVarUint8Array(byte[] data, int startOffset) {
        int[] offset = new int[]{startOffset};
        long lenLong = readVarUint(data, offset);
        if (lenLong < 0 || lenLong > Integer.MAX_VALUE) {
            throw new IllegalArgumentException("Invalid length");
        }
        int len = (int) lenLong;
        if (offset[0] + len > data.length) {
            throw new IllegalArgumentException("Length exceeds buffer");
        }
        return Arrays.copyOfRange(data, offset[0], offset[0] + len);
    }
    
    /**
     * 广播消息到文档的所有会话
     * 
     * @param documentId 文档ID
     * @param message 消息内容
     */
    public void broadcastToDocument(Long documentId, CollaborationMessageDTO message) {
        broadcastToDocument(documentId, message, null);
    }
    
    /**
     * 广播消息到文档的所有会话（排除指定会话）
     * 
     * @param documentId 文档ID
     * @param message 消息内容
     * @param excludeSession 排除的会话
     */
    public void broadcastToDocument(Long documentId, CollaborationMessageDTO message, Session excludeSession) {
        try {
            ConcurrentHashMap<String, Session> sessions = documentSessions.get(documentId);
            if (sessions == null || sessions.isEmpty()) {
                return;
            }
            
            String messageJson = JSON.toJSONString(message);
            int successCount = 0;
            int failCount = 0;
            
            for (Map.Entry<String, Session> entry : sessions.entrySet()) {
                Session session = entry.getValue();
                String sessionId = entry.getKey();
                
                // 排除指定会话
                if (session.equals(excludeSession)) {
                    continue;
                }
                
                // 检查会话是否有效
                if (!session.isOpen()) {
                    log.warn("会话已关闭，跳过广播: sessionId={}", sessionId);
                    failCount++;
                    continue;
                }
                
                try {
                    session.getBasicRemote().sendText(messageJson);
                    successCount++;
                } catch (IOException e) {
                    log.error("发送广播消息失败: sessionId={}, error={}", sessionId, e.getMessage());
                    failCount++;
                    
                    // 关闭异常会话
                    closeSession(session);
                }
            }
            
            log.debug("广播消息完成: documentId={}, type={}, success={}, fail={}", 
                    documentId, message.getType(), successCount, failCount);
                    
        } catch (Exception e) {
            log.error("广播消息异常: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }

    /**
     * 广播二进制消息到文档的所有会话（排除指定会话）
     * 用于 y-websocket 的二进制协议消息转发
     * 
     * @param documentId 文档ID
     * @param message 二进制消息内容
     * @param excludeSession 排除的会话
     */
    public void broadcastBinaryToDocument(Long documentId, byte[] message, Session excludeSession) {
        try {
            ConcurrentHashMap<String, Session> sessions = documentSessions.get(documentId);
            if (sessions == null || sessions.isEmpty()) {
                return;
            }
            
            int successCount = 0;
            int failCount = 0;
            
            for (Map.Entry<String, Session> entry : sessions.entrySet()) {
                Session session = entry.getValue();
                String sessionId = entry.getKey();
                
                // 排除指定会话
                if (session.equals(excludeSession)) {
                    continue;
                }
                
                // 检查会话是否有效
                if (!session.isOpen()) {
                    log.warn("会话已关闭，跳过广播: sessionId={}", sessionId);
                    failCount++;
                    continue;
                }
                
                try {
                    session.getAsyncRemote().sendBinary(java.nio.ByteBuffer.wrap(message));
                    successCount++;
                } catch (Exception e) {
                    log.error("发送二进制广播消息失败: sessionId={}, error={}", sessionId, e.getMessage());
                    failCount++;
                    
                    // 关闭异常会话
                    closeSession(session);
                }
            }
            
            log.debug("二进制消息广播完成: documentId={}, length={}, success={}, fail={}", 
                    documentId, message.length, successCount, failCount);
                    
        } catch (Exception e) {
            log.error("二进制消息广播异常: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }
    
    /**
     * 获取文档的在线用户数
     * 
     * @param documentId 文档ID
     * @return 在线用户数
     */
    public int getOnlineUserCount(Long documentId) {
        ConcurrentHashMap<String, Session> sessions = documentSessions.get(documentId);
        return sessions != null ? sessions.size() : 0;
    }
    
    /**
     * 获取用户的所有会话
     * 
     * @param userId 用户ID
     * @return 会话ID集合
     */
    public Set<String> getUserSessions(Long userId) {
        ConcurrentHashMap<String, Session> sessions = userSessions.get(userId);
        return sessions != null ? new HashSet<>(sessions.keySet()) : new HashSet<>();
    }
    
    /**
     * 获取会话信息
     * 
     * @param sessionId 会话ID
     * @return 会话信息
     */
    public SessionInfo getSessionInfo(String sessionId) {
        return sessionInfos.get(sessionId);
    }
    
    /**
     * 获取所有活跃会话数
     * 
     * @return 活跃会话数
     */
    public int getActiveSessionCount() {
        return sessionInfos.size();
    }
    
    // ==================== 私有方法 ====================
    
    /**
     * 检查连接数限制
     */
    private boolean checkConnectionLimits(Long documentId, Long userId) {
        // 检查总连接数
        if (sessionInfos.size() >= MAX_CONNECTIONS) {
            log.warn("总连接数超限: current={}, max={}", sessionInfos.size(), MAX_CONNECTIONS);
            return false;
        }
        
        // 检查每文档连接数
        ConcurrentHashMap<String, Session> docSessions = documentSessions.get(documentId);
        if (docSessions != null && docSessions.size() >= MAX_CONNECTIONS_PER_DOCUMENT) {
            log.warn("文档连接数超限: documentId={}, current={}, max={}", 
                    documentId, docSessions.size(), MAX_CONNECTIONS_PER_DOCUMENT);
            return false;
        }
        
        return true;
    }
    
    /**
     * 添加会话到映射
     */
    private void addSessionToMappings(Session session, SessionInfo sessionInfo) {
        String sessionId = sessionInfo.getSessionId();
        Long documentId = sessionInfo.getDocumentId();
        Long userId = sessionInfo.getUserId();
        
        // 添加到文档会话映射
        documentSessions.computeIfAbsent(documentId, k -> new ConcurrentHashMap<>())
                      .put(sessionId, session);
        
        // 添加到用户会话映射
        userSessions.computeIfAbsent(userId, k -> new ConcurrentHashMap<>())
                   .put(sessionId, session);
        
        // 添加会话信息
        sessionInfos.put(sessionId, sessionInfo);
        
        // 更新活动时间
        sessionLastActivity.put(sessionId, System.currentTimeMillis());
    }
    
    /**
     * 从映射中移除会话
     */
    private void removeSessionFromMappings(String sessionId) {
        SessionInfo sessionInfo = sessionInfos.get(sessionId);
        if (sessionInfo == null) {
            return;
        }
        
        Long documentId = sessionInfo.getDocumentId();
        Long userId = sessionInfo.getUserId();
        
        // 从文档会话映射移除
        ConcurrentHashMap<String, Session> docSessions = documentSessions.get(documentId);
        if (docSessions != null) {
            docSessions.remove(sessionId);
            if (docSessions.isEmpty()) {
                documentSessions.remove(documentId);
            }
        }
        
        // 从用户会话映射移除
        ConcurrentHashMap<String, Session> userSess = userSessions.get(userId);
        if (userSess != null) {
            userSess.remove(sessionId);
            if (userSess.isEmpty()) {
                userSessions.remove(userId);
            }
        }
        
        // 移除会话信息和活动时间
        sessionInfos.remove(sessionId);
        sessionLastActivity.remove(sessionId);
    }
    
    /**
     * 清理过期会话
     */
    private void cleanupExpiredSessions() {
        try {
            log.debug("开始清理过期会话");
            
            long currentTime = System.currentTimeMillis();
            long timeoutMillis = SESSION_TIMEOUT_MINUTES * 60 * 1000L;
            
            List<String> expiredSessions = sessionLastActivity.entrySet().stream()
                .filter(entry -> currentTime - entry.getValue() > timeoutMillis)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
            
            for (String sessionId : expiredSessions) {
                SessionInfo sessionInfo = sessionInfos.get(sessionId);
                if (sessionInfo != null) {
                    log.info("清理过期会话: sessionId={}, userId={}, documentId={}", 
                            sessionId, sessionInfo.getUserId(), sessionInfo.getDocumentId());
                    
                    ConcurrentHashMap<String, Session> docSessions = documentSessions.get(sessionInfo.getDocumentId());
                    if (docSessions != null) {
                        Session session = docSessions.get(sessionId);
                        if (session != null) {
                            closeSession(session);
                        }
                    }
                } else {
                    // 清理孤立的活动时间记录
                    sessionLastActivity.remove(sessionId);
                }
            }
            
            log.debug("过期会话清理完成，清理数量: {}", expiredSessions.size());
            
        } catch (Exception e) {
            log.error("清理过期会话失败: error={}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送心跳
     */
    private void sendHeartbeat() {
        try {
            CollaborationMessageDTO heartbeatMessage = new CollaborationMessageDTO();
            heartbeatMessage.setType("heartbeat");
            heartbeatMessage.setData(Map.of("timestamp", System.currentTimeMillis()));
            heartbeatMessage.setTimestamp(System.currentTimeMillis());
            
            String messageJson = JSON.toJSONString(heartbeatMessage);
            
            for (Map.Entry<String, SessionInfo> entry : sessionInfos.entrySet()) {
                String sessionId = entry.getKey();
                SessionInfo sessionInfo = entry.getValue();
                
                ConcurrentHashMap<String, Session> docSessions = documentSessions.get(sessionInfo.getDocumentId());
                if (docSessions != null) {
                    Session session = docSessions.get(sessionId);
                    if (session != null && session.isOpen()) {
                        try {
                            session.getBasicRemote().sendText(messageJson);
                        } catch (IOException e) {
                            log.warn("发送心跳失败: sessionId={}, error={}", sessionId, e.getMessage());
                        }
                    }
                }
            }
            
            log.debug("心跳发送完成");
            
        } catch (Exception e) {
            log.error("发送心跳失败: error={}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送连接成功消息
     */
    private void sendConnectionSuccessMessage(Session session, SessionInfo sessionInfo) {
        try {
            CollaborationMessageDTO message = new CollaborationMessageDTO();
            message.setType("connection_success");
            message.setDocumentId(sessionInfo.getDocumentId());
            message.setUserId(sessionInfo.getUserId());
            message.setData(Map.of(
                "sessionId", sessionInfo.getSessionId(),
                "connectTime", sessionInfo.getConnectTime().toString()
            ));
            message.setTimestamp(System.currentTimeMillis());
            
            sendMessageToSession(session, message);
            
        } catch (Exception e) {
            log.error("发送连接成功消息失败: sessionId={}, error={}", 
                    sessionInfo.getSessionId(), e.getMessage(), e);
        }
    }
    
    /**
     * 广播用户加入消息
     */
    private void broadcastUserJoined(Long documentId, Long userId, String sessionId) {
        try {
            CollaborationMessageDTO message = new CollaborationMessageDTO();
            message.setType("user_joined");
            message.setDocumentId(documentId);
            message.setUserId(userId);
            message.setData(Map.of("sessionId", sessionId));
            message.setTimestamp(System.currentTimeMillis());
            
            broadcastToDocument(documentId, message);
            
        } catch (Exception e) {
            log.error("广播用户加入消息失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
        }
    }
    
    /**
     * 广播用户离开消息
     */
    private void broadcastUserLeft(Long documentId, Long userId, String sessionId) {
        try {
            CollaborationMessageDTO message = new CollaborationMessageDTO();
            message.setType("user_left");
            message.setDocumentId(documentId);
            message.setUserId(userId);
            message.setData(Map.of("sessionId", sessionId));
            message.setTimestamp(System.currentTimeMillis());
            
            broadcastToDocument(documentId, message);
            
        } catch (Exception e) {
            log.error("广播用户离开消息失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
        }
    }
    
    /**
     * 发送在线用户列表
     */
    private void sendOnlineUsersList(Long documentId) {
        try {
            Set<Long> onlineUsers = collaborationService.getOnlineUsers(documentId);
            
            CollaborationMessageDTO message = new CollaborationMessageDTO();
            message.setType("online_users");
            message.setDocumentId(documentId);
            message.setData(Map.of("users", onlineUsers));
            message.setTimestamp(System.currentTimeMillis());
            
            broadcastToDocument(documentId, message);
            
        } catch (Exception e) {
            log.error("发送在线用户列表失败: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }
    
    /**
     * 发送错误消息
     */
    private void sendErrorMessage(Session session, String errorMessage) {
        try {
            CollaborationMessageDTO message = new CollaborationMessageDTO();
            message.setType("error");
            message.setData(Map.of("message", errorMessage));
            message.setTimestamp(System.currentTimeMillis());
            
            sendMessageToSession(session, message);
            
        } catch (Exception e) {
            log.error("发送错误消息失败: error={}", e.getMessage(), e);
        }
    }
    
    /**
     * 发送消息到会话
     */
    private void sendMessageToSession(Session session, CollaborationMessageDTO message) {
        try {
            if (session.isOpen()) {
                String messageJson = JSON.toJSONString(message);
                session.getBasicRemote().sendText(messageJson);
            }
        } catch (IOException e) {
            log.error("发送消息到会话失败: sessionId={}, error={}", 
                    getSessionId(session), e.getMessage(), e);
        }
    }
    
    /**
     * 获取会话ID
     */
    private String getSessionId(Session session) {
        return session.getId();
    }
    
    // ==================== 内部类 ====================
    
    /**
     * 会话信息
     */
    public static class SessionInfo {
        private final String sessionId;
        private final Long documentId;
        private final Long userId;
        private final String token;
        private final LocalDateTime connectTime;
        
        public SessionInfo(String sessionId, Long documentId, Long userId, String token) {
            this.sessionId = sessionId;
            this.documentId = documentId;
            this.userId = userId;
            this.token = token;
            this.connectTime = LocalDateTime.now();
        }
        
        public String getSessionId() { return sessionId; }
        public Long getDocumentId() { return documentId; }
        public Long getUserId() { return userId; }
        public String getToken() { return token; }
        public LocalDateTime getConnectTime() { return connectTime; }
    }
}
