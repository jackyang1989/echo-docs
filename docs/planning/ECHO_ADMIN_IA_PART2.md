# Echo IM - 管理后台 IA (Part 2)

**续接**: ECHO_ADMIN_IA.md  
**日期**: 2026-01-27

---

## 🟥 P0 - 平台生存级（续）

### 12. 系统监控与告警

**路由**: `/alerts`

#### 8.1 告警列表

**字段**:
```typescript
interface Alert {
  alertId: string;
  
  // 告警源
  source: 'node' | 'queue' | 'database' | 'push' | 'upload' | 'login' | 'custom';
  sourceName: string;
  
  // 告警信息
  type: string;                 // 具体告警类型
  level: 'info' | 'warning' | 'error' | 'critical';
  message: string;
  details: Record<string, any>;
  
  // 时间
  firstOccurredAt: Date;
  lastOccurredAt: Date;
  occurrenceCount: number;
  
  // 状态
  status: 'unconfirmed' | 'confirmed' | 'processing' | 'resolved' | 'ignored';
  
  // 处理信息
  assignedTo?: string;
  confirmedBy?: string;
  confirmedAt?: Date;
  resolvedBy?: string;
  resolvedAt?: Date;
  resolution?: string;
}
```

**告警类型**:
```typescript
enum AlertType {
  // 节点健康
  NODE_DOWN = 'node.down',
  NODE_DEGRADED = 'node.degraded',
  NODE_HIGH_CPU = 'node.high_cpu',
  NODE_HIGH_MEMORY = 'node.high_memory',
  
  // 队列
  QUEUE_BACKLOG = 'queue.backlog',
  QUEUE_PROCESSING_SLOW = 'queue.processing_slow',
  
  // 数据库
  DB_CONNECTION_HIGH = 'db.connection.high',
  DB_SLOW_QUERY = 'db.slow_query',
  DB_REPLICATION_LAG = 'db.replication_lag',
  
  // 推送
  PUSH_FAILURE_RATE_HIGH = 'push.failure_rate.high',
  PUSH_GATEWAY_DOWN = 'push.gateway.down',
  PUSH_LATENCY_HIGH = 'push.latency.high',
  
  // 上传
  UPLOAD_FAILURE_RATE_HIGH = 'upload.failure_rate.high',
  STORAGE_USAGE_HIGH = 'storage.usage.high',
  
  // 登录
  LOGIN_FAILURE_RATE_HIGH = 'login.failure_rate.high',
  ABNORMAL_REGISTRATION = 'registration.abnormal',
  
  // 业务
  REPORT_QUEUE_HIGH = 'report.queue.high',
  BAN_RATE_ABNORMAL = 'ban.rate.abnormal',
}
```

**筛选条件**:
- 告警源
- 告警级别
- 状态
- 时间范围
- 负责人

**操作**:
- 确认告警
- 分配负责人
- 标记为处理中
- 标记为已解决
- 忽略告警
- 创建事件记录
- 关联紧急开关

#### 8.2 告警规则配置

**字段**:
```typescript
interface AlertRule {
  ruleId: string;
  name: string;
  description: string;
  enabled: boolean;
  
  // 监控指标
  metric: string;
  threshold: number;
  comparison: '>' | '<' | '>=' | '<=' | '==' | '!=';
  timeWindow: number;           // 时间窗口（分钟）
  
  // 告警级别
  level: 'info' | 'warning' | 'error' | 'critical';
  
  // 通知设置
  notifyChannels: ('email' | 'sms' | 'webhook' | 'dashboard')[];
  notifyUsers: string[];
  
  // 升级规则
  escalation: {
    enabled: boolean;
    escalateAfter: number;      // 多久后升级（分钟）
    escalateTo: string[];       // 升级给谁
  };
  
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**预设告警规则**:
1. 推送失败率 > 10%（5分钟窗口）→ Warning
2. 推送失败率 > 30%（5分钟窗口）→ Critical
3. 队列积压 > 1000（10分钟窗口）→ Warning
4. 数据库连接 > 80%（5分钟窗口）→ Warning
5. 登录失败率 > 20%（10分钟窗口）→ Warning
6. 待处理举报 > 100 → Warning
7. 节点 Down → Critical

**操作**:
- 创建规则
- 编辑规则
- 启用/禁用规则
- 测试规则
- 查看规则历史

---

### 13. 管理员安全

**路由**: `/admin-security`

#### 9.1 管理员列表

**字段**:
```typescript
interface AdminUser {
  adminId: string;
  username: string;
  email: string;
  phone?: string;
  
  // 角色权限
  role: 'super_admin' | 'admin' | 'moderator' | 'viewer';
  permissions: string[];
  
  // 安全设置
  twoFactorEnabled: boolean;
  ipWhitelist: string[];
  allowedCountries: string[];
  
  // 状态
  status: 'active' | 'suspended' | 'locked';
  lastLoginAt: Date;
  lastLoginIP: string;
  
  // 元数据
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**操作**:
- 创建管理员
- 编辑管理员
- 修改角色
- 暂停/恢复
- 强制启用 2FA
- 设置 IP 白名单
- 设置地理限制
- 重置密码
- 查看操作日志

#### 9.2 管理员详情

**登录历史**:
```typescript
interface AdminLoginHistory {
  loginId: string;
  loginAt: Date;
  ip: string;
  country: string;
  city: string;
  device: string;
  userAgent: string;
  status: 'success' | 'failed' | 'blocked';
  failureReason?: string;
}
```

**操作统计**:
```typescript
interface AdminOperationStats {
  last24h: {
    totalOperations: number;
    highRiskOperations: number;
    usersBanned: number;
    chatsDisolved: number;
    reportsHandled: number;
  };
  last7d: {
    totalOperations: number;
    highRiskOperations: number;
  };
}
```

**权限详情**:
```typescript
interface AdminPermissions {
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
  
  // 策略管理
  canManagePolicies: boolean;
  
  // 系统控制
  canControlSystem: boolean;
  canUseEmergency: boolean;
  
  // 数据分析
  canViewAnalytics: boolean;
  canExportData: boolean;
  
  // 管理员管理
  canManageAdmins: boolean;
}
```

#### 9.3 角色管理

**预设角色**:

1. **Super Admin（超级管理员）**
   - 所有权限
   - 可以管理其他管理员
   - 可以使用紧急开关

2. **Admin（管理员）**
   - 用户管理（封禁、冻结）
   - 群组管理（封禁、解散）
   - 举报处理
   - 策略管理
   - 不能使用紧急开关
   - 不能管理其他管理员

3. **Moderator（审核员）**
   - 查看用户/群组
   - 处理举报
   - 冻结用户（不能封禁）
   - 不能解散群组
   - 不能修改策略

4. **Viewer（只读）**
   - 查看所有数据
   - 查看统计报表
   - 不能执行任何操作

**操作**:
- 创建自定义角色
- 编辑角色权限
- 删除角色
- 查看角色使用情况

#### 9.4 安全设置

**全局安全策略**:
```typescript
interface AdminSecurityPolicy {
  // 登录安全
  requireTwoFactor: boolean;    // 强制 2FA
  sessionTimeout: number;       // 会话超时（分钟）
  maxFailedAttempts: number;
  lockoutDuration: number;
  
  // IP 限制
  ipWhitelistEnabled: boolean;
  globalIPWhitelist: string[];
  
  // 地理限制
  geoRestrictionEnabled: boolean;
  allowedCountries: string[];
  
  // 操作限制
  requireApprovalFor: string[]; // 需要审批的操作
  highRiskOperationDelay: number; // 高风险操作延迟（秒）
}
```

**操作**:
- 编辑安全策略
- 查看安全日志
- 导出安全报告

---

## 🟧 P1 - 平台差异化

### 14. 邀请系统

**路由**: `/invites`

#### 10.1 邀请码管理

**批量生成**:
```typescript
interface InviteCodeGenerate {
  count: number;                // 生成数量
  prefix?: string;              // 前缀（可选）
  expiresIn: number;            // 有效期（天）
  maxUses: number;              // 最大使用次数（1=一次性）
  note?: string;                // 备注
  createdBy: string;
}
```

**邀请码列表**:
```typescript
interface InviteCode {
  code: string;
  createdBy: string;
  createdAt: Date;
  expiresAt: Date;
  maxUses: number;
  usedCount: number;
  status: 'active' | 'expired' | 'exhausted' | 'disabled';
  note?: string;
  
  // 使用统计
  registeredUsers: number;      // 成功注册数
  activeUsers: number;          // 活跃用户数
}
```

**操作**:
- 批量生成邀请码
- 禁用/启用邀请码
- 延长有效期
- 增加使用次数
- 导出邀请码
- 查看使用详情

#### 10.2 邀请关系链

**字段**:
```typescript
interface InviteRelationship {
  inviterId: string;
  inviterUsername: string;
  inviteeId: string;
  inviteeUsername: string;
  inviteCode: string;
  invitedAt: Date;
  registeredAt?: Date;
  status: 'pending' | 'registered' | 'active' | 'banned';
  
  // 邀请人统计
  inviterStats: {
    totalInvites: number;
    successfulInvites: number;
    activeInvites: number;
    conversionRate: number;
  };
}
```

**操作**:
- 查看邀请树（可视化）
- 按邀请人筛选
- 按邀请码筛选
- 导出关系链

#### 10.3 邀请配额

**字段**:
```typescript
interface InviteQuota {
  userId: string;
  username: string;
  inviteQuota: number;          // 可邀请人数
  invitedCount: number;         // 已邀请人数
  successfulInvites: number;    // 成功邀请
  remainingQuota: number;       // 剩余配额
  
  // 配额规则
  quotaType: 'unlimited' | 'daily' | 'total';
  dailyLimit?: number;
  totalLimit?: number;
  
  updatedBy: string;
  updatedAt: Date;
}
```

**操作**:
- 设置用户配额
- 批量设置配额
- 增加/减少配额
- 查看配额使用情况

#### 10.4 邀请统计

**指标**:
```typescript
interface InviteStats {
  // 总体统计
  totalCodes: number;
  activeCodes: number;
  totalInvites: number;
  successfulInvites: number;
  conversionRate: number;
  
  // 趋势
  dailyInvites: {
    date: Date;
    invites: number;
    registrations: number;
  }[];
  
  // Top 邀请人
  topInviters: {
    userId: string;
    username: string;
    inviteCount: number;
    successRate: number;
  }[];
}
```

---

### 15. 公告与运营

**路由**: `/announcements`

#### 11.1 官方公告

**字段**:
```typescript
interface Announcement {
  announcementId: string;
  type: 'system' | 'feature' | 'maintenance' | 'event';
  
  // 内容
  title: string;
  content: string;              // Markdown 支持
  coverImage?: string;
  
  // 发布设置
  publishAt: Date;
  expiresAt?: Date;
  status: 'draft' | 'scheduled' | 'published' | 'expired';
  
  // 目标用户
  targetType: 'all' | 'specific' | 'filter';
  targetUsers?: string[];
  targetFilter?: Record<string, any>;
  
  // 展示设置
  showInApp: boolean;           // 应用内展示
  showAsPopup: boolean;         // 弹窗展示
  priority: 'low' | 'medium' | 'high';
  
  // 统计
  viewCount: number;
  clickCount: number;
  
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**操作**:
- 创建公告
- 编辑公告
- 发布/撤回
- 定时发布
- 查看统计
- 删除公告

#### 11.2 维护通知

**字段**:
```typescript
interface MaintenanceNotice {
  noticeId: string;
  
  // 维护信息
  title: string;
  description: string;
  startTime: Date;
  endTime: Date;
  estimatedDuration: number;    // 预计时长（分钟）
  
  // 影响范围
  affectedServices: string[];
  severity: 'minor' | 'major' | 'critical';
  
  // 通知设置
  notifyBefore: number;         // 提前通知（小时）
  notifyChannels: ('push' | 'email' | 'in_app')[];
  
  status: 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
  
  createdBy: string;
  createdAt: Date;
}
```

**操作**:
- 创建维护通知
- 编辑维护通知
- 取消维护
- 标记完成
- 发送提醒

---

### 16. 客户端配置下发

**路由**: `/remote-config`

#### 12.1 配置管理

**字段**:
```typescript
interface RemoteConfig {
  configKey: string;
  configValue: any;
  valueType: 'boolean' | 'number' | 'string' | 'json';
  description: string;
  
  // 生效范围
  scope: 'global' | 'platform' | 'version' | 'user_group';
  scopeFilter?: {
    platform?: 'android' | 'ios' | 'desktop' | 'web';
    minVersion?: string;
    maxVersion?: string;
    userGroup?: string;
  };
  
  // 灰度发布
  rolloutPercentage: number;    // 0-100
  
  updatedBy: string;
  updatedAt: Date;
}
```

**预设配置项**:
```typescript
enum RemoteConfigKey {
  // 默认设置
  DEFAULT_DISCOVERABLE = 'default.discoverable',
  DEFAULT_MEDIA_ENABLED = 'default.media_enabled',
  DEFAULT_NEW_USER_COOLDOWN = 'default.new_user_cooldown',
  
  // 功能开关
  FEATURE_GROUP_CREATION = 'feature.group_creation',
  FEATURE_FILE_UPLOAD = 'feature.file_upload',
  FEATURE_FORWARD = 'feature.forward',
  
  // 限制
  MAX_FILE_SIZE_MB = 'limit.max_file_size_mb',
  MAX_GROUP_MEMBERS = 'limit.max_group_members',
  MAX_GROUPS_PER_USER = 'limit.max_groups_per_user',
  
  // UI 配置
  SHOW_DISCOVER_TAB = 'ui.show_discover_tab',
  SHOW_SQUARE_TAB = 'ui.show_square_tab',
}
```

**操作**:
- 创建配置
- 编辑配置
- 删除配置
- 灰度发布
- 回滚配置
- 查看配置历史

#### 12.2 Feature Flags

**字段**:
```typescript
interface FeatureFlag {
  flagKey: string;
  flagName: string;
  description: string;
  enabled: boolean;
  
  // 灰度设置
  rollout: {
    type: 'percentage' | 'whitelist' | 'filter';
    percentage?: number;
    whitelist?: string[];
    filter?: Record<string, any>;
  };
  
  // 生效范围
  platforms: ('android' | 'ios' | 'desktop' | 'web')[];
  minVersion?: string;
  
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
}
```

**操作**:
- 创建 Feature Flag
- 启用/禁用
- 调整灰度比例
- 添加白名单
- 查看使用统计

---

### 17. 基础统计

**路由**: `/analytics/basic`

#### 13.1 用户分析

**指标**:
```typescript
interface UserAnalytics {
  // 基础指标
  totalUsers: number;
  activeUsers: {
    dau: number;
    wau: number;
    mau: number;
  };
  
  // 新增用户
  newUsers: {
    today: number;
    yesterday: number;
    thisWeek: number;
    lastWeek: number;
    thisMonth: number;
    lastMonth: number;
  };
  
  // 留存率
  retention: {
    day1: number;
    day3: number;
    day7: number;
    day14: number;
    day30: number;
  };
  
  // 趋势图
  dailyTrend: {
    date: Date;
    newUsers: number;
    activeUsers: number;
    retainedUsers: number;
  }[];
}
```

#### 13.2 群组分析

**指标**:
```typescript
interface ChatAnalytics {
  // 基础指标
  totalChats: number;
  activeChats: number;
  
  // 分类统计
  byType: {
    groups: number;
    supergroups: number;
    channels: number;
  };
  
  // 活跃度排行
  topActiveChats: {
    chatId: string;
    chatTitle: string;
    messageCount: number;
    activeMembers: number;
    growthRate: number;
  }[];
  
  // 趋势
  dailyTrend: {
    date: Date;
    newChats: number;
    activeChats: number;
    dissolvedChats: number;
  }[];
}
```

#### 13.3 内容分析

**指标**:
```typescript
interface ContentAnalytics {
  // 消息统计
  totalMessages: number;
  messagesPerDay: number;
  messagesPerUser: number;
  
  // 文件统计
  totalFiles: number;
  storageUsed: number;          // GB
  filesByType: {
    images: number;
    videos: number;
    documents: number;
    audio: number;
  };
  
  // 趋势
  dailyTrend: {
    date: Date;
    messages: number;
    files: number;
    storageUsed: number;
  }[];
}
```

#### 13.4 治理分析

**指标**:
```typescript
interface ModerationAnalytics {
  // 封禁统计
  bannedUsers: number;
  frozenUsers: number;
  bannedChats: number;
  
  // 举报统计
  totalReports: number;
  pendingReports: number;
  resolvedReports: number;
  reportRate: number;           // 举报率
  
  // 处理效率
  avgHandleTime: number;        // 平均处理时间（小时）
  resolutionRate: number;       // 解决率
  
  // 趋势
  dailyTrend: {
    date: Date;
    reports: number;
    bans: number;
    resolved: number;
  }[];
}
```

**操作**:
- 选择时间范围
- 导出报表
- 设置数据告警
- 自定义图表

---

## 🟨 P2 - 运营扩展

### 18. 广场内容池

**路由**: `/square/pool`

**⚠️ 注意**: 只管理"进入广场的内容"，不碰 IM

**字段**:
```typescript
interface SquareContent {
  contentId: string;
  type: 'chat' | 'channel' | 'message';
  sourceId: string;
  sourceName: string;
  
  // 内容信息
  title: string;
  description: string;
  coverImage?: string;
  tags: string[];
  
  // 上架状态
  status: 'pending' | 'approved' | 'published' | 'rejected' | 'removed';
  publishedAt?: Date;
  
  // 热度
  hotScore: number;
  viewCount: number;
  joinCount: number;
  shareCount: number;
  
  // 审核
  reviewedBy?: string;
  reviewedAt?: Date;
  reviewNote?: string;
  
  createdBy: string;
  createdAt: Date;
}
```

**操作**:
- 添加到内容池
- 审核内容
- 上架/下架
- 设置标签
- 调整热度权重
- 置顶/取消置顶
- 删除内容

---

### 19. 广场审核

**路由**: `/square/moderation`

**审核队列**:
```typescript
interface SquareReview {
  reviewId: string;
  contentId: string;
  contentType: string;
  contentTitle: string;
  
  // 提交信息
  submittedBy: string;
  submittedAt: Date;
  
  // 审核状态
  status: 'pending' | 'approved' | 'rejected';
  reviewedBy?: string;
  reviewedAt?: Date;
  reviewNote?: string;
  
  // 风险评估
  riskLevel: 'low' | 'medium' | 'high';
  riskReasons: string[];
}
```

**操作**:
- 批准上架
- 拒绝上架
- 要求修改
- 标记风险
- 批量审核

---

## 🟩 P3 - 长期规划

### 20. 反滥用自动化

**路由**: `/automation`

**自动化规则**:
```typescript
interface AutomationRule {
  ruleId: string;
  name: string;
  description: string;
  enabled: boolean;
  
  // 触发条件
  trigger: {
    type: 'behavior' | 'threshold' | 'pattern';
    conditions: Record<string, any>;
  };
  
  // 自动动作
  action: {
    type: 'warn' | 'freeze' | 'ban' | 'notify';
    duration?: number;
    notifyAdmins?: boolean;
  };
  
  // 统计
  triggeredCount: number;
  lastTriggeredAt?: Date;
  
  createdBy: string;
  createdAt: Date;
}
```

---

### 21. 多节点/灾备

**路由**: `/infra/nodes`

**节点管理**:
```typescript
interface Node {
  nodeId: string;
  type: 'gateway' | 'session' | 'bff';
  hostname: string;
  ip: string;
  region: string;
  
  // 状态
  status: 'online' | 'offline' | 'maintenance';
  health: 'healthy' | 'degraded' | 'unhealthy';
  
  // 负载
  load: number;
  connections: number;
  cpu: number;
  memory: number;
  
  // 版本
  version: string;
  lastHeartbeat: Date;
}
```

**操作**:
- 查看节点状态
- 切换流量
- 标记维护
- 重启节点
- 查看日志

---

### 22. 合规工具

**路由**: `/compliance`

**数据导出请求**:
```typescript
interface DataExportRequest {
  requestId: string;
  userId: string;
  requestedBy: string;
  requestedAt: Date;
  
  // 导出范围
  dataTypes: ('profile' | 'messages' | 'files' | 'contacts')[];
  
  // 状态
  status: 'pending' | 'processing' | 'completed' | 'failed';
  processedAt?: Date;
  downloadUrl?: string;
  expiresAt?: Date;
}
```

**数据删除请求**:
```typescript
interface DataDeletionRequest {
  requestId: string;
  userId: string;
  requestedBy: string;
  requestedAt: Date;
  
  // 删除范围
  deleteTypes: ('account' | 'messages' | 'files' | 'all')[];
  
  // 状态
  status: 'pending' | 'scheduled' | 'processing' | 'completed';
  scheduledAt?: Date;
  completedAt?: Date;
}
```

**操作**:
- 创建导出请求
- 创建删除请求
- 查看请求状态
- 下载导出数据
- 查看合规日志

---

## ✅ 总结

### 完整菜单结构（可直接用于前端路由）

```
/dashboard                      # P0: 总览
/users                          # P0: 用户列表
/users/:id                      # P0: 用户详情
/chats                          # P0: 群组列表
/chats/:id                      # P0: 群组详情
/reports                        # P0: 举报队列
/reports/:id                    # P0: 举报详情
/push                           # P0: 推送控制
/policies                       # P0: 策略中心
/killswitch                     # P0: 紧急开关
/audit-logs                     # P0: 审计日志
/marks                          # P0: 诈骗/虚假标记 ⭐
/message-types                  # P0: 消息类型控制 ⭐
/alerts                         # P0: 系统告警
/admin-security                 # P0: 管理员安全

/invites                        # P1: 邀请系统
/announcements                  # P1: 公告运营
/remote-config                  # P1: 配置下发
/analytics/basic                # P1: 基础统计
/verifications                  # P1: 验证标记（蓝V）⭐
/usernames                      # P1: 用户名管理 ⭐

/square/pool                    # P2: 广场内容池
/square/moderation              # P2: 广场审核
/ads                            # P2: 广告位（可选）

/automation                     # P3: 自动化
/infra/nodes                    # P3: 节点管理
/compliance                     # P3: 合规工具
```

### 三样必备确认 ✅

1. **审计日志** ✅ - `/audit-logs` 完整实现
2. **策略中心** ✅ - `/policies` 完整实现
3. **告警闭环** ✅ - `/alerts` 完整实现

---

**最后更新**: 2026-01-27  
**状态**: IA 设计完成，可直接用于开发

