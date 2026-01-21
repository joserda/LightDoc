package com.lightdoc.utils;

import io.minio.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;


import java.io.ByteArrayInputStream;
import java.io.InputStream;

@Slf4j
@Component
public class MinioUtil {
    
    @Value("${minio.endpoint}")
    private String endpoint;
    
    @Value("${minio.access-key}")
    private String accessKey;
    
    @Value("${minio.secret-key}")
    private String secretKey;
    
    @Value("${minio.bucket-name}")
    private String bucketName;
    
    private MinioClient minioClient;
    
    public MinioClient getMinioClient() {
        if (minioClient == null) {
            minioClient = MinioClient.builder()
                    .endpoint(endpoint)
                    .credentials(accessKey, secretKey)
                    .build();
        }
        return minioClient;
    }
    
    public boolean bucketExists() {
        try {
            return getMinioClient().bucketExists(
                    BucketExistsArgs.builder().bucket(bucketName).build()
            );
        } catch (Exception e) {
            log.error("检查bucket失败: {}", e.getMessage());
            return false;
        }
    }
    
    public void createBucket() {
        try {
            if (!bucketExists()) {
                getMinioClient().makeBucket(
                        MakeBucketArgs.builder().bucket(bucketName).build()
                );
                log.info("创建bucket成功: {}", bucketName);
            }
        } catch (Exception e) {
            log.error("创建bucket失败: {}", e.getMessage());
        }
    }
    
    
    
    public String uploadFile(byte[] data, String objectName, String contentType) {
        try {
            if (!bucketExists()) {
                createBucket();
            }
            
            ByteArrayInputStream inputStream = new ByteArrayInputStream(data);
            
            getMinioClient().putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .stream(inputStream, data.length, -1)
                            .contentType(contentType)
                            .build()
            );
            
            log.info("文件上传成功: {}", objectName);
            return objectName;
        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage());
            throw new RuntimeException("文件上传失败");
        }
    }
    
    
    
    public InputStream downloadFile(String objectName) {
        try {
            return getMinioClient().getObject(
                    GetObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            log.error("文件下载失败: {}", e.getMessage());
            throw new RuntimeException("文件下载失败");
        }
    }
    
    public void deleteFile(String objectName) {
        try {
            getMinioClient().removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
            log.info("文件删除成功: {}", objectName);
        } catch (Exception e) {
            log.error("文件删除失败: {}", e.getMessage());
            throw new RuntimeException("文件删除失败");
        }
    }
    
    public String getFileUrl(String objectName) {
        try {
            return getMinioClient().getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(io.minio.http.Method.GET)
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            log.error("获取文件URL失败: {}", e.getMessage());
            throw new RuntimeException("获取文件URL失败");
        }
    }
    
    public long getFileSize(String objectName) {
        try {
            StatObjectResponse stat = getMinioClient().statObject(
                    StatObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
            return stat.size();
        } catch (Exception e) {
            log.error("获取文件大小失败: {}", e.getMessage());
            throw new RuntimeException("获取文件大小失败");
        }
    }
}