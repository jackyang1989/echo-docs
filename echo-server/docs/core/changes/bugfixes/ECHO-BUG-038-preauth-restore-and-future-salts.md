# [ECHO-BUG-038] 预授权未恢复已登录会话 & FutureSalts 在封装调用中丢失

**状态**: ✅ 已解决  
**优先级**: P0（影响登录后消息收发与登录页错误提示）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 重新登录后，客户端仍处于 Pre-Auth，`messages.sendMessage` 被静默跳过，消息无法发送。
- 登录页在输入手机号时弹出 `AUTH_KEY_UNREGISTERED`。
- Android 日志反复出现 `dc2 valid salt not found`。

## 🔍 根因分析

1. **已登录 AuthKey 未恢复授权状态**
   - 只在 `permAuthKeyId != 0` 时尝试恢复 `user_id` 绑定。
   - 正常永久 AuthKey 的 `permAuthKeyId` 为 0，导致恢复逻辑被跳过。
   - `bindAuthorizedSession` 也优先用 `permAuthKeyId`，与实际连接的 `auth_key_id` 不一致时绑定失败。

2. **TLGetFutureSalts 被封装后未进入 Pre-Auth 处理**
   - `invokeWithLayer/initConnection` 内部的 `get_future_salts` 被路由到 `rpcRouter`，未实现处理，导致客户端反复提示缺少 salts。

3. **Pre-Auth 阶段返回 AUTH_KEY_UNREGISTERED 触发客户端弹窗**
   - 登录前阶段返回该错误会造成明显的 UI 弹窗，影响体验。

## 🛠 修复方案

1. **恢复授权逻辑不依赖 permAuthKeyId**
   - 优先基于当前连接的 `auth_key_id` 恢复授权，必要时回退到 `perm_auth_key_id`。

2. **绑定时使用当前连接的 auth_key_id**
   - `bindAuthorizedSession` 以当前连接使用的 `auth_key_id` 作为主键，避免绑定到错误 key。

3. **在 Pre-Auth 中处理封装的 get_future_salts**
   - 对 `invokeWithLayer/initConnection` 内部的 `TLGetFutureSalts` 做直接处理，确保 salts 可用。

4. **Pre-Auth 阶段静默处理 AUTH_KEY_UNREGISTERED**
   - 登录前不返回该错误，避免登录页弹窗。

## ✅ 影响范围

- `echo-server/internal/gateway/server_gnet.go`

## ✅ 验证结果

- 登录后 Pre-Auth 正确恢复为 Authorized，`messages.sendMessage` 不再被跳过。
- `dc2 valid salt not found` 频率显著下降，登录页不再弹 `AUTH_KEY_UNREGISTERED`。

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **状态一致性可验证** ✅
