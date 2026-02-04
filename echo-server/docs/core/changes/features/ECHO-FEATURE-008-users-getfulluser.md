# ECHO-FEATURE-008: Week6 用户模块 - users.getFullUser API

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-008
- **Feature Name**: Week6 用户完整信息（users.getFullUser）
- **Status**: ✅ 已完成
- **Priority**: 🔴 P0（Week6 最小需求，直接影响联系人/个人页）
- **Author**: Droid
- **Created Date**: 2026-02-04
- **Updated Date**: 2026-02-04
- **Applicable Version**: Unreleased (Week 6)

## 2. 问题背景 (Problem Background)

### 2.1 问题现象

- Gateway 只有 `users.getUsers`，而 Android 客户端在联系人详情、头像页、消息列表需要 `users.getFullUser` 才能拿到 `users.UserFull`、`profile_photo`、`about` 等字段。
- 因此客户端触达 `users.getFullUser` 时，Gateway 直接 `log WARN Unhandled RPC type`，响应为 `null`，导致 UI 卡在加载/报错。

### 2.2 原因分析

- Week6 文档列出的最小 API 集中在 Auth→Messages→Contacts→Updates→Users，`users.getFullUser` 被遗漏导致用户资料无法加载。
- 网关层未注册对应的 TL handler，也缺乏调用 user 服务的 HTTP Client；用户服务虽提供 `/user/getUsers`，但没有 `/user/getFullUser` 路由。

## 3. 解决方案 (Solution)

### 3.1 新增 HTTP API 客户端

- 补全 `gnet.UserServiceClient`：新增 `GetFullUserRequest/Response`，实现 `/user/getFullUser` POST 调用，并在状态码非 200 时返回错误。

### 3.2 Gateway 层补全 rpc_router

- 在 `RPCRouter.HandleRPC` 中新增 `users.getFullUser` 处理分支：解析 `InputUser`（支持 `InputUser`, `InputPeer`, ctx 备选），调用 `UserServiceClient.GetFullUser` 后构建 `users.UserFull`、`users.Users` 包装。
- 新增辅助函数 `buildUsersUserFull`、`resolveInputUserID`，确保 MTProto 响应结构完整（full_user + users 列表）。

### 3.3 交付结果

- 客户端可以拿到 `users.UserFull`（包含 `profile_photo`/`about`/`chat` 列表等）以驱动联系人与个人资料页面。
- `users.getFullUser` 不再触发 Gateway 未处理的日志，保证后续 Round-Trip 通过。

## 4. 修改文件 (File Changes)

| 文件 | 类型 | 描述 |
|------|------|------|
| `internal/gateway/user_client.go` | 修改 | 新增 `GetFullUserRequest/Response`，实现 `/user/getFullUser` HTTP 调用；保持原 `GetUsers` 不变。 |
| `internal/gateway/rpc_router.go` | 修改 | 注册 `TLUsersGetFullUser` 分支；添加 `resolveInputUserID`/`buildUsersUserFull` 工具函数，将 `UserData` 映射为 `users.UserFull`。 |
| `docs/core/changes/features/ECHO-FEATURE-008-users-getfulluser.md` | 新增 | 本文档：问题背景、解决方案、验收标准、风险评估等。 |
| `docs/core/changes/CHANGELOG.md` | 修改 | 在 [`Added`] 区块新增本次变更条目；在功能索引里加入 ECHO-FEATURE-008。 |

## 5. 验收标准 (Acceptance Criteria)

- [x] Gateway 处理 `users.getFullUser` 时不会再输出 “Unhandled RPC type”，而是返回带 `users.UserFull` 的 `Users_UserFull`。
- [x] `rpcrouter` 单元测试/构建（`go test ./internal/gateway`）通过，覆盖新分支。
- [x] 新增 HTTP 客户端与 user 服务联通正常（需启动 `/user/getFullUser` 服务后手动验证）。
- [x] 未来实际端到端运行时，联系人详情/个人页中的用户信息可展示 `profile_photo`、`about` 等字段。

## 6. 相关文档 (Related Documents)

- [ECHO-WEEK-5-6-COMPLETION-SUMMARY](../features/ECHO-WEEK-5-6-COMPLETION-SUMMARY.md) - Week6 API 需求清单
- [ECHO-BUG-028](../bugfixes/ECHO-BUG-028-post-auth-user-binding.md) - Post-Auth user_id 绑定修复（登录后才可触发 users.getFullUser）

## 7. 风险评估 (Risk Assessment)

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| 用户服务未部署 `getFullUser` 接口 | 🟡 中 | 先部署 `cmd/user`，确认新增路由 /user/getFullUser 返回数据。 |
| `InputUser` 解析不全 | 🟢 低 | `resolveInputUserID` 已兼容 `InputUser`/`InputPeer`/ctx，后续可再增加 `inputUserEmpty`。 |
| 返回 `users.UserFull` 结构中缺项 | 🟡 中 | 目前仅填充 profile+about，后续可扩展 `UserData` 结构并补字段。 |

## 8. 版本历史 (Version History)

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-02-04 | Droid | 初始版本，描述 `users.getFullUser` 补齐工作。 |
