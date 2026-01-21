package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 知识库权限实体类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("knowledge_base_permissions")
public class KnowledgeBasePermission {
    
    /**
     * 权限ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 知识库ID
     */
    @TableField("knowledge_base_id")
    private Long knowledgeBaseId;
    
    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;
    
    /**
     * 权限类型（read-读，write-写，manage-管理）
     */
    @TableField("permission_type")
    private String permissionType;
    
    /**
     * 权限级别（0-无权限，1-只读，2-读写，3-管理）
     */
    @TableField("permission_level")
    private Integer permissionLevel;
    
    /**
     * 授权者ID
     */
    @TableField("granted_by")
    private Long grantedBy;
    
    /**
     * 授权时间
     */
    @TableField(value = "granted_at", fill = FieldFill.INSERT)
    private LocalDateTime grantedAt;
}