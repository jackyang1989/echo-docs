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

## 🔴 P0 硬约束：不得修改 MTProto / TL schema

Echo 不新增、不修改任何 MTProto/TL schema（包括不新增 TL Update 类型）。

因此：
- 本文档**禁止**使用 `Update*` 形式命名来描述“客户端可见变化”（这会误导为新增 TL Update）。
- 任何客户端可见变化必须映射到**既有 Telegram 机制**（例如 `updateDeleteMessages`、`updateChatDefaultBannedRights`、`FILE_REFERENCE_EXPIRED`）。

权威约束详见：`docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md`。

### 术语对照（避免写歪）

| 术语 | 含义 | 载体 |
|------|------|------|
| Client-visible change | 客户端必须感知/可回放的一致性变化 | 既有 TL updates / 既有 TL 错误码 / 既有对象字段变更 |
| Internal event | 服务端内部用于解耦/异步/审计的事件 | `im.xxx.v1`（不是 TL，不下发给客户端） |
| Replay log | 用于 `getDifference` 回放的更新日志 | `update_log`（或等价 append-only 存储） |

---

## 🎯 一、设计目标（不可违反）

### 核心约束

1. **Echo 不是"无限视频云盘"**
2. **Echo 的默认行为必须与 Telegram 一致**：
   - 消息默认永久保存
   - 允许按 Chat / Channel 设置保留策略
3. **任何存储 / 权限变化**：
   - 必须是服务端状态
   - **若影响客户端可见结果**：必须写入可回放记录（`update_log`），并映射到既有 TL 机制
   - **若纯内部实现（例如热/冷迁移）**：只允许 internal event + 审计，客户端不需要感知
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

**实际的媒体存储 Schema 请参考**：`docs/planning/ECHO_MEDIA_STORAGE_STRATEGY.md`（`files` 为唯一真相源）。

本文档只定义：
- Chat 级策略（TTL/可见性/权限）
- Role/Member 关系
- 权限校验顺序
- Client-visible change 的 TL 映射要求
- Internal event / 审计要求

两个文档的关系：
- **本文档**：定义权限和策略模型
- **ECHO_MEDIA_STORAGE_STRATEGY.md**：定义实际的存储 Schema（权威来源）

---

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
    file_id BIGINT,                   -- nullable，引用 files
    created_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP,             -- nullable，逻辑删除
    ttl_expires_at TIMESTAMP,         -- nullable，根据 chat_storage_policy 计算
    
    FOREIGN KEY (chat_id) REFERENCES chats(id),
    FOREIGN KEY (sender_id) REFERENCES users(id),
    FOREIGN KEY (file_id) REFERENCES files(id),
    
    INDEX idx_chat_created (chat_id, created_at),
    INDEX idx_ttl_expires (ttl_expires_at) WHERE ttl_expires_at IS NOT NULL
);
```

### ⚠️ 核心规则

1. **永不直接 DELETE**
2. **过期 = 写 deleted_at + 写入可回放记录**（`update_log`）
3. **客户端看到的"消失"，来自既有 TL 机制（删除/编辑/错误码），不是静默清理**

### 消息过期流程

```
1. 定时任务扫描 ttl_expires_at < NOW()
2. 更新 deleted_at = NOW()
3. 写入可回放记录（`update_log`）
4. 分配 pts
5. getDifference 可回放
6. 在线用户实时推送（如在线）
```

---

## 📁 五、媒体生命周期与访问（高成本点）

### 核心原则

1. 媒体生命周期状态的唯一真相源：`files`
2. `messages` 只引用 `file_id`，不存媒体状态
3. **文件引用失效 / 文件不可用**对客户端的表达必须使用既有机制：
   - `FILE_REFERENCE_EXPIRED` / `FILE_REFERENCE_EMPTY` / `FILE_REFERENCE_INVALID`（客户端具备刷新能力）
   - 或（经明确批准后）使用消息删除/编辑的 TL update（例如 `updateDeleteMessages` / `updateEditMessage`）

### 存储分层（hot/cold/archived）

存储分层是纯内部实现：
- 允许 internal event（例如 `im.media.storage.tier.changed.v1`）
- 允许审计记录
- **不要求客户端感知**，也不允许伪造“自定义 TL Update”

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

## 🔄 七、客户端可见变化与一致性（生死线）

### 必须可回放的行为（Client-visible change）

以下行为一旦启用并对客户端产生可见影响，必须：写入 `update_log` + 可被 `getDifference` 回放 + 映射到既有 TL 机制：

1. **消息过期（TTL）**
   - TL 映射：`updateDeleteMessages` / `updateDeleteChannelMessages`
2. **权限策略变更（禁言/限制）**
   - TL 映射：`updateChatDefaultBannedRights` + `chatBannedRights`（语义是“禁止”，注意取反）

说明：
- **媒体热/冷迁移**默认属于内部实现，不属于 client-visible change
- **媒体不可下载**优先使用 `FILE_REFERENCE_*` 错误族表达（不新增 TL update）

### 回放必须满足的条件

```typescript
interface ReplayRequirements {
  // 1. 分配 pts
  pts: number;
  
  // 2. 写入 update_log（或等价 append-only 日志）
  writeToUpdateLog: boolean;
  
  // 3. 支持 getDifference 回放
  supportGetDifference: boolean;
}
```

### ❌ 禁止的行为

- ❌ 后台定时任务直接清表
- ❌ 不生成 Update 的"静默清理"
- ❌ 绕过 pts 机制的状态变更

### TL 映射示例（只列方向，不新增 schema）

| 场景 | Client-visible change | 既有 TL 机制 |
|------|------------------------|--------------|
| 消息 TTL 过期 | 消息在对话中消失 | `updateDeleteMessages` / `updateDeleteChannelMessages` |
| 禁止发送媒体 | 客户端 UI 需同步变灰 + 服务端强制拒绝 | `updateChatDefaultBannedRights` + `chatBannedRights.send_media` |
| 文件引用过期 | 客户端刷新 file_reference 后重试 | 错误码：`FILE_REFERENCE_EXPIRED`/`FILE_REFERENCE_EMPTY`/`FILE_REFERENCE_INVALID` |

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
ALTER TABLE messages ADD COLUMN file_id BIGINT;
CREATE INDEX idx_messages_ttl_expires ON messages(ttl_expires_at) WHERE ttl_expires_at IS NOT NULL;

-- 5. 媒体存储（权威 Schema）
-- files 表为唯一真相源，详见：docs/planning/ECHO_MEDIA_STORAGE_STRATEGY.md
--
-- 如果未来需要引用计数/去重，优先使用 files.ref_count 或 file_refs 表，而不是新增 media_objects。
-- 示例（可选）：
-- CREATE TABLE file_refs (
--     file_id     BIGINT NOT NULL REFERENCES files(id),
--     owner_type  VARCHAR(20) NOT NULL,   -- message/chat/square...
--     owner_id    BIGINT NOT NULL,
--     created_at  TIMESTAMP DEFAULT NOW(),
--     PRIMARY KEY (file_id, owner_type, owner_id)
-- );

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
- [ ] 实现 client-visible change 的 TL 映射 + update_log 可回放
- [ ] 不暴露给客户端
- [ ] 不添加 UI

**验收标准**:
- 数据库表创建成功
- 权限校验逻辑可用
- TTL 过期可回放（update_log + TL 删除机制）
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
- [ ] **TTL 过期可回放（update_log + TL 删除机制）**
- [ ] **策略变更可回放（update_log + TL 权限机制）**
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
4. 写入 update_log（可回放）并触发 TL 删除机制（`updateDeleteMessages` / `updateDeleteChannelMessages`）
5. 推送给在线用户

预期结果：
- M1.deleted_at 不为空
- update_log 有对应记录，pts 正确
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
2. 写入策略变更审计 + 写入 update_log（可回放）
3. TL 映射：`updateChatDefaultBannedRights`（携带 `chatBannedRights`）
3. 用户 B 尝试发送图片

预期结果：
- 策略变更可回放（update_log + pts 正确）
- 用户 B 发送图片失败
- 返回 PERMISSION_DENIED 错误
```

#### 场景 3：媒体存储迁移（内部实现，不要求客户端感知）

```
前置条件：
- File F1 处于 hot（内部存储分层）
- F1 创建时间 > 30 天

操作步骤：
1. 定时任务扫描需要迁移的文件
2. 将文件迁移至 cold（内部实现）
3. 记录 internal event（例如 im.media.storage.tier.changed.v1）+ 审计

预期结果：
- 客户端无感知
- 下载仍正常（可能延迟增加，但协议语义不变）
- 不产生任何“自定义 TL Update”
```

---

## 🔗 十四、相关文档

- **项目宪法**: `ECHO执行方案-精简版.md`
- **AI Agent 规则**: `AGENTS.md`
- **功能路线图**: `docs/planning/ECHO_FEATURE_ROADMAP.md`
- **管理后台规划**: `docs/planning/ECHO_ADMIN_PANEL.md`
- **广场功能设计**: `docs/planning/ECHO_SQUARE_DESIGN.md`
- **权威约束清单**: `docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md`

---

## 🔄 变更历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| 1.0.0 | 2026-02-03 | AI Agent | 初始版本，定义存储与权限模型 |

---

**最后更新**: 2026-02-03  
**文档状态**: 📝 规划中  
**下一步**: 等待审核和批准，确定实施时间
