package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.DocumentOperationLog;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 文档操作日志数据访问层
 * 
 * @author lightdoc
 * @since 2025-12-29
 */
@Mapper
public interface DocumentOperationLogMapper extends BaseMapper<DocumentOperationLog> {
    
    /**
     * 根据文档ID查询操作日志
     * 
     * @param documentId 文档ID
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE document_id = #{documentId} ORDER BY operation_time DESC")
    List<DocumentOperationLog> selectByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 根据用户ID查询操作日志
     * 
     * @param userId 用户ID
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE user_id = #{userId} ORDER BY operation_time DESC")
    List<DocumentOperationLog> selectByUserId(@Param("userId") Long userId);
    
    /**
     * 根据文档ID和用户ID查询操作日志
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE document_id = #{documentId} AND user_id = #{userId} ORDER BY operation_time DESC")
    List<DocumentOperationLog> selectByDocumentIdAndUserId(@Param("documentId") Long documentId, @Param("userId") Long userId);
    
    /**
     * 根据操作类型查询操作日志
     * 
     * @param operationType 操作类型
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE operation_type = #{operationType} ORDER BY operation_time DESC")
    List<DocumentOperationLog> selectByOperationType(@Param("operationType") String operationType);
    
    /**
     * 统计文档操作数量
     * 
     * @param documentId 文档ID
     * @return 操作数量
     */
    @Select("SELECT COUNT(*) FROM document_operation_logs WHERE document_id = #{documentId}")
    int countByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 统计用户操作数量
     * 
     * @param userId 用户ID
     * @return 操作数量
     */
    @Select("SELECT COUNT(*) FROM document_operation_logs WHERE user_id = #{userId}")
    int countByUserId(@Param("userId") Long userId);
    
    /**
     * 统计指定时间范围内的操作数量
     * 
     * @param documentId 文档ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 操作数量
     */
    @Select("SELECT COUNT(*) FROM document_operation_logs WHERE document_id = #{documentId} AND operation_time BETWEEN #{startTime} AND #{endTime}")
    int countByDocumentIdAndTimeRange(@Param("documentId") Long documentId, 
                                      @Param("startTime") LocalDateTime startTime, 
                                      @Param("endTime") LocalDateTime endTime);
    
    /**
     * 查询指定时间范围内的操作日志
     * 
     * @param documentId 文档ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE document_id = #{documentId} AND operation_time BETWEEN #{startTime} AND #{endTime} ORDER BY operation_time DESC")
    List<DocumentOperationLog> selectByDocumentIdAndTimeRange(@Param("documentId") Long documentId, 
                                                              @Param("startTime") LocalDateTime startTime, 
                                                              @Param("endTime") LocalDateTime endTime);
    
    /**
     * 删除指定时间之前的操作日志
     * 
     * @param beforeTime 时间点
     * @return 删除的记录数
     */
    @Delete("DELETE FROM document_operation_logs WHERE operation_time < #{beforeTime}")
    int deleteBeforeTime(@Param("beforeTime") LocalDateTime beforeTime);
    
    /**
     * 查询最近的操作日志
     * 
     * @param documentId 文档ID
     * @param limit 限制数量
     * @return 操作日志列表
     */
    @Select("SELECT * FROM document_operation_logs WHERE document_id = #{documentId} ORDER BY operation_time DESC LIMIT #{limit}")
    List<DocumentOperationLog> selectRecentByDocumentId(@Param("documentId") Long documentId, @Param("limit") int limit);
}