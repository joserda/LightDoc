package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 知识库实体类（文件夹结构）
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("knowledge_bases")
public class KnowledgeBase {
    
    /**
     * 知识库ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 知识库名称
     */
    @TableField("name")
    private String name;
    
    /**
     * 知识库描述
     */
    @TableField("description")
    private String description;
    
    /**
     * 所有者ID
     */
    @TableField("owner_id")
    private Long ownerId;
    
    /**
     * 父知识库ID（用于层级结构）
     */
    @TableField("parent_id")
    private Long parentId;
    
    /**
     * 状态（0-正常，1-已归档，2-已删除）
     */
    @TableField("status")
    private Integer status;
    
    /**
     * 访问权限级别（0-私有，1-团队可见，2-公开）
     */
    @TableField("permission_level")
    private Integer permissionLevel;
    
    /**
     * 是否公开
     */
    @TableField("is_public")
    private Boolean isPublic;
    
    /**
     * 文档数量
     */
    @TableField("doc_count")
    private Integer docCount;
    
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