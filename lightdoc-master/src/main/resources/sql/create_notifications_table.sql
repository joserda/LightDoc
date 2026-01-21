-- 创建通知表
CREATE TABLE IF NOT EXISTS notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知ID',
    user_id BIGINT NOT NULL COMMENT '接收通知的用户ID',
    type VARCHAR(50) NOT NULL COMMENT '通知类型：doc_invite/kb_invite/comment_mention/system_notice等',
    title VARCHAR(200) NOT NULL COMMENT '通知标题',
    content TEXT COMMENT '通知内容',
    related_type VARCHAR(50) COMMENT '关联类型：document/knowledge_base/comment/system',
    related_id BIGINT COMMENT '关联ID，如文档ID、知识库ID、评论ID等',
    is_read TINYINT(1) DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT(1) DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
    INDEX idx_user_id (user_id) COMMENT '用户ID索引',
    INDEX idx_is_read (is_read) COMMENT '已读状态索引',
    INDEX idx_created_at (created_at) COMMENT '创建时间索引',
    INDEX idx_type (type) COMMENT '通知类型索引',
    INDEX idx_user_read (user_id, is_read) COMMENT '用户已读状态复合索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='通知表';