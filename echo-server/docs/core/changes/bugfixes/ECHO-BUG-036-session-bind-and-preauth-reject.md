# [ECHO-BUG-036] 会话未绑定 user_id 导致预授权循环 & RPC 静默丢弃

**状态**: ✅ 已解决  
**优先级**: P0（影响登录后会话识别与消息收发）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 客户端登录后仍长期处于 Pre-Auth，`messages.sendMessage / messages.getDialogs` 等被静默丢弃。
- 列表出现“连接中/占位闪烁”，消息无法实时收发。
- `sessions` 表存在 `auth_key_id/session_id` 记录但 `user_id` 为空。

## 🔍 根因分析

1. **Session 绑定逻辑无效**
   - `BindUser` 对 `UPDATE 0 rows` 不报错，导致没有真正写入 `user_id`。
   - Gateway 认为绑定成功，实际数据库未更新，后续无法恢复授权态。

2. **Pre-Auth 非白名单 RPC 被静默跳过**
   - 未登录或丢失绑定时，非白名单 RPC 被忽略，客户端超时重试，进入“连接中”循环。

## 🛠 修复方案

1. **BindUser 严格校验行数**
   - `UPDATE` 影响行数为 0 时返回错误，明确“session 不存在”。

2. **绑定失败时创建真实 Session 并重试绑定**
   - 使用真实 `session_id` 与当前连接信息创建记录，然后绑定 `user_id`。

3. **Pre-Auth 非白名单 RPC 返回 AUTH_KEY_UNREGISTERED**
   - 让客户端明确进入重新登录流程，避免静默超时。

## ✅ 影响范围

- `echo-server/internal/gateway/session_store.go`
- `echo-server/internal/gateway/server_gnet.go`

## ✅ 验证结果

- 登录后 `sessions.user_id` 正确写入。
- Gateway 日志出现 `Authorized session bound`，Pre-Auth 循环消失。
- `messages.sendMessage / messages.getDialogs` 不再被跳过，实时收发恢复。

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **错误必须显式返回并可验证** ✅

