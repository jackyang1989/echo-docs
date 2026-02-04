# ECHO-BUG-030: auth.initPasskeyLogin RPC 未处理

## 基本信息

| 字段 | 值 |
|------|-----|
| **变更 ID** | ECHO-BUG-030 |
| **变更类型** | Bug 修复 |
| **日期** | 2026-02-04 |
| **影响模块** | Gateway / RPC Router |
| **优先级** | P0 - 阻塞登录 |
| **状态** | ✅ 已修复 |

## 问题描述

### 症状
Samsung 手机无法进入验证码输入页面，客户端日志显示：

```
can't parse magic 87304e3e in TL_config
```

服务端日志显示：

```
⚠️ [RPC] Unhandled RPC type: *mtproto.TLAuthInitPasskeyLogin
```

### 根本原因
`auth.initPasskeyLogin`（constructor: 1368051895）是 **Layer 219+** 新增的 RPC，用于 Passkey 登录流程。

Echo 服务端的 `rpc_router.go` 和 `server_gnet.go` 没有处理该 RPC，导致：
1. 服务端返回错误响应
2. 客户端解析失败
3. 后续 RPC 交互中断

### 技术背景
- `TLAuthInitPasskeyLogin` 只有 `ApiId` 和 `ApiHash` 字段，**没有 `PhoneNumber`**
- 这是一个基于 WebAuthn/Passkey 的新型登录流程
- Echo 目前不支持 Passkey，需要返回适当错误让客户端回退到传统短信验证流程

## 修复方案

### 1. rpc_router.go 修改

**文件**: `internal/gateway/rpc_router.go`

**新增代码** (第 254-264 行):
```go
case *mtproto.TLAuthInitPasskeyLogin:
    // Layer 219+ 新增的 Passkey 登录 RPC。
    // Echo 暂不支持 Passkey：必须返回既有错误码（不得新增 TL/协议）
    logx.Warnf("⚠️ [RPC] auth.initPasskeyLogin not implemented (client should fallback)")
    return nil, mtproto.ErrMethodNotImpl
```

### 2. server_gnet.go 修改

**文件**: `internal/gateway/server_gnet.go`

**修改代码** (第 444-471 行):
```go
case *mtproto.TLAuthInitPasskeyLogin:
    logx.Warnf("⚠️ [Pre-Auth] auth.initPasskeyLogin not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
```

**修复说明**：
- 原代码尝试将 `auth.initPasskeyLogin` 映射为 `auth.sendCode`（违宪）
- 现改为 **明确返回 METHOD_NOT_IMPL**，不做任何兼容兜底

## 影响范围

- **影响文件**：
  - `internal/gateway/rpc_router.go` (新增 11 行)
  - `internal/gateway/server_gnet.go` (修改 7 行)
- **影响范围**：Gateway - Pre-Auth 和 Authorized RPC 处理
- **客户端版本**：所有 Layer 219+ 客户端

## 验证结果

1. ✅ Samsung 设备成功进入验证码输入页面
2. ✅ Samsung 设备成功完成登录
3. ✅ 编译通过，无错误

## Layer 兼容性说明

| Layer | auth.initPasskeyLogin | 处理方式 |
|-------|----------------------|----------|
| < 219 | 不存在 | N/A |
| ≥ 219 | 存在 | 返回 METHOD_NOT_IMPL 错误 |

客户端收到 `METHOD_NOT_IMPL` 后会回退到传统的 `auth.sendCode` 流程。

## 未来改进

如需支持 Passkey 登录，需要：
1. 实现 WebAuthn 后端服务
2. 添加 `auth.initPasskeyLogin` 正确响应
3. 实现 `auth.finishPasskeyLogin` 处理

## 相关链接

- 关联变更：ECHO-BUG-029（同一 session 修复）
- 上游对比：Telegram Layer 219 新增 RPC
- MTProto 协议：`auth.initPasskeyLogin#518ad0b7`
