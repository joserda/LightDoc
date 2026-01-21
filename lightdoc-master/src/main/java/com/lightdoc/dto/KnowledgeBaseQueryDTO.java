package com.lightdoc.dto;

import lombok.Data;

/**
 * 知识库查询数据传输对象
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
public class KnowledgeBaseQueryDTO {
    
    /**
     * 父知识库ID
     */
    private Long parentId;
    
    /**
     * 所有者ID
     */
    private Long ownerId;
    
    /**
     * 状态（0-正常，1-已归档，2-已删除）
     */
    private Integer status;
    
    /**
     * 知识库名称（模糊查询）
     */
    private String name;
    
    /**
     * 是否公开
     */
    private Boolean isPublic;
    
    /**
     * 页码
     */
    private Integer page = 1;
    
    /**
     * 每页大小
     */
    private Integer size = 10;
}