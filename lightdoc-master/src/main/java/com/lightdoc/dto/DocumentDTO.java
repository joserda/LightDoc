package com.lightdoc.dto;

import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档数据传输对象
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
public class DocumentDTO {
    
    /**
     * 文档ID
     */
    private Long id;
    
    /**
     * 文档标题
     */
    private String title;
    
    /**
     * 原始文档类型
     */
    private String originalDocumentType;
    
    /**
     * Yjs快照类型
     */
    private String yjsDocumentType;
    
    /**
     * 原始文件存储路径
     */
    private String originalFilePath;
    
    /**
     * Yjs快照存储路径
     */
    private String yjsSnapshotPath;
    
    /**
     * HTML预览内容
     */
    private String htmlPreviewContent;
    
    /**
     * 文档内容（从MinIO读取的Yjs快照）
     */
    private String content;
    
    /**
     * 原始文件大小
     */
    private Long fileSize;
    
    /**
     * Yjs快照大小
     */
    private Long yjsSnapshotSize;
    
    /**
     * 所有者ID
     */
    private Long ownerId;
    
    /**
     * 所有者昵称
     */
    private String ownerNickname;
    
    /**
     * 所属知识库ID
     */
    private Long knowledgeBaseId;
    
    /**
     * 文档状态
     */
    private Integer status;
    
    /**
     * 版本号
     */
    private Integer version;
    
    /**
     * 字数统计
     */
    private Integer wordCount;
    
    /**
     * 标签
     */
    private String tags;
    
    /**
     * 访问权限级别
     */
    private Integer permissionLevel;
    
    /**
     * 是否公开
     */
    private Boolean isPublic;
    
    /**
     * ProseMirror JSON内容
     */
    private String proseMirrorJson;
    
    /**
     * 文档摘要
     */
    private String summary;
    
    /**
     * 阅读次数
     */
    private Integer viewCount;
    
    /**
     * 最后编辑时间
     */
    private LocalDateTime lastEditTime;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    private Boolean canView;

    private Boolean canComment;

    private Boolean canEdit;

    private Boolean canSaveVersion;

    private Boolean canLock;

    private Boolean canManageMembers;

    private Boolean canChangeVisibility;

    private Boolean isOwner;
}
