package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档权限实体类
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
@TableName("document_permissions")
public class DocumentPermission {
    
    /**
     * 权限ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;
    
    /**
     * 权限类型（read-读，write-写）
     */
    @TableField("permission_type")
    private String permissionType;
    
    /**
     * 权限级别（0-只读，1-评论，2-编辑，3-所有者）
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
    
    /**
     * 邀请者ID
     */
    @TableField("inviter_id")
    private Long inviterId;
    
    /**
     * 邀请时间
     */
    @TableField("invite_time")
    private LocalDateTime inviteTime;
    
    /**
     * 邀请状态（pending-待处理，accepted-已接受，rejected-已拒绝）
     */
    @TableField("invite_status")
    private String inviteStatus;
    
    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}