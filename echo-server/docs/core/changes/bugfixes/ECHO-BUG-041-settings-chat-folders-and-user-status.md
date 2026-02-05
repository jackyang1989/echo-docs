# Bug Fix: Settings 页面 Chat Folders 缺失与用户昵称显示问题

**ID**: ECHO-BUG-041
**Type**: Bugfix
**Date**: 2026-02-06
**Status**: Fixed
**Severity**: High (UI/UX Broken)

## 1. 问题描述

用户反馈了两个严重影响体验的 UI 问题：
1.  **Settings 页面缺失入口**: "Chat Folders" 和 "My Stars" 入口不显示。
2.  **聊天列表显示手机号**: 对方的昵称未显示，而是直接显示手机号。

## 2. 根本原因分析 (Root Cause Analysis)

### 2.1 Chat Folders 缺失
Telegram 客户端通过调用 `messages.getDialogFilters` RPC 来决定是否显示 "Chat Folders" 设置项。如果服务器不支持该 RPC 或返回错误，客户端会隐藏该入口。

经排查，`rpc_router.go` 中缺少该 RPC 的处理逻辑。虽然之前添加了 stub，但可能因版本后缀问题（`EFD48C89` vs `F19ED96D`）导致匹配失败。

### 2.2 用户昵称显示问题
客户端优先显示本地通讯录名称，如果没有，则显示 `User` 对象中的 `FirstName` / `LastName`。但是，如果 `User` 对象的状态不完整（例如缺少 `Status` 字段），或者 `Self` / `Contact` 标志设置不当，可能导致客户端降级显示逻辑异常。

经排查，`buildUserFromData` 构造的 `User` 对象缺少 `Status` 字段（默认为 nil），且 `Contact` 默认为 false。这导致客户端认为该用户"从未上线"且不是联系人，从而在某些视图中优先展示 Phone。

## 3. 解决方案

### 3.1 补齐 Chat Folders RPC
在 `internal/gateway/rpc_router.go` 中实现了 `messages.getDialogFilters` 的两个版本处理（兼容性）：

```go
case *mtproto.TLMessagesGetDialogFiltersEFD48C89:
    return &mtproto.Vector_DialogFilter{Datas: []*mtproto.DialogFilter{}}, nil

case *mtproto.TLMessagesGetDialogFiltersF19ED96D:
    return &mtproto.Vector_DialogFilter{Datas: []*mtproto.DialogFilter{}}, nil
```

返回空列表明确告知客户端"支持该功能但目前没有过滤器"，从而激活 UI 入口。

### 3.2 增强 User 对象构造
修改 `buildUserFromData` 和 `buildSelfUser`，强制填充 `Status` 字段：

```go
status := mtproto.MakeTLUserStatusOffline(&mtproto.UserStatus{
    WasOnline: int32(time.Now().Unix()), // 设置为"刚刚在线"
}).To_UserStatus()
```

这不仅解决了昵称显示问题，还避免了用户显示为"Last seen long ago"。

## 4. 验证结果

-   [x] **Settings UI**: "Chat Folders" 入口已出现。
-   [x] **Chat List**: 对话列表正确显示用户昵称。
-   [x] **My Stars**: 同时也确认 Stars 入口显示正常（之前已修复）。

## 5. 影响范围

-   `internal/gateway/rpc_router.go`: RPC 分发逻辑
-   无数据库 Schema 变更。
