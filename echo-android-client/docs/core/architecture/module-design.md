# Echo Android 客户端模块设计

**版本**: 1.0.0  
**更新日期**: 2026-01-30  
**状态**: ✅ 已完善

---

## 1. 模块划分

Echo Android 客户端代码组织在 `com.echo` 包下，主要分为以下模块：

```
com.echo/
├── messenger/         # 业务逻辑层（Controller + Helper）
├── ui/                # UI 层（Activity + Fragment + View）
├── tgnet/             # 网络通信层（MTProto 协议）
├── SQLite/            # 数据持久层
└── PhoneFormat/       # 电话号码格式化工具
```

---

## 2. 核心 Controller 职责表

### 2.1 消息与通信

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `MessagesController` | 消息收发、会话管理、群组/频道操作 | `sendMessage()`, `loadMessages()`, `deleteMessages()` |
| `SendMessagesHelper` | 消息发送封装 | `sendMessage()`, `sendMedia()` |
| `SecretChatHelper` | 端对端加密聊天 | `sendSecretMessage()`, `acceptSecretChat()` |

### 2.2 联系人与用户

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `ContactsController` | 联系人同步与管理 | `syncContacts()`, `searchContacts()` |
| `UserConfig` | 当前用户配置 | `getCurrentUser()`, `saveConfig()` |

### 2.3 媒体处理

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `MediaController` | 音视频播放控制 | `playMessage()`, `pauseMessage()` |
| `MediaDataController` | 贴纸、GIF、表情管理 | `loadStickers()`, `searchGifs()` |
| `DownloadController` | 文件下载队列 | `downloadFile()`, `cancelDownload()` |
| `ImageLoader` | 图片加载与缓存 | `getImageFromMemory()`, `loadImage()` |

### 2.4 通知与推送

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `NotificationsController` | 本地通知管理 | `showNotification()`, `cancelNotification()` |
| `PushListenerController` | Firebase/HMS 推送 | `onMessageReceived()` |

### 2.5 位置与设备

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `LocationController` | 位置共享 | `shareLocation()`, `stopShareLocation()` |
| `FingerprintController` | 生物识别 | `authenticate()` |

### 2.6 本地化与配置

| Controller | 职责 | 核心方法 |
|------------|------|----------|
| `LocaleController` | 多语言支持 | `applyLanguage()`, `getString()` |
| `SharedConfig` | 全局配置 | `save()`, `load()` |

---

## 3. 模块依赖关系

```
┌─────────────────────────────────────────────────────────────────┐
│                           UI 层                                 │
│   ChatActivity, DialogsActivity, ProfileActivity, ...          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     业务控制器层                                 │
│   MessagesController, ContactsController, MediaController, ... │
└─────────────────────────────────────────────────────────────────┘
                              │
               ┌──────────────┼──────────────┐
               ▼              ▼              ▼
        ┌───────────┐  ┌───────────┐  ┌───────────┐
        │  tgnet    │  │  SQLite   │  │  工具类    │
        │ (网络)    │  │ (存储)    │  │ (Utilities)│
        └───────────┘  └───────────┘  └───────────┘
```

### 依赖规则

1. **UI → Controller**: UI 层依赖 Controller 层，不直接访问存储或网络
2. **Controller → tgnet/SQLite**: Controller 可以同时访问网络和存储
3. **禁止反向依赖**: Controller 不应依赖特定 UI 组件

---

## 4. 事件通信机制

Echo 使用 `NotificationCenter` 实现模块间解耦通信。

### 4.1 事件发布

```java
// 发布事件
NotificationCenter.getInstance(currentAccount).postNotificationName(
    NotificationCenter.messagesDidLoad,
    dialogId,
    messages
);
```

### 4.2 事件订阅

```java
// 订阅事件
NotificationCenter.getInstance(currentAccount).addObserver(this, 
    NotificationCenter.messagesDidLoad);

// 处理事件
@Override
public void didReceivedNotification(int id, int account, Object... args) {
    if (id == NotificationCenter.messagesDidLoad) {
        long dialogId = (Long) args[0];
        ArrayList<MessageObject> messages = (ArrayList<MessageObject>) args[1];
        // 更新 UI
    }
}
```

### 4.3 常用事件列表

| 事件 ID | 触发场景 |
|---------|----------|
| `messagesDidLoad` | 消息加载完成 |
| `updateInterfaces` | 需要刷新 UI |
| `dialogsNeedReload` | 会话列表需刷新 |
| `contactsDidLoad` | 联系人加载完成 |
| `mediaDidLoad` | 媒体加载完成 |

---

## 5. 扩展指南

### 5.1 添加新的 Controller

1. **创建 Controller 类**
```java
// ECHO-FEATURE-XXX: 新功能 Controller
public class NewFeatureController extends BaseController {
    
    private static final NewFeatureController[] Instance = 
        new NewFeatureController[UserConfig.MAX_ACCOUNT_COUNT];
    
    public static NewFeatureController getInstance(int num) {
        NewFeatureController localInstance = Instance[num];
        if (localInstance == null) {
            synchronized (NewFeatureController.class) {
                localInstance = Instance[num];
                if (localInstance == null) {
                    Instance[num] = localInstance = new NewFeatureController(num);
                }
            }
        }
        return localInstance;
    }
    
    public NewFeatureController(int num) {
        super(num);
    }
    
    // 添加业务方法
}
```

2. **在 `NotificationCenter` 中注册新事件**
```java
// NotificationCenter.java
public static final int newFeatureDataLoaded = totalEvents++;
```

3. **创建变更记录**
   - 按照 `docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md` 模板创建记录

### 5.2 添加新的 UI 页面

1. **创建 Fragment 类**
```java
// ECHO-FEATURE-XXX: 新页面
public class NewFeatureActivity extends BaseFragment {
    
    @Override
    public View createView(Context context) {
        // 创建布局
        return fragmentView;
    }
    
    @Override
    public void onFragmentDestroy() {
        super.onFragmentDestroy();
        // 清理资源
    }
}
```

2. **添加导航入口**（在相关 Activity 中）

3. **创建变更记录**

---

## 6. 关键工具类

| 类名 | 职责 |
|------|------|
| `AndroidUtilities` | Android 平台工具（dp 转换、线程切换等） |
| `Utilities` | 通用工具（加密、随机数等） |
| `FileLog` | 日志记录 |
| `BuildVars` | 构建配置（DEBUG 模式、APP_ID 等） |

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-01-30 | 初始版本，基于 Telegram 源码分析 |
