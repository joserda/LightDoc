package com.lightdoc.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 创建通知DTO
 */
@Data
public class CreateNotificationDTO {

    /**
     * 接收通知的用户ID
     */
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /**
     * 通知类型：doc_invite/kb_invite/comment_mention/system_notice等
     */
    @NotBlank(message = "通知类型不能为空")
    private String type;

    /**
     * 通知标题
     */
    @NotBlank(message = "通知标题不能为空")
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 关联类型：document/knowledge_base/comment/system
     */
    private String relatedType;

    /**
     * 关联ID
     */
    private Long relatedId;
}