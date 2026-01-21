package com.lightdoc.utils;

import com.lightdoc.dto.CreateNotificationDTO;
import com.lightdoc.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 通知工具类
 * 用于方便其他服务发送通知
 */
@Component
public class NotificationUtil {

    @Autowired
    private NotificationService notificationService;

    /**
     * 发送系统通知
     *
     * @param userId  用户ID
     * @param title   标题
     * @param content 内容
     * @return 通知ID
     */
    public Long sendSystemNotice(Long userId, String title, String content) {
        CreateNotificationDTO dto = new CreateNotificationDTO();
        dto.setUserId(userId);
        dto.setType("system_notice");
        dto.setTitle(title);
        dto.setContent(content);
        dto.setRelatedType("system");
        return notificationService.createNotification(dto);
    }

    /**
     * 发送文档邀请通知
     *
     * @param userId     用户ID
     * @param documentId 文档ID
     * @param title      标题
     * @param content    内容
     * @return 通知ID
     */
    public Long sendDocumentInvite(Long userId, Long documentId, String title, String content) {
        CreateNotificationDTO dto = new CreateNotificationDTO();
        dto.setUserId(userId);
        dto.setType("doc_invite");
        dto.setTitle(title);
        dto.setContent(content);
        dto.setRelatedType("document");
        dto.setRelatedId(documentId);
        return notificationService.createNotification(dto);
    }

    /**
     * 发送知识库邀请通知
     *
     * @param userId         用户ID
     * @param knowledgeBaseId 知识库ID
     * @param title          标题
     * @param content        内容
     * @return 通知ID
     */
    public Long sendKnowledgeBaseInvite(Long userId, Long knowledgeBaseId, String title, String content) {
        CreateNotificationDTO dto = new CreateNotificationDTO();
        dto.setUserId(userId);
        dto.setType("kb_invite");
        dto.setTitle(title);
        dto.setContent(content);
        dto.setRelatedType("knowledge_base");
        dto.setRelatedId(knowledgeBaseId);
        return notificationService.createNotification(dto);
    }

    /**
     * 发送评论提及通知
     *
     * @param userId    用户ID
     * @param commentId 评论ID
     * @param title     标题
     * @param content   内容
     * @return 通知ID
     */
    public Long sendCommentMention(Long userId, Long commentId, String title, String content) {
        CreateNotificationDTO dto = new CreateNotificationDTO();
        dto.setUserId(userId);
        dto.setType("comment_mention");
        dto.setTitle(title);
        dto.setContent(content);
        dto.setRelatedType("comment");
        dto.setRelatedId(commentId);
        return notificationService.createNotification(dto);
    }

    /**
     * 批量发送通知
     *
     * @param dtos 通知DTO列表
     * @return 创建的通知数量
     */
    public int sendBatchNotifications(CreateNotificationDTO... dtos) {
        return notificationService.createNotificationsBatch(java.util.Arrays.asList(dtos));
    }
}