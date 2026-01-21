package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档版本实体类
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Data
@TableName("document_versions")
public class DocumentVersion {
    
    /**
     * 版本ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 版本号
     */
    @TableField("version_number")
    private Integer versionNumber;
    
    /**
     * 版本类型（full-完整，incremental-增量）
     */
    @TableField("version_type")
    private String versionType;
    
    /**
     * 快照存储路径
     */
    @TableField("snapshot_path")
    private String snapshotPath;
    
    /**
     * 快照大小（字节）
     */
    @TableField("snapshot_size")
    private Long snapshotSize;
    
    /**
     * 变更描述
     */
    @TableField("change_description")
    private String changeDescription;
    
    /**
     * 创建者ID
     */
    @TableField("created_by")
    private Long createdBy;
    
    /**
     * 创建时间
     */
    @TableField(value = "created_at", fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}