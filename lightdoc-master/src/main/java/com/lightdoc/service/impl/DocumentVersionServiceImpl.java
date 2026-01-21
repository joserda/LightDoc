package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.dto.DocumentVersionDTO;
import com.lightdoc.entity.Document;
import com.lightdoc.entity.DocumentSettings;
import com.lightdoc.entity.DocumentVersion;
import com.lightdoc.entity.User;
import com.lightdoc.mapper.DocumentSettingsMapper;
import com.lightdoc.mapper.DocumentVersionMapper;
import com.lightdoc.mapper.UserMapper;
import com.lightdoc.service.DocumentService;
import com.lightdoc.service.DocumentVersionService;
import com.lightdoc.utils.YjsDocumentManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentVersionServiceImpl implements DocumentVersionService {

    private final DocumentVersionMapper documentVersionMapper;

    private final DocumentSettingsMapper documentSettingsMapper;

    private final DocumentService documentService;

    private final YjsDocumentManager yjsDocumentManager;

    private final UserMapper userMapper;

    @Override
    public List<DocumentVersionDTO> listVersions(Long documentId, Long userId) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
            throw new RuntimeException("没有权限查看版本历史");
        }

        List<DocumentVersion> versions = documentVersionMapper.selectByDocumentId(documentId);
        return versions.stream().map(this::toDTO).collect(Collectors.toList());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DocumentVersionDTO createVersion(Long documentId, Long userId, String yjsState, String description) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.SAVE_VERSION)) {
            throw new RuntimeException("没有权限保存版本");
        }

        DocumentSettings settings = documentSettingsMapper.selectOne(
                new LambdaQueryWrapper<DocumentSettings>()
                        .eq(DocumentSettings::getDocumentId, documentId)
        );

        if (settings == null || settings.getVersioningEnabled() == null || !settings.getVersioningEnabled()) {
            throw new RuntimeException("该文档未开启版本历史");
        }

        Integer maxVersionCount = settings.getMaxVersionCount();
        if (maxVersionCount == null || maxVersionCount <= 0) {
            maxVersionCount = 50;
        }

        Integer maxExisting = documentVersionMapper.selectMaxVersionByDocumentId(documentId);
        int nextVersion = maxExisting != null ? maxExisting + 1 : 1;

        boolean created = yjsDocumentManager.createSnapshot(documentId, yjsState, nextVersion, description);
        if (!created) {
            throw new RuntimeException("创建版本快照失败");
        }

        documentService.updateLastEditInfo(documentId, nextVersion);

        if (maxExisting != null) {
            Long count = (long) documentVersionMapper.countByDocumentId(documentId);
            if (count != null && count > maxVersionCount) {
                int offset = (int) (count - maxVersionCount);
                List<DocumentVersion> toDelete = documentVersionMapper.selectList(
                        new LambdaQueryWrapper<DocumentVersion>()
                                .eq(DocumentVersion::getDocumentId, documentId)
                                .orderByAsc(DocumentVersion::getVersionNumber)
                                .last("limit " + offset)
                );
                for (DocumentVersion v : toDelete) {
                    documentVersionMapper.deleteById(v.getId());
                }
            }
        }

        DocumentVersion version = documentVersionMapper.selectOne(
                new LambdaQueryWrapper<DocumentVersion>()
                        .eq(DocumentVersion::getDocumentId, documentId)
                        .eq(DocumentVersion::getVersionNumber, nextVersion)
        );

        if (version == null) {
            version = new DocumentVersion();
            version.setDocumentId(documentId);
            version.setVersionNumber(nextVersion);
            version.setVersionType("full");
            version.setChangeDescription(description);
            version.setCreatedBy(userId);
            version.setCreatedAt(LocalDateTime.now());
        }

        return toDTO(version);
    }

    @Override
    public String getSnapshot(Long documentId, Integer versionNumber, Long userId) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
            throw new RuntimeException("没有权限查看版本内容");
        }
        return yjsDocumentManager.loadSnapshot(documentId, versionNumber);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean rollbackToVersion(Long documentId, Integer versionNumber, Long userId) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
            throw new RuntimeException("没有权限回滚文档");
        }

        DocumentVersion version = documentVersionMapper.selectOne(
                new LambdaQueryWrapper<DocumentVersion>()
                        .eq(DocumentVersion::getDocumentId, documentId)
                        .eq(DocumentVersion::getVersionNumber, versionNumber)
        );
        if (version == null) {
            throw new RuntimeException("指定版本不存在");
        }

        Document document = documentService.getById(documentId);
        if (document == null) {
            throw new RuntimeException("文档不存在");
        }

        document.setYjsSnapshotPath(version.getSnapshotPath());
        document.setYjsSnapshotSize(version.getSnapshotSize());
        document.setVersion(version.getVersionNumber());
        document.setLastEditTime(LocalDateTime.now());

        return documentService.updateById(document);
    }

    private DocumentVersionDTO toDTO(DocumentVersion version) {
        DocumentVersionDTO dto = new DocumentVersionDTO();
        dto.setVersionNumber(version.getVersionNumber());
        dto.setVersionType(version.getVersionType());
        dto.setSnapshotSize(version.getSnapshotSize());
        dto.setChangeDescription(version.getChangeDescription());
        dto.setCreatedBy(version.getCreatedBy());
        dto.setCreatedAt(version.getCreatedAt());
        if (version.getCreatedBy() != null) {
            User user = userMapper.selectById(version.getCreatedBy());
            if (user != null) {
                dto.setCreatorNickname(user.getNickname());
            }
        }
        return dto;
    }
}
