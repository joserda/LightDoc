package com.lightdoc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lightdoc.dto.KnowledgeBaseDTO;
import com.lightdoc.dto.KnowledgeBaseQueryDTO;
import com.lightdoc.entity.KnowledgeBase;

/**
 * 知识库服务接口
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
public interface KnowledgeBaseService {
    
    /**
     * 创建知识库
     * 
     * @param knowledgeBaseDTO 知识库信息
     * @param userId 用户ID
     * @return 创建的知识库信息
     */
    KnowledgeBaseDTO createKnowledgeBase(KnowledgeBaseDTO knowledgeBaseDTO, Long userId);
    
    /**
     * 获取知识库详情
     * 
     * @param knowledgeBaseId 知识库ID
     * @param userId 用户ID
     * @return 知识库信息
     */
    KnowledgeBaseDTO getKnowledgeBaseDetail(Long knowledgeBaseId, Long userId);
    
    /**
     * 分页查询知识库列表
     * 
     * @param queryDTO 查询条件
     * @param userId 用户ID
     * @return 分页知识库列表
     */
    IPage<KnowledgeBaseDTO> queryKnowledgeBases(KnowledgeBaseQueryDTO queryDTO, Long userId);
    
    /**
     * 更新知识库信息
     * 
     * @param knowledgeBaseId 知识库ID
     * @param knowledgeBaseDTO 知识库信息
     * @param userId 用户ID
     * @return 更新后的知识库信息
     */
    KnowledgeBaseDTO updateKnowledgeBase(Long knowledgeBaseId, KnowledgeBaseDTO knowledgeBaseDTO, Long userId);
    
    /**
     * 删除知识库
     * 
     * @param knowledgeBaseId 知识库ID
     * @param userId 用户ID
     */
    void deleteKnowledgeBase(Long knowledgeBaseId, Long userId);
    
    /**
     * 移动知识库（更改父知识库）
     * 
     * @param knowledgeBaseId 知识库ID
     * @param parentId 新的父知识库ID
     * @param userId 用户ID
     * @return 移动后的知识库信息
     */
    KnowledgeBaseDTO moveKnowledgeBase(Long knowledgeBaseId, Long parentId, Long userId);
    
    /**
     * 检查用户是否有知识库访问权限
     * 
     * @param knowledgeBaseId 知识库ID
     * @param userId 用户ID
     * @param requiredPermission 需要的权限级别（0-读，1-写，2-管理）
     * @return 是否有权限
     */
    boolean hasPermission(Long knowledgeBaseId, Long userId, int requiredPermission);
}