# Echo 权威约束清单（不可妥协）

**日期**: 2026-02-03
**版本**: 1.0.0
**状态**: ✅ 生效中
**适用范围**: Echo 全部仓库与文档（echo-server / echo-proto / echo-android-client / echo-docs / Admin / Square）

本文件的目标是把“不会改 TL/MTProto”这类硬约束写进文档结构本身，让后续任何人都不可能误解、也不可能写出“看起来能做、实际做不了”的方案。

关联权威文档：
- `echo-docs/AGENTS.md`
- `echo-docs/ECHO执行方案-精简版.md`

---

## 0. 单一真相源（Single Source of Truth, SSOT）

### 0.1 协议 SSOT

Echo 必须满足：
- MTProto 协议正确性
- 与选定 API Layer 的 Telegram 客户端期望一致（冻结版本）
- `updates/pts/qts/getDifference` 的一致性与可回放

Echo 不需要满足：
- 任何第三方服务端业务实现（例如 Teamgram 的业务逻辑）

Teamgram 仅允许用于：
- MTProto Gateway / 协议解析与协议层参考（仅协议层）

### 0.2 数据 SSOT

媒体生命周期的唯一真相源是 `files`（或 files 子系统）。

禁止出现第二套“同等权威”的生命周期真相源（例如 `media_objects`），除非它是明确的迁移方案且包含：
- deprecation 计划
- 双写/回填策略
- 回滚策略

### 0.3 执行 SSOT

Admin 负责“写策略 + 记审计”，Core 负责“关键路径强制执行”。

策略必须不可被绕过（non-bypassable）。

---

## 1. 硬禁止：不得修改 MTProto / TL Schema

### 1.1 禁止事项

禁止新增/修改任何 TL 相关内容（包括但不限于）：
- 新增 TL type / TL constructor / TL update / TL field
- 文档中出现会暗示“新增 TL Update”的命名，例如：
  - `UpdateMediaStateChanged`
  - `UpdateChatPermissionPolicy`
  - `UpdateMessageDeleted`

### 1.2 允许的“客户端可见结果”（必须使用既有 Telegram 机制）

所有用户可见变化必须由现有 Telegram 兼容机制表达：
- 消息删除：`updateDeleteMessages` / `updateDeleteChannelMessages`
- 消息编辑：`updateEditMessage` / `updateEditChannelMessage`
- 群默认禁言/权限：`updateChatDefaultBannedRights` + `chatBannedRights`
- 媒体不可用/文件引用失效：返回既有错误码（例如 `FILE_REFERENCE_EXPIRED` / `FILE_REFERENCE_EMPTY` / `FILE_REFERENCE_INVALID`）

备注：上述名称可在 `echo-proto` 中直接找到（`echo-proto/v2/tg/*`、`echo-proto/mtproto/*`）。

---

## 2. 双层事件模型：Client-visible vs Internal

### 2.1 Client-visible change（TL 兼容）

凡是会影响客户端“看到什么”的状态变化，都必须：
1) 产生可回放记录（写入 `update_log` 或等价的可回放存储）
2) 能被 `updates.getDifference` 完整回放
3) 对外表现必须映射到既有 TL 机制（见 1.2）

### 2.2 Internal event（服务端内部事件）

Internal event 允许用于：异步任务、审计、运营配置、风控联动、分析等。

命名要求：
- 必须版本化：`im.xxx.yyy.v1`
- 必须显式标记为 internal（不下发给客户端作为 TL update）
- 文档中禁止使用 `Update*` 前缀命名 internal event

示例：
- `im.media.lifecycle.changed.v1`
- `im.chat.policy.updated.v1`
- `square.post.moderation.result.v1`

---

## 3. 生死线：updates / pts / qts / getDifference

### 3.1 不可协商

`updates/pts/qts/getDifference` 是系统生死线。
一旦不正确，多端状态会随时间持续漂移，最终不可恢复。

### 3.2 必须满足的规则

1) 任何“外部可观察”的状态变更都必须可回放
2) 后台 Job 执行删除/过期/迁移等，也必须写入可回放记录（不能静默）
3) `getDifference` 必须能从回放记录重建缺失更新
4) `pts/qts` 必须在其要求的作用域内严格单调（monotonic）且具备幂等保证

---

## 4. 媒体池与生命周期（files 为权威）

### 4.1 权威模型

媒体生命周期字段必须归属 `files`（或 files 子系统）：
- `expires_at`
- `status`（示例：active/expired/archived/deleted，具体枚举以 schema 为准）
- `preserved_by`
- `preserved_at`

可选（若未来需要去重/引用计数）：
- `files.ref_count` 或 `file_refs(file_id, owner_type, owner_id, created_at)`

### 4.2 messages 层规则

`messages` 只能引用 `file_id`（或 file_ids），不得成为生命周期真相源。
允许存“缓存/预计算字段”（例如 `ttl_expires_at`），但这些字段不得与 `files` 的权威状态产生矛盾。

### 4.3 文件引用失效（file_reference）

客户端已经具备 file reference 失效的重试与刷新机制。

服务端应使用既有错误码表达（示例）：
- `FILE_REFERENCE_EXPIRED`
- `FILE_REFERENCE_EMPTY`
- `FILE_REFERENCE_INVALID`

Android 客户端相关逻辑可参考：
- `echo-android-client/TMessagesProj/src/main/java/com/echo/messenger/FileRefController.java`（`isFileRefError`）

---

## 5. 权限模型必须对齐 Telegram rights 语义

### 5.1 禁止

- 定义无法映射到 Telegram rights 的权限模型
- 出现“服务端拒绝但客户端 UI 仍显示允许”的割裂

### 5.2 必须

所有权限/禁言/限制最终都要落到 Telegram 语义（例如 `chatBannedRights`、`updateChatDefaultBannedRights` 等）。

文档中必须维护一张映射表：
- Echo policy 字段 → Telegram rights 字段（注意很多字段语义是“禁止”，需要取反）

---

## 6. 后台任务（GC/过期/迁移）门禁

后台任务必须：
- 幂等（可安全重试）
- 可审计（who/when/what/reason/request_id）
- 不允许静默数据丢失

如果后台任务会造成客户端可见变化：
- 必须写入可回放记录（`update_log`）
- 必须能被 `getDifference` 回放

---

## 7. 广场（Square）边界规则

### 7.1 Square 是旁路系统

- Square 必须独立数据库（发布/互动/推荐/审核/实验参数等）
- Square 只读 IM（消费 IM 事件或只读视图）
- Square 禁止直接写 IM 核心消息表

### 7.2 ID 类型对齐

若 IM 使用 `BIGINT` 作为 user/chat ID，则 Square 中也必须使用 `BIGINT` 存储 `user_id/chat_id`。
`post_id` 可以是 ULID/UUID/string。

### 7.3 Square 媒体必须复用 media pool

Square 存储媒体必须引用 `file_id`（或 file_ids），不得以 URL 作为权威数据。

---

## 8. 管理后台（Admin）边界规则

### 8.1 严格分离

- Admin 服务：写策略/配置 + 审计
- IM Core：关键路径强制执行（upload.*、sendMessage、search、ban 等），不得依赖“拦截层”实现安全

### 8.2 强制审计与回滚

任何管理操作必须：
- 写入 `audit_log`（who/when/what/before/after/request_id）
- 对危险操作提供明确回滚策略（封禁/解散/紧急开关等）

---

## 9. 工程纪律（拒绝屎山）

禁止：
- 试验性代码混入主分支（注释掉旧代码、留死分支）
- stub/mock/fake success
- “先跳过以后补”破坏一致性

要求：
- 任何不确定假设必须在设计文档显式写清楚（而不是在代码里留 TODO 兜底）
- 任何可见变更必须可回放、可审计、可回滚

---

## 10. 扩展功能前置验收门槛

在启用存储/权限/Square/商业化前，必须先满足：
- 登录 + 纯文本消息收发可用
- 多端同步在 `pts/qts/getDifference` 下稳定
- `update_log` 可回放能力已验证
- 文件上传/下载 baseline 可用（以 `file_id` 模型为准）
- 管理操作具备审计（至少覆盖封禁/强制登出/紧急开关）

---

<a id="internal-transport-evolution-constraint"></a>

## 11. Internal Transport Evolution Constraint (P0)

### Hard Constraints (Week 1-8)

1. Until the end of Week 8, Gateway -> Auth / Message / Sync MUST continue using HTTP REST as the internal transport.
   - Temporary compatibility layers, stubs, fake success, or skipping logic are strictly forbidden.

2. Week 7-8 scope is strictly limited to:
   - Real-time push delivery (PushUpdate)
   - update_log based replay
   - MTProto end-to-end consistency (two devices identical)
   - stability, load testing, monitoring

   Any gRPC refactor or transport-layer replacement is prohibited during this period.

### When gRPC Migration Is Allowed

- Internal transport migration (HTTP -> gRPC) is only allowed starting from:
  **Week 9 (Phase 2, first iteration)**

- The migration must be:
  - behavior-preserving
  - fully reversible
  - independently verifiable via MTProto E2E tests

### Mandatory Migration Procedure

Step A. Extract interfaces first (no behavior change)

- Define backend interfaces inside Gateway:
  - AuthBackend.SendCode/SignIn/SignUp
  - MessageBackend.SendMessage/GetHistory/GetDialogs/ReadHistory/DeleteMessages
  - SyncBackend.PushUpdate/GetState/GetDifference
- Provide an HTTP implementation (existing REST) first and keep tests green.

Step B. Define gRPC protos (only cover implemented capabilities)

- Create new proto files:
  - `/api/proto/echo_auth.proto`
  - `/api/proto/echo_message.proto`
  - `/api/proto/echo_sync.proto`
- Generate Go code via buf or protoc.
- Only include Week 1-8 implemented P0 methods. Do not add unimplemented features.

Step C. Expose gRPC on services without removing HTTP

- Auth service adds a gRPC server.
- HTTP handlers and gRPC handlers MUST share the same business logic (same UseCase/Service). Do not duplicate logic.
- Repeat for Message/Sync.
- Deliverable: HTTP and gRPC both available, behavior identical.

Step D. Switch Gateway to gRPC with rollback

- Add config: `BACKEND_TRANSPORT=grpc|http` (default: http).
- In staging/local, switch to grpc and run E2E:
  - two devices identical
  - offline gap recovery via getDifference
  - update_log replay correctness
- After passing, change default to grpc but keep HTTP rollback for at least 2 weeks.

Step E. Remove HTTP (convergence)

- After 2 weeks without rollback in production, remove Gateway HTTP backend implementation and service HTTP routes (except /health if needed).
- Update docs to explicitly state:
  - Internal transport = gRPC
  - External protocol = MTProto

### Acceptance Gates

- Before/after migration: MTProto E2E MUST stay identical (two devices), offline gap recovery MUST work (getDifference), message order/read/delete behaviors MUST be unchanged.
- Any behavior difference is a failure. No "ship now, fix later".
