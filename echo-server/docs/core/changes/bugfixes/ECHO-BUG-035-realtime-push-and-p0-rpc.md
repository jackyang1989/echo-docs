# [ECHO-BUG-035] 实时推送未加密导致无效 & P0 RPC 缺失

**状态**: ✅ 已解决  
**优先级**: P0（影响实时收消息与登录后初始化）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 发送消息后对端无法实时收到，需要退出/重新进入或等待拉取。
- 登录后初始化阶段出现大量 `METHOD_NOT_IMPL` 或 UI 无法加载。

## 🔍 根因分析

1. **实时推送未加密且格式错误**
   - Gateway 推送接口把 JSON update 当作 TL 二进制发送。
   - 发送使用 `auth_key_id = 0` 的未加密消息格式，客户端直接丢弃。

2. **P0 初始化 RPC 缺失**
   - `messages.getDialogFilters / getDialogUnreadMarks`、`account.getPassword / getContentSettings / getContactSignUpNotification`、`contacts.getStatuses / getTopPeers / getBlocked` 未实现。
   - `messages.getPeerSettings` 返回结构不正确（应返回 `messages.PeerSettings` 而非 `PeerSettings`）。

## 🛠 修复方案

1. **实时推送改为合法 MTProto Updates**
   - 解析 update JSON，构造 `updates` 对象（含 `Updates/Users/State`）。
   - 使用 `auth_key_id + salt + session_id` 正确加密。
   - 通过 `serializeToBuffer2` + AES-IGE 加密发送。
   - 会话重连时补注册到 `SessionRegistry`，保证在线推送可达。

2. **补齐 P0 RPC**
   - `messages.getDialogFilters` 返回空过滤器列表（真实状态）。
   - `messages.getDialogUnreadMarks` 返回空 `Vector_DialogPeer`。
   - `account.getPassword` 返回未设置密码状态。
   - `account.getContentSettings` 返回默认值。
   - `account.getContactSignUpNotification` 返回 false。
   - `contacts.getStatuses` 返回空。
   - `contacts.getTopPeers` 返回 `topPeersDisabled`。
   - `contacts.getBlocked` 返回空集合。
   - `messages.getPeerSettings` 返回 `messages.PeerSettings`（含 Users）。

3. **设备推送注册落库**
   - 新增 `push_tokens` 写入逻辑，保存 `account.registerDevice` 结果。

## ✅ 影响范围

- `echo-server/internal/gateway/push_handler.go`
- `echo-server/internal/gateway/server_gnet.go`
- `echo-server/internal/gateway/push_token_store.go`
- `echo-server/internal/gateway/server.go`
- `echo-server/internal/gateway/rpc_router.go`
- `echo-server/cmd/gateway/main.go`

## ✅ 验证结果

- Gateway 重启后推送可用（客户端实时收到 update）。
- 登录后初始化不再因 P0 RPC 缺失卡住。

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **缺失功能明确返回禁用/空集合** ✅

## 相关文档

- [ECHO-BUG-034: messages.getPeerDialogs 缺失 Users 导致昵称显示为手机号](./ECHO-BUG-034-peer-dialogs-users-missing.md)
- [权威约束清单](../../../docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md)
