package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档锁定实体类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("document_locks")
public class DocumentLock {
    
    /**
     * 锁定ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 锁定用户ID
     */
    @TableField("user_id")
    private Long userId;
    
    /**
     * 锁定类型
     */
    @TableField("lock_type")
    private String lockType;
    
    /**
     * 锁定过期时间
     */
    @TableField("lock_expires_at")
    private LocalDateTime lockExpiresAt;
    
    /**
     * 锁定获取时间
     */
    @TableField(value = "acquired_at", fill = FieldFill.INSERT)
    private LocalDateTime acquiredAt;
}