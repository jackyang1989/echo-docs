# [ECHO-BUG-033] getDifference 回放缺失消息体 & 历史查询方向错误导致聊天转圈

**状态**: ✅ 已解决  
**优先级**: P0（影响核心聊天可用性）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 打开会话一直转圈，消息无法送达/接收。
- 聊天列表或顶部信息显示手机号而不是昵称。
- Gateway 日志出现大量 `Unhandled RPC`（emoji/sticker 相关）。

## 🔍 根因分析

1. **getDifference 回放缺失消息体**  
   Gateway 在处理 `updates.getDifference` 时只返回 `pts/pts_count`，未构造 `message` 内容，客户端无法还原消息。

2. **历史消息查询方向错误**  
   `messages.getHistory` 仅读取 `peer_id = 对方` 的单向消息，接收方无法看到来自发送方的消息记录。

3. **非核心 RPC 未处理**  
   `messages.getEmojiStickers / getFeaturedEmojiStickers / getArchivedStickers / getStickerSet` 等未处理，导致日志噪音并引发客户端初始化重试。

## 🛠 修复方案

1. **getDifference 构造完整 Update**  
   - 将 `updateNewMessage / updateReadHistory / updateDeleteMessages` 转为合法 MTProto Update。  
   - 拉取 `message_id` 对应消息，填充 `message`、`peer`、`date` 等字段。  
   - 回填 `Users` 列表，保证昵称可显示。

2. **修复历史消息查询**  
   - `GetHistory` 改为双向查询：  
     `(from_user_id = A AND peer_id = B) OR (from_user_id = B AND peer_id = A)`  
   - 保证双方均能看到完整会话历史。

3. **补齐非核心 RPC**  
   - Emoji/Archived Sticker RPC 返回空集合（语义正确）。  
   - `messages.getStickerSet` 返回 `STICKERSET_INVALID`（当前无贴纸系统）。  
   - `account.updateStatus` 明确返回 `METHOD_NOT_IMPLEMENTED`。

## ✅ 影响范围

- `echo-server/internal/gateway/rpc_router.go`
- `echo-server/internal/repository/message_repo.go`
- `echo-server/internal/service/message/service.go`

## ✅ 验证结果

- `go test ./...`（`echo-server` 模块）通过  
- Gateway / Message / Sync 重启成功  
- `sync/getDifference` 返回完整 `updateNewMessage`（含 message_id）

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **getDifference 真实回放 update_log** ✅  
- **未实现功能明确返回错误** ✅

## 相关文档

- [ECHO-BUG-032: Session 使用 auth_key_id 选择错误导致预授权读取失败](./ECHO-BUG-032-session-auth-key-id-selection.md)
- [权威约束清单](../../../docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md)
