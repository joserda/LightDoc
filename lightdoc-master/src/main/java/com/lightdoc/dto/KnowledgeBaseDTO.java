package com.lightdoc.dto;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 知识库数据传输对象
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
public class KnowledgeBaseDTO {
    
    /**
     * 知识库ID
     */
    private Long id;
    
    /**
     * 知识库名称
     */
    private String name;
    
    /**
     * 知识库描述
     */
    private String description;
    
    /**
     * 所有者ID
     */
    private Long ownerId;
    
    /**
     * 所有者昵称
     */
    private String ownerNickname;
    
    /**
     * 父知识库ID
     */
    private Long parentId;
    
    /**
     * 状态（0-正常，1-已归档，2-已删除）
     */
    private Integer status;
    
    /**
     * 访问权限级别（0-私有，1-团队可见，2-公开）
     */
    private Integer permissionLevel;
    
    /**
     * 是否公开
     */
    private Boolean isPublic;
    
    /**
     * 文档数量
     */
    private Integer docCount;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}