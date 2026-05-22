/*
 Navicat Premium Dump SQL

 Source Server         : 本机mysql80
 Source Server Type    : MySQL
 Source Server Version : 80040 (8.0.40)
 Source Host           : localhost:3306
 Source Schema         : light_doc

 Target Server Type    : MySQL
 Target Server Version : 80040 (8.0.40)
 File Encoding         : 65001

 Date: 23/03/2026 20:57:38
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '评论用户ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父评论ID（用于回复）',
  `position_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '位置信息（JSON格式，用于定位评论在文档中的位置）',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态（1-正常，0-已删除）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_locks
-- ----------------------------
DROP TABLE IF EXISTS `document_locks`;
CREATE TABLE `document_locks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '锁定用户ID',
  `lock_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'edit' COMMENT '锁定类型',
  `lock_expires_at` datetime NOT NULL COMMENT '锁定过期时间',
  `acquired_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '锁定获取时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_document_lock_type`(`document_id` ASC, `lock_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档锁定表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_operation_logs
-- ----------------------------
DROP TABLE IF EXISTS `document_operation_logs`;
CREATE TABLE `document_operation_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `operation_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '操作类型',
  `operation_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '操作详情',
  `operation_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_operation_time`(`operation_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1747 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_permissions
-- ----------------------------
DROP TABLE IF EXISTS `document_permissions`;
CREATE TABLE `document_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限类型（read-读，write-写）',
  `permission_level` int NOT NULL DEFAULT 0 COMMENT '权限级别（0-无权限，1-只读，2-读写）',
  `granted_by` bigint NOT NULL COMMENT '授权者ID',
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  `inviter_id` bigint NULL DEFAULT NULL COMMENT '邀请者ID',
  `invite_time` datetime NULL DEFAULT NULL COMMENT '邀请时间',
  `invite_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邀请状态',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_document_user_permission`(`document_id` ASC, `user_id` ASC, `permission_type` ASC) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_resources
-- ----------------------------
DROP TABLE IF EXISTS `document_resources`;
CREATE TABLE `document_resources`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `resource_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源唯一标识符',
  `resource_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源存储路径',
  `resource_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源原始名称',
  `resource_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '资源类型（image/audio/video等）',
  `file_size` bigint NULL DEFAULT NULL COMMENT '文件大小',
  `upload_by` bigint NOT NULL COMMENT '上传用户ID',
  `upload_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_document_resource`(`document_id` ASC, `resource_id` ASC) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_resource_type`(`resource_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 65 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档资源表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_settings
-- ----------------------------
DROP TABLE IF EXISTS `document_settings`;
CREATE TABLE `document_settings`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `versioning_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否开启版本历史',
  `max_version_count` int NOT NULL DEFAULT 50 COMMENT '最大保留版本数量',
  `autosave_enabled` tinyint(1) NOT NULL DEFAULT 1 COMMENT '是否开启自动保存',
  `autosave_interval_seconds` int NOT NULL DEFAULT 5 COMMENT '自动保存间隔（秒）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_document_settings_document`(`document_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档设置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for document_versions
-- ----------------------------
DROP TABLE IF EXISTS `document_versions`;
CREATE TABLE `document_versions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `document_id` bigint NOT NULL COMMENT '文档ID',
  `version_number` int NOT NULL COMMENT '版本号',
  `version_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'full' COMMENT '版本类型（full-完整，incremental-增量）',
  `snapshot_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '快照存储路径',
  `snapshot_size` bigint NULL DEFAULT NULL COMMENT '快照大小（字节）',
  `change_description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '变更描述',
  `created_by` bigint NOT NULL COMMENT '创建者ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_document_version`(`document_id` ASC, `version_number` ASC) USING BTREE,
  INDEX `idx_document_id`(`document_id` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档版本表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for documents
-- ----------------------------
DROP TABLE IF EXISTS `documents`;
CREATE TABLE `documents`  (
  `prose_mirror_json` json NULL COMMENT '文档的ProseMirrorJson格式内容',
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文档标题',
  `original_document_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原始文档类型',
  `yjs_document_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'application/octet-stream' COMMENT 'Yjs快照类型',
  `original_file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原始文件存储路径',
  `yjs_snapshot_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Yjs快照存储路径',
  `html_preview_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'HTML预览内容',
  `file_size` bigint NULL DEFAULT NULL COMMENT '原始文件大小（字节）',
  `yjs_snapshot_size` bigint NULL DEFAULT NULL COMMENT 'Yjs快照大小（字节）',
  `owner_id` bigint NULL DEFAULT NULL COMMENT '所有者ID',
  `knowledge_base_id` bigint NULL DEFAULT NULL COMMENT '所属知识库ID',
  `status` int NULL DEFAULT NULL COMMENT '文档状态（0-正常，1-草稿，2-已删除）',
  `version` int NULL DEFAULT NULL COMMENT '当前版本号',
  `word_count` int NULL DEFAULT NULL COMMENT '字数统计',
  `tags` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标签',
  `permission_level` int NULL DEFAULT NULL COMMENT '访问权限级别（0-私有，1-知识库内可见，2-公开可写）',
  `is_public` tinyint(1) NULL DEFAULT NULL COMMENT '是否公开',
  `summary` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '文档摘要',
  `view_count` int NULL DEFAULT NULL COMMENT '阅读次数',
  `last_edit_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后编辑时间',
  `created_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_owner_id`(`owner_id` ASC) USING BTREE,
  INDEX `idx_knowledge_base_id`(`knowledge_base_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文档表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for knowledge_base_permissions
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_base_permissions`;
CREATE TABLE `knowledge_base_permissions`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `knowledge_base_id` bigint NOT NULL COMMENT '知识库ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `permission_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限类型（read-读，write-写，manage-管理）',
  `permission_level` int NOT NULL DEFAULT 0 COMMENT '权限级别（0-无权限，1-只读，2-读写，3-管理）',
  `granted_by` bigint NOT NULL COMMENT '授权者ID',
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '授权时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_kb_user_permission`(`knowledge_base_id` ASC, `user_id` ASC, `permission_type` ASC) USING BTREE,
  INDEX `idx_kb_id`(`knowledge_base_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '知识库权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for knowledge_bases
-- ----------------------------
DROP TABLE IF EXISTS `knowledge_bases`;
CREATE TABLE `knowledge_bases`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '知识库名称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '知识库描述',
  `owner_id` bigint NOT NULL COMMENT '所有者ID',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父知识库ID（用于层级结构）',
  `status` int NULL DEFAULT 0 COMMENT '状态（0-正常，1-已归档，2-已删除）',
  `permission_level` int NULL DEFAULT 0 COMMENT '访问权限级别（0-私有，1-团队可见，2-公开）',
  `is_public` tinyint(1) NULL DEFAULT 0 COMMENT '是否公开',
  `doc_count` int NULL DEFAULT 0 COMMENT '文档数量',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_owner_id`(`owner_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '知识库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` bigint NOT NULL COMMENT '接收通知的用户ID',
  `sender_id` bigint NULL DEFAULT NULL COMMENT '发送通知的用户ID',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知类型：doc_invite/kb_invite/comment_mention/system_notice等',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '通知标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '通知内容',
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '关联类型：document/knowledge_base/comment/system',
  `related_id` bigint NULL DEFAULT NULL COMMENT '关联ID，如文档ID、知识库ID、评论ID等',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读：0-未读，1-已读',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` tinyint(1) NULL DEFAULT 0 COMMENT '是否删除：0-未删除，1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE COMMENT '用户ID索引',
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE COMMENT '已读状态索引',
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE COMMENT '创建时间索引',
  INDEX `idx_type`(`type` ASC) USING BTREE COMMENT '通知类型索引',
  INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE COMMENT '用户已读状态复合索引',
  INDEX `idx_sender_id`(`sender_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态（0-禁用，1-启用）',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'user' COMMENT '角色（user-普通用户，admin-管理员）',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
