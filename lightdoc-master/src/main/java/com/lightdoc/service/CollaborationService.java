package com.lightdoc.service;

import com.lightdoc.dto.CollaborationMessageDTO;

import java.util.List;
import java.util.Set;

/**
 * 协同编辑服务接口
 * 
 * 提供文档协同编辑的核心功能，包括：
 * 1. 用户连接管理和权限验证
 * 2. 文档锁定机制
 * 3. Yjs 文档状态管理
 * 4. 实时消息处理和广播
 * 5. 版本控制和快照管理
 * 6. 操作日志记录
 * 
 * @author lightdoc
 * @since 2025-12-29
 */
public interface CollaborationService {
    
    /**
     * 验证用户是否有文档协同编辑权限
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param token JWT令牌
     * @return 验证结果
     */
    boolean validateCollaborationPermission(Long documentId, Long userId, String token);
    
    /**
     * 检查用户是否有指定权限级别的文档权限
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param requiredPermission 所需权限级别（0:只读, 1:评论, 2:编辑）
     * @return 是否有权限
     */
    boolean hasPermission(Long documentId, Long userId, int requiredPermission);
    
    /**
     * 用户加入协同编辑会话
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param sessionId 会话ID
     * @return 是否加入成功
     */
    boolean joinCollaboration(Long documentId, Long userId, String sessionId);
    
    /**
     * 用户离开协同编辑会话
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param sessionId 会话ID
     */
    void leaveCollaboration(Long documentId, Long userId, String sessionId);
    
    /**
     * 获取文档的当前在线用户列表
     * 
     * @param documentId 文档ID
     * @return 在线用户ID集合
     */
    Set<Long> getOnlineUsers(Long documentId);
    
    /**
     * 处理协同编辑消息
     * 
     * @param message 协同编辑消息
     * @return 处理结果
     */
    boolean handleCollaborationMessage(CollaborationMessageDTO message);
    
    /**
     * 获取编辑锁
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否获取成功
     */
    boolean acquireEditLock(Long documentId, Long userId);
    
    /**
     * 释放编辑锁
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否释放成功
     */
    boolean releaseEditLock(Long documentId, Long userId);
    
    /**
     * 检查文档是否被锁定
     * 
     * @param documentId 文档ID
     * @param userId 请求锁定的用户ID
     * @return 锁定状态信息
     */
    LockStatus checkDocumentLock(Long documentId, Long userId);
    
    /**
     * 获取文档的 Yjs 状态
     * 
     * @param documentId 文档ID
     * @return Yjs 文档状态（字节数组）
     */
    byte[] getDocumentYjsState(Long documentId);
    
    /**
     * 更新文档的 Yjs 状态
     * 
     * @param documentId 文档ID
     * @param update Yjs 更新数据
     * @param userId 操作用户ID
     * @return 是否更新成功
     */
    boolean updateDocumentYjsState(Long documentId, byte[] update, Long userId);
    
    /**
     * 生成文档快照
     * 
     * @param documentId 文档ID
     * @param userId 操作用户ID
     * @return 快照路径
     */
    String generateDocumentSnapshot(Long documentId, Long userId);
    
    /**
     * 处理光标位置更新
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param position 光标位置
     * @param selection 选择范围（可选）
     */
    void handleCursorUpdate(Long documentId, Long userId, Integer position, String selection);
    
    /**
     * 获取文档的所有光标位置
     * 
     * @param documentId 文档ID
     * @return 光标位置信息列表
     */
    List<CursorInfo> getDocumentCursors(Long documentId);
    
    /**
     * 记录用户操作日志
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @param operationType 操作类型
     * @param operationDetail 操作详情
     */
    void recordUserOperation(Long documentId, Long userId, String operationType, String operationDetail);
    
    /**
     * 获取文档协同编辑统计信息
     * 
     * @param documentId 文档ID
     * @return 统计信息
     */
    CollaborationStats getCollaborationStats(Long documentId);
    
    /**
     * 清理过期的会话和锁
     * 
     * 定时任务方法，清理无效的会话连接和过期的文档锁
     */
    void cleanupExpiredSessions();
    
    /**
     * 文档锁定状态信息
     */
    class LockStatus {
        private boolean locked;
        private Long lockedBy;
        private String lockedByUsername;
        private java.time.LocalDateTime lockExpiresAt;
        private boolean isOwner;
        
        // 构造函数
        public LockStatus(boolean locked, Long lockedBy, String lockedByUsername, 
                         java.time.LocalDateTime lockExpiresAt, boolean isOwner) {
            this.locked = locked;
            this.lockedBy = lockedBy;
            this.lockedByUsername = lockedByUsername;
            this.lockExpiresAt = lockExpiresAt;
            this.isOwner = isOwner;
        }
        
        // Getter 方法
        public boolean isLocked() { return locked; }
        public Long getLockedBy() { return lockedBy; }
        public String getLockedByUsername() { return lockedByUsername; }
        public java.time.LocalDateTime getLockExpiresAt() { return lockExpiresAt; }
        public boolean isOwner() { return isOwner; }
    }
    
    /**
     * 光标位置信息
     */
    class CursorInfo {
        private Long userId;
        private String username;
        private Integer position;
        private String selection;
        private String color;
        private java.time.LocalDateTime lastUpdate;
        
        // 构造函数
        public CursorInfo(Long userId, String username, Integer position, 
                         String selection, String color, java.time.LocalDateTime lastUpdate) {
            this.userId = userId;
            this.username = username;
            this.position = position;
            this.selection = selection;
            this.color = color;
            this.lastUpdate = lastUpdate;
        }
        
        // Getter 方法
        public Long getUserId() { return userId; }
        public String getUsername() { return username; }
        public Integer getPosition() { return position; }
        public String getSelection() { return selection; }
        public String getColor() { return color; }
        public java.time.LocalDateTime getLastUpdate() { return lastUpdate; }
    }
    
    /**
     * 协同编辑统计信息
     */
    class CollaborationStats {
        private int onlineUserCount;
        private int versionCount;
        private int operationCount;
        private java.time.LocalDateTime lastEditTime;
        private boolean isLocked;
        private String lockedBy;
        
        // 构造函数
        public CollaborationStats(int onlineUserCount, int versionCount, int operationCount,
                                 java.time.LocalDateTime lastEditTime, boolean isLocked, String lockedBy) {
            this.onlineUserCount = onlineUserCount;
            this.versionCount = versionCount;
            this.operationCount = operationCount;
            this.lastEditTime = lastEditTime;
            this.isLocked = isLocked;
            this.lockedBy = lockedBy;
        }
        
        // Getter 方法
        public int getOnlineUserCount() { return onlineUserCount; }
        public int getVersionCount() { return versionCount; }
        public int getOperationCount() { return operationCount; }
        public java.time.LocalDateTime getLastEditTime() { return lastEditTime; }
        public boolean isLocked() { return isLocked; }
        public String getLockedBy() { return lockedBy; }
    }
}