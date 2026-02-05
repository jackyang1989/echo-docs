# [ECHO-BUG-034] messages.getPeerDialogs 返回缺失 Users 导致昵称显示为手机号

**状态**: ✅ 已解决  
**优先级**: P0（影响核心聊天可用性）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 同一对话双方显示不一致：一端显示昵称，另一端只显示手机号。
- 打开聊天后顶部标题为手机号，且部分会话无法实时刷新。

## 🔍 根因分析

`messages.getPeerDialogs` 当前只返回 `Dialogs`，`Users/Messages/State` 为空，
客户端无法拿到对等用户的 `User` 对象（姓名字段），因此回退显示手机号。

## 🛠 修复方案

1. **补齐 messages.getPeerDialogs 返回结构**
   - 拉取 `TopMessage` 对应消息，构造完整 `Messages`。
   - 汇总涉及用户 ID（self + peer + message.from），调用 `users.getUsers` 回填 `Users`。
   - 拉取 `sync.getState`，回填 `State`。
   - 对话条目补齐 `notify_settings`。

2. **保持一致性约束**
   - 不修改客户端逻辑。
   - 不返回 fake 数据；无数据则为空集合。

## ✅ 影响范围

- `echo-server/internal/gateway/rpc_router.go`

## ✅ 验证结果

- `go test ./...`（`echo-server` 模块）通过
- `messages.getPeerDialogs` 返回包含 `Users` 与 `Messages`
- 客户端对话标题显示昵称一致

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **缺失功能不伪造成功** ✅

## 相关文档

- [ECHO-BUG-033: getDifference 回放缺失消息体 & 历史查询方向错误导致聊天转圈](./ECHO-BUG-033-updates-diff-and-history.md)
- [权威约束清单](../../../docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md)
