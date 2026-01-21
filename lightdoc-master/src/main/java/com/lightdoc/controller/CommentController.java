package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.dto.CollaborationMessageDTO;
import com.lightdoc.entity.Comment;
import com.lightdoc.service.DocumentService;
import com.lightdoc.service.UserService;
import com.lightdoc.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 评论控制器
 *
 * @author lightdoc
 * @since 2025-11-28
 */
@Slf4j
@RestController
@RequestMapping("/comments")
public class CommentController {

    @Autowired
    private com.lightdoc.service.CommentService commentService;

    @Autowired
    private DocumentService documentService;

    @Autowired
    private UserService userService;

    /**
     * 获取文档评论列表
     *
     * @param documentId 文档ID
     * @return 评论列表
     */
    @GetMapping("/document/{documentId}")
    public Result<List<Comment>> getCommentsByDocument(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
                return Result.error("没有权限访问该文档的评论");
            }

            List<Comment> comments = commentService.getCommentsByDocument(documentId);
            return Result.success(comments);

        } catch (Exception e) {
            log.error("获取文档评论失败: {}", e.getMessage(), e);
            return Result.error("获取评论失败: " + e.getMessage());
        }
    }

    /**
     * 创建评论
     *
     * @param comment 评论信息
     * @return 创建结果
     */
    @PostMapping
    public Result<Comment> createComment(@RequestBody Comment comment) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(comment.getDocumentId(), userId, DocumentService.DocumentPermissionAction.COMMENT)) {
                return Result.error("没有权限在该文档中添加评论");
            }

            Comment createdComment = commentService.createComment(comment, userId);
            return Result.success(createdComment);

        } catch (Exception e) {
            log.error("创建评论失败: {}", e.getMessage(), e);
            return Result.error("创建评论失败: " + e.getMessage());
        }
    }

    /**
     * 回复评论
     *
     * @param commentId 评论ID
     * @param reply     回复内容
     * @return 回复结果
     */
    @PostMapping("/{commentId}/reply")
    public Result<Comment> replyComment(@PathVariable("commentId") Long commentId,
                                       @RequestBody Comment reply) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            Comment originalComment = commentService.getCommentById(commentId);
            if (originalComment == null) {
                return Result.error("评论不存在");
            }

            if (!documentService.hasPermission(originalComment.getDocumentId(), userId, DocumentService.DocumentPermissionAction.COMMENT)) {
                return Result.error("没有权限在该文档中添加评论");
            }

            reply.setParentId(commentId);
            Comment createdReply = commentService.createComment(reply, userId);
            return Result.success(createdReply);

        } catch (Exception e) {
            log.error("回复评论失败: {}", e.getMessage(), e);
            return Result.error("回复评论失败: " + e.getMessage());
        }
    }

    /**
     * 更新评论
     *
     * @param commentId 评论ID
     * @param comment   评论信息
     * @return 更新结果
     */
    @PutMapping("/{commentId}")
    public Result<Comment> updateComment(@PathVariable("commentId") Long commentId,
                                        @RequestBody Comment comment) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            // 检查评论是否存在以及是否为评论作者
            Comment existingComment = commentService.getCommentById(commentId);
            if (existingComment == null) {
                return Result.error("评论不存在");
            }

            if (!existingComment.getUserId().equals(userId)) {
                return Result.error("只能修改自己的评论");
            }

            Comment updatedComment = commentService.updateComment(commentId, comment, userId);
            return Result.success(updatedComment);

        } catch (Exception e) {
            log.error("更新评论失败: {}", e.getMessage(), e);
            return Result.error("更新评论失败: " + e.getMessage());
        }
    }

    /**
     * 删除评论
     *
     * @param commentId 评论ID
     * @return 删除结果
     */
    @DeleteMapping("/{commentId}")
    public Result<Void> deleteComment(@PathVariable("commentId") Long commentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            Comment comment = commentService.getCommentById(commentId);
            if (comment == null) {
                return Result.error("评论不存在");
            }

            if (!comment.getUserId().equals(userId) &&
                !documentService.hasPermission(comment.getDocumentId(), userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                return Result.error("没有权限删除此评论");
            }

            commentService.deleteComment(commentId, userId);
            return Result.success();

        } catch (Exception e) {
            log.error("删除评论失败: {}", e.getMessage(), e);
            return Result.error("删除评论失败: " + e.getMessage());
        }
    }
}
