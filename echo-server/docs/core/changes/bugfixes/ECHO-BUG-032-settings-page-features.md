# Bug 修复：设置页面功能缺失

| 字段 | 值 |
|-------|-------|
| **Bug ID** | ECHO-BUG-032 |
| **标题** | 设置页面缺失 "聊天文件夹" 和 "我的星星" 入口 |
| **状态** | 处理中 |
| **严重程度** | 高 (UI 功能缺失) |
| **创建时间** | 2026-02-05 |
| **作者** | AI Agent |

## 1. 问题描述

### 1.1 症状
- 设置页面中缺少 "聊天文件夹 (Chat Folders)" 入口。
- 设置页面中缺少 "我的星星 (My Stars)" 入口。
- "省电模式" 显示为 "Power Usage" 而非正确的 "Power Saving" (该文案由 App Config 控制)。

### 1.2 影响
- 用户无法使用文件夹整理会话，也无法访问星星钱包功能。
- UI 文案不匹配，表明配置同步失败。

### 1.3 复现步骤
1. 登录 Echo 安卓客户端。
2. 进入 "设置" (Settings) 页面。
3. 观察菜单项是否缺失。
4. 观察个人头像 UI 是否异常（顶部缺少相机图标，显示为 "Set Profile Photo" 列表项）。

---

## 2. 根本原因分析

### 2.1 诊断
- 客户端依赖特定的 RPC 来启用这些功能：
    - `messages.getDialogFilters` -> "聊天文件夹"
    - `messages.getSuggestedDialogFilters` -> "聊天文件夹" (初始状态)
    - `payments.getStarsStatus` -> "我的星星"
    - `help.getAppConfig` -> 功能开关和本地化微调 (如 "Power Saving" 文案)。
    - `photos.getUserPhotos` -> 头像历史记录。
- **头像 UI 问题**: 如果 `UserFull` 缺少 `Settings` 或 `NotifySettings`，或者 `photos.*` RPC 缺失，客户端会回退到 "受限" 或 "引导" UI 状态，隐藏顶部编辑图标。
- **初始化拦截问题**: 客户端会将 `help.getAppConfig` 等请求包裹在 `InvokeWithLayer` 或 `InitConnection` 中发送。Gateway 之前未实现这些包裹层的递归解包，直接返回 `MethodNotImpl` 错误，导致配置接口从未被真正执行。

### 2.2 技术细节
- **缺失/阻塞的 RPC**:
    - `TLInvokeWithLayer` / `TLInitConnection` (拦截了核心配置请求)
    - `TLMessagesGetDialogFiltersEFD48C89` / `F19ED96D`
    - `TLMessagesGetSuggestedDialogFilters`
    - `TLPaymentsGetStarsStatus`
    - `TLHelpGetAppConfig61E3F854` / `98914110`

---

## 3. 解决方案设计

### 3.1 修复策略
- 实现 `InvokeWithLayer` 和 `InitConnection` 的递归处理，确保内部请求能被路由。
- 实现缺失的 RPC Handler，返回有效（即使是空）的响应以满足客户端协议要求。
- **核心逻辑**: 优先打通协议链路，确保 UI 完整展示，即使具体功能暂为空数据。

### 3.2 代码变更
- **`internal/gateway/rpc_router.go`**:
    - **关键修复**: 实现了 `TLInvokeWithLayer` 和 `TLInitConnection` 的递归解包。
        - 之前: 返回 `ErrMethodNotImpl`，阻断初始化。
        - 现在: 解码 `req.Query` (bytes) -> `TLObject` 并调用 `r.HandleRPC(ctx, inner)` 进行处理。
    - **功能支持**:
        - `help.getAppConfig`: 返回 JSON 配置，包含 `stars_enabled=true`, `chat_folders_enabled=true`, `power_saving_enabled=true`。
        - `messages.getDialogFilters` & `messages.getSuggestedDialogFilters`: 返回空列表。
        - `payments.getStarsStatus`: 返回零余额。
        - `photos.getUserPhotos`: 返回空列表。
        - `UserFull`: 填充 `Settings` 和 `NotifySettings` 字段。
    - **工具函数**: 添加 `makeBoolJSON` 安全构建 `JSONObjectValue`。

## 4. 验证计划

### 4.1 自动化测试
- `go build` 验证递归 Handler 和新增 RPC 的编译正确性。

### 4.2 手动验证
- **前置条件**: 彻底杀掉 App 进程（强杀）。
- **操作**: 启动 App。
- **观察**:
    1. 设置 -> "Chat Folders" 菜单出现。
    2. 设置 -> "My Stars" 菜单出现。
    3. 个人主页顶部 -> 出现相机图标（而非底部的 "Set Profile Photo"）。
    4. 日志 -> 确认 `help.getAppConfig` 及被包裹的 RPC 显示为 "Handled" (而非 "MethodNotImpl" 或 rejected)。

