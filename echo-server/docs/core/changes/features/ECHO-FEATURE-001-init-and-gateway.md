# ECHO-FEATURE-001: Echo Server 初始化与 Gateway 提取

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-001
- **Feature Name**: Echo Server 初始化与 Gateway 提取
- **Status**: In Progress
- **Priority**: P0 (Critical)
- **Author**: AI Agent
- **Created Date**: 2026-02-01
- **Updated Date**: 2026-02-01
- **Applicable Version**: 1.0.0

## 2. 变更描述 (Description)

本变更完成了 Echo Server 的初始化搭建工作，并从 Teamgram Server 中提取了最小版本的 Gateway。主要目标是建立独立的基础设施和网关服务，摆脱对 etcd 和 kafka 的重依赖，同时将项目名称从 `echo-im` 更名为 `echo-app` 以符合产品定位。

## 3. 变更内容 (Changes)

### 3.1 基础设施搭建
- [x] 启动 PostgreSQL (Port: 5432)
- [x] 启动 Redis (Port: 6379)
- [x] 启动 MinIO (Port: 9010/9011)
- [x] 创建数据库 Schema（12 张核心表，包括 updates/pts 体系）

### 3.2 项目更名与配置
- [x] 修改 Module Name: `github.com/echo-im/echo-server` -> `github.com/echo-app/echo-server`
- [x] 创建简化版配置文件 `config.yaml`
- [x] 更新 `go.mod` 依赖，移除 unnecessary dependencies

### 3.3 Gateway 提取
- [x] 克隆 `teamgram-server` 代码库
- [x] 提取 `gnetway` 模块核心代码（22 个 .go 文件）
- [x] 创建 Gateway 提取计划 `docs/gateway-extraction-plan.md`
- [x] 创建简化版 Gateway 入口 `cmd/gateway/main.go`
- [x] 创建简化版配置结构 `pkg/config/config.go`

## 4. 影响范围 (Impact Analysis)

- **模块**: Gateway, Infrastructure, Config
- **兼容性**: 
    - **服务端**: 不兼容 Teamgram 原版配置（已去 etcd/kafka）
    - **客户端**: 保持 API Layer 221 兼容
- **数据**: 新增 12 张数据库表，无数据迁移风险

## 5. 测试计划 (Test Plan)

- [ ] **基础设施测试**: `scripts/start.sh` 检查各容器健康状态
- [ ] **编译测试**: `go build ./cmd/gateway` 确保依赖正常
- [ ] **连接测试**: 使用 Echo Android Client 连接本地 10443 端口
- [ ] **握手测试**: 验证 MTProto 握手流程日志

## 6. 回滚计划 (Rollback Plan)

由于是新项目初始化，回滚即为清空项目目录：
```bash
rm -rf echo-server/
docker compose down -v
```

## 7. 相关链接 (References)

- [AGENTS.md](../../../../AGENTS.md)
- [ECHO执行方案-精简版.md](../../../../ECHO执行方案-精简版.md)
- [Gateway Extraction Plan](../../../gateway-extraction-plan.md)
