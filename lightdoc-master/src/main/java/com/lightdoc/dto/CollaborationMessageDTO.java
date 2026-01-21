package com.lightdoc.dto;

import lombok.Data;
import java.util.Map;

/**
 * 协同编辑消息DTO
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
public class CollaborationMessageDTO {
    
    /**
     * 消息类型
     * - join: 用户加入
     * - leave: 用户离开
     * - content_update: 内容更新
     * - cursor_update: 光标更新
     * - lock_document: 锁定文档
     * - unlock_document: 解锁文档
     * - online_users: 在线用户列表
     */
    private String type;
    
    /**
     * 文档ID
     */
    private Long documentId;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 用户名
     */
    private String username;
    
    /**
     * 消息内容
     */
    private Map<String, Object> data;
    
    /**
     * 时间戳
     */
    private Long timestamp;
    
    /**
     * 消息序列号（用于确保消息顺序）
     */
    private Long sequence;
}