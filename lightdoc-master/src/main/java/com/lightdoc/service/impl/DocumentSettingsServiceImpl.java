package com.lightdoc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.lightdoc.dto.DocumentSettingsDTO;
import com.lightdoc.entity.DocumentSettings;
import com.lightdoc.mapper.DocumentSettingsMapper;
import com.lightdoc.service.DocumentService;
import com.lightdoc.service.DocumentSettingsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DocumentSettingsServiceImpl implements DocumentSettingsService {

    private final DocumentSettingsMapper documentSettingsMapper;

    private final DocumentService documentService;

    @Override
    public DocumentSettingsDTO getSettings(Long documentId, Long userId) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.MANAGE_MEMBERS)) {
            throw new RuntimeException("没有权限查看文档设置");
        }

        DocumentSettings settings = documentSettingsMapper.selectOne(
                new LambdaQueryWrapper<DocumentSettings>()
                        .eq(DocumentSettings::getDocumentId, documentId)
        );

        if (settings == null) {
            settings = createDefaultSettings(documentId);
        }

        DocumentSettingsDTO dto = new DocumentSettingsDTO();
        dto.setVersioningEnabled(settings.getVersioningEnabled());
        dto.setMaxVersionCount(settings.getMaxVersionCount());
        dto.setAutosaveEnabled(settings.getAutosaveEnabled());
        dto.setAutosaveIntervalSeconds(settings.getAutosaveIntervalSeconds());
        return dto;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public DocumentSettingsDTO updateSettings(Long documentId, Long userId, DocumentSettingsDTO settingsDTO) {
        if (userId == null || !documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.MANAGE_MEMBERS)) {
            throw new RuntimeException("没有权限修改文档设置");
        }

        DocumentSettings settings = documentSettingsMapper.selectOne(
                new LambdaQueryWrapper<DocumentSettings>()
                        .eq(DocumentSettings::getDocumentId, documentId)
        );

        if (settings == null) {
            settings = createDefaultSettings(documentId);
        }

        if (settingsDTO.getVersioningEnabled() != null) {
            settings.setVersioningEnabled(settingsDTO.getVersioningEnabled());
        }
        if (settingsDTO.getMaxVersionCount() != null) {
            settings.setMaxVersionCount(settingsDTO.getMaxVersionCount());
        }
        if (settingsDTO.getAutosaveEnabled() != null) {
            settings.setAutosaveEnabled(settingsDTO.getAutosaveEnabled());
        }
        if (settingsDTO.getAutosaveIntervalSeconds() != null) {
            settings.setAutosaveIntervalSeconds(settingsDTO.getAutosaveIntervalSeconds());
        }

        settings.setUpdatedAt(LocalDateTime.now());

        if (settings.getId() == null) {
            documentSettingsMapper.insert(settings);
        } else {
            documentSettingsMapper.updateById(settings);
        }

        DocumentSettingsDTO dto = new DocumentSettingsDTO();
        dto.setVersioningEnabled(settings.getVersioningEnabled());
        dto.setMaxVersionCount(settings.getMaxVersionCount());
        dto.setAutosaveEnabled(settings.getAutosaveEnabled());
        dto.setAutosaveIntervalSeconds(settings.getAutosaveIntervalSeconds());
        return dto;
    }

    private DocumentSettings createDefaultSettings(Long documentId) {
        DocumentSettings settings = new DocumentSettings();
        settings.setDocumentId(documentId);
        settings.setVersioningEnabled(true);
        settings.setMaxVersionCount(50);
        settings.setAutosaveEnabled(true);
        settings.setAutosaveIntervalSeconds(5);
        settings.setCreatedAt(LocalDateTime.now());
        settings.setUpdatedAt(LocalDateTime.now());
        documentSettingsMapper.insert(settings);
        return settings;
    }
}

