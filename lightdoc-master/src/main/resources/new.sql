-- 创建数据库
CREATE DATABASE IF NOT EXISTS lightdoc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE lightdoc;

-- 用户表
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `status` tinyint DEFAULT 1 COMMENT '状态（0-禁用，1-启用）',
  `role` varchar(20) DEFAULT 'user' COMMENT '角色（user-普通用户，admin-管理员）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 知识库表（文件夹结构）
CREATE TABLE `knowledge_bases` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '知识库名称',
  `description` text COMMENT '知识库描述',
  `owner_id` bigint NOT NULL COMMENT '所有者ID',
  `parent_id` bigint DEFAULT NULL COMMENT '父知识库ID（用于层级结构）',
  `status` int DEFAULT 0 COMMENT '状态（0-正常，1-已归档，2-已删除）',
  `permission_level` int DEFAULT 0 COMMENT '访问权限级别（0-私有，1-团队可见，2-公开）',
  `is_public` tinyint(1) DEFAULT 0 COMMENT '是否公开',
  `doc_count` int DEFAULT 0 COMMENT '文档数量',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_owner_id` (`owner_id`),
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识库表';

-- 文档表
CREATE TABLE `documents` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL COMMENT '文档标题',
  `original_document_type` varchar(100) DEFAULT NULL COMMENT '原始文档类型',
  `yjs_document_type` varchar(100) DEFAULT 'application/octet-stream' COMMENT 'Yjs快照类型',
  `original_file_path` varchar(500) DEFAULT NULL COMMENT '原始文件存储路径',
  `yjs_snapshot_path` varchar(500) DEFAULT NULL COMMENT 'Yjs快照存储路径',
  `html_preview_content` text COMMENT 'HTML预览内容',
  `prose_mirror_json` longtext COMMENT 'ProseMirror JSON内容',
  `file_size` bigint DEFAULT NULL COMMENT '原始文件大小（字节）',
  `yjs_snapshot_size` bigint DEFAULT NULL COMMENT 'Yjs快照大小（字节）',
  `owner_id` bigint DEFAULT NULL COMMENT '所有者ID',
  `knowledge_base_id` bigint DEFAULT NULL COMMENT '所属知识库ID',
  `status` int DEFAULT NULL COMMENT '文档状态（0-正常，1-草稿，2-已删除）',
  `version` int DEFAULT NULL COMMENT '当前版本号',
  `word_count` int DEFAULT NULL COMMENT '字数统计',
  `tags` varchar(500) DEFAULT NULL COMMENT '标签',
  `permission_level` int DEFAULT NULL COMMENT '访问权限级别（0-私有，1-知识库内可见，2-公开可写）',
  `is_public` tinyint(1) DEFAULT NULL COMMENT '是否公开',
  `summary` varchar(1000) DEFAULT NULL COMMENT '文档摘要',
  `view_count` int DEFAULT NULL COMMENT '阅读次数',
  `last_edit_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最后编辑时间',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_owner_id` (`owner_id`),
  INDEX `idx_knowledge_base_id` (`knowledge_base_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档表';

-- 文档版本表
CREATE TABLE `document_versions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `version_number` int NOT NULL COMMENT '版本号',
  `version_type` varchar(20) NOT NULL DEFAULT 'full' COMMENT '版本类型（full-完整，incremental-增量）',
  `snapshot_path` varchar(500) NOT NULL COMMENT '快照存储路径',
  `snapshot_size` bigint DEFAULT NULL COMMENT '快照大小（字节）',
  `change_description` varchar(1000) DEFAULT NULL COMMENT '变更描述',
  `created_by` bigint NOT NULL COMMENT '创建者ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_document_version` (`document_id`, `version_number`),
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档版本表';

-- 文档设置表
CREATE TABLE `document_settings` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `versioning_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否开启版本历史',
  `max_version_count` int NOT NULL DEFAULT 50 COMMENT '最大保留版本数量',
  `autosave_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否开启自动保存',
  `autosave_interval_seconds` int NOT NULL DEFAULT 5 COMMENT '自动保存间隔（秒）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_document_settings_document` (`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档设置表';

-- 文档资源表
CREATE TABLE `document_resources` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `resource_id` varchar(64) NOT NULL COMMENT '资源唯一标识符',
  `resource_path` varchar(500) NOT NULL COMMENT '资源存储路径',
  `resource_name` varchar(255) NOT NULL COMMENT '资源原始名称',
  `resource_type` varchar(50) NOT NULL COMMENT '资源类型（image/audio/video等）',
  `file_size` bigint DEFAULT NULL COMMENT '文件大小',
  `upload_by` bigint NOT NULL COMMENT '上传用户ID',
  `upload_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_document_resource` (`document_id`, `resource_id`),
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_resource_type` (`resource_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档资源表';

-- 文档权限表
CREATE TABLE `document_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `permission_type` varchar(20) NOT NULL COMMENT '权限类型（read-读，write-写）',
  `permission_level` int NOT NULL DEFAULT 0 COMMENT '权限级别（0-无权限，1-只读，2-读写）',
  `granted_by` bigint NOT NULL COMMENT '授权者ID',
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_document_user_permission` (`document_id`, `user_id`, `permission_type`),
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档权限表';

-- 知识库权限表
CREATE TABLE `knowledge_base_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `knowledge_base_id` bigint NOT NULL COMMENT '知识库ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `permission_type` varchar(20) NOT NULL COMMENT '权限类型（read-读，write-写，manage-管理）',
  `permission_level` int NOT NULL DEFAULT 0 COMMENT '权限级别（0-无权限，1-只读，2-读写，3-管理）',
  `granted_by` bigint NOT NULL COMMENT '授权者ID',
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_kb_user_permission` (`knowledge_base_id`, `user_id`, `permission_type`),
  INDEX `idx_kb_id` (`knowledge_base_id`),
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='知识库权限表';

-- 文档操作日志表
CREATE TABLE `document_operation_logs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `operation_type` varchar(50) NOT NULL COMMENT '操作类型',
  `operation_detail` text COMMENT '操作详情',
  `operation_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_operation_time` (`operation_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档操作日志表';

-- 文档锁定表
CREATE TABLE `document_locks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '锁定用户ID',
  `lock_type` varchar(20) NOT NULL DEFAULT 'edit' COMMENT '锁定类型',
  `lock_expires_at` datetime NOT NULL COMMENT '锁定过期时间',
  `acquired_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '锁定获取时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_document_lock_type` (`document_id`, `lock_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档锁定表';

-- 文档评论表（支持协同编辑评论）
CREATE TABLE `comments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '评论用户ID',
  `content` text NOT NULL COMMENT '评论内容',
  `parent_id` bigint DEFAULT NULL COMMENT '父评论ID（用于回复）',
  `position_info` text COMMENT '位置信息（JSON格式，用于定位评论在文档中的位置）',
  `status` tinyint DEFAULT 1 COMMENT '状态（1-正常，0-已删除）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文档评论表';

-- 插入默认管理员用户
INSERT INTO `users` (`username`, `email`, `password`, `nickname`, `status`, `role`) 
VALUES ('admin', 'admin@example.com', '$2a$10$8K1p/aWqk5pZ4mKiF1x1TOZ.yw8N6p7u27h/Q9d4F7m0vZzQpZ5ZK', '管理员', 1, 'admin');
