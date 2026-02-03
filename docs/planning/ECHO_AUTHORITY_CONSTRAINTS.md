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

## 11. 内部传输演进约束（P0）

术语约定：后续所有文档统一使用术语“内部传输迁移（HTTP → gRPC，行为保持）”，不得使用“gRPC refactor”等替代说法。

### 硬约束（Week 1-8）

1. 在 Week 8 结束之前，Gateway -> Auth / Message / Sync 的内部传输必须继续使用 HTTP REST。
   - 严禁临时兼容层、stub、fake success、跳过逻辑等行为。

2. Week 7-8 的范围严格限制为：
   - 实时推送投递（PushUpdate）
   - 基于 update_log 的回放
   - MTProto 端到端一致性（两设备结果完全一致）
   - 稳定性、压测、监控

   在此期间，禁止任何 gRPC 改造或通信层替换。

### 何时允许进行内部传输迁移（HTTP -> gRPC，行为保持）

- 内部传输迁移（HTTP -> gRPC，行为保持）仅允许从以下时点开始：
  **Week 9（Phase 2 第一个迭代）**

- 迁移必须满足：
  - 行为保持：迁移前后外部可观察行为完全一致
  - 可回滚：支持一键回退到 HTTP
  - 可独立验收：可通过 MTProto E2E 测试独立验证

### 强制迁移流程（必须按步骤执行）

Step A. 先抽象接口（不改行为）

- 在 Gateway 内定义 Backend 接口：
  - AuthBackend.SendCode/SignIn/SignUp
  - MessageBackend.SendMessage/GetHistory/GetDialogs/ReadHistory/DeleteMessages
  - SyncBackend.PushUpdate/GetState/GetDifference
- 先提供 HTTP 实现（复用现有 REST），保证测试全绿。

Step B. 定义 gRPC Proto（只覆盖已实现能力）

- 新建 proto 文件：
  - `/api/proto/echo_auth.proto`
  - `/api/proto/echo_message.proto`
  - `/api/proto/echo_sync.proto`
- 用 buf 或 protoc 生成 Go 代码。
- 仅允许把 Week 1-8 已实现的 P0 方法写进 proto，禁止提前加入未实现功能。

Step C. 服务端同时暴露 gRPC（HTTP 不删）

- Auth 服务新增 gRPC server。
- HTTP handler 与 gRPC handler 必须复用同一业务逻辑层（同一 UseCase/Service），禁止复制逻辑。
- Message/Sync 同样处理。
- 产物：HTTP 与 gRPC 两条入口并存，行为一致。

Step D. Gateway 切换到 gRPC（可回滚）

- 增加配置项：`BACKEND_TRANSPORT=grpc|http`（默认 http）。
- 在 staging/本地先切到 grpc 跑 E2E：
  - 两设备结果完全一致
  - 断网补洞可收敛（getDifference）
  - update_log 回放正确
- 通过后将默认改为 grpc，但必须保留 HTTP 回滚开关至少 2 周。

Step E. 删除 HTTP（收口）

- 线上连续 2 周无回滚后，删除 Gateway 的 HTTP Backend 实现与服务端 HTTP 路由（如需要可保留 /health）。
- 更新文档，明确：
  - 内部传输 = gRPC
  - 外部协议 = MTProto

### 验收门禁

- 迁移前后：MTProto E2E 必须保持完全一致（两设备），断线补洞必须可用（getDifference），消息顺序/已读/删除等行为必须不变。
- 任何行为差异都视为失败，不允许“先上线再修”。

---

## 12. P0 规则：禁止硬编码配置（尤其是 DB/端口/RSAKey/DC 地址）

本条款用于防止“把环境/安全配置写死在代码里”导致不可维护、不可审计、不可回滚的问题。

### 12.1 硬性要求（必须全部满足）

1) `cmd/gateway/main.go`（以及所有 `cmd/*/main.go`）里禁止出现任何“业务配置常量/硬编码结构体初始化”

- 禁止 `NewServer(Config{...})` 这种写法
- 禁止把 DB `Host/Port/User/Password/DBName` 写死
- 禁止把 RSAKey 路径写死
- 禁止把 DC 地址 / ExternalIP / 端口写死（含 `127.0.0.1` / `localhost` / 内网 IP 等）

2) 配置的单一真相源必须是：`configs/*.yaml`（或环境变量覆盖）

- 启动时必须遵循：先加载配置 -> 再启动服务
- 允许通过环境变量覆盖配置路径（例如：`ECHO_CONFIG=/path/xxx.yaml`）

3) 启动失败必须 fail-fast

- 任何必填项缺失/为零值 -> 立即报错退出
- 不允许靠默认值“凑合跑”

### 12.2 一次性修复步骤（Gateway）

A. 删掉 `main.go` 内硬编码 config

- `main.go` 只做：解析 flags/env -> 读取 YAML -> `Validate()` -> `NewServer(cfg)` -> `Run()`

B. 实现统一的 Load + Validate（必须有）

1) `pkg/config/load.go`

- `func Load(path string) (Config, error)` // 从 YAML 读

2) `pkg/config/validate.go`

- `func (c Config) Validate() error`

必填项（至少）：

- Gateway.ListenAddr
- RSAKey.PublicKeyPath / PrivateKeyPath（或 key 内容）
- Database.Host / Port / User / Password / DBName
- ExternalIP / MTProtoPort（如果 `help.getConfig` 用到）

C. `main.go` 规范模板（所有服务一致）

- 必须支持：`--config configs/gateway.yaml`
- 允许 ENV 覆盖（可选）：`ECHO_CONFIG=/path/xxx.yaml`

D. 加“硬编码门禁”脚本（防复发）

在 `tools/validate-no-hardcode.sh` 新增检查（gateway 先做，后续扩到所有 cmd）：

- 发现以下任一模式直接失败：
  1) `Config{` 出现在 `cmd/gateway/main.go`
  2) `Database:` 出现在 `cmd/gateway/main.go`
  3) `RSAKey:` 出现在 `cmd/gateway/main.go`
  4) `localhost:` / `127.0.0.1:` / `192.168.` 出现在 `cmd/gateway/main.go`（防写死地址）

- 把该脚本加入 `./tools/validate-agents-compliance.sh` 里作为硬门禁

### 12.3 验收标准

删除硬编码后：

1) 仅改 `configs/gateway.yaml` 就能切换 DB/端口/ExternalIP
2) configs 缺字段时，Gateway 启动直接报“Missing config: Database.Host”并退出
3) `validate-no-hardcode.sh` 能抓到任何硬编码并失败

### 12.4 禁止偷懒

- 不允许“先补个 Database 默认值让它跑起来”
- 不允许“临时把 DB 关掉/跳过连接”
- 不允许“先注释掉 DB 初始化”
