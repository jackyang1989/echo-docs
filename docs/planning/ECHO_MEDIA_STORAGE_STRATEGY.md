# Echo 群消息存储完整方案（对标 Telegram · 可长期运营）

**文档版本**: 1.0.0  
**创建日期**: 2026-02-03  
**状态**: 设计方案 📋

---

## 🎯 设计目标（硬约束）

### 1. 用户直觉一致

**创建群时**：
- 默认"永久保存"
- 无弹窗、无警告、无额外解释

**设置里**：
- 可选择消息保存期限

👉 **和 Telegram 一致，用户不需要被教育**

### 2. 成本可控

**永久 ≠ 永远无限制保存所有媒体**
- 文本、结构永久
- 媒体分层

### 3. 不产生技术债

- 不"先假装支持，后面再补"
- 每一条规则都是长期规则
- v0 阶段可以关闭功能，但结构必须完整

---

## 💡 Echo 的核心原则（一句话）

> **Echo 永久保存的是「对话结构与回应关系」，媒体文件是否长期存在，由明确规则和责任方决定。**

这句话是整个方案的基石。

---

## 📋 群创建时的默认行为（必须这样）

### ✅ 创建群的默认状态

- **群消息保存期限**：永久
- **不弹窗**
- **不警告**
- **不额外解释**
- **和 Telegram 完全一致**

### ⚠️ 但这是"逻辑永久"，不是"无限资源承诺"

---

## ⚙️ 群的「消息保存期限」设置（与 Telegram 对齐）

**路径**：群设置 → 消息保存期限

**可选项**：
- 永久（默认）
- 1 天
- 7 天
- 30 天
- 90 天
- 自定义（高级）

### ⚠️ 关键点

**这个设置只影响"媒体文件生命周期"，不影响文本结构**

---

## 🏗️ 真正的关键：Echo 的「三层存储规则」

这是整个系统不爆炸的核心。

### 🟢 第一层：结构层（永久，强一致）

**永久保存，不可关闭**

**包含**：
- 文本消息内容
- 回复 / 引用关系（Echo 的核心）
- 时间线顺序
- 谁回应了谁
- 消息 ID、pts、qts

**特点**：
- 这层 ≈ Echo 的"记忆"
- 数据量极小
- PostgreSQL 可扛十年
- **永远不清理**

---

### 🟡 第二层：媒体层（可过期）

**图片 / 视频 / 文件**

#### 默认规则（推荐直接用）

| 类型 | 默认保留 |
|------|---------|
| 图片 | 180 天 |
| 视频 | 60 天 |
| 文件 | 30 天 |

#### ⚠️ 重要说明

**即使群设置为「永久」，这里依然遵循媒体生命周期规则**

👉 这是 Telegram 没说清楚、但实际存在的规则  
👉 你只是把它显式化了

---

### 🔵 第三层：保管层（付费 + 显式）

**当媒体要长期存在，必须进入这一层**

#### 三种合法进入方式

1. **群存储池**
   - 群主 / 管理员开启
   - 群成员可赞助
   - 成本和价值对齐

2. **发送者保管权**
   - 媒体"所有权"属于发送者
   - 过期前可一键「转入个人保管」
   - 计入个人额度

3. **Echo Plus（个人）**
   - 更长默认媒体保留期
   - 更大个人保管空间
   - 不影响群规则

---

## 🎨 媒体过期后的表现（非常重要）

### ❌ 禁止

- 直接消失
- 404 / 加载失败

### ✅ 正确做法：占位符（Echo 标准）

#### 示例 UI 文案

```
📼 该视频已过期
发送于 2026-03-14
由群主 / 发送者决定是否续存

按钮（权限控制）：
【续存 30 天】
【转入个人保管】
【群存储池续存】
```

👉 **消息还在，回响还在，只是媒体不在**

---

## 👥 谁为"长期媒体"负责？（成本分摊关键）

Echo 必须明确责任主体。

### 方案 A：群存储池（最重要）⭐⭐⭐

**群 = 成本单位**

**机制**：
- 每个群有一个「媒体池」
- 群主 / 管理员可开启
- 群成员可赞助

**用途**：
- 群内重要视频长期保留
- 课程群 / 项目群 / 社区群

**优势**：
- 👉 成本和价值对齐
- 👉 非常符合 Telegram 群使用习惯

---

### 方案 B：发送者保管权

**媒体的"所有权"属于发送者**

**机制**：
- 在过期前可一键「转入个人保管」
- 转入即计入个人额度

**适合**：
- 私聊
- 内容创作者自己的重要资料

---

### 方案 C：Echo Plus（个人）

**个人订阅服务**

**特权**：
- 更长默认媒体保留期
- 更大个人保管空间
- 不影响群规则

---

## 🚀 Echo v0 可直接落地的最小实现（可照抄）

### v0 存储规则（建议锁死）

| 内容类型 | 保留期限 |
|---------|---------|
| 文本 & Echo 结构 | 永久 |
| 图片 | 180 天 |
| 视频 | 60 天 |
| 文件 | 30 天 |

### 过期处理

**过期 → 占位符**

**权限**：
- 群主 / 发送者可续存

---

## 💭 你现在最该意识到的一件事

> **长期存储不是功能问题，是产品诚实度问题**

Echo 不需要比 Telegram 更"假无限"，而是：
- ✅ 更清晰
- ✅ 更可控
- ✅ 更公平

---

## � 关键设计原则（非常重要）

### 不要在 v0 把功能写死为"必须付费"

**正确做法**：

```go
if has_entitlement {
    media_retention = extended
} else {
    media_retention = default
}
```

👉 **支付只是改变参数，不是解锁逻辑**

---

## 💰 Echo 的正确支付策略：三阶段

每一阶段都不推翻前一阶段，不会产生技术债。

### 🟢 Phase 0（v0）：无支付也能跑

**核心策略**：先把"可计费结构"做出来，但不一定立刻收费

#### 你现在必须实现的

**不是支付，而是**：
- 群存储池（容量字段）
- 媒体生命周期（可续存）
- 个人保管额度
- "需要续存"的 UX 流程

👉 **即使没有支付，系统是完整的**

#### v0 的"替代方式"

- 群主手动控制（清理 / 不清理）
- 管理员 whitelist
- "申请续存"（先人工）

#### 这一步的目标只有一个

**验证用户是否真的在乎"长期保存"**

---

### 🟡 Phase 1（最现实）：App Store / Google Play 内购

**这是唯一对中国开发者友好的"合法全球支付"**

#### 项目结论

**中国开发者**：
- ✅ 可以无需备案
- ✅ 覆盖全球
- ✅ 审核成本可控
- ✅ 用户信任高

#### 怎么用在 Echo？

**支付的不是"钱"，而是额度 / 权限**

**例子**：
- Echo Plus（月订阅）
- 群存储扩展包
- 个人保管空间

#### 合规性

App Store / Google Play 不关心你是 IM 还是云存储

**它们只关心**："这是数字内容 / 服务"

**完全合规。**

#### 中国用户怎么付钱？（现实答案）

**短期现实**：中国用户 ≠ 一定要微信 / 支付宝

**实际情况**：
- iOS 用户：App Store 内购
- Android 用户：Google Play（海外）/ 第三方版本
- 核心用户：接受订阅

👉 Telegram、Notion、Spotify 都是这么过来的

---

### 🟠 Phase 2（有用户后）：第三方 Web 支付（可选）

**等你有这些条件再考虑**：
- 明确的海外用户比例
- 稳定月活
- 有人愿意为 Echo 付钱

**可选路径**：
1. 海外壳公司 + Stripe（常见于很多项目，但不是现在）
2. 代理商 / Reseller 模式（别人帮你收钱，你给他分成）
3. 社区赞助 / 群主代付（非常适合 Echo 群存储池）

---

### 🔵 Phase 3（长期）：直接支付 / 企业方案

**适用场景**：
- 企业客户
- 大型社区
- 内容创作者

**支付方式**：
- Stripe（国际）
- 支付宝 / 微信（国内）
- 企业对公转账

**特点**：
- 更灵活的定价
- 更大的存储空间
- 专属技术支持

---

## 📊 数据库层设计（v0 实现）- 正确版本

### 🚨 关键设计原则（生死线）

**ChatGPT 专家审查结论**：思路正确，但需要 4 个关键修正

#### ❌ 原方案的致命问题

1. **语义混乱**：`messages.media_status` 和 `files.status` 重复/不一致
2. **破坏 pts**：过期/删除如果不走 `update_log`，会直接把 `pts/getDifference` 搞烂
3. **并发错误**：`storage_pool_used` 做成静态字段，后期一定会算错
4. **引用矛盾**：`media_status` 放 `messages` 上，转发/引用/多消息共享同一文件时出现矛盾

#### ✅ 正确的设计原则

1. **唯一真相**：文件生命周期只有一个真相源 → `files` 表
2. **messages 只存引用**：不存状态，状态由 `files` 决定
3. **统计量可重算**：`used_bytes` 用异步统计表或 Redis，不做强一致字段
4. **任何可见变化必须走 updates**：绕开 updates 系统 = 破坏 getDifference

---

### 铁律：你可以随时改数据库，但你不能绕开 updates 系统

**任何导致"客户端看到内容变了"的行为，都必须**：
1. 产生 Update
2. 进入 `update_log`（或等价结构）
3. 分配 pts
4. 在线推送 + 离线靠 getDifference 回放

**永远不要**：
- ❌ 直接删 files
- ❌ 直接删消息
- ❌ 不发 update

---

## 📋 最终可用且长期可维护的字段方案

### ECHO v0: Storage & Permission Model (Server Pre-embed)

**目标**：
1. 不改变 MTProto/TL schema
2. DB 字段仅服务端内部使用
3. 任何可见变化必须走 updates/pts

---

### 1. Chat Storage Policy（群存储策略 - 单一真相源）

```sql
-- 群存储策略表
CREATE TABLE IF NOT EXISTS chat_storage_policy (
    chat_id             BIGINT PRIMARY KEY,
    message_ttl_seconds INT NULL,     -- NULL = 永久
    media_ttl_seconds   INT NULL,     -- NULL = 永久
    history_visibility  SMALLINT NOT NULL DEFAULT 0, -- 0=full, 1=limited, 2=none
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_storage_policy_updated
    ON chat_storage_policy(updated_at);

-- 说明：
-- 1. message_ttl_seconds: 消息 TTL（NULL = 永久）
-- 2. media_ttl_seconds: 媒体 TTL（NULL = 永久）
-- 3. history_visibility: 历史可见性（0=完全可见）
```

---

### 2. Chat Permission Policy（群权限策略）

```sql
-- 群权限策略表
CREATE TABLE IF NOT EXISTS chat_permission_policy (
    chat_id             BIGINT PRIMARY KEY,
    can_send_message    BOOLEAN NOT NULL DEFAULT TRUE,
    can_send_media      BOOLEAN NOT NULL DEFAULT TRUE,
    can_view_history    BOOLEAN NOT NULL DEFAULT TRUE,
    can_export_content  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 说明：
-- 1. can_send_message: 是否可发送消息
-- 2. can_send_media: 是否可发送媒体
-- 3. can_view_history: 是否可查看历史
-- 4. can_export_content: 是否可导出内容
```

---

### 3. Chat Member Role（成员角色 - 最小化）

```sql
-- 成员角色表
CREATE TABLE IF NOT EXISTS chat_member_role (
    chat_id     BIGINT NOT NULL,
    user_id     BIGINT NOT NULL,
    role        SMALLINT NOT NULL DEFAULT 2,
    -- 0=owner, 1=admin, 2=member, 3=restricted, 4=readonly
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_member_role_user
    ON chat_member_role(user_id);

-- 说明：
-- 1. role: 角色类型（0=群主, 1=管理员, 2=成员, 3=受限, 4=只读）
```

---

### 4. Files Lifecycle（文件生命周期 - 唯一真相源）⭐⭐⭐

```sql
-- files 表新增字段（唯一真相源）
ALTER TABLE files
    ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ NULL,
    ADD COLUMN IF NOT EXISTS status SMALLINT NOT NULL DEFAULT 0,
    -- 0=active, 1=expired, 2=archived, 3=deleted
    ADD COLUMN IF NOT EXISTS preserved_by SMALLINT NULL,
    -- 1=chat_pool, 2=sender, 3=subscription
    ADD COLUMN IF NOT EXISTS preserved_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_files_status_expires
    ON files(status, expires_at);

-- 说明：
-- 1. expires_at: 过期时间（NULL = 永不过期）
-- 2. status: 文件状态（0=活跃, 1=已过期, 2=已归档, 3=已删除）
-- 3. preserved_by: 保管方式（1=群存储池, 2=发送者, 3=订阅）
-- 4. preserved_at: 转入保管的时间
-- 
-- ⚠️ 关键：这是文件状态的唯一真相源
-- messages 表不存储 media_status，只存储 file_id 引用
```

---

### 5. Messages Reference Files（消息引用文件 - 不存状态）

```sql
-- messages 表新增字段（只存引用，不存状态）
ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS file_id BIGINT NULL;

CREATE INDEX IF NOT EXISTS idx_messages_file_id
    ON messages(file_id);

-- 可选：预计算的 TTL（不是权威来源，只是缓存）
ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS ttl_expires_at TIMESTAMPTZ NULL,
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_messages_ttl_expires
    ON messages(ttl_expires_at) WHERE ttl_expires_at IS NOT NULL;

-- 说明：
-- 1. file_id: 引用的文件 ID
-- 2. ttl_expires_at: 预计算的过期时间（缓存，不是权威来源）
-- 3. deleted_at: 删除时间（软删除）
-- 
-- ⚠️ 关键：messages 不存储 media_status
-- 媒体状态由 files.status 决定
-- 避免转发/引用时出现状态矛盾
```

---

### 6. Quota & Entitlement（配额与权益 - 预埋，v0 不强制）

```sql
-- users 表新增字段（预埋，v0 不强制）
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS storage_quota_bytes BIGINT NOT NULL DEFAULT 1073741824,
    ADD COLUMN IF NOT EXISTS storage_used_bytes  BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS entitlement_level  SMALLINT NOT NULL DEFAULT 0;
    -- 0=free, 1=plus, 2=pro...

-- 说明：
-- 1. storage_quota_bytes: 存储配额（字节）
-- 2. storage_used_bytes: 已使用存储（字节）- ⚠️ 统计量，可重算
-- 3. entitlement_level: 权益等级（0=免费）
-- 
-- ⚠️ 关键：storage_used_bytes 是统计量
-- 不要当强一致来源，用异步统计表或 Redis
```

---

### 7. Background Jobs（后台任务 - 通用，面向未来）

```sql
-- 后台任务表（通用，支持多种任务类型）
CREATE TABLE IF NOT EXISTS background_jobs (
    id            BIGSERIAL PRIMARY KEY,
    job_type      VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id   BIGINT NOT NULL,
    run_at        TIMESTAMPTZ NOT NULL,
    status        SMALLINT NOT NULL DEFAULT 0,
    -- 0=pending, 1=running, 2=done, 3=failed, 4=cancelled
    attempts      INT NOT NULL DEFAULT 0,
    last_error    TEXT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (job_type, resource_type, resource_id)
);

CREATE INDEX IF NOT EXISTS idx_background_jobs_run
    ON background_jobs(status, run_at);

-- 说明：
-- 1. job_type: 任务类型（file_expiration, message_cleanup, cold_storage_migration）
-- 2. resource_type: 资源类型（file, message, chat）
-- 3. resource_id: 资源 ID
-- 4. run_at: 执行时间
-- 5. status: 任务状态（0=待执行, 1=执行中, 2=已完成, 3=失败, 4=已取消）
-- 
-- ⚠️ 关键：通用任务表，支持幂等与分片
-- 未来加"消息过期""冷存迁移"不需要再造表
```

---

## 🎯 完整 SQL 脚本（可直接执行）

```sql
-- =====================================================
-- ECHO v0: Storage & Permission Model (Server Pre-embed)
-- Target DB: PostgreSQL
-- Version: 2.0.0
-- Created: 2026-02-03
-- 
-- Goals:
-- 1) Do NOT change MTProto/TL schema
-- 2) DB fields are internal only
-- 3) Any visible change MUST go through updates/pts
-- =====================================================

BEGIN;

-- -----------------------------------------------------
-- 1) Chat storage policy (single source for TTL rules)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_storage_policy (
    chat_id             BIGINT PRIMARY KEY,
    message_ttl_seconds INT NULL,     -- NULL = forever
    media_ttl_seconds   INT NULL,     -- NULL = forever
    history_visibility  SMALLINT NOT NULL DEFAULT 0, -- 0=full, 1=limited, 2=none
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_storage_policy_updated
    ON chat_storage_policy(updated_at);

-- -----------------------------------------------------
-- 2) Chat permission policy (role-based gate)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_permission_policy (
    chat_id             BIGINT PRIMARY KEY,
    can_send_message    BOOLEAN NOT NULL DEFAULT TRUE,
    can_send_media      BOOLEAN NOT NULL DEFAULT TRUE,
    can_view_history    BOOLEAN NOT NULL DEFAULT TRUE,
    can_export_content  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- -----------------------------------------------------
-- 3) Member roles (minimal)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_member_role (
    chat_id     BIGINT NOT NULL,
    user_id     BIGINT NOT NULL,
    role        SMALLINT NOT NULL DEFAULT 2,
    -- 0=owner, 1=admin, 2=member, 3=restricted, 4=readonly
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_member_role_user
    ON chat_member_role(user_id);

-- -----------------------------------------------------
-- 4) Files lifecycle (SINGLE SOURCE OF TRUTH)
-- -----------------------------------------------------
ALTER TABLE files
    ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ NULL,
    ADD COLUMN IF NOT EXISTS status SMALLINT NOT NULL DEFAULT 0,
    -- 0=active, 1=expired, 2=archived, 3=deleted
    ADD COLUMN IF NOT EXISTS preserved_by SMALLINT NULL,
    -- 1=chat_pool, 2=sender, 3=subscription
    ADD COLUMN IF NOT EXISTS preserved_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_files_status_expires
    ON files(status, expires_at);

-- -----------------------------------------------------
-- 5) Messages reference files, NO media_status here
-- -----------------------------------------------------
ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS file_id BIGINT NULL;

CREATE INDEX IF NOT EXISTS idx_messages_file_id
    ON messages(file_id);

-- Optional: precomputed ttl for messages (not authoritative)
ALTER TABLE messages
    ADD COLUMN IF NOT EXISTS ttl_expires_at TIMESTAMPTZ NULL,
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_messages_ttl_expires
    ON messages(ttl_expires_at) WHERE ttl_expires_at IS NOT NULL;

-- -----------------------------------------------------
-- 6) Quota & entitlement (pre-embed; v0 not enforced)
-- -----------------------------------------------------
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS storage_quota_bytes BIGINT NOT NULL DEFAULT 1073741824,
    ADD COLUMN IF NOT EXISTS storage_used_bytes  BIGINT NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS entitlement_level  SMALLINT NOT NULL DEFAULT 0;
    -- 0=free, 1=plus, 2=pro...

-- -----------------------------------------------------
-- 7) Background jobs (generic, future-proof)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS background_jobs (
    id            BIGSERIAL PRIMARY KEY,
    job_type      VARCHAR(50) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id   BIGINT NOT NULL,
    run_at        TIMESTAMPTZ NOT NULL,
    status        SMALLINT NOT NULL DEFAULT 0,
    -- 0=pending, 1=running, 2=done, 3=failed, 4=cancelled
    attempts      INT NOT NULL DEFAULT 0,
    last_error    TEXT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (job_type, resource_type, resource_id)
);

CREATE INDEX IF NOT EXISTS idx_background_jobs_run
    ON background_jobs(status, run_at);

COMMIT;

-- =====================================================
-- 说明
-- =====================================================
-- 1. 所有字段默认值保证现有逻辑不变
-- 2. files 表是文件状态的唯一真相源
-- 3. messages 表只存引用，不存状态
-- 4. 统计量（storage_used_bytes）可重算，不做强一致
-- 5. Phase 0-1 只预埋字段，不启用清理逻辑
-- 6. 未来启用清理时，必须走 updates/pts 系统
-- =====================================================
```

---

## 🚨 未来启用清理时的正确流程（生死线）

**当你真正启用 TTL/过期清理时，必须这样做**：

### 步骤 1：后台 Job 扫描过期文件

```go
func ScanExpiredFiles() {
    // 1. 扫描 files.expires_at <= now()
    expiredFiles := db.Query(`
        SELECT id, storage_path 
        FROM files 
        WHERE expires_at <= NOW() 
        AND status = 0
        LIMIT 1000
    `)
    
    for _, file := range expiredFiles {
        // 2. 更新文件状态
        db.Exec(`UPDATE files SET status = 1 WHERE id = ?`, file.ID)
        
        // 3. ⚠️ 关键：生成 Update 事件
        GenerateFileExpiredUpdate(file.ID)
    }
}
```

---

### 步骤 2：生成 Update 并进入 update_log

```go
func GenerateFileExpiredUpdate(fileID int64) {
    // 1. 找到引用该文件的所有消息
    messages := db.Query(`
        SELECT id, from_user_id, peer_type, peer_id 
        FROM messages 
        WHERE file_id = ?
    `, fileID)
    
    for _, msg := range messages {
        // 2. 为每个对话生成 Update
        update := &UpdateMessageMediaExpired{
            MessageID: msg.ID,
            FileID:    fileID,
        }
        
        // 3. ⚠️ 关键：分配 pts 并写入 update_log
        pts := AllocatePts(msg.FromUserID)
        WriteUpdateLog(msg.FromUserID, pts, update)
        
        // 4. 在线推送
        PushUpdateToOnlineSessions(msg.FromUserID, pts, update)
    }
}
```

---

### 步骤 3：客户端通过 getDifference 回放

```go
func GetDifference(userID int64, pts int) *Updates {
    // 1. 从 update_log 读取 pts 之后的所有 updates
    updates := db.Query(`
        SELECT pts, update_type, update_data 
        FROM pending_updates 
        WHERE user_id = ? AND pts > ?
        ORDER BY pts
    `, userID, pts)
    
    // 2. 返回给客户端
    return &Updates{
        Updates: updates,
        // ...
    }
}
```

---

## 🎯 核心原则总结

### ✅ 正确的做法

1. **files 表是唯一真相源**：文件状态只在 files 表
2. **messages 只存引用**：不存 media_status，避免矛盾
3. **统计量可重算**：storage_used_bytes 用异步统计
4. **任何可见变化走 updates**：分配 pts，写 update_log

### ❌ 错误的做法

1. **❌ messages 存 media_status**：转发/引用时状态矛盾
2. **❌ 直接删文件不发 update**：破坏 getDifference
3. **❌ storage_used 做强一致字段**：并发下会漂移
4. **❌ 绕开 updates 系统**：离线用户永远补不回来

---

## 📚 参考资料

- **ChatGPT 专家审查**：2026-02-03
- **核心原则**：唯一真相 + updates 系统 + 可重算统计量
- **生死线**：你可以随时改数据库，但你不能绕开 updates 系统

---

## 🎨 具体 UX 文案

### 1. 创建群设置页

**群设置 → 消息保存期限**

```
消息保存期限

○ 永久（推荐）
  文本和结构永久保存
  媒体文件按默认规则保留

○ 1 天
○ 7 天
○ 30 天
○ 90 天
○ 自定义

[了解媒体保留规则]
```

---

### 2. 媒体过期提示

**聊天界面 - 过期媒体占位符**

```
┌─────────────────────────────┐
│ 📼 该视频已过期             │
│                             │
│ 发送于 2026-03-14           │
│ 由 @username 发送           │
│                             │
│ [续存 30 天]  [转入个人保管] │
└─────────────────────────────┘
```

**权限控制**：
- 群主 / 管理员：可使用群存储池续存
- 发送者：可转入个人保管
- 其他人：只能查看

---

### 3. 续存弹窗

**点击"续存 30 天"**

```
续存该视频

该视频将从群存储池中续存 30 天

群存储池剩余：2.3 GB / 5 GB
该视频大小：45 MB

续存后到期时间：2026-04-14

[取消]  [确认续存]
```

---

### 4. 转入个人保管

**点击"转入个人保管"**

```
转入个人保管

该视频将永久保存在你的个人空间

个人空间剩余：450 MB / 1 GB
该视频大小：45 MB

转入后将不再占用群存储池

[取消]  [确认转入]
```

---

### 5. 群存储池管理（群主 / 管理员）

**群设置 → 群存储池**

```
群存储池

当前容量：2.3 GB / 5 GB

已保存媒体：
- 视频：12 个（1.8 GB）
- 图片：45 个（0.5 GB）

[扩展容量]  [查看详情]

成员贡献：
@alice  1 GB
@bob    2 GB
@carol  2 GB

[邀请成员赞助]
```

---

## 💰 成本模型估算

### 场景 1：100 个群（小规模）

**假设**：
- 平均每群 50 人
- 每天每群 10 条消息
- 30% 包含媒体（3 条/天）
- 平均媒体大小：2 MB

**计算**：
```
每日新增媒体：100 群 × 3 条 × 2 MB = 600 MB/天
每月新增：600 MB × 30 = 18 GB/月

按默认规则（视频 60 天，图片 180 天）：
- 视频存储峰值：600 MB × 60 = 36 GB
- 图片存储峰值：600 MB × 180 = 108 GB
- 总峰值：~150 GB

存储成本（MinIO / S3）：
- MinIO 自建：~$0（硬件成本）
- AWS S3：$150/月 × $0.023/GB = ~$3.5/月
```

**结论**：**成本极低，完全可控**

---

### 场景 2：1000 个群（中规模）

**假设**：
- 平均每群 100 人
- 每天每群 50 条消息
- 40% 包含媒体（20 条/天）
- 平均媒体大小：3 MB

**计算**：
```
每日新增媒体：1000 群 × 20 条 × 3 MB = 60 GB/天
每月新增：60 GB × 30 = 1.8 TB/月

按默认规则：
- 视频存储峰值：60 GB × 60 = 3.6 TB
- 图片存储峰值：60 GB × 180 = 10.8 TB
- 总峰值：~15 TB

存储成本：
- MinIO 自建：~$500/月（硬件 + 带宽）
- AWS S3：15000 GB × $0.023 = ~$345/月
```

**结论**：**需要考虑收费，但仍可控**

---

### 场景 3：10000 个群（大规模，视频为主）

**假设**：
- 平均每群 200 人
- 每天每群 100 条消息
- 50% 包含媒体（50 条/天）
- 平均媒体大小：5 MB（视频为主）

**计算**：
```
每日新增媒体：10000 群 × 50 条 × 5 MB = 2.5 TB/天
每月新增：2.5 TB × 30 = 75 TB/月

按默认规则：
- 视频存储峰值：2.5 TB × 60 = 150 TB
- 图片存储峰值：2.5 TB × 180 = 450 TB
- 总峰值：~600 TB

存储成本：
- MinIO 自建：~$5000/月（硬件 + 带宽 + 运维）
- AWS S3：600000 GB × $0.023 = ~$13800/月
```

**结论**：**必须收费，但有明确的成本模型**

---

### 收费策略建议

#### v0 阶段（免费）
- 支持 100-1000 个群
- 成本：$0-500/月
- 策略：吸引早期用户，验证需求

#### Phase 1（App Store 内购）
- 群存储扩展包：$2.99/月（5 GB）
- Echo Plus：$4.99/月（10 GB 个人空间 + 更长保留期）
- 预计收入：1000 付费用户 × $3 = $3000/月

#### Phase 2（企业方案）
- 企业群存储：$99/月（100 GB）
- 大型社区：$299/月（500 GB）
- 预计收入：100 企业客户 × $100 = $10000/月

---

## 🎯 你最关键的认知转变（很重要）

### 支付 ≠ 商业化第一步

**存储结构 + 权限模型 才是**

如果你现在就纠结：
- 用哪个支付平台
- 怎么绕备案

**那说明产品还没到那一步。**

### Echo 当前最重要的是

1. 群消息长期存在"逻辑正确"
2. 成本不会失控
3. 用户能理解"为什么要续存"

---

## 📋 正确的阶段顺序（强烈建议照抄）

### ✅ Phase 0（现在正在做的，别被打断）

**目标**：协议 & 状态一致性

**你现在只该关心这几件事**：
- MTProto / teamgram-proto 跑通
- 客户端能：登录、发消息、收消息
- 多端同步不炸（pts / getDifference 正确）
- 媒体能：上传、下载、正确关联消息

⚠️ **只要 getDifference 没 100% 正确，任何商业设计都是虚的**

---

### ✅ Phase 1（紧接着，但仍然不做支付）

**目标**：存储 & 权限"可计费结构"

**这里是关键，但不接支付**

#### 你现在就应该做的

**数据结构里有这些字段（但不收费）**：
- `retention_policy`
- `media_expire_at`
- `storage_quota`
- `owner_entitlement`

**群 / 频道创建时**：
- 默认：永久 or X 天（可配置）
- 到期后：自动清理 or 冻结（只读）

👉 **注意：这一步是产品能力，不是商业行为**

#### ❌ 现在不该做的事（很重要）

- ❌ 接 Stripe / Paddle / LemonSqueezy
- ❌ 研究 Apple IAP 细节
- ❌ 纠结中国用户怎么付钱
- ❌ 设计价格表

**这些现在做 = 100% 浪费时间**

---

### 为什么一定要"等跑通再做支付"

#### 1️⃣ 支付不是独立模块

**支付依赖于**：
- 权限模型是否稳定
- 存储生命周期是否真实存在
- 用户是否"被痛点打到"

**如果你现在做支付，后面一定会**：
- 改 SKU
- 改 entitlement
- 改逻辑
- 被苹果/Google 卡

#### 2️⃣ Apple / Google 审核只看"行为"，不看你未来规划

**他们只关心一件事**：
- 你现在卖的这个东西
- 用户点了
- 系统行为是不是合理

**而你现在根本还不知道要卖什么。**

---

## 🎯 正确的"提前准备"方式（不写代码）

你现在唯一可以做的准备只有这个：

👉 **写一份「未来可能收费点清单」（不实现）**

**例如**：
- 群存储扩展（可能收费）
- 个人云空间（可能收费）
- 高级群权限（可能收费）

**但**：
- ❌ 不接 SDK
- ❌ 不暴露 UI
- ❌ 不给用户选择付费

**只是设计层面的认知准备。**

---

## 🚦 给你一个可以直接执行的判断标准

### 你什么时候可以开始做支付？

**当且仅当**：
1. getDifference 连续跑 1-2 周无状态错误
2. 多端同时在线不乱序
3. 群里发 1000+ 条消息 + 视频不丢
4. 你自己愿意每天用 Echo 聊天

**这一天之前，不要碰支付一行代码。**

---

## 🎯 现在该做什么（完全不碰客户端）

### 结论：分两层做

#### ✅ 现在就做（不改客户端、风险极低）

**只做服务端/数据库层面的"可计费结构"与"生命周期"**

也就是：
- 先把"未来会收费的能力"变成后端的参数和状态机
- 客户端完全无感

#### ✅ 等跑通后再做（会改客户端、风险高）

**所有需要 UI、提示、设置入口、购买入口、容量显示 的东西**

这些都等 IM 核心稳定后再改。

---

### 1) 数据库先加"不会影响现有逻辑"的字段

**这些字段默认值保证行为不变**：

```sql
-- messages 表
messages.expire_at NULL  -- NULL = 永不过期

-- media 表
media.expire_at NULL

-- chats 表
chats.retention_days INT NULL  -- NULL = 永久
chats.storage_quota_bytes BIGINT NULL  -- NULL = 不限

-- users 表
users.entitlement_level SMALLINT DEFAULT 0  -- 0=免费
```

✅ **这些字段加了，客户端完全不知道**  
✅ **你也可以先不启用清理任务**

---

### 2) 服务端先实现"计算规则"，但不执行"删除"

**先做函数，不做动作**：

```go
ComputeExpireAt(chat, message)
CanUploadMedia(user, chat, size)
GetQuotaStatus(chat)
```

✅ **这不会改变任何现有路径**  
✅ **只是在为未来准备"正确的结构"**

---

### 3) 先打点（关键）

**即使不收费，你也要先知道**：
- 哪些群发视频最多
- 哪些媒体最占空间
- 单群每天增长多少 GB
- 用户是否真的在乎"永久"

✅ **这一步完全不需要客户端改动**  
✅ **你在服务端写日志/metrics 就行**

---

## 🚫 什么时候才需要动客户端？

**只有当你要做这些功能时，才必须改客户端**：
- 群设置里选择"消息保存期限"
- 群空间使用情况展示
- 超限后的提示（"需要扩容/清理/升级"）
- 购买入口（IAP/订阅）
- 媒体"即将到期"的标记

**这些属于 Phase：产品化/商业化，必须等协议与同步稳定。**

---

## 🎯 给你一个硬标准：什么时候可以开始二次开发客户端？

**满足这 4 条，再动客户端**：

1. 登录/发消息/收消息稳定
2. 多端同步（pts/getDifference）连续跑几天不出现断档/回滚
3. 媒体上传下载稳定
4. 你已经能用它当主力 IM（至少自己日常用）

**没到这一步，任何客户端 UI 改动都可能把你从"协议 bug"拉回"UI bug + 协议 bug"的双地狱。**

---

## 💡 最佳实践：现在"预埋"，以后"开关"

你现在就可以在服务端做成：

```go
retention_enabled = false  // 全局开关
quota_enabled = false
cleanup_job_enabled = false
```

**等跑通以后**：
1. 先开 `retention_enabled`
2. 观察一周
3. 再开 `cleanup_job_enabled`
4. 最后才开收费

**这样不会返工，也不会打断主线。**

---

## 🎯 下一步行动

### 立即执行（本周）- Phase 0

1. **✅ 创建本文档**
   - 完整的存储策略设计
   - 数据库 schema 设计
   - 实施原则和阶段划分

2. **📋 只在服务端 + DB 加字段（默认不生效）**
   - `media_files` 表（expire_at, status）
   - `group_storage_pools` 表（容量字段）
   - `user_storage_quotas` 表（额度字段）
   - `media_expiration_tasks` 表（过期任务）

3. **📋 写"计算 expire_at/quota"的纯函数（不删数据）**
   - `ComputeExpireAt(chat, message)`
   - `CanUploadMedia(user, chat, size)`
   - `GetQuotaStatus(chat)`

4. **📋 加 metrics 统计存储增长**
   - 哪些群发视频最多
   - 哪些媒体最占空间
   - 单群每天增长多少 GB

**客户端一行不改。**

---

### 短期执行（本月）- Phase 1

**⚠️ 前提：getDifference 已经稳定运行 1-2 周**

5. **📋 实现媒体生命周期管理（服务端）**
   - 媒体上传时设置 `expires_at`
   - 定时任务处理过期媒体（先不删，只标记）
   - 测试过期逻辑

6. **📋 实现群存储池功能（服务端）**
   - 群主开启 / 关闭存储池
   - 容量计算和统计
   - 续存媒体逻辑

7. **📋 实现个人保管功能（服务端）**
   - 转入个人保管逻辑
   - 个人空间管理
   - 额度统计

**客户端仍然不改。**

---

### 中期执行（下季度）- Phase 2

**⚠️ 前提：IM 核心功能已经稳定运行 30 天**

8. **📋 实现 UX 界面（客户端）**
   - 过期媒体占位符
   - 续存弹窗
   - 群存储池管理页

9. **📋 集成 App Store / Google Play 内购**
   - 群存储扩展包
   - Echo Plus 订阅
   - 支付流程

10. **📋 成本监控和优化**
    - 存储使用统计
    - 成本预警
    - 自动清理策略

---

## 📚 相关文档

| 文档 | 说明 |
|------|------|
| `ECHO_STORAGE_PERMISSION_MODEL.md` | 存储与权限模型（服务端预埋） |
| `ECHO_COMPLETE_DEVELOPMENT_PLAN.md` | 完整开发计划 |
| `ECHO_DEVELOPMENT_PLAN_V2.md` | 调整后的开发计划 |
| `AGENTS.md` | AI Agent 规范和架构铁律 |

---

**最后更新**: 2026-02-03  
**维护者**: Echo 项目团队  
**状态**: 设计方案 📋  
**版本**: 2.0.0 - 移除 Teamgram 对齐误导，明确 100% 自研定位

---

## 🎯 一句话总结

**Echo 通过三层存储架构（结构层永久 + 媒体层可过期 + 保管层付费），在保持用户体验一致性的同时，实现了成本可控、长期可维护的媒体存储方案，不产生技术债，不牺牲产品诚实度。**
