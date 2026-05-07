# LightDoc - 轻量级文档协同编辑平台

LightDoc 是一个基于 Spring Boot + Vue 3 的在线文档协同编辑平台，支持实时协作、版本控制、知识库管理等功能。

## 项目简介

LightDoc 提供了一个现代化的在线文档编辑解决方案，支持多人实时协同编辑、文档版本管理、权限控制等企业级功能。系统采用前后端分离架构，后端基于 Spring Boot 3.x，前端使用 Vue 3 + TypeScript。

## 核心功能

### 文档管理
- 文档创建、编辑、删除、查看
- 支持多种文档格式导入（PDF、Word、Markdown）
- 文档搜索和标签管理
- 文档分享和权限控制

### 协同编辑
- 基于 Yjs 的实时协同编辑
- 多人同时编辑，实时同步
- 协作者光标显示
- 文档锁定机制

### 知识库管理
- 知识库创建和管理
- 层级目录结构
- 知识库权限控制
- 文档分类组织

### 版本控制
- 自动版本保存
- 版本历史查看
- 版本对比和回滚
- 版本描述和备注

### 权限管理
- 细粒度权限控制（读/写/管理）
- 文档邀请机制
- 权限继承和覆盖
- 操作日志记录

### 评论系统
- 文档评论和回复
- 评论位置定位
- @提及功能
- 评论状态管理

### 通知系统
- 实时消息通知
- 多种通知类型（邀请、评论、系统通知）
- 已读未读状态
- 通知中心

## 技术栈

### 后端技术
- **框架**: Spring Boot 3.2.3
- **语言**: Java 21
- **数据库**: MySQL 8.0
- **ORM**: MyBatis Plus 3.5.5
- **缓存**: Redis 7.0
- **安全**: Spring Security + JWT
- **实时通信**: WebSocket
- **文件存储**: MinIO / 阿里云 OSS
- **文档解析**: Apache Tika、PDFBox、POI
- **Markdown**: Flexmark

### 前端技术
- **框架**: Vue 3.4 + TypeScript
- **构建工具**: Vite 5.0
- **路由**: Vue Router 4.2
- **状态管理**: Pinia 2.1
- **UI 组件库**: Ant Design Vue 4.1
- **编辑器**: Tiptap 3.11
- **协同编辑**: Yjs 13.6 + y-websocket
- **HTTP 客户端**: Axios 1.6

## 项目结构

```
light-doc-new/
├── lightdoc-master/          # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/lightdoc/
│   │   │   │   ├── config/          # 配置类
│   │   │   │   ├── controller/      # 控制器
│   │   │   │   ├── dto/             # 数据传输对象
│   │   │   │   ├── entity/          # 实体类
│   │   │   │   ├── filter/          # 过滤器
│   │   │   │   ├── handler/         # 处理器
│   │   │   │   ├── manager/         # 管理器
│   │   │   │   ├── mapper/          # MyBatis Mapper
│   │   │   │   ├── service/         # 服务层
│   │   │   │   └── utils/           # 工具类
│   │   │   └── resources/
│   │   │       ├── mapper/          # MyBatis XML
│   │   │       ├── sql/             # SQL 脚本
│   │   │       └── application.yml  # 配置文件
│   │   └── test/                    # 测试代码
│   └── pom.xml                      # Maven 配置
│
├── lightdoc-vue/             # 前端项目
│   ├── src/
│   │   ├── api/              # API 接口
│   │   ├── components/       # 公共组件
│   │   ├── router/           # 路由配置
│   │   ├── types/            # TypeScript 类型
│   │   ├── utils/            # 工具函数
│   │   ├── views/            # 页面组件
│   │   ├── App.vue           # 根组件
│   │   └── main.ts           # 入口文件
│   ├── .env.development      # 开发环境变量
│   ├── .env.production       # 生产环境变量
│   ├── package.json          # 依赖配置
│   ├── tsconfig.json         # TypeScript 配置
│   └── vite.config.ts        # Vite 配置
│
├── docker-compose.yml        # Docker Compose 配置
├── db-structure.sql          # 数据库结构
└── db-data.sql              # 数据库初始数据
```

## 快速开始

### 环境要求

- JDK 21+
- Node.js 18+
- MySQL 8.0+
- Redis 7.0+
- Maven 3.8+
- Docker & Docker Compose（可选）

### 后端部署

1. **克隆项目**
```bash
git clone <repository-url>
cd light-doc-new
```

2. **创建数据库**
```bash
mysql -u root -p
CREATE DATABASE light_doc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE light_doc;
SOURCE db-structure.sql;
SOURCE db-data.sql;
```

3. **修改配置**

编辑 `lightdoc-master/src/main/resources/application.yml`，配置数据库、Redis、MinIO 等信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/light_doc
    username: root
    password: your_password
  data:
    redis:
      host: localhost
      port: 6379
```

4. **构建并运行**
```bash
cd lightdoc-master
mvn clean package
java -jar target/lightdoc-1.0.0.jar
```

后端服务将在 `http://localhost:8080` 运行。

### 前端部署

1. **安装依赖**
```bash
cd lightdoc-vue
npm install
```

2. **配置环境变量**

编辑 `.env.development`：
```
VITE_API_BASE_URL=http://localhost:8080/api
```

3. **开发模式运行**
```bash
npm run dev
```

前端服务将在 `http://localhost:3000` 运行。

4. **生产构建**
```bash
npm run build
```

构建产物将生成在 `dist/` 目录。

### Docker 部署（推荐）

使用 Docker Compose 快速部署依赖服务：

```bash
docker-compose up -d
```

这将启动：
- Redis 服务（端口 6379）
- MinIO 服务（API 端口 9000，控制台端口 9001）

MinIO 控制台访问：`http://localhost:9001`
- 用户名：admin
- 密码：12345678

## 数据库设计

### 核心表结构

- **users**: 用户表
- **documents**: 文档表
- **knowledge_bases**: 知识库表
- **document_permissions**: 文档权限表
- **knowledge_base_permissions**: 知识库权限表
- **document_versions**: 文档版本表
- **comments**: 评论表
- **notifications**: 通知表
- **document_locks**: 文档锁定表
- **document_resources**: 文档资源表
- **document_settings**: 文档设置表
- **document_operation_logs**: 操作日志表

详细的数据库结构请参考 [db-structure.sql](db-structure.sql)。

## API 文档

### 认证接口

```http
POST /api/auth/login          # 用户登录
POST /api/auth/register       # 用户注册
GET  /api/auth/me             # 获取当前用户信息
```

### 文档接口

```http
GET    /api/documents         # 获取文档列表
POST   /api/documents         # 创建文档
GET    /api/documents/{id}    # 获取文档详情
PUT    /api/documents/{id}    # 更新文档
DELETE /api/documents/{id}    # 删除文档
```

### 知识库接口

```http
GET    /api/knowledge-bases         # 获取知识库列表
POST   /api/knowledge-bases         # 创建知识库
GET    /api/knowledge-bases/{id}    # 获取知识库详情
PUT    /api/knowledge-bases/{id}    # 更新知识库
DELETE /api/knowledge-bases/{id}    # 删除知识库
```

### 协同编辑接口

```http
WebSocket /ws/collaboration/{documentId}  # 协同编辑 WebSocket 连接
```

## 开发指南

### 后端开发

1. **代码规范**
   - 遵循阿里巴巴 Java 开发手册
   - 使用 Lombok 简化代码
   - 统一异常处理
   - 统一返回结果格式

2. **分层架构**
   - Controller: 控制层，处理 HTTP 请求
   - Service: 服务层，业务逻辑处理
   - Mapper: 数据访问层，数据库操作
   - Entity: 实体类，对应数据库表
   - DTO: 数据传输对象

3. **安全机制**
   - JWT Token 认证
   - Spring Security 权限控制
   - 密码加密存储
   - XSS 防护

### 前端开发

1. **代码规范**
   - 使用 TypeScript 强类型
   - 遵循 Vue 3 Composition API
   - 组件化开发
   - 统一代码风格

2. **目录规范**
   - api: API 接口定义
   - components: 可复用组件
   - views: 页面组件
   - utils: 工具函数
   - types: 类型定义

3. **状态管理**
   - 使用 Pinia 进行状态管理
   - 模块化 Store 设计
   - 持久化存储用户信息

## 功能特性

### 协同编辑原理

LightDoc 使用 Yjs 作为协同编辑引擎，通过 WebSocket 实现实时同步：

1. **冲突解决**: Yjs 使用 CRDT（Conflict-free Replicated Data Types）算法自动解决编辑冲突
2. **实时同步**: WebSocket 连接保证低延迟的实时通信
3. **离线支持**: 本地存储编辑内容，网络恢复后自动同步
4. **版本快照**: 定期保存文档快照，支持版本回滚

### 文档导入导出

支持多种文档格式的导入和导出：

- **导入**: PDF、Word (.docx)、Markdown
- **导出**: PDF、HTML、Markdown
- **解析**: Apache Tika 自动识别文档格式

### 文件存储

支持多种文件存储方案：

- **MinIO**: 本地对象存储，适合私有化部署
- **阿里云 OSS**: 云端对象存储，适合生产环境
- **可扩展**: 支持扩展其他云存储服务

## 性能优化

### 后端优化
- Redis 缓存热点数据
- 数据库索引优化
- 分页查询优化
- 异步处理耗时操作

### 前端优化
- 路由懒加载
- 组件按需加载
- 图片懒加载
- 虚拟滚动优化长列表

## 安全措施

- JWT Token 认证机制
- Spring Security 权限控制
- 密码 BCrypt 加密
- SQL 注入防护
- XSS 攻击防护
- CSRF 防护
- 文件上传安全检查

## 测试

### 后端测试
```bash
cd lightdoc-master
mvn test
```

### 前端测试
```bash
cd lightdoc-vue
npm run test
```

## 部署建议

### 生产环境部署

1. **后端部署**
   - 使用 Docker 容器化部署
   - 配置 Nginx 反向代理
   - 启用 HTTPS
   - 配置日志收集

2. **前端部署**
   - 构建生产版本
   - 使用 Nginx 托管静态文件
   - 配置 CDN 加速
   - 启用 Gzip 压缩

3. **数据库部署**
   - MySQL 主从复制
   - Redis 哨兵模式
   - 定期数据备份

## 常见问题

### 1. 协同编辑连接失败
- 检查 WebSocket 连接配置
- 确认后端 WebSocket 服务正常运行
- 检查防火墙端口开放

### 2. 文件上传失败
- 检查 MinIO/OSS 配置
- 确认存储桶权限设置
- 检查文件大小限制

### 3. 登录 Token 失效
- 检查 JWT 配置
- 确认 Token 有效期设置
- 检查 Redis 连接状态

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进项目。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 联系方式

如有问题或建议，欢迎通过以下方式联系：

- 提交 Issue
- 发送邮件

## 致谢

感谢以下开源项目：

- [Spring Boot](https://spring.io/projects/spring-boot)
- [Vue.js](https://vuejs.org/)
- [Yjs](https://yjs.dev/)
- [Tiptap](https://tiptap.dev/)
- [Ant Design Vue](https://antdv.com/)
