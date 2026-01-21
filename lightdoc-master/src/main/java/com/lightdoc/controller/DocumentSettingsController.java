package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.dto.DocumentSettingsDTO;
import com.lightdoc.service.DocumentSettingsService;
import com.lightdoc.utils.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequestMapping("/documents")
@RequiredArgsConstructor
public class DocumentSettingsController {

    private final DocumentSettingsService documentSettingsService;

    @GetMapping("/{documentId}/settings")
    public Result<DocumentSettingsDTO> getDocumentSettings(@PathVariable Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }
            DocumentSettingsDTO dto = documentSettingsService.getSettings(documentId, userId);
            return Result.success(dto);
        } catch (Exception e) {
            log.error("获取文档设置失败: {}", e.getMessage(), e);
            return Result.error("获取文档设置失败: " + e.getMessage());
        }
    }

    @PutMapping("/{documentId}/settings")
    public Result<DocumentSettingsDTO> updateDocumentSettings(@PathVariable Long documentId,
                                                              @RequestBody DocumentSettingsDTO settingsDTO) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }
            DocumentSettingsDTO dto = documentSettingsService.updateSettings(documentId, userId, settingsDTO);
            return Result.success(dto);
        } catch (Exception e) {
            log.error("更新文档设置失败: {}", e.getMessage(), e);
            return Result.error("更新文档设置失败: " + e.getMessage());
        }
    }
}

