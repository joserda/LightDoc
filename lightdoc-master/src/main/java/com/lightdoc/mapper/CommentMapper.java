package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.Comment;
import org.apache.ibatis.annotations.Mapper;

/**
 * 评论数据访问层
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Mapper
public interface CommentMapper extends BaseMapper<Comment> {
}