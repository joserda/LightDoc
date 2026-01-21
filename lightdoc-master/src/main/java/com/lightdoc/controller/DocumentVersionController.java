package com.lightdoc.controller;

import com.lightdoc.common.Result;
import com.lightdoc.dto.DocumentVersionDTO;
import com.lightdoc.service.DocumentVersionService;
import com.lightdoc.service.DocumentService;
import com.lightdoc.utils.SecurityUtils;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/documents")
@RequiredArgsConstructor
public class DocumentVersionController {

    private final DocumentVersionService documentVersionService;

    private final DocumentService documentService;

    @GetMapping("/{documentId}/versions")
    public Result<List<DocumentVersionDTO>> listVersions(@PathVariable Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }
            List<DocumentVersionDTO> versions = documentVersionService.listVersions(documentId, userId);
            return Result.success(versions);
        } catch (Exception e) {
            log.error("获取版本历史失败: {}", e.getMessage(), e);
            return Result.error("获取版本历史失败: " + e.getMessage());
        }
    }

    @PostMapping("/{documentId}/versions")
    public Result<DocumentVersionDTO> createVersion(@PathVariable Long documentId,
                                                    @RequestBody CreateVersionRequest request) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }
            DocumentVersionDTO dto = documentVersionService.createVersion(
                    documentId, userId, request.getYjsState(), request.getDescription());
            return Result.success(dto);
        } catch (Exception e) {
            log.error("创建文档版本失败: {}", e.getMessage(), e);
            return Result.error("创建文档版本失败: " + e.getMessage());
        }
    }

    @GetMapping("/{documentId}/versions/{versionNumber}/snapshot")
    public Result<String> getSnapshot(@PathVariable Long documentId, @PathVariable Integer versionNumber) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }
            String base64 = documentVersionService.getSnapshot(documentId, versionNumber, userId);
            if (base64 == null) {
                return Result.error("版本快照不存在");
            }
            return Result.success(base64);
        } catch (Exception e) {
            log.error("获取版本快照失败: {}", e.getMessage(), e);
            return Result.error("获取版本快照失败: " + e.getMessage());
        }
    }

    @PostMapping("/{documentId}/versions/{versionNumber}/rollback")
    public Result<Boolean> rollback(
            @PathVariable Long documentId,
            @PathVariable Integer versionNumber) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                return Result.error("没有权限回滚此文档");
            }

            boolean ok = documentVersionService.rollbackToVersion(documentId, versionNumber, userId);
            if (!ok) {
                return Result.error("回滚失败");
            }
            return Result.success(true);
        } catch (Exception e) {
            log.error("回滚文档版本失败: {}", e.getMessage(), e);
            return Result.error("回滚文档版本失败: " + e.getMessage());
        }
    }

    @Data
    private static class CreateVersionRequest {
        private String yjsState;
        private String description;
    }
}
