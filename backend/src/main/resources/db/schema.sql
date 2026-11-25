-- =============================================================
--  日迹 Diary Platform 建表脚本
--  数据库：MySQL 8.0+
--  用法：mysql -u root -p < schema.sql
--  说明：包含 RBAC 5 张表 + 业务 6 张表 + 审计 2 张表，共 13 张
-- =============================================================

CREATE DATABASE IF NOT EXISTS `diary_platform`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE `diary_platform`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 1. sys_user  用户表
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`
(
    `id`                 BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`           VARCHAR(50)  NOT NULL COMMENT '登录名，唯一',
    `email`              VARCHAR(100) DEFAULT NULL COMMENT '邮箱，唯一（可为空）',
    `password_hash`      VARCHAR(100) NOT NULL COMMENT 'BCrypt 加盐哈希，禁止明文',
    `nickname`           VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
    `avatar_url`         VARCHAR(255) DEFAULT NULL COMMENT '头像地址',
    `status`             TINYINT      NOT NULL DEFAULT 1 COMMENT '账号状态：1 正常，0 禁用',
    `failed_login_count` INT          NOT NULL DEFAULT 0 COMMENT '连续登录失败次数',
    `locked_until`       DATETIME     DEFAULT NULL COMMENT '锁定截止时间，NULL 表示未锁定',
    `token_version`      INT          NOT NULL DEFAULT 0 COMMENT '令牌版本号，改密/禁用时自增使旧 Token 失效',
    `last_login_at`      DATETIME     DEFAULT NULL COMMENT '最近登录时间',
    `created_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`            TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0 未删除，1 已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_username` (`username`),
    UNIQUE KEY `uk_user_email` (`email`),
    KEY `idx_user_status` (`status`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户表';

-- -------------------------------------------------------------
-- 2. sys_role  角色表
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`
(
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `code`        VARCHAR(50) NOT NULL COMMENT '角色编码：USER/REVIEWER/OPERATOR/ADMIN',
    `name`        VARCHAR(50) NOT NULL COMMENT '角色名称',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '角色说明',
    `built_in`    TINYINT     NOT NULL DEFAULT 0 COMMENT '是否内置角色：1 内置（禁止删除），0 自定义',
    `sort`        INT         NOT NULL DEFAULT 0 COMMENT '排序',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_code` (`code`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='角色表';

-- -------------------------------------------------------------
-- 3. sys_permission  权限表（细化到接口/操作级）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`
(
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `code`        VARCHAR(80) NOT NULL COMMENT '权限码，如 diary:audit',
    `name`        VARCHAR(80) NOT NULL COMMENT '权限名称',
    `module`      VARCHAR(50) NOT NULL COMMENT '所属模块：diary/user/role/report/tag/announcement/ai/stats',
    `description` VARCHAR(255) DEFAULT NULL,
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_permission_code` (`code`),
    KEY `idx_permission_module` (`module`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='权限表';

-- -------------------------------------------------------------
-- 4. sys_user_role  用户-角色（多对多，支持一人多角色）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`
(
    `id`         BIGINT   NOT NULL AUTO_INCREMENT,
    `user_id`    BIGINT   NOT NULL COMMENT '用户 ID',
    `role_id`    BIGINT   NOT NULL COMMENT '角色 ID',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
    KEY `idx_ur_role` (`role_id`),
    CONSTRAINT `fk_ur_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ur_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户角色关联表';

-- -------------------------------------------------------------
-- 5. sys_role_permission  角色-权限（多对多）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`
(
    `id`            BIGINT   NOT NULL AUTO_INCREMENT,
    `role_id`       BIGINT   NOT NULL COMMENT '角色 ID',
    `permission_id` BIGINT   NOT NULL COMMENT '权限 ID',
    `created_at`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_role_permission` (`role_id`, `permission_id`),
    KEY `idx_rp_permission` (`permission_id`),
    CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_rp_permission` FOREIGN KEY (`permission_id`) REFERENCES `sys_permission` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='角色权限关联表';

-- -------------------------------------------------------------
-- 6. tag  标签表
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`
(
    `id`         BIGINT      NOT NULL AUTO_INCREMENT,
    `name`       VARCHAR(30) NOT NULL COMMENT '标签名',
    `color`      VARCHAR(20)  DEFAULT NULL COMMENT '展示色值',
    `created_by` BIGINT       DEFAULT NULL COMMENT '创建人（运营）',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`    TINYINT     NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_tag_name` (`name`),
    KEY `idx_tag_created_by` (`created_by`),
    CONSTRAINT `fk_tag_creator` FOREIGN KEY (`created_by`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='标签表';

-- -------------------------------------------------------------
-- 7. diary  日记表（核心业务实体）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `diary`;
CREATE TABLE `diary`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT,
    `author_id`    BIGINT       NOT NULL COMMENT '作者 ID，与用户一对多',
    `title`        VARCHAR(100) NOT NULL COMMENT '标题',
    `content`      TEXT         NOT NULL COMMENT '正文',
    `summary`      VARCHAR(500)  DEFAULT NULL COMMENT 'AI 生成的摘要',
    `mood`         VARCHAR(20)   DEFAULT NULL COMMENT 'AI 情绪标签：HAPPY/SAD/ANXIOUS/CALM/ANGRY',
    `visibility`   TINYINT      NOT NULL DEFAULT 0 COMMENT '可见性：0 私密，1 公开',
    `status`       VARCHAR(20)  NOT NULL DEFAULT 'DRAFT' COMMENT '状态：DRAFT/PENDING/PUBLISHED/REJECTED/TAKEN_DOWN/PRIVATE',
    `diary_date`   DATE         NOT NULL COMMENT '日记归属日期，支持补写',
    `word_count`   INT          NOT NULL DEFAULT 0 COMMENT '字数',
    `published_at` DATETIME      DEFAULT NULL COMMENT '公开时间',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`      TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_diary_author` (`author_id`),
    KEY `idx_diary_status_created` (`status`, `created_at`),
    KEY `idx_diary_date` (`diary_date`),
    KEY `idx_diary_visibility_status` (`visibility`, `status`),
    CONSTRAINT `fk_diary_author` FOREIGN KEY (`author_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='日记表';

-- -------------------------------------------------------------
-- 8. diary_tag  日记-标签（多对多）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `diary_tag`;
CREATE TABLE `diary_tag`
(
    `id`         BIGINT   NOT NULL AUTO_INCREMENT,
    `diary_id`   BIGINT   NOT NULL,
    `tag_id`     BIGINT   NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_diary_tag` (`diary_id`, `tag_id`),
    KEY `idx_dt_tag` (`tag_id`),
    CONSTRAINT `fk_dt_diary` FOREIGN KEY (`diary_id`) REFERENCES `diary` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_dt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='日记标签关联表';

-- -------------------------------------------------------------
-- 9. diary_audit_record  审核流水（状态流转留痕）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `diary_audit_record`;
CREATE TABLE `diary_audit_record`
(
    `id`            BIGINT      NOT NULL AUTO_INCREMENT,
    `diary_id`      BIGINT      NOT NULL,
    `from_status`   VARCHAR(20) NOT NULL COMMENT '变更前状态',
    `to_status`     VARCHAR(20) NOT NULL COMMENT '变更后状态',
    `action`        VARCHAR(20) NOT NULL COMMENT '动作：submit/approve/reject/withdraw/resubmit/takedown/unpublish',
    `operator_id`   BIGINT      NOT NULL COMMENT '操作人',
    `operator_role` VARCHAR(50) NOT NULL COMMENT '操作人角色快照',
    `remark`        VARCHAR(500) DEFAULT NULL COMMENT '审核意见 / 驳回理由',
    `created_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_audit_diary` (`diary_id`, `created_at`),
    KEY `idx_audit_operator` (`operator_id`),
    CONSTRAINT `fk_audit_diary` FOREIGN KEY (`diary_id`) REFERENCES `diary` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_audit_operator` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='日记审核流水表';

-- -------------------------------------------------------------
-- 10. report  举报表（第二条状态流转）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `report`;
CREATE TABLE `report`
(
    `id`            BIGINT       NOT NULL AUTO_INCREMENT,
    `diary_id`      BIGINT       NOT NULL COMMENT '被举报日记',
    `reporter_id`   BIGINT       NOT NULL COMMENT '举报人',
    `reason`        VARCHAR(200) NOT NULL COMMENT '举报理由',
    `status`        VARCHAR(20)  NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING/ACCEPTED/REJECTED',
    `handled_by`    BIGINT        DEFAULT NULL COMMENT '处理人（审核员）',
    `handle_remark` VARCHAR(500)  DEFAULT NULL COMMENT '处理说明',
    `handled_at`    DATETIME      DEFAULT NULL COMMENT '处理时间',
    `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_report_diary_reporter` (`diary_id`, `reporter_id`),
    KEY `idx_report_status` (`status`, `created_at`),
    KEY `idx_report_reporter` (`reporter_id`),
    KEY `idx_report_handler` (`handled_by`),
    CONSTRAINT `fk_report_diary` FOREIGN KEY (`diary_id`) REFERENCES `diary` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_report_reporter` FOREIGN KEY (`reporter_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_report_handler` FOREIGN KEY (`handled_by`) REFERENCES `sys_user` (`id`) ON DELETE SET NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='举报表';

-- -------------------------------------------------------------
-- 11. announcement  公告表
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`
(
    `id`         BIGINT       NOT NULL AUTO_INCREMENT,
    `title`      VARCHAR(100) NOT NULL,
    `content`    TEXT         NOT NULL,
    `publisher_id` BIGINT     NOT NULL COMMENT '发布人（运营）',
    `status`     TINYINT      NOT NULL DEFAULT 1 COMMENT '1 已发布，0 下线',
    `pinned`     TINYINT      NOT NULL DEFAULT 0 COMMENT '是否置顶',
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted`    TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `idx_ann_status_pinned` (`status`, `pinned`, `created_at`),
    CONSTRAINT `fk_ann_publisher` FOREIGN KEY (`publisher_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='公告表';

-- -------------------------------------------------------------
-- 12. ai_call_log  AI 调用审计表
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `ai_call_log`;
CREATE TABLE `ai_call_log`
(
    `id`             BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`        BIGINT       NOT NULL COMMENT '调用用户',
    `diary_id`       BIGINT        DEFAULT NULL COMMENT '关联日记（可为空）',
    `scene`          VARCHAR(30)  NOT NULL COMMENT '场景：SUMMARY/TAG_SUGGEST/MOOD_REPORT/NL_SEARCH',
    `provider`       VARCHAR(30)  NOT NULL COMMENT '模型提供方：deepseek/qwen/zhipu',
    `model`          VARCHAR(50)  NOT NULL,
    `prompt_tokens`  INT          NOT NULL DEFAULT 0,
    `output_tokens`  INT          NOT NULL DEFAULT 0,
    `cost_ms`        INT          NOT NULL DEFAULT 0,
    `success`        TINYINT      NOT NULL DEFAULT 1,
    `error_message`  VARCHAR(500)  DEFAULT NULL,
    `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_ai_user_created` (`user_id`, `created_at`),
    KEY `idx_ai_diary` (`diary_id`),
    CONSTRAINT `fk_ai_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ai_diary` FOREIGN KEY (`diary_id`) REFERENCES `diary` (`id`) ON DELETE SET NULL
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='AI 调用审计表';

-- -------------------------------------------------------------
-- 13. sys_operation_log  操作审计表（安全增强项）
-- -------------------------------------------------------------
DROP TABLE IF EXISTS `sys_operation_log`;
CREATE TABLE `sys_operation_log`
(
    `id`          BIGINT       NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT        DEFAULT NULL COMMENT '操作人，未登录为 NULL',
    `username`    VARCHAR(50)   DEFAULT NULL COMMENT '操作人快照',
    `module`      VARCHAR(50)  NOT NULL COMMENT '模块',
    `action`      VARCHAR(100) NOT NULL COMMENT '操作描述',
    `method`      VARCHAR(10)  NOT NULL COMMENT 'HTTP 方法',
    `uri`         VARCHAR(255) NOT NULL COMMENT '请求路径',
    `ip`          VARCHAR(64)   DEFAULT NULL,
    `success`     TINYINT      NOT NULL DEFAULT 1,
    `cost_ms`     INT          NOT NULL DEFAULT 0,
    `detail`      VARCHAR(1000) DEFAULT NULL COMMENT '关键参数摘要，禁止记录密码',
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_oplog_user_created` (`user_id`, `created_at`),
    KEY `idx_oplog_module` (`module`, `created_at`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='操作审计日志表';

SET FOREIGN_KEY_CHECKS = 1;
