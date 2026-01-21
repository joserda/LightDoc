package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.entity.Comment;
import com.lightdoc.entity.Document;
import com.lightdoc.mapper.CommentMapper;
import com.lightdoc.mapper.DocumentMapper;
import com.lightdoc.service.CommentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 评论服务实现类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Slf4j
@Service
public class CommentServiceImpl implements CommentService {
    
    @Autowired
    private CommentMapper commentMapper;
    
    @Autowired
    private DocumentMapper documentMapper;
    
    @Override
    public List<Comment> getCommentsByDocument(Long documentId) {
        try {
            LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Comment::getDocumentId, documentId)
                   .eq(Comment::getStatus, 1) // 只获取正常状态的评论
                   .isNull(Comment::getParentId) // 获取顶级评论
                   .orderByDesc(Comment::getCreatedAt);
            
            List<Comment> comments = commentMapper.selectList(wrapper);
            
            // 为每个顶级评论获取回复
            for (Comment comment : comments) {
                List<Comment> replies = getRepliesByComment(comment.getId());
                comment.setReplies(replies);
            }
            
            log.info("获取文档 {} 的评论列表，共 {} 条顶级评论", documentId, comments.size());
            return comments;
        } catch (Exception e) {
            log.error("获取文档 {} 的评论列表失败: {}", documentId, e.getMessage(), e);
            throw new RuntimeException("获取评论列表失败: " + e.getMessage());
        }
    }
    
    /**
     * 根据父评论ID获取回复
     */
    private List<Comment> getRepliesByComment(Long parentId) {
        try {
            LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Comment::getParentId, parentId)
                   .eq(Comment::getStatus, 1) // 只获取正常状态的评论
                   .orderByAsc(Comment::getCreatedAt);
            
            return commentMapper.selectList(wrapper);
        } catch (Exception e) {
            log.error("获取评论 {} 的回复失败: {}", parentId, e.getMessage(), e);
            throw new RuntimeException("获取评论回复失败: " + e.getMessage());
        }
    }
    
    @Override
    public Comment getCommentById(Long commentId) {
        try {
            Comment comment = commentMapper.selectById(commentId);
            log.info("获取评论 {}，存在: {}", commentId, comment != null);
            return comment;
        } catch (Exception e) {
            log.error("获取评论 {} 失败: {}", commentId, e.getMessage(), e);
            throw new RuntimeException("获取评论失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Comment createComment(Comment comment, Long userId) {
        try {
            // 验证文档是否存在
            Document document = documentMapper.selectById(comment.getDocumentId());
            if (document == null) {
                throw new RuntimeException("文档不存在");
            }
            
            // 设置评论基本信息
            comment.setUserId(userId);
            comment.setStatus(1); // 正常状态
            comment.setCreatedAt(LocalDateTime.now());
            
            // 如果是回复，验证父评论是否存在
            if (comment.getParentId() != null) {
                Comment parentComment = commentMapper.selectById(comment.getParentId());
                if (parentComment == null) {
                    throw new RuntimeException("父评论不存在");
                }
                
                // 确保回复的文档ID与父评论的文档ID一致
                if (!parentComment.getDocumentId().equals(comment.getDocumentId())) {
                    throw new RuntimeException("回复的文档ID与父评论的文档ID不一致");
                }
            }
            
            // 保存评论
            commentMapper.insert(comment);
            
            log.info("用户 {} 创建评论成功，评论ID: {}", userId, comment.getId());
            return comment;
        } catch (Exception e) {
            log.error("用户 {} 创建评论失败: {}", userId, e.getMessage(), e);
            throw new RuntimeException("创建评论失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Comment updateComment(Long commentId, Comment comment, Long userId) {
        try {
            Comment existingComment = commentMapper.selectById(commentId);
            if (existingComment == null) {
                throw new RuntimeException("评论不存在");
            }
            
            // 检查是否为评论作者
            if (!existingComment.getUserId().equals(userId)) {
                throw new RuntimeException("只能修改自己的评论");
            }
            
            // 更新评论内容
            existingComment.setContent(comment.getContent());
            existingComment.setPositionInfo(comment.getPositionInfo()); // 更新位置信息
            existingComment.setUpdatedAt(LocalDateTime.now());
            
            commentMapper.updateById(existingComment);
            
            log.info("用户 {} 更新评论 {} 成功", userId, commentId);
            return existingComment;
        } catch (Exception e) {
            log.error("用户 {} 更新评论 {} 失败: {}", userId, commentId, e.getMessage(), e);
            throw new RuntimeException("更新评论失败: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteComment(Long commentId, Long userId) {
        try {
            Comment comment = commentMapper.selectById(commentId);
            if (comment == null) {
                throw new RuntimeException("评论不存在");
            }
            
            // 检查权限：评论作者或文档所有者可以删除评论
            if (!comment.getUserId().equals(userId)) {
                // 如果不是评论作者，检查是否为文档所有者或有管理权限
                Document document = documentMapper.selectById(comment.getDocumentId());
                if (document == null || !document.getOwnerId().equals(userId)) {
                    throw new RuntimeException("没有权限删除此评论");
                }
            }
            
            // 软删除：将状态设置为0
            comment.setStatus(0);
            comment.setUpdatedAt(LocalDateTime.now());
            commentMapper.updateById(comment);
            
            // 递归删除回复
            deleteReplies(commentId);
            
            log.info("用户 {} 删除评论 {} 成功", userId, commentId);
        } catch (Exception e) {
            log.error("用户 {} 删除评论 {} 失败: {}", userId, commentId, e.getMessage(), e);
            throw new RuntimeException("删除评论失败: " + e.getMessage());
        }
    }
    
    /**
     * 递归删除评论的回复
     */
    private void deleteReplies(Long parentId) {
        try {
            LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Comment::getParentId, parentId);
            
            List<Comment> replies = commentMapper.selectList(wrapper);
            for (Comment reply : replies) {
                // 软删除回复
                reply.setStatus(0);
                reply.setUpdatedAt(LocalDateTime.now());
                commentMapper.updateById(reply);
                
                // 递归删除该回复的回复
                deleteReplies(reply.getId());
            }
        } catch (Exception e) {
            log.error("删除评论回复失败: {}", e.getMessage(), e);
        }
    }
}