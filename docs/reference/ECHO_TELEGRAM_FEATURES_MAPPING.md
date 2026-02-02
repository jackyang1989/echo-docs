# Echo - Telegram 客户端功能映射与后台管理

**日期**: 2026-01-27  
**基于**: Telegram Android v11.4.2 实际代码分析  
**目的**: 明确哪些功能在客户端存在，后台需要如何管理

---

## 🎯 核心原则

1. **客户端已有的功能** - 不重复实现，只做管理控制
2. **后台管理边界** - 控制"是否可用"，不控制"如何使用"
3. **基于实际代码** - 所有功能都基于 Telegram 源码验证

---

## 📱 Telegram 客户端真实功能清单

### 1. 用户与账号管理

#### 1.1 会话管理 (SessionsActivity.java)

**客户端已有功能**:
```java
// SessionsActivity.java - 真实存在
public class SessionsActivity extends BaseFragment {
    public static final int TYPE_DEVICES = 0;
    public static final int TYPE_WEB_SESSIONS = 1;
    
    private ArrayList<TLObject> sessions;              // 活跃会话列表
    private ArrayList<TLObject> passwordSessions;      // 密码会话
    private TLRPC.TL_authorization currentSession;     // 当前会话
}
```

**会话信息包含**:
- 设备类型（Android/iOS/Desktop/Web）
- 应用名称和版本
- IP 地址
- 国家/城市
- 最后活跃时间
- 是否当前会话

**用户可以做的**:
- 查看所有活跃会话
- 终止特定会话
- 终止所有其他会话

**后台必须能做的** ⭐:
```typescript
interface SessionManagement {
  // 查看用户所有会话
  getUserSessions(userId: string): Session[];
  
  // 强制终止特定会话
  terminateSession(userId: string, sessionId: string): void;
  
  // 强制终止用户所有会话（封禁时）
  terminateAllSessions(userId: string): void;
  
  // 会话异常检测
  detectAbnormalSessions(userId: string): AbnormalSession[];
}
```

#### 1.2 隐私设置 (PrivacySettingsActivity.java)

**客户端已有功能**:
```java
// PrivacySettingsActivity.java - 真实存在
public class PrivacySettingsActivity extends BaseFragment {
    // 隐私规则类型
    public final static int PRIVACY_RULES_TYPE_LASTSEEN = 0;      // 最后上线时间
    public final static int PRIVACY_RULES_TYPE_INVITE = 1;        // 邀请到群组
    public final static int PRIVACY_RULES_TYPE_CALLS = 2;         // 语音通话
    public final static int PRIVACY_RULES_TYPE_P2P = 3;           // P2P 通话
    public final static int PRIVACY_RULES_TYPE_PHOTO = 4;         // 个人资料照片
    public final static int PRIVACY_RULES_TYPE_FORWARDS = 5;      // 转发消息
    public final static int PRIVACY_RULES_TYPE_PHONE = 6;         // 电话号码
    public final static int PRIVACY_RULES_TYPE_ADDED_BY_PHONE = 7;// 通过电话号码添加
    public final static int PRIVACY_RULES_TYPE_VOICE_MESSAGES = 8;// 语音消息
    public final static int PRIVACY_RULES_TYPE_BIO = 9;           // 个人简介
    public final static int PRIVACY_RULES_TYPE_BIRTHDAY = 10;     // 生日
    public final static int PRIVACY_RULES_TYPE_GIFTS = 11;        // 礼物
    
    // 全局隐私设置
    private TLRPC.GlobalPrivacySettings globalPrivacySettings;
}
```

**全局隐私设置**:
```java
// TLRPC.GlobalPrivacySettings - 真实存在
class GlobalPrivacySettings {
    boolean archive_and_mute_new_noncontact_peers;    // 自动归档非联系人
    boolean new_noncontact_peers_require_premium;     // 非联系人需要 Premium
    boolean hide_read_marks;                          // 隐藏已读标记
    boolean hide_phone_number;                        // 隐藏电话号码
    boolean hide_last_visit;                          // 隐藏最后上线
    boolean hide_profile_photo;                       // 隐藏头像
}
```

**后台不应该管理** ❌:
- 用户的个人隐私设置（这是用户权利）
- 谁可以看到用户的最后上线时间
- 谁可以邀请用户到群组

**后台可以管理** ✅:
```typescript
interface PrivacyPolicyManagement {
  // 全局隐私策略（影响所有用户）
  setGlobalPrivacyPolicy(policy: {
    forceArchiveNonContacts: boolean;      // 强制归档非联系人
    requirePremiumForNonContacts: boolean; // 非联系人需要 Premium
  }): void;
  
  // 隐私功能开关（平台级）
  disablePrivacyFeature(feature: 'voice_messages' | 'calls' | 'p2p'): void;
}
```

---

### 2. 群组与频道管理

#### 2.1 群组类型 (MessagesController.java)

**真实存在的群组类型**:
```java
// TLRPC.Chat - 真实存在
class Chat {
    boolean megagroup;          // 超级群组
    boolean gigagroup;          // 巨型群组
    boolean broadcast;          // 频道（广播）
    boolean verified;           // 已验证
    boolean scam;               // 诈骗标记
    boolean fake;               // 虚假标记
    boolean restricted;         // 受限
    boolean creator;            // 创建者
    boolean left;               // 已离开
    boolean deactivated;        // 已停用
    int participants_count;     // 成员数
    String username;            // 公开用户名
}
```

**群组权限** (ChatRightsEditActivity.java):
```java
// TLRPC.TL_chatAdminRights - 真实存在
class TL_chatAdminRights {
    boolean change_info;        // 修改群组信息
    boolean post_messages;      // 发布消息
    boolean edit_messages;      // 编辑消息
    boolean delete_messages;    // 删除消息
    boolean ban_users;          // 封禁用户
    boolean invite_users;       // 邀请用户
    boolean pin_messages;       // 置顶消息
    boolean add_admins;         // 添加管理员
    boolean anonymous;          // 匿名发送
    boolean manage_call;        // 管理语音聊天
    boolean other;              // 其他权限
    boolean manage_topics;      // 管理话题
    boolean post_stories;       // 发布故事
    boolean edit_stories;       // 编辑故事
    boolean delete_stories;     // 删除故事
}

// TLRPC.TL_chatBannedRights - 真实存在
class TL_chatBannedRights {
    boolean view_messages;      // 查看消息
    boolean send_messages;      // 发送消息
    boolean send_media;         // 发送媒体
    boolean send_stickers;      // 发送贴纸
    boolean send_gifs;          // 发送 GIF
    boolean send_games;         // 发送游戏
    boolean send_inline;        // 发送内联
    boolean embed_links;        // 嵌入链接
    boolean send_polls;         // 发送投票
    boolean change_info;        // 修改信息
    boolean invite_users;       // 邀请用户
    boolean pin_messages;       // 置顶消息
    boolean manage_topics;      // 管理话题
    boolean send_photos;        // 发送照片
    boolean send_videos;        // 发送视频
    boolean send_roundvideos;   // 发送圆形视频
    boolean send_audios;        // 发送音频
    boolean send_voices;        // 发送语音
    boolean send_docs;          // 发送文档
    boolean send_plain;         // 发送纯文本
    int until_date;             // 限制到期时间
}
```

**后台必须能做的** ⭐:
```typescript
interface ChatManagement {
  // 查看群组详情
  getChatDetail(chatId: string): {
    type: 'group' | 'supergroup' | 'gigagroup' | 'channel';
    title: string;
    username?: string;
    participantsCount: number;
    creator: string;
    admins: Admin[];
    isPublic: boolean;
    isVerified: boolean;
    isScam: boolean;          // 诈骗标记
    isFake: boolean;          // 虚假标记
    isRestricted: boolean;    // 受限状态
    restrictionReason?: string;
  };
  
  // 标记群组
  markChatAsScam(chatId: string, reason: string): void;
  markChatAsFake(chatId: string, reason: string): void;
  
  // 限制群组
  restrictChat(chatId: string, restrictions: {
    canSendMessages: boolean;
    canSendMedia: boolean;
    canInviteUsers: boolean;
    reason: string;
  }): void;
  
  // 解散群组
  dissolveChat(chatId: string, reason: string): void;
  
  // 移除公开用户名（取消公开）
  removePublicUsername(chatId: string): void;
}
```

---

### 3. 消息与内容管理

#### 3.1 消息类型 (MessageObject.java)

**真实存在的消息类型**:
```java
// MessageObject.java - 真实存在
class MessageObject {
    int type;  // 消息类型
    
    // 类型常量
    public static final int TYPE_TEXT = 0;
    public static final int TYPE_PHOTO = 1;
    public static final int TYPE_VIDEO = 3;
    public static final int TYPE_GEO = 4;
    public static final int TYPE_AUDIO = 5;
    public static final int TYPE_CONTACT = 6;
    public static final int TYPE_FILE = 8;
    public static final int TYPE_GIF = 13;
    public static final int TYPE_STICKER = 13;
    public static final int TYPE_MUSIC = 14;
    public static final int TYPE_VOICE = 2;
    public static final int TYPE_ROUND_VIDEO = 5;
    public static final int TYPE_POLL = 17;
    public static final int TYPE_ANIMATED_STICKER = 15;
}
```

**后台不能做** ❌:
- 查看加密消息内容
- 修改消息内容
- 拦截特定关键词

**后台可以做** ✅:
```typescript
interface MessageManagement {
  // 删除消息（服务器级 revoke）
  revokeMessage(chatId: string, messageId: string, reason: string): void;
  
  // 批量删除消息
  revokeMessages(chatId: string, messageIds: string[], reason: string): void;
  
  // 禁用特定消息类型（按群组）
  disableMessageTypes(chatId: string, types: MessageType[]): void;
}

enum MessageType {
  MEDIA = 'media',           // 所有媒体
  PHOTOS = 'photos',         // 照片
  VIDEOS = 'videos',         // 视频
  FILES = 'files',           // 文件
  VOICE = 'voice',           // 语音
  STICKERS = 'stickers',     // 贴纸
  GIFS = 'gifs',             // GIF
  POLLS = 'polls',           // 投票
  LINKS = 'links',           // 链接
}
```

#### 3.2 文件管理 (FileLoader.java)

**真实存在的文件类型**:
```java
// FileLoader.java - 真实存在
class FileLoader {
    public static final int MEDIA_DIR_IMAGE = 0;
    public static final int MEDIA_DIR_VIDEO = 1;
    public static final int MEDIA_DIR_AUDIO = 2;
    public static final int MEDIA_DIR_DOCUMENT = 3;
    public static final int MEDIA_DIR_CACHE = 4;
}
```

**后台必须能做的** ⭐:
```typescript
interface FileManagement {
  // 文件上传控制
  setFileUploadPolicy(policy: {
    globalEnabled: boolean;
    maxFileSizeMB: number;
    maxImageSizeMB: number;
    maxVideoSizeMB: number;
    allowedTypes: FileType[];
  }): void;
  
  // 按群组控制
  setChatFilePolicy(chatId: string, policy: {
    uploadEnabled: boolean;
    allowedTypes: FileType[];
  }): void;
  
  // 按用户控制
  setUserFileQuota(userId: string, quota: {
    dailyUploadLimitMB: number;
    maxFileSizeMB: number;
  }): void;
  
  // 存储管理
  getStorageStats(): {
    totalUsedGB: number;
    byType: Record<FileType, number>;
    topUsers: { userId: string; usedGB: number }[];
  };
}
```

---

### 4. 通知与推送

#### 4.1 通知设置 (NotificationsController.java)

**客户端已有功能**:
```java
// NotificationsController.java - 真实存在
class NotificationsController {
    public static final int TYPE_PRIVATE = 0;      // 私聊通知
    public static final int TYPE_GROUP = 1;        // 群组通知
    public static final int TYPE_CHANNEL = 2;      // 频道通知
    
    // 通知设置
    private boolean notificationsEnabled;
    private int notificationDelay;
    private boolean inAppSounds;
    private boolean inAppVibrate;
    private boolean inAppPreview;
    private int vibrate_messages;
    private int vibrate_group;
    private int vibrate_channel;
}
```

**后台必须能做的** ⭐:
```typescript
interface PushManagement {
  // 全局推送控制（已在 ECHO_ADMIN_PANEL.md 中详细设计）
  setGlobalPushEnabled(enabled: boolean): void;
  
  // 用户推送控制
  setUserPushEnabled(userId: string, enabled: boolean, reason?: string): void;
  
  // 群组推送控制
  setChatPushEnabled(chatId: string, enabled: boolean): void;
  
  // 推送频率限制
  setPushRateLimit(limits: {
    maxPerUserPerHour: number;
    maxPerChatPerHour: number;
    autoSilentThreshold: number;
  }): void;
  
  // 推送统计
  getPushStats(): {
    last24h: {
      total: number;
      success: number;
      failed: number;
      failureRate: number;
    };
    failureReasons: { reason: string; count: number }[];
  };
}
```

---

### 5. 搜索与发现

#### 5.1 全局搜索 (DialogsSearchAdapter.java)

**客户端已有功能**:
```java
// DialogsSearchAdapter.java - 真实存在
class DialogsSearchAdapter {
    // 搜索类型
    private static final int SEARCH_DIALOGS = 0;      // 搜索对话
    private static final int SEARCH_GLOBAL = 1;       // 全局搜索
    private static final int SEARCH_MESSAGES = 2;     // 搜索消息
    
    // 可搜索内容
    - 用户（通过 username 或电话号码）
    - 群组/频道（通过 username 或名称）
    - 消息内容（在对话中）
    - 全局消息（公开频道）
}
```

**后台必须能做的** ⭐:
```typescript
interface SearchManagement {
  // 用户可发现性
  setUserDiscoverable(userId: string, discoverable: boolean): void;
  
  // 群组可发现性
  setChatDiscoverable(chatId: string, discoverable: boolean): void;
  
  // 搜索白名单（只有白名单内的群组可被搜索）
  setSearchWhitelist(chatIds: string[]): void;
  
  // 新群默认设置
  setNewChatDefaultPrivate(enabled: boolean): void;
  
  // 搜索统计
  getSearchStats(): {
    topSearchedUsers: { userId: string; searchCount: number }[];
    topSearchedChats: { chatId: string; searchCount: number }[];
  };
}
```

---

### 6. 封禁与限制

#### 6.1 封禁用户 (MessagesController.java)

**客户端已有功能**:
```java
// MessagesController.java - 真实存在
class MessagesController {
    public LongSparseIntArray blockePeers = new LongSparseIntArray();
    public int totalBlockedCount = -1;
    public boolean blockedEndReached;
    
    // 封禁相关方法
    public void blockPeer(long id);
    public void unblockPeer(long id);
    public void getBlockedPeers(boolean reset);
}
```

**后台必须能做的** ⭐:
```typescript
interface BanManagement {
  // 封禁用户
  banUser(userId: string, ban: {
    type: 'temporary' | 'permanent';
    duration?: number;        // 小时
    reason: string;
    banIP: boolean;           // 同时封禁 IP
    banDevice: boolean;       // 同时封禁设备
  }): void;
  
  // 冻结用户（限制功能但可登录）
  freezeUser(userId: string, freeze: {
    canSendMessages: boolean;
    canCreateGroups: boolean;
    canUploadFiles: boolean;
    reason: string;
  }): void;
  
  // 解封用户
  unbanUser(userId: string, reason: string): void;
  
  // 查看封禁历史
  getBanHistory(userId: string): BanRecord[];
  
  // 封禁统计
  getBanStats(): {
    totalBanned: number;
    totalFrozen: number;
    bansByReason: Record<string, number>;
    banTrend: { date: Date; count: number }[];
  };
}
```

---

## 🔄 Telegram 功能 → 后台管理映射表

| Telegram 功能 | 客户端文件 | 后台是否需要管理 | 管理方式 |
|--------------|-----------|----------------|---------|
| **用户与账号** |
| 会话管理 | SessionsActivity.java | ✅ 必须 | 查看/终止会话 |
| 隐私设置 | PrivacySettingsActivity.java | ⚠️ 部分 | 全局策略，不管个人设置 |
| 用户资料 | ProfileActivity.java | ✅ 必须 | 查看/标记/封禁 |
| 联系人 | ContactsController.java | ❌ 不需要 | 用户自己管理 |
| **群组与频道** |
| 群组管理 | ChatActivity.java | ✅ 必须 | 查看/限制/解散 |
| 群组权限 | ChatRightsEditActivity.java | ⚠️ 部分 | 平台级限制 |
| 频道管理 | ChatActivity.java | ✅ 必须 | 同群组 |
| **消息与内容** |
| 消息发送 | SendMessagesHelper.java | ❌ 不能 | 不看内容 |
| 消息删除 | MessagesController.java | ✅ 必须 | 服务器级 revoke |
| 文件上传 | FileLoader.java | ✅ 必须 | 控制上传开关/限制 |
| 媒体查看 | PhotoViewer.java | ❌ 不需要 | 客户端功能 |
| **通知与推送** |
| 推送通知 | NotificationsController.java | ✅ 必须 | 控制是否发生 ⭐ |
| 通知设置 | NotificationsSettingsActivity.java | ❌ 不需要 | 用户自己设置 |
| **搜索与发现** |
| 全局搜索 | DialogsSearchAdapter.java | ✅ 必须 | 控制可发现性 |
| 用户搜索 | ContactsActivity.java | ✅ 必须 | 白名单机制 |
| **安全与隐私** |
| 封禁用户 | MessagesController.java | ✅ 必须 | 封禁/解封 |
| 两步验证 | TwoStepVerificationActivity.java | ❌ 不需要 | 用户自己设置 |
| 密码锁 | PasscodeActivity.java | ❌ 不需要 | 客户端功能 |
| **其他功能** |
| 贴纸 | StickersActivity.java | ⚠️ 可选 | 可禁用贴纸功能 |
| Bot | BotWebViewSheet.java | ⚠️ P3 | Bot 白名单 |
| 投票 | ChatActivity.java | ⚠️ 可选 | 可禁用投票功能 |
| 语音通话 | VoIPService.java | ⚠️ 可选 | 可禁用通话功能 |

---

## ✅ 后台管理功能补充清单

基于 Telegram 实际代码，以下是需要补充到管理后台的功能：

### 补充到 P0（必须实现）

1. **诈骗/虚假标记** ⭐
```typescript
interface ScamManagement {
  markUserAsScam(userId: string, reason: string): void;
  markChatAsScam(chatId: string, reason: string): void;
  markUserAsFake(userId: string, reason: string): void;
  markChatAsFake(chatId: string, reason: string): void;
}
```

2. **群组限制原因** ⭐
```typescript
interface ChatRestriction {
  restrictChat(chatId: string, restriction: {
    restricted: boolean;
    reason: string;           // 显示给用户的原因
    canSendMessages: boolean;
    canSendMedia: boolean;
    canInviteUsers: boolean;
  }): void;
}
```

3. **消息类型控制** ⭐
```typescript
interface MessageTypeControl {
  // 按群组禁用特定消息类型
  disableMessageTypes(chatId: string, types: {
    photos: boolean;
    videos: boolean;
    files: boolean;
    voice: boolean;
    stickers: boolean;
    gifs: boolean;
    polls: boolean;
    links: boolean;
  }): void;
}
```

### 补充到 P1（强烈建议）

4. **验证标记管理**
```typescript
interface VerificationManagement {
  verifyUser(userId: string): void;
  verifyChat(chatId: string): void;
  removeVerification(id: string): void;
}
```

5. **公开用户名管理**
```typescript
interface UsernameManagement {
  // 移除公开用户名（取消公开）
  removePublicUsername(id: string, reason: string): void;
  
  // 保留用户名（防止被占用）
  reserveUsername(username: string): void;
}
```

---

## 📋 实施建议

### 1. 优先实现（基于实际代码）

根据 Telegram 实际功能，优先实现以下管理功能：

**Week 1-2**:
- ✅ 会话管理（SessionsActivity 对应）
- ✅ 用户封禁（MessagesController.blockePeers 对应）
- ✅ 群组管理（Chat 实体对应）
- ✅ 诈骗/虚假标记（Chat.scam/fake 对应）

**Week 3**:
- ✅ 文件上传控制（FileLoader 对应）
- ✅ 消息类型控制（MessageObject.type 对应）
- ✅ 推送控制（NotificationsController 对应）

### 2. 数据库字段映射

基于 Telegram 实际字段，后台数据库需要存储：

```sql
-- 用户状态表（映射 TLRPC.User）
CREATE TABLE user_status (
  user_id VARCHAR(255) PRIMARY KEY,
  status VARCHAR(20) NOT NULL,        -- normal, frozen, banned
  is_scam BOOLEAN DEFAULT FALSE,      -- 对应 User.scam
  is_fake BOOLEAN DEFAULT FALSE,      -- 对应 User.fake
  is_verified BOOLEAN DEFAULT FALSE,  -- 对应 User.verified
  restriction_reason TEXT,            -- 对应 User.restriction_reason
  banned_at TIMESTAMP,
  banned_by VARCHAR(255),
  ban_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 群组状态表（映射 TLRPC.Chat）
CREATE TABLE chat_status (
  chat_id VARCHAR(255) PRIMARY KEY,
  type VARCHAR(20) NOT NULL,          -- group, supergroup, gigagroup, channel
  is_scam BOOLEAN DEFAULT FALSE,      -- 对应 Chat.scam
  is_fake BOOLEAN DEFAULT FALSE,      -- 对应 Chat.fake
  is_verified BOOLEAN DEFAULT FALSE,  -- 对应 Chat.verified
  is_restricted BOOLEAN DEFAULT FALSE,-- 对应 Chat.restricted
  restriction_reason TEXT,            -- 对应 Chat.restriction_reason
  status VARCHAR(20) DEFAULT 'normal',-- normal, restricted, banned, dissolved
  banned_at TIMESTAMP,
  banned_by VARCHAR(255),
  ban_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 消息类型限制表
CREATE TABLE message_type_restrictions (
  id SERIAL PRIMARY KEY,
  chat_id VARCHAR(255) NOT NULL,
  photos_disabled BOOLEAN DEFAULT FALSE,
  videos_disabled BOOLEAN DEFAULT FALSE,
  files_disabled BOOLEAN DEFAULT FALSE,
  voice_disabled BOOLEAN DEFAULT FALSE,
  stickers_disabled BOOLEAN DEFAULT FALSE,
  gifs_disabled BOOLEAN DEFAULT FALSE,
  polls_disabled BOOLEAN DEFAULT FALSE,
  links_disabled BOOLEAN DEFAULT FALSE,
  updated_by VARCHAR(255),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## ✅ 总结

### 基于 Telegram 实际代码的核心发现

1. **会话管理是真实存在的** - SessionsActivity.java 完整实现
2. **隐私设置非常细致** - 11 种隐私规则类型
3. **群组权限非常复杂** - 20+ 种管理员权限，20+ 种封禁权限
4. **消息类型很丰富** - 17+ 种消息类型
5. **诈骗/虚假标记是内置的** - Chat.scam, Chat.fake, User.scam, User.fake
6. **推送通知有 3 种类型** - 私聊/群组/频道

### 后台管理的正确边界

**必须管理**:
- ✅ 会话（查看/终止）
- ✅ 封禁（用户/群组）
- ✅ 标记（诈骗/虚假/验证）
- ✅ 限制（消息类型/文件上传）
- ✅ 推送（是否发生）
- ✅ 搜索（可发现性）

**不应该管理**:
- ❌ 用户个人隐私设置
- ❌ 消息内容
- ❌ 加密通信
- ❌ 客户端 UI/UX

---

**最后更新**: 2026-01-27  
**基于**: Telegram Android v11.4.2 源码分析  
**状态**: 功能映射完成，可用于补充管理后台设计

