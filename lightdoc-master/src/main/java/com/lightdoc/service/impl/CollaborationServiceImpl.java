package com.lightdoc.service.impl;

import com.lightdoc.dto.CollaborationMessageDTO;
import com.lightdoc.entity.Document;
import com.lightdoc.entity.DocumentLock;
import com.lightdoc.entity.DocumentOperationLog;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.DocumentLockMapper;
import com.lightdoc.mapper.DocumentMapper;
import com.lightdoc.mapper.DocumentOperationLogMapper;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.CollaborationService;
import com.lightdoc.service.DocumentService;
import com.lightdoc.utils.JwtUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 协同编辑服务实现类
 * 
 * 职责：
 * 1. 用户权限验证和会话管理
 * 2. 文档锁定机制防止并发冲突
 * 3. 实时消息处理和广播（只转发，不处理CRDT）
 * 4. 操作审计和性能监控
 * 
 * 注意：Yjs的CRDT合并由前端处理，后端只负责消息转发和权限验证
 *
 * @author lightdoc
 * @since 2025-12-29
 */
@Slf4j
@Service
public class CollaborationServiceImpl implements CollaborationService {
    
    // ==================== 配置参数 ====================
    
    /** 编辑锁过期时间（分钟） */
    private static final int LOCK_EXPIRE_MINUTES = 30;
    
    /** 最大在线用户数 */
    private static final int MAX_ONLINE_USERS = 50;
    
    // ==================== 依赖注入 ====================
    
    @Autowired
    private DocumentService documentService;
    
    @Autowired
    private DocumentMapper documentMapper;
    
    @Autowired
    private DocumentLockMapper documentLockMapper;
    
    @Autowired
    private DocumentOperationLogMapper operationLogMapper;
    
    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    // ==================== 内存缓存 ====================
    
    /** 文档在线用户映射：documentId -> userId Set */
    private final Map<Long, Set<Long>> documentOnlineUsers = new ConcurrentHashMap<>();
    
    /** 用户颜色映射：userId -> color */
    private final Map<Long, String> userColors = new ConcurrentHashMap<>();
    
    // ==================== 核心方法实现 ====================
    
    /**
     * 验证用户协同编辑权限
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param token JWT令牌
     * @return 验证结果
     */
    @Override
    public boolean validateCollaborationPermission(Long documentId, Long userId, String token) {
        try {
            log.debug("验证用户协同编辑权限: documentId={}, userId={}", documentId, userId);
            
            // 1. 验证JWT令牌
            if (token == null || token.isEmpty() || !jwtUtil.validateToken(token)) {
                log.warn("JWT令牌验证失败: userId={}", userId);
                return false;
            }
            
            // 2. 验证令牌中的用户ID
            Long tokenUserId = jwtUtil.extractUserId(token);
            if (tokenUserId == null || !tokenUserId.equals(userId)) {
                log.warn("令牌中的用户ID不匹配: tokenUserId={}, userId={}", tokenUserId, userId);
                return false;
            }
            
            // 3. 验证用户状态
            User user = userMapper.selectById(userId);
            if (user == null || user.getStatus() != 1) {
                log.warn("用户不存在或已禁用: userId={}", userId);
                return false;
            }
            
            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
                log.warn("用户没有文档访问权限: documentId={}, userId={}", documentId, userId);
                return false;
            }
            
            log.debug("用户协同编辑权限验证通过: documentId={}, userId={}", documentId, userId);
            return true;
            
        } catch (Exception e) {
            log.error("验证协同编辑权限异常: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 检查用户是否有指定权限级别的文档权限
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param requiredPermission 所需权限级别（0:只读, 1:评论, 2:编辑）
     * @return 是否有权限
     */
    @Override
    public boolean hasPermission(Long documentId, Long userId, int requiredPermission) {
        try {
            return documentService.hasPermission(documentId, userId, requiredPermission);
        } catch (Exception e) {
            log.error("检查文档权限异常: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 用户加入协同编辑会话
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param sessionId 会话ID
     * @return 是否加入成功
     */
    @Override
    @Transactional
    public boolean joinCollaboration(Long documentId, Long userId, String sessionId) {
        try {
            log.info("用户加入协同编辑: documentId={}, userId={}, sessionId={}", 
                    documentId, userId, sessionId);
            
            // 1. 检查文档是否存在
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            // 2. 检查在线用户数量限制
            Set<Long> onlineUsers = documentOnlineUsers.computeIfAbsent(documentId, k -> new HashSet<>());
            if (onlineUsers.size() >= MAX_ONLINE_USERS && !onlineUsers.contains(userId)) {
                log.warn("在线用户数量已达上限: documentId={}, currentCount={}", 
                        documentId, onlineUsers.size());
                return false;
            }
            
            // 3. 添加用户到在线列表
            onlineUsers.add(userId);
            
            // 4. 分配用户颜色
            if (!userColors.containsKey(userId)) {
                userColors.put(userId, generateUserColor(userId));
            }
            
            // 5. 记录操作日志
            recordUserOperation(documentId, userId, "join_collaboration", "用户加入协同编辑");
            
            log.info("用户成功加入协同编辑: documentId={}, userId={}, currentOnlineCount={}", 
                    documentId, userId, onlineUsers.size());
            return true;
            
        } catch (Exception e) {
            log.error("用户加入协同编辑失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 用户离开协同编辑会话
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param sessionId 会话ID
     */
    @Override
    @Transactional
    public void leaveCollaboration(Long documentId, Long userId, String sessionId) {
        try {
            log.info("用户离开协同编辑: documentId={}, userId={}, sessionId={}", 
                    documentId, userId, sessionId);
            
            // 1. 从在线用户列表移除
            Set<Long> onlineUsers = documentOnlineUsers.get(documentId);
            if (onlineUsers != null) {
                onlineUsers.remove(userId);
                
                // 如果没有在线用户，清理相关数据
                if (onlineUsers.isEmpty()) {
                    cleanupDocumentData(documentId);
                }
            }
            
            // 2. 释放用户持有的编辑锁
            releaseEditLock(documentId, userId);
            
            // 3. 记录操作日志
            recordUserOperation(documentId, userId, "leave_collaboration", "用户离开协同编辑");
            
            log.info("用户成功离开协同编辑: documentId={}, userId={}, remainingOnlineCount={}", 
                    documentId, userId, onlineUsers != null ? onlineUsers.size() : 0);
            
        } catch (Exception e) {
            log.error("用户离开协同编辑失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
        }
    }
    
    /**
     * 获取文档的当前在线用户列表
     * 
     * @param documentId 文档ID
     * @return 在线用户ID集合
     */
    @Override
    public Set<Long> getOnlineUsers(Long documentId) {
        Set<Long> onlineUsers = documentOnlineUsers.get(documentId);
        return onlineUsers != null ? new HashSet<>(onlineUsers) : new HashSet<>();
    }
    
    /**
     * 处理协同编辑消息（简化版，只做权限验证，不处理CRDT）
     * 
     * @param message 协同编辑消息
     * @return 处理结果
     */
    @Override
    @Transactional
    public boolean handleCollaborationMessage(CollaborationMessageDTO message) {
        try {
            Long documentId = message.getDocumentId();
            Long userId = message.getUserId();
            String messageType = message.getType();
            
            log.debug("处理协同编辑消息: documentId={}, userId={}, type={}", 
                    documentId, userId, messageType);
            
            // 1. 验证用户是否在线
            if (!isUserOnline(documentId, userId)) {
                log.warn("用户不在线: documentId={}, userId={}", documentId, userId);
                return false;
            }
            
            // 2. 根据消息类型处理
            switch (messageType) {
                case "yjs_update":
                    // Yjs更新消息：只验证权限，不处理CRDT
                    return handleYjsUpdate(message);
                case "cursor_update":
                    // 光标更新消息
                    return handleCursorUpdateMessage(message);
                case "lock_document":
                case "lock_request":
                    // 锁定文档请求
                    return handleLockRequest(message);
                case "unlock_document":
                case "unlock_request":
                    // 解锁文档请求
                    return handleUnlockRequest(message);
                case "ping":
                    // 心跳消息
                    return handlePingMessage(message);
                case "get_document_state":
                    // 获取文档状态请求（前端会处理）
                    return true;
                default:
                    log.warn("未知消息类型: {}", messageType);
                    return false;
            }
            
        } catch (Exception e) {
            log.error("处理协同编辑消息异常: message={}, error={}", 
                    message, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 获取编辑锁
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否获取成功
     */
    @Override
    @Transactional
    public boolean acquireEditLock(Long documentId, Long userId) {
        try {
            log.debug("尝试获取编辑锁: documentId={}, userId={}", documentId, userId);
            
            // 1. 检查当前锁状态
            DocumentLock currentLock = documentLockMapper.selectByDocumentIdAndType(documentId, "edit");
            
            if (currentLock != null) {
                // 检查锁是否过期
                if (currentLock.getLockExpiresAt().isBefore(LocalDateTime.now())) {
                    // 锁已过期，删除
                    documentLockMapper.deleteById(currentLock.getId());
                    log.info("编辑锁已过期并删除: documentId={}, lockId={}", 
                            documentId, currentLock.getId());
                } else if (!currentLock.getUserId().equals(userId)) {
                    // 锁被其他用户持有
                    log.info("编辑锁被其他用户持有: documentId={}, lockUserId={}, requestUserId={}", 
                            documentId, currentLock.getUserId(), userId);
                    return false;
                } else {
                    // 已是当前用户持有
                    log.debug("编辑锁已被当前用户持有: documentId={}, userId={}", documentId, userId);
                    return true;
                }
            }
            
            // 2. 创建新锁
            DocumentLock newLock = new DocumentLock();
            newLock.setDocumentId(documentId);
            newLock.setUserId(userId);
            newLock.setLockType("edit");
            newLock.setLockExpiresAt(LocalDateTime.now().plusMinutes(LOCK_EXPIRE_MINUTES));
            newLock.setAcquiredAt(LocalDateTime.now());
            
            documentLockMapper.insert(newLock);
            
            log.info("编辑锁获取成功: documentId={}, userId={}, lockId={}", 
                    documentId, userId, newLock.getId());
            
            // 3. 记录操作日志
            recordUserOperation(documentId, userId, "acquire_lock", "获取编辑锁");
            
            return true;
            
        } catch (Exception e) {
            log.error("获取编辑锁失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 释放编辑锁
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否释放成功
     */
    @Override
    @Transactional
    public boolean releaseEditLock(Long documentId, Long userId) {
        try {
            log.debug("尝试释放编辑锁: documentId={}, userId={}", documentId, userId);
            
            DocumentLock lock = documentLockMapper.selectByDocumentIdAndType(documentId, "edit");
            if (lock == null) {
                log.debug("编辑锁不存在: documentId={}", documentId);
                return true;
            }
            
            if (!lock.getUserId().equals(userId)) {
                log.warn("用户无权释放编辑锁: documentId={}, lockUserId={}, requestUserId={}", 
                        documentId, lock.getUserId(), userId);
                return false;
            }
            
            documentLockMapper.deleteById(lock.getId());
            
            log.info("编辑锁释放成功: documentId={}, userId={}, lockId={}", 
                    documentId, userId, lock.getId());
            
            // 记录操作日志
            recordUserOperation(documentId, userId, "release_lock", "释放编辑锁");
            
            return true;
            
        } catch (Exception e) {
            log.error("释放编辑锁失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 检查文档锁定状态
     * 
     * @param documentId 文档ID
     * @param userId 请求用户ID
     * @return 锁定状态信息
     */
    @Override
    public LockStatus checkDocumentLock(Long documentId, Long userId) {
        try {
            DocumentLock lock = documentLockMapper.selectByDocumentIdAndType(documentId, "edit");
            
            if (lock == null) {
                return new LockStatus(false, null, null, null, false);
            }
            
            // 检查锁是否过期
            if (lock.getLockExpiresAt().isBefore(LocalDateTime.now())) {
                documentLockMapper.deleteById(lock.getId());
                return new LockStatus(false, null, null, null, false);
            }
            
            // 获取锁定用户名
            User lockUser = userMapper.selectById(lock.getUserId());
            String username = lockUser != null ? 
                    (lockUser.getNickname() != null ? lockUser.getNickname() : lockUser.getUsername()) : 
                    "未知用户";
            
            boolean isOwner = lock.getUserId().equals(userId);
            
            return new LockStatus(true, lock.getUserId(), username, 
                    lock.getLockExpiresAt(), isOwner);
            
        } catch (Exception e) {
            log.error("检查文档锁定状态失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return new LockStatus(false, null, null, null, false);
        }
    }
    
    /**
     * 获取文档的 Yjs 状态（已移除，由前端管理）
     * 
     * @param documentId 文档ID
     * @return null（不再使用）
     */
    @Override
    public byte[] getDocumentYjsState(Long documentId) {
        // Yjs状态由前端管理，后端不再提供此功能
        log.debug("后端不再提供Yjs状态获取功能: documentId={}", documentId);
        return null;
    }
    
    /**
     * 更新文档的 Yjs 状态（已移除，由前端管理）
     * 
     * @param documentId 文档ID
     * @param update Yjs 更新数据
     * @param userId 操作用户ID
     * @return false（不再使用）
     */
    @Override
    @Transactional
    public boolean updateDocumentYjsState(Long documentId, byte[] update, Long userId) {
        // Yjs更新由前端管理，后端不再处理
        log.debug("后端不再处理Yjs状态更新: documentId={}, userId={}", documentId, userId);
        return false;
    }
    
    /**
     * 生成文档快照（已移除，由前端管理）
     * 
     * @param documentId 文档ID
     * @param userId 操作用户ID
     * @return null（不再使用）
     */
    @Override
    @Transactional
    public String generateDocumentSnapshot(Long documentId, Long userId) {
        // 文档快照由前端管理，后端不再提供此功能
        log.debug("后端不再提供文档快照生成功能: documentId={}, userId={}", documentId, userId);
        return null;
    }
    
    /**
     * 处理光标位置更新（简化版，只记录日志）
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param position 光标位置
     * @param selection 选择范围（可选）
     */
    @Override
    public void handleCursorUpdate(Long documentId, Long userId, Integer position, String selection) {
        try {
            log.debug("光标位置更新（仅记录日志）: documentId={}, userId={}, position={}", 
                    documentId, userId, position);
            
            // 光标位置由前端通过Yjs Awareness机制管理，后端不再存储
            // 这里只记录操作日志用于审计
            recordUserOperation(documentId, userId, "cursor_update", 
                    "光标位置: " + position);
            
        } catch (Exception e) {
            log.error("处理光标位置更新失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
        }
    }
    
    /**
     * 获取文档的所有光标位置（已移除，由前端管理）
     * 
     * @param documentId 文档ID
     * @return 空列表（不再使用）
     */
    @Override
    public List<CursorInfo> getDocumentCursors(Long documentId) {
        // 光标位置由前端管理，后端不再提供此功能
        log.debug("后端不再提供光标位置获取功能: documentId={}", documentId);
        return new ArrayList<>();
    }
    
    /**
     * 记录用户操作日志
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param operationType 操作类型
     * @param operationDetail 操作详情
     */
    @Override
    @Async
    public void recordUserOperation(Long documentId, Long userId, String operationType, String operationDetail) {
        try {
            DocumentOperationLog log = new DocumentOperationLog();
            log.setDocumentId(documentId);
            log.setUserId(userId);
            log.setOperationType(operationType);
            log.setOperationDetail(operationDetail);
            log.setOperationTime(LocalDateTime.now());
            
            operationLogMapper.insert(log);
            
        } catch (Exception e) {
            log.error("记录用户操作日志失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
        }
    }
    
    /**
     * 获取文档协同编辑统计信息
     * 
     * @param documentId 文档ID
     * @return 统计信息
     */
    @Override
    public CollaborationStats getCollaborationStats(Long documentId) {
        try {
            // 获取在线用户数
            int onlineUserCount = getOnlineUsers(documentId).size();
            
            // 获取操作数量
            int operationCount = operationLogMapper.countByDocumentId(documentId);
            
            // 获取最后编辑时间
            Document document = documentMapper.selectById(documentId);
            LocalDateTime lastEditTime = document != null ? document.getLastEditTime() : null;
            
            // 检查锁定状态
            LockStatus lockStatus = checkDocumentLock(documentId, null);
            String lockedBy = lockStatus.isLocked() ? lockStatus.getLockedByUsername() : null;
            
            return new CollaborationStats(onlineUserCount, 0, operationCount, 
                    lastEditTime, lockStatus.isLocked(), lockedBy);
                    
        } catch (Exception e) {
            log.error("获取协同编辑统计信息失败: documentId={}, error={}", 
                    documentId, e.getMessage(), e);
            return new CollaborationStats(0, 0, 0, null, false, null);
        }
    }
    
    /**
     * 清理过期的会话和锁
     * 定时任务，每5分钟执行一次
     */
    @Override
    @Scheduled(fixedRate = 300000) // 5分钟
    public void cleanupExpiredSessions() {
        try {
            log.debug("开始清理过期的会话和锁");
            
            // 清理过期的编辑锁
            List<DocumentLock> expiredLocks = documentLockMapper.selectExpiredLocks();
            for (DocumentLock lock : expiredLocks) {
                documentLockMapper.deleteById(lock.getId());
                log.info("清理过期编辑锁: documentId={}, userId={}, lockId={}", 
                        lock.getDocumentId(), lock.getUserId(), lock.getId());
            }
            
            log.debug("清理过期的会话和锁完成");
            
        } catch (Exception e) {
            log.error("清理过期会话和锁失败: error={}", e.getMessage(), e);
        }
    }
    
    // ==================== 私有辅助方法 ====================
    
    /**
     * 检查用户是否在线
     */
    private boolean isUserOnline(Long documentId, Long userId) {
        Set<Long> onlineUsers = documentOnlineUsers.get(documentId);
        return onlineUsers != null && onlineUsers.contains(userId);
    }
    
    /**
     * 处理Yjs更新消息（简化版，只验证权限）
     */
    private boolean handleYjsUpdate(CollaborationMessageDTO message) {
        try {
            Long documentId = message.getDocumentId();
            Long userId = message.getUserId();
            
            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                log.warn("用户没有编辑权限: documentId={}, userId={}", documentId, userId);
                return false;
            }
            
            // 检查文档锁
            LockStatus lockStatus = checkDocumentLock(documentId, userId);
            if (lockStatus.isLocked() && !lockStatus.isOwner()) {
                log.warn("文档被锁定: documentId={}, lockUserId={}, requestUserId={}", 
                        documentId, lockStatus.getLockedBy(), userId);
                return false;
            }
            
            // Yjs更新由前端处理，后端只验证权限并转发消息
            log.debug("Yjs更新消息权限验证通过: documentId={}, userId={}", documentId, userId);
            
            // 记录操作日志
            recordUserOperation(documentId, userId, "yjs_update", "更新文档内容");
            
            return true;
            
        } catch (Exception e) {
            log.error("处理Yjs更新消息失败: message={}, error={}", 
                    message, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 处理光标更新消息
     */
    private boolean handleCursorUpdateMessage(CollaborationMessageDTO message) {
        try {
            Long documentId = message.getDocumentId();
            Long userId = message.getUserId();
            
            Integer position = (Integer) message.getData().get("position");
            String selection = (String) message.getData().get("selection");
            
            handleCursorUpdate(documentId, userId, position, selection);
            return true;
            
        } catch (Exception e) {
            log.error("处理光标更新消息失败: message={}, error={}", 
                    message, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 处理锁请求消息
     */
    private boolean handleLockRequest(CollaborationMessageDTO message) {
        Long documentId = message.getDocumentId();
        Long userId = message.getUserId();
        return acquireEditLock(documentId, userId);
    }
    
    /**
     * 处理解锁请求消息
     */
    private boolean handleUnlockRequest(CollaborationMessageDTO message) {
        Long documentId = message.getDocumentId();
        Long userId = message.getUserId();
        return releaseEditLock(documentId, userId);
    }
    
    /**
     * 处理ping消息
     */
    private boolean handlePingMessage(CollaborationMessageDTO message) {
        // ping消息用于保持连接活跃，不需要特殊处理
        return true;
    }
    
    /**
     * 生成用户颜色
     */
    private String generateUserColor(Long userId) {
        String[] colors = {
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7",
            "#DDA0DD", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2"
        };
        
        int index = (int) (userId % colors.length);
        return colors[index];
    }
    
    /**
     * 清理文档相关数据
     */
    private void cleanupDocumentData(Long documentId) {
        try {
            // 清理在线用户
            documentOnlineUsers.remove(documentId);
            
            log.info("文档数据清理完成: documentId={}", documentId);
            
        } catch (Exception e) {
            log.error("清理文档数据失败: documentId={}, error={}", documentId, e.getMessage(), e);
        }
    }
}
