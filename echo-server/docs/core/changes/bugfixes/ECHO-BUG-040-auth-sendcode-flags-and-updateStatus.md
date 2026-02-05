# [ECHO-BUG-040] auth.sendCode/resendCode 响应类型/flags 不兼容 & account.updateStatus 未实现导致登录页弹错

**状态**: 🟡 已实现（待验收）  
**优先级**: P0（影响登录页体验与初始化稳定性）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 背景与现象

在 Android 客户端“输入手机号/请求验证码”的初始化阶段，出现以下问题：

- 登录页频繁弹出 `METHOD_NOT_IMPL` / `AUTH_KEY_UNREGISTERED` 等错误提示（toast）。
- 客户端在手机号页/验证码页出现转圈卡住（进入 `auth.sendCode` 之前或之后无法推进）。
- Gateway 日志出现 `account.updateStatus not implemented`（客户端在线心跳）。

> 备注：本记录仅覆盖本次对 Gateway `rpc_router` 的兼容性修复实现；是否已完全消除客户端转圈，需以端到端验收为准。

## 🔍 根因分析

1. **`auth.sendCode` / `auth.resendCode` 返回的 `auth.sentCode` 不兼容**
- Auth 服务返回的 `SendCodeResponse.Type` 为结构化 map。
- Gateway 若未正确从该 map 提取 `code_type/length/next_type/timeout` 并构造带合法 flags 的 `auth.sentCode`，客户端可能拒绝响应并表现为“转圈/无跳转”。

2. **`account.updateStatus` 未实现导致客户端弹 `METHOD_NOT_IMPL`**
- `account.updateStatus` 为客户端初始化/在线心跳的一部分。
- 若返回 `METHOD_NOT_IMPL`，客户端会显式提示错误并可能影响后续状态机推进。

## 🛠 修复方案（Gateway）

### 1) 统一从 Auth 响应提取验证码类型并构造 `auth.sentCode`

在 `rpc_router.go` 增加/使用以下辅助逻辑：
- `extractCodeTypeAndLength(resp *SendCodeResponse) (string, int)`：从 `resp.Type` map 中提取 `code_type` 与 `length`。
- `buildSentCodeType(codeType string, length int) *mtproto.Auth_SentCodeType`：将 `code_type/length` 映射为 MTProto `sentCodeType`。
- `buildAuthCodeType(nextType string) *mtproto.Auth_CodeType`：将 `next_type` 映射为 MTProto `auth.codeType`（用于 `next_type`）。

并在 `auth.sendCode` / `auth.resendCode` 路径：
- 使用提取到的 `code_type/length/next_type/timeout` 构造带正确 flags 的 `auth.sentCode` 返回。

### 2) `account.updateStatus` 返回 `boolTrue`

- 将 `account.updateStatus` 从未实现改为返回 `boolTrue`。
- 设计意图：在线状态以 session 活跃时间驱动，该 RPC 作为心跳确认应返回成功，避免客户端弹窗/中断初始化流程。

## ✅ 影响范围

- `echo-server/internal/gateway/rpc_router.go`

## 🔗 关联提交

该修复实现已出现在 `echo-server` 仓库提交中（可通过 `git log -S "buildSentCodeType" -- internal/gateway/rpc_router.go` 定位）：
- `88b029fa727d5fe34336848e14b517a39b5cf06b`（2026-02-05 23:04:00 +0800，自动提交）

## ✅ 验收建议（端到端）

1. 客户端首次安装/清空数据后进入手机号页：不应弹 `METHOD_NOT_IMPL`（尤其是 `account.updateStatus`）。
2. 请求验证码后应稳定进入验证码页；输入验证码后应进入首页，不应长期转圈。
3. Gateway 日志不应再出现 `account.updateStatus not implemented`。

## 📜 权威约束合规性说明

- **不修改客户端业务逻辑** ✅（本次仅改 Gateway）  
- **不使用 mock/stub/fake success** ✅（返回值基于协议语义：心跳成功、验证码类型来自真实 Auth 响应）  
- **可验证一致性** 🟡（需通过端到端验收确认客户端状态机稳定推进）

