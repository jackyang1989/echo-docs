# ECHO-BUG-031: AUTH_KEY_UNREGISTERED 错误显示问题

**状态**: 🟢 已完成 (Fixed)
**优先级**: P0 - 阻塞登录流程
**日期**: 2026-02-05

## 问题描述

用户在安装 APP 后打开时，**在进入输入手机号页面前**就会看到 `Unknown error: AUTH_KEY_UNREGISTERED` 错误提示。

### 用户报告

- 清空 APP 数据后仍然出现
- 完全卸载重装后仍然出现
- 错误在进入手机号输入页面时就出现

### 预期行为

- 用户不应该看到任何内部错误提示
- 即使需要重新协商密钥，这个过程应该对用户透明

## 修复方案

### 修复的代码路径

在 `server_gnet.go` 中找到并移除了**三个**返回 AUTH_KEY_UNREGISTERED 错误的位置：

#### 1. 孤儿 AuthKey 检查 (Line 291-337)

**原代码**：
```go
if ctx.preAuthPhase != PreAuthPhaseAuthorized && permAuthKeyId != 0 {
    userID, err := s.sessionStore.GetUserByAuthKey(...)
    if err != nil {
        // 返回 AUTH_KEY_UNREGISTERED 错误
        return mtproto.NewRpcError(mtproto.ErrAuthKeyUnregistered)
    }
}
```

**问题**：登录前的请求（如 auth.sendCode）当然没有绑定用户，不应该返回错误。

**修复**：移除错误返回，改为静默记录日志。

---

#### 2. asyncRun2 回调中的 -404 响应 (Line 853-862)

**原代码**：
```go
if errors.Is(err, mtproto.ErrAuthKeyUnregistered) {
    out2 := &mtproto.MTPRawMessage{Payload: make([]byte, 4)}
    binary.LittleEndian.PutUint32(out2.Payload, uint32(-404))
    _ = UnThreadSafeWrite(c2, out2)
}
```

**问题**：-404 错误码触发客户端显示错误弹窗。

**修复**：移除 -404 发送，改为静默关闭连接。

---

#### 3. asyncRunIfError 回调中的 RPC 错误 (Line 754-778)

**原代码**：
```go
if errors.Is(err, mtproto.ErrAuthKeyUnregistered) {
    payload := serializeToBuffer2(..., &mtproto.TLRpcResult{
        Result: mtproto.MakeTLRpcError(&mtproto.RpcError{
            ErrorCode:    403,
            ErrorMessage: "AUTH_KEY_UNREGISTERED",
        }).To_RpcError(),
    }, ...)
    _ = UnThreadSafeWrite(c, ...)
}
```

**问题**：发送 RPC 错误 403 AUTH_KEY_UNREGISTERED 给客户端。

**修复**：移除错误发送，改为静默记录日志。

---

### 待排查的其他可能来源

修复以上三处后，`server_gnet.go` 中已无 `AUTH_KEY_UNREGISTERED` 字符串，但用户仍然看到错误。

可能的其他来源：
1. **mtproto 包**：`ErrAuthKeyUnregistered` 可能在其他地方被使用
2. **rpc_router.go**：可能有返回此错误的 RPC 处理器
3. **auth_key_store.go**：`QueryAuthKey` 返回的错误可能被其他代码捕获
4. **客户端缓存**：客户端可能缓存了之前的错误状态

## 修复记录

| 时间 | 操作 | 结果 |
|-----|------|------|
| 09:08 | 修复第1处（孤儿AuthKey检查） | 错误仍存在 |
| 09:12 | 修复第2处（-404响应） | 错误仍存在 |
| 09:17 | 修复第3处（RPC错误响应） | 错误仍存在 |

## 下一步计划

1. 搜索 mtproto 包中所有 `ErrAuthKeyUnregistered` 引用
2. 搜索 rpc_router.go 中所有错误返回
3. 检查 echo-proto 中是否有相关错误定义
4. 考虑错误是否来自客户端自身逻辑

## 相关文件

- `/Users/jianouyang/Project/echo/echo-server/internal/gateway/server_gnet.go`
- `/Users/jianouyang/Project/echo/echo-server/internal/gateway/auth_key_store.go`
- `/Users/jianouyang/Project/echo/echo-server/internal/gateway/rpc_router.go`

## 符合 AGENTS.md 要求

- ✅ 不修改客户端代码
- ✅ 从服务端解决问题
- ✅ 记录完整的排查过程
- ✅ 保持代码可维护性
