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

 Date: 23/03/2026 20:57:55
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
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES (1, 31, 3, '测试评论1', NULL, NULL, 1, '2026-01-20 17:08:15', NULL);
INSERT INTO `comments` VALUES (2, 31, 3, '111', NULL, NULL, 1, '2026-01-20 17:31:46', NULL);
INSERT INTO `comments` VALUES (3, 31, 4, '好好', NULL, NULL, 1, '2026-01-20 17:32:50', NULL);
INSERT INTO `comments` VALUES (4, 31, 3, 'cs', NULL, NULL, 1, '2026-01-28 17:17:34', NULL);
INSERT INTO `comments` VALUES (5, 35, 3, 'hello', NULL, NULL, 1, '2026-02-28 14:50:55', NULL);
INSERT INTO `comments` VALUES (6, 35, 3, '我是ack', NULL, NULL, 1, '2026-02-28 14:51:00', NULL);
INSERT INTO `comments` VALUES (7, 35, 6, 'i am usr', NULL, NULL, 1, '2026-02-28 14:51:11', NULL);

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
-- Records of document_locks
-- ----------------------------

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
-- Records of document_operation_logs
-- ----------------------------
INSERT INTO `document_operation_logs` VALUES (1, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:33:32');
INSERT INTO `document_operation_logs` VALUES (2, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:34:35');
INSERT INTO `document_operation_logs` VALUES (3, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:34:36');
INSERT INTO `document_operation_logs` VALUES (4, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:34:43');
INSERT INTO `document_operation_logs` VALUES (5, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:34:48');
INSERT INTO `document_operation_logs` VALUES (6, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:37:28');
INSERT INTO `document_operation_logs` VALUES (7, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:37:40');
INSERT INTO `document_operation_logs` VALUES (8, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:37:41');
INSERT INTO `document_operation_logs` VALUES (9, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:05');
INSERT INTO `document_operation_logs` VALUES (10, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:05');
INSERT INTO `document_operation_logs` VALUES (11, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:24');
INSERT INTO `document_operation_logs` VALUES (12, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:24');
INSERT INTO `document_operation_logs` VALUES (13, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:33');
INSERT INTO `document_operation_logs` VALUES (14, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:33');
INSERT INTO `document_operation_logs` VALUES (15, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:39');
INSERT INTO `document_operation_logs` VALUES (16, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:39');
INSERT INTO `document_operation_logs` VALUES (17, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:46');
INSERT INTO `document_operation_logs` VALUES (18, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:46');
INSERT INTO `document_operation_logs` VALUES (19, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:40:52');
INSERT INTO `document_operation_logs` VALUES (20, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:40:53');
INSERT INTO `document_operation_logs` VALUES (21, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:41:49');
INSERT INTO `document_operation_logs` VALUES (22, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:42:12');
INSERT INTO `document_operation_logs` VALUES (23, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:42:12');
INSERT INTO `document_operation_logs` VALUES (24, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:42:17');
INSERT INTO `document_operation_logs` VALUES (25, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:42:18');
INSERT INTO `document_operation_logs` VALUES (26, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:43:43');
INSERT INTO `document_operation_logs` VALUES (27, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:43:43');
INSERT INTO `document_operation_logs` VALUES (28, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:43:53');
INSERT INTO `document_operation_logs` VALUES (29, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:43:53');
INSERT INTO `document_operation_logs` VALUES (30, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:44:11');
INSERT INTO `document_operation_logs` VALUES (31, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:44:11');
INSERT INTO `document_operation_logs` VALUES (32, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:44:20');
INSERT INTO `document_operation_logs` VALUES (33, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:44:20');
INSERT INTO `document_operation_logs` VALUES (34, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:44:31');
INSERT INTO `document_operation_logs` VALUES (35, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:46:15');
INSERT INTO `document_operation_logs` VALUES (36, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:46:34');
INSERT INTO `document_operation_logs` VALUES (37, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:46:34');
INSERT INTO `document_operation_logs` VALUES (38, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:47:52');
INSERT INTO `document_operation_logs` VALUES (39, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:47:53');
INSERT INTO `document_operation_logs` VALUES (40, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:48:12');
INSERT INTO `document_operation_logs` VALUES (41, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:48:12');
INSERT INTO `document_operation_logs` VALUES (42, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:48:51');
INSERT INTO `document_operation_logs` VALUES (43, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:48:51');
INSERT INTO `document_operation_logs` VALUES (44, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:49:05');
INSERT INTO `document_operation_logs` VALUES (45, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:49:06');
INSERT INTO `document_operation_logs` VALUES (46, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:49:11');
INSERT INTO `document_operation_logs` VALUES (47, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:49:11');
INSERT INTO `document_operation_logs` VALUES (48, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:49:16');
INSERT INTO `document_operation_logs` VALUES (49, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:49:16');
INSERT INTO `document_operation_logs` VALUES (50, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:49:22');
INSERT INTO `document_operation_logs` VALUES (51, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:49:22');
INSERT INTO `document_operation_logs` VALUES (52, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:50:03');
INSERT INTO `document_operation_logs` VALUES (53, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:50:03');
INSERT INTO `document_operation_logs` VALUES (54, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:50:08');
INSERT INTO `document_operation_logs` VALUES (55, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:50:08');
INSERT INTO `document_operation_logs` VALUES (56, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:50:34');
INSERT INTO `document_operation_logs` VALUES (57, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:50:34');
INSERT INTO `document_operation_logs` VALUES (58, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:51:17');
INSERT INTO `document_operation_logs` VALUES (59, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:51:17');
INSERT INTO `document_operation_logs` VALUES (60, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:53:14');
INSERT INTO `document_operation_logs` VALUES (61, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:53:14');
INSERT INTO `document_operation_logs` VALUES (62, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:55:32');
INSERT INTO `document_operation_logs` VALUES (63, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:55:32');
INSERT INTO `document_operation_logs` VALUES (64, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:55:39');
INSERT INTO `document_operation_logs` VALUES (65, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:55:42');
INSERT INTO `document_operation_logs` VALUES (66, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:58:27');
INSERT INTO `document_operation_logs` VALUES (67, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:58:27');
INSERT INTO `document_operation_logs` VALUES (68, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 18:59:42');
INSERT INTO `document_operation_logs` VALUES (69, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 18:59:42');
INSERT INTO `document_operation_logs` VALUES (70, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:07:24');
INSERT INTO `document_operation_logs` VALUES (71, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:07:27');
INSERT INTO `document_operation_logs` VALUES (72, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:07:46');
INSERT INTO `document_operation_logs` VALUES (73, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:07:47');
INSERT INTO `document_operation_logs` VALUES (74, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:07:48');
INSERT INTO `document_operation_logs` VALUES (75, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:07:54');
INSERT INTO `document_operation_logs` VALUES (76, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:11:12');
INSERT INTO `document_operation_logs` VALUES (77, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:11:13');
INSERT INTO `document_operation_logs` VALUES (78, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:15:33');
INSERT INTO `document_operation_logs` VALUES (79, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:15:34');
INSERT INTO `document_operation_logs` VALUES (80, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:28:57');
INSERT INTO `document_operation_logs` VALUES (81, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:29:00');
INSERT INTO `document_operation_logs` VALUES (82, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:31:44');
INSERT INTO `document_operation_logs` VALUES (83, 30, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:31:45');
INSERT INTO `document_operation_logs` VALUES (84, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:31:45');
INSERT INTO `document_operation_logs` VALUES (85, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:34:08');
INSERT INTO `document_operation_logs` VALUES (86, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:43:06');
INSERT INTO `document_operation_logs` VALUES (87, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:43:10');
INSERT INTO `document_operation_logs` VALUES (88, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:43:12');
INSERT INTO `document_operation_logs` VALUES (89, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:43:12');
INSERT INTO `document_operation_logs` VALUES (90, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:43:18');
INSERT INTO `document_operation_logs` VALUES (91, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:50:47');
INSERT INTO `document_operation_logs` VALUES (92, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 19:50:48');
INSERT INTO `document_operation_logs` VALUES (93, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 19:56:32');
INSERT INTO `document_operation_logs` VALUES (94, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 20:01:18');
INSERT INTO `document_operation_logs` VALUES (95, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 20:07:19');
INSERT INTO `document_operation_logs` VALUES (96, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-30 20:07:20');
INSERT INTO `document_operation_logs` VALUES (97, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-30 20:07:32');
INSERT INTO `document_operation_logs` VALUES (98, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 12:49:31');
INSERT INTO `document_operation_logs` VALUES (99, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 12:49:49');
INSERT INTO `document_operation_logs` VALUES (100, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 12:49:50');
INSERT INTO `document_operation_logs` VALUES (101, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 12:50:07');
INSERT INTO `document_operation_logs` VALUES (102, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 12:50:08');
INSERT INTO `document_operation_logs` VALUES (103, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 12:59:31');
INSERT INTO `document_operation_logs` VALUES (104, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:01:12');
INSERT INTO `document_operation_logs` VALUES (105, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:05:37');
INSERT INTO `document_operation_logs` VALUES (106, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:05:43');
INSERT INTO `document_operation_logs` VALUES (107, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:09:01');
INSERT INTO `document_operation_logs` VALUES (108, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:09:02');
INSERT INTO `document_operation_logs` VALUES (109, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:11:57');
INSERT INTO `document_operation_logs` VALUES (110, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:11:58');
INSERT INTO `document_operation_logs` VALUES (111, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:19:32');
INSERT INTO `document_operation_logs` VALUES (112, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:19:33');
INSERT INTO `document_operation_logs` VALUES (113, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:20:18');
INSERT INTO `document_operation_logs` VALUES (114, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:20:19');
INSERT INTO `document_operation_logs` VALUES (115, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:20:32');
INSERT INTO `document_operation_logs` VALUES (116, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:22:06');
INSERT INTO `document_operation_logs` VALUES (117, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:22:58');
INSERT INTO `document_operation_logs` VALUES (118, 31, 3, 'join_collaboration', '用户加入协同编辑', '2025-12-31 13:22:59');
INSERT INTO `document_operation_logs` VALUES (119, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2025-12-31 13:24:57');
INSERT INTO `document_operation_logs` VALUES (120, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:05:01');
INSERT INTO `document_operation_logs` VALUES (121, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:05:48');
INSERT INTO `document_operation_logs` VALUES (122, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:05:49');
INSERT INTO `document_operation_logs` VALUES (123, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:06:29');
INSERT INTO `document_operation_logs` VALUES (124, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:06:29');
INSERT INTO `document_operation_logs` VALUES (125, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:07:17');
INSERT INTO `document_operation_logs` VALUES (126, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:07:18');
INSERT INTO `document_operation_logs` VALUES (127, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:07:33');
INSERT INTO `document_operation_logs` VALUES (128, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:07:34');
INSERT INTO `document_operation_logs` VALUES (129, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:08:50');
INSERT INTO `document_operation_logs` VALUES (130, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:08:50');
INSERT INTO `document_operation_logs` VALUES (131, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:09:04');
INSERT INTO `document_operation_logs` VALUES (132, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:09:12');
INSERT INTO `document_operation_logs` VALUES (133, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:12:03');
INSERT INTO `document_operation_logs` VALUES (134, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:12:04');
INSERT INTO `document_operation_logs` VALUES (135, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:15:26');
INSERT INTO `document_operation_logs` VALUES (136, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:15:27');
INSERT INTO `document_operation_logs` VALUES (137, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:15:37');
INSERT INTO `document_operation_logs` VALUES (138, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:15:37');
INSERT INTO `document_operation_logs` VALUES (139, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:15:43');
INSERT INTO `document_operation_logs` VALUES (140, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:15:43');
INSERT INTO `document_operation_logs` VALUES (141, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:15:51');
INSERT INTO `document_operation_logs` VALUES (142, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:15:51');
INSERT INTO `document_operation_logs` VALUES (143, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:15:58');
INSERT INTO `document_operation_logs` VALUES (144, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:15:58');
INSERT INTO `document_operation_logs` VALUES (145, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:16:04');
INSERT INTO `document_operation_logs` VALUES (146, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:16:04');
INSERT INTO `document_operation_logs` VALUES (147, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:16:18');
INSERT INTO `document_operation_logs` VALUES (148, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:16:18');
INSERT INTO `document_operation_logs` VALUES (149, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:16:51');
INSERT INTO `document_operation_logs` VALUES (150, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:16:51');
INSERT INTO `document_operation_logs` VALUES (151, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:18:25');
INSERT INTO `document_operation_logs` VALUES (152, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:18:25');
INSERT INTO `document_operation_logs` VALUES (153, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:18:38');
INSERT INTO `document_operation_logs` VALUES (154, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:18:38');
INSERT INTO `document_operation_logs` VALUES (155, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:18:50');
INSERT INTO `document_operation_logs` VALUES (156, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:18:50');
INSERT INTO `document_operation_logs` VALUES (157, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:18:59');
INSERT INTO `document_operation_logs` VALUES (158, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:18:59');
INSERT INTO `document_operation_logs` VALUES (159, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:19:25');
INSERT INTO `document_operation_logs` VALUES (160, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:19:25');
INSERT INTO `document_operation_logs` VALUES (161, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:19:32');
INSERT INTO `document_operation_logs` VALUES (162, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:19:32');
INSERT INTO `document_operation_logs` VALUES (163, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:19:38');
INSERT INTO `document_operation_logs` VALUES (164, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:19:38');
INSERT INTO `document_operation_logs` VALUES (165, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:19:43');
INSERT INTO `document_operation_logs` VALUES (166, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:19:43');
INSERT INTO `document_operation_logs` VALUES (167, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:19:52');
INSERT INTO `document_operation_logs` VALUES (168, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:19:52');
INSERT INTO `document_operation_logs` VALUES (169, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:21:42');
INSERT INTO `document_operation_logs` VALUES (170, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:21:42');
INSERT INTO `document_operation_logs` VALUES (171, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:23:14');
INSERT INTO `document_operation_logs` VALUES (172, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:23:14');
INSERT INTO `document_operation_logs` VALUES (173, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:24:20');
INSERT INTO `document_operation_logs` VALUES (174, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:24:20');
INSERT INTO `document_operation_logs` VALUES (175, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:24:35');
INSERT INTO `document_operation_logs` VALUES (176, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:24:35');
INSERT INTO `document_operation_logs` VALUES (177, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:24:43');
INSERT INTO `document_operation_logs` VALUES (178, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:24:43');
INSERT INTO `document_operation_logs` VALUES (179, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:24:49');
INSERT INTO `document_operation_logs` VALUES (180, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:24:49');
INSERT INTO `document_operation_logs` VALUES (181, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:25:00');
INSERT INTO `document_operation_logs` VALUES (182, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:25:00');
INSERT INTO `document_operation_logs` VALUES (183, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:25:07');
INSERT INTO `document_operation_logs` VALUES (184, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:25:07');
INSERT INTO `document_operation_logs` VALUES (185, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:25:56');
INSERT INTO `document_operation_logs` VALUES (186, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:25:56');
INSERT INTO `document_operation_logs` VALUES (187, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:26:34');
INSERT INTO `document_operation_logs` VALUES (188, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:26:34');
INSERT INTO `document_operation_logs` VALUES (189, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:26:41');
INSERT INTO `document_operation_logs` VALUES (190, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:26:41');
INSERT INTO `document_operation_logs` VALUES (191, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:26:53');
INSERT INTO `document_operation_logs` VALUES (192, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:26:53');
INSERT INTO `document_operation_logs` VALUES (193, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:26:59');
INSERT INTO `document_operation_logs` VALUES (194, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:26:59');
INSERT INTO `document_operation_logs` VALUES (195, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:28:00');
INSERT INTO `document_operation_logs` VALUES (196, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:28:00');
INSERT INTO `document_operation_logs` VALUES (197, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:30:20');
INSERT INTO `document_operation_logs` VALUES (198, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:30:20');
INSERT INTO `document_operation_logs` VALUES (199, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:30:47');
INSERT INTO `document_operation_logs` VALUES (200, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:30:47');
INSERT INTO `document_operation_logs` VALUES (201, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:30:57');
INSERT INTO `document_operation_logs` VALUES (202, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:30:57');
INSERT INTO `document_operation_logs` VALUES (203, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:31:22');
INSERT INTO `document_operation_logs` VALUES (204, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:31:22');
INSERT INTO `document_operation_logs` VALUES (205, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:31:28');
INSERT INTO `document_operation_logs` VALUES (206, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:31:29');
INSERT INTO `document_operation_logs` VALUES (207, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:44:33');
INSERT INTO `document_operation_logs` VALUES (208, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:44:34');
INSERT INTO `document_operation_logs` VALUES (209, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:53:31');
INSERT INTO `document_operation_logs` VALUES (210, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:53:32');
INSERT INTO `document_operation_logs` VALUES (211, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 09:53:34');
INSERT INTO `document_operation_logs` VALUES (212, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-05 09:53:36');
INSERT INTO `document_operation_logs` VALUES (213, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-05 10:03:19');
INSERT INTO `document_operation_logs` VALUES (214, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-09 14:42:01');
INSERT INTO `document_operation_logs` VALUES (215, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-09 14:42:44');
INSERT INTO `document_operation_logs` VALUES (216, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-09 14:55:58');
INSERT INTO `document_operation_logs` VALUES (217, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-09 14:56:01');
INSERT INTO `document_operation_logs` VALUES (218, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-09 16:06:14');
INSERT INTO `document_operation_logs` VALUES (219, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-09 16:06:17');
INSERT INTO `document_operation_logs` VALUES (220, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 19:08:30');
INSERT INTO `document_operation_logs` VALUES (221, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 19:08:59');
INSERT INTO `document_operation_logs` VALUES (222, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 19:49:45');
INSERT INTO `document_operation_logs` VALUES (223, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:06:57');
INSERT INTO `document_operation_logs` VALUES (224, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:06:59');
INSERT INTO `document_operation_logs` VALUES (225, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:08:25');
INSERT INTO `document_operation_logs` VALUES (226, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:15:39');
INSERT INTO `document_operation_logs` VALUES (227, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:15:50');
INSERT INTO `document_operation_logs` VALUES (228, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:16:29');
INSERT INTO `document_operation_logs` VALUES (229, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:19:36');
INSERT INTO `document_operation_logs` VALUES (230, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:20:01');
INSERT INTO `document_operation_logs` VALUES (231, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:22:48');
INSERT INTO `document_operation_logs` VALUES (232, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:25:54');
INSERT INTO `document_operation_logs` VALUES (233, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:31:09');
INSERT INTO `document_operation_logs` VALUES (234, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:37:13');
INSERT INTO `document_operation_logs` VALUES (235, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:38:10');
INSERT INTO `document_operation_logs` VALUES (236, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:38:11');
INSERT INTO `document_operation_logs` VALUES (237, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:48:23');
INSERT INTO `document_operation_logs` VALUES (238, 31, 3, 'invite', '邀请用户 4 加入文档', '2026-01-11 20:48:31');
INSERT INTO `document_operation_logs` VALUES (239, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:48:37');
INSERT INTO `document_operation_logs` VALUES (240, 31, 4, 'reject_invite', '拒绝邀请', '2026-01-11 20:50:30');
INSERT INTO `document_operation_logs` VALUES (241, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-11 20:54:04');
INSERT INTO `document_operation_logs` VALUES (242, 31, 3, 'invite', '邀请用户 4 加入文档', '2026-01-11 20:54:11');
INSERT INTO `document_operation_logs` VALUES (243, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-11 20:54:14');
INSERT INTO `document_operation_logs` VALUES (244, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:24:45');
INSERT INTO `document_operation_logs` VALUES (245, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:25:25');
INSERT INTO `document_operation_logs` VALUES (246, 31, 4, 'accept_invite', '接受邀请', '2026-01-12 19:28:01');
INSERT INTO `document_operation_logs` VALUES (247, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:28:11');
INSERT INTO `document_operation_logs` VALUES (248, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:28:21');
INSERT INTO `document_operation_logs` VALUES (249, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:28:22');
INSERT INTO `document_operation_logs` VALUES (250, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:28:26');
INSERT INTO `document_operation_logs` VALUES (251, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:28:58');
INSERT INTO `document_operation_logs` VALUES (252, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:30:00');
INSERT INTO `document_operation_logs` VALUES (253, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:30:41');
INSERT INTO `document_operation_logs` VALUES (254, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:31:05');
INSERT INTO `document_operation_logs` VALUES (255, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:49:51');
INSERT INTO `document_operation_logs` VALUES (256, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:49:54');
INSERT INTO `document_operation_logs` VALUES (257, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:50:09');
INSERT INTO `document_operation_logs` VALUES (258, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 19:50:24');
INSERT INTO `document_operation_logs` VALUES (259, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-12 19:50:25');
INSERT INTO `document_operation_logs` VALUES (260, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 20:09:49');
INSERT INTO `document_operation_logs` VALUES (261, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 20:28:57');
INSERT INTO `document_operation_logs` VALUES (262, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-12 20:29:31');
INSERT INTO `document_operation_logs` VALUES (263, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 20:30:03');
INSERT INTO `document_operation_logs` VALUES (264, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 20:30:04');
INSERT INTO `document_operation_logs` VALUES (265, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 20:51:03');
INSERT INTO `document_operation_logs` VALUES (266, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 20:53:03');
INSERT INTO `document_operation_logs` VALUES (267, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:00:33');
INSERT INTO `document_operation_logs` VALUES (268, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:04:03');
INSERT INTO `document_operation_logs` VALUES (269, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:07:35');
INSERT INTO `document_operation_logs` VALUES (270, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:08:00');
INSERT INTO `document_operation_logs` VALUES (271, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:08:01');
INSERT INTO `document_operation_logs` VALUES (272, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:08:15');
INSERT INTO `document_operation_logs` VALUES (273, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:10:18');
INSERT INTO `document_operation_logs` VALUES (274, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:10:32');
INSERT INTO `document_operation_logs` VALUES (275, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:10:33');
INSERT INTO `document_operation_logs` VALUES (276, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:11:15');
INSERT INTO `document_operation_logs` VALUES (277, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:11:16');
INSERT INTO `document_operation_logs` VALUES (278, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:11:17');
INSERT INTO `document_operation_logs` VALUES (279, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:12:02');
INSERT INTO `document_operation_logs` VALUES (280, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:14:38');
INSERT INTO `document_operation_logs` VALUES (281, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:14:38');
INSERT INTO `document_operation_logs` VALUES (282, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:14:44');
INSERT INTO `document_operation_logs` VALUES (283, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-12 21:14:44');
INSERT INTO `document_operation_logs` VALUES (284, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-12 21:15:07');
INSERT INTO `document_operation_logs` VALUES (285, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:05:01');
INSERT INTO `document_operation_logs` VALUES (286, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:06:30');
INSERT INTO `document_operation_logs` VALUES (287, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:06:30');
INSERT INTO `document_operation_logs` VALUES (288, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:08:24');
INSERT INTO `document_operation_logs` VALUES (289, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:08:25');
INSERT INTO `document_operation_logs` VALUES (290, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:08:35');
INSERT INTO `document_operation_logs` VALUES (291, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:08:35');
INSERT INTO `document_operation_logs` VALUES (292, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:09:51');
INSERT INTO `document_operation_logs` VALUES (293, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:09:51');
INSERT INTO `document_operation_logs` VALUES (294, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:10:53');
INSERT INTO `document_operation_logs` VALUES (295, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:10:53');
INSERT INTO `document_operation_logs` VALUES (296, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:12:19');
INSERT INTO `document_operation_logs` VALUES (297, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:12:19');
INSERT INTO `document_operation_logs` VALUES (298, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:12:39');
INSERT INTO `document_operation_logs` VALUES (299, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:12:39');
INSERT INTO `document_operation_logs` VALUES (300, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:12:51');
INSERT INTO `document_operation_logs` VALUES (301, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:12:51');
INSERT INTO `document_operation_logs` VALUES (302, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:13:48');
INSERT INTO `document_operation_logs` VALUES (303, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:13:50');
INSERT INTO `document_operation_logs` VALUES (304, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:15:28');
INSERT INTO `document_operation_logs` VALUES (305, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:15:28');
INSERT INTO `document_operation_logs` VALUES (306, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:15:48');
INSERT INTO `document_operation_logs` VALUES (307, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:15:48');
INSERT INTO `document_operation_logs` VALUES (308, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:16:33');
INSERT INTO `document_operation_logs` VALUES (309, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:16:34');
INSERT INTO `document_operation_logs` VALUES (310, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:25:33');
INSERT INTO `document_operation_logs` VALUES (311, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:25:34');
INSERT INTO `document_operation_logs` VALUES (312, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:27:15');
INSERT INTO `document_operation_logs` VALUES (313, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:27:15');
INSERT INTO `document_operation_logs` VALUES (314, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:28:28');
INSERT INTO `document_operation_logs` VALUES (315, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:28:29');
INSERT INTO `document_operation_logs` VALUES (316, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:30:33');
INSERT INTO `document_operation_logs` VALUES (317, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:30:33');
INSERT INTO `document_operation_logs` VALUES (318, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:30:45');
INSERT INTO `document_operation_logs` VALUES (319, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:30:45');
INSERT INTO `document_operation_logs` VALUES (320, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:30:56');
INSERT INTO `document_operation_logs` VALUES (321, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:30:56');
INSERT INTO `document_operation_logs` VALUES (322, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:31:15');
INSERT INTO `document_operation_logs` VALUES (323, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:31:15');
INSERT INTO `document_operation_logs` VALUES (324, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:32:23');
INSERT INTO `document_operation_logs` VALUES (325, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:32:24');
INSERT INTO `document_operation_logs` VALUES (326, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:40:59');
INSERT INTO `document_operation_logs` VALUES (327, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:40:59');
INSERT INTO `document_operation_logs` VALUES (328, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:43:52');
INSERT INTO `document_operation_logs` VALUES (329, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:43:52');
INSERT INTO `document_operation_logs` VALUES (330, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:44:17');
INSERT INTO `document_operation_logs` VALUES (331, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:44:18');
INSERT INTO `document_operation_logs` VALUES (332, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:46:23');
INSERT INTO `document_operation_logs` VALUES (333, 30, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:46:24');
INSERT INTO `document_operation_logs` VALUES (334, 30, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:46:25');
INSERT INTO `document_operation_logs` VALUES (335, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:46:29');
INSERT INTO `document_operation_logs` VALUES (336, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:49:40');
INSERT INTO `document_operation_logs` VALUES (337, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:49:40');
INSERT INTO `document_operation_logs` VALUES (338, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:49:48');
INSERT INTO `document_operation_logs` VALUES (339, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:49:48');
INSERT INTO `document_operation_logs` VALUES (340, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:50:36');
INSERT INTO `document_operation_logs` VALUES (341, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:50:37');
INSERT INTO `document_operation_logs` VALUES (342, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-15 15:55:42');
INSERT INTO `document_operation_logs` VALUES (343, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:55:52');
INSERT INTO `document_operation_logs` VALUES (344, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-15 15:57:25');
INSERT INTO `document_operation_logs` VALUES (345, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-16 21:52:55');
INSERT INTO `document_operation_logs` VALUES (346, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-16 21:55:09');
INSERT INTO `document_operation_logs` VALUES (347, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-16 21:55:09');
INSERT INTO `document_operation_logs` VALUES (348, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-16 22:01:06');
INSERT INTO `document_operation_logs` VALUES (349, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-16 22:07:55');
INSERT INTO `document_operation_logs` VALUES (350, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-16 22:14:18');
INSERT INTO `document_operation_logs` VALUES (351, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-16 22:14:33');
INSERT INTO `document_operation_logs` VALUES (352, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 16:40:29');
INSERT INTO `document_operation_logs` VALUES (353, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 16:44:44');
INSERT INTO `document_operation_logs` VALUES (354, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 16:47:02');
INSERT INTO `document_operation_logs` VALUES (355, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 16:47:02');
INSERT INTO `document_operation_logs` VALUES (356, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 16:47:03');
INSERT INTO `document_operation_logs` VALUES (357, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:03:49');
INSERT INTO `document_operation_logs` VALUES (358, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:07:53');
INSERT INTO `document_operation_logs` VALUES (359, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:08:59');
INSERT INTO `document_operation_logs` VALUES (360, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:09:09');
INSERT INTO `document_operation_logs` VALUES (361, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:09:09');
INSERT INTO `document_operation_logs` VALUES (362, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:11:37');
INSERT INTO `document_operation_logs` VALUES (363, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:41');
INSERT INTO `document_operation_logs` VALUES (364, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:41');
INSERT INTO `document_operation_logs` VALUES (365, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:41');
INSERT INTO `document_operation_logs` VALUES (366, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:41');
INSERT INTO `document_operation_logs` VALUES (367, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:42');
INSERT INTO `document_operation_logs` VALUES (368, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:42');
INSERT INTO `document_operation_logs` VALUES (369, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:43');
INSERT INTO `document_operation_logs` VALUES (370, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:43');
INSERT INTO `document_operation_logs` VALUES (371, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:44');
INSERT INTO `document_operation_logs` VALUES (372, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:44');
INSERT INTO `document_operation_logs` VALUES (373, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:45');
INSERT INTO `document_operation_logs` VALUES (374, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:45');
INSERT INTO `document_operation_logs` VALUES (375, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:46');
INSERT INTO `document_operation_logs` VALUES (376, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:46');
INSERT INTO `document_operation_logs` VALUES (377, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:47');
INSERT INTO `document_operation_logs` VALUES (378, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (379, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (380, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (381, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (382, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (383, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:50');
INSERT INTO `document_operation_logs` VALUES (384, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:51');
INSERT INTO `document_operation_logs` VALUES (385, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:51');
INSERT INTO `document_operation_logs` VALUES (386, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:51');
INSERT INTO `document_operation_logs` VALUES (387, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:51');
INSERT INTO `document_operation_logs` VALUES (388, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:51');
INSERT INTO `document_operation_logs` VALUES (389, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (390, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (391, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (392, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (393, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (394, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (395, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:52');
INSERT INTO `document_operation_logs` VALUES (396, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:53');
INSERT INTO `document_operation_logs` VALUES (397, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:53');
INSERT INTO `document_operation_logs` VALUES (398, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:53');
INSERT INTO `document_operation_logs` VALUES (399, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:53');
INSERT INTO `document_operation_logs` VALUES (400, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:54');
INSERT INTO `document_operation_logs` VALUES (401, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:54');
INSERT INTO `document_operation_logs` VALUES (402, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:54');
INSERT INTO `document_operation_logs` VALUES (403, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:55');
INSERT INTO `document_operation_logs` VALUES (404, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:55');
INSERT INTO `document_operation_logs` VALUES (405, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:55');
INSERT INTO `document_operation_logs` VALUES (406, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:55');
INSERT INTO `document_operation_logs` VALUES (407, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:56');
INSERT INTO `document_operation_logs` VALUES (408, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:56');
INSERT INTO `document_operation_logs` VALUES (409, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:56');
INSERT INTO `document_operation_logs` VALUES (410, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:56');
INSERT INTO `document_operation_logs` VALUES (411, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:56');
INSERT INTO `document_operation_logs` VALUES (412, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:57');
INSERT INTO `document_operation_logs` VALUES (413, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:57');
INSERT INTO `document_operation_logs` VALUES (414, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:57');
INSERT INTO `document_operation_logs` VALUES (415, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:57');
INSERT INTO `document_operation_logs` VALUES (416, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:57');
INSERT INTO `document_operation_logs` VALUES (417, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:58');
INSERT INTO `document_operation_logs` VALUES (418, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:58');
INSERT INTO `document_operation_logs` VALUES (419, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:58');
INSERT INTO `document_operation_logs` VALUES (420, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:58');
INSERT INTO `document_operation_logs` VALUES (421, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:58');
INSERT INTO `document_operation_logs` VALUES (422, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:59');
INSERT INTO `document_operation_logs` VALUES (423, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:16:59');
INSERT INTO `document_operation_logs` VALUES (424, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:59');
INSERT INTO `document_operation_logs` VALUES (425, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:16:59');
INSERT INTO `document_operation_logs` VALUES (426, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:00');
INSERT INTO `document_operation_logs` VALUES (427, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:00');
INSERT INTO `document_operation_logs` VALUES (428, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:00');
INSERT INTO `document_operation_logs` VALUES (429, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:00');
INSERT INTO `document_operation_logs` VALUES (430, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:00');
INSERT INTO `document_operation_logs` VALUES (431, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:01');
INSERT INTO `document_operation_logs` VALUES (432, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:01');
INSERT INTO `document_operation_logs` VALUES (433, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:01');
INSERT INTO `document_operation_logs` VALUES (434, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:01');
INSERT INTO `document_operation_logs` VALUES (435, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:01');
INSERT INTO `document_operation_logs` VALUES (436, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:02');
INSERT INTO `document_operation_logs` VALUES (437, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:02');
INSERT INTO `document_operation_logs` VALUES (438, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:02');
INSERT INTO `document_operation_logs` VALUES (439, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:02');
INSERT INTO `document_operation_logs` VALUES (440, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:03');
INSERT INTO `document_operation_logs` VALUES (441, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:03');
INSERT INTO `document_operation_logs` VALUES (442, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:03');
INSERT INTO `document_operation_logs` VALUES (443, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:03');
INSERT INTO `document_operation_logs` VALUES (444, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:03');
INSERT INTO `document_operation_logs` VALUES (445, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (446, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (447, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (448, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (449, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (450, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:04');
INSERT INTO `document_operation_logs` VALUES (451, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (452, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (453, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (454, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (455, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (456, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (457, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (458, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:05');
INSERT INTO `document_operation_logs` VALUES (459, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (460, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (461, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (462, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (463, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (464, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (465, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (466, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (467, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:06');
INSERT INTO `document_operation_logs` VALUES (468, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (469, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (470, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (471, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (472, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (473, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (474, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:07');
INSERT INTO `document_operation_logs` VALUES (475, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (476, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (477, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (478, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (479, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (480, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (481, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:08');
INSERT INTO `document_operation_logs` VALUES (482, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (483, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (484, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (485, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (486, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (487, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (488, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:09');
INSERT INTO `document_operation_logs` VALUES (489, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (490, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (491, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (492, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (493, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (494, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (495, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (496, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:10');
INSERT INTO `document_operation_logs` VALUES (497, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (498, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (499, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (500, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (501, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (502, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (503, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (504, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (505, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:11');
INSERT INTO `document_operation_logs` VALUES (506, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (507, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (508, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (509, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (510, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (511, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (512, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:12');
INSERT INTO `document_operation_logs` VALUES (513, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (514, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (515, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (516, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (517, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (518, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:13');
INSERT INTO `document_operation_logs` VALUES (519, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (520, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (521, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (522, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (523, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (524, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (525, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (526, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (527, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (528, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:14');
INSERT INTO `document_operation_logs` VALUES (529, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (530, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (531, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (532, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (533, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (534, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (535, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (536, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (537, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:15');
INSERT INTO `document_operation_logs` VALUES (538, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (539, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (540, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (541, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (542, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (543, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (544, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (545, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (546, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (547, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:16');
INSERT INTO `document_operation_logs` VALUES (548, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (549, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (550, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (551, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (552, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (553, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (554, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (555, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (556, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (557, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:17');
INSERT INTO `document_operation_logs` VALUES (558, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (559, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (560, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (561, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (562, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (563, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (564, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (565, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:18');
INSERT INTO `document_operation_logs` VALUES (566, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (567, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (568, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (569, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (570, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (571, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (572, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (573, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (574, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:19');
INSERT INTO `document_operation_logs` VALUES (575, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (576, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (577, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (578, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (579, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (580, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (581, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (582, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (583, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (584, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:20');
INSERT INTO `document_operation_logs` VALUES (585, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (586, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (587, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (588, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (589, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (590, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (591, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (592, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:21');
INSERT INTO `document_operation_logs` VALUES (593, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (594, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (595, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (596, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (597, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (598, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (599, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (600, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (601, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:22');
INSERT INTO `document_operation_logs` VALUES (602, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (603, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (604, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (605, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (606, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (607, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (608, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:23');
INSERT INTO `document_operation_logs` VALUES (609, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (610, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (611, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (612, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (613, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (614, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (615, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:24');
INSERT INTO `document_operation_logs` VALUES (616, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (617, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (618, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (619, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (620, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (621, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (622, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (623, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (624, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:25');
INSERT INTO `document_operation_logs` VALUES (625, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (626, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (627, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (628, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (629, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (630, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (631, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (632, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:26');
INSERT INTO `document_operation_logs` VALUES (633, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (634, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (635, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (636, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (637, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (638, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (639, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:27');
INSERT INTO `document_operation_logs` VALUES (640, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (641, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (642, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (643, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (644, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (645, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (646, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:28');
INSERT INTO `document_operation_logs` VALUES (647, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (648, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (649, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (650, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (651, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (652, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (653, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:29');
INSERT INTO `document_operation_logs` VALUES (654, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (655, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (656, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (657, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (658, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (659, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (660, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:30');
INSERT INTO `document_operation_logs` VALUES (661, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (662, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (663, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (664, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (665, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (666, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (667, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (668, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:31');
INSERT INTO `document_operation_logs` VALUES (669, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (670, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (671, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (672, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (673, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (674, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (675, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:32');
INSERT INTO `document_operation_logs` VALUES (676, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (677, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (678, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (679, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (680, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (681, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (682, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:33');
INSERT INTO `document_operation_logs` VALUES (683, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (684, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (685, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (686, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (687, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (688, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (689, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:34');
INSERT INTO `document_operation_logs` VALUES (690, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (691, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (692, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (693, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (694, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (695, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (696, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (697, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:35');
INSERT INTO `document_operation_logs` VALUES (698, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (699, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (700, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (701, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (702, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (703, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (704, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (705, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:36');
INSERT INTO `document_operation_logs` VALUES (706, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (707, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (708, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (709, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (710, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (711, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (712, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (713, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:37');
INSERT INTO `document_operation_logs` VALUES (714, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (715, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (716, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (717, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (718, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (719, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (720, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (721, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:38');
INSERT INTO `document_operation_logs` VALUES (722, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (723, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (724, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (725, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (726, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (727, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (728, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (729, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (730, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (731, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (732, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:39');
INSERT INTO `document_operation_logs` VALUES (733, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (734, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (735, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (736, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (737, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (738, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (739, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (740, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (741, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (742, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (743, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (744, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (745, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (746, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (747, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (748, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (749, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (750, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (751, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (752, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (753, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (754, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (755, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (756, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (757, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (758, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (759, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (760, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (761, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (762, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (763, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (764, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (765, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (766, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:40');
INSERT INTO `document_operation_logs` VALUES (767, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (768, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (769, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (770, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (771, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (772, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (773, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (774, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (775, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (776, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (777, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (778, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (779, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (780, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (781, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (782, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (783, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (784, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (785, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (786, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (787, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (788, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (789, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (790, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (791, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (792, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (793, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (794, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (795, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:41');
INSERT INTO `document_operation_logs` VALUES (796, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (797, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (798, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (799, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (800, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (801, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (802, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (803, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (804, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (805, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (806, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (807, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (808, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (809, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (810, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (811, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (812, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (813, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (814, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (815, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (816, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (817, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (818, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (819, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (820, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (821, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (822, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (823, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (824, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:42');
INSERT INTO `document_operation_logs` VALUES (825, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:43');
INSERT INTO `document_operation_logs` VALUES (826, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:43');
INSERT INTO `document_operation_logs` VALUES (827, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:43');
INSERT INTO `document_operation_logs` VALUES (828, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:43');
INSERT INTO `document_operation_logs` VALUES (829, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (830, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (831, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (832, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (833, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (834, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (835, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (836, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (837, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (838, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (839, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (840, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:17:44');
INSERT INTO `document_operation_logs` VALUES (841, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:17:45');
INSERT INTO `document_operation_logs` VALUES (842, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:21:53');
INSERT INTO `document_operation_logs` VALUES (843, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (844, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (845, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (846, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (847, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (848, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (849, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (850, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (851, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (852, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (853, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (854, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (855, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:03');
INSERT INTO `document_operation_logs` VALUES (856, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (857, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (858, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (859, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (860, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (861, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (862, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (863, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (864, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (865, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (866, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (867, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (868, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (869, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (870, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (871, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (872, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (873, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (874, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (875, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (876, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (877, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (878, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (879, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (880, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (881, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (882, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (883, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (884, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (885, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:08');
INSERT INTO `document_operation_logs` VALUES (886, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (887, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (888, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (889, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (890, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (891, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (892, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (893, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (894, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (895, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (896, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (897, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (898, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (899, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (900, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (901, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (902, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (903, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (904, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (905, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (906, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (907, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (908, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (909, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (910, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (911, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (912, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (913, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (914, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:09');
INSERT INTO `document_operation_logs` VALUES (915, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (916, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (917, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (918, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (919, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (920, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (921, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (922, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (923, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (924, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (925, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (926, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (927, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (928, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (929, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (930, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (931, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (932, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (933, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (934, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (935, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (936, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (937, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:10');
INSERT INTO `document_operation_logs` VALUES (938, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (939, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (940, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (941, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (942, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (943, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (944, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (945, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (946, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (947, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (948, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (949, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (950, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (951, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (952, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (953, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (954, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (955, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:11');
INSERT INTO `document_operation_logs` VALUES (956, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (957, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (958, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (959, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (960, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (961, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (962, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (963, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (964, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (965, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (966, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (967, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (968, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (969, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (970, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (971, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (972, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (973, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:12');
INSERT INTO `document_operation_logs` VALUES (974, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (975, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (976, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (977, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (978, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (979, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (980, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (981, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (982, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (983, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (984, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:22:13');
INSERT INTO `document_operation_logs` VALUES (985, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:22:14');
INSERT INTO `document_operation_logs` VALUES (986, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:25:52');
INSERT INTO `document_operation_logs` VALUES (987, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (988, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (989, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (990, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (991, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (992, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (993, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (994, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (995, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (996, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (997, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (998, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (999, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (1000, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:31');
INSERT INTO `document_operation_logs` VALUES (1001, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:32');
INSERT INTO `document_operation_logs` VALUES (1002, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:32');
INSERT INTO `document_operation_logs` VALUES (1003, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:32');
INSERT INTO `document_operation_logs` VALUES (1004, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:32');
INSERT INTO `document_operation_logs` VALUES (1005, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:32');
INSERT INTO `document_operation_logs` VALUES (1006, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:33');
INSERT INTO `document_operation_logs` VALUES (1007, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:33');
INSERT INTO `document_operation_logs` VALUES (1008, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:33');
INSERT INTO `document_operation_logs` VALUES (1009, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:33');
INSERT INTO `document_operation_logs` VALUES (1010, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:33');
INSERT INTO `document_operation_logs` VALUES (1011, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:26:42');
INSERT INTO `document_operation_logs` VALUES (1012, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:26:42');
INSERT INTO `document_operation_logs` VALUES (1013, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:27:56');
INSERT INTO `document_operation_logs` VALUES (1014, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:27:58');
INSERT INTO `document_operation_logs` VALUES (1015, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:27:58');
INSERT INTO `document_operation_logs` VALUES (1016, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:27:58');
INSERT INTO `document_operation_logs` VALUES (1017, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:00');
INSERT INTO `document_operation_logs` VALUES (1018, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:23');
INSERT INTO `document_operation_logs` VALUES (1019, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:23');
INSERT INTO `document_operation_logs` VALUES (1020, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:23');
INSERT INTO `document_operation_logs` VALUES (1021, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:24');
INSERT INTO `document_operation_logs` VALUES (1022, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:24');
INSERT INTO `document_operation_logs` VALUES (1023, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:24');
INSERT INTO `document_operation_logs` VALUES (1024, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:25');
INSERT INTO `document_operation_logs` VALUES (1025, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:25');
INSERT INTO `document_operation_logs` VALUES (1026, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:26');
INSERT INTO `document_operation_logs` VALUES (1027, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:26');
INSERT INTO `document_operation_logs` VALUES (1028, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:27');
INSERT INTO `document_operation_logs` VALUES (1029, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:27');
INSERT INTO `document_operation_logs` VALUES (1030, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:28');
INSERT INTO `document_operation_logs` VALUES (1031, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:28');
INSERT INTO `document_operation_logs` VALUES (1032, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:29');
INSERT INTO `document_operation_logs` VALUES (1033, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:29');
INSERT INTO `document_operation_logs` VALUES (1034, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:30');
INSERT INTO `document_operation_logs` VALUES (1035, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:30');
INSERT INTO `document_operation_logs` VALUES (1036, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:31');
INSERT INTO `document_operation_logs` VALUES (1037, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:31');
INSERT INTO `document_operation_logs` VALUES (1038, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:32');
INSERT INTO `document_operation_logs` VALUES (1039, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:32');
INSERT INTO `document_operation_logs` VALUES (1040, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:33');
INSERT INTO `document_operation_logs` VALUES (1041, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:33');
INSERT INTO `document_operation_logs` VALUES (1042, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:34');
INSERT INTO `document_operation_logs` VALUES (1043, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:34');
INSERT INTO `document_operation_logs` VALUES (1044, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:35');
INSERT INTO `document_operation_logs` VALUES (1045, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:35');
INSERT INTO `document_operation_logs` VALUES (1046, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:36');
INSERT INTO `document_operation_logs` VALUES (1047, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:36');
INSERT INTO `document_operation_logs` VALUES (1048, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:37');
INSERT INTO `document_operation_logs` VALUES (1049, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:37');
INSERT INTO `document_operation_logs` VALUES (1050, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:38');
INSERT INTO `document_operation_logs` VALUES (1051, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:38');
INSERT INTO `document_operation_logs` VALUES (1052, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:39');
INSERT INTO `document_operation_logs` VALUES (1053, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:39');
INSERT INTO `document_operation_logs` VALUES (1054, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:40');
INSERT INTO `document_operation_logs` VALUES (1055, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:40');
INSERT INTO `document_operation_logs` VALUES (1056, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:41');
INSERT INTO `document_operation_logs` VALUES (1057, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:41');
INSERT INTO `document_operation_logs` VALUES (1058, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:42');
INSERT INTO `document_operation_logs` VALUES (1059, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:42');
INSERT INTO `document_operation_logs` VALUES (1060, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:43');
INSERT INTO `document_operation_logs` VALUES (1061, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:43');
INSERT INTO `document_operation_logs` VALUES (1062, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:43');
INSERT INTO `document_operation_logs` VALUES (1063, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:44');
INSERT INTO `document_operation_logs` VALUES (1064, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:44');
INSERT INTO `document_operation_logs` VALUES (1065, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:44');
INSERT INTO `document_operation_logs` VALUES (1066, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:45');
INSERT INTO `document_operation_logs` VALUES (1067, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:45');
INSERT INTO `document_operation_logs` VALUES (1068, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:46');
INSERT INTO `document_operation_logs` VALUES (1069, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:46');
INSERT INTO `document_operation_logs` VALUES (1070, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:47');
INSERT INTO `document_operation_logs` VALUES (1071, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:47');
INSERT INTO `document_operation_logs` VALUES (1072, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:48');
INSERT INTO `document_operation_logs` VALUES (1073, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:48');
INSERT INTO `document_operation_logs` VALUES (1074, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:49');
INSERT INTO `document_operation_logs` VALUES (1075, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:49');
INSERT INTO `document_operation_logs` VALUES (1076, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:50');
INSERT INTO `document_operation_logs` VALUES (1077, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:50');
INSERT INTO `document_operation_logs` VALUES (1078, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:51');
INSERT INTO `document_operation_logs` VALUES (1079, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:51');
INSERT INTO `document_operation_logs` VALUES (1080, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:52');
INSERT INTO `document_operation_logs` VALUES (1081, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:52');
INSERT INTO `document_operation_logs` VALUES (1082, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:53');
INSERT INTO `document_operation_logs` VALUES (1083, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:53');
INSERT INTO `document_operation_logs` VALUES (1084, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:54');
INSERT INTO `document_operation_logs` VALUES (1085, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:54');
INSERT INTO `document_operation_logs` VALUES (1086, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:55');
INSERT INTO `document_operation_logs` VALUES (1087, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:55');
INSERT INTO `document_operation_logs` VALUES (1088, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:56');
INSERT INTO `document_operation_logs` VALUES (1089, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:56');
INSERT INTO `document_operation_logs` VALUES (1090, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:57');
INSERT INTO `document_operation_logs` VALUES (1091, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:57');
INSERT INTO `document_operation_logs` VALUES (1092, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:58');
INSERT INTO `document_operation_logs` VALUES (1093, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:58');
INSERT INTO `document_operation_logs` VALUES (1094, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:30:59');
INSERT INTO `document_operation_logs` VALUES (1095, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:30:59');
INSERT INTO `document_operation_logs` VALUES (1096, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:00');
INSERT INTO `document_operation_logs` VALUES (1097, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:00');
INSERT INTO `document_operation_logs` VALUES (1098, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:01');
INSERT INTO `document_operation_logs` VALUES (1099, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:01');
INSERT INTO `document_operation_logs` VALUES (1100, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:02');
INSERT INTO `document_operation_logs` VALUES (1101, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:02');
INSERT INTO `document_operation_logs` VALUES (1102, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:03');
INSERT INTO `document_operation_logs` VALUES (1103, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:03');
INSERT INTO `document_operation_logs` VALUES (1104, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:04');
INSERT INTO `document_operation_logs` VALUES (1105, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:04');
INSERT INTO `document_operation_logs` VALUES (1106, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:05');
INSERT INTO `document_operation_logs` VALUES (1107, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:05');
INSERT INTO `document_operation_logs` VALUES (1108, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:06');
INSERT INTO `document_operation_logs` VALUES (1109, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:08');
INSERT INTO `document_operation_logs` VALUES (1110, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:08');
INSERT INTO `document_operation_logs` VALUES (1111, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:08');
INSERT INTO `document_operation_logs` VALUES (1112, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:08');
INSERT INTO `document_operation_logs` VALUES (1113, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:09');
INSERT INTO `document_operation_logs` VALUES (1114, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:09');
INSERT INTO `document_operation_logs` VALUES (1115, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:09');
INSERT INTO `document_operation_logs` VALUES (1116, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:31:09');
INSERT INTO `document_operation_logs` VALUES (1117, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:31:10');
INSERT INTO `document_operation_logs` VALUES (1118, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:35:57');
INSERT INTO `document_operation_logs` VALUES (1119, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:37:43');
INSERT INTO `document_operation_logs` VALUES (1120, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:37:44');
INSERT INTO `document_operation_logs` VALUES (1121, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:37:45');
INSERT INTO `document_operation_logs` VALUES (1122, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:37:45');
INSERT INTO `document_operation_logs` VALUES (1123, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:37:46');
INSERT INTO `document_operation_logs` VALUES (1124, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:41:58');
INSERT INTO `document_operation_logs` VALUES (1125, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:43:04');
INSERT INTO `document_operation_logs` VALUES (1126, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:43:04');
INSERT INTO `document_operation_logs` VALUES (1127, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:45:46');
INSERT INTO `document_operation_logs` VALUES (1128, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 17:45:58');
INSERT INTO `document_operation_logs` VALUES (1129, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 17:45:59');
INSERT INTO `document_operation_logs` VALUES (1130, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 18:02:48');
INSERT INTO `document_operation_logs` VALUES (1131, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 18:06:23');
INSERT INTO `document_operation_logs` VALUES (1132, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 18:06:25');
INSERT INTO `document_operation_logs` VALUES (1133, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 18:06:26');
INSERT INTO `document_operation_logs` VALUES (1134, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 18:08:25');
INSERT INTO `document_operation_logs` VALUES (1135, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 18:23:45');
INSERT INTO `document_operation_logs` VALUES (1136, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 18:25:03');
INSERT INTO `document_operation_logs` VALUES (1137, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:12:25');
INSERT INTO `document_operation_logs` VALUES (1138, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:14:27');
INSERT INTO `document_operation_logs` VALUES (1139, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:14:27');
INSERT INTO `document_operation_logs` VALUES (1140, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:15:29');
INSERT INTO `document_operation_logs` VALUES (1141, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:15:58');
INSERT INTO `document_operation_logs` VALUES (1142, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:15:59');
INSERT INTO `document_operation_logs` VALUES (1143, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:18:54');
INSERT INTO `document_operation_logs` VALUES (1144, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:18:54');
INSERT INTO `document_operation_logs` VALUES (1145, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:19:23');
INSERT INTO `document_operation_logs` VALUES (1146, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:19:23');
INSERT INTO `document_operation_logs` VALUES (1147, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:21:48');
INSERT INTO `document_operation_logs` VALUES (1148, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:21:49');
INSERT INTO `document_operation_logs` VALUES (1149, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:22:03');
INSERT INTO `document_operation_logs` VALUES (1150, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:22:05');
INSERT INTO `document_operation_logs` VALUES (1151, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:22:42');
INSERT INTO `document_operation_logs` VALUES (1152, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:22:43');
INSERT INTO `document_operation_logs` VALUES (1153, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:23:14');
INSERT INTO `document_operation_logs` VALUES (1154, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:23:15');
INSERT INTO `document_operation_logs` VALUES (1155, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:23:24');
INSERT INTO `document_operation_logs` VALUES (1156, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:23:46');
INSERT INTO `document_operation_logs` VALUES (1157, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:23:46');
INSERT INTO `document_operation_logs` VALUES (1158, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:23:47');
INSERT INTO `document_operation_logs` VALUES (1159, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:24:23');
INSERT INTO `document_operation_logs` VALUES (1160, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:24:23');
INSERT INTO `document_operation_logs` VALUES (1161, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:24:24');
INSERT INTO `document_operation_logs` VALUES (1162, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:25:45');
INSERT INTO `document_operation_logs` VALUES (1163, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:25:45');
INSERT INTO `document_operation_logs` VALUES (1164, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:25:57');
INSERT INTO `document_operation_logs` VALUES (1165, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:25:57');
INSERT INTO `document_operation_logs` VALUES (1166, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:25:57');
INSERT INTO `document_operation_logs` VALUES (1167, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:26:05');
INSERT INTO `document_operation_logs` VALUES (1168, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:26:05');
INSERT INTO `document_operation_logs` VALUES (1169, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:26:05');
INSERT INTO `document_operation_logs` VALUES (1170, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:26:06');
INSERT INTO `document_operation_logs` VALUES (1171, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:26:06');
INSERT INTO `document_operation_logs` VALUES (1172, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:26:06');
INSERT INTO `document_operation_logs` VALUES (1173, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:37');
INSERT INTO `document_operation_logs` VALUES (1174, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:37');
INSERT INTO `document_operation_logs` VALUES (1175, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:27:38');
INSERT INTO `document_operation_logs` VALUES (1176, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1177, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1178, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1179, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1180, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1181, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:27:42');
INSERT INTO `document_operation_logs` VALUES (1182, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:28:28');
INSERT INTO `document_operation_logs` VALUES (1183, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:28:29');
INSERT INTO `document_operation_logs` VALUES (1184, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:28:32');
INSERT INTO `document_operation_logs` VALUES (1185, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:28:32');
INSERT INTO `document_operation_logs` VALUES (1186, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:28:32');
INSERT INTO `document_operation_logs` VALUES (1187, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:30:53');
INSERT INTO `document_operation_logs` VALUES (1188, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:30:53');
INSERT INTO `document_operation_logs` VALUES (1189, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:30:53');
INSERT INTO `document_operation_logs` VALUES (1190, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:30:53');
INSERT INTO `document_operation_logs` VALUES (1191, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:30:53');
INSERT INTO `document_operation_logs` VALUES (1192, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:29');
INSERT INTO `document_operation_logs` VALUES (1193, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:29');
INSERT INTO `document_operation_logs` VALUES (1194, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:31:30');
INSERT INTO `document_operation_logs` VALUES (1195, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:30');
INSERT INTO `document_operation_logs` VALUES (1196, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:31:30');
INSERT INTO `document_operation_logs` VALUES (1197, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:30');
INSERT INTO `document_operation_logs` VALUES (1198, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:31:30');
INSERT INTO `document_operation_logs` VALUES (1199, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:31');
INSERT INTO `document_operation_logs` VALUES (1200, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:31:31');
INSERT INTO `document_operation_logs` VALUES (1201, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:31:55');
INSERT INTO `document_operation_logs` VALUES (1202, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:31:55');
INSERT INTO `document_operation_logs` VALUES (1203, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:37:49');
INSERT INTO `document_operation_logs` VALUES (1204, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:37:50');
INSERT INTO `document_operation_logs` VALUES (1205, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:41:49');
INSERT INTO `document_operation_logs` VALUES (1206, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:41:50');
INSERT INTO `document_operation_logs` VALUES (1207, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:41:50');
INSERT INTO `document_operation_logs` VALUES (1208, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:41:51');
INSERT INTO `document_operation_logs` VALUES (1209, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:48:17');
INSERT INTO `document_operation_logs` VALUES (1210, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:48:17');
INSERT INTO `document_operation_logs` VALUES (1211, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:48:17');
INSERT INTO `document_operation_logs` VALUES (1212, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:48:17');
INSERT INTO `document_operation_logs` VALUES (1213, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:48:29');
INSERT INTO `document_operation_logs` VALUES (1214, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:48:29');
INSERT INTO `document_operation_logs` VALUES (1215, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:48:29');
INSERT INTO `document_operation_logs` VALUES (1216, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:48:29');
INSERT INTO `document_operation_logs` VALUES (1217, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:48:29');
INSERT INTO `document_operation_logs` VALUES (1218, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:49:49');
INSERT INTO `document_operation_logs` VALUES (1219, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:49:50');
INSERT INTO `document_operation_logs` VALUES (1220, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:50:49');
INSERT INTO `document_operation_logs` VALUES (1221, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:50:50');
INSERT INTO `document_operation_logs` VALUES (1222, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1223, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1224, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1225, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1226, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1227, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:54:49');
INSERT INTO `document_operation_logs` VALUES (1228, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 20:54:50');
INSERT INTO `document_operation_logs` VALUES (1229, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 20:58:49');
INSERT INTO `document_operation_logs` VALUES (1230, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:03:01');
INSERT INTO `document_operation_logs` VALUES (1231, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:03:01');
INSERT INTO `document_operation_logs` VALUES (1232, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:03:14');
INSERT INTO `document_operation_logs` VALUES (1233, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:03:14');
INSERT INTO `document_operation_logs` VALUES (1234, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:12');
INSERT INTO `document_operation_logs` VALUES (1235, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:13');
INSERT INTO `document_operation_logs` VALUES (1236, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:13');
INSERT INTO `document_operation_logs` VALUES (1237, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1238, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1239, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1240, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1241, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1242, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:14');
INSERT INTO `document_operation_logs` VALUES (1243, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:18');
INSERT INTO `document_operation_logs` VALUES (1244, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:18');
INSERT INTO `document_operation_logs` VALUES (1245, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:18');
INSERT INTO `document_operation_logs` VALUES (1246, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:20');
INSERT INTO `document_operation_logs` VALUES (1247, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:20');
INSERT INTO `document_operation_logs` VALUES (1248, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:21');
INSERT INTO `document_operation_logs` VALUES (1249, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:21');
INSERT INTO `document_operation_logs` VALUES (1250, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:21');
INSERT INTO `document_operation_logs` VALUES (1251, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:21');
INSERT INTO `document_operation_logs` VALUES (1252, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:21');
INSERT INTO `document_operation_logs` VALUES (1253, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:22');
INSERT INTO `document_operation_logs` VALUES (1254, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:22');
INSERT INTO `document_operation_logs` VALUES (1255, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:22');
INSERT INTO `document_operation_logs` VALUES (1256, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:27');
INSERT INTO `document_operation_logs` VALUES (1257, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:27');
INSERT INTO `document_operation_logs` VALUES (1258, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:29');
INSERT INTO `document_operation_logs` VALUES (1259, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:29');
INSERT INTO `document_operation_logs` VALUES (1260, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:30');
INSERT INTO `document_operation_logs` VALUES (1261, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:30');
INSERT INTO `document_operation_logs` VALUES (1262, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:30');
INSERT INTO `document_operation_logs` VALUES (1263, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:32');
INSERT INTO `document_operation_logs` VALUES (1264, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:32');
INSERT INTO `document_operation_logs` VALUES (1265, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:33');
INSERT INTO `document_operation_logs` VALUES (1266, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:34');
INSERT INTO `document_operation_logs` VALUES (1267, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:35');
INSERT INTO `document_operation_logs` VALUES (1268, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:35');
INSERT INTO `document_operation_logs` VALUES (1269, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:04:35');
INSERT INTO `document_operation_logs` VALUES (1270, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:41');
INSERT INTO `document_operation_logs` VALUES (1271, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:41');
INSERT INTO `document_operation_logs` VALUES (1272, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:04:42');
INSERT INTO `document_operation_logs` VALUES (1273, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:05:59');
INSERT INTO `document_operation_logs` VALUES (1274, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:06:00');
INSERT INTO `document_operation_logs` VALUES (1275, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1276, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1277, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1278, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1279, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1280, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:07:05');
INSERT INTO `document_operation_logs` VALUES (1281, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:10:03');
INSERT INTO `document_operation_logs` VALUES (1282, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:10:03');
INSERT INTO `document_operation_logs` VALUES (1283, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:10:04');
INSERT INTO `document_operation_logs` VALUES (1284, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:17:13');
INSERT INTO `document_operation_logs` VALUES (1285, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:17:14');
INSERT INTO `document_operation_logs` VALUES (1286, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:23:48');
INSERT INTO `document_operation_logs` VALUES (1287, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:23:48');
INSERT INTO `document_operation_logs` VALUES (1288, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:23:48');
INSERT INTO `document_operation_logs` VALUES (1289, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:23:48');
INSERT INTO `document_operation_logs` VALUES (1290, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:23:48');
INSERT INTO `document_operation_logs` VALUES (1291, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:20');
INSERT INTO `document_operation_logs` VALUES (1292, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:20');
INSERT INTO `document_operation_logs` VALUES (1293, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:20');
INSERT INTO `document_operation_logs` VALUES (1294, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:24:20');
INSERT INTO `document_operation_logs` VALUES (1295, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:24:20');
INSERT INTO `document_operation_logs` VALUES (1296, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:41');
INSERT INTO `document_operation_logs` VALUES (1297, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:41');
INSERT INTO `document_operation_logs` VALUES (1298, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:24:41');
INSERT INTO `document_operation_logs` VALUES (1299, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:24:41');
INSERT INTO `document_operation_logs` VALUES (1300, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:24:41');
INSERT INTO `document_operation_logs` VALUES (1301, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:46');
INSERT INTO `document_operation_logs` VALUES (1302, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:46');
INSERT INTO `document_operation_logs` VALUES (1303, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:26:46');
INSERT INTO `document_operation_logs` VALUES (1304, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:48');
INSERT INTO `document_operation_logs` VALUES (1305, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:26:48');
INSERT INTO `document_operation_logs` VALUES (1306, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:50');
INSERT INTO `document_operation_logs` VALUES (1307, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:50');
INSERT INTO `document_operation_logs` VALUES (1308, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:26:52');
INSERT INTO `document_operation_logs` VALUES (1309, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:26:53');
INSERT INTO `document_operation_logs` VALUES (1310, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:26:53');
INSERT INTO `document_operation_logs` VALUES (1311, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:12');
INSERT INTO `document_operation_logs` VALUES (1312, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:12');
INSERT INTO `document_operation_logs` VALUES (1313, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:27:14');
INSERT INTO `document_operation_logs` VALUES (1314, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:15');
INSERT INTO `document_operation_logs` VALUES (1315, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:15');
INSERT INTO `document_operation_logs` VALUES (1316, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:27:16');
INSERT INTO `document_operation_logs` VALUES (1317, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:54');
INSERT INTO `document_operation_logs` VALUES (1318, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:27:54');
INSERT INTO `document_operation_logs` VALUES (1319, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-18 21:27:54');
INSERT INTO `document_operation_logs` VALUES (1320, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:28:47');
INSERT INTO `document_operation_logs` VALUES (1321, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-18 21:28:48');
INSERT INTO `document_operation_logs` VALUES (1322, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 15:59:26');
INSERT INTO `document_operation_logs` VALUES (1323, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 15:59:28');
INSERT INTO `document_operation_logs` VALUES (1324, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1325, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1326, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1327, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1328, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1329, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:11');
INSERT INTO `document_operation_logs` VALUES (1330, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:12');
INSERT INTO `document_operation_logs` VALUES (1331, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:13');
INSERT INTO `document_operation_logs` VALUES (1332, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:14');
INSERT INTO `document_operation_logs` VALUES (1333, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:14');
INSERT INTO `document_operation_logs` VALUES (1334, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:14');
INSERT INTO `document_operation_logs` VALUES (1335, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:15');
INSERT INTO `document_operation_logs` VALUES (1336, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:15');
INSERT INTO `document_operation_logs` VALUES (1337, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:15');
INSERT INTO `document_operation_logs` VALUES (1338, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:01:15');
INSERT INTO `document_operation_logs` VALUES (1339, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:01:16');
INSERT INTO `document_operation_logs` VALUES (1340, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:22:49');
INSERT INTO `document_operation_logs` VALUES (1341, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:22:49');
INSERT INTO `document_operation_logs` VALUES (1342, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:22:50');
INSERT INTO `document_operation_logs` VALUES (1343, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:22:50');
INSERT INTO `document_operation_logs` VALUES (1344, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:25:54');
INSERT INTO `document_operation_logs` VALUES (1345, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:25:54');
INSERT INTO `document_operation_logs` VALUES (1346, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:27:41');
INSERT INTO `document_operation_logs` VALUES (1347, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:27:42');
INSERT INTO `document_operation_logs` VALUES (1348, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:27:46');
INSERT INTO `document_operation_logs` VALUES (1349, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:27:46');
INSERT INTO `document_operation_logs` VALUES (1350, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:27:46');
INSERT INTO `document_operation_logs` VALUES (1351, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:27:47');
INSERT INTO `document_operation_logs` VALUES (1352, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:27:48');
INSERT INTO `document_operation_logs` VALUES (1353, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:31:54');
INSERT INTO `document_operation_logs` VALUES (1354, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:31:54');
INSERT INTO `document_operation_logs` VALUES (1355, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:31:54');
INSERT INTO `document_operation_logs` VALUES (1356, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:31:54');
INSERT INTO `document_operation_logs` VALUES (1357, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:32:31');
INSERT INTO `document_operation_logs` VALUES (1358, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:32:31');
INSERT INTO `document_operation_logs` VALUES (1359, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:32:31');
INSERT INTO `document_operation_logs` VALUES (1360, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:32:33');
INSERT INTO `document_operation_logs` VALUES (1361, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:32:34');
INSERT INTO `document_operation_logs` VALUES (1362, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:34:00');
INSERT INTO `document_operation_logs` VALUES (1363, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:34:03');
INSERT INTO `document_operation_logs` VALUES (1364, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:35:37');
INSERT INTO `document_operation_logs` VALUES (1365, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:42:40');
INSERT INTO `document_operation_logs` VALUES (1366, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:44:30');
INSERT INTO `document_operation_logs` VALUES (1367, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:45:55');
INSERT INTO `document_operation_logs` VALUES (1368, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:46:12');
INSERT INTO `document_operation_logs` VALUES (1369, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:46:16');
INSERT INTO `document_operation_logs` VALUES (1370, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:53:26');
INSERT INTO `document_operation_logs` VALUES (1371, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:53:26');
INSERT INTO `document_operation_logs` VALUES (1372, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:53:26');
INSERT INTO `document_operation_logs` VALUES (1373, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:53:26');
INSERT INTO `document_operation_logs` VALUES (1374, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:53:54');
INSERT INTO `document_operation_logs` VALUES (1375, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:53:54');
INSERT INTO `document_operation_logs` VALUES (1376, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:53:54');
INSERT INTO `document_operation_logs` VALUES (1377, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:53:54');
INSERT INTO `document_operation_logs` VALUES (1378, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 16:58:54');
INSERT INTO `document_operation_logs` VALUES (1379, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 16:58:54');
INSERT INTO `document_operation_logs` VALUES (1380, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:14:21');
INSERT INTO `document_operation_logs` VALUES (1381, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:14:22');
INSERT INTO `document_operation_logs` VALUES (1382, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:29:21');
INSERT INTO `document_operation_logs` VALUES (1383, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:29:22');
INSERT INTO `document_operation_logs` VALUES (1384, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:33:21');
INSERT INTO `document_operation_logs` VALUES (1385, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:33:22');
INSERT INTO `document_operation_logs` VALUES (1386, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:36:53');
INSERT INTO `document_operation_logs` VALUES (1387, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:36:53');
INSERT INTO `document_operation_logs` VALUES (1388, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:37:58');
INSERT INTO `document_operation_logs` VALUES (1389, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:38:04');
INSERT INTO `document_operation_logs` VALUES (1390, 31, 3, 'invite', '邀请用户 5 加入文档', '2026-01-19 17:38:10');
INSERT INTO `document_operation_logs` VALUES (1391, 31, 5, 'accept_invite', '接受邀请', '2026-01-19 17:38:24');
INSERT INTO `document_operation_logs` VALUES (1392, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:39:21');
INSERT INTO `document_operation_logs` VALUES (1393, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:39:33');
INSERT INTO `document_operation_logs` VALUES (1394, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:39:33');
INSERT INTO `document_operation_logs` VALUES (1395, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:39:59');
INSERT INTO `document_operation_logs` VALUES (1396, 32, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:40:12');
INSERT INTO `document_operation_logs` VALUES (1397, 32, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:40:14');
INSERT INTO `document_operation_logs` VALUES (1398, 32, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:40:15');
INSERT INTO `document_operation_logs` VALUES (1399, 32, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 17:40:20');
INSERT INTO `document_operation_logs` VALUES (1400, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:40:23');
INSERT INTO `document_operation_logs` VALUES (1401, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-19 17:40:40');
INSERT INTO `document_operation_logs` VALUES (1402, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 18:00:49');
INSERT INTO `document_operation_logs` VALUES (1403, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 18:00:49');
INSERT INTO `document_operation_logs` VALUES (1404, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-19 18:00:50');
INSERT INTO `document_operation_logs` VALUES (1405, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 18:00:50');
INSERT INTO `document_operation_logs` VALUES (1406, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 18:03:49');
INSERT INTO `document_operation_logs` VALUES (1407, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-19 18:03:50');
INSERT INTO `document_operation_logs` VALUES (1408, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 18:06:12');
INSERT INTO `document_operation_logs` VALUES (1409, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 18:06:14');
INSERT INTO `document_operation_logs` VALUES (1410, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 20:20:20');
INSERT INTO `document_operation_logs` VALUES (1411, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-19 20:20:38');
INSERT INTO `document_operation_logs` VALUES (1412, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-19 20:20:40');
INSERT INTO `document_operation_logs` VALUES (1413, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:27:20');
INSERT INTO `document_operation_logs` VALUES (1414, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:33:45');
INSERT INTO `document_operation_logs` VALUES (1415, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:34:07');
INSERT INTO `document_operation_logs` VALUES (1416, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:34:07');
INSERT INTO `document_operation_logs` VALUES (1417, 31, 3, 'update_permission', '修改用户 5 的权限级别为 0', '2026-01-20 15:34:10');
INSERT INTO `document_operation_logs` VALUES (1418, 31, 3, 'update_permission', '修改用户 5 的权限级别为 2', '2026-01-20 15:34:12');
INSERT INTO `document_operation_logs` VALUES (1419, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:35:00');
INSERT INTO `document_operation_logs` VALUES (1420, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:35:01');
INSERT INTO `document_operation_logs` VALUES (1421, 31, 3, 'update_permission', '修改用户 4 的权限级别为 0', '2026-01-20 15:35:03');
INSERT INTO `document_operation_logs` VALUES (1422, 31, 3, 'update_permission', '修改用户 4 的权限级别为 1', '2026-01-20 15:35:06');
INSERT INTO `document_operation_logs` VALUES (1423, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:35:45');
INSERT INTO `document_operation_logs` VALUES (1424, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:35:46');
INSERT INTO `document_operation_logs` VALUES (1425, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:54:21');
INSERT INTO `document_operation_logs` VALUES (1426, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:54:22');
INSERT INTO `document_operation_logs` VALUES (1427, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:54:22');
INSERT INTO `document_operation_logs` VALUES (1428, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:54:22');
INSERT INTO `document_operation_logs` VALUES (1429, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:54:22');
INSERT INTO `document_operation_logs` VALUES (1430, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:54:23');
INSERT INTO `document_operation_logs` VALUES (1431, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:54:23');
INSERT INTO `document_operation_logs` VALUES (1432, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 15:54:23');
INSERT INTO `document_operation_logs` VALUES (1433, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 15:54:23');
INSERT INTO `document_operation_logs` VALUES (1434, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:00:51');
INSERT INTO `document_operation_logs` VALUES (1435, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:00:51');
INSERT INTO `document_operation_logs` VALUES (1436, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:06:55');
INSERT INTO `document_operation_logs` VALUES (1437, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:06:55');
INSERT INTO `document_operation_logs` VALUES (1438, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:07:49');
INSERT INTO `document_operation_logs` VALUES (1439, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:07:49');
INSERT INTO `document_operation_logs` VALUES (1440, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:08:18');
INSERT INTO `document_operation_logs` VALUES (1441, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:08:18');
INSERT INTO `document_operation_logs` VALUES (1442, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:13:04');
INSERT INTO `document_operation_logs` VALUES (1443, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:13:23');
INSERT INTO `document_operation_logs` VALUES (1444, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:13:24');
INSERT INTO `document_operation_logs` VALUES (1445, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:23:48');
INSERT INTO `document_operation_logs` VALUES (1446, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:23:49');
INSERT INTO `document_operation_logs` VALUES (1447, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:24:08');
INSERT INTO `document_operation_logs` VALUES (1448, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:24:10');
INSERT INTO `document_operation_logs` VALUES (1449, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:33:12');
INSERT INTO `document_operation_logs` VALUES (1450, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:33:13');
INSERT INTO `document_operation_logs` VALUES (1451, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:33:54');
INSERT INTO `document_operation_logs` VALUES (1452, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:41:29');
INSERT INTO `document_operation_logs` VALUES (1453, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:41:29');
INSERT INTO `document_operation_logs` VALUES (1454, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:41:42');
INSERT INTO `document_operation_logs` VALUES (1455, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:41:42');
INSERT INTO `document_operation_logs` VALUES (1456, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:43:28');
INSERT INTO `document_operation_logs` VALUES (1457, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:44:08');
INSERT INTO `document_operation_logs` VALUES (1458, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:44:09');
INSERT INTO `document_operation_logs` VALUES (1459, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:49:34');
INSERT INTO `document_operation_logs` VALUES (1460, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:49:34');
INSERT INTO `document_operation_logs` VALUES (1461, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:50:15');
INSERT INTO `document_operation_logs` VALUES (1462, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:50:15');
INSERT INTO `document_operation_logs` VALUES (1463, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:51:08');
INSERT INTO `document_operation_logs` VALUES (1464, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 16:51:08');
INSERT INTO `document_operation_logs` VALUES (1465, 31, 3, 'update_permission', '修改用户 4 的权限级别为 1', '2026-01-20 16:51:19');
INSERT INTO `document_operation_logs` VALUES (1466, 31, 3, 'update_permission', '修改用户 4 的权限级别为 0', '2026-01-20 16:51:23');
INSERT INTO `document_operation_logs` VALUES (1467, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 16:55:10');
INSERT INTO `document_operation_logs` VALUES (1468, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:02:54');
INSERT INTO `document_operation_logs` VALUES (1469, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:06:02');
INSERT INTO `document_operation_logs` VALUES (1470, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:06:02');
INSERT INTO `document_operation_logs` VALUES (1471, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:06:26');
INSERT INTO `document_operation_logs` VALUES (1472, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:06:27');
INSERT INTO `document_operation_logs` VALUES (1473, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:06:27');
INSERT INTO `document_operation_logs` VALUES (1474, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:06:27');
INSERT INTO `document_operation_logs` VALUES (1475, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:06:36');
INSERT INTO `document_operation_logs` VALUES (1476, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:06:36');
INSERT INTO `document_operation_logs` VALUES (1477, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:07:13');
INSERT INTO `document_operation_logs` VALUES (1478, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:07:13');
INSERT INTO `document_operation_logs` VALUES (1479, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:15:38');
INSERT INTO `document_operation_logs` VALUES (1480, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:15:39');
INSERT INTO `document_operation_logs` VALUES (1481, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:21:18');
INSERT INTO `document_operation_logs` VALUES (1482, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:21:19');
INSERT INTO `document_operation_logs` VALUES (1483, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:27:16');
INSERT INTO `document_operation_logs` VALUES (1484, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:27:16');
INSERT INTO `document_operation_logs` VALUES (1485, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:31:49');
INSERT INTO `document_operation_logs` VALUES (1486, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-20 17:32:36');
INSERT INTO `document_operation_logs` VALUES (1487, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-20 17:54:04');
INSERT INTO `document_operation_logs` VALUES (1488, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:31:12');
INSERT INTO `document_operation_logs` VALUES (1489, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:31:51');
INSERT INTO `document_operation_logs` VALUES (1490, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:31:52');
INSERT INTO `document_operation_logs` VALUES (1491, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:32:34');
INSERT INTO `document_operation_logs` VALUES (1492, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:32:35');
INSERT INTO `document_operation_logs` VALUES (1493, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:36:39');
INSERT INTO `document_operation_logs` VALUES (1494, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:36:40');
INSERT INTO `document_operation_logs` VALUES (1495, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:39:44');
INSERT INTO `document_operation_logs` VALUES (1496, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:39:45');
INSERT INTO `document_operation_logs` VALUES (1497, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:46:24');
INSERT INTO `document_operation_logs` VALUES (1498, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:46:24');
INSERT INTO `document_operation_logs` VALUES (1499, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:48:01');
INSERT INTO `document_operation_logs` VALUES (1500, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:48:02');
INSERT INTO `document_operation_logs` VALUES (1501, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:50:32');
INSERT INTO `document_operation_logs` VALUES (1502, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:50:33');
INSERT INTO `document_operation_logs` VALUES (1503, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:51:05');
INSERT INTO `document_operation_logs` VALUES (1504, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:51:06');
INSERT INTO `document_operation_logs` VALUES (1505, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:51:36');
INSERT INTO `document_operation_logs` VALUES (1506, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:51:36');
INSERT INTO `document_operation_logs` VALUES (1507, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:53:25');
INSERT INTO `document_operation_logs` VALUES (1508, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:53:26');
INSERT INTO `document_operation_logs` VALUES (1509, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 21:53:34');
INSERT INTO `document_operation_logs` VALUES (1510, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 21:53:35');
INSERT INTO `document_operation_logs` VALUES (1511, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:08:35');
INSERT INTO `document_operation_logs` VALUES (1512, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:08:36');
INSERT INTO `document_operation_logs` VALUES (1513, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:08:41');
INSERT INTO `document_operation_logs` VALUES (1514, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:13:42');
INSERT INTO `document_operation_logs` VALUES (1515, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:23:44');
INSERT INTO `document_operation_logs` VALUES (1516, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:23:45');
INSERT INTO `document_operation_logs` VALUES (1517, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:29:06');
INSERT INTO `document_operation_logs` VALUES (1518, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:29:06');
INSERT INTO `document_operation_logs` VALUES (1519, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:29:06');
INSERT INTO `document_operation_logs` VALUES (1520, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:32:29');
INSERT INTO `document_operation_logs` VALUES (1521, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:32:29');
INSERT INTO `document_operation_logs` VALUES (1522, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:32:29');
INSERT INTO `document_operation_logs` VALUES (1523, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:32:29');
INSERT INTO `document_operation_logs` VALUES (1524, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:38:23');
INSERT INTO `document_operation_logs` VALUES (1525, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-21 22:38:24');
INSERT INTO `document_operation_logs` VALUES (1526, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:38:25');
INSERT INTO `document_operation_logs` VALUES (1527, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-21 22:38:29');
INSERT INTO `document_operation_logs` VALUES (1528, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:00:21');
INSERT INTO `document_operation_logs` VALUES (1529, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:22:04');
INSERT INTO `document_operation_logs` VALUES (1530, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:22:04');
INSERT INTO `document_operation_logs` VALUES (1531, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:25:42');
INSERT INTO `document_operation_logs` VALUES (1532, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:25:44');
INSERT INTO `document_operation_logs` VALUES (1533, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:26:36');
INSERT INTO `document_operation_logs` VALUES (1534, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:26:37');
INSERT INTO `document_operation_logs` VALUES (1535, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:26:43');
INSERT INTO `document_operation_logs` VALUES (1536, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:26:55');
INSERT INTO `document_operation_logs` VALUES (1537, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:28:23');
INSERT INTO `document_operation_logs` VALUES (1538, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:28:24');
INSERT INTO `document_operation_logs` VALUES (1539, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:28:26');
INSERT INTO `document_operation_logs` VALUES (1540, 32, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:28:27');
INSERT INTO `document_operation_logs` VALUES (1541, 32, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:28:28');
INSERT INTO `document_operation_logs` VALUES (1542, 32, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:28:29');
INSERT INTO `document_operation_logs` VALUES (1543, 32, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:28:30');
INSERT INTO `document_operation_logs` VALUES (1544, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:28:31');
INSERT INTO `document_operation_logs` VALUES (1545, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:30:53');
INSERT INTO `document_operation_logs` VALUES (1546, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:41:51');
INSERT INTO `document_operation_logs` VALUES (1547, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:45:46');
INSERT INTO `document_operation_logs` VALUES (1548, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:45:51');
INSERT INTO `document_operation_logs` VALUES (1549, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:45:51');
INSERT INTO `document_operation_logs` VALUES (1550, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 16:46:07');
INSERT INTO `document_operation_logs` VALUES (1551, 32, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:46:08');
INSERT INTO `document_operation_logs` VALUES (1552, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 16:55:39');
INSERT INTO `document_operation_logs` VALUES (1553, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:11:52');
INSERT INTO `document_operation_logs` VALUES (1554, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:11:52');
INSERT INTO `document_operation_logs` VALUES (1555, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:11:52');
INSERT INTO `document_operation_logs` VALUES (1556, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:21:29');
INSERT INTO `document_operation_logs` VALUES (1557, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:21:29');
INSERT INTO `document_operation_logs` VALUES (1558, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:23:50');
INSERT INTO `document_operation_logs` VALUES (1559, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:39:12');
INSERT INTO `document_operation_logs` VALUES (1560, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:39:12');
INSERT INTO `document_operation_logs` VALUES (1561, 33, 4, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:52:06');
INSERT INTO `document_operation_logs` VALUES (1562, 33, 4, 'invite', '邀请用户 3 加入文档', '2026-01-22 17:52:14');
INSERT INTO `document_operation_logs` VALUES (1563, 33, 4, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:52:15');
INSERT INTO `document_operation_logs` VALUES (1564, 33, 3, 'accept_invite', '接受邀请', '2026-01-22 17:52:25');
INSERT INTO `document_operation_logs` VALUES (1565, 33, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 17:53:34');
INSERT INTO `document_operation_logs` VALUES (1566, 33, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 17:53:38');
INSERT INTO `document_operation_logs` VALUES (1567, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:40:09');
INSERT INTO `document_operation_logs` VALUES (1568, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:40:53');
INSERT INTO `document_operation_logs` VALUES (1569, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:43:39');
INSERT INTO `document_operation_logs` VALUES (1570, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:43:45');
INSERT INTO `document_operation_logs` VALUES (1571, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:43:55');
INSERT INTO `document_operation_logs` VALUES (1572, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:43:57');
INSERT INTO `document_operation_logs` VALUES (1573, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:48:32');
INSERT INTO `document_operation_logs` VALUES (1574, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:48:34');
INSERT INTO `document_operation_logs` VALUES (1575, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:56:10');
INSERT INTO `document_operation_logs` VALUES (1576, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:56:12');
INSERT INTO `document_operation_logs` VALUES (1577, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:56:15');
INSERT INTO `document_operation_logs` VALUES (1578, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:56:16');
INSERT INTO `document_operation_logs` VALUES (1579, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:56:46');
INSERT INTO `document_operation_logs` VALUES (1580, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:56:51');
INSERT INTO `document_operation_logs` VALUES (1581, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 19:57:02');
INSERT INTO `document_operation_logs` VALUES (1582, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 19:57:04');
INSERT INTO `document_operation_logs` VALUES (1583, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 20:21:25');
INSERT INTO `document_operation_logs` VALUES (1584, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 20:21:28');
INSERT INTO `document_operation_logs` VALUES (1585, 34, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 20:21:29');
INSERT INTO `document_operation_logs` VALUES (1586, 34, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 20:21:30');
INSERT INTO `document_operation_logs` VALUES (1587, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 20:21:31');
INSERT INTO `document_operation_logs` VALUES (1588, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 20:21:54');
INSERT INTO `document_operation_logs` VALUES (1589, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 20:21:55');
INSERT INTO `document_operation_logs` VALUES (1590, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 20:27:05');
INSERT INTO `document_operation_logs` VALUES (1591, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-22 20:35:52');
INSERT INTO `document_operation_logs` VALUES (1592, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-22 20:36:01');
INSERT INTO `document_operation_logs` VALUES (1593, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:02:56');
INSERT INTO `document_operation_logs` VALUES (1594, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:03:33');
INSERT INTO `document_operation_logs` VALUES (1595, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:05:48');
INSERT INTO `document_operation_logs` VALUES (1596, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:05:48');
INSERT INTO `document_operation_logs` VALUES (1597, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:07:51');
INSERT INTO `document_operation_logs` VALUES (1598, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:07:51');
INSERT INTO `document_operation_logs` VALUES (1599, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:13:16');
INSERT INTO `document_operation_logs` VALUES (1600, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:13:17');
INSERT INTO `document_operation_logs` VALUES (1601, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:20:52');
INSERT INTO `document_operation_logs` VALUES (1602, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:20:52');
INSERT INTO `document_operation_logs` VALUES (1603, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:20:52');
INSERT INTO `document_operation_logs` VALUES (1604, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:20:52');
INSERT INTO `document_operation_logs` VALUES (1605, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:21:17');
INSERT INTO `document_operation_logs` VALUES (1606, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:21:17');
INSERT INTO `document_operation_logs` VALUES (1607, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:21:17');
INSERT INTO `document_operation_logs` VALUES (1608, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:21:17');
INSERT INTO `document_operation_logs` VALUES (1609, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:21:59');
INSERT INTO `document_operation_logs` VALUES (1610, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:21:59');
INSERT INTO `document_operation_logs` VALUES (1611, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:21:59');
INSERT INTO `document_operation_logs` VALUES (1612, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:21:59');
INSERT INTO `document_operation_logs` VALUES (1613, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:22:47');
INSERT INTO `document_operation_logs` VALUES (1614, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:22:47');
INSERT INTO `document_operation_logs` VALUES (1615, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:22:47');
INSERT INTO `document_operation_logs` VALUES (1616, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:22:47');
INSERT INTO `document_operation_logs` VALUES (1617, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:22:47');
INSERT INTO `document_operation_logs` VALUES (1618, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:25:42');
INSERT INTO `document_operation_logs` VALUES (1619, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:25:42');
INSERT INTO `document_operation_logs` VALUES (1620, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:25:42');
INSERT INTO `document_operation_logs` VALUES (1621, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:26:00');
INSERT INTO `document_operation_logs` VALUES (1622, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:26:00');
INSERT INTO `document_operation_logs` VALUES (1623, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:26:00');
INSERT INTO `document_operation_logs` VALUES (1624, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:26:01');
INSERT INTO `document_operation_logs` VALUES (1625, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:43:16');
INSERT INTO `document_operation_logs` VALUES (1626, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:43:17');
INSERT INTO `document_operation_logs` VALUES (1627, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:46:16');
INSERT INTO `document_operation_logs` VALUES (1628, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:46:16');
INSERT INTO `document_operation_logs` VALUES (1629, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:46:17');
INSERT INTO `document_operation_logs` VALUES (1630, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:46:17');
INSERT INTO `document_operation_logs` VALUES (1631, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:48:16');
INSERT INTO `document_operation_logs` VALUES (1632, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:48:17');
INSERT INTO `document_operation_logs` VALUES (1633, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:51:16');
INSERT INTO `document_operation_logs` VALUES (1634, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:51:17');
INSERT INTO `document_operation_logs` VALUES (1635, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:53:16');
INSERT INTO `document_operation_logs` VALUES (1636, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:53:17');
INSERT INTO `document_operation_logs` VALUES (1637, 31, 5, 'leave_collaboration', '用户离开协同编辑', '2026-01-26 21:57:16');
INSERT INTO `document_operation_logs` VALUES (1638, 31, 5, 'join_collaboration', '用户加入协同编辑', '2026-01-26 21:57:17');
INSERT INTO `document_operation_logs` VALUES (1639, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 15:16:08');
INSERT INTO `document_operation_logs` VALUES (1640, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 15:32:03');
INSERT INTO `document_operation_logs` VALUES (1641, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 15:32:03');
INSERT INTO `document_operation_logs` VALUES (1642, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 15:32:03');
INSERT INTO `document_operation_logs` VALUES (1643, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 15:37:12');
INSERT INTO `document_operation_logs` VALUES (1644, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 15:37:13');
INSERT INTO `document_operation_logs` VALUES (1645, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 15:44:12');
INSERT INTO `document_operation_logs` VALUES (1646, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 15:44:13');
INSERT INTO `document_operation_logs` VALUES (1647, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 15:46:43');
INSERT INTO `document_operation_logs` VALUES (1648, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 15:46:43');
INSERT INTO `document_operation_logs` VALUES (1649, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:01:39');
INSERT INTO `document_operation_logs` VALUES (1650, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:04:03');
INSERT INTO `document_operation_logs` VALUES (1651, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:05:13');
INSERT INTO `document_operation_logs` VALUES (1652, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:06:13');
INSERT INTO `document_operation_logs` VALUES (1653, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:06:14');
INSERT INTO `document_operation_logs` VALUES (1654, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:08:24');
INSERT INTO `document_operation_logs` VALUES (1655, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:08:56');
INSERT INTO `document_operation_logs` VALUES (1656, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:08:57');
INSERT INTO `document_operation_logs` VALUES (1657, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:09:20');
INSERT INTO `document_operation_logs` VALUES (1658, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:09:20');
INSERT INTO `document_operation_logs` VALUES (1659, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:09:30');
INSERT INTO `document_operation_logs` VALUES (1660, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:09:32');
INSERT INTO `document_operation_logs` VALUES (1661, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:11:43');
INSERT INTO `document_operation_logs` VALUES (1662, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:11:43');
INSERT INTO `document_operation_logs` VALUES (1663, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:05');
INSERT INTO `document_operation_logs` VALUES (1664, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:06');
INSERT INTO `document_operation_logs` VALUES (1665, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:06');
INSERT INTO `document_operation_logs` VALUES (1666, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1667, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1668, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1669, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1670, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1671, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:07');
INSERT INTO `document_operation_logs` VALUES (1672, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1673, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1674, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1675, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1676, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1677, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1678, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1679, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1680, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:15:08');
INSERT INTO `document_operation_logs` VALUES (1681, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:39:26');
INSERT INTO `document_operation_logs` VALUES (1682, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:39:27');
INSERT INTO `document_operation_logs` VALUES (1683, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:45:21');
INSERT INTO `document_operation_logs` VALUES (1684, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:45:21');
INSERT INTO `document_operation_logs` VALUES (1685, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 16:45:59');
INSERT INTO `document_operation_logs` VALUES (1686, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:45:59');
INSERT INTO `document_operation_logs` VALUES (1687, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 16:48:01');
INSERT INTO `document_operation_logs` VALUES (1688, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:01:06');
INSERT INTO `document_operation_logs` VALUES (1689, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:01:06');
INSERT INTO `document_operation_logs` VALUES (1690, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:03:13');
INSERT INTO `document_operation_logs` VALUES (1691, 31, 3, 'update_permission', '修改用户 4 的权限级别为 3', '2026-01-28 17:05:43');
INSERT INTO `document_operation_logs` VALUES (1692, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:09:32');
INSERT INTO `document_operation_logs` VALUES (1693, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:09:32');
INSERT INTO `document_operation_logs` VALUES (1694, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:12:21');
INSERT INTO `document_operation_logs` VALUES (1695, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:16:04');
INSERT INTO `document_operation_logs` VALUES (1696, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:16:09');
INSERT INTO `document_operation_logs` VALUES (1697, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:16:10');
INSERT INTO `document_operation_logs` VALUES (1698, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:19:30');
INSERT INTO `document_operation_logs` VALUES (1699, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:19:30');
INSERT INTO `document_operation_logs` VALUES (1700, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:21:41');
INSERT INTO `document_operation_logs` VALUES (1701, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:21:42');
INSERT INTO `document_operation_logs` VALUES (1702, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-01-28 17:22:09');
INSERT INTO `document_operation_logs` VALUES (1703, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-01-28 17:22:09');
INSERT INTO `document_operation_logs` VALUES (1704, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-02-27 18:22:37');
INSERT INTO `document_operation_logs` VALUES (1705, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-27 19:19:56');
INSERT INTO `document_operation_logs` VALUES (1706, 35, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:44:21');
INSERT INTO `document_operation_logs` VALUES (1707, 35, 6, 'invite', '邀请用户 3 加入文档', '2026-02-28 14:48:12');
INSERT INTO `document_operation_logs` VALUES (1708, 35, 3, 'accept_invite', '接受邀请', '2026-02-28 14:48:42');
INSERT INTO `document_operation_logs` VALUES (1709, 35, 3, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:50:16');
INSERT INTO `document_operation_logs` VALUES (1710, 35, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:50:40');
INSERT INTO `document_operation_logs` VALUES (1711, 35, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:50:40');
INSERT INTO `document_operation_logs` VALUES (1712, 35, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:50:40');
INSERT INTO `document_operation_logs` VALUES (1713, 35, 3, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:50:41');
INSERT INTO `document_operation_logs` VALUES (1714, 35, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:56:23');
INSERT INTO `document_operation_logs` VALUES (1715, 35, 3, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:56:24');
INSERT INTO `document_operation_logs` VALUES (1716, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:56:52');
INSERT INTO `document_operation_logs` VALUES (1717, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:56:52');
INSERT INTO `document_operation_logs` VALUES (1718, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:56:52');
INSERT INTO `document_operation_logs` VALUES (1719, 35, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:57:06');
INSERT INTO `document_operation_logs` VALUES (1720, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:57:07');
INSERT INTO `document_operation_logs` VALUES (1721, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:57:07');
INSERT INTO `document_operation_logs` VALUES (1722, 36, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:58:13');
INSERT INTO `document_operation_logs` VALUES (1723, 36, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 14:58:15');
INSERT INTO `document_operation_logs` VALUES (1724, 35, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 14:58:44');
INSERT INTO `document_operation_logs` VALUES (1725, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 15:00:23');
INSERT INTO `document_operation_logs` VALUES (1726, 35, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 15:00:23');
INSERT INTO `document_operation_logs` VALUES (1727, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 15:11:32');
INSERT INTO `document_operation_logs` VALUES (1728, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 15:11:32');
INSERT INTO `document_operation_logs` VALUES (1729, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 15:11:32');
INSERT INTO `document_operation_logs` VALUES (1730, 35, 3, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 15:11:42');
INSERT INTO `document_operation_logs` VALUES (1731, 35, 6, 'join_collaboration', '用户加入协同编辑', '2026-02-28 15:22:12');
INSERT INTO `document_operation_logs` VALUES (1732, 35, 6, 'leave_collaboration', '用户离开协同编辑', '2026-02-28 16:03:52');
INSERT INTO `document_operation_logs` VALUES (1733, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-03-02 17:10:22');
INSERT INTO `document_operation_logs` VALUES (1734, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-03-02 17:11:18');
INSERT INTO `document_operation_logs` VALUES (1735, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:38:27');
INSERT INTO `document_operation_logs` VALUES (1736, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:38:27');
INSERT INTO `document_operation_logs` VALUES (1737, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:38:27');
INSERT INTO `document_operation_logs` VALUES (1738, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-03-02 19:38:28');
INSERT INTO `document_operation_logs` VALUES (1739, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:38:28');
INSERT INTO `document_operation_logs` VALUES (1740, 31, 4, 'join_collaboration', '用户加入协同编辑', '2026-03-02 19:38:30');
INSERT INTO `document_operation_logs` VALUES (1741, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-03-02 19:38:33');
INSERT INTO `document_operation_logs` VALUES (1742, 31, 3, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:38:33');
INSERT INTO `document_operation_logs` VALUES (1743, 31, 3, 'join_collaboration', '用户加入协同编辑', '2026-03-02 19:38:34');
INSERT INTO `document_operation_logs` VALUES (1744, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:39:24');
INSERT INTO `document_operation_logs` VALUES (1745, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:39:24');
INSERT INTO `document_operation_logs` VALUES (1746, 31, 4, 'leave_collaboration', '用户离开协同编辑', '2026-03-02 19:39:24');

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
-- Records of document_permissions
-- ----------------------------
INSERT INTO `document_permissions` VALUES (1, 31, 4, 'write', 3, 3, '2026-01-12 19:28:01', 3, '2026-01-11 20:48:31', 'accepted', '2026-01-12 19:28:01', NULL);
INSERT INTO `document_permissions` VALUES (2, 31, 5, 'write', 2, 3, '2026-01-19 17:38:24', 3, '2026-01-19 17:38:10', 'accepted', '2026-01-19 17:38:24', NULL);
INSERT INTO `document_permissions` VALUES (3, 33, 3, 'write', 3, 4, '2026-01-22 17:52:25', 4, '2026-01-22 17:52:13', 'accepted', '2026-01-22 17:52:25', '2026-01-28 17:09:23');
INSERT INTO `document_permissions` VALUES (4, 35, 6, 'write', 3, 6, '2026-02-28 14:44:20', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `document_permissions` VALUES (5, 35, 3, 'write', 2, 6, '2026-02-28 14:48:42', 6, '2026-02-28 14:48:12', 'accepted', '2026-02-28 14:48:42', '2026-02-28 14:50:09');

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
-- Records of document_resources
-- ----------------------------

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
-- Records of document_settings
-- ----------------------------
INSERT INTO `document_settings` VALUES (1, 31, 1, 50, 1, 10, '2026-01-20 15:54:25', '2026-01-20 16:13:12');
INSERT INTO `document_settings` VALUES (2, 35, 1, 50, 1, 5, '2026-02-28 14:47:18', '2026-02-28 14:47:20');

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
-- Records of document_versions
-- ----------------------------
INSERT INTO `document_versions` VALUES (1, 31, 1, 'full', 'snapshots/31/snapshot_1_20260120_161724_31fbb59c.bin', 2169, '测试版本', 3, '2026-01-20 16:17:25');
INSERT INTO `document_versions` VALUES (2, 31, 2, 'full', 'snapshots/31/snapshot_2_20260120_171525_0c7d712c.bin', 2252, '回滚用版本\n', 3, '2026-01-20 17:15:25');
INSERT INTO `document_versions` VALUES (3, 31, 3, 'full', 'snapshots/31/snapshot_3_20260122_202145_b92b70a8.bin', 2295, 'new\n', 3, '2026-01-22 20:21:46');
INSERT INTO `document_versions` VALUES (4, 31, 4, 'full', 'snapshots/31/snapshot_4_20260128_160530_ef5064ef.bin', 2988, 'compare', 3, '2026-01-28 16:05:31');
INSERT INTO `document_versions` VALUES (5, 31, 5, 'full', 'snapshots/31/snapshot_5_20260128_160604_aa82dbae.bin', 3022, 'new comp[are', 3, '2026-01-28 16:06:04');
INSERT INTO `document_versions` VALUES (6, 35, 1, 'full', 'snapshots/35/snapshot_1_20260228_144726_2e6f33bc.bin', 14408, 'version01\n', 6, '2026-02-28 14:47:26');

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
-- Records of documents
-- ----------------------------
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\"}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image1.jpeg\", \"src\": \"/api/documents/28/resources/194ad6f06b6140218ec8f82f70c0cfcd\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image2.png\", \"src\": \"/api/documents/28/resources/b566f97661724f81bf86760cd1f8b659\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image3.jpeg\", \"src\": \"/api/documents/28/resources/111f3d62469f4def8c412298deb0bf3f\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"“下一个，萧媚！”\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"听着测验人的喊声，一名少女快速的人群中跑出，少女刚刚出场，附近的议论声便是小了许多，一双双略微火热的目光，牢牢的锁定着少女的脸颊……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"少女年龄不过十四左右，虽然并算不上绝色，不过那张稚气未脱的小脸，却是蕴含着淡淡的妩媚，清纯与妩媚，矛盾的集合，让得她成功的成为了全场瞩目的焦点……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"少女快步上前，小手轻车熟路的触摸着漆黑的魔石碑，然后缓缓闭上眼睛……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"在少女闭眼片刻之后，漆黑的魔石碑之上再次亮起了光芒……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"“斗之气：七段！”\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"“萧媚，斗之气：七段！级别：高级！”\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"听着人群中传来的一阵阵羡慕声，少女脸颊上的笑容更是多了几分，虚荣心，这是很多女孩都无法抗拒的诱惑……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\"}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image4.jpeg\", \"src\": \"/api/documents/28/resources/51f1b55484fa4bfa9c59aefd1e989b63\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image5.png\", \"src\": \"/api/documents/28/resources/826d80b91807493d912f63b81bce217b\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image6.jpeg\", \"src\": \"/api/documents/28/resources/ed44532a01c5409490b222cfb2ae2436\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image7.jpeg\", \"src\": \"/api/documents/28/resources/728a0b4609634ca0a70ccb7b889cbda7\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": \"image8.jpeg\", \"src\": \"/api/documents/28/resources/6992c30cdc544700b02902d6490a72e7\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"与平日里的几个姐妹互相笑谈着，萧媚的视线，忽然的透过周围的人群，停在了人群外的那一道孤单身影上……\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"content\": [{\"text\": \"皱眉思虑了瞬间，萧媚还是打消了过去的念头，现在的两人，已经不在同一个阶层之上，以萧炎最近几年的表现，成年后，顶多只能作为家族中的下层人员，而天赋优秀的她，则将会成为家族重点培养的强者，前途可以说是不可限量。\", \"type\": \"text\"}]}]}', 28, 'testimg', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/octet-stream', 'documents/8f020dbb-69ff-48de-9094-e3940e83b13b.docx', NULL, '<html>\n <head></head>\n <body>\n  <img src=\"/api/documents/28/resources/194ad6f06b6140218ec8f82f70c0cfcd\" alt=\"image1.jpeg\"><img src=\"/api/documents/28/resources/b566f97661724f81bf86760cd1f8b659\" alt=\"image2.png\"><img src=\"/api/documents/28/resources/111f3d62469f4def8c412298deb0bf3f\" alt=\"image3.jpeg\">\n  <p>“下一个，萧媚！”</p>\n  <p>听着测验人的喊声，一名少女快速的人群中跑出，少女刚刚出场，附近的议论声便是小了许多，一双双略微火热的目光，牢牢的锁定着少女的脸颊……</p>\n  <p>少女年龄不过十四左右，虽然并算不上绝色，不过那张稚气未脱的小脸，却是蕴含着淡淡的妩媚，清纯与妩媚，矛盾的集合，让得她成功的成为了全场瞩目的焦点……</p>\n  <p>少女快步上前，小手轻车熟路的触摸着漆黑的魔石碑，然后缓缓闭上眼睛……</p>\n  <p>在少女闭眼片刻之后，漆黑的魔石碑之上再次亮起了光芒……</p>\n  <p>“斗之气：七段！”</p>\n  <p>“萧媚，斗之气：七段！级别：高级！”</p>\n  <p>听着人群中传来的一阵阵羡慕声，少女脸颊上的笑容更是多了几分，虚荣心，这是很多女孩都无法抗拒的诱惑……</p><img src=\"/api/documents/28/resources/51f1b55484fa4bfa9c59aefd1e989b63\" alt=\"image4.jpeg\"><img src=\"/api/documents/28/resources/826d80b91807493d912f63b81bce217b\" alt=\"image5.png\"><img src=\"/api/documents/28/resources/ed44532a01c5409490b222cfb2ae2436\" alt=\"image6.jpeg\"><img src=\"/api/documents/28/resources/728a0b4609634ca0a70ccb7b889cbda7\" alt=\"image7.jpeg\"><img src=\"/api/documents/28/resources/6992c30cdc544700b02902d6490a72e7\" alt=\"image8.jpeg\">\n  <p>与平日里的几个姐妹互相笑谈着，萧媚的视线，忽然的透过周围的人群，停在了人群外的那一道孤单身影上……</p>\n  <p>皱眉思虑了瞬间，萧媚还是打消了过去的念头，现在的两人，已经不在同一个阶层之上，以萧炎最近几年的表现，成年后，顶多只能作为家族中的下层人员，而天赋优秀的她，则将会成为家族重点培养的强者，前途可以说是不可限量。</p>\n </body>\n</html>', NULL, NULL, 2, NULL, 0, 1, 17, NULL, 0, 0, '<html><body><img src...', 0, '2025-11-29 17:48:51', '2025-11-29 17:48:51', NULL);
INSERT INTO `documents` VALUES (NULL, 29, '杨坤的文档', NULL, 'application/octet-stream', NULL, NULL, NULL, NULL, NULL, 2, 3, 0, 1, 0, '坤坤', 0, 0, NULL, 2, '2025-11-29 18:37:44', '2025-11-29 18:37:44', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"heading\", \"attrs\": {\"level\": 1, \"textAlign\": null}, \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"小丑坤坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}, {\"type\": \"strike\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": \"center\"}, \"content\": [{\"text\": \"大丑坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}, {\"text\": \"坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}, {\"type\": \"superscript\"}]}, {\"text\": \"，\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"codeBlock\", \"attrs\": {\"theme\": \"bordered\", \"language\": \"css\"}}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"hello world\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"gheilwd\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"新增内容\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"测试\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}]}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"小丑坤坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"大丑坤坤，\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"codeBlock\", \"attrs\": {\"theme\": \"dark\", \"language\": \"java\"}, \"content\": [{\"text\": \"hello world\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"gheilwd\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}, {\"text\": \"34他F\", \"type\": \"text\"}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/31/images/20260121_213147_716cee8d.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260121%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260121T133147Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=25bbf7405ac61c9e6057407e2aeedcc46606da7131c4df36ce2fc4702e67fe46\", \"title\": null, \"width\": \"25%\", \"height\": null}}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 4, \"textAlign\": null}, \"content\": [{\"text\": \"新增内容\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"测试\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"#f5222d\", \"fontSize\": null}}]}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 6, \"textAlign\": null}, \"content\": [{\"text\": \"fdkw\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}, {\"type\": \"horizontalRule\"}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"bulletList\", \"content\": [{\"type\": \"listItem\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": \"center\"}, \"content\": [{\"text\": \"thd\", \"type\": \"text\"}]}]}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"会欧拉会io\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}]}, {\"type\": \"codeBlock\", \"attrs\": {\"theme\": \"dark\", \"language\": \"plaintext\"}, \"content\": [{\"text\": \"hell word\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"ackackackackack\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/31/images/20260227_191904_788e9e6a.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260227%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260227T111904Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=520423a8f41290fb7dc193c64995fa501d4f692f921aa5b891478512b543c3c0\", \"title\": null, \"width\": \"11%\", \"height\": null}}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 1, \"textAlign\": null}, \"content\": [{\"text\": \"fegewegrg\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"#fa8c16\", \"fontSize\": \"24px\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"22222\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}]}', 31, 'test02', NULL, 'application/octet-stream', NULL, 'documents/31/yjs-snapshots/1772442725523.bin', NULL, NULL, 4081, 3, 4, 0, 5, 0, 'kk', 0, 0, '4444444', 447, '2026-03-02 17:12:06', '2025-12-30 19:34:07', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\"}]}]}', 32, 'test03', NULL, 'application/octet-stream', NULL, NULL, NULL, NULL, NULL, 3, 4, 2, 1, 0, 'kk', 0, 0, NULL, 5, '2026-01-19 17:40:12', '2026-01-19 17:40:12', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\"}]}]}', 33, 'shared01', NULL, 'application/octet-stream', NULL, NULL, NULL, NULL, NULL, 4, NULL, 0, 1, 0, '', 0, 0, NULL, 2, '2026-01-22 17:52:05', '2026-01-22 17:52:05', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"heading\", \"attrs\": {\"level\": 1, \"textAlign\": null}, \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"小丑坤坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"大丑坤坤，\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"hello world\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"gheilwd\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"新增内容\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"测试\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"underline\"}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}]}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"小丑坤坤\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"大丑坤坤，\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"italic\"}]}]}, {\"type\": \"codeBlock\", \"attrs\": {\"theme\": \"dark\", \"language\": \"plaintext\"}, \"content\": [{\"text\": \"hello world\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"gheilwd\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}, {\"text\": \"34他F\", \"type\": \"text\"}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/31/images/20260121_213147_716cee8d.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260121%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260121T133147Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=25bbf7405ac61c9e6057407e2aeedcc46606da7131c4df36ce2fc4702e67fe46\", \"title\": null, \"width\": \"25%\", \"height\": null}}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"新增内容\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"测试\", \"type\": \"text\"}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"fdkw\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}, {\"type\": \"horizontalRule\"}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"bulletList\", \"content\": [{\"type\": \"listItem\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": \"center\"}, \"content\": [{\"text\": \"thd\", \"type\": \"text\"}]}]}]}]}, {\"type\": \"blockquote\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"会欧拉会io\", \"type\": \"text\", \"marks\": [{\"type\": \"code\"}]}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}]}', 34, 'test00', NULL, 'application/octet-stream', NULL, NULL, NULL, NULL, NULL, 3, NULL, 0, 2, 0, NULL, 0, 0, NULL, 6, '2026-01-22 20:18:24', '2026-01-22 19:43:38', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"                                                                                                        \", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"20pt\"}}]}, {\"text\": \" 2025-2026-1图像处理与模式识别复习资料\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"18px\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": \"center\"}, \"content\": [{\"text\": \"（\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"考试题型与复习题型一致，本复习试题覆盖考试部分试题\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"）\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 1, \"textAlign\": \"center\"}, \"content\": [{\"text\": \"复习试题一\", \"type\": \"text\", \"marks\": [{\"type\": \"bold\"}, {\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"20pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"一、单项选择题\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"1. 一幅灰度图像量化等级为256，其灰度值最大为：   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"  A\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"A. 255  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(255, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   B. 256  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   C. 0  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   D. 128\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"codeBlock\", \"attrs\": {\"theme\": \"dark\", \"language\": \"javascript\"}, \"content\": [{\"text\": \"let num = 255\", \"type\": \"text\"}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"2. 以下哪个不是边缘检测算子？       \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"               B\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   A. Sobel  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"B. Gaussian \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(255, 0, 0)\", \"fontSize\": \"12pt\"}}]}, {\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   C. Canny  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   D. Laplacian\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145410_2168915b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065410Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=980651000501cd8caac9c073b945327e0e582ddd9bd8cd1e1b9e749bccdeed4b\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145413_69f3a2c1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065413Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=a6ae4883e365f5dcaedc5fe91720d186cd075b7d9d0d57af8297059f2b7f04c1\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145414_9ac62fde.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065414Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=125189ab2cee7692eb6a690257bd773ac643bae78ae41e9ad531e506131ad49b\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145414_89a809d5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065414Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d93d5fcfcbecabfec0e91cadf8fbc1b13748c669227142864961eb7a77eab780\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145414_4c29ff26.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065414Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=f7038acb5307c300e143ea3f45102e0e57a249035b440f028994a8e3c3813c7b\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145414_f7401f08.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065414Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=5ca0d894f240973763e4454165083e5cb17a64f832a81acce730f112505903c8\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145414_8009c512.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065415Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=9712a3d4cdb52d7b176308382b9523de1d27a81d0867e5db5d63554e85e2b2b2\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145415_337282ce.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065415Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=ec7b80e93b772f457cf1980889d4f3bea1d6370b79e559fa9a160fdb01bcc484\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145415_9e1ffee6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065415Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=16187a7cefdeecd190ab801a7ac158f6256c560f639c570574c7e33f6c303d6f\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145415_a6a1e9de.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065415Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=95ba8fbbf1b6f2d82f0f6cd035b7431108117c2ecc6bf535012b4a81464657be\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145415_d7fdcf8c.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065415Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=349fca1c7592738b80cc8e3339e8975d720f0ba11191327c2cd009b83681e468\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145416_eaf13864.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065416Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=d74998e0c765bd6fdb39d9d9da729c9a7f5eafc2fc374c292714e88527b1e245\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145416_85b08de2.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065416Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=23bd34b0c53967e45df6eccf5bf7c07ead26e88e33a3c1b7412fdc55d89c8fab\", \"title\": null, \"width\": null, \"height\": null}}, {\"type\": \"image\", \"attrs\": {\"alt\": null, \"src\": \"http://localhost:9000/light-doc-bucket/documents/35/images/20260228_145416_1addc888.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=admin%2F20260228%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260228T065416Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=c7a50b624552ecc9bfcb5e1d8b2ed59e3b6bcf3a3534910c6209da875c791bbb\", \"title\": null, \"width\": null, \"height\": null}}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"3. SIFT特征描述子具有哪种特性？                    \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"B\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   A. 对尺度变化不敏感  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"B. 对旋转不变  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(255, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   C. 仅适用于彩色图像  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   D. 对光照变化敏感\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"4. 用于图像平滑的滤波器中，哪种对椒盐噪声效果最好？  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \" C\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   A. 均值滤波  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   B. 高斯滤波  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"C. 中值滤波  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(255, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   D. Sobel滤波\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"5. 下列哪种算法常用于图像二值化时自动确定阈值？      \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \" B\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   A. 均值法  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"B. OTSU算法  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(255, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   C. 高斯法  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"   D. 手动设置\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"二、填空题\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"1. 图像可分为__\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"数字图像_\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}, {\"text\": \"___和模拟图像两大类。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"2. 图像的基本位置变换包括平移、__\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"缩放\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}, {\"text\": \"____和旋转。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"3. 图像数字化过程包括三个步骤：采样、__\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"编码\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}, {\"text\": \"____和量化。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"4. 在OpenCV中，将BGR图像转换为灰度图的函数是__ \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)`____。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"5. 霍夫变换常用于检测图像中的__\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}, {\"text\": \"直线（或圆、形状）\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}, {\"text\": \"____。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"heading\", \"attrs\": {\"level\": 2, \"textAlign\": null}, \"content\": [{\"text\": \"三、简答题\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"1. 简述图像平滑的目的，并比较均值滤波和中值滤波的适用场景。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"目的：去噪保核心信息。适用场景：均值滤波用于高斯噪声、对细节要求低；中值滤波用于椒盐噪声、需保边缘。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"2. \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": null}}]}, {\"text\": \"解释“梯度”在边缘检测中的意义，并说明Sobel算子的工作原理。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"梯度意义：反映灰度突变程度，助力定位边缘。Sobel 原理：双卷积核算 x/y 梯度，幅值超阈值为边缘。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"3. \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": null}}]}, {\"text\": \"简述文字识别的基本流程。  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"流程：采集→预处理→分割→特征提取→分类识别→后处理。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"4. \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": null}}]}, {\"text\": \"为什么中值滤波适合去除椒盐噪声？  \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"原因：椒盐噪声孤立，邻域中值不含噪声，且保边缘。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \" \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"5. \", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": null}}]}, {\"text\": \"简述人脸识别的基本步骤。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": null, \"fontSize\": \"12pt\"}}]}]}, {\"type\": \"paragraph\", \"attrs\": {\"textAlign\": null}, \"content\": [{\"text\": \"步骤：采集→预处理→特征提取→特征匹配→决策。\", \"type\": \"text\", \"marks\": [{\"type\": \"textStyle\", \"attrs\": {\"color\": \"rgb(238, 0, 0)\", \"fontSize\": \"12pt\"}}]}]}]}', 35, 'doc01', NULL, 'application/octet-stream', NULL, 'documents/35/yjs-snapshots/1772262196011.bin', NULL, NULL, 19964, 6, 5, 0, 1, 0, 'java', 0, 0, NULL, 8, '2026-02-28 15:03:16', '2026-02-28 14:44:20', NULL);
INSERT INTO `documents` VALUES ('{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"content\": [{\"text\": \"yangkun is a joker.\", \"type\": \"text\"}]}]}', 36, 'del01', NULL, 'application/octet-stream', NULL, NULL, NULL, NULL, NULL, 6, 5, 2, 1, 0, '', 0, 0, NULL, 1, '2026-02-28 14:58:13', '2026-02-28 14:58:13', NULL);

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
-- Records of knowledge_base_permissions
-- ----------------------------
INSERT INTO `knowledge_base_permissions` VALUES (1, 2, 2, 'manage', 3, 2, '2025-11-28 17:05:11');
INSERT INTO `knowledge_base_permissions` VALUES (2, 3, 2, 'manage', 3, 2, '2025-11-29 18:37:22');
INSERT INTO `knowledge_base_permissions` VALUES (3, 4, 3, 'manage', 3, 3, '2025-12-29 09:12:39');
INSERT INTO `knowledge_base_permissions` VALUES (4, 5, 6, 'manage', 3, 6, '2026-02-28 14:43:50');

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
-- Records of knowledge_bases
-- ----------------------------
INSERT INTO `knowledge_bases` VALUES (2, '杨坤的库1', '小丑坤坤', 2, NULL, 0, 0, 0, 0, NULL, NULL);
INSERT INTO `knowledge_bases` VALUES (3, '杨坤的库2', 'ggg', 2, NULL, 0, 0, 0, 0, NULL, NULL);
INSERT INTO `knowledge_bases` VALUES (4, 'ack01', '', 3, NULL, 0, 0, 0, 0, NULL, NULL);
INSERT INTO `knowledge_bases` VALUES (5, 'baseo1', '...', 6, NULL, 0, 0, 0, 0, NULL, NULL);

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
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1, 3, 4, 'system_notice', '测试', '测试内容', 'system', NULL, 1, NULL, '2026-01-11 19:41:25', 0);
INSERT INTO `notifications` VALUES (2, 4, 3, 'system_notice', '测试1', 'ssss', 'system', NULL, 0, NULL, '2026-01-11 19:41:26', 0);
INSERT INTO `notifications` VALUES (3, 4, NULL, 'doc_invite', '文档邀请', 'null 邀请您加入文档《test02》', 'document', 31, 1, NULL, '2026-01-11 20:50:30', 0);
INSERT INTO `notifications` VALUES (4, 4, 3, 'doc_invite', '文档邀请', 'null 邀请您加入文档《test02》', 'document', 31, 1, NULL, '2026-01-12 19:28:00', 0);
INSERT INTO `notifications` VALUES (5, 5, 3, 'doc_invite', '文档邀请', 'null 邀请您加入文档《test02》', 'document', 31, 1, NULL, '2026-01-19 17:38:24', 0);
INSERT INTO `notifications` VALUES (6, 3, 4, 'doc_invite', '文档邀请', 'null 邀请您加入文档《shared01》', 'document', 33, 1, NULL, '2026-01-22 17:52:25', 0);
INSERT INTO `notifications` VALUES (7, 3, 6, 'system_notice', '通知', '测试信息', 'system', NULL, 0, NULL, NULL, 0);
INSERT INTO `notifications` VALUES (8, 3, 6, 'doc_invite', '文档邀请', 'null 邀请您加入文档《doc01》', 'document', 35, 1, NULL, '2026-02-28 14:48:42', 0);

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

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', 'admin@example.com', '$2a$10$8K1p/aWqk5pZ4mKiF1x1TOZ.yw8N6p7u27h/Q9d4F7m0vZzQpZ5ZK', '管理员', 1, 'admin', '2025-11-28 15:45:51', '2025-11-28 15:45:51', NULL);
INSERT INTO `users` VALUES (2, '杨坤鲲', '2312892148@qq.com', '$2a$10$XAb/rZZs4r5pKm5zwpWUN.CSKG1p.zNPxj0xM2al8ILay86YGkQPq', NULL, 1, 'user', NULL, NULL, NULL);
INSERT INTO `users` VALUES (3, 'ack', 'a19970573204@163.com', '$2a$10$2UcngXJ0nMWLk6UYaKn8MOOwEr8zcfz7D8dBRFxepnWPXhTvimv6.', NULL, 1, 'user', NULL, NULL, NULL);
INSERT INTO `users` VALUES (4, 'fin', 'user@lightdoc.com', '$2a$10$wmH5SVNu0LMkXexOZUTqGOmvKRA0Tf0tzgTMc81s4ilq/4QW8EIJO', NULL, 1, 'user', NULL, NULL, NULL);
INSERT INTO `users` VALUES (5, 'reader', 'abc@123.com', '$2a$10$8xgy0XZYiUKpQBqpDhu.tu2X46TtrEzBR7n8ZNmlQgCNbq.tBMoJW', NULL, 1, 'user', NULL, NULL, NULL);
INSERT INTO `users` VALUES (6, 'usr', 'abcd@123.com', '$2a$10$cnQ9qjQDJHWJbEvsKTR5iOjKbD0SYeVgzyKsOsqjaZTleilUkQ83.', NULL, 1, 'user', NULL, NULL, NULL);

SET FOREIGN_KEY_CHECKS = 1;
