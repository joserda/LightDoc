package com.lightdoc.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 通知DTO
 */
@Data
public class NotificationDTO {

    /**
     * 通知ID
     */
    private Long id;

    /**
     * 接收通知的用户ID
     */
    private Long userId;

    /**
     * 发送通知的用户ID
     */
    private Long senderId;

    /**
     * 发送通知的用户昵称
     */
    private String senderName;

    /**
     * 通知类型
     */
    private String type;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 关联类型
     */
    private String relatedType;

    /**
     * 关联ID
     */
    private Long relatedId;

    /**
     * 是否已读
     */
    private Integer isRead;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}