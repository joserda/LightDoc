package com.lightdoc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.lightdoc.common.Result;
import com.lightdoc.dto.DocumentDTO;
import com.lightdoc.dto.DocumentQueryDTO;
import com.lightdoc.service.DocumentService;
import com.lightdoc.utils.MinioUtil;
import com.lightdoc.utils.SecurityUtils;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * 文档管理控制器
 * 
 * @author lightdoc
 * @since 2025-11-27
 */
@Slf4j
@RestController
@RequestMapping("/documents")
public class DocumentController {

    private final DocumentService documentService;

    private final MinioUtil minioUtil;

    public DocumentController(DocumentService documentService, MinioUtil minioUtil) {
        this.documentService = documentService;
        this.minioUtil = minioUtil;
    }


    /**
     * 创建文档
     *
     * @param documentDTO 文档信息
     * @return 创建结果
     */
    @PostMapping
    public Result<DocumentDTO> createDocument(@RequestBody DocumentDTO documentDTO) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            DocumentDTO result = documentService.createDocument(documentDTO, userId);
            return Result.success(result);

        } catch (Exception e) {
            log.error("创建文档失败: {}", e.getMessage(), e);
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 获取文档详情
     *
     * @param documentId 文档ID
     * @return 文档详情
     */
    @GetMapping("/{documentId}")
    public Result<DocumentDTO> getDocumentDetail(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();

            DocumentDTO documentDTO = documentService.getDocumentDetail(documentId, userId);
            return Result.success(documentDTO);

        } catch (Exception e) {
            log.error("获取文档详情失败: {}", e.getMessage(), e);
            return Result.error("获取失败: " + e.getMessage());
        }
    }

    @GetMapping("/{documentId}/download")
    public ResponseEntity<InputStreamResource> downloadDocument(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            DocumentDTO documentDTO = documentService.getDocumentDetail(documentId, userId);
            String originalFilePath = documentDTO.getOriginalFilePath();
            if (originalFilePath == null || originalFilePath.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            InputStream inputStream = minioUtil.downloadFile(originalFilePath);
            InputStreamResource resource = new InputStreamResource(inputStream);

            String baseName = documentDTO.getTitle() != null ? documentDTO.getTitle() : "document";
            String extension = "";
            if (documentDTO.getOriginalDocumentType() != null && !documentDTO.getOriginalDocumentType().isEmpty()) {
                extension = "." + documentDTO.getOriginalDocumentType();
            }
            String filename = baseName + extension;
            String encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");

            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFilename);

            return ResponseEntity
                    .ok()
                    .headers(headers)
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(resource);
        } catch (Exception e) {
            log.error("下载文档失败: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 下载文档的 ProseMirror JSON 内容
     *
     * @param documentId 文档ID
     * @return JSON 文件
     */
    @GetMapping("/{documentId}/json-download")
    public ResponseEntity<byte[]> downloadDocumentJson(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return ResponseEntity.status(401).build();
            }

            DocumentDTO documentDTO = documentService.getDocumentDetail(documentId, userId);
            String proseMirrorJson = documentDTO.getProseMirrorJson();
            if (proseMirrorJson == null) {
                proseMirrorJson = "";
            }

            String baseName = documentDTO.getTitle() != null ? documentDTO.getTitle() : "document";
            String filename = baseName + ".json";
            String encodedFilename = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");

            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFilename);

            byte[] bytes = proseMirrorJson.getBytes(StandardCharsets.UTF_8);
            return ResponseEntity
                    .ok()
                    .headers(headers)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(bytes);
        } catch (Exception e) {
            log.error("下载文档JSON失败: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * 分页查询文档列表
     *
     * @param queryDTO 查询条件
     * @return 文档列表
     */
    @GetMapping
    public Result<IPage<DocumentDTO>> queryDocuments(@Valid DocumentQueryDTO queryDTO) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();

            IPage<DocumentDTO> page = documentService.queryDocuments(queryDTO, userId);
            return Result.success(page);

        } catch (Exception e) {
            log.error("查询文档列表失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 更新文档信息
     *
     * @param documentId  文档ID
     * @param documentDTO 文档信息
     * @return 更新后的文档信息
     */
    @PutMapping("/{documentId}")
    public Result<DocumentDTO> updateDocument(
            @PathVariable("documentId") Long documentId,
            @RequestBody DocumentDTO documentDTO) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            DocumentDTO result = documentService.updateDocument(documentId, documentDTO, userId);
            return Result.success(result);

        } catch (Exception e) {
            log.error("更新文档失败: {}", e.getMessage(), e);
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 删除文档
     *
     * @param documentId 文档ID
     * @return 删除结果
     */
    @DeleteMapping("/{documentId}")
    public Result<Void> deleteDocument(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            documentService.deleteDocument(documentId, userId);
            return Result.success();

        } catch (Exception e) {
            log.error("删除文档失败: {}", e.getMessage(), e);
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    @PostMapping("/{documentId}/restore")
    public Result<Void> restoreDocument(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            documentService.restoreDocument(documentId, userId);
            return Result.success();

        } catch (Exception e) {
            log.error("恢复文档失败: {}", e.getMessage(), e);
            return Result.error("恢复失败: " + e.getMessage());
        }
    }

    @DeleteMapping("/{documentId}/permanent")
    public Result<Void> deleteDocumentPermanently(@PathVariable("documentId") Long documentId) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            documentService.deleteDocumentPermanently(documentId, userId);
            return Result.success();

        } catch (Exception e) {
            log.error("彻底删除文档失败: {}", e.getMessage(), e);
            return Result.error("彻底删除失败: " + e.getMessage());
        }
    }

    /**
     * 更新文档ProseMirror JSON内容
     *
     * @param documentId  文档ID
     * @param requestBody 请求体，包含proseMirrorJson字段
     * @return 更新结果
     */
    @PutMapping("/{documentId}/json")
    public Result<DocumentDTO> updateDocumentJson(
            @PathVariable("documentId") Long documentId,
            @RequestBody UpdateJsonRequest requestBody) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                return Result.error("没有权限编辑此文档");
            }

            // 首先更新ProseMirror JSON
            boolean updated = documentService.updateProseMirrorJson(documentId, requestBody.getProseMirrorJson());
            if (!updated) {
                return Result.error("更新文档内容失败");
            }

            // 返回更新后的文档详情
            DocumentDTO result = documentService.getDocumentDetail(documentId, userId);
            return Result.success(result);
        } catch (Exception e) {
            log.error("更新文档JSON失败: {}", e.getMessage(), e);
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 用于接收更新文档JSON内容的请求
     */
    @Data
    private static class UpdateJsonRequest {
        private String proseMirrorJson;
    }

    @PostMapping("/{documentId}/images")
    public Result<Map<String, String>> uploadDocumentImage(
            @PathVariable("documentId") Long documentId,
            @RequestParam("file") MultipartFile file) {
        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                return Result.error("没有权限编辑此文档");
            }

            if (file == null || file.isEmpty()) {
                return Result.error("上传文件不能为空");
            }

            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null) {
                int dotIndex = originalFilename.lastIndexOf('.');
                if (dotIndex >= 0) {
                    extension = originalFilename.substring(dotIndex);
                }
            }

            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String uuid = UUID.randomUUID().toString().substring(0, 8);
            String objectName = String.format("documents/%d/images/%s_%s%s", documentId, timestamp, uuid, extension);

            byte[] data = file.getBytes();
            String contentType = file.getContentType();
            if (contentType == null || contentType.isEmpty()) {
                contentType = "application/octet-stream";
            }

            minioUtil.uploadFile(data, objectName, contentType);
            String url = minioUtil.getFileUrl(objectName);

            Map<String, String> responseData = new HashMap<>();
            responseData.put("url", url);
            responseData.put("objectName", objectName);
            responseData.put("name", originalFilename != null ? originalFilename : "");

            return Result.success(responseData);
        } catch (Exception e) {
            log.error("上传文档图片失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return Result.error("上传图片失败: " + e.getMessage());
        }
    }

    /**
     * 保存文档的Yjs状态
     *
     * @param documentId 文档ID
     * @param requestBody 请求体，包含yjsState字段（Base64编码）
     * @return 保存结果
     */
    @PostMapping("/{documentId}/yjs-state")
    public Result<Boolean> saveDocumentYjsState(
            @PathVariable("documentId") Long documentId,
            @RequestBody SaveYjsStateRequest requestBody) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.EDIT_CONTENT)) {
                return Result.error("没有权限编辑此文档");
            }

            if (requestBody == null || requestBody.getYjsState() == null || requestBody.getYjsState().isEmpty()) {
                return Result.error("yjsState 不能为空");
            }

            byte[] yjsStateBytes;
            try {
                yjsStateBytes = java.util.Base64.getDecoder().decode(requestBody.getYjsState());
            } catch (IllegalArgumentException e) {
                return Result.error("yjsState Base64 解码失败");
            }

            // 保存Yjs状态
            boolean saved = documentService.saveDocumentYjsState(documentId, 
                    yjsStateBytes, userId);
            
            if (!saved) {
                return Result.error("保存Yjs状态失败");
            }

            return Result.success(true);
        } catch (Exception e) {
            log.error("保存Yjs状态失败: {}", e.getMessage(), e);
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 加载文档的Yjs状态
     *
     * @param documentId 文档ID
     * @return Yjs状态（Base64编码）
     */
    @GetMapping("/{documentId}/yjs-state")
    public Result<String> loadDocumentYjsState(
            @PathVariable("documentId") Long documentId) {

        try {
            Long userId = SecurityUtils.getCurrentUserId();
            if (userId == null) {
                return Result.error("用户未登录");
            }

            if (!documentService.hasPermission(documentId, userId, DocumentService.DocumentPermissionAction.VIEW)) {
                return Result.error("没有权限访问此文档");
            }

            // 加载Yjs状态
            byte[] yjsStateBytes = documentService.loadDocumentYjsState(documentId);
            
            if (yjsStateBytes != null) {
                String base64State = java.util.Base64.getEncoder().encodeToString(yjsStateBytes);
                return Result.success(base64State);
            } else {
                return Result.success(""); // 返回空字符串表示没有Yjs状态
            }
        } catch (Exception e) {
            log.error("加载Yjs状态失败: {}", e.getMessage(), e);
            return Result.error("加载失败: " + e.getMessage());
        }
    }

    /**
     * 用于接收保存Yjs状态的请求
     */
    @Data
    private static class SaveYjsStateRequest {
        private String yjsState;
    }
}
