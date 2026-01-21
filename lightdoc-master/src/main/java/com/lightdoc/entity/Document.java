package com.lightdoc.entity;

import cn.hutool.json.JSON;
import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档实体类
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
@TableName("documents")
public class Document {
    
    /**
     * 文档ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档标题
     */
    @TableField("title")
    private String title;
    
    /**
     * 原始文档类型
     */
    @TableField("original_document_type")
    private String originalDocumentType;
    
    /**
     * Yjs快照类型
     */
    @TableField("yjs_document_type")
    private String yjsDocumentType;
    
    /**
     * 原始文件存储路径
     */
    @TableField("original_file_path")
    private String originalFilePath;
    
    /**
     * Yjs快照存储路径
     */
    @TableField("yjs_snapshot_path")
    private String yjsSnapshotPath;
    
    /**
     * HTML预览内容
     */
    @TableField("html_preview_content")
    private String htmlPreviewContent;
    
    /**
     * 原始文件大小（字节）
     */
    @TableField("file_size")
    private Long fileSize;
    
    /**
     * Yjs快照大小（字节）
     */
    @TableField("yjs_snapshot_size")
    private Long yjsSnapshotSize;

    /**
     * ProseMirror JSON内容
     */
    @TableField("prose_mirror_json")
    private String proseMirrorJson;
    
    /**
     * 所有者ID
     */
    @TableField("owner_id")
    private Long ownerId;
    
    /**
     * 所属知识库ID
     */
    @TableField("knowledge_base_id")
    private Long knowledgeBaseId;
    
    /**
     * 文档状态（0-正常，1-草稿，2-已删除）
     */
    @TableField("status")
    private Integer status;
    
    /**
     * 版本号
     */
    @TableField("version")
    private Integer version;
    
    /**
     * 字数统计
     */
    @TableField("word_count")
    private Integer wordCount;
    
    /**
     * 标签
     */
    @TableField("tags")
    private String tags;
    
    /**
     * 访问权限级别（0-私有，1-知识库内可见，2-公开可写）
     */
    @TableField("permission_level")
    private Integer permissionLevel;
    
    /**
     * 是否公开
     */
    @TableField("is_public")
    private Boolean isPublic;
    
    /**
     * 文档摘要
     */
    @TableField("summary")
    private String summary;
    
    /**
     * 阅读次数
     */
    @TableField("view_count")
    private Integer viewCount;
    
    /**
     * 最后编辑时间
     */
    @TableField("last_edit_time")
    private LocalDateTime lastEditTime;
    
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