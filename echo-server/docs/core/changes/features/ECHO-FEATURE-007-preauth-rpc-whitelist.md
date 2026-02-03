# ECHO-FEATURE-007: Pre-Auth RPC 白名单

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-007
- **Feature Name**: Pre-Auth RPC 白名单
- **Status**: 📋 Planned
- **Priority**: P0 (Critical - 阻塞登录流程)
- **Author**: AI Agent
- **Created Date**: 2026-02-04
- **Updated Date**: 2026-02-04
- **Applicable Version**: 1.0.0

## 2. 问题背景 (Problem Background)

### 2.1 问题现象

客户端在 TempAuthKey 阶段（`permAuthKeyId == 0`）发送 `invokeWithLayer(initConnection(help.getConfig))`，
被 Gateway 在 `server_gnet.go:287-289` 行拒绝，导致客户端无法完成初始化流程。

### 2.2 客户端日志

```
Gateway: recv unknown msg: {constructor:-990308245}, ignore it
```

其中 `-990308245` = `0xc4f9186b` = `help_getConfig`

### 2.3 问题分析

- MTProto 协议中，客户端创建 TempAuthKey 后需要先调用 `help.getConfig` 获取 DC 配置
- 此时 `permAuthKeyId == 0`（TempAuthKey 尚未绑定到 PermAuthKey）
- Gateway 不允许 `permAuthKeyId == 0` 时发送非 `auth.bindTempAuthKey` 的请求
- 这是**正确的安全策略**，但需要例外处理少量"pre-auth safe"的 RPC

## 3. 解决方案 (Solution)

### 3.1 核心原则（符合项目宪法）

1. **不修改 TL schema**
2. **不 fake success**
3. **返回合法 TL 对象**
4. **字段必须对 Echo 的 DC/地址真实有效**
5. **白名单必须是显式列表 + 单元测试**
6. **禁止用 contains/正则/宽泛匹配扩大攻击面**

### 3.2 设计方案

#### 3.2.1 显式白名单

```go
// Pre-auth safe RPC 白名单（显式列表）
var preAuthSafeRPCWhitelist = map[int32]bool{
    mtproto.CRC32_help_getConfig:    true,  // 必须 - 获取 DC 配置
    mtproto.CRC32_help_getNearestDc: true,  // 建议 - 获取最近 DC
    mtproto.CRC32_help_getAppConfig: true,  // 可选 - 获取应用配置
}
```

#### 3.2.2 本地 Handler

- `help.getConfig`: 从 `gateway.yaml` 读取配置，返回合法的 `help.config` TL 对象
- 配置来源为单一真相源（Single Source of Truth）
- 不依赖 DB/用户态

#### 3.2.3 非白名单 RPC 拒绝

```go
if permAuthKeyId == 0 {
    if !IsPreAuthSafeRPC(constructor) {
        logx.Errorf("recv unknown msg in pre-auth: %T, not in whitelist", msg)
        return fmt.Errorf("unknown msg")
    }
    // 处理 pre-auth safe RPC
}
```

## 4. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 说明 |
|---------|---------|------|
| `internal/gateway/preauth_whitelist.go` | 新增 | Pre-auth RPC 白名单定义 |
| `internal/gateway/preauth_whitelist_test.go` | 新增 | 白名单单元测试 |
| `internal/gateway/help_config_handler.go` | 新增 | help.getConfig 本地 handler |
| `internal/gateway/preauth_handler.go` | 新增 | Pre-auth RPC 处理逻辑 |
| `internal/gateway/server_gnet.go` | 修改 | 集成白名单检查 |
| `internal/gateway/config.go` | 修改 | 添加 ExternalIP 配置 |
| `configs/gateway.yaml` | 修改 | 添加 externalIp 配置 |

## 5. 验收标准 (Acceptance Criteria)

### 5.1 功能验收

- [ ] 握手 → getConfig → 进入登录页
- [ ] 可以点击 sendCode 按钮
- [ ] 未登录态调用 `messages.*` 仍被拒绝

### 5.2 安全验收

- [ ] 单元测试验证白名单完整性
- [ ] 非白名单 RPC 被正确拒绝
- [ ] 无宽泛匹配/正则匹配

### 5.3 代码质量

- [ ] 无临时方案/workaround
- [ ] 无注释掉的代码
- [ ] 可长期维护

## 6. 相关文档 (Related Documents)

- [ECHO_AUTHORITY_CONSTRAINTS.md](file:///Users/jianouyang/Project/echo/echo-docs/docs/planning/ECHO_AUTHORITY_CONSTRAINTS.md) - 权威约束清单
- [AGENTS.md](file:///Users/jianouyang/Project/echo/AGENTS.md) - 项目宪法
- [ECHO-BUG-016-dh-handshake-failure.md](file:///Users/jianouyang/Project/echo/echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-016-dh-handshake-failure.md) - 相关问题分析

## 7. 风险评估 (Risk Assessment)

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| 白名单过宽导致安全问题 | 🔴 高 | 显式列表 + 单元测试 |
| help.config 字段不完整 | 🟡 中 | 参考 Telegram 官方响应 |
| 配置不一致 | 🟡 中 | 单一真相源（gateway.yaml）|

## 8. 版本历史 (Version History)

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| 1.0.0 | 2026-02-04 | AI Agent | 初始版本 - 计划阶段 |
