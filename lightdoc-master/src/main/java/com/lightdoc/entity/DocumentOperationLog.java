package com.lightdoc.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 文档操作日志实体类
 * 
 * @author lightdoc
 * @since 2025-11-28
 */
@Data
@TableName("document_operation_logs")
public class DocumentOperationLog {
    
    /**
     * 日志ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 文档ID
     */
    @TableField("document_id")
    private Long documentId;
    
    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;
    
    /**
     * 操作类型
     */
    @TableField("operation_type")
    private String operationType;
    
    /**
     * 操作详情
     */
    @TableField("operation_detail")
    private String operationDetail;
    
    /**
     * 操作时间
     */
    @TableField(value = "operation_time", fill = FieldFill.INSERT)
    private LocalDateTime operationTime;
}