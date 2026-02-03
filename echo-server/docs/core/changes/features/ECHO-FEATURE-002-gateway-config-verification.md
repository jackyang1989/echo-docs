# ECHO-FEATURE-002: Gateway 服务配置与验证

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-002
- **Feature Name**: Gateway 服务配置与验证
- **Status**: Completed
- **Priority**: P0 (Critical)
- **Author**: AI Agent
- **Created Date**: 2026-02-02
- **Updated Date**: 2026-02-02
- **Applicable Version**: 1.0.0

## 2. 变更描述 (Description)

完成 Gateway 服务的完整配置和启动验证，包括 RSA 密钥生成、fingerprint 计算、数据库端口冲突解决、Logger 依赖修复等工作。确认服务能够在端口 10443 正常监听。

## 3. 变更内容 (Changes)

### 3.1 RSA 密钥配置
- [x] 生成 PKCS#1 格式 RSA 密钥（`openssl genrsa -traditional`）
- [x] 创建 fingerprint 计算工具 `tools/fingerprint/main.go`
- [x] 计算 fingerprint: `6198469329574911852`
- [x] 更新 `cmd/gateway/main.go` 配置

### 3.2 数据库配置
- [x] 解决 PostgreSQL 端口冲突（5432 → 5433）
- [x] 新增 `auth_keys` 表（MTProto 授权密钥）
- [x] 新增 `server_salts` 表（加密盐值）
- [x] 确认 14 张表全部就绪

### 3.3 依赖修复
- [x] 修复 `pkg/logger/logger.go` 对不存在的 `pkg/config` 依赖
- [x] 定义本地 `LogConfig` 类型

### 3.4 TDLib 数据模型研究
- [x] 分析 AuthManager 状态机设计
- [x] 确认 ID 类型使用 int64（BIGINT）
- [x] 验证当前 schema 与 TDLib 规范一致

## 4. 影响范围 (Impact Analysis)

- **模块**: Gateway, Database, Config, Tools
- **兼容性**: 
    - **服务端**: 数据库表结构完整，支持 Week 2 Auth 开发
    - **客户端**: 保持 API Layer 221 兼容
- **数据**: 新增 2 张数据库表（auth_keys, server_salts）

## 5. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 说明 |
|---------|---------|------|
| `configs/rsa_keys/rsa_private_key.pem` | 新增 | RSA 私钥（PKCS#1 格式） |
| `configs/rsa_keys/rsa_public_key.pem` | 新增 | RSA 公钥 |
| `tools/fingerprint/main.go` | 新增 | fingerprint 计算工具 |
| `cmd/gateway/main.go` | 修改 | 添加 fingerprint 配置 |
| `pkg/logger/logger.go` | 修改 | 定义本地 LogConfig 类型 |
| `docker-compose.yaml` | 修改 | PostgreSQL 端口 5432→5433 |

## 6. 测试计划 (Test Plan)

- [x] **编译测试**: `go build ./cmd/gateway` 成功
- [x] **启动测试**: Gateway 监听 0.0.0.0:10443
- [x] **数据库连接**: PostgreSQL 5433 端口连接正常
- [ ] **客户端连接**: 待 Echo Android Client 测试
- [ ] **MTProto 握手**: 待验证

## 7. 验收结果

| 检查项 | 状态 |
|--------|------|
| 编译成功 | ✅ |
| 数据库 14 张表 | ✅ |
| RSA 密钥加载 | ✅ |
| Fingerprint 配置 | ✅ |
| 服务启动 (10443) | ✅ |
| gnet 事件引擎 | ✅ |

## 8. 数据库 Schema 待补充

| 表 | 优先级 | 计划周期 |
|----|--------|----------|
| channels | P1 | Week 3-4 |
| secret_chats | P2 | Week 5+ |
| media 详细表 | P1 | Week 3 |

## 9. 回滚计划 (Rollback Plan)

```bash
# 停止 Gateway
pkill -f gateway

# 恢复数据库端口
# docker-compose.yaml: 5433:5432 → 5432:5432

# 删除新增文件
rm -rf configs/rsa_keys/
rm -rf tools/fingerprint/
```

## 10. 相关链接 (References)

- [AGENTS.md](../../../../AGENTS.md)
- [ECHO执行方案-精简版.md](../../../../ECHO执行方案-精简版.md)
- [ECHO-FEATURE-001](./ECHO-FEATURE-001-init-and-gateway.md)
- [TDLib AuthManager.h](https://github.com/tdlib/td/blob/master/td/telegram/AuthManager.h)
