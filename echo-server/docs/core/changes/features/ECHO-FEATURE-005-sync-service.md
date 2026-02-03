# ECHO-FEATURE-005: Sync 服务实现

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-005
- **Feature Name**: Sync 服务实现（Week 5-6）
- **Status**: Completed
- **Priority**: P0 (Critical - 项目生死线)
- **Author**: AI Agent
- **Created Date**: 2026-02-03
- **Updated Date**: 2026-02-03
- **Applicable Version**: 1.0.0

## 2. 变更描述 (Description)

实现 Week 5-6 核心 Sync 服务，支持多端同步和断线补洞。包括 2 个核心 API：getState、getDifference。

**遵循项目铁律**：
- **铁律 A**: pts 必须原子分配（已在 Week 3-4 实现）
- **铁律 B**: getDifference 是"回放更新日志"，不是查消息表

## 3. 变更内容 (Changes)

### 3.1 业务逻辑层 (`internal/service/sync`)
- [x] `GetState()` - 返回用户当前 pts/qts/seq/date
- [x] `GetDifference()` - 回放 pending_updates 日志
- [x] 处理 DifferenceEmpty / DifferenceTooLong

### 3.2 服务入口 (`cmd/sync`)
- [x] HTTP 服务启动（端口 9003）
- [x] POST /sync/getState
- [x] POST /sync/getDifference
- [x] GET /health

### 3.3 Gateway 集成
- [x] `SyncServiceClient` HTTP 客户端
- [x] RPC Router 扩展（TLUpdatesGetState、TLUpdatesGetDifference）

### 3.4 数据访问层修改
- [x] `PtsRepository` 添加 `GetPts()` 方法
- [x] `model.Update` 结构体用于 getDifference 响应

## 4. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 行数 | 说明 |
|---------|---------|------|------|
| `internal/service/sync/service.go` | 新增 | ~170 | GetState, GetDifference 核心逻辑 |
| `cmd/sync/main.go` | 新增 | ~150 | HTTP 服务入口 |
| `internal/gateway/sync_client.go` | 新增 | ~130 | Gateway HTTP 客户端 |
| `internal/repository/pts_repo.go` | 修改 | +15 | 添加 GetPts 方法 |
| `internal/model/message.go` | 修改 | +8 | 添加 Update 结构体 |
| `internal/gateway/rpc_router.go` | 修改 | +75 | 添加 sync handlers |
| `internal/gateway/server.go` | 修改 | +2 | 添加 sync 服务 URL |

## 5. API 端点

| 方法 | 路径 | 功能 |
|-----|------|------|
| POST | `/sync/getState` | 获取当前状态 |
| POST | `/sync/getDifference` | 补洞（回放更新日志） |
| GET | `/health` | 健康检查 |

## 6. MTProto RPC Handlers（新增）

| Handler | 说明 |
|---------|------|
| `TLUpdatesGetState` | 返回 Updates_State |
| `TLUpdatesGetDifference` | 返回 Difference / DifferenceEmpty / DifferenceTooLong |

## 7. 构建验证

```bash
# Sync 服务构建成功
$ go build ./cmd/sync/...
# 无错误

# Gateway 构建成功
$ go build ./cmd/gateway/...
# 无错误
```

## 8. 回滚计划 (Rollback Plan)

```bash
# 停止 Sync 服务
pkill -f sync

# 删除新增文件
rm -rf internal/service/sync/
rm -rf cmd/sync/
rm -rf internal/gateway/sync_client.go

# 恢复修改的文件
git checkout internal/repository/pts_repo.go
git checkout internal/model/message.go
git checkout internal/gateway/rpc_router.go
git checkout internal/gateway/server.go
```

## 9. 相关链接 (References)

- [ECHO-FEATURE-004 Message 服务](./ECHO-FEATURE-004-message-service.md)
- [ECHO执行方案-精简版.md - 3.9 getDifference 完整实现](../../../../ECHO执行方案-精简版.md)
- [铁律 A & B - pts 和 pending_updates 设计](../../../../ECHO执行方案-精简版.md)
