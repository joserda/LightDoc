package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.lightdoc.dto.DocumentDTO;
import com.lightdoc.dto.DocumentQueryDTO;
import com.lightdoc.entity.Document;
import com.lightdoc.entity.DocumentPermission;
import com.lightdoc.entity.DocumentResource;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.DocumentMapper;
import com.lightdoc.mapper.DocumentPermissionMapper;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.DocumentService;
import com.lightdoc.utils.MinioUtil;
import com.lightdoc.utils.YjsDocumentManager;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;

/**
 * 文档服务实现类
 * 仅保留基础的CRUD功能
 */
@Service
@Slf4j
public class DocumentServiceImpl implements DocumentService {

    @Autowired
    private DocumentMapper documentMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private DocumentPermissionMapper documentPermissionMapper;

    @Autowired
    private MinioUtil minioUtil;

    @Autowired
    private YjsDocumentManager yjsDocumentManager;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DocumentDTO createDocument(DocumentDTO documentDTO, Long userId) {
        log.info("创建文档，用户ID: {}, 标题: {}", userId, documentDTO.getTitle());

        Document document = new Document();
        document.setTitle(documentDTO.getTitle());
        document.setOwnerId(userId);
        document.setKnowledgeBaseId(documentDTO.getKnowledgeBaseId());
        document.setStatus(0); // 正常状态
        document.setVersion(1); // 初始版本为1
        document.setWordCount(0);
        document.setTags(documentDTO.getTags());
        document.setPermissionLevel(documentDTO.getPermissionLevel() != null ? documentDTO.getPermissionLevel() : 0);
        document.setIsPublic(documentDTO.getIsPublic() != null ? documentDTO.getIsPublic() : false);
        document.setViewCount(0);
        document.setCreatedAt(LocalDateTime.now());
        document.setLastEditTime(LocalDateTime.now());
        
        // 为新文档设置默认的ProseMirror JSON内容
        String defaultContent = "{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\"}]}]}";
        document.setProseMirrorJson(defaultContent);

        documentMapper.insert(document);

        log.info("文档创建成功，文档ID: {}", document.getId());
        return convertToDTO(document);
    }

    @Override
    public DocumentDTO getDocumentDetail(Long documentId, Long userId) {
        log.info("查询文档详情，文档ID: {}, 用户ID: {}", documentId, userId);

        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            throw new RuntimeException("文档不存在");
        }

        if (!hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
            throw new RuntimeException("没有权限访问该文档");
        }

        // 更新阅读次数
        document.setViewCount((document.getViewCount() != null ? document.getViewCount() : 0) + 1);
        documentMapper.updateById(document);

        DocumentDTO dto = convertToDTO(document);
        if (userId != null) {
            applyUserCapabilities(dto, userId);
        }
        return dto;
    }

    @Override
    public IPage<DocumentDTO> queryDocuments(DocumentQueryDTO queryDTO, Long userId) {
        log.info("查询文档列表，用户ID: {}, 查询条件: {}", userId, queryDTO);

        Page<Document> page = new Page<>(queryDTO.getPage(), queryDTO.getSize());

        LambdaQueryWrapper<Document> wrapper = new LambdaQueryWrapper<Document>()
                .eq(queryDTO.getKnowledgeBaseId() != null, Document::getKnowledgeBaseId, queryDTO.getKnowledgeBaseId())
                .eq(queryDTO.getOwnerId() != null, Document::getOwnerId, queryDTO.getOwnerId())
                .eq(queryDTO.getStatus() != null, Document::getStatus, queryDTO.getStatus())
                .like(StringUtils.hasText(queryDTO.getTitle()), Document::getTitle, queryDTO.getTitle())
                .eq(StringUtils.hasText(queryDTO.getOriginalDocumentType()), Document::getOriginalDocumentType, queryDTO.getOriginalDocumentType())
                .eq(StringUtils.hasText(queryDTO.getTags()), Document::getTags, queryDTO.getTags())
                .and(w -> w.eq(Document::getOwnerId, userId)
                        .or()
                        .eq(Document::getIsPublic, true)
                        .or(w1 -> w1.exists("SELECT 1 FROM document_permissions p WHERE p.document_id = documents.id AND p.user_id = " + userId + " AND p.permission_level >= 1")));

        IPage<Document> documentPage = documentMapper.selectPage(page, wrapper);

        return documentPage.convert(doc -> {
            DocumentDTO dto = convertToDTO(doc);
            if (userId != null) {
                applyUserCapabilities(dto, userId);
            }
            return dto;
        });
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DocumentDTO updateDocument(Long documentId, DocumentDTO documentDTO, Long userId) {
        log.info("更新文档，文档ID: {}, 用户ID: {}", documentId, userId);

        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            throw new RuntimeException("文档不存在");
        }

        if (!hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
            throw new RuntimeException("没有权限修改该文档");
        }

        if (StringUtils.hasText(documentDTO.getTitle())) {
            document.setTitle(documentDTO.getTitle());
        }
        if (StringUtils.hasText(documentDTO.getTags())) {
            document.setTags(documentDTO.getTags());
        }
        if (documentDTO.getPermissionLevel() != null) {
            document.setPermissionLevel(documentDTO.getPermissionLevel());
        }
        if (documentDTO.getIsPublic() != null) {
            document.setIsPublic(documentDTO.getIsPublic());
        }
        if (StringUtils.hasText(documentDTO.getSummary())) {
            document.setSummary(documentDTO.getSummary());
        }
        if (StringUtils.hasText(documentDTO.getProseMirrorJson())) {
            document.setProseMirrorJson(documentDTO.getProseMirrorJson());
        }
        if (documentDTO.getKnowledgeBaseId() != null) {
            // 检查目标知识库权限
            if (!hasKnowledgeBasePermission(documentDTO.getKnowledgeBaseId(), userId, 1)) {
                throw new RuntimeException("没有权限移动到目标知识库");
            }
            document.setKnowledgeBaseId(documentDTO.getKnowledgeBaseId());
        }

        document.setVersion(document.getVersion() + 1);
        document.setLastEditTime(LocalDateTime.now());
        documentMapper.updateById(document);

        log.info("文档更新成功，文档ID: {}", documentId);
        DocumentDTO dto = convertToDTO(document);
        applyUserCapabilities(dto, userId);
        return dto;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteDocument(Long documentId, Long userId) {
        log.info("删除文档，文档ID: {}, 用户ID: {}", documentId, userId);

        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            throw new RuntimeException("文档不存在");
        }

        if (!hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.DELETE_DOCUMENT)) {
            throw new RuntimeException("没有权限删除该文档");
        }

        // 删除文档权限记录
        documentPermissionMapper.delete(
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId));

        // 删除MinIO中的文件
            if (document.getOriginalFilePath() != null && !document.getOriginalFilePath().isEmpty()) {
                try {
                    minioUtil.deleteFile(document.getOriginalFilePath());
                } catch (Exception e) {
                    log.error("删除MinIO文件失败: {}", e.getMessage());
                }
            }

        // 删除文档
        documentMapper.deleteById(documentId);

        log.info("文档删除成功，文档ID: {}", documentId);
    }

    @Override
    public boolean hasPermission(Long documentId, Long userId, int requiredPermission) {
        if (userId == null) {
            return false;
        }

        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            return false;
        }

        // 检查是否为文档所有者
        if (document.getOwnerId().equals(userId)) {
            return true;
        }

        // 检查文档的公开权限
        if (document.getIsPublic()) {
            if (requiredPermission == 0) {
                return true;
            }
            return document.getPermissionLevel() != null && document.getPermissionLevel() >= requiredPermission;
        }

        // 检查文档特定权限
        DocumentPermission permission = documentPermissionMapper.selectOne(
            new LambdaQueryWrapper<DocumentPermission>()
                .eq(DocumentPermission::getDocumentId, documentId)
                .eq(DocumentPermission::getUserId, userId));

        if (permission != null) {
            return permission.getPermissionLevel() >= requiredPermission;
        }

        // 检查所属知识库的权限
        if (document.getKnowledgeBaseId() != null) {
            return hasKnowledgeBasePermission(document.getKnowledgeBaseId(), userId, requiredPermission);
        }

        return false;
    }

    /**
     * 检查用户对知识库的权限
     */
    private boolean hasKnowledgeBasePermission(Long knowledgeBaseId, Long userId, int requiredPermission) {
        // 这里应该调用知识库权限检查逻辑
        // 为简化，假设存在知识库权限表并进行检查
        // 实际应用中需要实现知识库权限检查
        return true; // 简化实现
    }


    @Transactional(rollbackFor = Exception.class)
    public DocumentDTO updateDocumentJson(Long documentId, String proseMirrorJson, Long userId) {
        if (!hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
            throw new RuntimeException("没有编辑权限");
        }

        Document document = documentMapper.selectById(documentId);
        if (document == null) {
            throw new RuntimeException("文档不存在");
        }

        // 更新ProseMirror JSON内容
        document.setProseMirrorJson(proseMirrorJson);
        document.setLastEditTime(LocalDateTime.now());

        documentMapper.updateById(document);

        DocumentDTO dto = convertToDTO(document);
        applyUserCapabilities(dto, userId);
        return dto;
    }


    /**
     * 提取文本摘要 - 只取前N个字符
     *
     * @param content 文档内容
     * @param maxLength 最大长度
     * @return 文本摘要
     */
    private String extractTextSummary(String content, int maxLength) {
        if (content == null || content.isEmpty()) {
            return "";
        }

        // 移除HTML标签，只保留纯文本
        String textContent = content.replaceAll("<[^>]*>", "");

        // 移除多余的空白字符
        String cleanedContent = textContent.trim().replaceAll("\\s+", " ");

        if (cleanedContent.length() <= maxLength) {
            return cleanedContent;
        }

        // 截取前maxLength个字符
        return cleanedContent.substring(0, maxLength);
    }


@Override
    public List<Document> listByIds(List<Long> documentIds) {
        try {
            if (documentIds == null || documentIds.isEmpty()) {
                return new ArrayList<>();
            }
            
            return documentMapper.selectBatchIds(documentIds);
            
        } catch (Exception e) {
            log.error("批量查询文档失败: documentIds={}, error={}", documentIds, e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    @Override
    public boolean updateLastEditInfo(Long documentId, Integer version) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            document.setLastEditTime(LocalDateTime.now());
            if (version != null) {
                document.setVersion(version);
            }
            
            int result = documentMapper.updateById(document);
            return result > 0;
            
        } catch (Exception e) {
            log.error("更新最后编辑信息失败: documentId={}, version={}, error={}", documentId, version, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public Long getDocumentOwnerId(Long documentId) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return null;
            }
            
            return document.getOwnerId();
            
        } catch (Exception e) {
            log.error("获取文档所有者ID失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return null;
        }
    }

    @Override
    public boolean existsById(Long documentId) {
        try {
            if (documentId == null) {
                return false;
            }
            
            Document document = documentMapper.selectById(documentId);
            return document != null;
            
        } catch (Exception e) {
            log.error("检查文档是否存在失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<Long> getAccessibleDocumentIds(Long userId) {
        try {
            // 查询用户拥有的文档
            LambdaQueryWrapper<Document> ownerQuery = new LambdaQueryWrapper<>();
            ownerQuery.eq(Document::getOwnerId, userId)
                      .select(Document::getId);
            
            List<Long> ownerIds = documentMapper.selectList(ownerQuery).stream()
                    .map(Document::getId)
                    .collect(Collectors.toList());
            
            // 查询有权限的文档
            LambdaQueryWrapper<DocumentPermission> permissionQuery = new LambdaQueryWrapper<>();
            permissionQuery.eq(DocumentPermission::getUserId, userId)
                          .eq(DocumentPermission::getPermissionLevel, 2) // 读写权限
                          .select(DocumentPermission::getDocumentId);
            
            List<Long> permissionIds = documentPermissionMapper.selectList(permissionQuery).stream()
                    .map(DocumentPermission::getDocumentId)
                    .collect(Collectors.toList());
            
            // 合并并去重
            Set<Long> accessibleIds = new HashSet<>();
            accessibleIds.addAll(ownerIds);
            accessibleIds.addAll(permissionIds);
            
            return new ArrayList<>(accessibleIds);
            
        } catch (Exception e) {
            log.error("获取可访问文档ID列表失败: userId={}, error={}", userId, e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    @Override
    public Document getById(Long documentId) {
        try {
            if (documentId == null) {
                log.warn("文档ID为null");
                return null;
            }
            
            return documentMapper.selectById(documentId);
            
        } catch (Exception e) {
            log.error("获取文档失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return null;
        }
    }

    @Override
    public boolean updateById(Document document) {
        try {
            if (document == null) {
                log.warn("文档对象为null");
                return false;
            }
            
            int result = documentMapper.updateById(document);
            return result > 0;
            
        } catch (Exception e) {
            log.error("更新文档失败: documentId={}, error={}", document.getId(), e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean isDocumentOwner(Long documentId, Long userId) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            return Objects.equals(document.getOwnerId(), userId);
            
        } catch (Exception e) {
            log.error("检查文档所有权失败: documentId={}, userId={}, error={}", documentId, userId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public Long getKnowledgeBaseId(Long documentId) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return null;
            }
            
            return document.getKnowledgeBaseId();
            
        } catch (Exception e) {
            log.error("获取知识库ID失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return null;
        }
    }

    @Override
    public boolean updateProseMirrorJson(Long documentId, String proseMirrorJson) {
        // 该方法不进行权限检查，直接更新文档
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            document.setProseMirrorJson(proseMirrorJson);
            document.setLastEditTime(LocalDateTime.now());
            
            int result = documentMapper.updateById(document);
            return result > 0;
            
        } catch (Exception e) {
            log.error("更新ProseMirror JSON失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateYjsSnapshotInfo(Long documentId, String snapshotPath, Long snapshotSize) {
        try {
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            document.setYjsSnapshotPath(snapshotPath);
            document.setYjsSnapshotSize(snapshotSize);
            document.setLastEditTime(LocalDateTime.now());
            
            int result = documentMapper.updateById(document);
            return result > 0;
            
        } catch (Exception e) {
            log.error("更新Yjs快照信息失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveDocumentYjsState(Long documentId, byte[] yjsState, Long userId) {
        try {
            log.info("保存文档Yjs状态: documentId={}, userId={}, stateSize={}", 
                    documentId, userId, yjsState.length);
            
            // 1. 检查文档是否存在
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            // 2. 生成快照路径
            String snapshotPath = String.format("documents/%d/yjs-snapshots/%d.bin", 
                    documentId, System.currentTimeMillis());
            
            // 3. 上传Yjs状态到MinIO
            minioUtil.uploadFile(yjsState, snapshotPath, "application/octet-stream");
            
            // 4. 更新文档记录
            document.setYjsSnapshotPath(snapshotPath);
            document.setYjsSnapshotSize((long) yjsState.length);
            document.setLastEditTime(LocalDateTime.now());
            
            int result = documentMapper.updateById(document);

            yjsDocumentManager.clearRecentUpdates(documentId);
            
            log.info("文档Yjs状态保存成功: documentId={}, path={}", documentId, snapshotPath);
            return result > 0;
            
        } catch (Exception e) {
            log.error("保存文档Yjs状态失败: documentId={}, userId={}, error={}", 
                    documentId, userId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public byte[] loadDocumentYjsState(Long documentId) {
        try {
            log.debug("加载文档Yjs状态: documentId={}", documentId);
            
            // 1. 获取文档信息
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return null;
            }
            
            // 2. 检查是否有Yjs快照
            String snapshotPath = document.getYjsSnapshotPath();
            if (snapshotPath == null || snapshotPath.isEmpty()) {
                log.debug("文档没有Yjs快照: documentId={}", documentId);
                return null;
            }
            
            // 3. 从MinIO下载Yjs状态
            byte[] yjsState = minioUtil.downloadFile(snapshotPath).readAllBytes();
            
            log.debug("文档Yjs状态加载成功: documentId={}, size={}", documentId, yjsState.length);
            return yjsState;
            
        } catch (Exception e) {
            log.error("加载文档Yjs状态失败: documentId={}, error={}", 
                    documentId, e.getMessage(), e);
            return null;
        }
    }

    private void applyUserCapabilities(DocumentDTO dto, Long userId) {
        Long documentId = dto.getId();
        if (documentId == null || userId == null) {
            return;
        }

        boolean canView = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW);
        boolean canComment = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.COMMENT);
        boolean canEdit = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT);
        boolean canSaveVersion = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.SAVE_VERSION);
        boolean canLock = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.LOCK_DOCUMENT);
        boolean canManageMembers = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.MANAGE_MEMBERS);
        boolean canChangeVisibility = hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.CHANGE_VISIBILITY);

        dto.setCanView(canView);
        dto.setCanComment(canComment);
        dto.setCanEdit(canEdit);
        dto.setCanSaveVersion(canSaveVersion);
        dto.setCanLock(canLock);
        dto.setCanManageMembers(canManageMembers);
        dto.setCanChangeVisibility(canChangeVisibility);
        dto.setIsOwner(dto.getOwnerId() != null && dto.getOwnerId().equals(userId));
    }

    private DocumentDTO convertToDTO(Document document) {
        DocumentDTO dto = new DocumentDTO();
        BeanUtils.copyProperties(document, dto);
        if (document.getOwnerId() != null) {
            User user = userMapper.selectById(document.getOwnerId());
            if (user != null) {
                dto.setOwnerNickname(user.getNickname());
            }
        }
        
        // 设置ProseMirror JSON内容
        dto.setProseMirrorJson(document.getProseMirrorJson());
        
        return dto;
    }
}
