-- 更新document_permissions表结构，添加邀请相关字段
-- 执行前请先备份数据库

USE lightdoc;

-- 添加邀请者ID字段
ALTER TABLE `document_permissions` 
ADD COLUMN `inviter_id` bigint DEFAULT NULL COMMENT '邀请者ID' AFTER `granted_at`;

-- 添加邀请时间字段
ALTER TABLE `document_permissions` 
ADD COLUMN `invite_time` datetime DEFAULT NULL COMMENT '邀请时间' AFTER `inviter_id`;

-- 添加邀请状态字段
ALTER TABLE `document_permissions` 
ADD COLUMN `invite_status` varchar(20) DEFAULT NULL COMMENT '邀请状态（pending-待处理，accepted-已接受，rejected-已拒绝）' AFTER `invite_time`;

-- 添加创建时间字段
ALTER TABLE `document_permissions` 
ADD COLUMN `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间' AFTER `invite_status`;

-- 添加更新时间字段
ALTER TABLE `document_permissions` 
ADD COLUMN `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间' AFTER `created_at`;

-- 添加索引以优化查询性能
CREATE INDEX `idx_inviter_id` ON `document_permissions` (`inviter_id`);
CREATE INDEX `idx_invite_status` ON `document_permissions` (`invite_status`);
CREATE INDEX `idx_created_at` ON `document_permissions` (`created_at`);