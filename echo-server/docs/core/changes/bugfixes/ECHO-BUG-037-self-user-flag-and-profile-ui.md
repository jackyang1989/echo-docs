# [ECHO-BUG-037] 自身用户未标记 Self 导致设置页/昵称异常

**状态**: ✅ 已解决  
**优先级**: P0（影响设置入口与聊天昵称显示）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 重新登录后聊天顶部显示对方手机号而非昵称。
- 设置页进入后仅显示“Add to contacts”等简化信息，缺失完整入口。
- 自己资料页被当作“他人资料页”展示。

## 🔍 根因分析

`users.getUsers / users.getFullUser / messages.*` 返回的 `User` 对象未标记 `Self=true`，  
客户端无法识别“当前登录用户”，导致设置页与昵称逻辑走了“他人用户”分支。

## 🛠 修复方案

1. **补齐 Self 标记**
   - 在所有返回 `User` 的 RPC 中，如果 `user_id == ctx.userID` 则设置 `Self=true`。

2. **UserFull 构建同步 Self**
   - `users.getFullUser` 同样使用带 Self 标记的 User。

## ✅ 影响范围

- `echo-server/internal/gateway/rpc_router.go`

## ✅ 验证结果

- 设置页恢复完整入口。
- 聊天标题显示昵称一致。

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **返回结构符合 Telegram 语义** ✅

