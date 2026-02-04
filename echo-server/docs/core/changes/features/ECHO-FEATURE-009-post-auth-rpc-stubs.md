# [ECHO-FEATURE-009] Post-Auth RPC 初始化桩实现

**状态**: ✅ 已完成
**类型**: 功能补全 / 紧急修复
**日期**: 2026-02-05
**优先级**: P0
**作者**: Antigravity

## 🎯 目标

解决客户端登录成功后，因一系列初始化 RPC（如 `account.getThemes`, `messages.getDialogFilters`）未实现而导致 UI 卡死、一直转圈的问题。

## 📝 变更内容

在 `internal/gateway/rpc_router.go` 中，为以下 RPC 增加了**桩实现（Stub Implementation）**。这些实现返回符合 MTProto 协议规范的空值或默认值，确保客户端能继续后续流程。

### 新增 RPC 支持

| RPC Constructor | 方法名 | 返回值 | 说明 |
|-----------------|--------|--------|------|
| `account.getThemes` | `TLAccountGetThemes` | `account.Themes{}` (Empty) | 解除 UI 主题加载阻塞 |
| `account.getGlobalPrivacySettings` | `TLAccountGetGlobalPrivacySettings` | `GlobalPrivacySettings{}` (Default) | 隐私设置初始化 |
| `messages.getDialogFilters` | `TLMessagesGetDialogFilters` (EFD48C89/F19ED96D) | `Vector<DialogFilter>{}` (Empty) | 文件夹标签页初始化 |
| `messages.getPinnedDialogs` | `TLMessagesGetPinnedDialogs` | `messages.PeerDialogs{}` (Empty) | 置顶会话初始化 |
| `messages.getAllStickers` | `TLMessagesGetAllStickers` | `messages.AllStickers{}` (Empty) | 表情包列表初始化 |
| `messages.getFeaturedStickers` | `TLMessagesGetFeaturedStickers` | `messages.FeaturedStickers{}` (Empty) | 推荐表情包初始化 |
| `messages.getRecentStickers` | `TLMessagesGetRecentStickers` | `messages.RecentStickers{}` (Empty) | 最近使用表情初始化 |
| `messages.getAttachMenuBots` | `TLMessagesGetAttachMenuBots` | `AttachMenuBots{}` (Empty) | 附件菜单 Bot 初始化 |

## 🔍 技术实现细节

1. **协议兼容性**:
   - 针对 `messages.getDialogFilters`，同时支持了 `EFD48C89` 和 `F19ED96D` 接两个版本的 Constructor，确保不同版本客户端兼容性。
   - 严格使用 `mtproto` 包提供的构造函数（如 `MakeTLGlobalPrivacySettings`）或结构体指针，确返回的 TL 对象序列化正确。

2. **数据一致性**:
   - `GlobalPrivacySettings` 的 `ArchiveAndMuteNewNoncontactPeers` 字段根据 schema 定义正确设置了 `_FLAGBOOLEAN`。

## 🛡 权威约束合规性 (Compliance)

- **[1.0] 硬禁止修改 MTProto**: 本次变更完全基于现有的 TL Schema 实现服务端逻辑，未修改任何 `.tl` 文件或生成代码。
- **[1.2] 服务端必须兼容既有客户端**: 实现了客户端必须的初始化 RPC，消除了 "Unhandled RPC type" 错误，提升了兼容性。
- **[2.2] 内部事件**: RPC 处理完全在 `rpcRouter` 内部消化，未使用 gRPC，符合 Week 1-8 仅使用 HTTP/Internal 的约束。
- **[12.0] 禁止硬编码**: 返回的是协议规定的“空状态”数据（空列表、默认语义值），不包含硬编码的业务配置（如 URL、IP 等）。

## ✅ 验证计划

- **手动验证**: 重启 Gateway 后，客户端应能结束 loading 动画，显示主界面（虽然列表为空）。
- **日志验证**: `gateway.log` 中不应再出现针对上述 RPC 的 `Unhandled RPC type` 警告。
