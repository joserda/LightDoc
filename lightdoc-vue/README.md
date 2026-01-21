# LightDoc Vue 前端项目

基于 Vue3 + TypeScript + Vite 的在线文档协同编辑平台前端。

## 技术栈

- **框架**: Vue 3.4 + TypeScript
- **构建工具**: Vite 5.0
- **路由**: Vue Router 4.2
- **状态管理**: Pinia 2.1
- **UI 组件库**: Ant Design Vue 4.1
- **HTTP 客户端**: Axios 1.6
- **图标**: @ant-design/icons-vue

## 项目结构

```
lightdoc-vue/
├── src/
│   ├── api/                 # API 接口
│   │   └── auth.ts         # 认证相关 API
│   ├── assets/              # 静态资源
│   ├── components/          # 公共组件
│   ├── router/              # 路由配置
│   │   └── index.ts        # 路由定义
│   ├── types/               # TypeScript 类型定义
│   │   └── index.ts        # 全局类型
│   ├── utils/               # 工具函数
│   │   ├── request.ts      # Axios 封装
│   │   └── storage.ts      # 本地存储工具
│   ├── views/               # 页面组件
│   │   ├── auth/           # 认证页面
│   │   │   ├── Login.vue   # 登录页
│   │   │   └── Register.vue # 注册页
│   │   └── home/           # 首页
│   │       └── Index.vue   # 主页
│   ├── App.vue             # 根组件
│   └── main.ts             # 入口文件
├── .env.development        # 开发环境变量
├── .env.production         # 生产环境变量
├── index.html              # HTML 模板
├── package.json            # 依赖配置
├── tsconfig.json           # TypeScript 配置
├── vite.config.ts          # Vite 配置
└── README.md               # 项目说明
```

## 页面功能

### 1. 登录页 (`/login`)
- 用户名/密码登录
- 表单验证
- 跳转注册页链接
- JWT Token 存储

### 2. 注册页 (`/register`)
- 用户名、邮箱、密码输入
- 密码确认验证
- 表单验证
- 跳转登录页链接

### 3. 首页 (`/`)
- 左侧导航菜单（我的文档、共享文档、收藏、回收站）
- 顶部搜索栏
- 文档列表/网格视图切换
- 新建文档功能
- 用户下拉菜单（个人设置、退出登录）
- 文档操作（分享、收藏、更多）

## 开发环境配置

### 环境变量

`.env.development`:
```
VITE_API_BASE_URL=http://localhost:8080/api
```

`.env.production`:
```
VITE_API_BASE_URL=/api
```

### API 接口约定

前端期望后端提供以下接口：

```typescript
// 登录
POST /api/auth/login
Request: { username: string, password: string }
Response: { code: number, message: string, data: { token: string, user: User } }

// 注册
POST /api/auth/register
Request: { username: string, email: string, password: string, confirmPassword: string }
Response: { code: number, message: string, data: any }

// 获取当前用户
GET /api/auth/me
Response: { code: number, message: string, data: User }
```

## 运行项目

### 安装依赖

```bash
cd lightdoc-vue
npm install
```

### 开发模式

```bash
npm run dev
```

项目将在 `http://localhost:3000` 运行。

### 构建生产版本

```bash
npm run build
```

### 预览生产版本

```bash
npm run preview
```

## 主要功能特性

1. **响应式设计**: 适配不同屏幕尺寸
2. **路由守卫**: 未登录用户自动跳转登录页
3. **请求拦截**: 自动添加 JWT Token
4. **错误处理**: 统一的错误提示
5. **加载状态**: 按钮加载状态管理
6. **表单验证**: 使用 Ant Design Vue 的表单验证
7. **本地存储**: Token 和用户信息本地存储

## 后续开发建议

1. **文档编辑功能**: 集成 Tiptap + Yjs 实现协同编辑
2. **文档管理**: 实现文档的 CRUD 操作
3. **权限管理**: 细化文档权限控制
4. **实时协作**: 添加 WebSocket 实时同步
5. **版本控制**: 实现文档版本管理
6. **评论系统**: 添加文档评论功能
7. **文件上传**: 集成 OSS/MinIO 文件存储
