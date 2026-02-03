# Echo Android 客户端系统架构设计

**版本**: 1.0.0  
**更新日期**: 2026-01-30  
**状态**: ✅ 已完善

---

## 1. 系统架构概览

Echo Android 客户端基于 Telegram 官方客户端开发，采用**单体控制器 + Fragment**架构模式。

### 四层架构模型

```
┌─────────────────────────────────────────────────────────────┐
│                      UI 层 (com.echo.ui)                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │
│  │  Activity   │ │  Fragment   │ │   Custom Views      │    │
│  │  (入口)      │ │  (页面)      │ │   (自定义组件)       │    │
│  └─────────────┘ └─────────────┘ └─────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                 业务控制器层 (com.iecho.messenger)            │
│  ┌──────────────────┐ ┌──────────────────┐ ┌────────────┐  │
│  │ MessagesController │ │ ContactsController │ │ ...更多    │  │
│  │   (消息管理)       │ │   (联系人管理)      │ │ Controllers│  │
│  └──────────────────┘ └──────────────────┘ └────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   网络通信层 (com.echo.tgnet)                │
│  ┌──────────────────┐ ┌──────────────────┐ ┌────────────┐  │
│  │ConnectionsManager │ │      TLRPC       │ │ MTProto    │  │
│  │   (连接管理)       │ │   (协议定义)      │ │ (加密协议)  │  │
│  └──────────────────┘ └──────────────────┘ └────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   数据持久层 (com.echo.SQLite)               │
│  ┌──────────────────┐ ┌──────────────────┐                 │
│  │   MessagesStorage │ │  SharedPreferences│                 │
│  │   (消息存储)       │ │   (配置存储)       │                 │
│  └──────────────────┘ └──────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 核心组件说明

### 2.1 Application 入口

| 类名 | 路径 | 职责 |
|------|------|------|
| `ApplicationLoader` | `com.iecho.messenger` | 应用启动入口，初始化全局资源 |
| `LaunchActivity` | `com.echo.ui` | 主 Activity，管理 Fragment 导航 |

### 2.2 核心 Controller（单例模式）

所有 Controller 继承自 `BaseController`，通过 `getInstance(accountNum)` 获取实例，支持多账户。

| Controller | 职责 | 代码行数 |
|------------|------|---------|
| `MessagesController` | 消息收发、会话管理、群组/频道操作 | 23,584 |
| `ContactsController` | 联系人同步、搜索、导入/导出 | ~3,000 |
| `NotificationsController` | 推送通知、消息提醒 | ~2,500 |
| `MediaController` | 音视频播放、媒体下载 | ~5,000 |
| `DownloadController` | 文件下载队列管理 | ~2,000 |
| `LocationController` | 位置共享、地理定位 | ~1,500 |

### 2.3 核心 Activity/Fragment

| 类名 | 职责 | 代码行数 |
|------|------|---------|
| `ChatActivity` | 聊天界面（最核心） | 44,581 |
| `DialogsActivity` | 会话列表 | ~8,000 |
| `ProfileActivity` | 个人/群组资料页 | ~6,000 |
| `LaunchActivity` | 启动页/主容器 | ~4,000 |

---

## 3. 数据流转机制

### 3.1 消息发送流程

```
┌──────────┐    ┌───────────────────┐    ┌──────────────────┐
│ ChatActivity │ →  │ SendMessagesHelper │ →  │ ConnectionsManager │
│  (用户输入)  │    │   (消息封装)        │    │   (网络发送)        │
└──────────┘    └───────────────────┘    └──────────────────┘
                                                    │
                                                    ▼
                                         ┌──────────────────┐
                                         │   Telegram 服务器  │
                                         └──────────────────┘
```

### 3.2 消息接收流程

```
┌──────────────────┐    ┌───────────────────┐    ┌──────────────┐
│ Telegram 服务器   │ →  │ ConnectionsManager │ →  │ MessagesController │
│                  │    │   (接收解密)        │    │   (处理分发)        │
└──────────────────┘    └───────────────────┘    └──────────────┘
                                                        │
                                                        ▼
                                            ┌────────────────────┐
                                            │  NotificationCenter │
                                            │    (事件广播)        │
                                            └────────────────────┘
                                                        │
                        ┌───────────────────────────────┼───────────────────────────────┐
                        ▼                               ▼                               ▼
                ┌──────────────┐              ┌──────────────┐              ┌──────────────┐
                │ ChatActivity  │              │MessagesStorage│              │Notifications │
                │  (UI 更新)    │              │  (本地存储)   │              │  (推送)      │
                └──────────────┘              └──────────────┘              └──────────────┘
```

---

## 4. 网络通信 (MTProto 协议)

### 4.1 协议特点

- **端到端加密**: Secret Chat 使用 MTProto 2.0
- **传输加密**: 所有通信使用 AES-256
- **消息确认**: 可靠投递机制
- **多数据中心**: 支持自动切换

### 4.2 核心类

| 类名 | 职责 |
|------|------|
| `ConnectionsManager` | 管理与服务器的连接 |
| `TLRPC` | 协议消息类型定义 |
| `NativeByteBuffer` | 高效二进制序列化 |
| `SerializedData` | 数据序列化/反序列化 |

---

## 5. 本地存储策略

### 5.1 存储类型

| 存储方式 | 用途 | 位置 |
|----------|------|------|
| SQLite | 消息、会话、联系人 | `/data/data/com.iecho.messenger/databases/` |
| SharedPreferences | 用户配置、设置 | `/data/data/com.iecho.messenger/shared_prefs/` |
| 文件系统 | 媒体缓存 | `/storage/emulated/0/Android/data/com.iecho.messenger/` |

### 5.2 核心存储类

| 类名 | 职责 |
|------|------|
| `MessagesStorage` | 消息和会话的数据库操作 |
| `UserConfig` | 用户配置持久化 |
| `SharedConfig` | 应用全局配置 |

---

## 6. 多账户支持机制

Echo 支持同时登录多个账户（最多 4 个）。

### 6.1 实现方式

```java
// Controller 获取实例时传入账户编号
MessagesController controller = MessagesController.getInstance(accountNum);

// 账户管理
UserConfig.getInstance(accountNum).isClientActivated();
```

### 6.2 账户隔离

- 每个账户有独立的 Controller 实例
- 每个账户有独立的数据库文件（后缀 `_accountN`）
- 共享：主题设置、语言设置

---

## 7. 线程模型

### 7.1 线程类型

| 线程 | 用途 |
|------|------|
| Main Thread | UI 渲染、用户交互 |
| `stageQueue` | 消息处理、业务逻辑 |
| `fileLoaderQueue` | 文件上传/下载 |
| `saveToGalleryQueue` | 媒体保存 |
| Native Thread | MTProto 网络通信（JNI） |

### 7.2 线程调度

```java
// 切换到主线程
AndroidUtilities.runOnUIThread(() -> {
    // UI 操作
});

// 切换到后台线程
Utilities.stageQueue.postRunnable(() -> {
    // 耗时操作
});
```

---

## 8. 与 Echo 服务端的交互

Echo Android 客户端连接 `echo-server-source` 服务端，通信流程：

```
┌────────────────┐          MTProto          ┌────────────────┐
│  Echo Android  │  ◄─────────────────────►  │   Echo Server  │
│    Client      │                           │ (echo-server-  │
│                │                           │    source)     │
└────────────────┘                           └────────────────┘
```

### 服务端配置

在客户端中配置服务器地址（参见部署文档）：
- `native-lib.cpp` 中的 DC 配置
- `BuildVars.java` 中的 APP_ID 和 APP_HASH

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-01-30 | 初始版本，基于 Telegram 源码分析 |
