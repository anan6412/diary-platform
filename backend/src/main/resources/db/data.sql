-- =============================================================
--  日迹 Diary Platform 种子数据脚本
--  依赖：先执行 schema.sql
--  用法：mysql -u root -p diary_platform < data.sql
--
--  演示账号（明文密码，供 README 与答辩使用）：
--    admin    / Admin@123      超级管理员
--    reviewer / Review@123     内容审核员
--    operator / Operator@123   运营
--    alice    / User@123       普通用户
--    bob      / User@123       普通用户
--  所有密码均为 BCrypt(rounds=10) 哈希存储，禁止明文。
-- =============================================================

USE `diary_platform`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------
-- 角色
-- -------------------------------------------------------------
INSERT INTO `sys_role` (`id`, `code`, `name`, `description`, `built_in`, `sort`)
VALUES (1, 'USER', '普通用户', '记录日记、管理自己的内容、申请公开、举报违规', 1, 10),
       (2, 'REVIEWER', '内容审核员', '审核公开申请、处理举报、下架违规内容', 1, 20),
       (3, 'OPERATOR', '运营', '维护标签库、发布公告、查看平台数据看板', 1, 30),
       (4, 'ADMIN', '超级管理员', '用户管理、角色权限管理、系统配置、全量数据', 1, 40);

-- -------------------------------------------------------------
-- 权限（细化到接口/操作级，共 22 个）
-- -------------------------------------------------------------
INSERT INTO `sys_permission` (`code`, `name`, `module`, `description`)
VALUES ('diary:create', '创建日记', 'diary', '新建自己的日记'),
       ('diary:read:own', '查看自己的日记', 'diary', '读取本人日记，含私密内容'),
       ('diary:update:own', '修改自己的日记', 'diary', '仅限本人，需归属校验'),
       ('diary:delete:own', '删除自己的日记', 'diary', '仅限本人，需归属校验'),
       ('diary:read:public', '查看公开日记', 'diary', '浏览社区公开流'),
       ('diary:submit', '提交/撤回审核', 'diary', '把自己的日记送入或撤出审核队列'),
       ('diary:audit', '审核日记', 'diary', '通过或驳回公开申请'),
       ('diary:takedown', '下架日记', 'diary', '把已发布内容强制下架'),
       ('diary:read:all', '查看全部日记', 'diary', '跨用户读取，含待审队列'),
       ('tag:manage', '管理标签', 'tag', '标签库增删改'),
       ('report:create', '提交举报', 'report', '举报他人公开日记'),
       ('report:handle', '处理举报', 'report', '判定举报成立或驳回'),
       ('announcement:read', '查看公告', 'announcement', '读取平台公告'),
       ('announcement:manage', '管理公告', 'announcement', '发布、修改、下线公告'),
       ('stats:view', '查看运营数据', 'stats', '平台概览与趋势统计'),
       ('ai:summary', '使用 AI 能力', 'ai', '摘要、情绪分析、标签推荐、自然语言搜索'),
       ('user:list', '查看用户列表', 'user', '分页查询用户'),
       ('user:manage', '管理用户', 'user', '新增、修改、禁用/启用、分配角色'),
       ('role:manage', '管理角色', 'role', '角色增删改、分配权限'),
       ('permission:list', '查看权限列表', 'role', '读取全部权限码'),
       ('audit:log:view', '查看审计日志', 'system', '读取操作审计记录'),
       ('system:config', '系统配置', 'system', '平台级参数配置');

-- -------------------------------------------------------------
-- 角色 × 权限
-- -------------------------------------------------------------
-- USER：只在自己的数据范围内工作
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `sys_role` r,
     `sys_permission` p
WHERE r.code = 'USER'
  AND p.code IN ('diary:create', 'diary:read:own', 'diary:update:own', 'diary:delete:own',
                 'diary:read:public', 'diary:submit', 'report:create', 'announcement:read', 'ai:summary');

-- REVIEWER：USER 的全部权限 + 审核与举报处理
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `sys_role` r,
     `sys_permission` p
WHERE r.code = 'REVIEWER'
  AND p.code IN ('diary:create', 'diary:read:own', 'diary:update:own', 'diary:delete:own',
                 'diary:read:public', 'diary:submit', 'report:create', 'announcement:read', 'ai:summary',
                 'diary:audit', 'diary:takedown', 'diary:read:all', 'report:handle');

-- OPERATOR：USER 的全部权限 + 标签、公告、数据看板
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `sys_role` r,
     `sys_permission` p
WHERE r.code = 'OPERATOR'
  AND p.code IN ('diary:create', 'diary:read:own', 'diary:update:own', 'diary:delete:own',
                 'diary:read:public', 'diary:submit', 'report:create', 'announcement:read', 'ai:summary',
                 'tag:manage', 'announcement:manage', 'stats:view', 'diary:read:all');

-- ADMIN：全部权限
INSERT INTO `sys_role_permission` (`role_id`, `permission_id`)
SELECT r.id, p.id
FROM `sys_role` r,
     `sys_permission` p
WHERE r.code = 'ADMIN';

-- -------------------------------------------------------------
-- 用户（密码统一 BCrypt 加盐哈希）
-- -------------------------------------------------------------
INSERT INTO `sys_user` (`id`, `username`, `email`, `password_hash`, `nickname`, `status`, `token_version`)
VALUES (1, 'admin', 'admin@daytrace.local',
        '$2b$10$i7gsMQoRpiPTNz86YNqOx.oWCKVWRYDWY2BuOFNadLZtHDbTuqpQa', '系统管理员', 1, 0),
       (2, 'reviewer', 'reviewer@daytrace.local',
        '$2b$10$vcdSHtAcdkUTt63FiKzm3OBYIp7280e4eaveJ739KLAnC49jyo8le', '审核小周', 1, 0),
       (3, 'operator', 'operator@daytrace.local',
        '$2b$10$GsKQJtJcJxBAKeC1eDG3Ye6ScCWQLVDjeT6ybqoAbSuT6nKLqBOXO', '运营小陈', 1, 0),
       (4, 'alice', 'alice@daytrace.local',
        '$2b$10$iLtr07QybJtfAvEnMmUnCegYQD4fbEha9mWedup.bLGKlkBKu7JS.', '爱丽丝', 1, 0),
       (5, 'bob', 'bob@daytrace.local',
        '$2b$10$iLtr07QybJtfAvEnMmUnCegYQD4fbEha9mWedup.bLGKlkBKu7JS.', '鲍勃', 1, 0),
       (6, 'carol', 'carol@daytrace.local',
        '$2b$10$iLtr07QybJtfAvEnMmUnCegYQD4fbEha9mWedup.bLGKlkBKu7JS.', '卡罗尔', 0, 0);

-- 用户 × 角色（carol 用于演示「禁用账号」与「无角色」场景）
INSERT INTO `sys_user_role` (`user_id`, `role_id`)
VALUES (1, 4),
       (2, 2),
       (3, 3),
       (4, 1),
       (5, 1),
       (6, 1);

-- -------------------------------------------------------------
-- 标签
-- -------------------------------------------------------------
INSERT INTO `tag` (`id`, `name`, `color`, `created_by`)
VALUES (1, '日常', '#378ADD', 3),
       (2, '工作', '#534AB7', 3),
       (3, '读书', '#1D9E75', 3),
       (4, '旅行', '#D85A30', 3),
       (5, '情绪', '#D4537E', 3),
       (6, '美食', '#BA7517', 3);

-- -------------------------------------------------------------
-- 日记（覆盖全部状态，便于演示与测试）
-- -------------------------------------------------------------
INSERT INTO `diary` (`id`, `author_id`, `title`, `content`, `summary`, `mood`, `visibility`, `status`,
                     `diary_date`, `word_count`, `published_at`, `created_at`)
VALUES (1, 4, '立冬后的第一个早晨', '早上六点半醒来，窗外有雾。煮了一壶茶，坐在阳台上看远处的楼群一点点从雾里浮出来。今天决定把想了很久的日记本搬到线上。', NULL, 'CALM', 0, 'DRAFT',
        DATE_SUB(CURDATE(), INTERVAL 1 DAY), 78, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
       (2, 4, '关于坚持这件事', '坚持跑步第 30 天。最难的不是跑，是穿鞋的那一刻。今天下雨，还是去了。', NULL, 'HAPPY', 1, 'PENDING',
        DATE_SUB(CURDATE(), INTERVAL 2 DAY), 45, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
       (3, 4, '读《被讨厌的勇气》', '课题分离这个概念，第一次读觉得冷漠，再读觉得是解脱。别人怎么看我，是别人的课题。', '记录阅读《被讨厌的勇气》的感悟，重点在"课题分离"带来的心态转变：从觉得冷漠到感到解脱。', 'CALM', 1, 'PUBLISHED',
        DATE_SUB(CURDATE(), INTERVAL 4 DAY), 62, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
       (4, 4, '加班到十一点', '项目上线前的最后一个晚上。所有人都在，会议室灯一直亮着。有点累，但也踏实。', NULL, 'ANXIOUS', 1, 'PUBLISHED',
        DATE_SUB(CURDATE(), INTERVAL 6 DAY), 41, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
       (5, 4, '一篇被驳回的日记', '随手写了几句抱怨，可能措辞有点冲。提交公开的时候被驳回了，理由是不适合公开展示。', NULL, 'ANGRY', 1, 'REJECTED',
        DATE_SUB(CURDATE(), INTERVAL 7 DAY), 38, NULL, DATE_SUB(NOW(), INTERVAL 7 DAY)),
       (6, 5, '周末去山里', '开车两小时到山脚下，爬到半山腰突然起雾。看不清路，但闻得到松树的味道。', '周末登山遇雾的经历，重点描写雾中松树气味的感官记忆。', 'HAPPY', 1, 'PUBLISHED',
        DATE_SUB(CURDATE(), INTERVAL 3 DAY), 55, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
       (7, 5, '做饭这件事', '第一次做红烧肉没有炒糖色，颜色发白。但味道居然还行。', NULL, 'CALM', 1, 'PUBLISHED',
        DATE_SUB(CURDATE(), INTERVAL 8 DAY), 28, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY)),
       (8, 5, '待审核的草稿', '写了点关于换工作的想法，还在犹豫要不要公开。', NULL, 'ANXIOUS', 1, 'PENDING',
        DATE_SUB(CURDATE(), INTERVAL 1 DAY), 32, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
       (9, 6, '养猫的第三年', '它今天第一次主动跳到我腿上睡觉。等了三年。', NULL, 'HAPPY', 1, 'PUBLISHED',
        DATE_SUB(CURDATE(), INTERVAL 5 DAY), 24, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY)),
       (10, 4, '被下架的一篇', '内容涉及具体公司名称，被认为有风险，已下架。', NULL, 'CALM', 1, 'TAKEN_DOWN',
        DATE_SUB(CURDATE(), INTERVAL 10 DAY), 30, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY));

-- 日记 × 标签
INSERT INTO `diary_tag` (`diary_id`, `tag_id`)
VALUES (1, 1),
       (2, 1),
       (3, 3),
       (3, 5),
       (4, 2),
       (5, 5),
       (6, 4),
       (7, 6),
       (8, 2),
       (9, 1),
       (10, 2);

-- -------------------------------------------------------------
-- 审核流水（对应上面的状态，让审核记录有历史可看）
-- -------------------------------------------------------------
INSERT INTO `diary_audit_record` (`diary_id`, `from_status`, `to_status`, `action`, `operator_id`, `operator_role`, `remark`, `created_at`)
VALUES (2, 'DRAFT', 'PENDING', 'submit', 4, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 2 DAY)),
       (3, 'DRAFT', 'PENDING', 'submit', 4, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 4 DAY)),
       (3, 'PENDING', 'PUBLISHED', 'approve', 2, 'REVIEWER', '内容健康，通过', DATE_SUB(NOW(), INTERVAL 3 DAY)),
       (4, 'DRAFT', 'PENDING', 'submit', 4, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 6 DAY)),
       (4, 'PENDING', 'PUBLISHED', 'approve', 2, 'REVIEWER', '通过', DATE_SUB(NOW(), INTERVAL 5 DAY)),
       (5, 'DRAFT', 'PENDING', 'submit', 4, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 7 DAY)),
       (5, 'PENDING', 'REJECTED', 'reject', 2, 'REVIEWER', '措辞不当，不适合公开展示', DATE_SUB(NOW(), INTERVAL 7 DAY)),
       (6, 'DRAFT', 'PENDING', 'submit', 5, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 3 DAY)),
       (6, 'PENDING', 'PUBLISHED', 'approve', 2, 'REVIEWER', '通过', DATE_SUB(NOW(), INTERVAL 2 DAY)),
       (8, 'DRAFT', 'PENDING', 'submit', 5, 'USER', '提交公开申请', DATE_SUB(NOW(), INTERVAL 1 DAY)),
       (10, 'PUBLISHED', 'TAKEN_DOWN', 'takedown', 2, 'REVIEWER', '涉及具体公司信息，存在风险', DATE_SUB(NOW(), INTERVAL 9 DAY));

-- -------------------------------------------------------------
-- 举报（第二条状态流转：待处理 / 成立 / 驳回）
-- -------------------------------------------------------------
INSERT INTO `report` (`diary_id`, `reporter_id`, `reason`, `status`, `handled_by`, `handle_remark`, `handled_at`, `created_at`)
VALUES (6, 4, '这篇内容疑似广告', 'PENDING', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
       (7, 4, '内容与标签不符', 'REJECTED', 2, '核实后内容正常，举报不成立', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
       (9, 5, '含有不实信息', 'ACCEPTED', 2, '举报成立，已通知作者修改', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY));

-- -------------------------------------------------------------
-- 公告
-- -------------------------------------------------------------
INSERT INTO `announcement` (`title`, `content`, `publisher_id`, `status`, `pinned`, `created_at`)
VALUES ('欢迎来到日迹', '日迹是一个安静的日记本。你的私密日记只有你能看到，公开内容会经过审核后进入社区。', 3, 1, 1, DATE_SUB(NOW(), INTERVAL 10 DAY)),
       ('关于公开内容的规范', '请勿在公开日记中包含他人隐私、具体公司信息与联系方式。违规内容可能被下架。', 3, 1, 0, DATE_SUB(NOW(), INTERVAL 5 DAY));

-- -------------------------------------------------------------
-- AI 调用记录（示例，便于运营统计）
-- -------------------------------------------------------------
INSERT INTO `ai_call_log` (`user_id`, `diary_id`, `scene`, `provider`, `model`, `prompt_tokens`, `output_tokens`, `cost_ms`, `success`, `created_at`)
VALUES (4, 3, 'SUMMARY', 'deepseek', 'deepseek-chat', 420, 68, 1830, 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
       (4, 3, 'TAG_SUGGEST', 'deepseek', 'deepseek-chat', 380, 22, 1240, 1, DATE_SUB(NOW(), INTERVAL 4 DAY)),
       (5, 6, 'SUMMARY', 'deepseek', 'deepseek-chat', 396, 54, 1610, 1, DATE_SUB(NOW(), INTERVAL 3 DAY));

SET FOREIGN_KEY_CHECKS = 1;
