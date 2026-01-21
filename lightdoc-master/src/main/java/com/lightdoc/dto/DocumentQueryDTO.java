package com.lightdoc.dto;

import lombok.Data;

/**
 * 文档查询数据传输对象
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
public class DocumentQueryDTO {
    
    /**
     * 文档标题（模糊查询）
     */
    private String title;
    
    /**
     * 原始文档类型
     */
    private String originalDocumentType;
    
    /**
     * 所有者ID
     */
    private Long ownerId;
    
    /**
     * 所属知识库ID
     */
    private Long knowledgeBaseId;
    
    /**
     * 文档状态
     */
    private Integer status;
    
    /**
     * 是否公开
     */
    private Boolean isPublic;
    
    /**
     * 标签
     */
    private String tags;
    
    /**
     * 页码
     */
    private Integer page = 1;
    
    /**
     * 每页大小
     */
    private Integer size = 10;
}