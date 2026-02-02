# Echo IM - 管理后台信息架构 (IA)

**日期**: 2026-01-27  
**版本**: 1.0  
**用途**: 可直接用于拆 PRD、排迭代、开工

---

## 🎯 核心原则

1. **不看私聊内容、不做内容扫描**
2. **后台只做：开关 / 限制 / 治理 / 审计**
3. **三样必备**:
   - ✅ 审计日志（可追责）
   - ✅ 策略中心（可控阈值/黑白名单/限流模板）
   - ✅ 告警闭环（出了事能第一时间知道并止血）

---

## 📐 完整菜单结构

```
Echo Admin Panel/
├── 📊 P0 - 平台生存级
│   ├── /dashboard                    # 总览仪表盘
│   ├── /users                        # 用户管理
│   │   └── /users/:id                # 用户详情
│   ├── /chats                        # 群组/频道管理
│   │   └── /chats/:id                # 群组详情
│   ├── /reports                      # 举报与治理
│   │   └── /reports/:id              # 举报详情
│   ├── /push                         # 推送控制
│   ├── /policies                     # 策略中心
│   ├── /killswitch                   # 紧急开关
│   ├── /audit-logs                   # 审计日志
│   ├── /marks                        # 诈骗/虚假标记 ⭐
│   ├── /message-types                # 消息类型控制 ⭐
│   └── /admin-security               # 管理员安全
│
├── 🟧 P1 - 平台差异化
│   ├── /invites                      # 邀请系统
│   ├── /announcements                # 公告与运营
│   ├── /remote-config                # 客户端配置下发
│   ├── /analytics/basic              # 基础统计
│   ├── /verifications                # 验证标记（蓝V）⭐
│   └── /usernames                    # 公开用户名管理 ⭐
│
├── 🟨 P2 - 运营扩展
│   ├── /square/pool                  # 广场内容池
│   ├── /square/moderation            # 广场审核
│   └── /ads (optional)               # 广告位管理
│
└── 🟩 P3 - 长期规划
    ├── /automation                   # 反滥用自动化
    ├── /infra/nodes                  # 多节点/灾备
    └── /compliance                   # 合规工具
```

---

## 🟥 P0 - 平台生存级（MVP 必须上线）

### 0. Dashboard - 总览仪表盘

**路由**: `/dashboard`

**目的**: 一眼看到平台是否健康、是否需要止血

#### 页面模块

**实时指标卡片**:
```typescript
interface DashboardMetrics {
  // 用户指标
  onlineUsers: number;          // 当前在线
  dau: number;                  // 日活
  
  // 性能指标
  messageTPS: number;           // 消息 TPS
  uploadTPS: number;            // 上传 TPS
  pushFailureRate: number;      // 推送失败率 (%)
  
  // 注册/登录
  registrationRate: number;     // 注册成功率
  loginFailureRate: number;     // 登录失败率
}
```

**风险指标**:
```typescript
interface RiskMetrics {
  bannedUsersToday: number;     // 今日封禁数
  pendingReports: number;       // 待处理举报
  abnormalRegistration: boolean;// 异常注册峰值
  abnormalGroupCreation: boolean;// 异常建群峰值
  abnormalUpload: boolean;      // 异常上传峰值
}
```

**系统状态**:
```typescript
interface SystemStatus {
  nodes: {
    gateway: 'healthy' | 'degraded' | 'down';
    session: 'healthy' | 'degraded' | 'down';
    bff: 'healthy' | 'degraded' | 'down';
  };
  queue: {
    backlog: number;            // 队列积压数
    status: 'normal' | 'warning' | 'critical';
  };
  database: {
    connections: number;
    maxConnections: number;
    status: 'normal' | 'warning' | 'critical';
  };
  pushGateway: {
    fcm: 'online' | 'offline';
    apns: 'online' | 'offline';
  };
}
```

#### 操作按钮

- **一键进入"紧急开关"** (红色按钮)
- **一键进入"告警事件"** (黄色按钮)
- **刷新数据** (实时更新)

---

### 1. 用户管理

#### 1.1 用户列表

**路由**: `/users`

**字段**:
```typescript
interface UserListItem {
  userId: string;               // 内部 ID（不显示）
  phone: string;                // 手机号（脱敏：138****5678）
  username?: string;            // @username
  displayName: string;          // 显示名称
  registeredAt: Date;           // 注册时间
  lastActiveAt: Date;           // 最后活跃
  status: 'normal' | 'frozen' | 'banned';  // 账号状态
  riskLevel: 'none' | 'low' | 'medium' | 'high';  // 风险等级
  deviceCount: number;          // 设备数量
  groupCount: number;           // 加入的群数
  createdGroupCount: number;    // 创建的群数
}
```

**筛选条件**:
- 状态（正常/冻结/封禁）
- 风险等级
- 注册时间范围
- 最后活跃时间范围
- 搜索（手机号/username）

**批量操作**:
- 批量冻结
- 批量封禁
- 批量加入黑名单
- 导出列表

**单项操作**:
- 冻结/解冻
- 封禁/解封
- 强制登出所有设备
- 加入黑名单/白名单
- 添加备注
- 查看详情


#### 1.2 用户详情页

**路由**: `/users/:id`

**基本信息**:
```typescript
interface UserDetail {
  // 基本信息
  userId: string;
  phone: string;
  username?: string;
  displayName: string;
  bio?: string;
  avatar?: string;
  
  // 注册信息
  registeredAt: Date;
  registrationIP: string;       // 注册 IP
  registrationCountry: string;  // 国家/地区
  
  // 状态信息
  status: 'normal' | 'frozen' | 'banned';
  riskLevel: 'none' | 'low' | 'medium' | 'high';
  lastActiveAt: Date;
  
  // 统计信息
  deviceCount: number;
  groupCount: number;
  createdGroupCount: number;
}
```

**设备会话列表**:
```typescript
interface DeviceSession {
  sessionId: string;
  deviceType: 'android' | 'ios' | 'desktop' | 'web';
  clientVersion: string;
  lastActiveAt: Date;
  lastIP: string;
  lastCountry: string;
  status: 'online' | 'offline';
}
```

**行为统计**:
```typescript
interface UserBehaviorStats {
  // 24小时统计
  last24h: {
    messagesSent: number;
    groupsCreated: number;
    filesUploaded: number;
    uploadSize: number;         // MB
  };
  
  // 7天统计
  last7d: {
    messagesSent: number;
    groupsCreated: number;
    filesUploaded: number;
    uploadSize: number;
  };
}
```

**风险事件**:
```typescript
interface RiskEvent {
  eventId: string;
  type: 'rate_limit' | 'abnormal_behavior' | 'reported';
  description: string;
  triggeredAt: Date;
  action: 'warned' | 'frozen' | 'banned';
}
```

**举报关联**:
```typescript
interface ReportRelation {
  reportedByOthers: number;     // 被举报次数
  reportedOthers: number;       // 举报他人次数
  recentReports: {
    reportId: string;
    type: 'reporter' | 'reported';
    reason: string;
    createdAt: Date;
    status: string;
  }[];
}
```

**操作按钮**:
- 冻结/解冻账号
- 封禁/解封账号
- 强制登出所有设备
- 解除特定设备会话
- 设置用户限额（上传大小/频率）
- 加入黑名单/白名单
- 添加/编辑备注
- **标记为诈骗/虚假** ⭐ (新增)
- **验证用户（蓝V）** ⭐ (新增)
- 查看审计日志

---

### 2. 群组/频道管理

#### 2.1 群组/频道列表

**路由**: `/chats`

**字段**:
```typescript
interface ChatListItem {
  chatId: string;
  type: 'group' | 'supergroup' | 'channel';
  title: string;
  creator: string;              // 创建者 username
  creatorId: string;
  memberCount: number;
  createdAt: Date;
  isPublic: boolean;            // 是否公开
  username?: string;            // 公开链接 @username
  discoverable: boolean;        // 可发现性
  mediaEnabled: boolean;        // 媒体许可
  status: 'normal' | 'restricted' | 'banned';
  riskLevel: 'none' | 'low' | 'medium' | 'high';
}
```

**筛选条件**:
- 类型（群/超级群/频道）
- 状态（正常/受限/封禁）
- 可发现性
- 成员数范围
- 创建时间范围
- 搜索（群名称/username）

**批量操作**:
- 批量设置不可搜索
- 批量关闭媒体上传
- 批量封禁
- 导出列表

**单项操作**:
- 限制群（禁言新成员/限制发言）
- 关闭媒体上传
- 设置不可搜索
- 封禁/解封群
- 解散群（高风险，二次确认）
- 查看详情

#### 2.2 群组/频道详情页

**路由**: `/chats/:id`

**基本信息**:
```typescript
interface ChatDetail {
  chatId: string;
  type: 'group' | 'supergroup' | 'channel';
  title: string;
  description?: string;
  avatar?: string;
  
  // 创建信息
  creator: string;
  creatorId: string;
  createdAt: Date;
  
  // 公开信息
  isPublic: boolean;
  username?: string;
  inviteLink?: string;
  
  // 状态
  status: 'normal' | 'restricted' | 'banned';
  riskLevel: 'none' | 'low' | 'medium' | 'high';
  
  // 权限设置
  discoverable: boolean;
  mediaEnabled: boolean;
  forwardEnabled: boolean;
  newMemberCanSpeak: boolean;
  
  // 统计
  memberCount: number;
  adminCount: number;
}
```

**管理员列表**:
```typescript
interface ChatAdmin {
  userId: string;
  username: string;
  role: 'creator' | 'admin';
  addedAt: Date;
}
```

**活跃统计**:
```typescript
interface ChatActivityStats {
  last24h: {
    messageCount: number;
    fileCount: number;
    joinCount: number;
    leaveCount: number;
    activeMembers: number;
  };
}
```

**举报汇总**:
```typescript
interface ChatReportSummary {
  totalReports: number;
  pendingReports: number;
  resolvedReports: number;
  recentReports: {
    reportId: string;
    reason: string;
    createdAt: Date;
    status: string;
  }[];
}
```

**风险记录**:
```typescript
interface ChatRiskRecord {
  rateLimitTriggered: number;
  bannedHistory: {
    bannedAt: Date;
    bannedBy: string;
    reason: string;
    unbannedAt?: Date;
  }[];
}
```

**操作按钮**:
- 限制群权限
- 关闭/开启媒体上传
- 设置可发现性
- 封禁/解封群
- 解散群（高风险，二次确认）
- 导出成员列表（仅 user_id/username，不导内容）
- **标记为诈骗/虚假** ⭐ (新增)
- **验证群组（蓝V）** ⭐ (新增)
- **设置消息类型限制** ⭐ (新增)
- **移除公开用户名** ⭐ (新增)
- 查看审计日志

---

### 3. 举报与治理

#### 3.1 举报队列

**路由**: `/reports`

**字段**:
```typescript
interface ReportListItem {
  reportId: string;
  type: 'user' | 'chat' | 'message';
  
  // 举报信息
  reportedBy: string;           // 举报人 username
  reportedById: string;
  reportedTarget: string;       // 被举报对象
  reportedTargetId: string;
  
  // 来源
  sourceChat?: string;          // 所在群组
  sourceChatId?: string;
  messageId?: string;           // 消息 ID（不显示内容）
  
  // 原因
  reason: 'spam' | 'harassment' | 'violence' | 'pornography' | 'illegal' | 'other';
  description?: string;
  
  // 状态
  status: 'pending' | 'processing' | 'resolved' | 'dismissed' | 'appealed';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  
  // 处理信息
  assignedTo?: string;          // 处理人
  createdAt: Date;
  updatedAt: Date;
}
```

**筛选条件**:
- 状态（待处理/处理中/已结案/已驳回/申诉中）
- 类型（用户/群/消息）
- 原因分类
- 优先级
- 处理人
- 时间范围

**批量操作**:
- 批量分配处理人
- 批量标记优先级
- 导出报表

**单项操作**:
- 分配处理人
- 标记优先级
- 开始处理
- 查看详情


#### 3.2 举报详情（工单化）

**路由**: `/reports/:id`

**举报信息**:
```typescript
interface ReportDetail {
  reportId: string;
  type: 'user' | 'chat' | 'message';
  
  // 举报人信息卡
  reporter: {
    userId: string;
    username: string;
    reportCount: number;        // 历史举报次数
    reportSuccessRate: number;  // 举报成功率
  };
  
  // 被举报对象信息卡
  reported: {
    id: string;
    type: 'user' | 'chat';
    name: string;
    violationCount: number;     // 历史违规次数
    lastViolation?: Date;
    riskLevel: string;
  };
  
  // 举报详情
  reason: string;
  description: string;
  evidence: {
    messageId?: string;         // 消息 ID（不显示内容）
    chatId?: string;
    screenshots?: string[];     // 截图 URL
  };
  
  // 状态
  status: string;
  priority: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**处理动作记录**:
```typescript
interface ReportAction {
  actionId: string;
  actionType: 'delete_message' | 'mute_user' | 'ban_user' | 'ban_chat' | 'warn' | 'dismiss';
  actionBy: string;
  actionAt: Date;
  reason: string;
  evidence: string[];           // 证据留存（截图/引用 ID）
  
  // 动作参数
  duration?: number;            // 禁言/封禁时长（小时）
  note?: string;
}
```

**复核记录**:
```typescript
interface ReviewRecord {
  reviewId: string;
  reviewedBy: string;
  reviewedAt: Date;
  decision: 'upheld' | 'overturned' | 'modified';
  reason: string;
  newAction?: string;
}
```

**操作按钮**:
- **处理动作**:
  - 删除消息（revoke）
  - 禁言用户（临时/永久）
  - 冻结用户
  - 封禁用户
  - 封禁群组
  - 警告（记录但不处罚）
  - 驳回举报
- **流程操作**:
  - 分配给其他人
  - 标记优先级
  - 提交复核
  - 回滚动作（如果误封）
  - 添加备注
  - 上传证据

---

### 4. 推送控制

**路由**: `/push`

#### 4.1 推送总控台

**全局推送状态**:
```typescript
interface PushGlobalStatus {
  // 推送网关状态
  gateway: {
    fcm: {
      status: 'online' | 'offline' | 'degraded';
      successRate: number;      // 成功率 (%)
      avgLatency: number;       // 平均延迟 (ms)
    };
    apns: {
      status: 'online' | 'offline' | 'degraded';
      successRate: number;
      avgLatency: number;
    };
  };
  
  // 推送量统计
  stats: {
    last1h: {
      total: number;
      success: number;
      failed: number;
      failureRate: number;
    };
    last24h: {
      total: number;
      success: number;
      failed: number;
      failureRate: number;
    };
  };
  
  // 失败原因分布
  failureReasons: {
    reason: string;             // FCM/APNs 错误码
    count: number;
    percentage: number;
  }[];
  
  // 熔断状态
  circuitBreaker: {
    enabled: boolean;
    triggeredAt?: Date;
    triggeredBy?: string;
    reason?: string;
  };
}
```

**操作按钮（P0 必须）**:
- **全局关闭聊天推送（熔断）** - 红色按钮，二次确认
- **按群关闭推送** - 跳转到群组推送控制
- **按用户关闭推送** - 跳转到用户推送控制
- **推送限频策略** - 跳转到策略中心
- **查看推送日志**

#### 4.2 用户推送控制

**字段**:
```typescript
interface UserPushControl {
  userId: string;
  username: string;
  pushEnabled: boolean;
  reason?: string;              // 禁用原因
  
  // 限频设置
  maxPushPerHour: number;
  maxPushPerDay: number;
  cooldownSeconds: number;      // 冷却期（新用户）
  
  // 统计
  last24hPushCount: number;
  last24hBlockedCount: number;  // 被限频次数
  
  updatedBy: string;
  updatedAt: Date;
}
```

**操作**:
- 启用/禁用推送
- 设置限频参数
- 设置冷却期
- 批量操作

#### 4.3 群组推送控制

**字段**:
```typescript
interface ChatPushControl {
  chatId: string;
  chatTitle: string;
  pushEnabled: boolean;
  silentMode: boolean;          // 静默模式
  
  // 限频设置
  maxPushPerHour: number;
  
  // 统计
  last24hPushCount: number;
  last24hBlockedCount: number;
  
  updatedBy: string;
  updatedAt: Date;
}
```

**操作**:
- 启用/禁用推送
- 设置静默模式
- 设置限频参数
- 批量操作

#### 4.4 系统推送（非聊天）

**创建系统推送**:
```typescript
interface SystemPushCreate {
  type: 'announcement' | 'maintenance' | 'security' | 'invite' | 'system';
  
  // 推送内容（可自定义）
  title: string;                // 最多 50 字
  body: string;                 // 最多 200 字
  icon?: string;                // 图标 URL
  
  // 目标用户
  targetType: 'all' | 'specific' | 'group' | 'filter';
  targetUsers?: string[];       // 特定用户 ID
  targetGroups?: string[];      // 特定群组的成员
  targetFilter?: {              // 筛选条件
    registeredAfter?: Date;
    registeredBefore?: Date;
    riskLevel?: string[];
    status?: string[];
  };
  
  // 推送时间
  sendNow: boolean;
  sendAt?: Date;                // 定时推送
  
  // 跳转
  action?: {
    type: 'url' | 'chat' | 'user' | 'none';
    value?: string;
  };
}
```

**系统推送历史**:
```typescript
interface SystemPushHistory {
  pushId: string;
  type: string;
  title: string;
  targetType: string;
  targetCount: number;          // 目标用户数
  deliveredCount: number;       // 送达数
  deliveryRate: number;         // 送达率 (%)
  clickCount: number;           // 点击数
  clickRate: number;            // 点击率 (%)
  createdBy: string;
  createdAt: Date;
  sentAt?: Date;
  status: 'draft' | 'scheduled' | 'sending' | 'sent' | 'failed';
}
```

**操作**:
- 创建新推送
- 编辑草稿
- 删除草稿
- 立即发送
- 取消定时推送
- 查看详情和统计

---

### 5. 策略中心

**路由**: `/policies`

#### 5.1 全局策略

**注册策略**:
```typescript
interface RegistrationPolicy {
  enabled: boolean;
  
  // 速率限制
  maxPerIP: number;             // 单 IP 注册上限
  maxPerDevice: number;         // 单设备注册上限
  timeWindow: number;           // 时间窗口（小时）
  
  // 冷却期
  newUserCooldown: {
    canCreateGroup: boolean;
    cooldownHours: number;
    canUploadFile: boolean;
    uploadLimitMB: number;
  };
}
```

**登录策略**:
```typescript
interface LoginPolicy {
  enabled: boolean;
  
  // 失败阈值
  maxFailedAttempts: number;
  lockoutDuration: number;      // 锁定时长（分钟）
  
  // 异常检测
  detectAbnormalLocation: boolean;
  detectAbnormalDevice: boolean;
}
```

**建群策略**:
```typescript
interface GroupCreationPolicy {
  enabled: boolean;
  
  // 频率限制
  maxPerUser: number;
  maxPerDay: number;
  
  // 新群默认设置
  defaultPrivate: boolean;      // 默认不可搜索
  defaultMediaDisabled: boolean;// 默认禁止媒体
  requireApproval: boolean;     // 需要审批
}
```

**上传策略**:
```typescript
interface UploadPolicy {
  enabled: boolean;
  
  // 频率限制
  maxPerUser: number;           // 每用户每分钟
  maxPerChat: number;           // 每群每分钟
  maxPerDay: number;            // 每用户每天
  
  // 大小限制
  maxFileSizeMB: number;
  maxImageSizeMB: number;
  maxVideoSizeMB: number;
  
  // 类型限制
  allowedTypes: ('image' | 'video' | 'document' | 'audio')[];
}
```

**推送策略**:
```typescript
interface PushPolicy {
  enabled: boolean;
  
  // 触发频率限制
  maxPerUser: number;           // 每用户每小时
  maxPerChat: number;           // 每群每小时
  
  // 自动静默
  autoSilentThreshold: {
    messagesPerMinute: number;
    silentDuration: number;     // 静默持续时间（秒）
  };
}
```

**操作**:
- 编辑策略参数
- 启用/停用策略
- 恢复默认值
- 查看策略历史
- 导出策略配置

#### 5.2 黑白名单

**用户黑白名单**:
```typescript
interface UserBlacklist {
  userId: string;
  username: string;
  type: 'blacklist' | 'whitelist';
  reason: string;
  addedBy: string;
  addedAt: Date;
  expiresAt?: Date;             // 有效期（临时）
  note?: string;
}
```

**群组黑白名单**:
```typescript
interface ChatBlacklist {
  chatId: string;
  chatTitle: string;
  type: 'blacklist' | 'whitelist';
  reason: string;
  addedBy: string;
  addedAt: Date;
  expiresAt?: Date;
  note?: string;
}
```

**IP 黑白名单**:
```typescript
interface IPBlacklist {
  ipRange: string;              // IP 或 IP 段
  type: 'blacklist' | 'whitelist';
  reason: string;
  addedBy: string;
  addedAt: Date;
  expiresAt?: Date;
  note?: string;
}
```

**操作**:
- 添加到黑名单/白名单
- 移除
- 设置有效期
- 批量导入
- 导出列表
- 搜索和筛选

---

### 6. 紧急开关（止血面板）

**路由**: `/killswitch`

**⚠️ 高风险操作，所有开关切换必须二次确认并记录审计日志**

**开关列表**:
```typescript
interface EmergencySwitch {
  key: string;
  name: string;
  description: string;
  enabled: boolean;
  lastChangedBy: string;
  lastChangedAt: Date;
  impact: 'critical' | 'high' | 'medium';
}
```

**P0 必须开关**:

1. **关闭新注册**
   - Key: `registration_enabled`
   - 影响: 禁止新用户注册
   - 场景: 遭受注册攻击

2. **仅邀请模式**
   - Key: `invite_only_mode`
   - 影响: 只能通过邀请码注册
   - 场景: 控制用户增长

3. **关闭新建群/频道**
   - Key: `group_creation_enabled`
   - 影响: 禁止创建新群和频道
   - 场景: 群组滥用

4. **关闭媒体上传**
   - Key: `file_upload_enabled`
   - 影响: 全局禁止上传文件
   - 场景: 内容事故、存储压力

5. **全站只读模式**
   - Key: `read_only_mode`
   - 影响: 只能查看，不能发送消息
   - 场景: 紧急维护、严重事故

6. **关闭聊天推送（熔断）**
   - Key: `push_enabled`
   - 影响: 关闭所有聊天推送
   - 场景: 推送系统故障、推送滥用

7. **维护模式**
   - Key: `maintenance_mode`
   - 影响: 所有功能暂停，显示维护公告
   - 场景: 系统维护、重大升级

**操作**:
- 切换开关（二次确认）
- 查看开关历史
- 批量操作（谨慎）
- 设置维护公告内容

**页面布局**:
```
┌─────────────────────────────────────────┐
│  ⚠️  紧急开关 - 高风险操作区域            │
├─────────────────────────────────────────┤
│  🔴 关闭新注册          [ON]  [OFF]      │
│  🔴 仅邀请模式          [ON]  [OFF]      │
│  🔴 关闭新建群/频道     [ON]  [OFF]      │
│  🔴 关闭媒体上传        [ON]  [OFF]      │
│  🔴 全站只读模式        [ON]  [OFF]      │
│  🔴 关闭聊天推送        [ON]  [OFF]      │
│  🔴 维护模式            [ON]  [OFF]      │
└─────────────────────────────────────────┘
```

---

### 7. 审计日志

**路由**: `/audit-logs`

**字段**:
```typescript
interface AuditLog {
  logId: string;
  
  // 操作人
  operatorId: string;
  operatorUsername: string;
  operatorRole: string;
  operatorIP: string;
  
  // 操作信息
  action: string;               // 操作类型
  actionCategory: 'user' | 'chat' | 'policy' | 'system' | 'push' | 'report';
  
  // 操作对象
  targetType: 'user' | 'chat' | 'policy' | 'switch' | 'report';
  targetId: string;
  targetName: string;
  
  // 变更内容
  changes: {
    field: string;
    before: any;
    after: any;
  }[];
  
  // 元数据
  reason?: string;              // 操作原因
  note?: string;                // 备注
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  
  createdAt: Date;
}
```

**操作类型枚举**:
```typescript
enum AuditAction {
  // 用户操作
  USER_FREEZE = 'user.freeze',
  USER_UNFREEZE = 'user.unfreeze',
  USER_BAN = 'user.ban',
  USER_UNBAN = 'user.unban',
  USER_LOGOUT_ALL = 'user.logout_all',
  USER_BLACKLIST_ADD = 'user.blacklist.add',
  USER_WHITELIST_ADD = 'user.whitelist.add',
  
  // 群组操作
  CHAT_BAN = 'chat.ban',
  CHAT_UNBAN = 'chat.unban',
  CHAT_DISSOLVE = 'chat.dissolve',
  CHAT_RESTRICT = 'chat.restrict',
  CHAT_MEDIA_DISABLE = 'chat.media.disable',
  
  // 策略操作
  POLICY_UPDATE = 'policy.update',
  POLICY_ENABLE = 'policy.enable',
  POLICY_DISABLE = 'policy.disable',
  
  // 系统开关
  SWITCH_TOGGLE = 'switch.toggle',
  EMERGENCY_MODE = 'emergency.mode',
  
  // 推送操作
  PUSH_GLOBAL_DISABLE = 'push.global.disable',
  PUSH_USER_DISABLE = 'push.user.disable',
  PUSH_CHAT_DISABLE = 'push.chat.disable',
  SYSTEM_PUSH_SEND = 'system_push.send',
  
  // 举报处理
  REPORT_HANDLE = 'report.handle',
  REPORT_DISMISS = 'report.dismiss',
  REPORT_REVIEW = 'report.review',
}
```

**筛选条件**:
- 操作人
- 操作类型
- 操作分类
- 风险等级
- 时间范围
- 搜索（目标对象）

**操作**:
- 查看详情
- 导出日志
- 高危操作标红显示
- 按操作人统计

**页面特性**:
- 高危操作（critical）标红
- 变更内容 diff 对比显示
- 支持按时间线查看
- 支持关联查询（查看某个对象的所有操作历史）

---

### 8. 诈骗/虚假标记管理 ⭐

**路由**: `/marks`

#### 8.1 标记列表

**字段**:
```typescript
interface MarkListItem {
  markId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  markType: 'scam' | 'fake';
  reason: string;
  markedBy: string;
  markedAt: Date;
  status: 'active' | 'removed';
}
```

**筛选条件**:
- 标记类型（诈骗/虚假）
- 目标类型（用户/群组）
- 状态（活跃/已移除）
- 标记人
- 时间范围

**操作**:
- 查看详情
- 移除标记
- 导出列表

#### 8.2 标记详情

**字段**:
```typescript
interface MarkDetail {
  markId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  markType: 'scam' | 'fake';
  
  // 标记信息
  reason: string;
  evidence: string[];         // 证据（截图URL/举报ID）
  markedBy: string;
  markedAt: Date;
  
  // 移除信息
  removedBy?: string;
  removedAt?: Date;
  removeReason?: string;
  
  status: 'active' | 'removed';
}
```

**操作**:
- 移除标记
- 添加证据
- 查看目标详情
- 查看审计日志

---

### 9. 消息类型控制 ⭐

**路由**: `/message-types`

#### 9.1 群组消息类型限制列表

**字段**:
```typescript
interface MessageTypeRestrictionListItem {
  chatId: string;
  chatTitle: string;
  
  // 限制开关
  photosDisabled: boolean;
  videosDisabled: boolean;
  filesDisabled: boolean;
  voiceDisabled: boolean;
  stickersDisabled: boolean;
  gifsDisabled: boolean;
  pollsDisabled: boolean;
  linksDisabled: boolean;
  
  updatedBy: string;
  updatedAt: Date;
}
```

**筛选条件**:
- 群组名称
- 限制类型
- 更新人
- 时间范围

**批量操作**:
- 批量设置限制
- 批量移除限制
- 导出配置

**单项操作**:
- 编辑限制
- 移除限制
- 查看详情

#### 9.2 消息类型限制详情

**字段**:
```typescript
interface MessageTypeRestrictionDetail {
  chatId: string;
  chatTitle: string;
  
  // 当前限制
  restrictions: {
    photos: boolean;
    videos: boolean;
    files: boolean;
    voice: boolean;
    stickers: boolean;
    gifs: boolean;
    polls: boolean;
    links: boolean;
  };
  
  reason: string;
  updatedBy: string;
  updatedAt: Date;
  
  // 历史记录
  history: {
    changedAt: Date;
    changedBy: string;
    changes: Record<string, boolean>;
  }[];
}
```

**操作**:
- 编辑限制
- 移除所有限制
- 查看历史
- 查看审计日志

#### 9.3 全局消息类型策略

**字段**:
```typescript
interface GlobalMessageTypePolicy {
  messageType: string;
  disabled: boolean;
  reason: string;
  updatedBy: string;
  updatedAt: Date;
}
```

**操作**:
- 全局禁用消息类型
- 启用消息类型
- 设置新群默认限制

---

### 10. 验证标记管理（蓝V）⭐

**路由**: `/verifications`

#### 10.1 验证列表

**字段**:
```typescript
interface VerificationListItem {
  verificationId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  reason: string;
  verifiedBy: string;
  verifiedAt: Date;
  status: 'active' | 'removed';
}
```

**筛选条件**:
- 目标类型（用户/群组）
- 状态（活跃/已移除）
- 验证人
- 时间范围

**操作**:
- 查看详情
- 移除验证
- 导出列表

#### 10.2 验证详情

**字段**:
```typescript
interface VerificationDetail {
  verificationId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  
  // 验证信息
  reason: string;
  verifiedBy: string;
  verifiedAt: Date;
  note?: string;
  
  // 移除信息
  removedBy?: string;
  removedAt?: Date;
  removeReason?: string;
  
  status: 'active' | 'removed';
}
```

**操作**:
- 移除验证
- 编辑备注
- 查看目标详情
- 查看审计日志

#### 10.3 验证申请审核

**字段**:
```typescript
interface VerificationRequest {
  requestId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  reason: string;
  requestedBy: string;
  requestedAt: Date;
  status: 'pending' | 'approved' | 'rejected';
  
  // 审核信息
  reviewedBy?: string;
  reviewedAt?: Date;
  reviewNote?: string;
}
```

**操作**:
- 批准申请
- 拒绝申请
- 查看申请详情

---

### 11. 公开用户名管理 ⭐

**路由**: `/usernames`

#### 11.1 保留用户名列表

**字段**:
```typescript
interface ReservedUsernameListItem {
  username: string;
  reason: string;
  reservedBy: string;
  reservedAt: Date;
  expiresAt?: Date;
  status: 'active' | 'released';
}
```

**筛选条件**:
- 状态（活跃/已释放）
- 保留人
- 时间范围
- 搜索用户名

**操作**:
- 保留用户名
- 释放用户名
- 延长有效期
- 导出列表

#### 11.2 用户名历史记录

**字段**:
```typescript
interface UsernameRecordListItem {
  recordId: string;
  targetType: 'user' | 'chat';
  targetId: string;
  targetName: string;
  username: string;
  action: 'set' | 'removed' | 'reserved' | 'released';
  reason?: string;
  actionBy: string;
  actionAt: Date;
}
```

**筛选条件**:
- 操作类型
- 目标类型
- 操作人
- 时间范围
- 搜索用户名

**操作**:
- 查看详情
- 导出记录

#### 11.3 保留用户名

**表单**:
```typescript
interface ReserveUsernameForm {
  username: string;           // 必填
  reason: string;             // 必填
  expiresAt?: Date;           // 可选，永久保留则不填
  note?: string;              // 可选
}
```

**操作**:
- 提交保留
- 检查可用性
- 批量保留

---

## 🟧 P1 - 平台差异化

### 12. 邀请系统