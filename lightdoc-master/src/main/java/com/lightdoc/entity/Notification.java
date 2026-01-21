package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知实体类
 */
@Data
@TableName("notifications")
public class Notification {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 接收通知的用户ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 发送通知的用户ID
     */
    @TableField("sender_id")
    private Long senderId;

    /**
     * 通知类型：doc_invite/kb_invite/comment_mention/system_notice等
     */
    @TableField("type")
    private String type;

    /**
     * 通知标题
     */
    @TableField("title")
    private String title;

    /**
     * 通知内容
     */
    @TableField("content")
    private String content;

    /**
     * 关联类型：document/knowledge_base/comment/system
     */
    @TableField("related_type")
    private String relatedType;

    /**
     * 关联ID，如文档ID、知识库ID、评论ID等
     */
    @TableField("related_id")
    private Long relatedId;

    /**
     * 是否已读：0-未读，1-已读
     */
    @TableField("is_read")
    private Integer isRead;

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
     * 是否删除：0-未删除，1-已删除
     */
    @TableLogic
    @TableField("deleted")
    private Integer deleted;
}