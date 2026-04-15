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
    
    private String title;
    
    private String originalDocumentType;
    
    private Long ownerId;
    
    private Long knowledgeBaseId;
    
    private Integer status;
    
    private Boolean isPublic;
    
    private String tags;

    private String viewType;
    
    private Integer page = 1;
    
    private Integer size = 10;
}
