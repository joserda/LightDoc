# Light-Doc 数据库 ER 图

```mermaid
graph TD
    %% 实体（矩形）
    User["用户"]
    Document["文档"]
    Version["版本"]
    Permission["权限"]
    Notification["通知"]
    Resource["资源"]
    Minio["MinIO存储"]

    %% 属性（椭圆）
    UserId["id"]
    Username["username"]
    Email["email"]
    DocId["id"]
    Title["title"]
    Content["content"]
    CreatorId["creatorId"]
    VersionId["id"]
    DocVersion["version"]
    SnapshotKey["snapshotKey"]
    PermId["id"]
    UserIdPerm["userId"]
    DocIdPerm["documentId"]
    Role["role"]
    NotifId["id"]
    UserIdNotif["userId"]
    DocIdNotif["documentId"]
    ResourceId["id"]
    ResourceName["name"]
    StorageKey["storageKey"]
    MinioKey["key"]
    MinioContent["content"]

    %% 关系（菱形）
    Creates["创建"]
    HasVersion["包含版本"]
    HasPermission["授予权限"]
    Generates["生成通知"]
    Contains["包含资源"]
    StoresVersion["存储版本"]
    StoresResource["存储资源"]

    %% 连接实体与属性
    UserId --- User
    Username --- User
    Email --- User
    
    DocId --- Document
    Title --- Document
    Content --- Document
    CreatorId --- Document
    
    VersionId --- Version
    DocVersion --- Version
    SnapshotKey --- Version
    
    PermId --- Permission
    UserIdPerm --- Permission
    DocIdPerm --- Permission
    Role --- Permission
    
    NotifId --- Notification
    UserIdNotif --- Notification
    DocIdNotif --- Notification
    
    ResourceId --- Resource
    ResourceName --- Resource
    StorageKey --- Resource
    
    MinioKey --- Minio
    MinioContent --- Minio

    %% 连接实体与关系
    User -- "1" --> Creates
    Creates -- "n" --> Document
    
    Document -- "1" --> HasVersion
    HasVersion -- "n" --> Version
    
    Document -- "1" --> HasPermission
    HasPermission -- "n" --> Permission
    
    User -- "1" --> Permission
    
    Document -- "1" --> Generates
    Generates -- "n" --> Notification
    
    User -- "1" --> Notification
    
    Document -- "1" --> Contains
    Contains -- "n" --> Resource
    
    Version -- "1" --> StoresVersion
    StoresVersion -- "1" --> Minio
    
    Resource -- "1" --> StoresResource
    StoresResource -- "1" --> Minio

    %% 底部空白
    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    Minio --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

## 核心ER图说明

### 实体（Entities）
- **用户**：系统用户
- **文档**：协同文档
- **版本**：文档历史版本
- **权限**：用户对文档的访问权限
- **通知**：系统通知消息
- **资源**：文档附件
- **MinIO存储**：存储文档快照和资源

### 核心关系
- **用户 - 文档**：1:N（用户创建多个文档）
- **文档 - 版本**：1:N（文档有多个版本）
- **文档 - 权限**：1:N（文档授予多个权限）
- **用户 - 权限**：1:N（用户拥有多个权限）
- **文档 - 通知**：1:N（文档生成多个通知）
- **用户 - 通知**：1:N（用户接收多个通知）
- **文档 - 资源**：1:N（文档包含多个资源）
- **版本 - MinIO**：1:1（版本存储在MinIO）
- **资源 - MinIO**：1:1（资源存储在MinIO）

### 存储说明
- **MySQL**：存储结构化数据（用户、文档、版本、权限、通知）
- **MinIO**：存储非结构化数据（文档快照、文件资源）
- **Redis**：存储在线状态、消息队列等临时数据（未在ER图中体现）

---

# Light-Doc 系统框架图

```mermaid
flowchart TD
    subgraph 外部层
        A["用户 前端"]
    end

    subgraph 应用服务层
        B1["认证服务<br/>AuthController"]
        B2["文档服务<br/>DocumentController"]
        B3["协同服务<br/>CollabSessionManager"]
        B4["通知服务<br/>NotificationController"]
        B5["权限服务<br/>DocumentInviteService"]
    end

    subgraph 业务逻辑层
        C1["UserService"]
        C2["DocumentService"]
        C3["CollaborationService"]
        C4["NotificationService"]
        C5["PermissionService"]
    end

    subgraph 存储层
        D1["MySQL<br/>用户/文档/权限/通知"]
        D2["Redis<br/>在线状态/消息广播"]
        D3["MinIO<br/>Yjs快照/资源"]
    end

    A --> B1
    A --> B2
    A --> B3
    A --> B4
    A --> B5

    B1 --> C1
    B2 --> C2
    B3 --> C3
    B4 --> C4
    B5 --> C5

    C1 --> D1
    C2 --> D1
    C2 --> D3
    C3 --> D1
    C3 --> D2
    C4 --> D1
    C4 --> D2
    C5 --> D1

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    D3 --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0

    classDef outer fill:#f9f,stroke:#333,stroke-width:2px
    classDef service fill:#bbf,stroke:#333,stroke-width:1px
    classDef logic fill:#bfb,stroke:#333,stroke-width:1px
    classDef storage fill:#fbb,stroke:#333,stroke-width:1px

    class A outer
    class B1,B2,B3,B4,B5 service
    class C1,C2,C3,C4,C5 logic
    class D1,D2,D3 storage
```

## 框架说明

| 层次 | 组件 | 职责 |
|------|------|------|
| **外部层** | 用户前端 | 与用户交互的界面 |
| **应用服务层** | 各控制器 | 处理HTTP/WebSocket请求 |
| **业务逻辑层** | 各服务 | 实现核心业务逻辑 |
| **存储层** | MySQL/Redis/MinIO | 数据持久化与缓存 |

## 核心技术栈

- **前端**：可能使用React/Vue等框架
- **后端**：Spring Boot + Java
- **存储**：MySQL + Redis + MinIO
- **实时通信**：WebSocket + Redis Pub/Sub
- **协同编辑**：Yjs CRDT

该框架图简洁展示了系统的整体结构和各组件间的关系，便于理解系统架构。

---

# Light-Doc 核心数据流图 (DFD)

---

## 1. 用户认证数据流

```mermaid
flowchart TB
    subgraph EA[外部层]
        A["用户 前端"]
    end

    subgraph SVC[认证服务]
        B["AuthController<br/>/auth/login"]
        C["AuthenticationManager"]
        D["UserService"]
        E["JwtUtil"]
    end

    subgraph DS[数据存储]
        F["(MySQL<br/>users表)"]
    end

    A -->|"登录请求<br/>username, password"| B
    B --> C
    C --> D
    D -->|"查询用户"| F
    D -->|"验证密码"| F
    F -->|"用户数据"| D
    D --> E
    E -->|"生成Token"| G
    G["返回token<br/>userInfo"]
    G --> A

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    G --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 2. 协同编辑数据流 (核心)

```mermaid
flowchart TB
    subgraph EA[外部层]
        A["用户A 前端"]
        B["用户B 前端"]
    end

    subgraph SVC[协同服务]
        C["CollaborationSessionManager<br/>WebSocket端点"]
        D["CollaborationMessageHandler<br/>消息处理"]
        E["CollaborationService<br/>权限验证"]
    end

    subgraph DS[存储层]
        F["(MySQL<br/>文档权限)"]
        G["(Redis<br/>在线状态)"]
        H["Redis Pub/Sub<br/>collab:doc:{id}"]
    end

    A -->|"Yjs更新<br/>yjs_update"| C
    C --> D
    D --> E
    E -->|"验证权限"| F
    D -->|"广播"| H
    H -->|"推送Yjs更新"| B
    B -->|"sync_step2<br/>sync_update"| C

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    B --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 3. 文档管理数据流

```mermaid
flowchart LR
    subgraph EA[外部层]
        A["用户 前端"]
    end

    subgraph SVC[服务层]
        B["DocumentController"]
        C["DocumentService"]
        D["DocumentServiceImpl"]
    end

    subgraph DS[存储层]
        E["(MySQL<br/>documents)"]
        F["(MySQL<br/>permissions)"]
        G["(MySQL<br/>versions)"]
        H["(MinIO<br/>snapshots)"]
        I["(MinIO<br/>resources)"]
    end

    A -->|"DocDTO<br/>title, content"| B
    B --> C
    C --> D
    D -->|"CRUD"| E
    D -->|"权限检查"| F
    D -->|"版本记录"| G
    D -->|"Yjs快照"| H
    D -->|"资源存储"| I

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    I --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 4. 文档版本管理数据流

```mermaid
flowchart TB
    subgraph EA[外部层]
        A["用户 前端"]
    end

    subgraph SVC[服务层]
        B["DocumentVersionController"]
        C["DocumentVersionService"]
        D["YjsDocumentManager<br/>快照管理"]
    end

    subgraph DS[存储层]
        E["(MySQL<br/>versions)"]
        F["(MinIO<br/>snapshots)"]
    end

    A -->|"保存版本请求<br/>documentId, snapshot"| B
    B --> C
    C --> D
    C -->|"版本记录"| E
    D -->|"快照文件"| F
    E -->|"版本列表"| A
    F -->|"加载快照"| A

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    F --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 5. 通知消息数据流

```mermaid
flowchart LR
    subgraph EA[外部层]
        A["用户A 前端"]
        B["用户B 前端"]
    end

    subgraph SVC[服务层]
        C["NotificationController"]
        D["NotificationService"]
    end

    subgraph DS[存储层]
        E["(MySQL<br/>notifications)"]
        F["Redis Publisher"]
        G["Redis Pub/Sub"]
        H["CollaborationSessionManager<br/>WebSocket推送"]
    end

    A -->|"通知请求<br/>type, content"| C
    C --> D
    D -->|"存储通知"| E
    D -->|"发布消息"| F
    F --> G
    G -->|"实时推送"| H
    H -->|"WebSocket"| B

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    B --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 6. 邀请协作者数据流

```mermaid
flowchart TB
    subgraph EA[外部层]
        A["文档所有者 前端"]
        B["被邀请人 前端"]
    end

    subgraph SVC[服务层]
        C["DocumentInviteController"]
        D["DocumentInviteService"]
        E["NotificationService"]
    end

    subgraph DS[存储层]
        F["(MySQL<br/>invitations)"]
        G["(MySQL<br/>permissions)"]
        H["(MySQL<br/>notifications)"]
    end

    A -->|"邀请请求<br/>inviteeEmail, docId"| C
    C --> D
    D -->|"验证权限"| F
    D -->|"创建邀请"| F
    D -->|"发送通知"| E
    E -->|"通知记录"| H
    F -->|"邀请链接"| B
    B -->|"接受邀请"| G
    G -->|"权限记录"| G

    subgraph SPACER[" "]
        S1[" "]
        S2[" "]
        S3[" "]
        S4[" "]
    end
    G --> S1
    S1 --> S2
    S2 --> S3
    S3 --> S4
    style SPACER fill-opacity:0,border-opacity:0
    style S1 fill-opacity:0,border-opacity:0
    style S2 fill-opacity:0,border-opacity:0
    style S3 fill-opacity:0,border-opacity:0
    style S4 fill-opacity:0,border-opacity:0
```

---

## 顶层数据流全景图 (Context Diagram)

```mermaid
flowchart LR
    subgraph USER[外部实体]
        U["用户 前端"]
    end

    subgraph SYS[Light-Doc系统]
        subgraph AUTH[认证服务]
            A1["AuthController"]
            A2["UserService"]
        end

        subgraph DOC[文档服务]
            B1["DocumentController"]
            B2["DocumentService"]
        end

        subgraph COLLAB[协同服务]
            C1["CollabSessionManager"]
            C2["CollabMessageHandler"]
        end

        subgraph NOTIF[通知服务]
            D1["NotificationController"]
            D2["NotificationService"]
        end

        subgraph PERM[权限服务]
            E1["DocumentInviteService"]
            E2["PermissionService"]
        end

        subgraph STORAGE[存储层]
            S1["MySQL<br/>用户表"]
            S2["MySQL<br/>文档表"]
            S3["Redis<br/>协作状态"]
            S4["MinIO<br/>快照"]
            S5["MySQL<br/>通知表"]
        end
    end

    U -->|"1.登录"| A1
    A1 --> S1
    A2 --> S1

    U -->|"2.文档CRUD"| B1
    B2 --> S2
    B2 --> S4

    U -->|"3.协同编辑"| C1
    C2 --> S3

    U -->|"4.发送通知"| D1
    D2 --> S5
    D2 --> S3

    U -->|"5.邀请协作"| E1
    E2 --> S2
    E2 --> S5

    subgraph SPACER[" "]
        SP1[" "]
        SP2[" "]
        SP3[" "]
        SP4[" "]
    end
    S5 --> SP1
    SP1 --> SP2
    SP2 --> SP3
    SP3 --> SP4
    style SPACER fill-opacity:0,border-opacity:0
    style SP1 fill-opacity:0,border-opacity:0
    style SP2 fill-opacity:0,border-opacity:0
    style SP3 fill-opacity:0,border-opacity:0
    style SP4 fill-opacity:0,border-opacity:0
```

---
