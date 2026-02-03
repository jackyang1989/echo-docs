# Echo · 存储与权限模型设计
# Storage & Permission Model (Server-side, Pre-embedded)

**日期**: 2026-02-03  
**版本**: 1.0.0  
**优先级**: P0（v0 阶段预埋）  
**状态**: 📝 规划中

---

## 📋 文档说明

**本文档为 Echo 服务端的"未来约束模型"，v0 阶段仅写入规则，不暴露给客户端**

这是一个预埋功能设计，确保系统从 Day 1 就具备长期可演进的存储和权限架构。

---

## 🎯 一、设计目标（不可违反）

### 核心约束

1. **Echo 不是"无限视频云盘"**
2. **Echo 的默认行为必须与 Telegram 一致**：
   - 消息默认永久保存
   - 允许按 Chat / Channel 设置保留策略
3. **任何存储 / 权限变化**：
   - 必须是服务端状态
   - 必须产生 Update
   - 必须可被 getDifference 回放
4. **v0 阶段**：
   - 不修改客户端
   - 不新增客户端 UI
   - 不引入支付
   - 仅在服务端预埋模型与数据结构

---

## 📐 二、核心原则（长期有效）

### 设计原则

1. **"消息是否存在" ≠ "用户是否还能看到"**
   - 逻辑删除优先于物理删除

2. **存储策略是 Chat / Channel 的属性，不是 Message 的属性**

3. **权限策略是 Role 的属性，不是 User 的属性**

4. **所有策略变化，都是"状态事件"，不是后台运维操作**

---

## 🗄️ 三、核心实体定义（服务端）

### 3.1 Chat / Channel 级别

#### chat_storage_policy（存储策略表）

```sql
CREATE TABLE chat_storage_policy (
    chat_id BIGINT PRIMARY KEY,
    message_ttl_seconds INT,          -- NULL = 永久
    media_ttl_seconds INT,            -- NULL = 永久
    history_visibility VARCHAR(20),   -- full | limited | none
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    FOREIGN KEY (chat_id) REFERENCES chats(id)
);
```

**字段说明**：
- `message_ttl_seconds`: 消息保留时长（秒），NULL 表示永久保存
- `media_ttl_seconds`: 媒体文件保留时长（秒），NULL 表示永久保存
- `history_visibility`: 历史消息可见性
  - `full`: 完全可见
  - `limited`: 受限可见（仅最近 N 天）
  - `none`: 不可见

#### chat_permission_policy（权限策略表）

```sql
CREATE TABLE chat_permission_policy (
    chat_id BIGINT PRIMARY KEY,
    can_send_message BOOLEAN DEFAULT TRUE,
    can_send_media BOOLEAN DEFAULT TRUE,
    can_view_history BOOLEAN DEFAULT TRUE,
    can_export_content BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    FOREIGN KEY (chat_id) REFERENCES chats(id)
);
```

**字段说明**：
- `can_send_message`: 是否允许发送消息
- `can_send_media`: 是否允许发送媒体文件
- `can_view_history`: 是否允许查看历史消息
- `can_export_content`: 是否允许导出内容

### 3.2 用户角色

#### chat_member_role（成员角色表）

```sql
CREATE TABLE chat_member_role (
    chat_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,        -- owner | admin | member | restricted | readonly
    assigned_at TIMESTAMP DEFAULT NOW(),
    
    PRIMARY KEY (chat_id, user_id),
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**角色说明**：
- `owner`: 群主/频道主
- `admin`: 管理员
- `member`: 普通成员
- `restricted`: 受限成员
- `readonly`: 只读成员

---

## 💬 四、消息存储模型（核心）

### messages 表扩展

```sql
CREATE TABLE messages (
    message_id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    sender_id BIGINT NOT NULL,
    content TEXT,
    media_id BIGINT,                  -- nullable
    created_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP,             -- nullable，逻辑删除
    ttl_expires_at TIMESTAMP,         -- nullable，根据 chat_storage_policy 计算
    
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (media_id) REFERENCES media_objects(media_id),
    
    INDEX idx_chat_created (chat_id, created_at),
    INDEX idx_ttl_expires (ttl_expires_at) WHERE ttl_expires_at IS NOT NULL
);
```

### ⚠️ 核心规则

1. **永不直接 DELETE**
2. **过期 = 写 deleted_at + 生成 Update**
3. **客户端看到的"消失"，来自 Update，不是静默清理**

### 消息过期流程

```
1. 定时任务扫描 ttl_expires_at < NOW()
2. 更新 deleted_at = NOW()
3. 生成 UpdateMessageDeleted
4. 分配 pts
5. 写入 pending_updates
6. 推送给在线用户
```

---

## 📁 五、媒体存储模型（高成本点）

### media_objects 表

```sql
CREATE TABLE media_objects (
    media_id BIGSERIAL PRIMARY KEY,
    owner_chat_id BIGINT NOT NULL,
    storage_class VARCHAR(20) DEFAULT 'hot',  -- hot | cold | archived
    created_at TIMESTAMP DEFAULT NOW(),
    expire_at TIMESTAMP,              -- nullable
    size_bytes BIGINT NOT NULL,
    ref_count INT DEFAULT 1,          -- 引用计数
    
    FOREIGN KEY (owner_chat_id) REFERENCES chats(id),
    
    INDEX idx_storage_class (storage_class),
    INDEX idx_expire_at (expire_at) WHERE expire_at IS NOT NULL
);
```

### 存储类别说明

| 存储类别 | 说明 | 访问速度 | 成本 |
|---------|------|---------|------|
| **hot** | 热存储 | 快 | 高 |
| **cold** | 冷存储 | 中 | 中 |
| **archived** | 归档存储 | 慢 | 低 |

### 存储迁移规则

```
v0: 统一 hot
v1: hot → cold → archived
v2: 可选物理删除（仅 archived 且 ref_count=0）
```

### ⚠️ 核心规则

**所有阶段迁移必须产生 UpdateMediaStateChanged**

---

## 🔒 六、权限校验规则（强制）

### 需要权限校验的操作

所有以下操作，必须经过 Permission Check：
- `sendMessage`
- `sendMedia`
- `getHistory`
- `forwardMessage`
- `exportChat`

### 校验顺序（不可调整）

```typescript
function checkPermission(userId: number, chatId: number, action: string): boolean {
  // 1. Chat 是否存在
  const chat = getChat(chatId);
  if (!chat) {
    throw new Error('CHAT_NOT_FOUND');
  }
  
  // 2. User 是否是成员
  const member = getChatMember(chatId, userId);
  if (!member) {
    throw new Error('USER_NOT_MEMBER');
  }
  
  // 3. Role 是否允许该行为
  const role = member.role;
  if (!roleCanPerformAction(role, action)) {
    throw new Error('PERMISSION_DENIED');
  }
  
  // 4. Storage Policy 是否允许
  const policy = getChatPermissionPolicy(chatId);
  if (!policyAllowsAction(policy, action)) {
    throw new Error('POLICY_DENIED');
  }
  
  return true;
}
```

### 拒绝处理

任何拒绝：
- ✅ 返回明确错误码
- ❌ 不得"假成功"

---

## 🔄 七、Update 与一致性（生死线）

### 必须生成 Update 的行为

以下行为必须生成 Update：
1. **消息过期（TTL）** → `UpdateMessageDeleted`
2. **媒体状态迁移** → `UpdateMediaStateChanged`
3. **权限策略变更** → `UpdateChatPermissionPolicy`
4. **历史可见性变更** → `UpdateChatStoragePolicy`

### Update 必须满足的条件

```typescript
interface UpdateRequirements {
  // 1. 分配 pts
  pts: number;
  
  // 2. 写入 update_log
  writeToUpdateLog: boolean;
  
  // 3. 支持 getDifference 回放
  supportGetDifference: boolean;
}
```

### ❌ 禁止的行为

- ❌ 后台定时任务直接清表
- ❌ 不生成 Update 的"静默清理"
- ❌ 绕过 pts 机制的状态变更

### Update 示例

```typescript
// 消息过期 Update
interface UpdateMessageDeleted {
  _: 'updateMessageDeleted';
  pts: number;
  pts_count: number;
  messages: number[];           // 被删除的消息 ID 列表
  chat_id: number;
  reason: 'ttl_expired';        // 删除原因
}

// 媒体状态变更 Update
interface UpdateMediaStateChanged {
  _: 'updateMediaStateChanged';
  pts: number;
  pts_count: number;
  media_id: number;
  old_state: 'hot' | 'cold' | 'archived';
  new_state: 'hot' | 'cold' | 'archived';
}

// 权限策略变更 Update
interface UpdateChatPermissionPolicy {
  _: 'updateChatPermissionPolicy';
  pts: number;
  pts_count: number;
  chat_id: number;
  policy: ChatPermissionPolicy;
}
```

---

## 🚫 八、v0 阶段明确"不做"的事

### 不实现的功能

- ❌ 客户端显示"消息保留期限"
- ❌ 用户可配置存储策略
- ❌ 付费解锁存储
- ❌ 群主 UI 设置入口
- ❌ 自动删除不通知客户端

### 为什么不做？

**这些能力只在 v1 / v2 启用，但 v0 的数据结构与逻辑必须已经存在。**

---

## 💡 九、为什么必须现在预埋

### 如果 v0 不预埋会发生什么？

| 场景 | 后果 |
|------|------|
| v1 加 TTL | 破坏历史一致性 |
| v1 加权限 | 客户端状态错乱 |
| v1 加付费 | pts 无法回放 |

### 结论

**现在不写规则，未来一定重构。**

---

## ✅ 十、最终判断标准

### 唯一判断标准

**任何实现方案，只问一句：**

> "如果今天的一个消息，在 6 个月后被删除，客户端通过 getDifference 能不能完整理解'它为什么不见了'？"

- ✅ **能** → 正确方案
- ❌ **不能** → 必须重做

---

## 📊 十一、数据库 Schema 完整定义

### 完整 SQL

```sql
-- 1. 存储策略表
CREATE TABLE chat_storage_policy (
    chat_id BIGINT PRIMARY KEY,
    message_ttl_seconds INT,
    media_ttl_seconds INT,
    history_visibility VARCHAR(20) DEFAULT 'full',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    CHECK (history_visibility IN ('full', 'limited', 'none'))
);

-- 2. 权限策略表
CREATE TABLE chat_permission_policy (
    chat_id BIGINT PRIMARY KEY,
    can_send_message BOOLEAN DEFAULT TRUE,
    can_send_media BOOLEAN DEFAULT TRUE,
    can_view_history BOOLEAN DEFAULT TRUE,
    can_export_content BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    FOREIGN KEY (chat_id) REFERENCES chats(id)
);

-- 3. 成员角色表
CREATE TABLE chat_member_role (
    chat_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,
    assigned_at TIMESTAMP DEFAULT NOW(),
    
    PRIMARY KEY (chat_id, user_id),
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    CHECK (role IN ('owner', 'admin', 'member', 'restricted', 'readonly'))
);

-- 4. 消息表扩展（添加字段）
ALTER TABLE messages ADD COLUMN deleted_at TIMESTAMP;
ALTER TABLE messages ADD COLUMN ttl_expires_at TIMESTAMP;
CREATE INDEX idx_messages_ttl_expires ON messages(ttl_expires_at) WHERE ttl_expires_at IS NOT NULL;

-- 5. 媒体对象表
CREATE TABLE media_objects (
    media_id BIGSERIAL PRIMARY KEY,
    owner_chat_id BIGINT NOT NULL,
    storage_class VARCHAR(20) DEFAULT 'hot',
    created_at TIMESTAMP DEFAULT NOW(),
    expire_at TIMESTAMP,
    size_bytes BIGINT NOT NULL,
    ref_count INT DEFAULT 1,
    
    FOREIGN KEY (owner_chat_id) REFERENCES chats(id),
    CHECK (storage_class IN ('hot', 'cold', 'archived')),
    INDEX idx_storage_class (storage_class),
    INDEX idx_expire_at (expire_at) WHERE expire_at IS NOT NULL
);

-- 6. 策略变更历史表（审计）
CREATE TABLE policy_change_history (
    id BIGSERIAL PRIMARY KEY,
    chat_id BIGINT NOT NULL,
    policy_type VARCHAR(50) NOT NULL,  -- storage | permission
    old_value JSONB,
    new_value JSONB,
    changed_by BIGINT NOT NULL,
    changed_at TIMESTAMP DEFAULT NOW(),
    
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    FOREIGN KEY (changed_by) REFERENCES users(id)
);
```

---

## 🔄 十二、实施路线图

### Phase 0: v0 预埋（当前）

**目标**: 数据结构就绪，逻辑不暴露

- [ ] 创建所有数据库表
- [ ] 实现权限校验逻辑
- [ ] 实现 TTL 计算逻辑
- [ ] 实现 Update 生成逻辑
- [ ] 不暴露给客户端
- [ ] 不添加 UI

**验收标准**:
- 数据库表创建成功
- 权限校验逻辑可用
- TTL 过期生成 Update
- getDifference 可回放

### Phase 1: v1 启用（未来）

**目标**: 群主可配置存储策略

- [ ] 添加群主设置 UI
- [ ] 实现策略配置 API
- [ ] 客户端显示保留期限
- [ ] 用户可查看策略

### Phase 2: v2 扩展（未来）

**目标**: 付费解锁、高级功能

- [ ] 付费存储套餐
- [ ] 媒体存储分级
- [ ] 高级权限控制
- [ ] 数据导出功能

---

## 📝 十三、验收标准

### 核心验收标准

- [ ] **数据库表创建成功**
- [ ] **权限校验逻辑正确**
- [ ] **TTL 过期生成 Update**
- [ ] **媒体状态迁移生成 Update**
- [ ] **策略变更生成 Update**
- [ ] **getDifference 可回放所有变更**
- [ ] **客户端不感知（v0 阶段）**

### 测试场景

#### 场景 1：消息 TTL 过期

```
前置条件：
- Chat A 设置 message_ttl_seconds = 86400（24小时）
- 用户 B 在 Chat A 发送消息 M1

操作步骤：
1. 等待 24 小时
2. 定时任务扫描过期消息
3. 更新 M1.deleted_at = NOW()
4. 生成 UpdateMessageDeleted
5. 推送给在线用户

预期结果：
- M1.deleted_at 不为空
- 生成了 UpdateMessageDeleted
- Update 有正确的 pts
- 客户端收到 Update（如果在线）
- getDifference 可以回放这个删除
```

#### 场景 2：权限策略变更

```
前置条件：
- Chat A 的 can_send_media = true
- 用户 B 是 Chat A 的成员

操作步骤：
1. 群主将 Chat A 的 can_send_media 改为 false
2. 生成 UpdateChatPermissionPolicy
3. 用户 B 尝试发送图片

预期结果：
- 策略变更生成了 Update
- Update 有正确的 pts
- 用户 B 发送图片失败
- 返回 PERMISSION_DENIED 错误
```

#### 场景 3：媒体存储迁移

```
前置条件：
- Media M1 的 storage_class = 'hot'
- M1 创建时间 > 30 天

操作步骤：
1. 定时任务扫描需要迁移的媒体
2. 更新 M1.storage_class = 'cold'
3. 生成 UpdateMediaStateChanged

预期结果：
- M1.storage_class = 'cold'
- 生成了 UpdateMediaStateChanged
- Update 有正确的 pts
- getDifference 可以回放这个变更
```

---

## 🔗 十四、相关文档

- **项目宪法**: `ECHO执行方案-精简版.md`
- **AI Agent 规则**: `AGENTS.md`
- **功能路线图**: `docs/planning/ECHO_FEATURE_ROADMAP.md`
- **管理后台规划**: `docs/planning/ECHO_ADMIN_PANEL.md`
- **广场功能设计**: `docs/planning/ECHO_SQUARE_DESIGN.md`

---

## 🔄 变更历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| 1.0.0 | 2026-02-03 | AI Agent | 初始版本，定义存储与权限模型 |

---

**最后更新**: 2026-02-03  
**文档状态**: 📝 规划中  
**下一步**: 等待审核和批准，确定实施时间

