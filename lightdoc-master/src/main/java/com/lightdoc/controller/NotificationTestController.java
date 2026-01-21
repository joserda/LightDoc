package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.utils.NotificationUtil;
import com.lightdoc.utils.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 通知测试控制器
 * 用于测试通知功能
 */
@RestController
@RequestMapping("/notifications/test")
public class NotificationTestController {

    @Autowired
    private NotificationUtil notificationUtil;

    /**
     * 发送测试通知
     */
    @PostMapping("/send")
    public Result<Long> sendTestNotification(
            @RequestParam(defaultValue = "测试通知") String title,
            @RequestParam(defaultValue = "这是一条测试通知内容") String content) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long notificationId = notificationUtil.sendSystemNotice(userId, title, content);
        return Result.success(notificationId);
    }

    /**
     * 发送文档邀请测试通知
     */
    @PostMapping("/send/doc-invite")
    public Result<Long> sendDocInviteTest(
            @RequestParam Long documentId,
            @RequestParam(defaultValue = "文档邀请") String title,
            @RequestParam(defaultValue = "您被邀请加入文档") String content) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long notificationId = notificationUtil.sendDocumentInvite(userId, documentId, title, content);
        return Result.success(notificationId);
    }

    /**
     * 发送知识库邀请测试通知
     */
    @PostMapping("/send/kb-invite")
    public Result<Long> sendKbInviteTest(
            @RequestParam Long knowledgeBaseId,
            @RequestParam(defaultValue = "知识库邀请") String title,
            @RequestParam(defaultValue = "您被邀请加入知识库") String content) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long notificationId = notificationUtil.sendKnowledgeBaseInvite(userId, knowledgeBaseId, title, content);
        return Result.success(notificationId);
    }

    /**
     * 发送评论提及测试通知
     */
    @PostMapping("/send/comment-mention")
    public Result<Long> sendCommentMentionTest(
            @RequestParam Long commentId,
            @RequestParam(defaultValue = "评论提及") String title,
            @RequestParam(defaultValue = "有人在评论中提到了您") String content) {

        Long userId = SecurityUtils.getCurrentUserId();
        if (userId == null) {
            return Result.error("用户未登录");
        }

        Long notificationId = notificationUtil.sendCommentMention(userId, commentId, title, content);
        return Result.success(notificationId);
    }
}