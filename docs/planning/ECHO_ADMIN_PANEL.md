# Echo IM - 管理后台功能规划

**日期**: 2026-01-27  
**版本**: 1.0  
**核心理念**: 控制"权力边界"，不是"功能细节"

---

## 🎯 设计哲学

### 后台的职责

管理后台回答三个核心问题：
1. **谁可以用？** - 用户准入和封禁
2. **用到什么程度？** - 功能边界和权限
3. **出事我能不能一键止血？** - 紧急控制开关

### 不是后台的职责

- ❌ 管理消息细节（如何发送、格式、内容）
- ❌ 管理 UI（界面样式、交互细节）
- ❌ 管理加密内容（端到端加密的消息）
- ❌ 自定义推送文案（推送内容由客户端定义）

### 核心原则

> **Echo 不控制"推送说什么"，只控制"推送会不会发生"**

**三条生存线（P0 必须）**：

1. **搜索与可发现性是 P0** - 不做就会失控（垃圾号、黑产、骚扰）
2. **会话强制登出是 P0** - 不做就没法真正封禁/止血
3. **后台只管"推送是否发生"，不碰"聊天推送内容"** - 保持 Telegram 体验

---

## 📊 功能优先级总览

### 🟥 P0 - 平台生存级（必须实现）

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 1 | 用户管理 | 账号状态控制 | 封号、冻结、强制登出 |
| 2 | 风控系统 | 封号/黑名单 | IP 封禁、设备封禁、风险标记 |
| 3 | 对话管理 | 群组/频道控制 | 解散群、封禁群、禁止创建 |
| 4 | 文件控制 | 上传开关 | 全局/按群控制文件上传 |
| 5 | **搜索与可发现性** ⭐⭐⭐ | **全局搜索控制** | **搜索总开关、白名单、风控联动（生存线）** |
| 6 | **会话管理** ⭐⭐⭐ | **强制登出** | **终止会话、异常检测（封禁必备）** |
| 7 | **平台隐私策略** ⭐ | **功能开关** | **全局禁用通话/语音/位置等** |
| 8 | 内容治理 | 举报处理 | 被动响应举报，删除/禁言 |
| 9 | **推送控制** ⭐⭐⭐ | **推送开关** | **控制推送是否发生（不是内容）** |
| 10 | **诈骗/虚假标记** ⭐ | **标记管理** | **标记诈骗/虚假用户和群组** |
| 11 | **消息类型控制** ⭐ | **类型限制** | **按群组禁用特定消息类型** |
| 12 | 系统开关 | 紧急止血 | 关闭注册、只读模式 |

### 🟧 P1 - 平台差异化（强烈建议）

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 11 | 邀请系统 | 注册门槛 | 邀请码、配额、关系链 |
| 12 | 权限边界 | 群组权限 | 转发控制、新成员限制 |
| 13 | 系统推送 | 非聊天推送 | 平台公告、系统通知（可自定义） |
| 14 | 数据统计 | 基础指标 | DAU/MAU、活跃度 |
| 15 | **验证标记** ⭐ | **蓝V管理** | **官方账号/群组验证标记** |
| 16 | **用户名管理** ⭐ | **公开用户名** | **保留/移除公开用户名** |


### 🟨 P2 - 运营扩展（可选）

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 17 | 圈子/标签 | 兴趣分类 | 基于群组的标签系统 |
| 18 | 广场/推荐 | 内容聚合 | 手动推荐、热度排序 |
| 19 | 内容聚合 | 精选消息 | 官方合集（只读） |

### 🟩 P3 - 长期规划

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 20 | Bot 管理 | 机器人控制 | 白名单、权限管理 |
| 21 | 反滥用自动化 | 行为检测 | 频率限制、异常检测 |
| 22 | 多节点/灾备 | 高可用 | 节点管理、流量切换 |
| 23 | 合规工具 | 法律响应 | 数据导出、删除请求 |

---

## 🟥 P0 功能详细设计

### 1️⃣ 用户管理 - 账号状态控制

#### Telegram 客户端已有功能
- ✅ 手机号注册
- ✅ 多设备登录
- ✅ 会话管理
- ✅ 用户资料（头像、昵称、bio）
- ✅ 用户名系统（@username）
- ✅ 在线状态

#### 后台必须能做的

**用户列表**:
```typescript
interface UserListItem {
  userId: string;           // 内部 ID（不显示给管理员）
  phone: string;            // 手机号（脱敏显示）
  username?: string;        // @username
  displayName: string;      // 显示名称
  registeredAt: Date;       // 注册时间
  lastActiveAt: Date;       // 最后活跃
  status: 'normal' | 'frozen' | 'banned';  // 账号状态
  deviceCount: number;      // 设备数量
  riskLevel: 'low' | 'medium' | 'high';    // 风险等级
}
```

**账号状态控制**:
- **正常 (normal)**: 所有功能可用
- **冻结 (frozen)**: 
  - 可以登录和查看消息
  - 不能发送消息
  - 不能创建群组
  - 不能上传文件
- **封禁 (banned)**:
  - 无法登录
  - 所有设备强制登出
  - 无法注册新账号（同设备/IP）


**操作功能**:
- 查看用户详情（基本信息、设备列表、活跃群组）
- 冻结账号（临时限制）
- 封禁账号（永久禁止）
- 解封账号
- 强制登出所有设备
- 查看活跃会话（设备类型、IP、最后活跃时间）
- 踢掉特定设备会话

**控制粒度**: 账号级 / 会话级（不是消息级）

**数据来源**: 
- Echo DB (只读): `users`, `auth_keys`, `user_presences`
- Echo DB (读写): `user_status`, `user_risk_scores`, `ban_records`

---

### 2️⃣ 风控系统 - 封号/黑名单

#### Telegram 官方能力
- ✅ 官方可封号
- ✅ 官方可限制账号行为

#### 后台必须能做的

**风控维度**:
```typescript
interface RiskControl {
  // IP 封禁
  bannedIPs: string[];           // 封禁的 IP 列表
  ipWhitelist: string[];         // IP 白名单
  
  // 设备封禁
  bannedDevices: string[];       // 设备指纹
  
  // 行为风控
  maxRegistrationsPerIP: number; // 单 IP 注册上限
  maxDevicesPerUser: number;     // 单用户设备上限
  
  // 风险标记
  riskUsers: {
    userId: string;
    level: 'low' | 'medium' | 'high';
    reason: string;
    markedAt: Date;
  }[];
}
```

**封禁类型**:
1. **用户封禁**: 封禁特定用户
2. **IP 封禁**: 封禁特定 IP（防止重新注册）
3. **设备封禁**: 封禁特定设备（防止换号）
4. **批量封禁**: 批量处理风险账号

**风险标记**:
- 异常注册（短时间大量注册）
- 异常行为（频繁创建群、发送消息）
- 举报次数过多
- 设备异常（模拟器、多开）

**控制粒度**: 行为层控制，不碰加密内容

**数据来源**:
- Echo DB: `banned_ips`, `banned_devices`, `risk_scores`, `ban_logs`

---

### 3️⃣ 对话管理 - 群组/频道控制

#### Telegram 客户端已有功能
- ✅ 私聊（1对1）
- ✅ 基础群组（Basic Groups）
- ✅ 超级群组（Supergroups）
- ✅ 频道（Channels）


#### 后台必须能做的

**⚠️ 重点**: 不是"管理聊天内容"，是"控制空间是否存在"

**群组/频道列表**:
```typescript
interface ChatListItem {
  chatId: string;
  type: 'private' | 'group' | 'supergroup' | 'channel';
  title: string;
  creator: string;           // 创建者
  memberCount: number;       // 成员数
  createdAt: Date;
  isPublic: boolean;         // 是否公开
  username?: string;         // 公开链接
  status: 'active' | 'banned' | 'dissolved';
}
```

**操作功能**:
- **禁止创建新群/频道**: 全局开关
- **解散群/频道**: 强制解散（所有成员退出）
- **封禁群/频道**: 禁止发言，但不解散
- **查看群基本信息**:
  - 成员数
  - 创建者
  - 是否公开
  - 活跃度
- **批量操作**: 批量解散/封禁

**不能做的**:
- ❌ 查看聊天内容（加密消息）
- ❌ 修改群设置（由群主管理）
- ❌ 踢出特定成员（由群主管理）

**控制粒度**: 对话实体级（dialog level）

**数据来源**:
- Echo DB (只读): `chats`, `channels`, `chat_participants`
- Echo DB (读写): `chat_status`, `banned_chats`, `dissolution_logs`

---

### 4️⃣ 文件控制 - 上传开关

#### Telegram 客户端已有功能
- ✅ 文件上传（图片、视频、文档）
- ✅ 大文件支持（2GB+）
- ✅ 云端存储

#### 后台必须能做的

**文件控制策略**:
```typescript
interface FileControl {
  // 全局控制
  globalUploadEnabled: boolean;
  
  // 文件类型限制
  allowedTypes: ('image' | 'video' | 'document' | 'audio')[];
  
  // 大小限制
  maxFileSize: number;           // 单位: MB
  maxImageSize: number;
  maxVideoSize: number;
  
  // 按群控制
  chatFileControls: {
    chatId: string;
    uploadEnabled: boolean;
    allowedTypes: string[];
  }[];
  
  // 按用户控制
  userFileControls: {
    userId: string;
    uploadEnabled: boolean;
    dailyQuota: number;          // 每日上传配额
  }[];
}
```


**操作功能**:
- **全局关闭文件上传**: 紧急止血
- **按群关闭媒体**: 特定群禁止上传
- **限制文件类型**: 只允许图片，禁止视频/文档
- **限制文件大小**: 设置上传大小上限
- **紧急只读模式**: 全站只允许文本消息

**控制粒度**: 上传层控制，不解析内容

**实现方式**:
- Echo Business Server 拦截上传请求
- 检查用户/群组的上传权限
- 检查文件类型和大小
- 允许/拒绝上传到 MinIO

**数据来源**:
- Echo DB: `file_control_policies`, `upload_quotas`, `upload_logs`

---

### 5️⃣ 搜索与可发现性控制 ⭐

#### Telegram 客户端已有功能
- ✅ 全局搜索（搜索用户、群组、频道）
- ✅ 通过 @username 搜索
- ✅ 通过手机号搜索（需要对方允许）
- ✅ 附近的人（基于地理位置）
- ✅ 搜索历史

#### 后台必须能做的

**全局搜索控制台**:
```typescript
interface GlobalSearchControl {
  // 搜索总开关
  globalSearchEnabled: boolean;
  
  // 用户搜索控制
  userSearch: {
    byUsername: boolean;        // 允许通过 @username 搜索
    byPhone: boolean;           // 允许通过手机号搜索
    nearbyEnabled: boolean;     // 附近的人功能
  };
  
  // 群组/频道搜索控制
  chatSearch: {
    publicChatsEnabled: boolean;  // 公开群组可搜索
    channelsEnabled: boolean;     // 频道可搜索
  };
  
  // 搜索白名单
  searchWhitelist: {
    users: string[];            // 允许被搜索的用户
    chats: string[];            // 允许被搜索的群组
  };
  
  // 风控联动
  autoHideScam: boolean;        // 自动隐藏诈骗标记对象
  autoHideFake: boolean;        // 自动隐藏虚假标记对象
  autoHideRestricted: boolean;  // 自动隐藏受限对象
}
```

**用户可发现性控制**:
```typescript
interface UserDiscoverability {
  userId: string;
  username: string;
  
  // 可发现性设置
  searchable: boolean;          // 是否可被搜索
  searchableByUsername: boolean;// 可通过 @username 搜索
  searchableByPhone: boolean;   // 可通过手机号搜索
  showInNearby: boolean;        // 显示在附近的人
  showInSuggestions: boolean;   // 显示在推荐列表
  
  // 风控联动
  isScam: boolean;              // 诈骗标记（自动隐藏）
  isFake: boolean;              // 虚假标记（自动隐藏）
  isRestricted: boolean;        // 受限状态（自动隐藏）
  
  updatedBy: string;
  updatedAt: Date;
}
```

**群组/频道可发现性控制**:
```typescript
interface ChatDiscoverability {
  chatId: string;
  chatTitle: string;
  type: 'group' | 'supergroup' | 'channel';
  
  // 可发现性设置
  searchable: boolean;          // 是否可被搜索
  publicUsername: string | null;// 公开用户名
  inviteOnly: boolean;          // 仅邀请
  requireApproval: boolean;     // 需要审批
  
  // 白名单机制
  inWhitelist: boolean;         // 在白名单中
  whitelistReason?: string;
  
  // 风控联动
  isScam: boolean;
  isFake: boolean;
  isRestricted: boolean;
  
  updatedBy: string;
  updatedAt: Date;
}
```

**操作功能**:
- **全局控制**:
  - 关闭/开启全局搜索
  - 关闭/开启用户名搜索
  - 关闭/开启手机号搜索
  - 关闭/开启附近的人
- **白名单管理**:
  - 添加到搜索白名单
  - 从白名单移除
  - 批量导入白名单
  - 导出白名单
- **可发现性控制**:
  - 设置用户不可搜索
  - 设置群组不可搜索
  - 批量设置可发现性
- **风控联动**:
  - 自动隐藏诈骗/虚假对象
  - 自动隐藏受限对象
  - 查看隐藏列表

**控制粒度**: 全局级 / 用户级 / 群组级

**实现方式**:
- Echo Business Server 维护搜索索引
- 过滤不可搜索的用户/群组
- Echo 搜索 API 返回结果后再过滤
- 风控标记自动联动隐藏

**数据来源**:
- Echo DB (只读): `users`, `chats`, `usernames`
- Echo DB (读写): `discoverability_settings`, `search_whitelist`, `search_logs`

---

### 6️⃣ 会话管理 - 强制登出 ⭐

#### Telegram 客户端真实存在

```java
// SessionsActivity.java - 真实会话管理
class SessionsActivity {
    // 设备会话列表
    ArrayList<TL_authorization> sessions;
    
    // 会话信息
    class TL_authorization {
        long hash;              // 会话 hash
        String device_model;    // 设备型号
        String platform;        // 平台
        String system_version;  // 系统版本
        String app_name;        // 应用名称
        String app_version;     // 应用版本
        int date_created;       // 创建时间
        int date_active;        // 最后活跃
        String ip;              // IP 地址
        String country;         // 国家
        String region;          // 地区
    }
    
    // 终止会话
    void terminateSession(long hash);
    
    // 终止所有其他会话
    void terminateAllSessions();
}
```

#### 后台必须能做的

**会话管理**:
```typescript
interface SessionManagement {
  // 查看用户所有会话
  getUserSessions(userId: string): Session[];
  
  // 终止特定会话
  terminateSession(userId: string, sessionHash: string, reason: string): void;
  
  // 终止所有会话（强制登出）
  terminateAllSessions(userId: string, reason: string): void;
  
  // 异常会话检测
  detectAbnormalSessions(userId: string): AbnormalSession[];
}
```

**会话信息**:
```typescript
interface Session {
  sessionHash: string;
  userId: string;
  
  // 设备信息
  deviceModel: string;
  platform: 'android' | 'ios' | 'desktop' | 'web';
  systemVersion: string;
  appName: string;
  appVersion: string;
  
  // 时间信息
  createdAt: Date;
  lastActiveAt: Date;
  
  // 位置信息
  ip: string;
  country: string;
  region: string;
  city?: string;
  
  // 状态
  status: 'online' | 'offline';
  isAbnormal: boolean;          // 异常标记
  abnormalReason?: string;
  
  // 操作记录
  terminatedBy?: string;
  terminatedAt?: Date;
  terminateReason?: string;
}
```

**异常会话检测**:
```typescript
interface AbnormalSessionDetection {
  // 异常类型
  type: 'location_change' | 'device_change' | 'concurrent_login' | 'suspicious_ip';
  
  // 检测规则
  rules: {
    // 地理位置异常
    locationChange: {
      enabled: boolean;
      maxDistanceKm: number;    // 最大距离（公里）
      timeWindowMinutes: number;// 时间窗口（分钟）
    };
    
    // 设备异常
    deviceChange: {
      enabled: boolean;
      alertOnNewDevice: boolean;
    };
    
    // 并发登录
    concurrentLogin: {
      enabled: boolean;
      maxConcurrent: number;    // 最大并发数
    };
    
    // 可疑 IP
    suspiciousIP: {
      enabled: boolean;
      blacklist: string[];      // IP 黑名单
      vpnDetection: boolean;    // VPN 检测
    };
  };
}
```

**操作功能**:
- **查看会话**:
  - 查看用户所有活跃会话
  - 查看会话详细信息
  - 查看会话历史
- **终止会话**:
  - 终止特定会话
  - 终止所有会话（强制登出）
  - 批量终止异常会话
- **异常检测**:
  - 检测异常会话
  - 标记可疑会话
  - 自动终止异常会话
- **联动操作**:
  - 封禁时自动终止所有会话
  - 冻结时自动终止所有会话
  - 密码修改时自动终止所有会话

**控制粒度**: 会话级控制

**实现方式**:
- 通过 Echo API 查询会话列表
- 通过 Echo API 终止会话
- Echo Business Server 记录操作日志
- 异常检测规则在 Echo 侧实现

**数据来源**:
- Echo DB (只读): `auth_keys`, `user_presences`
- Echo DB (读写): `session_logs`, `abnormal_sessions`, `session_termination_logs`

---

### 7️⃣ 平台隐私策略 ⭐

#### Telegram 客户端已有功能
- ✅ 用户个人隐私设置（谁能看我的手机号、最后上线时间等）
- ✅ 通话功能（语音/视频通话）
- ✅ P2P 连接（点对点连接）
- ✅ 语音消息
- ✅ 位置分享

#### 后台必须能做的

**⚠️ 重点**: 不管理用户个人隐私设置，只控制平台级功能开关

**平台隐私策略**:
```typescript
interface PlatformPrivacyPolicy {
  // 通话功能控制
  calls: {
    voiceCallsEnabled: boolean;   // 语音通话
    videoCallsEnabled: boolean;   // 视频通话
    groupCallsEnabled: boolean;   // 群组通话
    p2pEnabled: boolean;          // P2P 连接
  };
  
  // 消息类型控制
  messages: {
    voiceMessagesEnabled: boolean;// 语音消息
    videoMessagesEnabled: boolean;// 视频消息
    locationSharingEnabled: boolean;// 位置分享
  };
  
  // 隐私功能控制
  privacy: {
    phoneNumberDiscoveryEnabled: boolean;  // 通过手机号发现
    usernameSearchEnabled: boolean;        // 通过用户名搜索
    nearbyPeopleEnabled: boolean;          // 附近的人
    profilePhotoEnabled: boolean;          // 头像显示
  };
  
  // 数据收集控制
  dataCollection: {
    analyticsEnabled: boolean;    // 分析数据收集
    crashReportsEnabled: boolean; // 崩溃报告
    usageStatsEnabled: boolean;   // 使用统计
  };
}
```

**操作功能**:
- **功能开关**:
  - 全局禁用语音/视频通话
  - 全局禁用 P2P 连接
  - 全局禁用语音消息
  - 全局禁用位置分享
- **隐私功能**:
  - 禁用手机号发现
  - 禁用附近的人
  - 禁用头像显示
- **数据收集**:
  - 禁用分析数据收集
  - 禁用崩溃报告
  - 禁用使用统计

**控制粒度**: 平台级控制

**实现方式**:
- 通过 Remote Config 下发到客户端
- 客户端根据配置禁用相应功能
- 服务端拦截被禁用的功能请求

**数据来源**:
- Echo DB: `platform_privacy_policy`, `privacy_policy_logs`

---

### 8️⃣ 内容治理 - 举报处理

#### Telegram 客户端已有功能
- ✅ 举报消息
- ✅ 举报用户
- ✅ 举报群组


#### 后台必须能做的

**举报管理**:
```typescript
interface ReportManagement {
  reportId: string;
  type: 'message' | 'user' | 'chat';
  reportedBy: string;          // 举报人
  reportedTarget: string;      // 被举报对象
  reason: 'spam' | 'violence' | 'pornography' | 'other';
  description: string;
  createdAt: Date;
  status: 'pending' | 'reviewing' | 'resolved' | 'dismissed';
  
  // 定位信息
  messageId?: string;          // 消息 ID（但不解密内容）
  chatId?: string;             // 所在群组
  
  // 处理记录
  handledBy?: string;          // 处理人
  handledAt?: Date;
  action?: 'delete' | 'ban_user' | 'ban_chat' | 'warn' | 'dismiss';
  note?: string;
}
```

**操作功能**:
- **查看举报列表**: 按状态、类型筛选
- **定位到对象**:
  - 用户 → 查看用户详情
  - 群组 → 查看群组详情
  - 消息 → 定位到 message_id（但不解密内容）
- **处理操作**:
  - 删除消息（服务器级 revoke）
  - 禁言用户（临时/永久）
  - 封禁用户
  - 解散群组
  - 警告（记录但不处罚）
  - 驳回举报

**⚠️ 重点**: 被动触发，不主动扫描

**控制粒度**: 被动响应，不看内容

**数据来源**:
- Echo DB (只读): `messages` (只读 ID，不读内容)
- Echo DB (读写): `reports`, `report_actions`, `moderation_logs`

---

### 9️⃣ 推送控制 - 推送开关 ⭐⭐⭐

#### 核心理念

> **Echo 不控制"推送说什么"，只控制"推送会不会发生"**

#### Telegram 推送机制

```
消息到达服务器
    ↓
服务器判断用户是否在线
    ↓
不在线 → 触发 Push Gateway (FCM/APNs)
    ↓
客户端收到系统通知
```

**推送是服务端行为，但内容 & 样式是客户端定义的**

#### Telegram 客户端已有功能
- ✅ 私聊消息推送
- ✅ 群消息推送
- ✅ 频道新消息推送
- ✅ @ 提及推送
- ✅ 回复推送
- ✅ 静音/免打扰
- ✅ 全局通知开关
- ✅ 每个聊天单独通知设置

**这些全部是客户端已有功能，你不能、也不需要重做**


#### 后台必须能做的

**1. 推送总开关（平台生死线）**

```typescript
interface PushGlobalControl {
  // 全局开关
  globalPushEnabled: boolean;    // 所有用户推送总开关
  
  // 紧急熔断
  emergencyMode: boolean;        // 紧急模式：关闭所有推送
  
  // 推送服务状态
  fcmEnabled: boolean;           // Android 推送
  apnsEnabled: boolean;          // iOS 推送
}
```

**操作**: 
- 全局关闭推送（所有用户）
- 紧急熔断（事故止血）
- 分平台控制（关闭 Android 或 iOS）

**2. 用户级推送资格控制**

```typescript
interface UserPushControl {
  userId: string;
  pushEnabled: boolean;          // 该用户是否允许推送
  reason?: string;               // 禁用原因
  
  // 风控限制
  maxPushPerHour: number;        // 每小时推送上限
  cooldownSeconds: number;       // 推送冷却期（新用户）
}
```

**操作**:
- 被封禁用户 → 不允许触发推送
- 风控用户 → 限制推送频率
- 新注册用户 → 可设置推送冷却期

**3. 群/频道推送许可**

```typescript
interface ChatPushControl {
  chatId: string;
  pushEnabled: boolean;          // 该群是否允许触发推送
  silentMode: boolean;           // 静默模式（消息不推送）
  
  // 频率限制
  maxPushPerHour: number;        // 该群每小时推送上限
}
```

**操作**:
- 某个群不允许触发 push
- 频道：允许推送 / 静默发布（no push）
- 事故群：立即关闭推送

**4. 推送风控（不是内容）**

```typescript
interface PushRiskControl {
  // 频率限制
  userPushRateLimit: {
    userId: string;
    maxPerHour: number;
    maxPerDay: number;
  }[];
  
  // 群组推送限制
  chatPushRateLimit: {
    chatId: string;
    maxPerHour: number;
  }[];
  
  // 自动静默
  autoSilentThreshold: {
    messagesPerMinute: number;   // 短时间大量消息 → 自动静默
    duration: number;            // 静默持续时间（秒）
  };
}
```

**操作**:
- 单用户推送频率限制
- 单群推送频率限制
- 短时间大量消息 → 自动静默 push


#### 你【不该做】的推送相关功能

❌ **不要做自定义 push 文案**
- Telegram 客户端已定义
- 你改不了
- 改了就不是 Telegram 体验

❌ **不要试图"分析消息决定是否推送"**
- 加密你也看不到
- 这是反 Telegram 精神的

❌ **不要绕开 Telegram 推送系统**
- 不要自己接 APNs / FCM 给聊天用
- 会破坏多端一致性

#### 控制粒度

**是否触发 push，而不是 push 内容**

#### 实现方式

```typescript
// Echo Business Server - Push Gateway
@Injectable()
export class PushGatewayService {
  async shouldSendPush(
    userId: string,
    chatId: string,
    messageId: string,
  ): Promise<boolean> {
    // 1. 检查全局开关
    if (!this.config.globalPushEnabled) return false;
    
    // 2. 检查用户推送资格
    const userControl = await this.getUserPushControl(userId);
    if (!userControl.pushEnabled) return false;
    
    // 3. 检查群组推送许可
    const chatControl = await this.getChatPushControl(chatId);
    if (!chatControl.pushEnabled) return false;
    
    // 4. 检查推送频率
    const rateOk = await this.checkPushRate(userId, chatId);
    if (!rateOk) return false;
    
    // 5. 检查用户是否在线（从 Echo 查询）
    const isOnline = await this.echoBridge.isUserOnline(userId);
    if (isOnline) return false;
    
    return true;
  }
}
```

#### 数据来源

- Echo DB (只读): `user_presences` (在线状态)
- Echo DB (读写): `push_controls`, `push_rate_limits`, `push_logs`

---

### 🔟 诈骗/虚假标记管理 ⭐

#### Telegram 客户端真实存在

```java
// TLRPC.User - 真实字段
class User {
    boolean scam;           // 诈骗标记
    boolean fake;           // 虚假标记
    boolean verified;       // 验证标记（蓝V）
}

// TLRPC.Chat - 真实字段
class Chat {
    boolean scam;           // 诈骗标记
    boolean fake;           // 虚假标记
    boolean verified;       // 验证标记
    boolean restricted;     // 受限状态
    String restriction_reason;  // 限制原因（显示给用户）
}
```

#### 后台必须能做的

**标记管理**:
```typescript
interface MarkManagement {
  // 标记为诈骗
  markAsScam(id: string, type: 'user' | 'chat', mark: {
    reason: string;
    evidence: string[];     // 证据（截图/举报ID）
    markedBy: string;
  }): void;
  
  // 标记为虚假
  markAsFake(id: string, type: 'user' | 'chat', mark: {
    reason: string;
    evidence: string[];
    markedBy: string;
  }): void;
  
  // 移除标记
  removeMark(id: string, type: 'user' | 'chat', markType: 'scam' | 'fake', reason: string): void;
  
  // 查看标记历史
  getMarkHistory(id: string, type: 'user' | 'chat'): MarkRecord[];
}
```

**标记记录**:
```typescript
interface MarkRecord {
  markId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  markType: 'scam' | 'fake';
  reason: string;
  evidence: string[];
  markedBy: string;
  markedAt: Date;
  removedBy?: string;
  removedAt?: Date;
  removeReason?: string;
  status: 'active' | 'removed';
}
```

**操作功能**:
- 标记用户/群组为诈骗
- 标记用户/群组为虚假
- 移除标记
- 查看标记历史
- 批量标记
- 导出标记列表

**控制粒度**: 标记级控制，不碰内容

**实现方式**:
- Echo Business Server 维护标记状态
- 同步到 Echo DB 的 `scam`/`fake` 字段
- 客户端显示警告标识

**数据来源**:
- Echo DB (读写): `users.scam`, `users.fake`, `chats.scam`, `chats.fake`
- Echo DB (读写): `mark_records`

---

### 1️⃣1️⃣ 消息类型控制 ⭐

#### Telegram 客户端真实存在

```java
// TLRPC.TL_chatBannedRights - 真实权限控制
class TL_chatBannedRights {
    boolean send_messages;      // 发送消息
    boolean send_media;         // 发送媒体
    boolean send_stickers;      // 发送贴纸
    boolean send_gifs;          // 发送 GIF
    boolean send_polls;         // 发送投票
    boolean send_photos;        // 发送照片
    boolean send_videos;        // 发送视频
    boolean send_audios;        // 发送音频
    boolean send_voices;        // 发送语音
    boolean send_docs;          // 发送文档
    boolean embed_links;        // 嵌入链接
}
```

#### 后台必须能做的

**按群组控制消息类型**:
```typescript
interface MessageTypeControl {
  // 设置群组消息类型限制
  setChatMessageTypeRestrictions(chatId: string, restrictions: {
    photos: boolean;          // 禁止照片
    videos: boolean;          // 禁止视频
    files: boolean;           // 禁止文件
    voice: boolean;           // 禁止语音
    stickers: boolean;        // 禁止贴纸
    gifs: boolean;            // 禁止 GIF
    polls: boolean;           // 禁止投票
    links: boolean;           // 禁止链接
    reason: string;
  }): void;
  
  // 批量设置
  batchSetMessageTypeRestrictions(chatIds: string[], restrictions: MessageTypeRestrictions): void;
  
  // 查看限制
  getChatMessageTypeRestrictions(chatId: string): MessageTypeRestrictions;
  
  // 移除限制
  removeChatMessageTypeRestrictions(chatId: string): void;
}
```

**全局消息类型策略**:
```typescript
interface GlobalMessageTypePolicy {
  // 全局禁用特定消息类型
  disableMessageTypeGlobally(type: MessageType, reason: string): void;
  
  // 新群默认限制
  setNewChatDefaultRestrictions(restrictions: MessageTypeRestrictions): void;
}
```

**操作功能**:
- 设置群组消息类型限制
- 批量设置限制
- 全局禁用特定类型
- 设置新群默认限制
- 查看限制历史
- 导出限制配置

**控制粒度**: 消息类型级控制

**实现方式**:
- Echo Business Server 维护限制配置
- 同步到 Echo DB 的 `chat_banned_rights`
- 客户端根据权限禁用发送功能

**数据来源**:
- Echo DB (读写): `chats.default_banned_rights`
- Echo DB (读写): `message_type_restrictions`

---

### 1️⃣2️⃣ 系统开关 - 紧急止血

#### 后台必须能做的

**系统级安全开关**:
```typescript
interface SystemEmergencyControls {
  // 注册控制
  registrationEnabled: boolean;   // 是否允许新注册
  inviteOnlyMode: boolean;        // 仅邀请模式
  
  // 功能控制
  fileUploadEnabled: boolean;     // 全局文件上传
  groupCreationEnabled: boolean;  // 是否允许创建群
  channelCreationEnabled: boolean;// 是否允许创建频道
  
  // 紧急模式
  readOnlyMode: boolean;          // 只读模式（只能查看，不能发送）
  maintenanceMode: boolean;       // 维护模式（所有功能暂停）
  
  // 推送控制
  pushEnabled: boolean;           // 全局推送开关
}
```


**操作功能**:
- **关闭新注册**: 禁止新用户注册
- **仅邀请模式**: 只能通过邀请码注册
- **关闭文件上传**: 全局禁止上传
- **关闭群组创建**: 禁止创建新群/频道
- **只读模式**: 所有用户只能查看，不能发送
- **维护模式**: 所有功能暂停，显示维护公告
- **关闭推送**: 全局关闭推送通知

**使用场景**:
- 遭受攻击时快速止血
- 系统维护时暂停服务
- 内容事故时紧急控制
- 服务器压力过大时降级

**控制粒度**: 平台级

**数据来源**:
- Echo DB: `system_controls`, `emergency_logs`

---

## 🟧 P1 功能详细设计

### 9️⃣ 邀请系统 - 注册门槛

#### 为什么需要邀请系统？

Echo 是筛选型产品，需要控制用户质量和增长速度。

#### 后台必须能做的

**邀请码管理**:
```typescript
interface InviteCodeManagement {
  // 邀请码生成
  generateCodes: {
    count: number;              // 生成数量
    expiresIn: number;          // 有效期（天）
    maxUses: number;            // 最大使用次数
    note?: string;              // 备注
  };
  
  // 邀请码列表
  codes: {
    code: string;               // 邀请码
    createdBy: string;          // 创建者
    createdAt: Date;
    expiresAt: Date;
    maxUses: number;
    usedCount: number;
    status: 'active' | 'expired' | 'exhausted';
  }[];
  
  // 邀请配额
  userQuotas: {
    userId: string;
    inviteQuota: number;        // 可邀请人数
    invitedCount: number;       // 已邀请人数
    successfulInvites: number;  // 成功邀请（已注册）
  }[];
}
```

**邀请关系链**:
```typescript
interface InviteRelationship {
  inviterId: string;            // 邀请人
  inviteeId: string;            // 被邀请人
  inviteCode: string;           // 使用的邀请码
  invitedAt: Date;
  registeredAt?: Date;          // 注册时间
  status: 'pending' | 'registered' | 'active';
}
```

**操作功能**:
- 批量生成邀请码
- 设置邀请码有效期和使用次数
- 查看邀请码使用情况
- 禁用/启用邀请码
- 设置用户邀请配额
- 查看邀请关系链
- 统计邀请效果（转化率、活跃度）

**数据来源**:
- Echo DB: `invite_codes`, `invite_relationships`, `user_quotas`

---

### 🔟 权限边界 - 群组权限

#### 后台必须能做的

**群组权限控制**:
```typescript
interface ChatPermissionBoundaries {
  chatId: string;
  
  // 消息权限
  allowForward: boolean;        // 是否允许转发
  allowLinks: boolean;          // 是否允许发链接
  allowMedia: boolean;          // 是否允许发媒体
  
  // 成员权限
  newMemberCanSpeak: boolean;   // 新成员是否可发言
  newMemberMuteHours: number;   // 新成员禁言时长
  
  // Bot 权限
  allowBots: boolean;           // 是否允许 Bot
  
  // 匿名权限
  allowAnonymous: boolean;      // 是否允许匿名管理员
}
```

**操作功能**:
- 设置群组是否允许转发
- 设置新成员发言限制
- 设置是否允许 Bot
- 批量应用权限模板

**⚠️ 注意**: 这是对"是否打扰用户"的控制权，不是对消息内容的控制

**数据来源**:
- Echo DB: `chat_permission_boundaries`

---

### 1️⃣1️⃣ 系统推送 - 非聊天推送 ⭐

#### 与聊天推送的区别

| 类型 | 聊天推送 | 系统推送 |
|------|---------|---------|
| 来源 | Telegram 消息 | Echo 平台 |
| 内容 | 客户端定义 | 后台可自定义 |
| 控制 | 只能控制是否发生 | 完全可控 |
| 通道 | Echo 推送系统 | Echo 推送通道 |

#### 后台必须能做的

**系统推送类型**:
```typescript
interface SystemPushNotification {
  type: 'announcement' | 'maintenance' | 'security' | 'invite' | 'system';
  
  // 推送内容（可自定义）
  title: string;
  body: string;
  icon?: string;
  
  // 目标用户
  targetType: 'all' | 'specific' | 'group';
  targetUsers?: string[];       // 特定用户
  targetGroups?: string[];      // 特定群组的成员
  
  // 推送时间
  sendAt?: Date;                // 定时推送
  
  // 跳转
  action?: {
    type: 'url' | 'chat' | 'user';
    value: string;
  };
}
```

**系统推送场景**:
1. **平台公告**: 新功能、活动通知
2. **系统维护**: 维护通知、恢复通知
3. **安全提醒**: 异常登录、密码修改
4. **邀请提醒**: 邀请码到期、配额提醒
5. **服务公告**: 服务升级、政策变更

**操作功能**:
- 创建系统推送
- 选择目标用户（全部/特定/群组）
- 自定义推送内容
- 定时发送
- 查看推送历史和送达率

**数据来源**:
- Echo DB: `system_pushes`, `push_delivery_logs`

---

### 1️⃣2️⃣ 数据统计 - 基础指标

#### 后台必须能做的

**用户指标**:
```typescript
interface UserMetrics {
  // 基础指标
  totalUsers: number;           // 总用户数
  activeUsers: {
    dau: number;                // 日活
    wau: number;                // 周活
    mau: number;                // 月活
  };
  
  // 新增用户
  newUsers: {
    today: number;
    thisWeek: number;
    thisMonth: number;
  };
  
  // 留存率
  retention: {
    day1: number;               // 次日留存
    day7: number;               // 7日留存
    day30: number;              // 30日留存
  };
}
```

**群组指标**:
```typescript
interface ChatMetrics {
  totalChats: number;           // 总群组数
  activeChats: number;          // 活跃群组数
  
  // 群组活跃度
  chatActivity: {
    chatId: string;
    messageCount: number;       // 消息数
    activeMembers: number;      // 活跃成员数
    growthRate: number;         // 增长率
  }[];
}
```

**内容指标**:
```typescript
interface ContentMetrics {
  // 消息统计
  totalMessages: number;
  messagesPerDay: number;
  
  // 文件统计
  totalFiles: number;
  storageUsed: number;          // 存储使用量（GB）
  
  // 举报统计
  totalReports: number;
  reportRate: number;           // 举报率
  resolvedReports: number;
}
```

**封禁指标**:
```typescript
interface ModerationMetrics {
  bannedUsers: number;
  frozenUsers: number;
  bannedChats: number;
  
  // 封禁趋势
  banTrend: {
    date: Date;
    count: number;
  }[];
}
```

**操作功能**:
- 查看实时数据
- 导出数据报表
- 设置数据告警（异常检测）
- 自定义时间范围

**数据来源**:
- Echo DB (只读): 聚合查询
- Echo DB (读写): `metrics_cache`, `daily_stats`

---

### 1️⃣5️⃣ 验证标记管理（蓝V）⭐

#### Telegram 客户端真实存在

```java
// TLRPC.User / TLRPC.Chat - 真实字段
class User {
    boolean verified;       // 验证标记（蓝V）
}

class Chat {
    boolean verified;       // 验证标记
}
```

#### 后台必须能做的

**验证标记管理**:
```typescript
interface VerificationManagement {
  // 验证用户
  verifyUser(userId: string, verification: {
    reason: string;         // 验证原因（官方账号、知名人士等）
    verifiedBy: string;
    note?: string;
  }): void;
  
  // 验证群组/频道
  verifyChat(chatId: string, verification: {
    reason: string;         // 验证原因（官方群组、认证组织等）
    verifiedBy: string;
    note?: string;
  }): void;
  
  // 移除验证
  removeVerification(id: string, type: 'user' | 'chat', reason: string): void;
  
  // 查看验证历史
  getVerificationHistory(id: string, type: 'user' | 'chat'): VerificationRecord[];
  
  // 验证申请审核
  reviewVerificationRequest(requestId: string, decision: 'approve' | 'reject', note: string): void;
}
```

**验证记录**:
```typescript
interface VerificationRecord {
  verificationId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  reason: string;
  verifiedBy: string;
  verifiedAt: Date;
  removedBy?: string;
  removedAt?: Date;
  removeReason?: string;
  status: 'active' | 'removed';
}
```

**操作功能**:
- 验证用户/群组
- 移除验证
- 审核验证申请
- 查看验证历史
- 批量验证
- 导出验证列表

**控制粒度**: 标记级控制

**实现方式**:
- Echo Business Server 维护验证状态
- 同步到 Echo DB 的 `verified` 字段
- 客户端显示蓝V标识

**数据来源**:
- Echo DB (读写): `users.verified`, `chats.verified`
- Echo DB (读写): `verification_records`

---

### 1️⃣6️⃣ 公开用户名管理 ⭐

#### Telegram 客户端真实存在

```java
// TLRPC.User / TLRPC.Chat - 真实字段
class User {
    String username;        // 公开用户名 @username
}

class Chat {
    String username;        // 公开用户名 @username
}
```

#### 后台必须能做的

**公开用户名管理**:
```typescript
interface UsernameManagement {
  // 移除公开用户名（取消公开）
  removePublicUsername(id: string, type: 'user' | 'chat', removal: {
    reason: string;
    removedBy: string;
    note?: string;
  }): void;
  
  // 保留用户名（防止被占用）
  reserveUsername(username: string, reservation: {
    reason: string;
    reservedBy: string;
    expiresAt?: Date;
  }): void;
  
  // 释放保留的用户名
  releaseReservedUsername(username: string, reason: string): void;
  
  // 查看用户名历史
  getUsernameHistory(id: string, type: 'user' | 'chat'): UsernameRecord[];
  
  // 检查用户名是否可用
  checkUsernameAvailability(username: string): {
    available: boolean;
    reason?: string;
    reservedBy?: string;
  };
}
```

**用户名记录**:
```typescript
interface UsernameRecord {
  recordId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  username: string;
  action: 'set' | 'removed' | 'reserved' | 'released';
  reason?: string;
  actionBy: string;
  actionAt: Date;
}
```

**操作功能**:
- 移除公开用户名
- 保留用户名
- 释放保留的用户名
- 查看用户名历史
- 检查用户名可用性
- 批量保留用户名
- 导出用户名列表

**控制粒度**: 用户名级控制

**实现方式**:
- Echo Business Server 维护用户名状态
- 同步到 Echo DB 的 `username` 字段
- 维护保留用户名列表

**数据来源**:
- Echo DB (读写): `users.username`, `chats.username`
- Echo DB (读写): `username_records`, `reserved_usernames`

---

## 🟨 P2 功能详细设计

### 1️⃣7️⃣ 圈子/标签 - 兴趣分类

#### 基于 Telegram 群组的标签系统

**标签管理**:
```typescript
interface CircleTagSystem {
  // 标签定义
  tags: {
    id: string;
    name: string;               // 标签名（如 tech, art, private）
    displayName: string;        // 显示名称
    description: string;
    icon?: string;
    color?: string;
  }[];
  
  // 群组标签
  chatTags: {
    chatId: string;
    tags: string[];             // 标签 ID 列表
    assignedBy: string;         // 分配者
    assignedAt: Date;
  }[];
}
```

**操作功能**:
- 创建/编辑标签
- 为群组分配标签
- 按标签筛选群组
- 标签统计（群组数、活跃度）

**用途**: 未来做"推荐/广场"的基础

**数据来源**:
- Echo DB: `circle_tags`, `chat_tags`

---

### 1️⃣8️⃣ 广场/推荐 - 内容聚合

#### 不干扰 IM 的推荐系统

**推荐机制**:
```typescript
interface RecommendationSystem {
  // 推荐内容
  recommendations: {
    type: 'chat' | 'channel' | 'message';
    targetId: string;
    title: string;
    description: string;
    tags: string[];
    
    // 推荐权重
    weight: number;             // 手动设置
    hotScore: number;           // 热度分数
    
    // 状态
    status: 'active' | 'hidden';
    publishedAt: Date;
  }[];
  
  // 热度计算
  hotScoreFactors: {
    messageCount: number;       // 消息数
    memberGrowth: number;       // 成员增长
    forwardCount: number;       // 转发数
    replyCount: number;         // 回复数
  };
}
```

**操作功能**:
- 手动推荐群组/频道
- 设置推荐权重
- 下架推荐
- 按标签推荐
- 查看推荐效果（点击率、加入率）

**⚠️ 重点**: 广场是"内容层"，IM 是"通信层"——严格分离

**数据来源**:
- Echo DB: `recommendations`, `hot_scores`, `recommendation_clicks`

---

### 1️⃣9️⃣ 内容聚合 - 精选消息

#### 只读的内容聚合

**精选内容**:
```typescript
interface FeaturedContent {
  collectionId: string;
  title: string;
  description: string;
  
  // 精选消息（只转发，不修改）
  messages: {
    messageId: string;
    chatId: string;
    forwardedAt: Date;
  }[];
  
  status: 'draft' | 'published' | 'archived';
}
```

**操作功能**:
- 创建精选合集
- 添加消息到合集（通过转发）
- 发布/下架合集
- 不修改原消息

**数据来源**:
- Echo DB: `featured_collections`, `featured_messages`

---

## 🟩 P3 功能详细设计

### 2️⃣0️⃣ Bot 管理 - 机器人控制

#### Telegram Bot 真实存在

**Bot 控制**:
```typescript
interface BotManagement {
  // Bot 白名单
  allowedBots: {
    botId: string;
    botUsername: string;
    allowedChats: string[];     // 允许使用的群组
    permissions: string[];      // 权限列表
  }[];
  
  // 全局设置
  botsEnabled: boolean;         // 是否允许 Bot
  requireApproval: boolean;     // Bot 需要审批
}
```

**操作功能**:
- 允许/禁止 Bot
- 设置 Bot 白名单
- 限制 Bot 使用范围

**数据来源**:
- Echo DB: `bot_whitelist`, `bot_permissions`

---

### 2️⃣1️⃣ 反滥用自动化 - 行为检测

#### 不看内容的行为检测

**自动化规则**:
```typescript
interface AntiAbuseRules {
  // 注册频率
  registrationRateLimit: {
    maxPerIP: number;           // 单 IP 注册上限
    timeWindow: number;         // 时间窗口（小时）
  };
  
  // 群创建频率
  groupCreationRateLimit: {
    maxPerUser: number;
    timeWindow: number;
  };
  
  // 文件上传频率
  fileUploadRateLimit: {
    maxPerUser: number;
    maxSizePerDay: number;      // 每日上传大小上限
  };
  
  // 自动处理
  autoActions: {
    trigger: string;            // 触发条件
    action: 'warn' | 'freeze' | 'ban';
    duration?: number;          // 持续时间
  }[];
}
```

**数据来源**:
- Echo DB: `abuse_rules`, `abuse_detections`, `auto_actions`

---

### 2️⃣2️⃣ 多节点/灾备 - 高可用

**节点管理**:
```typescript
interface NodeManagement {
  nodes: {
    nodeId: string;
    type: 'gateway' | 'session' | 'bff';
    status: 'online' | 'offline' | 'maintenance';
    load: number;               // 负载
    connections: number;        // 连接数
  }[];
  
  // 流量切换
  trafficRouting: {
    enabled: boolean;
    strategy: 'round-robin' | 'least-connections' | 'weighted';
  };
}
```

---

### 2️⃣3️⃣ 合规工具 - 法律响应

**合规功能**:
```typescript
interface ComplianceTools {
  // 数据导出
  dataExport: {
    userId: string;
    requestedAt: Date;
    status: 'pending' | 'processing' | 'completed';
    downloadUrl?: string;
  }[];
  
  // 数据删除
  dataDeletion: {
    userId: string;
    requestedAt: Date;
    scheduledAt: Date;
    status: 'pending' | 'scheduled' | 'completed';
  }[];
}
```

---

## 📐 技术架构设计

### 数据库设计

**Echo Business DB (PostgreSQL)**:

```sql
-- 用户状态表
CREATE TABLE user_status (
  user_id VARCHAR(255) PRIMARY KEY,
  status VARCHAR(20) NOT NULL,  -- normal, frozen, banned
  risk_level VARCHAR(20),
  banned_at TIMESTAMP,
  banned_by VARCHAR(255),
  ban_reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 推送控制表
CREATE TABLE push_controls (
  id SERIAL PRIMARY KEY,
  entity_type VARCHAR(20) NOT NULL,  -- user, chat, global
  entity_id VARCHAR(255),
  push_enabled BOOLEAN DEFAULT TRUE,
  max_push_per_hour INTEGER,
  reason TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 举报表
CREATE TABLE reports (
  id SERIAL PRIMARY KEY,
  report_type VARCHAR(20) NOT NULL,  -- message, user, chat
  reported_by VARCHAR(255) NOT NULL,
  reported_target VARCHAR(255) NOT NULL,
  reason VARCHAR(50),
  description TEXT,
  message_id VARCHAR(255),
  chat_id VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending',
  handled_by VARCHAR(255),
  handled_at TIMESTAMP,
  action VARCHAR(20),
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 邀请码表
CREATE TABLE invite_codes (
  code VARCHAR(50) PRIMARY KEY,
  created_by VARCHAR(255),
  expires_at TIMESTAMP,
  max_uses INTEGER DEFAULT 1,
  used_count INTEGER DEFAULT 0,
  status VARCHAR(20) DEFAULT 'active',
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 系统推送表
CREATE TABLE system_pushes (
  id SERIAL PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  target_type VARCHAR(20) NOT NULL,
  target_users TEXT[],
  send_at TIMESTAMP,
  sent_at TIMESTAMP,
  delivery_count INTEGER DEFAULT 0,
  created_by VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 系统控制表
CREATE TABLE system_controls (
  key VARCHAR(50) PRIMARY KEY,
  value BOOLEAN NOT NULL,
  updated_by VARCHAR(255),
  updated_at TIMESTAMP DEFAULT NOW()
);
```


### API 设计

**RESTful API 结构**:

```
echo-business-server/
├── /api/admin/
│   ├── /users
│   │   ├── GET    /               # 用户列表
│   │   ├── GET    /:id            # 用户详情
│   │   ├── POST   /:id/freeze     # 冻结用户
│   │   ├── POST   /:id/ban        # 封禁用户
│   │   ├── POST   /:id/unban      # 解封用户
│   │   └── POST   /:id/logout-all # 强制登出
│   │
│   ├── /chats
│   │   ├── GET    /               # 群组列表
│   │   ├── GET    /:id            # 群组详情
│   │   ├── POST   /:id/ban        # 封禁群组
│   │   ├── POST   /:id/dissolve   # 解散群组
│   │   └── POST   /:id/unban      # 解封群组
│   │
│   ├── /files
│   │   ├── GET    /controls       # 文件控制策略
│   │   ├── PUT    /controls       # 更新策略
│   │   └── POST   /controls/emergency # 紧急关闭
│   │
│   ├── /push
│   │   ├── GET    /controls       # 推送控制列表
│   │   ├── PUT    /controls/:id   # 更新推送控制
│   │   ├── POST   /emergency-stop # 紧急关闭推送
│   │   └── POST   /system-push    # 发送系统推送
│   │
│   ├── /reports
│   │   ├── GET    /               # 举报列表
│   │   ├── GET    /:id            # 举报详情
│   │   ├── POST   /:id/handle     # 处理举报
│   │   └── POST   /:id/dismiss    # 驳回举报
│   │
│   ├── /invites
│   │   ├── GET    /codes          # 邀请码列表
│   │   ├── POST   /codes/generate # 生成邀请码
│   │   ├── PUT    /codes/:code    # 更新邀请码
│   │   └── GET    /relationships  # 邀请关系链
│   │
│   ├── /system
│   │   ├── GET    /controls       # 系统开关状态
│   │   ├── PUT    /controls       # 更新系统开关
│   │   └── POST   /emergency      # 紧急模式
│   │
│   └── /metrics
│       ├── GET    /users          # 用户指标
│       ├── GET    /chats          # 群组指标
│       ├── GET    /content        # 内容指标
│       └── GET    /moderation     # 封禁指标
```

---

## 🎨 前端页面结构

### 管理后台页面

```
Echo Admin Panel/
├── 📊 Dashboard (仪表盘)
│   ├── 实时数据概览
│   ├── 关键指标卡片
│   └── 告警通知
│
├── 👥 User Management (用户管理)
│   ├── 用户列表
│   ├── 用户详情
│   ├── 封禁记录
│   └── 风险用户
│
├── 💬 Chat Management (对话管理)
│   ├── 群组列表
│   ├── 频道列表
│   ├── 群组详情
│   └── 封禁记录
│
├── 📁 File Control (文件控制)
│   ├── 控制策略
│   ├── 上传统计
│   └── 存储管理
│
├── 🔔 Push Control (推送控制)
│   ├── 推送开关
│   ├── 用户推送控制
│   ├── 群组推送控制
│   ├── 系统推送
│   └── 推送日志
│
├── 🚨 Reports (举报管理)
│   ├── 待处理举报
│   ├── 已处理举报
│   └── 处理统计
│
├── 🎫 Invites (邀请系统)
│   ├── 邀请码管理
│   ├── 邀请关系链
│   └── 邀请统计
│
├── ⚙️ System (系统设置)
│   ├── 系统开关
│   ├── 紧急控制
│   └── 操作日志
│
└── 📈 Analytics (数据分析)
    ├── 用户分析
    ├── 群组分析
    ├── 内容分析
    └── 自定义报表
```

---

## 🔐 权限设计

### 管理员角色

```typescript
interface AdminRole {
  role: 'super_admin' | 'admin' | 'moderator' | 'viewer';
  
  permissions: {
    // 用户管理
    canViewUsers: boolean;
    canFreezeUsers: boolean;
    canBanUsers: boolean;
    
    // 对话管理
    canViewChats: boolean;
    canBanChats: boolean;
    canDissolveChats: boolean;
    
    // 文件控制
    canControlFiles: boolean;
    
    // 推送控制
    canControlPush: boolean;
    canSendSystemPush: boolean;
    
    // 举报处理
    canViewReports: boolean;
    canHandleReports: boolean;
    
    // 邀请系统
    canManageInvites: boolean;
    
    // 系统控制
    canControlSystem: boolean;
    canUseEmergency: boolean;
    
    // 数据分析
    canViewAnalytics: boolean;
    canExportData: boolean;
  };
}
```

**角色权限矩阵**:

| 功能 | Super Admin | Admin | Moderator | Viewer |
|------|-------------|-------|-----------|--------|
| 查看用户 | ✅ | ✅ | ✅ | ✅ |
| 冻结用户 | ✅ | ✅ | ✅ | ❌ |
| 封禁用户 | ✅ | ✅ | ❌ | ❌ |
| 解散群组 | ✅ | ✅ | ❌ | ❌ |
| 文件控制 | ✅ | ✅ | ✅ | ❌ |
| 推送控制 | ✅ | ✅ | ✅ | ❌ |
| 处理举报 | ✅ | ✅ | ✅ | ❌ |
| 邀请管理 | ✅ | ✅ | ❌ | ❌ |
| 系统控制 | ✅ | ✅ | ❌ | ❌ |
| 紧急开关 | ✅ | ❌ | ❌ | ❌ |
| 数据导出 | ✅ | ✅ | ❌ | ❌ |

---

## 🚀 实施路线图

### Phase 1: P0 核心功能（3-4 周）

**Week 1-2**:
- ✅ 用户管理（列表、详情、封禁）
- ✅ 风控系统（IP/设备封禁）
- ✅ 对话管理（群组列表、封禁、解散）
- ✅ **诈骗/虚假标记** ⭐ (新增)

**Week 3**:
- ✅ 文件控制（上传开关、类型限制）
- ✅ 搜索控制（可发现性）
- ✅ 举报管理（列表、处理）
- ✅ **消息类型控制** ⭐ (新增)

**Week 4**:
- ✅ 推送控制（总开关、用户级、群组级）
- ✅ 系统开关（紧急控制）

**验收标准**:
- 可以封禁/解封用户
- 可以解散/封禁群组
- 可以关闭文件上传
- 可以处理举报
- **可以控制推送是否发生**
- **可以标记诈骗/虚假用户和群组** ⭐
- **可以按群组控制消息类型** ⭐
- 可以一键紧急止血

---

### Phase 2: P1 差异化功能（2-3 周）

**Week 5**:
- ✅ 邀请系统（邀请码生成、管理）
- ✅ 权限边界（群组权限控制）
- ✅ **验证标记管理** ⭐ (新增)

**Week 6**:
- ✅ 系统推送（非聊天推送）
- ✅ 数据统计（DAU/MAU、基础指标）
- ✅ **用户名管理** ⭐ (新增)

**验收标准**:
- 可以生成和管理邀请码
- 可以设置群组权限边界
- 可以发送系统推送
- 可以查看基础数据指标
- **可以验证用户/群组（蓝V）** ⭐
- **可以保留/移除公开用户名** ⭐

---

### Phase 3: P2 运营扩展（2 周）

**Week 7**:
- ✅ 圈子/标签系统
- ✅ 广场/推荐

**Week 8**:
- ✅ 内容聚合
- ✅ 推荐算法优化

---

### Phase 4: P3 长期规划（按需）

- Bot 管理
- 反滥用自动化
- 多节点/灾备
- 合规工具

---

## 📋 开发检查清单

### 架构检查

- [ ] Echo Business Server 独立部署
- [ ] 使用独立的 PostgreSQL 数据库
- [ ] Echo DB 只读访问
- [ ] 通过事件/gRPC 与 Echo 通信
- [ ] 业务层故障不影响 IM 核心

### 功能检查

**P0 功能**:
- [ ] 用户管理（封禁、冻结、强制登出）
- [ ] 风控系统（IP/设备封禁）
- [ ] 对话管理（解散群、封禁群）
- [ ] 文件控制（上传开关）
- [ ] 搜索控制（可发现性）
- [ ] 举报管理（处理举报）
- [ ] **推送控制（总开关、用户级、群组级、风控）** ⭐
- [ ] **诈骗/虚假标记（用户和群组标记管理）** ⭐
- [ ] **消息类型控制（按群组禁用特定类型）** ⭐
- [ ] 系统开关（紧急止血）

**P1 功能**:
- [ ] 邀请系统
- [ ] 权限边界
- [ ] 系统推送
- [ ] 数据统计
- [ ] **验证标记（蓝V管理）** ⭐
- [ ] **用户名管理（保留/移除公开用户名）** ⭐

### 推送功能专项检查 ⭐

- [ ] 全局推送开关可用
- [ ] 用户级推送控制可用
- [ ] 群组级推送控制可用
- [ ] 推送频率限制生效
- [ ] 紧急熔断功能可用
- [ ] 系统推送（非聊天）可发送
- [ ] 推送日志完整记录
- [ ] **不自定义聊天推送文案**
- [ ] **不绕过 Telegram 推送系统**
- [ ] **只控制推送是否发生，不控制内容**

### 安全检查

- [ ] 管理员权限控制
- [ ] 操作日志记录
- [ ] 敏感操作二次确认
- [ ] API 访问鉴权
- [ ] 数据脱敏显示

### 性能检查

- [ ] 用户列表分页加载
- [ ] 群组列表分页加载
- [ ] 数据统计使用缓存
- [ ] 大量操作使用队列
- [ ] 数据库查询优化

---

## ✅ 总结

### 核心原则（必须遵守）

1. **控制"权力边界"，不是"功能细节"**
2. **Echo 不控制"推送说什么"，只控制"推送会不会发生"** ⭐
3. **被动治理，不主动扫描**
4. **行为层控制，不碰加密内容**
5. **平台级开关，紧急止血**

### 三条生存线（P0 核心）⭐⭐⭐

1. **搜索与可发现性是 P0** - 不做就会失控（垃圾号、黑产、骚扰）
2. **会话强制登出是 P0** - 不做就没法真正封禁/止血
3. **后台只管"推送是否发生"，不碰"聊天推送内容"** - 保持 Telegram 体验

### 推送控制核心要点 ⭐⭐⭐

**必须做的**:
- ✅ 控制推送是否发生
- ✅ 用户级推送资格控制
- ✅ 群组级推送许可
- ✅ 推送频率风控
- ✅ 全局推送开关
- ✅ 系统推送（非聊天）可自定义

**不能做的**:
- ❌ 自定义聊天推送文案
- ❌ 分析消息内容决定推送
- ❌ 绕过 Telegram 推送系统

### 功能优先级

**立即实施 (P0) - 12项生存级功能**:
1. 用户管理
2. 风控系统
3. 对话管理
4. 文件控制
5. **搜索与可发现性** ⭐⭐⭐ (生存线)
6. **会话管理（强制登出）** ⭐⭐⭐ (生存线)
7. **平台隐私策略** ⭐
8. 内容治理
9. **推送控制** ⭐⭐⭐ (生存线)
10. **诈骗/虚假标记** ⭐
11. **消息类型控制** ⭐
12. 系统开关

**强烈建议 (P1)**:
13. 邀请系统
14. 权限边界
15. 系统推送
16. 数据统计
17. **验证标记** ⭐
18. **用户名管理** ⭐

**可选 (P2-P3)**:
19-25. 运营扩展和长期规划

### 下一步行动

1. ✅ 完成 Echo Server 部署
2. 🔄 搭建 Echo Business Server 框架
3. 🔄 实现 P0 核心功能（含推送控制）
4. ⏳ 实现 P1 差异化功能
5. ⏳ 按需实现 P2-P3 功能

---

**最后更新**: 2026-01-27  
**状态**: 管理后台功能规划完成（含推送控制完整设计）

