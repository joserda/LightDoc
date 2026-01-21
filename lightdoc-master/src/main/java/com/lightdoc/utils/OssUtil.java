package com.lightdoc.utils;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.aliyun.oss.model.OSSObject;
import com.aliyun.oss.model.ObjectMetadata;
import com.aliyun.oss.model.PutObjectRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;


import java.io.ByteArrayInputStream;
import java.io.InputStream;

@Slf4j
@Component
public class OssUtil {

    @Value("${oss.endpoint}")
    private String endpoint;

    @Value("${oss.access-key-id}")
    private String accessKeyId;

    @Value("${oss.access-key-secret}")
    private String accessKeySecret;

    @Value("${oss.bucket-name}")
    private String bucketName;

    private OSS ossClient;

    public OSS getOssClient() {
        if (ossClient == null) {
            ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);
        }
        return ossClient;
    }

    public boolean bucketExists() {
        try {
            return getOssClient().doesBucketExist(bucketName);
        } catch (Exception e) {
            log.error("检查bucket失败: {}", e.getMessage());
            return false;
        }
    }

    public void createBucket() {
        try {
            if (!bucketExists()) {
                getOssClient().createBucket(bucketName);
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

            ObjectMetadata metadata = new ObjectMetadata();
            if (contentType != null) {
                metadata.setContentType(contentType);
            }
            metadata.setContentLength(data.length);

            PutObjectRequest putObjectRequest = new PutObjectRequest(bucketName, objectName, inputStream, metadata);

            getOssClient().putObject(putObjectRequest);

            log.info("文件上传成功: {}", objectName);
            return objectName;
        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage());
            throw new RuntimeException("文件上传失败");
        }
    }

    public InputStream downloadFile(String objectName) {
        try {
            OSSObject ossObject = getOssClient().getObject(bucketName, objectName);
            return ossObject.getObjectContent();
        } catch (Exception e) {
            log.error("文件下载失败: {}", e.getMessage());
            throw new RuntimeException("文件下载失败");
        }
    }

    public void deleteFile(String objectName) {
        try {
            getOssClient().deleteObject(bucketName, objectName);
            log.info("文件删除成功: {}", objectName);
        } catch (Exception e) {
            log.error("文件删除失败: {}", e.getMessage());
            throw new RuntimeException("文件删除失败");
        }
    }

    public String getFileUrl(String objectName) {
        try {
            return "https://" + bucketName + "." + endpoint.replace("https://", "") + "/" + objectName;
        } catch (Exception e) {
            log.error("获取文件URL失败: {}", e.getMessage());
            throw new RuntimeException("获取文件URL失败");
        }
    }

    public boolean fileExists(String objectName) {
        try {
            return getOssClient().doesObjectExist(bucketName, objectName);
        } catch (Exception e) {
            log.error("检查文件是否存在失败: {}", e.getMessage());
            return false;
        }
    }
}
