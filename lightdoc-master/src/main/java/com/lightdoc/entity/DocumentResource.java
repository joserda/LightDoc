package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档资源实体类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("document_resources")
public class DocumentResource {
    
    /**
     * 资源ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 资源唯一标识符
     */
    @TableField("resource_id")
    private String resourceId;
    
    /**
     * 资源存储路径
     */
    @TableField("resource_path")
    private String resourcePath;
    
    /**
     * 资源原始名称
     */
    @TableField("resource_name")
    private String resourceName;
    
    /**
     * 资源类型（image/audio/video等）
     */
    @TableField("resource_type")
    private String resourceType;
    
    /**
     * 文件大小
     */
    @TableField("file_size")
    private Long fileSize;
    
    /**
     * 上传用户ID
     */
    @TableField("upload_by")
    private Long uploadBy;
    
    /**
     * 上传时间
     */
    @TableField(value = "upload_time", fill = FieldFill.INSERT)
    private LocalDateTime uploadTime;
}