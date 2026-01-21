package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.DocumentVersion;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 文档版本数据访问层
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Mapper
public interface DocumentVersionMapper extends BaseMapper<DocumentVersion> {
    
    /**
     * 根据文档ID查询所有版本
     * 
     * @param documentId 文档ID
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} ORDER BY version_number DESC")
    List<DocumentVersion> selectByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 根据文档ID和版本号查询版本
     * 
     * @param documentId 文档ID
     * @param versionNumber 版本号
     * @return 版本信息
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} AND version_number = #{versionNumber}")
    DocumentVersion selectByDocumentIdAndVersion(@Param("documentId") Long documentId, @Param("versionNumber") Integer versionNumber);
    
    /**
     * 查询文档的最大版本号
     * 
     * @param documentId 文档ID
     * @return 最大版本号
     */
    @Select("SELECT MAX(version_number) FROM document_versions WHERE document_id = #{documentId}")
    Integer selectMaxVersionByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 统计文档版本数量
     * 
     * @param documentId 文档ID
     * @return 版本数量
     */
    @Select("SELECT COUNT(*) FROM document_versions WHERE document_id = #{documentId}")
    int countByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 根据创建者查询版本
     * 
     * @param createdBy 创建者ID
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE created_by = #{createdBy} ORDER BY created_at DESC")
    List<DocumentVersion> selectByCreatedBy(@Param("createdBy") Long createdBy);
    
    /**
     * 根据版本类型查询版本
     * 
     * @param documentId 文档ID
     * @param versionType 版本类型
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} AND version_type = #{versionType} ORDER BY version_number DESC")
    List<DocumentVersion> selectByDocumentIdAndType(@Param("documentId") Long documentId, @Param("versionType") String versionType);
    
    /**
     * 查询指定时间范围内的版本
     * 
     * @param documentId 文档ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} AND created_at BETWEEN #{startTime} AND #{endTime} ORDER BY version_number DESC")
    List<DocumentVersion> selectByDocumentIdAndTimeRange(@Param("documentId") Long documentId, 
                                                          @Param("startTime") LocalDateTime startTime, 
                                                          @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询最近的版本
     * 
     * @param documentId 文档ID
     * @param limit 限制数量
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} ORDER BY version_number DESC LIMIT #{limit}")
    List<DocumentVersion> selectRecentByDocumentId(@Param("documentId") Long documentId, @Param("limit") int limit);
    
    /**
     * 查询指定版本号之后的版本
     * 
     * @param documentId 文档ID
     * @param afterVersion 版本号
     * @return 版本列表
     */
    @Select("SELECT * FROM document_versions WHERE document_id = #{documentId} AND version_number > #{afterVersion} ORDER BY version_number ASC")
    List<DocumentVersion> selectAfterVersion(@Param("documentId") Long documentId, @Param("afterVersion") Integer afterVersion);
    
    /**
     * 删除指定文档的所有版本
     * 
     * @param documentId 文档ID
     * @return 删除数量
     */
    @Delete("DELETE FROM document_versions WHERE document_id = #{documentId}")
    int deleteByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 删除指定时间之前的版本
     * 
     * @param beforeTime 时间点
     * @return 删除数量
     */
    @Delete("DELETE FROM document_versions WHERE created_at < #{beforeTime}")
    int deleteBeforeTime(@Param("beforeTime") LocalDateTime beforeTime);
    
    /**
     * 更新版本的变更描述
     * 
     * @param id 版本ID
     * @param changeDescription 变更描述
     * @return 更新结果
     */
    @Update("UPDATE document_versions SET change_description = #{changeDescription} WHERE id = #{id}")
    int updateChangeDescription(@Param("id") Long id, @Param("changeDescription") String changeDescription);
    
    /**
     * 统计指定用户的版本数量
     * 
     * @param createdBy 创建者ID
     * @return 版本数量
     */
    @Select("SELECT COUNT(*) FROM document_versions WHERE created_by = #{createdBy}")
    int countByCreatedBy(@Param("createdBy") Long createdBy);
    
    /**
     * 统计指定时间范围内创建的版本数量
     * 
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 版本数量
     */
    @Select("SELECT COUNT(*) FROM document_versions WHERE created_at BETWEEN #{startTime} AND #{endTime}")
    int countByTimeRange(@Param("startTime") LocalDateTime startTime, @Param("endTime") LocalDateTime endTime);
}