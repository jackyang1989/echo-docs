# [ECHO-BUG-032] Session 使用 auth_key_id 选择错误导致预授权读取失败

**状态**: ✅ 已解决
**优先级**: P0（影响登录稳定性）
**日期**: 2026-02-05
**作者**: AI Agent (Claude)

## 🛑 问题描述

**症状**:
- 预授权阶段（TempAuthKey）出现 Session 不存在、`AUTH_KEY_UNREGISTERED`。
- 服务端日志频繁提示 `GetSession failed` 或 `UpdateSessionActivity failed`。

## 🔍 根因分析

Session 表主键为 `(auth_key_id, session_id)`，而在 `server_gnet.go` 中使用了 **permAuthKeyId** 来写入和读取 session。
在 TempAuthKey 阶段，`permAuthKeyId` 往往为 0 或未绑定，导致：
- `CreateSession` 使用错误 key 写入
- `UpdateSessionActivity` 与 `GetSession` 查不到记录

## 🛠 修复方案

统一使用当前连接的 **auth_key_id** 作为 session 的键：

```go
sessionAuthKeyId := authKey.AuthKeyId()
if sessionAuthKeyId == 0 {
    sessionAuthKeyId = permAuthKeyId
}

// CreateSession / UpdateSessionActivity / GetSession
// 统一使用 sessionAuthKeyId
```

## ✅ 影响范围

- `internal/gateway/server_gnet.go`
  - Session 的创建、更新、读取都改为 `sessionAuthKeyId`

## ✅ 验证结果

- 预授权阶段 Session 行可稳定创建与读取
- 不再出现重复 `AUTH_KEY_UNREGISTERED` 报错

## 📜 权威约束合规性

- **不修改 TL/协议** ✅
- **不使用 stub/mock** ✅
- **返回合法 TL rpc_error** ✅

## 相关文档

- [ECHO-BUG-030: auth.initPasskeyLogin RPC 未处理](./ECHO-BUG-030-auth-init-passkey-login.md)
- [ECHO-BUG-031: 客户端初始化 API 请求被 Gateway 拦截](./ECHO-BUG-031-pre-auth-rpc-rejection.md)
- [权威约束清单](../../../docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md)
