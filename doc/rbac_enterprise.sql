-- ============================================================================
-- 企业级通用 RBAC 权限体系  (MySQL 8.0+ / utf8mb4 / InnoDB)
-- 覆盖: 组织架构(部门树) + 岗位 + 用户 + 角色 + 权限(目录/菜单/按钮/接口) + 数据范围
-- 所有表统一基础字段: id / create_time / update_time / creator / update_by
-- 后端: FastAPI    前端: Vue3 + Element Plus
-- admin 初始密码: Admin@123
-- ============================================================================

CREATE DATABASE IF NOT EXISTS lib_agent DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lib_agent;

-- ============================================================================
-- 通用说明（所有表均含以下基础字段，下文不再重复注释）:
--   id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
--   create_time DATETIME DEFAULT CURRENT_TIMESTAMP          数据插入时间
--   update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP  最后修改时间(自动刷新)
--   creator     BIGINT UNSIGNED DEFAULT NULL                创建人(用户ID)
--   update_by   BIGINT UNSIGNED DEFAULT NULL                修改人(用户ID)
-- ============================================================================

-- ============================================================================
-- 一、组织架构
-- ============================================================================

-- 组织/部门表（树形，支持集团-公司-部门-小组任意层级）
CREATE TABLE IF NOT EXISTS sys_org (
    id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    parent_id  BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '父组织ID,0=根',
    ancestors  VARCHAR(500) NOT NULL DEFAULT '' COMMENT '祖级路径,如 0,1,2 (便于查所有下级)',
    name       VARCHAR(64)  NOT NULL COMMENT '组织名称',
    code       VARCHAR(32)  DEFAULT '' COMMENT '组织编码(可对接HR/钉钉/企微)',
    type       TINYINT      NOT NULL DEFAULT 2 COMMENT '1公司 2部门 3小组(可扩展)',
    leader_id  BIGINT UNSIGNED NULL COMMENT '负责人用户ID',
    phone      VARCHAR(20)  DEFAULT '',
    email      VARCHAR(64)  DEFAULT '',
    sort       INT          NOT NULL DEFAULT 0,
    status     TINYINT      NOT NULL DEFAULT 1,
    deleted    TINYINT      NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    KEY idx_parent (parent_id),
    KEY idx_ancestors (ancestors)
) ENGINE=InnoDB COMMENT='组织/部门表';

-- 岗位表（职级维度，与部门解耦：一个人一个部门可以有多个岗位）
CREATE TABLE IF NOT EXISTS sys_post (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(32)  NOT NULL COMMENT '岗位编码',
    name        VARCHAR(32)  NOT NULL COMMENT '岗位名称',
    level       INT          NOT NULL DEFAULT 0 COMMENT '职级,数字越小越高',
    sort        INT          NOT NULL DEFAULT 0,
    status      TINYINT      NOT NULL DEFAULT 1,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_code (code)
) ENGINE=InnoDB COMMENT='岗位表';

-- ============================================================================
-- 二、用户
-- ============================================================================

CREATE TABLE IF NOT EXISTS sys_user (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(32)  NOT NULL COMMENT '登录名',
    password    VARCHAR(100) NOT NULL COMMENT 'bcrypt加密',
    nickname    VARCHAR(32)  DEFAULT '',
    email       VARCHAR(64)  DEFAULT '',
    phone       VARCHAR(20)  DEFAULT '',
    avatar      VARCHAR(255) DEFAULT '',
    gender      TINYINT      DEFAULT 0 COMMENT '0未知 1男 2女',
    org_id      BIGINT UNSIGNED NULL COMMENT '主部门ID',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
    is_super    TINYINT      NOT NULL DEFAULT 0 COMMENT '1超级管理员(跳过一切校验)',
    last_login  DATETIME     NULL,
    deleted     TINYINT      NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_username (username),
    KEY idx_org (org_id)
) ENGINE=InnoDB COMMENT='用户表';

-- 用户-兼职部门（主部门在 sys_user.org_id，这里支持一人多部门）
CREATE TABLE IF NOT EXISTS sys_user_org (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    org_id      BIGINT UNSIGNED NOT NULL,
    is_main     TINYINT NOT NULL DEFAULT 0 COMMENT '是否主部门冗余标记',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_user_org (user_id, org_id)
) ENGINE=InnoDB COMMENT='用户部门关联(含兼职)';

-- 用户-岗位
CREATE TABLE IF NOT EXISTS sys_user_post (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    post_id     BIGINT UNSIGNED NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_user_post (user_id, post_id)
) ENGINE=InnoDB COMMENT='用户岗位关联';

-- ============================================================================
-- 三、角色 + 数据范围
-- ============================================================================

-- data_scope: 1=全部数据 2=本部门及以下 3=本部门 4=仅本人 5=自定义(见 sys_role_org)
CREATE TABLE IF NOT EXISTS sys_role (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(32)  NOT NULL,
    name        VARCHAR(32)  NOT NULL,
    data_scope  TINYINT      NOT NULL DEFAULT 4 COMMENT '数据范围',
    description VARCHAR(200) DEFAULT '',
    sort        INT          NOT NULL DEFAULT 0,
    status      TINYINT      NOT NULL DEFAULT 1,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_code (code)
) ENGINE=InnoDB COMMENT='角色表';

-- data_scope=5 时生效：角色可看的自定义组织列表
CREATE TABLE IF NOT EXISTS sys_role_org (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id     BIGINT UNSIGNED NOT NULL,
    org_id      BIGINT UNSIGNED NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_role_org (role_id, org_id)
) ENGINE=InnoDB COMMENT='角色自定义数据范围';

-- ============================================================================
-- 四、权限（一棵树承载: 0目录 1菜单 2按钮 3接口）
-- ============================================================================

CREATE TABLE IF NOT EXISTS sys_menu (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    parent_id   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    name        VARCHAR(64)  NOT NULL COMMENT '路由名',
    title       VARCHAR(64)  NOT NULL COMMENT '显示名称',
    type        TINYINT      NOT NULL COMMENT '0目录 1菜单 2按钮 3接口(API)',
    path        VARCHAR(128) DEFAULT '' COMMENT '前端路由路径',
    component   VARCHAR(255) DEFAULT '' COMMENT '前端组件路径',
    icon        VARCHAR(64)  DEFAULT '',
    perm        VARCHAR(128) DEFAULT '' COMMENT '权限标识: system:user:add 或 api:/user/*',
    method      VARCHAR(8)   DEFAULT '' COMMENT 'type=3时: GET/POST/PUT/DELETE',
    api_path    VARCHAR(128) DEFAULT '' COMMENT 'type=3时: 后端接口路径,如 /api/v1/users',
    sort        INT          NOT NULL DEFAULT 0,
    visible     TINYINT      NOT NULL DEFAULT 1,
    status      TINYINT      NOT NULL DEFAULT 1,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    KEY idx_parent (parent_id)
) ENGINE=InnoDB COMMENT='权限表(目录/菜单/按钮/接口)';

-- 用户-角色
CREATE TABLE IF NOT EXISTS sys_user_role (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT UNSIGNED NOT NULL,
    role_id     BIGINT UNSIGNED NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB COMMENT='用户角色关联';

-- 角色-权限
CREATE TABLE IF NOT EXISTS sys_role_menu (
    id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    role_id     BIGINT UNSIGNED NOT NULL,
    menu_id     BIGINT UNSIGNED NOT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator     BIGINT UNSIGNED DEFAULT NULL COMMENT '创建人ID',
    update_by   BIGINT UNSIGNED DEFAULT NULL COMMENT '修改人ID',
    UNIQUE KEY uk_role_menu (role_id, menu_id)
) ENGINE=InnoDB COMMENT='角色权限关联';

-- ============================================================================
-- 基础数据 (seed, creator 统一记为 1 = admin)
-- ============================================================================

-- ---------- 组织树 ----------
INSERT INTO sys_org (id, parent_id, ancestors, name, code, type, sort, creator) VALUES
(1, 0, '0',       '某某科技集团', 'GROUP',      1, 1, 1),
(2, 1, '0,1',     '北京总公司',   'BJHQ',       1, 1, 1),
(3, 1, '0,1',     '上海分公司',   'SHFB',       1, 2, 1),
(4, 2, '0,1,2',   '研发中心',     'RD',         2, 1, 1),
(5, 2, '0,1,2',   '市场部',       'MKT',        2, 2, 1),
(6, 2, '0,1,2',   '综合管理部',   'ADMIN_DEPT', 2, 3, 1),
(7, 4, '0,1,2,4', '后端开发组',   'RD_BACKEND', 3, 1, 1),
(8, 4, '0,1,2,4', '前端开发组',   'RD_FRONT',   3, 2, 1),
(9, 4, '0,1,2,4', '测试组',       'RD_QA',      3, 3, 1),
(10, 3, '0,1,3',  '上海市场部',   'SH_MKT',     2, 1, 1);

-- ---------- 岗位 ----------
INSERT INTO sys_post (id, code, name, level, sort, creator) VALUES
(1, 'CEO',      '总经理',     1, 1, 1),
(2, 'DIRECTOR', '总监',       2, 2, 1),
(3, 'MGR',      '部门经理',   3, 3, 1),
(4, 'LEADER',   '组长',       4, 4, 1),
(5, 'DEV',      '工程师',     5, 5, 1),
(6, 'QA',       '测试工程师', 5, 6, 1),
(7, 'INTERN',   '实习生',     9, 7, 1);

-- ---------- 用户 (密码均为 Admin@123) ----------
INSERT INTO sys_user (id, username, password, nickname, org_id, is_super, creator) VALUES
(1, 'admin',    '$2b$12$Ui8lYIDpTCD5OPWjhHZqHe5x0W5292xFR.FYmrzCtB7/zPzluvf1W', '超级管理员', 6, 1, 1),
(2, 'zhangsan', '$2b$12$Ui8lYIDpTCD5OPWjhHZqHe5x0W5292xFR.FYmrzCtB7/zPzluvf1W', '张三',       4, 0, 1),
(3, 'lisi',     '$2b$12$Ui8lYIDpTCD5OPWjhHZqHe5x0W5292xFR.FYmrzCtB7/zPzluvf1W', '李四',       7, 0, 1);

INSERT INTO sys_user_org (user_id, org_id, is_main, creator) VALUES
(1, 6, 1, 1), (2, 4, 1, 1), (3, 7, 1, 1);

INSERT INTO sys_user_post (user_id, post_id, creator) VALUES
(1, 1, 1), (2, 2, 1), (3, 5, 1);

-- ---------- 角色 ----------
INSERT INTO sys_role (id, code, name, data_scope, description, sort, creator) VALUES
(1, 'ADMIN',      '系统管理员', 1, '全部数据+全部功能', 1, 1),
(2, 'DEPT_ADMIN', '部门管理员', 2, '本部门及以下数据',  2, 1),
(3, 'STAFF',      '普通员工',   4, '仅本人数据',        3, 1);

INSERT INTO sys_user_role (user_id, role_id, creator) VALUES
(1, 1, 1), (2, 2, 1), (3, 3, 1);

-- ---------- 权限树: 目录(0) ----------
INSERT INTO sys_menu (id, parent_id, name, title, type, path, icon, sort, creator) VALUES
(1,  0, 'System',  '系统管理', 0, '/system',  'Setting',      90, 1),
(2,  0, 'Library', '文库管理', 0, '/library', 'FolderOpened', 10, 1);

-- ---------- 菜单(1) ----------
INSERT INTO sys_menu (id, parent_id, name, title, type, path, component, icon, sort, creator) VALUES
(11, 1, 'Org',       '组织管理', 1, 'org',    'system/org/index',     'OfficeBuilding', 1, 1),
(12, 1, 'User',      '用户管理', 1, 'user',   'system/user/index',    'User',      2, 1),
(13, 1, 'Role',      '角色管理', 1, 'role',   'system/role/index',    'Avatar',    3, 1),
(14, 1, 'Post',      '岗位管理', 1, 'post',   'system/post/index',    'Postcard',  4, 1),
(15, 1, 'Menu',      '菜单权限', 1, 'menu',   'system/menu/index',    'Menu',      5, 1),
(21, 2, 'DocList',   '文档列表', 1, 'doc',    'library/doc/index',    'Document',  1, 1),
(22, 2, 'DocUpload', '上传文档', 1, 'upload', 'library/upload/index', 'Upload',    2, 1);

-- ---------- 按钮(2): 前端 v-perm 控制显隐 ----------
INSERT INTO sys_menu (id, parent_id, name, title, type, perm, sort, creator) VALUES
(111, 11, 'OrgAdd',     '新增组织', 2, 'system:org:add',       1, 1),
(112, 11, 'OrgEdit',    '编辑组织', 2, 'system:org:edit',      2, 1),
(113, 11, 'OrgDelete',  '删除组织', 2, 'system:org:delete',    3, 1),
(121, 12, 'UserAdd',    '新增用户', 2, 'system:user:add',      1, 1),
(122, 12, 'UserEdit',   '编辑用户', 2, 'system:user:edit',     2, 1),
(123, 12, 'UserDelete', '删除用户', 2, 'system:user:delete',   3, 1),
(124, 12, 'UserReset',  '重置密码', 2, 'system:user:reset',    4, 1),
(131, 13, 'RoleAdd',    '新增角色', 2, 'system:role:add',      1, 1),
(132, 13, 'RoleEdit',   '编辑角色', 2, 'system:role:edit',     2, 1),
(133, 13, 'RoleAssign', '分配权限', 2, 'system:role:assign',   3, 1),
(211, 21, 'DocAdd',     '新增文档', 2, 'library:doc:add',      1, 1),
(212, 21, 'DocEdit',    '编辑文档', 2, 'library:doc:edit',     2, 1),
(213, 21, 'DocDelete',  '删除文档', 2, 'library:doc:delete',   3, 1),
(214, 21, 'DocDownload','下载文档', 2, 'library:doc:download', 4, 1);

-- ---------- 接口(3): 后端 require_perm 精确到方法+路径 ----------
INSERT INTO sys_menu (id, parent_id, name, title, type, perm, method, api_path, sort, creator) VALUES
(1151, 11, 'OrgListApi',  '组织查询接口', 3, 'system:org:list',    'GET',    '/api/v1/orgs',       1, 1),
(1152, 11, 'OrgSaveApi',  '组织保存接口', 3, 'system:org:save',    'POST',   '/api/v1/orgs',       2, 1),
(1251, 12, 'UserListApi', '用户查询接口', 3, 'system:user:list',   'GET',    '/api/v1/users',      1, 1),
(1252, 12, 'UserSaveApi', '用户保存接口', 3, 'system:user:save',   'POST',   '/api/v1/users',      2, 1),
(1253, 12, 'UserDelApi',  '用户删除接口', 3, 'system:user:delete', 'DELETE', '/api/v1/users/{id}', 3, 1),
(2151, 21, 'DocListApi',  '文档查询接口', 3, 'library:doc:list',   'GET',    '/api/v1/docs',       1, 1),
(2152, 21, 'DocDelApi',   '文档删除接口', 3, 'library:doc:delete', 'DELETE', '/api/v1/docs/{id}',  2, 1);

-- ---------- 角色-权限 ----------
-- ADMIN: 全部
INSERT INTO sys_role_menu (role_id, menu_id, creator) SELECT 1, id, 1 FROM sys_menu;

-- DEPT_ADMIN: 系统管理只读(除菜单权限), 文库可增改, 不能删用户/文档
INSERT INTO sys_role_menu (role_id, menu_id, creator) VALUES
(2, 1, 1), (2, 11, 1), (2, 12, 1), (2, 14, 1),
(2, 1151, 1), (2, 1251, 1),
(2, 2, 1), (2, 21, 1), (2, 22, 1), (2, 211, 1), (2, 212, 1), (2, 214, 1),
(2, 2151, 1);

-- STAFF: 只有文库列表+上传+新增
INSERT INTO sys_role_menu (role_id, menu_id, creator) VALUES
(3, 2, 1), (3, 21, 1), (3, 22, 1), (3, 211, 1), (3, 2151, 1);

-- DEPT_ADMIN 自定义数据范围示例: 研发中心及以下(4及其子孙 7,8,9)
INSERT INTO sys_role_org (role_id, org_id, creator) VALUES (2, 4, 1);
