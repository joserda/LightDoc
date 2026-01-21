package com.lightdoc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.lightdoc.entity.DocumentLock;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 文档锁定数据访问层
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Mapper
public interface DocumentLockMapper extends BaseMapper<DocumentLock> {
    
    /**
     * 根据文档ID和锁定类型查询文档锁
     * 
     * @param documentId 文档ID
     * @param lockType 锁定类型
     * @return 文档锁信息
     */
    @Select("SELECT * FROM document_locks WHERE document_id = #{documentId} AND lock_type = #{lockType} AND lock_expires_at > NOW() LIMIT 1")
    DocumentLock selectByDocumentIdAndType(@Param("documentId") Long documentId, @Param("lockType") String lockType);
    
    /**
     * 根据文档ID查询所有有效的文档锁
     * 
     * @param documentId 文档ID
     * @return 文档锁列表
     */
    @Select("SELECT * FROM document_locks WHERE document_id = #{documentId} AND lock_expires_at > NOW() ORDER BY acquired_at DESC")
    List<DocumentLock> selectValidLocksByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 根据用户ID查询文档锁
     * 
     * @param userId 用户ID
     * @return 文档锁列表
     */
    @Select("SELECT * FROM document_locks WHERE user_id = #{userId} AND lock_expires_at > NOW() ORDER BY acquired_at DESC")
    List<DocumentLock> selectByUserId(@Param("userId") Long userId);
    
    /**
     * 查询所有过期的文档锁
     * 
     * @return 过期的文档锁列表
     */
    @Select("SELECT * FROM document_locks WHERE lock_expires_at < NOW() ORDER BY lock_expires_at ASC")
    List<DocumentLock> selectExpiredLocks();
    
    /**
     * 统计文档的有效锁数量
     * 
     * @param documentId 文档ID
     * @return 锁数量
     */
    @Select("SELECT COUNT(*) FROM document_locks WHERE document_id = #{documentId} AND lock_expires_at > NOW()")
    int countValidLocksByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 统计用户的锁数量
     * 
     * @param userId 用户ID
     * @return 锁数量
     */
    @Select("SELECT COUNT(*) FROM document_locks WHERE user_id = #{userId} AND lock_expires_at > NOW()")
    int countValidLocksByUserId(@Param("userId") Long userId);
    
    /**
     * 更新文档锁的过期时间
     * 
     * @param id 锁ID
     * @param expiresAt 新的过期时间
     * @return 更新结果
     */
    @Update("UPDATE document_locks SET lock_expires_at = #{expiresAt} WHERE id = #{id}")
    int updateLockExpires(@Param("id") Long id, @Param("expiresAt") LocalDateTime expiresAt);
    
    /**
     * 删除指定文档的所有锁
     * 
     * @param documentId 文档ID
     * @return 删除数量
     */
    @Delete("DELETE FROM document_locks WHERE document_id = #{documentId}")
    int deleteByDocumentId(@Param("documentId") Long documentId);
    
    /**
     * 删除指定用户的所有锁
     * 
     * @param userId 用户ID
     * @return 删除数量
     */
    @Delete("DELETE FROM document_locks WHERE user_id = #{userId}")
    int deleteByUserId(@Param("userId") Long userId);
    
    /**
     * 删除过期的锁
     * 
     * @return 删除数量
     */
    @Delete("DELETE FROM document_locks WHERE lock_expires_at < NOW()")
    int deleteExpiredLocks();
    
    /**
     * 强制释放文档锁（管理员操作）
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 删除数量
     */
    @Delete("DELETE FROM document_locks WHERE document_id = #{documentId} AND user_id = #{userId}")
    int forceReleaseLock(@Param("documentId") Long documentId, @Param("userId") Long userId);
}