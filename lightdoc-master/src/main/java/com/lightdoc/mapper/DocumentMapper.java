package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.Document;
import org.apache.ibatis.annotations.Mapper;

/**
 * 文档数据访问层
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Mapper
public interface DocumentMapper extends BaseMapper<Document> {
}