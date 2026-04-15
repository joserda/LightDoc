# IFLOW - 在线文档协同编辑平台

## 项目概述

这是一个开源的企业级在线文档协同编辑平台，支持多格式文档的实时协作编辑。项目旨在解决传统文档处理方式的痛点，提供格式开放、深度定制、安全可控的协同办公解决方案。

### 核心特性
- **多格式支持**: docx/pdf/md等格式的上传、解析与展示
- **实时协作**: 毫秒级同步，多人同时编辑，冲突自动合并
- **版本控制**: 自动保存历史版本，支持版本回溯与差异对比
- **权限管理**: 读/写/评论权限分级控制
- **企业级安全**: JWT认证，Spring Security防护
- **双存储支持**: MinIO本地存储 + 阿里云OSS云存储
- **知识库管理**: 支持层级知识库结构，便于文档组织和管理
- **协同编辑增强**: 支持光标位置追踪、在线用户显示、文档锁定等功能
- **主题切换**: 支持默认/暗黑/护眼/极简四种主题，即时切换
- **编辑器扩展**: 基于Tiptap的可扩展富文本编辑器
- **通知系统**: 完整的通知管理，支持文档邀请、评论提及、系统通知等
- **文档邀请**: 支持邀请用户协作编辑文档，成员权限管理
- **Redis缓存**: Redis集成，提升系统性能
- **集群协同**: 基于Redis发布/订阅的跨服务器协同编辑同步
- **文档锁定**: 防止并发冲突的文档锁定机制

## 技术栈

### 前端 (lightdoc-vue/)
- **框架**: Vue 3.4.0 + TypeScript 5.3.3 + Vite 5.0.8
- **UI组件**: Ant Design Vue 4.1.2 + @ant-design/icons-vue 7.0.1
- **富文本编辑**: Tiptap 3.11.1 + Yjs 13.6.10 (CRDT协同编辑)
- **Tiptap扩展**:
  - Starter Kit: 基础编辑功能
  - Collaboration: 协同编辑
  - Collaboration Cursor: 协同光标
  - Table: 表格功能（包含 Table/TableCell/TableHeader/TableRow）
  - Image: 图片功能
  - Link: 链接功能
  - Text Align: 文本对齐
  - Underline: 下划线
- **协同算法**: Yjs 13.6.10 (CRDT)
- **协同协议**: y-protocols 1.0.6, y-prosemirror 1.3.7
- **状态管理**: Pinia 2.1.7 + Vue Composition API
- **文档解析**: mammoth 1.11.0 (docx), pdfjs-dist 5.4.394 (pdf)
- **HTTP客户端**: Axios 1.6.5
- **实时通信**: y-websocket 1.5.0 + 自定义WebSocket提供者
- **时间处理**: dayjs 1.11.10 (包含 relativeTime 插件)
- **路由**: Vue Router 4.2.5
- **开发工具**: vue-tsc 1.8.25 (TypeScript类型检查)

### 后端 (lightdoc-master/)
- **框架**: SpringBoot 3.2.3 + MyBatis Plus 3.5.5
- **语言**: Java 21
- **数据库**: MySQL 8.0.33 + mysql-connector-j 8.0.33
- **缓存**: Redis (Spring Data Redis + Redis发布/订阅)
- **存储**: MinIO 8.5.7 + 阿里云OSS 3.17.4
- **安全**: JWT 0.12.3 + Spring Security
- **文档解析**:
  - Apache Tika 2.9.1 (统一解析框架)
  - Apache PDFBox 3.0.1 (PDF处理)
  - Apache POI 5.2.5 (Office文档：poi/poi-ooxml/poi-scratchpad)
  - Flexmark 0.64.8 (Markdown处理)
- **工具库**:
  - Hutool 5.8.22 (Java工具集)
  - Jsoup 1.17.2 (HTML解析)
  - FastJSON2 2.0.53 (JSON处理)
  - Lombok 1.18.30 (代码简化)
  - Jackson (JSON序列化)
- **WebSocket通信**: Spring WebSocket
- **Yjs集成**: 自定义Yjs文档管理器(二进制快照处理)
- **数据验证**: Spring Boot Validation
- **AOP支持**: Spring Boot AOP
- **MyBatis**: mybatis-spring 3.0.3
- **集群支持**: Redis发布/订阅实现跨服务器协同编辑同步

### 通信协议
- **实时通信**: WebSocket + Yjs CRDT算法
- **API风格**: RESTful
- **端口配置**: 前端3000, 后端8080
- **Redis端口**: 6379

## 项目结构

```
light-doc-new/
├── 编辑器扩展配置说明.md             # 编辑器扩展配置和使用指南
├── 后端协同编辑功能说明文档.md      # 协同编辑后端实现说明
├── 文档编辑器功能文档.md            # 编辑器功能说明
├── 协同编辑功能实现方案.md         # 协同编辑实现方案
├── 主题切换功能说明.md             # 主题切换功能详细文档
├── compile_error.log              # 编译错误日志
├── IFLOW.md                      # 项目说明文档（本文件）
├── lightdoc-master/              # 后端项目目录
│   ├── pom.xml                   # Maven项目配置
│   ├── backend.log               # 后端运行日志
│   ├── compile_error.log         # 后端编译错误日志
│   ├── run_error.log             # 后端运行错误日志
│   ├── src/main/java/com/lightdoc/
│   │   ├── LightdocApplication.java    # 应用启动类
│   │   ├── common/               # 通用工具类
│   │   │   └── Result.java      # 统一返回结果包装类
│   │   ├── config/               # 配置类
│   │   │   ├── MyBatisPlusConfig.java  # MyBatis Plus配置
│   │   │   ├── RedisConfig.java        # Redis配置
│   │   │   ├── SecurityConfig.java     # Spring Security安全配置
│   │   │   ├── WebConfig.java          # Web配置（CORS等）
│   │   │   └── WebSocketConfig.java    # WebSocket配置
│   │   ├── controller/           # 控制器层
│   │   │   ├── AuthController.java     # 认证控制器
│   │   │   ├── CommentController.java  # 评论控制器
│   │   │   ├── DocumentController.java # 文档控制器
│   │   │   ├── DocumentInviteController.java  # 文档邀请控制器
│   │   │   ├── KnowledgeBaseController.java  # 知识库控制器
│   │   │   ├── NotificationController.java    # 通知控制器
│   │   │   └── NotificationTestController.java # 通知测试控制器
│   │   ├── dto/                  # 数据传输对象
│   │   │   ├── CollaborationMessageDTO.java  # 协同消息DTO
│   │   │   ├── CollaborationBroadcastMessageDTO.java # 协同广播消息DTO
│   │   │   ├── CreateNotificationDTO.java    # 创建通知DTO
│   │   │   ├── DocumentDTO.java   # 文档DTO
│   │   │   ├── DocumentQueryDTO.java  # 文档查询DTO
│   │   │   ├── InviteDTO.java     # 邀请DTO
│   │   │   ├── InviteDetailDTO.java  # 邀请详情DTO
│   │   │   ├── KnowledgeBaseDTO.java  # 知识库DTO
│   │   │   ├── KnowledgeBaseQueryDTO.java  # 知识库查询DTO
│   │   │   ├── LoginDTO.java     # 登录DTO
│   │   │   ├── MemberDTO.java    # 成员DTO
│   │   │   ├── NotificationDTO.java    # 通知DTO
│   │   │   └── RegisterDTO.java  # 注册DTO
│   │   ├── entity/               # 实体类
│   │   │   ├── Comment.java      # 评论实体
│   │   │   ├── Document.java     # 文档实体
│   │   │   ├── DocumentLock.java  # 文档锁定实体
│   │   │   ├── DocumentOperationLog.java  # 文档操作日志实体
│   │   │   ├── DocumentPermission.java  # 文档权限实体
│   │   │   ├── DocumentResource.java  # 文档资源实体
│   │   │   ├── DocumentVersion.java  # 文档版本实体
│   │   │   ├── DocumentSettings.java # 文档设置实体
│   │   │   ├── KnowledgeBase.java  # 知识库实体
│   │   │   ├── KnowledgeBasePermission.java  # 知识库权限实体
│   │   │   ├── Notification.java  # 通知实体
│   │   │   └── User.java         # 用户实体
│   │   ├── filter/               # 过滤器
│   │   │   └── JwtAuthenticationFilter.java  # JWT认证过滤器
│   │   ├── handler/              # 处理器
│   │   │   ├── CollaborativeEditorHandler.java  # 协同编辑处理器
│   │   │   └── CollaborationMessageHandler.java  # 协同消息处理器
│   │   ├── manager/              # 管理器
│   │   │   ├── CollaborationRedisPublisher.java  # 协同Redis发布者
│   │   │   ├── CollaborationRedisSubscriber.java # 协同Redis订阅者
│   │   │   └── CollaborationSessionManager.java  # 协作会话管理器
│   │   ├── mapper/               # 数据访问层（MyBatis Mapper）
│   │   │   └── NotificationMapper.java  # 通知Mapper
│   │   ├── service/              # 业务逻辑层
│   │   │   ├── UserService.java  # 用户服务
│   │   │   ├── KnowledgeBaseService.java  # 知识库服务
│   │   │   ├── DocumentService.java  # 文档服务
│   │   │   ├── CommentService.java  # 评论服务
│   │   │   ├── CollaborationService.java  # 协同服务
│   │   │   ├── DocumentInviteService.java # 文档邀请服务
│   │   │   ├── DocumentSettingsService.java # 文档设置服务
│   │   │   ├── DocumentVersionService.java # 文档版本服务
│   │   │   ├── KnowledgeBaseService.java # 知识库服务
│   │   │   ├── NotificationService.java  # 通知服务
│   │   │   └── impl/             # 业务逻辑实现
│   │   └── utils/                # 工具类
│   │       ├── JwtUtil.java      # JWT工具
│   │       ├── MarkdownUtil.java # Markdown工具
│   │       ├── MinioUtil.java    # MinIO工具
│   │       ├── OssUtil.java      # 阿里云OSS工具
│   │       ├── NotificationUtil.java # 通知工具
│   │       └── YjsDocumentManager.java  # Yjs文档管理器
│   └── src/main/resources/
│       ├── application.yml       # 主配置文件
│       ├── new.sql               # 数据库初始化脚本
│       ├── sql/
│       │   └── create_notifications_table.sql  # 通知表创建脚本
│       ├── mapper/               # MyBatis XML映射文件
│       │   └── NotificationMapper.xml  # 通知Mapper XML
│       ├── static/               # 静态资源
│       └── templates/            # 模板文件
└── lightdoc-vue/                 # 前端项目目录
    ├── package.json              # 前端依赖配置
    ├── tsconfig.json             # TypeScript配置
    ├── tsconfig.node.json        # Node.js TypeScript配置
    ├── vite.config.ts            # Vite构建配置
    ├── index.html                # HTML入口
    ├── README.md                 # 前端项目说明
    ├── .env.development          # 开发环境变量
    ├── .env.production           # 生产环境变量
    ├── y-websocket.log           # WebSocket日志
    └── src/
        ├── main.ts               # 应用入口
        ├── App.vue               # 根组件
        ├── api/                  # API接口
        │   ├── auth.ts          # 认证API
        │   ├── comments.ts      # 评论API
        │   ├── documentInvites.ts  # 文档邀请API
        │   ├── documents.ts     # 文档API
        │   ├── knowledgeBase.ts # 知识库API
        │   └── notifications.ts # 通知API
        ├── components/           # 组件
        │   └── editor/          # 编辑器组件
        │       └── EditorMenuBar.vue  # 编辑器菜单栏
        ├── router/               # 路由配置
        │   └── index.ts         # 路由定义
        ├── types/                # TypeScript类型定义
        │   ├── collaboration.ts # 协同编辑类型
        │   ├── index.ts         # 通用类型
        │   └── y-websocket.d.ts # Y-websocket类型定义
        ├── utils/                # 工具函数
        │   ├── request.ts       # HTTP请求封装
        │   ├── storage.ts       # 本地存储封装
        │   └── customWebsocketProvider.ts  # 自定义WebSocket提供者
        └── views/                # 页面组件
            ├── auth/             # 认证页面
            │   ├── Login.vue     # 登录页
            │   └── Register.vue  # 注册页
            ├── document/         # 文档页面
            │   ├── Editor.vue    # 文档编辑器
            │   └── MyDocuments.vue  # 我的文档
            ├── home/             # 首页
            │   ├── Index.vue     # 首页
            │   ├── HomeLayout.vue  # 首页布局
            │   ├── Dashboard.vue  # 仪表盘
            │   ├── Notifications.vue  # 通知页面
            │   ├── Notifications_backup.vue  # 通知备份页面
            │   └── SendNotification.vue  # 发送通知页面
            └── knowledge-base/   # 知识库页面
                ├── List.vue      # 知识库列表
                └── Detail.vue    # 知识库详情
```

## 开发环境搭建

### 前置要求
- **Node.js**: 20.10.6+ (推荐使用最新LTS版本)
- **Java**: 21 (JDK 21)
- **MySQL**: 8.0.33+
- **Redis**: 5.0+ (用于缓存和会话管理)
- **Maven**: 3.6+
- **MinIO服务器**: 用于本地文件存储
- **IDE**: IntelliJ IDEA (推荐) 或 VS Code

### 前端项目运行

```bash
# 进入前端目录
cd lightdoc-vue

# 安装依赖（首次运行或依赖更新时）
npm install

# 启动开发服务器（端口3000）
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

**注意事项**:
- 开发服务器默认运行在 `http://localhost:3000`
- API请求会通过Vite代理转发到 `http://localhost:8080`
- WebSocket连接地址为 `ws://localhost:8080/api`
- 热模块替换（HMR）已启用，修改代码后会自动刷新

### 后端项目运行

```bash
# 进入后端目录
cd lightdoc-master

# 编译并安装依赖
mvn clean install

# 跳过测试编译（如果不需要运行测试）
mvn clean install -DskipTests

# 运行项目（端口8080）
mvn spring-boot:run

# 运行测试
mvn test

# 打包为可执行JAR
mvn clean package
```

**注意事项**:
- 应用默认运行在 `http://localhost:8080/api`
- 上下文路径为 `/api`
- 日志级别设置为DEBUG，便于开发调试
- 确保MySQL和Redis服务已启动并可连接

### 数据库初始化

```bash
# 创建数据库并导入表结构（脚本中已包含数据库创建语句）
mysql -u root -p < lightdoc-master/src/main/resources/new.sql

# 创建通知表
mysql -u root -p light_doc < lightdoc-master/src/main/resources/sql/create_notifications_table.sql
```

**数据库配置**:
- 数据库名称: `light_doc` (注意是 light_doc 而不是 lightdoc)
- 字符集: `utf8mb4`
- 排序规则: `utf8mb4_unicode_ci`
- 默认用户: `root`
- 默认密码: `123456` (可在 application.yml 中修改)

**重要提示**:
- 首次运行前必须执行数据库初始化脚本
- 脚本会自动创建数据库和所有必要的表
- 如需重置数据库，请先删除现有数据库再执行脚本

### Redis配置

```bash
# 启动Redis服务（默认端口6379）
redis-server

# 或使用Docker启动
docker run -d -p 6379:6379 redis:latest
```

**Redis配置信息**:
- 主机地址: `localhost`
- 端口: `6379`
- 密码: 无 (可在 application.yml 中配置)
- 数据库: 1 (可在 application.yml 中配置)

**注意事项**:
- 确保Redis服务在应用启动前已运行
- 生产环境建议设置密码并使用持久化配置

### MinIO配置

```bash
# 启动MinIO服务（端口9000）
minio server C:\minio-data --console-address ":9001"

# 或者使用Docker（推荐）
docker run -d \
  -p 9000:9000 \
  -p 9001:9001 \
  -v minio-data:/data \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=12345678" \
  minio/minio server /data --console-address ":9001"
```

**MinIO配置信息**:
- API访问地址: `http://localhost:9000`
- 管理界面: `http://localhost:9001`
- 默认账号: `admin`
- 默认密码: `12345678`
- 存储桶名称: `light-doc-bucket`

**注意事项**:
- 首次启动需要手动创建存储桶 `light-doc-bucket`
- 确保MinIO服务在应用启动前已运行
- 生产环境建议使用更强的密码

## 开发约定

### 前端约定
- 使用Composition API和TypeScript 5.3.3+
- 组件命名采用PascalCase
- 文件命名采用kebab-case
- 路径别名: `@` 指向 `src` 目录
- API请求统一通过 `@/api` 模块管理
- 环境变量通过 `.env` 文件配置
- 使用Ant Design Vue作为UI组件库
- 使用Tiptap作为富文本编辑器
- 协同编辑使用Yjs和自定义WebSocket提供者
- 使用dayjs进行时间处理，支持相对时间显示

### 后端约定
- 使用Java 21开发
- 遵循RESTful API设计规范
- 统一返回格式: `Result<T>` 包装类
- Controller层处理HTTP请求和参数校验
- Service层处理业务逻辑
- Mapper层处理数据库操作
- 使用MyBatis Plus进行数据库操作
- 统一异常处理和日志记录
- 使用Spring Security进行安全控制
- 协同编辑使用YjsDocumentManager和WebSocket处理器
- 使用Redis进行缓存和会话管理

### 数据库约定
- 数据库名称: light_doc
- 表名使用复数形式(如: users, documents, knowledge_bases, notifications)
- 字段名使用下划线命名(如: user_id, created_at)
- 主键统一使用 `id` 并自增
- 软删除字段: `deleted`
- 时间字段: `created_at`, `updated_at`
- 支持逻辑删除配置

### Git工作流
- main分支: 生产环境代码
- develop分支: 开发环境代码
- feature/xxx分支: 功能开发
- hotfix/xxx分支: 紧急修复

## 核心模块实现指南

### 1. 文档解析模块
- 使用Apache Tika 2.9.1统一处理多格式解析
- docx解析: mammoth.js (前端) + Apache Tika + Apache POI (后端)
- pdf解析: pdfjs-dist (前端) + PDFBox (后端)
- markdown解析: Flexmark (后端)
- 设计HTML-to-Tiptap转换规则
- 快照版本与原始文件解耦存储

### 2. 实时协同模块
- 基于Yjs 13.6.10 CRDT算法实现无冲突合并
- 使用WebSocket进行实时通信
- 实现操作压缩和延迟补偿
- 协同编辑处理器: `CollaborativeEditorHandler`
- 消息处理器: `CollaborationMessageHandler`
- Yjs文档管理器: `YjsDocumentManager`
- 前端WebSocket提供者: `CustomWebsocketProvider`
- 文档锁定机制防止并发冲突
- 光标位置追踪和在线用户显示
- Redis发布/订阅实现跨服务器协同编辑同步
- 协同会话管理器: `CollaborationSessionManager`

### 3. 版本控制模块
- 每次保存生成新快照
- 快照存储为独立OSS对象
- 基于JSON diff算法生成变更视图
- 版本表存储快照路径和元数据
- 支持版本回溯和差异对比

### 4. 权限管理模块
- JWT进行身份验证
- Spring Security进行权限控制
- 支持读/写/评论三级权限
- 文档权限表: `document_permissions`
- 知识库权限表: `knowledge_base_permissions`
- 用户认证过滤器: `JwtAuthenticationFilter`

### 5. 文件存储模块
- 双存储策略: MinIO(本地) + 阿里云OSS(云端)
- 文件存储表: `document_resources`
- 存储工具类: `MinioUtil`, `OssUtil`
- 支持大文件上传(最大100MB)

### 6. 知识库管理模块
- 支持层级知识库结构
- 知识库权限管理
- 文档与知识库关联
- 知识库移动和重组功能

### 7. 通知系统模块
- 支持多种通知类型：系统通知、文档邀请、知识库邀请、评论提及
- 通知创建、读取、批量操作
- 未读通知数量统计
- 通知与关联文档/知识库的跳转
- 通知持久化存储
- 通知工具类: `NotificationUtil`

### 8. 文档邀请模块
- 文档成员邀请功能
- 邀请接受/拒绝机制
- 成员列表管理
- 成员权限修改
- 成员移除功能

### 9. 缓存模块
- Redis集成用于缓存和会话管理
- 支持键值对存储
- 使用GenericJackson2JsonRedisSerializer进行序列化
- 配置类: `RedisConfig`

### 10. 集群协同模块
- Redis发布/订阅实现跨服务器协同编辑同步
- 协同Redis发布者: `CollaborationRedisPublisher`
- 协同Redis订阅者: `CollaborationRedisSubscriber`
- 支持多服务器部署的协同编辑功能

## 配置文件说明

### 前端配置

#### vite.config.ts
Vite构建配置文件，主要包含:
- **插件配置**: Vue 3插件
- **路径别名**: `@` 指向 `src` 目录
- **开发服务器**: 端口3000，API代理到8080
- **依赖优化**: 预构建Tiptap相关依赖

```typescript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

#### tsconfig.json
TypeScript配置文件，主要包含:
- **编译目标**: ES2020
- **严格模式**: 启用所有严格检查
- **路径映射**: `@/*` 映射到 `src/*`
- **模块解析**: bundler模式

#### 环境变量

**.env.development (开发环境)**:
```bash
VITE_API_BASE_URL=http://localhost:8080/api
VITE_WEBSOCKET_BASE_URL=ws://localhost:8080/api
```

**.env.production (生产环境)**:
```bash
VITE_API_BASE_URL=/api
```

**注意事项**:
- 所有环境变量必须以 `VITE_` 开头才能在客户端代码中访问
- 生产环境建议使用相对路径，由Nginx处理反向代理

### 后端配置

#### application.yml
SpringBoot主配置文件，包含以下主要配置:

**服务器配置**:
```yaml
server:
  port: 8080
  servlet:
    context-path: /api
```

**数据库配置**:
```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/light_doc?useUnicode=true&characterEncoding=utf8&allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 123456
```

**Redis配置**:
```yaml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: ''
      database: 1
```

**MinIO配置**:
```yaml
minio:
  endpoint: http://localhost:9000
  access-key: admin
  secret-key: 12345678
  bucket-name: light-doc-bucket
```

**阿里云OSS配置**:
```yaml
oss:
  endpoint: oss-cn-beijing.aliyuncs.com
  access-key-id: your-access-key-id
  access-key-secret: your-access-key-secret
  bucket-name: lightdoc-bucket
  domain: https://lightdoc-bucket.oss-cn-hangzhou.aliyuncs.com
  storage-prefix: lightdoc/attachments/
```

**JWT配置**:
```yaml
jwt:
  secret: bGlnaHRkb2NfanB0X3NlY3JldF9rZXlfbGlnaHRkb2NfanB0X3NlY3JldF9rZXk=
  expiration: 86400000  # 24小时（毫秒）
  token-prefix: Bearer
  token-header: Authorization
```

**协同编辑配置**:
```yaml
collaboration:
  redis:
    channel-shards: 8
```

**MyBatis Plus配置**:
```yaml
mybatis-plus:
  configuration:
    map-underscore-to-camel-case: true  # 驼峰命名转换
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # SQL日志
  global-config:
    db-config:
      id-type: auto  # 主键自增
      logic-delete-field: deleted  # 逻辑删除字段
      logic-delete-value: 1  # 已删除值
      logic-not-delete-value: 0  # 未删除值
  mapper-locations: classpath:/mapper/**/*.xml
  type-aliases-package: com.lightdoc.entity
```

**日志配置**:
```yaml
logging:
  level:
    com.lightdoc: debug  # 应用日志级别
    org.springframework.web: info  # Spring日志级别
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{50} - %msg%n"
```

**安全提示**:
- 生产环境必须修改JWT密钥、数据库密码、MinIO密码、Redis密码等敏感信息
- 建议使用环境变量或配置中心管理敏感配置
- 不要将包含敏感信息的配置文件提交到版本控制

## 数据库设计

### 核心表结构

**users - 用户表**
- 用户基本信息（用户名、邮箱、密码、昵称）
- 用户状态和角色
- 唯一索引：username, email

**knowledge_bases - 知识库表**
- 知识库基本信息（名称、描述、所有者）
- 层级结构支持（parent_id）
- 权限级别和公开状态
- 文档数量统计
- 索引：owner_id, parent_id, status

**knowledge_base_permissions - 知识库权限表**
- 知识库与用户的权限映射
- 支持多级权限控制

**documents - 文档表**
- 文档基本信息（标题、类型、所有者）
- 原始文件和Yjs快照存储路径
- HTML预览和ProseMirror JSON内容
- 文档状态和版本信息
- 知识库关联

**document_versions - 文档版本表**
- 版本号和版本名称
- 快照存储路径
- 变更日志和版本描述
- 创建者和创建时间

**document_permissions - 文档权限表**
- 文档与用户的权限映射
- 支持读/写/评论等权限级别

**document_comments - 文档评论表**
- 评论内容和位置信息
- 评论者信息和时间戳

**document_resources - 文档资源表**
- 原始文件存储信息
- 文件类型和大小
- 存储路径和访问URL

**document_locks - 文档锁定表**
- 协同编辑锁机制
- 锁定者和锁定时间
- 文档锁定状态

**document_operation_logs - 文档操作日志表**
- 操作类型和操作者
- 操作时间戳
- 操作详情

**notifications - 通知表**
- 通知基本信息（类型、标题、内容）
- 接收用户和已读状态
- 发送用户ID（sender_id）
- 关联类型和关联ID（文档、知识库、评论等）
- 创建和更新时间
- 索引：user_id, is_read, created_at, type, user_read

### 数据库特性

**技术特性**:
- 使用MyBatis Plus进行ORM映射
- 支持逻辑删除（deleted字段）
- 字符集：utf8mb4，排序规则：utf8mb4_unicode_ci
- Redis缓存集成

**索引设计**:
- 主键：所有表都使用自增id作为主键
- 外键索引：关联字段都建立了索引
- 查询优化：常用查询字段建立了索引
- 唯一约束：username, email等唯一字段
- 复合索引：notifications表的user_read索引

**数据完整性**:
- 外键约束保证关联数据完整性
- NOT NULL约束保证必填字段
- 默认值设置（如created_at, updated_at）
- 软删除支持（deleted字段）

**特殊功能**:
- 层级结构查询（知识库的parent_id）
- 版本控制（document_versions表）
- 操作审计（document_operation_logs表）
- 协同锁定（document_locks表）
- 通知系统（notifications表）

### 命名规范

**数据库级别**:
- 数据库名称: `light_doc`
- 字符集: `utf8mb4`
- 排序规则: `utf8mb4_unicode_ci`

**表级别**:
- 表名: 使用复数形式，小写下划线命名（如：users, documents, notifications）
- 主键: 统一使用 `id` 并自增
- 时间字段: `created_at`, `updated_at`
- 软删除: `deleted` 字段
- 状态字段: `status`

**字段级别**:
- 字段名: 小写下划线命名（如：user_id, created_at）
- 外键: 关联表名 + _id（如：owner_id, document_id）
- 布尔值: tinyint(1)，0表示false，1表示true
- 金额: decimal类型，保留两位小数
- 枚举: 使用int类型，通过注释说明各值含义

## 部署说明

### 环境要求
- JDK 21+
- Node.js 20.10.6+
- MySQL 8.0.33+
- Redis 5.0+
- MinIO服务器
- Nginx(反向代理)

### 部署步骤
1. 配置数据库、Redis和MinIO
2. 构建前端项目(`npm run build`)
3. 构建后端项目(`mvn clean package`)
4. 配置Nginx反向代理
5. 启动服务

### 生产环境配置
- 前端静态文件由Nginx托管
- 后端API通过Nginx代理到8080端口
- MinIO用于文件存储
- Redis用于缓存和会话管理
- 数据库定期备份
- 日志收集和监控

## 已实现功能

### 前端已实现
- [x] Vue 3.4.0 + TypeScript 5.3.3项目结构
- [x] Ant Design Vue 4.1.2 UI框架集成
- [x] Tiptap 3.11.1富文本编辑器集成
- [x] Yjs 13.6.10协同编辑框架集成
- [x] 用户认证界面(登录/注册)
- [x] 文档编辑界面
- [x] 知识库管理界面
- [x] API请求封装
- [x] 路由配置
- [x] 环境变量配置
- [x] 自定义WebSocket提供者实现协同编辑
- [x] 光标位置追踪和在线用户显示
- [x] 协同编辑状态管理
- [x] 文档锁定和解锁功能
- [x] 实时心跳机制保持连接
- [x] 主题切换功能(默认/暗黑/护眼/极简主题)
- [x] 主题持久化存储(本地存储)
- [x] 编辑器扩展系统基础架构
- [x] 通知系统页面(Notifications.vue)
- [x] 发送通知页面(SendNotification.vue)
- [x] 通知API封装(notifications.ts)
- [x] 文档邀请API封装(documentInvites.ts)
- [x] 相对时间显示(dayjs relativeTime插件)
- [x] 通知批量操作(批量标记已读、批量删除)
- [x] 通知类型筛选和排序
- [x] 文档邀请接受/拒绝功能
- [x] 评论功能

### 后端已实现
- [x] Spring Boot 3.2.3项目结构
- [x] 用户认证模块(JWT)
- [x] 文档管理模块
- [x] 知识库管理模块
- [x] 文档解析模块(Apache Tika + Apache POI)
- [x] 协同编辑模块(WebSocket)
- [x] 版本控制模块
- [x] 权限管理模块
- [x] 文件存储模块(MinIO + 阿里云OSS)
- [x] 数据库设计和初始化脚本
- [x] 文档锁定机制
- [x] 操作日志记录
- [x] Yjs文档管理器(YjsDocumentManager)
- [x] 协同消息处理器(CollaborationMessageHandler)
- [x] 协作会话管理器(CollaborationSessionManager)
- [x] WebSocket心跳和连接管理
- [x] 文档状态同步和更新应用
- [x] Redis集成和配置(RedisConfig)
- [x] 通知实体类(Notification.java)
- [x] 通知控制器(NotificationController.java)
- [x] 通知测试控制器(NotificationTestController.java)
- [x] 通知服务(NotificationService)
- [x] 通知Mapper(NotificationMapper)
- [x] 文档邀请控制器(DocumentInviteController.java)
- [x] 通知DTO类(NotificationDTO, CreateNotificationDTO)
- [x] 文档邀请DTO类(InviteDTO, InviteDetailDTO, MemberDTO)
- [x] Redis发布/订阅协同编辑同步(CollaborationRedisPublisher/Subscriber)
- [x] 通知工具类(NotificationUtil)
- [x] 协同编辑会话管理增强功能
- [x] 文档设置模块

## 待办事项

### 高优先级
- [ ] **完善API文档**: 使用Swagger/OpenAPI生成完整的API文档
- [ ] **编写单元测试**: 前端和后端核心功能的单元测试覆盖率达到80%+
- [ ] **编写集成测试**: 关键业务流程的集成测试
- [ ] **性能优化**: 数据库查询优化、Redis缓存策略、前端加载性能优化
- [ ] **安全加固**: 密码强度验证、XSS防护、CSRF防护、SQL注入防护

### 功能增强
- [ ] **@提及功能**: 评论中@用户通知和提醒
- [ ] **文档全文搜索**: 基于Elasticsearch的全文搜索功能
- [ ] **文档模板功能**: 预设模板和自定义模板
- [ ] **文档导出功能**: 支持导出为PDF、Word、Markdown等格式
- [ ] **移动端适配**: 响应式设计和移动端优化
- [ ] **协同编辑优化**: 用户状态显示优化、冲突解决算法优化
- [ ] **文档导入优化**: 支持更多格式，提高解析准确性
- [ ] **实时通知推送**: WebSocket实时推送通知到前端
- [ ] **知识库邀请功能**: 类似文档邀请的知识库成员邀请

### 主题系统
- [ ] **动态主题**: 根据时间自动切换主题
- [ ] **主题动画**: 主题切换动画效果
- [ ] **主题分享**: 主题配置分享和导入/导出
- [ ] **主题市场**: 预设主题库和用户主题分享
- [ ] **主题插件**: 主题插件系统开发

### 编辑器扩展
- [ ] **自定义节点**: 卡片、提示框、引用块等自定义节点
- [ ] **自定义标记**: 高亮、荧光笔、删除线等自定义标记
- [ ] **数学公式**: 集成KaTeX或MathJax数学公式扩展
- [ ] **表情符号**: 集成表情符号选择器
- [ ] **代码高亮**: 集成代码高亮和语法检查
- [ ] **拖拽手柄**: 段落和块的拖拽排序功能
- [ ] **表格增强**: 表格样式、合并单元格、公式计算等

### 协同编辑
- [ ] **实时评论**: 文档内实时评论和讨论
- [ ] **修订模式**: 类似Word的修订模式，记录所有修改
- [ ] **版本对比**: 可视化版本差异对比
- [ ] **冲突解决**: 更智能的冲突检测和解决机制
- [ ] **离线编辑**: 支持离线编辑和自动同步
- [ ] **协同历史**: 查看协同编辑历史记录

### 知识库管理
- [ ] **权限细化**: 更细粒度的权限控制（查看、编辑、删除、分享等）
- [ ] **标签系统**: 文档标签和分类管理
- [ ] **收藏功能**: 文档收藏和快速访问
- [ ] **知识库统计**: 文档数量、访问量、活跃度等统计
- [ ] **知识库导出**: 整个知识库导出为压缩包

### 用户体验
- [ ] **快捷键支持**: 常用操作的快捷键
- [ ] **拖拽上传**: 文件拖拽上传功能
- [ ] **批量操作**: 文档批量删除、移动、导出等
- [ ] **搜索优化**: 搜索建议、历史搜索、高级搜索
- [ ] **通知系统优化**: 实时通知推送、通知分类、通知设置
- [ ] **个人设置**: 用户偏好设置和个性化配置

### 开发质量
- [ ] **代码规范**: 统一代码风格和命名规范
- [ ] **代码审查**: 建立代码审查流程
- [ ] **CI/CD**: 持续集成和持续部署流程
- [ ] **错误监控**: 集成错误监控和日志分析
- [ ] **性能监控**: 应用性能监控和分析

### 运维部署
- [ ] **Docker支持**: Docker容器化部署
- [ ] **Kubernetes**: K8s集群部署支持
- [ ] **负载均衡**: 多实例部署和负载均衡
- [ ] **高可用**: 数据库主从、Redis集群等高可用方案
- [ ] **日志收集**: ELK或类似日志收集和分析系统
- [ ] **监控告警**: Prometheus + Grafana监控和告警
- [ ] **数据备份**: 自动化数据备份和恢复方案
- [ ] **部署文档**: 完善的部署和运维文档

## 新增功能说明

### 主题切换功能

系统支持多种预设主题和自定义主题配置，提供个性化的编辑体验。

**预设主题**:
- **默认主题**: 蓝色主色调，适合日常办公
- **暗黑主题**: 深色背景，适合夜间使用，减少屏幕亮度刺激
- **护眼主题**: 绿色主色调，适合长时间阅读
- **极简主题**: 简洁清爽，专注内容本身

**核心特性**:
- 即时主题切换，无需刷新页面
- 主题设置自动持久化到本地存储
- 支持系统主题自动跟随
- 支持自定义主题创建和配置
- 支持主题分享和导入/导出
- 主题切换动画效果(0.3秒淡入淡出)

**快捷键**:
- Ctrl+Shift+L: 打开主题切换面板
- Ctrl+Shift+1~4: 快速切换到对应主题

详细说明请参考: [主题切换功能说明](./主题切换功能说明.md)

### 编辑器扩展配置

Tiptap编辑器通过扩展系统提供丰富的功能支持。

**扩展类型**:
- **节点扩展**: 定义文档中的块级元素(段落、标题、列表、表格、代码块等)
- **标记扩展**: 定义文本样式(加粗、斜体、下划线、链接、高亮等)
- **功能扩展**: 添加编辑器行为(撤销/重做、协同编辑、占位符等)

**核心扩展包**:
- **StarterKit**: 基础扩展包，包含最常用的编辑功能
- **Table**: 完整的表格功能(插入、编辑、合并单元格等)
- **Image**: 图片上传和显示功能
- **Link**: 超链接功能
- **TaskList**: 任务列表功能
- **Collaboration**: 协同编辑扩展
- **CollaborationCursor**: 协同光标显示

**自定义扩展**:
- 支持创建自定义节点扩展
- 支持创建自定义标记扩展
- 支持创建自定义功能扩展
- 提供完整的扩展开发流程指南

详细说明请参考: [编辑器扩展配置说明](./编辑器扩展配置说明.md)

### 通知系统

系统提供完整的通知管理功能，支持多种通知类型和灵活的通知操作。

**通知类型**:
- **系统通知**: 系统级别的重要通知
- **文档邀请**: 文档协作邀请通知
- **知识库邀请**: 知识库成员邀请通知
- **评论提及**: 评论中@用户的通知

**核心功能**:
- 创建通知（单个/批量）
- 获取用户通知列表（分页）
- 标记通知为已读（单个/批量/全部）
- 删除通知（单个/批量）
- 获取未读通知数量
- 通知类型筛选和排序
- 通知与关联文档/知识库的跳转
- 相对时间显示（如"5分钟前"）

**API接口**:
- `POST /notifications` - 创建通知
- `POST /notifications/batch` - 批量创建通知
- `GET /notifications` - 获取用户通知列表
- `GET /notifications/:id` - 获取通知详情
- `PUT /notifications/:id/read` - 标记通知为已读
- `PUT /notifications/batch/read` - 批量标记为已读
- `PUT /notifications/all/read` - 标记所有通知为已读
- `DELETE /notifications/:id` - 删除通知
- `DELETE /notifications/batch` - 批量删除通知
- `GET /notifications/unread/count` - 获取未读通知数量

**前端页面**:
- `Notifications.vue` - 通知列表页面，支持查看、标记、删除、筛选等操作
- `SendNotification.vue` - 发送通知页面，支持单个/批量发送通知

### 文档邀请功能

系统支持文档成员邀请和权限管理，方便团队协作。

**核心功能**:
- 邀请用户加入文档协作
- 接受/拒绝文档邀请
- 获取文档成员列表
- 移除文档成员
- 修改成员权限
- 获取文档的待处理邀请列表
- 获取当前用户的待处理邀请列表

**API接口**:
- `POST /documents/:id/invite` - 邀请用户加入文档
- `PUT /documents/:id/invites/accept` - 接受邀请
- `PUT /documents/:id/invites/reject` - 拒绝邀请
- `GET /documents/:id/members` - 获取文档成员列表
- `DELETE /documents/:id/members/:userId` - 移除成员
- `PUT /documents/:id/members/:userId/permission` - 修改成员权限
- `GET /documents/:id/invites` - 获取文档的待处理邀请列表
- `GET /documents/user/invites` - 获取当前用户的待处理邀请列表

**权限级别**:
- 读权限：只能查看文档
- 写权限：可以编辑文档
- 评论权限：可以添加评论

### Redis缓存集成

系统集成了Redis用于缓存和会话管理，提升系统性能。

**配置信息**:
- 主机地址: `localhost`
- 端口: `6379`
- 密码: 可配置
- 数据库: `1`

**序列化配置**:
- Key序列化: StringRedisSerializer
- Value序列化: GenericJackson2JsonRedisSerializer
- Hash Key序列化: StringRedisSerializer
- Hash Value序列化: GenericJackson2JsonRedisSerializer

**配置类**: `RedisConfig.java`

### 集群协同编辑功能

系统支持跨服务器协同编辑，使用Redis发布/订阅实现实时同步。

**核心组件**:
- `CollaborationRedisPublisher`: Redis消息发布者
- `CollaborationRedisSubscriber`: Redis消息订阅者
- 消息分片策略：支持8个Redis频道分片
- 二进制消息支持：Yjs协议的二进制同步

**配置**:
- 频道分片数：默认8个分片
- 跨服务器同步：基于Redis Pub/Sub
- 会话管理：支持跨服务器会话状态同步

## 项目状态

### 当前版本
- **前端版本**: 0.0.0
- **后端版本**: 1.0.0
- **最后更新**: 2026-02-28

### 开发状态
- ✅ 项目基础架构已完成
- ✅ 核心功能已实现（文档管理、协同编辑、知识库管理）
- ✅ 主题切换功能已实现
- ✅ 编辑器扩展系统已搭建
- ✅ 通知系统已实现
- ✅ 文档邀请功能已实现
- ✅ Redis缓存已集成
- ✅ 跨服务器协同编辑已实现
- 🚧 部分功能待优化和完善
- 📝 单元测试和集成测试待补充

### 已知问题
- [ ] WebSocket连接稳定性需要进一步优化
- [ ] 大文件上传性能需要优化
- [ ] 协同编辑冲突解决算法需要优化
- [ ] 移动端适配尚未完成
- [ ] API文档需要完善（Swagger/OpenAPI）
- [ ] 部分边界情况处理需要完善
- [ ] 通知实时推送功能待实现

### 性能指标
- 前端构建时间: ~30-60秒
- 后端启动时间: ~10-20秒
- 数据库查询响应: <100ms（常规查询）
- WebSocket延迟: <50ms（局域网环境）
- Redis缓存响应: <10ms

### 技术债务
- 部分代码缺少单元测试
- 错误处理机制需要统一
- 日志记录需要规范化
- 配置管理需要优化（建议使用配置中心）
- 文档注释需要补充
- 通知系统需要实时推送支持

## 相关文档

### 项目文档
- [前端项目说明](./lightdoc-vue/README.md) - 前端项目详细说明

### 技术文档
- [协同编辑功能实现方案](./协同编辑功能实现方案.md) - 协同编辑实现方案
- [后端协同编辑功能说明文档](./后端协同编辑功能说明文档.md) - 协同编辑后端实现
- [文档编辑器功能文档](./文档编辑器功能文档.md) - 编辑器功能说明

### 功能文档
- [主题切换功能说明](./主题切换功能说明.md) - 主题切换功能详细文档
- [编辑器扩展配置说明](./编辑器扩展配置说明.md) - 编辑器扩展配置和使用指南

### 待创建文档
- [API文档](./lightdoc-master/docs/api.md) - RESTful API文档（待创建）
- [数据库设计文档](./lightdoc-master/docs/database.md) - 数据库设计详细文档（待创建）
- [部署文档](./lightdoc-master/docs/deployment.md) - 部署运维文档（待创建）
- [开发规范文档](./lightdoc-master/docs/coding-standards.md) - 代码规范文档（待创建）
- [通知系统文档](./lightdoc-master/docs/notification-system.md) - 通知系统详细文档（待创建）
- [文档邀请功能文档](./lightdoc-master/docs/document-invite.md) - 文档邀请功能文档（待创建）

## 贡献指南

### 开发流程
1. 从develop分支创建feature分支
2. 在feature分支上进行开发
3. 提交代码前运行测试
4. 创建Pull Request到develop分支
5. 代码审查通过后合并

### 代码规范
- 前端遵循Vue 3官方风格指南
- 后端遵循阿里巴巴Java开发手册
- 使用ESLint和Prettier格式化前端代码
- 使用CheckStyle和SpotBugs检查后端代码

### 提交规范
提交信息格式：`<type>(<scope>): <subject>`

- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构
- test: 测试相关
- chore: 构建/工具链相关

示例：
```
feat(editor): 添加表格合并功能
fix(auth): 修复JWT token过期问题
docs(readme): 更新安装说明
feat(notification): 实现通知系统
feat(invite): 实现文档邀请功能
feat(cache): 集成Redis缓存
```

## 许可证

本项目采用开源许可证，具体信息请参考LICENSE文件。

## 联系方式

如有问题或建议，请通过以下方式联系：
- 提交Issue
- 发送邮件
- 加入讨论组

---

**最后更新**: 2026-02-28
**维护者**: LightDoc Team