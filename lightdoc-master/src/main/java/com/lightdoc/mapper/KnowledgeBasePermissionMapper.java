package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.KnowledgeBasePermission;
import org.apache.ibatis.annotations.Mapper;

/**
 * 知识库权限数据访问层
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Mapper
public interface KnowledgeBasePermissionMapper extends BaseMapper<KnowledgeBasePermission> {
}