package com.lightdoc.utils;

import com.lightdoc.entity.Document;
import com.lightdoc.mapper.DocumentMapper;
import com.lightdoc.mapper.DocumentVersionMapper;
import io.minio.ListObjectsArgs;
import io.minio.Result;
import io.minio.messages.Item;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedDeque;

/**
 * Yjs 文档存储管理器
 * 
 * 负责Yjs文档状态的存储和加载，不负责CRDT合并逻辑。
 * Yjs的CRDT合并由前端处理，后端只负责：
 * 1. 存储Yjs二进制状态到MinIO/OSS
 * 2. 从存储加载Yjs二进制状态
 * 3. 创建文档快照和版本
 * 
 * @author lightdoc
 * @since 2026-01-12
 */
@Slf4j
@Component
public class YjsDocumentManager {
    
    // ==================== 配置参数 ====================
    
    @Value("${minio.bucket-name:light-doc-bucket}")
    private String bucketName;
    
    @Value("${yjs.snapshot.prefix:snapshots/}")
    private String snapshotPrefix;
    
    /** 空文档的Yjs状态（Base64编码，对应 [0, 0]） */
    private static final String EMPTY_YJS_STATE = "AAA=";

    private static final int MAX_RECENT_UPDATES = 200;

    private final ConcurrentHashMap<Long, ConcurrentLinkedDeque<byte[]>> recentUpdates = new ConcurrentHashMap<>();
    
    // ==================== 依赖注入 ====================
    
    @Autowired
    private DocumentMapper documentMapper;
    
    @Autowired
    private DocumentVersionMapper documentVersionMapper;
    
    @Autowired
    private MinioUtil minioUtil;
    
    // ==================== 核心方法 ====================
    
    /**
     * 保存Yjs增量更新
     * 
     * 注意：为了简化实现，这里暂时将增量更新追加到当前的快照中。
     * 在实际生产环境中，应该使用 Yjs 的 mergeUpdates 方法将增量更新合并到文档状态中，
     * 或者将增量更新作为单独的记录存储，定期进行合并。
     * 
     * 由于后端没有 Yjs 运行时（只负责转发和存储），我们这里采用 "Append Only" 或者 "Overwrite" 策略。
     * 考虑到 MinIO 对象存储的特性（不支持追加写入），我们需要：
     * 1. 读取当前状态
     * 2. (理想情况下) 合并更新 - 但后端做不到
     * 3. (妥协方案) 仅仅保存这个 Update 作为最新的状态是不对的，因为 Update 只是增量。
     * 
     * **修正策略**：
     * 由于后端无法合并 CRDT，我们暂时只能将这个 Update 视为一个独立的 "Log" 保存，
     * 或者，我们假设前端会在特定时机（如保存按钮）发送完整的 State。
     * 
     * 但为了响应 `CollaborationSessionManager` 的调用，我们需要提供这个方法。
     * 目前的临时实现是：**忽略增量更新的持久化，只打印日志**。
     * 
     * 真正的数据持久化应该依赖于前端定期发送完整的文档状态（snapshot），
     * 或者后端引入 Java 版的 Yjs 库（如 y-java，但目前不成熟）。
     * 
     * 为了不破坏现有的逻辑，我们先提供一个空实现，或者只做简单的日志记录。
     * 
     * @param documentId 文档ID
     * @param updateData Yjs增量更新数据
     */
    public void saveYjsUpdate(Long documentId, byte[] updateData) {
        if (documentId == null || updateData == null || updateData.length == 0) return;

        try {
            String objectName = generateUpdateStoragePath(documentId);
            minioUtil.uploadFile(updateData, objectName, "application/octet-stream");
        } catch (Exception e) {
            log.warn("持久化Yjs增量更新失败: documentId={}, error={}", documentId, e.getMessage());
        }

        ConcurrentLinkedDeque<byte[]> deque = recentUpdates.computeIfAbsent(documentId, k -> new ConcurrentLinkedDeque<>());
        deque.addLast(Arrays.copyOf(updateData, updateData.length));
        while (deque.size() > MAX_RECENT_UPDATES) {
            deque.pollFirst();
        }

        if (log.isDebugEnabled()) {
            log.debug("收到Yjs增量更新: documentId={}, size={} bytes. (后端暂不支持增量合并，跳过存储)", 
                    documentId, updateData != null ? updateData.length : 0);
        }
    }

    public List<byte[]> getRecentUpdates(Long documentId) {
        if (documentId == null) return Collections.emptyList();
        ConcurrentLinkedDeque<byte[]> deque = recentUpdates.get(documentId);
        if (deque != null && !deque.isEmpty()) {
            return new ArrayList<>(deque);
        }
        return loadRecentUpdatesFromStorage(documentId, MAX_RECENT_UPDATES);
    }

    public void clearRecentUpdates(Long documentId) {
        if (documentId == null) return;

        ConcurrentLinkedDeque<byte[]> deque = recentUpdates.get(documentId);
        if (deque != null) {
            deque.clear();
        }

        String prefix = getUpdatesPrefix(documentId);
        try {
            Iterable<Result<Item>> results = minioUtil.getMinioClient().listObjects(
                    ListObjectsArgs.builder()
                            .bucket(bucketName)
                            .prefix(prefix)
                            .recursive(true)
                            .build()
            );
            for (Result<Item> r : results) {
                try {
                    Item item = r.get();
                    if (item != null && item.objectName() != null) {
                        minioUtil.deleteFile(item.objectName());
                    }
                } catch (Exception ignored) {
                }
            }
        } catch (Exception e) {
            log.warn("清理Yjs增量更新失败: documentId={}, error={}", documentId, e.getMessage());
        }
    }

    /**
     * 保存Yjs文档状态
     * 
     * @param documentId 文档ID
     * @param yjsState Yjs二进制状态（Base64编码）
     * @return 是否保存成功
     */
    public boolean saveYjsState(Long documentId, String yjsState) {
        try {
            log.debug("保存Yjs文档状态: documentId={}, stateSize={}", documentId, yjsState != null ? yjsState.length() : 0);
            
            // 1. 验证参数
            if (documentId == null || yjsState == null || yjsState.isEmpty()) {
                log.warn("保存Yjs状态失败：参数无效");
                return false;
            }
            
            // 2. 解码Base64
            byte[] stateBytes = Base64.getDecoder().decode(yjsState);
            
            // 3. 生成存储路径
            String storagePath = generateStoragePath(documentId, "state");
            
            // 4. 上传到MinIO
            minioUtil.uploadFile(stateBytes, storagePath, "application/octet-stream");
            boolean uploadSuccess = true;
            
            if (!uploadSuccess) {
                log.error("上传Yjs状态到MinIO失败: documentId={}", documentId);
                return false;
            }
            
            // 5. 更新数据库中的快照路径
            Document document = documentMapper.selectById(documentId);
            if (document != null) {
                document.setYjsSnapshotPath(storagePath);
                document.setYjsSnapshotSize((long) stateBytes.length);
                document.setUpdatedAt(LocalDateTime.now());
                documentMapper.updateById(document);
            }
            
            log.info("Yjs文档状态保存成功: documentId={}, path={}, size={}", 
                    documentId, storagePath, stateBytes.length);
            return true;
            
        } catch (Exception e) {
            log.error("保存Yjs文档状态失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 加载Yjs文档状态
     * 
     * @param documentId 文档ID
     * @return Yjs二进制状态（Base64编码），如果不存在返回空文档状态
     */
    public String loadYjsState(Long documentId) {
        try {
            log.debug("加载Yjs文档状态: documentId={}", documentId);
            
            // 1. 查询文档信息
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return EMPTY_YJS_STATE;
            }
            
            // 2. 检查是否有Yjs快照
            if (document.getYjsSnapshotPath() == null || document.getYjsSnapshotPath().isEmpty()) {
                log.info("文档没有Yjs快照，返回空状态: documentId={}", documentId);
                return EMPTY_YJS_STATE;
            }
            
            // 3. 从MinIO下载
            try (InputStream inputStream = minioUtil.downloadFile(document.getYjsSnapshotPath())) {
                if (inputStream == null) {
                    log.warn("无法下载Yjs快照，返回空状态: documentId={}", documentId);
                    return EMPTY_YJS_STATE;
                }
                
                byte[] stateBytes = inputStream.readAllBytes();
                String base64State = Base64.getEncoder().encodeToString(stateBytes);
                
                log.info("Yjs文档状态加载成功: documentId={}, size={}", documentId, stateBytes.length);
                return base64State;
                
            } catch (Exception e) {
                log.error("下载Yjs快照失败: documentId={}, error={}", documentId, e.getMessage(), e);
                return EMPTY_YJS_STATE;
            }
            
        } catch (Exception e) {
            log.error("加载Yjs文档状态失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return EMPTY_YJS_STATE;
        }
    }
    
    /**
     * 创建文档快照
     * 
     * @param documentId 文档ID
     * @param yjsState Yjs二进制状态（Base64编码）
     * @param versionNumber 版本号
     * @param description 版本描述
     * @return 是否创建成功
     */
    public boolean createSnapshot(Long documentId, String yjsState, Integer versionNumber, String description) {
        try {
            log.info("创建文档快照: documentId={}, versionNumber={}", documentId, versionNumber);
            
            // 1. 验证参数
            if (documentId == null || yjsState == null || yjsState.isEmpty()) {
                log.warn("创建快照失败：参数无效");
                return false;
            }
            
            // 2. 解码Base64
            byte[] stateBytes = Base64.getDecoder().decode(yjsState);
            
            // 3. 生成存储路径
            String storagePath = generateStoragePath(documentId, "snapshot_" + versionNumber);
            
            // 4. 上传到MinIO
            minioUtil.uploadFile(stateBytes, storagePath, "application/octet-stream");
            boolean uploadSuccess = true;
            
            if (!uploadSuccess) {
                log.error("上传快照到MinIO失败: documentId={}", documentId);
                return false;
            }
            
            // 5. 创建版本记录
            com.lightdoc.entity.DocumentVersion version = new com.lightdoc.entity.DocumentVersion();
            version.setDocumentId(documentId);
            version.setVersionNumber(versionNumber != null ? versionNumber : 1);
            version.setVersionType("full");
            version.setSnapshotPath(storagePath);
            version.setSnapshotSize((long) stateBytes.length);
            version.setChangeDescription(description);
            version.setCreatedBy(documentMapper.selectById(documentId).getOwnerId());
            version.setCreatedAt(LocalDateTime.now());
            
            documentVersionMapper.insert(version);
            
            log.info("文档快照创建成功: documentId={}, versionNumber={}, path={}", 
                    documentId, versionNumber, storagePath);
            return true;
            
        } catch (Exception e) {
            log.error("创建文档快照失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * 加载文档快照
     * 
     * @param documentId 文档ID
     * @param versionNumber 版本号
     * @return Yjs二进制状态（Base64编码），如果不存在返回null
     */
    public String loadSnapshot(Long documentId, Integer versionNumber) {
        try {
            log.debug("加载文档快照: documentId={}, versionNumber={}", documentId, versionNumber);
            
            // 1. 查询版本记录
            com.lightdoc.entity.DocumentVersion version = documentVersionMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<com.lightdoc.entity.DocumentVersion>()
                    .eq(com.lightdoc.entity.DocumentVersion::getDocumentId, documentId)
                    .eq(com.lightdoc.entity.DocumentVersion::getVersionNumber, versionNumber)
            );
            
            if (version == null) {
                log.warn("版本不存在: documentId={}, versionNumber={}", documentId, versionNumber);
                return null;
            }
            
            // 2. 从MinIO下载
            try (InputStream inputStream = minioUtil.downloadFile(version.getSnapshotPath())) {
                if (inputStream == null) {
                    log.warn("无法下载快照: documentId={}, versionNumber={}", documentId, versionNumber);
                    return null;
                }
                
                byte[] stateBytes = inputStream.readAllBytes();
                String base64State = Base64.getEncoder().encodeToString(stateBytes);
                
                log.info("文档快照加载成功: documentId={}, versionNumber={}, size={}", 
                        documentId, versionNumber, stateBytes.length);
                return base64State;
                
            } catch (Exception e) {
                log.error("下载快照失败: documentId={}, versionNumber={}, error={}", 
                        documentId, versionNumber, e.getMessage(), e);
                return null;
            }
            
        } catch (Exception e) {
            log.error("加载文档快照失败: documentId={}, versionNumber={}, error={}", 
                    documentId, versionNumber, e.getMessage(), e);
            return null;
        }
    }
    
    /**
     * 删除文档的所有Yjs数据
     * 
     * @param documentId 文档ID
     * @return 是否删除成功
     */
    public boolean deleteDocumentData(Long documentId) {
        try {
            log.info("删除文档Yjs数据: documentId={}", documentId);
            
            // 1. 查询文档信息
            Document document = documentMapper.selectById(documentId);
            if (document == null) {
                log.warn("文档不存在: documentId={}", documentId);
                return false;
            }
            
            // 2. 删除Yjs快照
            if (document.getYjsSnapshotPath() != null && !document.getYjsSnapshotPath().isEmpty()) {
                minioUtil.deleteFile(document.getYjsSnapshotPath());
            }
            
            // 3. 删除所有版本快照
            java.util.List<com.lightdoc.entity.DocumentVersion> versions = documentVersionMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<com.lightdoc.entity.DocumentVersion>()
                    .eq(com.lightdoc.entity.DocumentVersion::getDocumentId, documentId)
            );
            
            for (com.lightdoc.entity.DocumentVersion version : versions) {
                if (version.getSnapshotPath() != null && !version.getSnapshotPath().isEmpty()) {
                    minioUtil.deleteFile(version.getSnapshotPath());
                }
            }
            
            log.info("文档Yjs数据删除成功: documentId={}", documentId);
            return true;
            
        } catch (Exception e) {
            log.error("删除文档Yjs数据失败: documentId={}, error={}", documentId, e.getMessage(), e);
            return false;
        }
    }
    
    // ==================== 私有辅助方法 ====================
    
    /**
     * 生成存储路径
     * 
     * @param documentId 文档ID
     * @param type 类型（state/snapshot）
     * @return 存储路径
     */
    private String generateStoragePath(Long documentId, String type) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return String.format("%s%d/%s_%s_%s.bin", snapshotPrefix, documentId, type, timestamp, uuid);
    }

    private String getUpdatesPrefix(Long documentId) {
        return String.format("documents/%d/yjs-updates/", documentId);
    }

    private String generateUpdateStoragePath(Long documentId) {
        String uuid = UUID.randomUUID().toString().substring(0, 8);
        return String.format("%s%d_%s.bin", getUpdatesPrefix(documentId), System.currentTimeMillis(), uuid);
    }

    private List<byte[]> loadRecentUpdatesFromStorage(Long documentId, int limit) {
        try {
            String prefix = getUpdatesPrefix(documentId);
            List<String> objectNames = new ArrayList<>();

            Iterable<Result<Item>> results = minioUtil.getMinioClient().listObjects(
                    ListObjectsArgs.builder()
                            .bucket(bucketName)
                            .prefix(prefix)
                            .recursive(true)
                            .build()
            );
            for (Result<Item> r : results) {
                try {
                    Item item = r.get();
                    if (item != null && item.objectName() != null) {
                        objectNames.add(item.objectName());
                    }
                } catch (Exception ignored) {
                }
            }

            objectNames.sort(Comparator.naturalOrder());
            if (objectNames.size() > limit) {
                objectNames = objectNames.subList(objectNames.size() - limit, objectNames.size());
            }

            List<byte[]> updates = new ArrayList<>();
            for (String objectName : objectNames) {
                try (InputStream in = minioUtil.downloadFile(objectName)) {
                    if (in == null) continue;
                    byte[] bytes = in.readAllBytes();
                    if (bytes.length > 0) {
                        updates.add(bytes);
                    }
                } catch (Exception ignored) {
                }
            }
            return updates;
        } catch (Exception e) {
            return Collections.emptyList();
        }
    }
}
