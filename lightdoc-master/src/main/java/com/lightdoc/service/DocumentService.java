package com.lightdoc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lightdoc.dto.DocumentDTO;
import com.lightdoc.dto.DocumentQueryDTO;
import com.lightdoc.entity.Document;

import java.util.List;

/**
 * 文档服务接口
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
public interface DocumentService {
    
    /**
     * 创建文档
     * 
     * @param documentDTO 文档信息
     * @param userId 用户ID
     * @return 文档信息
     */
    DocumentDTO createDocument(DocumentDTO documentDTO, Long userId);
    
    /**
     * 获取文档详情
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 文档信息
     */
    DocumentDTO getDocumentDetail(Long documentId, Long userId);
    
    /**
     * 分页查询文档列表
     * 
     * @param queryDTO 查询条件
     * @param userId 用户ID
     * @return 分页文档列表
     */
    IPage<DocumentDTO> queryDocuments(DocumentQueryDTO queryDTO, Long userId);
    
    /**
     * 更新文档信息
     * 
     * @param documentId 文档ID
     * @param documentDTO 文档信息
     * @param userId 用户ID
     * @return 更新后的文档信息
     */
    DocumentDTO updateDocument(Long documentId, DocumentDTO documentDTO, Long userId);
    
    /**
     * 删除文档
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     */
    void deleteDocument(Long documentId, Long userId);
    
    boolean hasPermission(Long documentId, Long userId, int requiredPermission);

    default boolean hasPermission(Long documentId, Long userId, DocumentPermissionAction action) {
        if (action == null) {
            return false;
        }
        if (action == DocumentPermissionAction.DELETE_DOCUMENT || action == DocumentPermissionAction.TRANSFER_OWNERSHIP) {
            Long ownerId = getDocumentOwnerId(documentId);
            return ownerId != null && ownerId.equals(userId);
        }
        int requiredLevel = switch (action) {
            case VIEW -> 0;
            case COMMENT -> 1;
            case EDIT_CONTENT, SAVE_VERSION -> 2;
            case LOCK_DOCUMENT, MANAGE_MEMBERS, CHANGE_VISIBILITY -> 3;
            default -> 3;
        };
        return hasPermission(documentId, userId, requiredLevel);
    }

    enum DocumentPermissionAction {
        VIEW,
        COMMENT,
        EDIT_CONTENT,
        SAVE_VERSION,
        LOCK_DOCUMENT,
        MANAGE_MEMBERS,
        CHANGE_VISIBILITY,
        DELETE_DOCUMENT,
        TRANSFER_OWNERSHIP
    }
    
    /**
     * 根据ID获取文档实体
     * 
     * @param documentId 文档ID
     * @return 文档实体
     */
    Document getById(Long documentId);
    
    /**
     * 更新文档实体
     * 
     * @param document 文档实体
     * @return 是否更新成功
     */
    boolean updateById(Document document);
    
    /**
     * 获取用户有权限访问的文档ID列表
     * 
     * @param userId 用户ID
     * @return 文档ID列表
     */
    List<Long> getAccessibleDocumentIds(Long userId);
    
    /**
     * 检查文档是否存在
     * 
     * @param documentId 文档ID
     * @return 是否存在
     */
    boolean existsById(Long documentId);
    
    /**
     * 获取文档的拥有者ID
     * 
     * @param documentId 文档ID
     * @return 拥有者ID
     */
    Long getDocumentOwnerId(Long documentId);
    
    /**
     * 更新文档的最后编辑时间和版本号
     * 
     * @param documentId 文档ID
     * @param version 新版本号
     * @return 是否更新成功
     */
    boolean updateLastEditInfo(Long documentId, Integer version);
    
    /**
     * 批量获取文档信息
     * 
     * @param documentIds 文档ID列表
     * @return 文档列表
     */
    List<Document> listByIds(List<Long> documentIds);
    
    /**
     * 检查用户是否为文档拥有者
     * 
     * @param documentId 文档ID
     * @param userId 用户ID
     * @return 是否为拥有者
     */
    boolean isDocumentOwner(Long documentId, Long userId);
    
    /**
     * 获取文档的知识库ID
     * 
     * @param documentId 文档ID
     * @return 知识库ID
     */
    Long getKnowledgeBaseId(Long documentId);
    
    /**
     * 更新文档的ProseMirror JSON内容
     * 
     * @param documentId 文档ID
     * @param proseMirrorJson ProseMirror JSON内容
     * @return 是否更新成功
     */
    boolean updateProseMirrorJson(Long documentId, String proseMirrorJson);
    
    /**
     * 更新文档的Yjs快照信息
     * 
     * @param documentId 文档ID
     * @param snapshotPath 快照路径
     * @param snapshotSize 快照大小
     * @return 是否更新成功
     */
    boolean updateYjsSnapshotInfo(Long documentId, String snapshotPath, Long snapshotSize);
    
    /**
     * 保存文档的Yjs状态
     * 
     * @param documentId 文档ID
     * @param yjsState Yjs二进制状态
     * @param userId 操作用户ID
     * @return 是否保存成功
     */
    boolean saveDocumentYjsState(Long documentId, byte[] yjsState, Long userId);
    
    /**
     * 加载文档的Yjs状态
     * 
     * @param documentId 文档ID
     * @return Yjs二进制状态，如果不存在返回null
     */
    byte[] loadDocumentYjsState(Long documentId);
}
