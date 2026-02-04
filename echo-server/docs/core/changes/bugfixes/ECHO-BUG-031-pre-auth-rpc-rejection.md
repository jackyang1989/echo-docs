# [ECHO-BUG-031] 客户端初始化 API 请求被 Gateway 拦截

**状态**: ✅ 已解决
**优先级**: P0 (阻塞所有客户端初始化)
**日期**: 2026-02-05
**作者**: AI Agent (Claude)

## 🛑 问题描述

**症状**:
- 客户端（尤其是 Android 重装后）无法进入验证码页面或长时间卡顿。
- Gateway 日志出现 `RPC rejected` 或未实现 RPC 的处理异常。
- 初始化阶段涉及 `help.getAppConfig` / `help.getCountriesList` / `langpack.*` 等请求。

**影响范围**:
- 所有新安装/重装的客户端。
- 登录前初始化流程。

## 🔍 根因分析

1. **Pre-Auth 白名单覆盖不足**
   - `pre_auth.go` 中白名单未包含部分初始化 RPC，导致合法请求被拒绝。

2. **未实现 RPC 采用 stub/空结果**（违反项目宪法）
   - 某些路径返回空对象/NotModified，造成客户端解析异常或逻辑卡住。

## 🛠 修复方案

### 1) 补齐 Pre-Auth 白名单
在 `pre_auth.go` 中加入初始化阶段常见 RPC（但不做假返回）：
- `help.getAppConfig`
- `help.getCountriesList`
- `langpack.getLangPack`
- `langpack.getStrings`
- `langpack.getDifference`
- `langpack.getLanguages`
- `auth.initPasskeyLogin`

### 2) Pre-Auth 明确返回 METHOD_NOT_IMPL
对未实现的 RPC **统一返回** `METHOD_NOT_IMPL`，保证合法 `rpc_error`，避免 stub：

```go
// internal/gateway/server_gnet.go
case *mtproto.TLHelpGetAppConfig61E3F854:
    logx.Warnf("⚠️ [Pre-Auth] help.getAppConfig not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
case *mtproto.TLLangpackGetLangPack:
    logx.Warnf("⚠️ [Pre-Auth] langpack.getLangPack not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
case *mtproto.TLLangpackGetLanguages:
    logx.Warnf("⚠️ [Pre-Auth] langpack.getLanguages not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
case *mtproto.TLHelpGetCountriesList:
    logx.Warnf("⚠️ [Pre-Auth] help.getCountriesList not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
case *mtproto.TLLangpackGetStrings:
    logx.Warnf("⚠️ [Pre-Auth] langpack.getStrings not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
case *mtproto.TLLangpackGetDifference:
    logx.Warnf("⚠️ [Pre-Auth] langpack.getDifference not implemented")
    rpcErr = mtproto.ErrMethodNotImpl
```

### 3) Router 兜底统一错误
`rpc_router.go` 中相同 RPC 也返回 `ErrMethodNotImpl`，确保所有路径都能稳定返回合法错误。

## ✅ 验证结果

- 初始化阶段不再出现 “RPC rejected: unknown”。
- 未实现 RPC 统一收到 `METHOD_NOT_IMPL`，客户端可安全回退或忽略。
- 不再出现 stub/空对象导致的解析异常。

## 📜 权威约束合规性

- **MTProto/TL Schema 未改动** ✅
- **无 stub/mock/假返回** ✅
- **返回合法 TL rpc_error** ✅

## 相关文档

- [ECHO-BUG-025: Pre-Auth RPC 白名单机制](./ECHO-BUG-025-pre-auth-rpc-whitelist.md)
- [ECHO-BUG-030: auth.initPasskeyLogin RPC 未处理](./ECHO-BUG-030-auth-init-passkey-login.md)
- [权威约束清单](../../../docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md)
