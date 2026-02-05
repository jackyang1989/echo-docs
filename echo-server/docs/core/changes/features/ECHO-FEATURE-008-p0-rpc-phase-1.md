# ECHO-FEATURE-008: P0 RPC Phase 1 实施记录 (Implementation)

## 元数据 (Metadata)
- **类型**: Feature
- **ID**: ECHO-FEATURE-008
- **日期**: 2026-02-05
- **状态**: 已实现 (messages.getPeerDialogs)
- **优先级**: P0-紧急
- **作者**: AI Agent

## 1. 背景 (Context)

通过分析客户端源码 (`MessagesController.java`) 发现，客户端在启动和 UI 初始化期间调用了 100+ 个 RPC 方法，但 Gateway 目前只实现了 37 个。这种差距导致主要功能（如设置、聊天记录等）无法使用。

## 2. 目标 (Goals)

实现登录后 UI 初始化所需的 16 个紧急 RPC端点。

**Phase 1 严格约束**:
- **严禁 Stub/Fake**: 必须返回真实数据或 `ErrMethodNotImpl`。
- **正确性**: 返回的数据必须与 `updates` 和 `pts` 保持一致。

## 3. 已实现变更 (Phase 1.1)

### 3.1 `messages.getPeerDialogs`
实现严格遵循 SSOT 原则，直接查询 `dialogs` 表。

#### Repository 层 (`internal/repository/dialog_repo.go`)
- 在 `DialogRepository` 接口和 `PostgresDialogRepository` 实现中添加了 `GetDialogsByPeers` 方法。
- 使用 `(peer_type, peer_id) IN (...)` 语法实现了高效 SQL 查询，避免 N+1 问题。

#### Model 层 (`internal/model/message.go`)
- 添加 `Peer` 结构体，用于 Repository 查询的格式化输入。

#### Service 层 (`internal/service/message/service.go`)
- 添加 `GetPeerDialogs` 方法，调用 Repository 并返回 `model.Dialog` 对象（避免与 Gateway DTOs 的循环依赖）。

#### HTTP API 层 (`cmd/message/main.go`)
- 注册 `POST /message/getPeerDialogs` 接口。
- 处理从 JSON 请求到 Service 调用并返回 JSON 响应的转换。

#### Gateway Client 层 (`internal/gateway/message_client.go`)
- 添加 `InputPeerStruct` 和 `GetPeerDialogsRequest/Response` 结构体。
- 添加 `GetPeerDialogs` 客户端方法以调用 Message Service API。

#### Gateway Router 层 (`internal/gateway/rpc_router.go`)
- 在 `HandleRPC` 中添加 `TLMessagesGetPeerDialogs` 分支。
- 实现了 `handleMessagesGetPeerDialogs` 辅助函数：
  - 解析 `TLInputDialogPeer` 提取 User/Chat/Channel ID。
  - 调用 Message Client。
  - 将结果转换回 `TLDialog` 对象。
- 移除了 `gateway` 包的自引用导入，修复了 Import Cycle 问题。

## 4. 剩余范围 (Phase 1.2+)

### messages.getPeerSettings
- 需要在 `ContactsService` 中实现检查 `contacts` 和 `blocked` 表的逻辑。

### 其他 RPC
- `messages.getPinnedDialogs`
- `messages.getMessages`
- `account.getGlobalPrivacySettings`

## 5. 验证 (Verification)

- **编译检查**: 通过 `go build ./cmd/gateway/main.go` 和 `go build ./cmd/message/main.go` 验证通过。
- **逻辑检查**: 代码路径遵循 `RPC -> Gateway -> MessageClient -> MessageService -> DialogRepo -> DB` 的标准流程。

## 6. 回滚计划 (Rollback Plan)

- 还原 `internal/gateway/rpc_router.go` 中的更改（注释掉 `case *mtproto.TLMessagesGetPeerDialogs`）。
- 向后兼容：逻辑仅新增方法，不修改现有行为。
