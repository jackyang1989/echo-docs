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

### 3.2 `messages.getPeerSettings`
实现基于 `ContactService` 和 `Router` 编排。

#### Repository 层
- 复用现有的 `ContactRepository`。

#### Service/API 层 (`internal/service/contacts/service.go`, `cmd/message/main.go`)
- 暴露了 `GetContact`（单个查询）接口，支持 Gateway 进行细粒度的权限检查。

#### Gateway 层
- `ContactsClient` 增加了 `GetContact` 方法。
- `RPCRouter` 实现了 `TLMessagesGetPeerSettings`：
  - 自动识别用户/群组/频道。
  - 对于用户 Peer，查询联系人状态。
  - 动态设置 `AddContact` (非联系人为 true) 和 `ReportSpam`。
  - 严禁 Mock：通过真实查询判断状态。

### 3.3 `messages.getMessages`
实现消息内容和发送者信息的完整获取。

#### Service/API 层
- 复用了现有的 `/message/getMessages` API (MessageService) 和 `/user/getUsers` API (UserService)。

#### Gateway 层
- `RPCRouter` 实现了 `TLMessagesGetMessages`：
  - 处理 `Vector<InputMessageID>` 输入。
  - 调用 `MessageClient.GetMessages` 获取消息体。
  - **Data Hydration**: 从消息中提取 `FromID` 和 `PeerID`，并调用 `UserClient.GetUsers` 批量获取 `UserData`。
  - 组装 `Messages_MessagesSlice`，确保 UI 能显示发送者头像和名称。

## 4. 剩余范围 (Phase 1.2+)

### 其他 RPC
- `messages.getPinnedDialogs`
- `account.getGlobalPrivacySettings`

## 5. 验证 (Verification)

- **编译检查**: 验证通过。
- **逻辑检查**: `messages.getMessages` 包含了数据补全（Hydration）步骤，优于单纯的数据透传。

## 6. 回滚计划 (Rollback Plan)

- 还原 `internal/gateway/rpc_router.go` 中的更改（注释掉 `case *mtproto.TLMessagesGetPeerDialogs`）。
- 向后兼容：逻辑仅新增方法，不修改现有行为。
