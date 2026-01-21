package com.lightdoc.service;

import com.lightdoc.entity.Comment;

import java.util.List;

/**
 * 评论服务接口
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
public interface CommentService {
    
    /**
     * 根据文档ID获取评论列表
     * 
     * @param documentId 文档ID
     * @return 评论列表
     */
    List<Comment> getCommentsByDocument(Long documentId);
    
    /**
     * 根据评论ID获取评论
     * 
     * @param commentId 评论ID
     * @return 评论信息
     */
    Comment getCommentById(Long commentId);
    
    /**
     * 创建评论
     * 
     * @param comment 评论信息
     * @param userId 用户ID
     * @return 创建的评论
     */
    Comment createComment(Comment comment, Long userId);
    
    /**
     * 更新评论
     * 
     * @param commentId 评论ID
     * @param comment 评论信息
     * @param userId 用户ID
     * @return 更新的评论
     */
    Comment updateComment(Long commentId, Comment comment, Long userId);
    
    /**
     * 删除评论
     * 
     * @param commentId 评论ID
     * @param userId 用户ID
     */
    void deleteComment(Long commentId, Long userId);
}