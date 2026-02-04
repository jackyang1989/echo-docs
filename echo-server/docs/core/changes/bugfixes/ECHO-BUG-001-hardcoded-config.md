# ECHO-BUG-001: 硬编码配置导致客户端无限重试

**变更 ID**: ECHO-BUG-001
**变更类型**: Bug 修复
**优先级**: P0 (阻塞)
**开发者**: Claude (Antigravity AI)
**开发日期**: 2026-02-04
**上游版本基线**: Teamgram Gateway v1.0

---

## 📋 问题描述

### 症状
- **现象**: 登录后客户端显示空白界面，"没有一个功能可用，大量入口缺失"
- **日志**: 客户端无限循环调用 `help.getConfig`（137,872 次），其他 API 仅调用 116 次后停止
- **影响**: 即使在内网测试环境，功能也完全不可用

### 根本原因

经过日志分析发现：

```
# API 调用统计（整个日志文件）
137872 次 help.getConfig  ← 客户端疯狂重试！
116 次 users.getFullUser
116 次 updates.getState
116 次 messages.getDialogs
116 次 contacts.getContacts
```

**问题根源**：

1. **硬编码内网 IP**: `rpc_router.go:895` 硬编码返回 `192.168.0.17`
2. **客户端无法连接**: 收到配置后尝试连接内网 IP，连接失败
3. **无限重试**: 客户端不断重试 `help.getConfig`，导致其他 API 无法调用
4. **功能全失效**: 无法加载对话列表、联系人列表等任何功能

---

## 🔍 违反的宪法条款

### 违反 ECHO_AUTHORITY_CONSTRAINTS.md

1. **第 12.1 条**: 禁止在代码中硬编码业务配置
   - **违规代码**: `cmd/gateway/main.go:64` - `ExternalIP: "192.168.0.17"`
   - **违规代码**: `rpc_router.go:895` - `IpAddress: "192.168.0.17"`

2. **第 12.2 条**: 配置必须从 YAML 文件加载
   - **违规**: 完全未实现配置加载器，`configs/gateway.yaml` 形同虚设

3. **第 12.4 条**: 禁止硬编码 RPC 服务地址
   - **违规代码**: `internal/gateway/server.go:110` - 硬编码 `localhost:9001-9004`

### 违反 AGENTS.md

1. **第 123-130 条**: 禁止 stub/mock/fake 实现
   - **违规代码**: `rpc_router.go:254-255` - 硬编码 API ID/Hash
   - **违规代码**: `rpc_router.go:272` - `auth.cancelCode` 返回假成功
   - **违规代码**: `rpc_router.go:281` - `auth.bindTempAuthKey` 返回假成功

---

## 🛠️ 修复方案

### 修复 #1: help.getConfig 硬编码 IP

**文件**: `internal/gateway/rpc_router.go`
**行号**: 887-932

**修复前**:
```go
case *mtproto.TLHelpGetConfig:
    // ...
    for i := 1; i <= 5; i++ {
        dcOptions = append(dcOptions, mtproto.MakeTLDcOption(&mtproto.DcOption{
            Id:        int32(i),
            IpAddress: "192.168.0.17",  // ❌ 硬编码!
            Port:      10443,
        }).To_DcOption())
    }
```

**修复后**:
```go
case *mtproto.TLHelpGetConfig:
    // ✅ 从配置获取 ExternalIP
    externalIP := r.cfg.Gateway.ExternalIP
    mtprotoPort := r.cfg.Gateway.MtprotoPort

    for i := 1; i <= 5; i++ {
        dcOptions = append(dcOptions, mtproto.MakeTLDcOption(&mtproto.DcOption{
            Id:        int32(i),
            IpAddress: externalIP,  // ✅ 从配置读取
            Port:      mtprotoPort,
        }).To_DcOption())
    }
```

---

### 修复 #2: Gateway main.go 硬编码配置

**文件**: `cmd/gateway/main.go`
**行号**: 33-67

**修复前**:
```go
// ⚠️ Week 1: 使用硬编码配置（后续从文件加载）
cfg := gnet.Config{
    Server: gnet.ServerConfig{
        Name: "echo-gateway",
        Host: "0.0.0.0",
        Port: 10443,
    },
    Database: gnet.DatabaseConfig{
        Host:     "localhost",  // ❌ 硬编码
        Port:     5432,
        // ...
    },
    ExternalIP:  "192.168.0.17",  // ❌ 硬编码内网IP
    // ...
}
```

**修复后**:
```go
// ✅ 从配置文件加载
cfg, err := config.Load(*configFile)
if err != nil {
    log.Fatalf("Failed to load config: %v", err)
}
if err := cfg.Validate(); err != nil {
    log.Fatalf("Invalid config: %v", err)
}
```

---

### 修复 #3: 删除违宪的 stub 代码

**文件**: `internal/gateway/rpc_router.go`

#### 3.1 auth.resendCode 硬编码 API ID/Hash

**行号**: 254-255

**修复前**:
```go
case *mtproto.TLAuthResendCode:
    // TODO: Load from config or context
    resp, err := r.authClient.SendCode(&SendCodeRequest{
        PhoneNumber: req.PhoneNumber,
        ApiID:       2040,                               // ❌ 硬编码
        ApiHash:     "b18441a1ff607e10a989891a5462e627", // ❌ 硬编码
    })
```

**修复后**:
```go
case *mtproto.TLAuthResendCode:
    // ✅ 从 session 中获取之前保存的 API ID/Hash
    apiID := ctx.GetSessionApiID()
    apiHash := ctx.GetSessionApiHash()
    if apiID == 0 {
        return nil, errors.New("RESEND_CODE: missing API credentials in session")
    }

    resp, err := r.authClient.SendCode(&SendCodeRequest{
        PhoneNumber: req.PhoneNumber,
        ApiID:       apiID,
        ApiHash:     apiHash,
    })
```

#### 3.2 auth.cancelCode 假成功

**行号**: 268-272

**修复方案**: 删除或返回 NOT_IMPLEMENTED

```go
case *mtproto.TLAuthCancelCode:
    // ❌ 旧代码: return mtproto.MakeTLBoolTrue(nil).To_Bool(), nil

    // ✅ 方案1: 真正实现
    err := r.authClient.CancelCode(&CancelCodeRequest{
        PhoneNumber:   req.PhoneNumber,
        PhoneCodeHash: req.PhoneCodeHash,
    })
    if err != nil {
        return nil, err
    }
    return mtproto.MakeTLBoolTrue(nil).To_Bool(), nil

    // ✅ 方案2: 返回明确错误
    // return nil, errors.New("auth.cancelCode: NOT_IMPLEMENTED")
```

#### 3.3 auth.bindTempAuthKey 假成功

**行号**: 274-281

**修复方案**: 同上

---

## ✅ 修复后的验收标准

1. **配置可切换**:
   - 修改 `configs/gateway.yaml` 中的 `external_ip` 即生效
   - 无需修改代码

2. **客户端正常初始化**:
   - `help.getConfig` 不再无限重试
   - 返回正确的外部 IP 地址
   - 客户端可以正常调用其他 API

3. **日志正常**:
   ```
   # 修复前
   137872 次 help.getConfig  ← 异常

   # 修复后（预期）
   2-3 次 help.getConfig
   N 次 messages.getDialogs
   N 次 contacts.getContacts
   N 次 updates.getState
   ```

4. **功能恢复**:
   - 对话列表可加载
   - 联系人列表可加载
   - 可以发送/接收消息

---

## 📊 影响范围

### 修改的文件

| 文件 | 修改类型 | 行数变化 |
|------|---------|---------|
| `cmd/gateway/main.go` | 删除硬编码配置 | -34, +3 |
| `pkg/config/load.go` | 新增配置加载器 | +50 |
| `pkg/config/validate.go` | 新增配置验证 | +30 |
| `internal/gateway/rpc_router.go` | 修复硬编码 IP + 删除 stub | -10, +15 |
| `internal/gateway/server.go` | 修复硬编码 RPC 地址 | -4, +1 |

**总计**: ~120 行代码变更

### 依赖变更

新增依赖:
```bash
go get github.com/spf13/viper
```

---

## 🔄 回滚计划

1. **Git 回滚**:
   ```bash
   git revert <commit-hash>
   ```

2. **快速回滚**:
   - 恢复 `cmd/gateway/main.go` 的硬编码配置
   - 重新编译并重启

3. **数据影响**: 无（仅配置修改，无数据库变更）

---

## 📝 上游兼容性

### Teamgram Gateway 兼容性

- **影响**: 无
- **原因**: 修改的是业务层配置加载，不涉及协议层

### 未来升级建议

1. 保留配置加载器接口不变
2. 新增配置项通过 `Validate()` 强制检查
3. 使用环境变量覆盖机制

---

## 🎯 相关问题

### 为什么之前没发现？

1. **缺乏自动化门禁**: 没有 `validate-no-hardcode.sh` 脚本
2. **缺乏 pre-commit hook**: 无法在提交时检查
3. **执行方案偏差**: 宣称完成 Week 6，但 Week 1-2 基础未通过

### 如何避免复发？

1. **创建强制门禁**:
   ```bash
   ./tools/validate-no-hardcode.sh
   ```

2. **添加 Git pre-commit hook**:
   ```bash
   #!/bin/bash
   ./tools/validate-no-hardcode.sh || exit 1
   ```

3. **CI/CD 集成**:
   - PR 合并前强制运行验证脚本

---

## 📌 相关文档

- [ECHO_AUTHORITY_CONSTRAINTS.md](../../planning/ECHO_AUTHORITY_CONSTRAINTS.md) - 第 12 节
- [AGENTS.md](../../../AGENTS.md) - 第 175-191 条
- [ECHO执行方案-精简版.md](../../../ECHO执行方案-精简版.md) - 项目宪法

---

**修复状态**: 🚧 进行中
**测试状态**: ⏳ 待验证
**文档状态**: ✅ 已完成
