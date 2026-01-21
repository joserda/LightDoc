package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 文档评论实体类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("comments")
public class Comment {
    
    /**
     * 评论ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 评论用户ID
     */
    @TableField("user_id")
    private Long userId;
    
    /**
     * 评论内容
     */
    @TableField("content")
    private String content;
    
    /**
     * 父评论ID（用于回复）
     */
    @TableField("parent_id")
    private Long parentId;
    
    /**
     * 位置信息（JSON格式，用于定位评论在文档中的位置）
     */
    @TableField("position_info")
    private String positionInfo;
    
    /**
     * 状态（1-正常，0-已删除）
     */
    @TableField("status")
    private Integer status;
    
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
    
    /**
     * 回复列表（非数据库字段）
     */
    @TableField(exist = false)
    private List<Comment> replies;
}