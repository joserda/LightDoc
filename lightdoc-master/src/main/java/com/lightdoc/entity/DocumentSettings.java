package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("document_settings")
public class DocumentSettings {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("document_id")
    private Long documentId;

    @TableField("versioning_enabled")
    private Boolean versioningEnabled;

    @TableField("max_version_count")
    private Integer maxVersionCount;

    @TableField("autosave_enabled")
    private Boolean autosaveEnabled;

    @TableField("autosave_interval_seconds")
    private Integer autosaveIntervalSeconds;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField(value = "updated_at", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}

