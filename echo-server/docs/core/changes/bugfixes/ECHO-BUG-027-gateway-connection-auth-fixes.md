# ECHO-BUG-027: Gateway 多项连接和认证问题修复

## 变更 ID
**ECHO-BUG-027**

## 基本信息
- **功能名称**: Gateway 多项连接和认证问题修复
- **变更类型**: Bug 修复（多项合并）
- **优先级**: 🔴 P0（阻塞登录流程）
- **开发者**: AI Agent (Claude)
- **开发日期**: 2026-02-04
- **上游版本基线**: Echo Gateway v0.1.0
- **状态**: ⏳ 进行中

---

## 问题描述

### 问题 1: auth.bindTempAuthKey 缺失响应
**现象**：客户端发送 `auth.bindTempAuthKey` 后没有收到响应，导致连接断开并重连。

**根本原因**：
- `server_gnet.go` 第 269-276 行只更新了内部状态（`permAuthKeyId` 和 `authKey.keyData`）
- **没有发送 `boolTrue` 响应给客户端**
- 客户端等待响应超时后断开连接

**修复**：
```go
// 第 277-299 行添加 boolTrue 响应
logx.Infof("✅ [Gateway] auth.bindTempAuthKey: binding temp_auth_key %d to perm_auth_key %d",
    authKey.AuthKeyId(), permAuthKeyId)

payload := serializeToBuffer2(salt, sessionId, &mtproto.TLMessage2{
    MsgId: nextMessageId(false),
    Seqno: 0,
    Bytes: 0,
    Object: &mtproto.TLRpcResult{
        ReqMsgId: msgId,
        Result:   mtproto.ToBool(true), // boolTrue
    },
})
// ... 加密并发送
return nil
```

---

### 问题 2: Gateway 重启后 AuthKey 缓存丢失
**现象**：Gateway 重启后，客户端使用已保存的 `auth_key_id` 连接，但服务器无法解密消息（日志显示 `frame is nil`）。

**根本原因**：
- `cache_auth_key.go` 的 `GetAuthKey` 方法只检查内存缓存
- **缓存未命中时不从数据库加载**
- Gateway 重启后内存缓存为空，导致所有现有 AuthKey 失效

**修复**：
```go
func (s *Server) GetAuthKey(authKeyId int64) *mtproto.AuthKeyInfo {
    // 1. 先查缓存
    if v, ok := s.cache.Get(cacheK); ok {
        return v.(*CacheV).V
    }

    // 2. 缓存未命中，从数据库加载 ✅ 新增
    keyInfo, err := s.authKeyStore.QueryAuthKey(context.Background(), authKeyId)
    if err != nil {
        logx.Debugf("GetAuthKey: cache miss and db query failed - auth_key_id: %d", authKeyId)
        return nil
    }

    // 3. 加载成功，写入缓存 ✅ 新增
    s.PutAuthKey(keyInfo)
    logx.Infof("✅ [Gateway] AuthKey loaded from DB - auth_key_id: %d", authKeyId)

    return keyInfo
}
```

---

### 问题 3: Pre-Auth 处理只处理第一条消息
**现象**：客户端在同一个 `msg_container` 中发送 `help.getConfig` 和 `auth.sendCode`，但只有 `help.getConfig` 被处理。

**根本原因**：
- `server_gnet.go` Pre-Auth 逻辑在处理完每条消息后都 `return nil`（第 443 行）
- 这导致 container 中的后续消息被跳过

**修复**：
```go
// 将 return nil 改为 continue
// 第 440-447 行
logx.Errorf("❌ [Pre-Auth] Error response sent: %v", rpcErr)
}

// ✅ 继续处理 container 中的下一条消息，而不是立即返回
continue
}
}
}
// ✅ Pre-Auth 处理完成，所有消息都已处理
return nil
```

---

### 问题 4: Pre-Auth 白名单遗漏 auth.* 方法
**现象**：`auth.sendCode` 在 `PreAuthPhaseInit` 阶段被拒绝，因为白名单只包含 `help.getConfig`。

**根本原因**：
- 白名单设计过于严格，`PreAuthPhaseInit` 阶段不允许 `auth.*` 方法
- 但客户端可能在 `help.getConfig` 后立即发送 `auth.sendCode`（在同一连接上）

**修复**：
```go
// pre_auth.go 第 23-38 行
var PreAuthWhitelist = map[PreAuthPhase]map[string]bool{
    PreAuthPhaseInit: {
        "help.getConfig":    true,
        "help.getNearestDc": true,
        // ✅ Auth 方法也在 Init 阶段允许
        "auth.sendCode":   true,
        "auth.resendCode": true,
        "auth.signIn":     true,
        "auth.signUp":     true,
        "auth.cancelCode": true,
    },
    // ...
}
```

---

## 修改的文件

| 文件 | 修改类型 | 行号 | 说明 |
|------|----------|------|------|
| `internal/gateway/server_gnet.go` | 修改 | 277-299 | 添加 `auth.bindTempAuthKey` 的 `boolTrue` 响应 |
| `internal/gateway/server_gnet.go` | 修改 | 443 | 将 `return nil` 改为 `continue` 以处理所有消息 |
| `internal/gateway/cache_auth_key.go` | 修改 | 32-57 | 添加数据库回退加载逻辑 |
| `internal/gateway/pre_auth.go` | 修改 | 23-32 | 将 auth.* 方法添加到 PreAuthPhaseInit 白名单 |

---

## 验证结果

### 日志验证

1. **auth.bindTempAuthKey 响应**：
```
✅ [Gateway] auth.bindTempAuthKey: binding temp_auth_key -6306388154772500547 to perm_auth_key 6118872497486220409
```

2. **AuthKey 数据库加载**：
```
✅ [Gateway] AuthKey loaded from DB - auth_key_id: 9118173138188678312, type: 1
```

3. **Pre-Auth 处理**：
```
✅ [Pre-Auth] Processing RPC in phase 0: *mtproto.TLHelpGetConfig
✅ [Pre-Auth] Phase transition: PreAuthInit -> PreAuthLogin
✅ [Pre-Auth] Response sent: *mtproto.Config
```

### 待解决问题

- ⏳ `auth.sendCode` 仍被识别为 `unknown`，需要检查 `getRPCMethodName` 类型匹配
- ⏳ `langpack.getLangPack` 等请求需要添加到白名单或单独处理

---

## 技术债务说明

### P0 硬编码配置问题

根据 AGENTS.md 第 175-203 行：

> **禁止做的事（硬性禁止）**：
> - 在 `cmd/*/main.go` 中硬编码任何业务配置常量或结构体初始化

**当前状态**：
- `cmd/gateway/main.go` 第 34-70 行存在硬编码配置
- 包括数据库连接参数、RSA Key 路径、External IP 等
- 这是 Week 1 遗留的临时措施

**计划修复**：
- 需要实现从 `configs/gateway.yaml` 加载配置
- 配置验证（fail-fast）
- 环境变量覆盖支持

---

## 回滚计划

如需回滚，按以下顺序操作：

1. **恢复 server_gnet.go**：
   - 移除 auth.bindTempAuthKey 响应逻辑（第 277-299 行）
   - 将 `continue` 改回 `return nil`（第 443 行）

2. **恢复 cache_auth_key.go**：
   - 移除数据库回退加载逻辑

3. **恢复 pre_auth.go**：
   - 移除 PreAuthPhaseInit 中的 auth.* 方法

4. **重新编译并部署**

---

## 相关文档

- [ECHO-BUG-025](ECHO-BUG-025-pre-auth-rpc-whitelist.md) - Pre-Auth RPC 白名单机制
- [ECHO-BUG-024](ECHO-BUG-024-gateway-rpc-response-not-sent.md) - Gateway RPC 响应发送逻辑缺失
- [ECHO_AUTHORITY_CONSTRAINTS.md](../../../../echo-docs/docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md) - 权威约束清单
