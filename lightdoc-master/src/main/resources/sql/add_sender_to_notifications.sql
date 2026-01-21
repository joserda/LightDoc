-- 为通知表添加发送者字段
ALTER TABLE notifications ADD COLUMN sender_id BIGINT COMMENT '发送通知的用户ID' AFTER user_id;

-- 为发送者字段添加索引
ALTER TABLE notifications ADD INDEX idx_sender_id (sender_id) COMMENT '发送者ID索引';