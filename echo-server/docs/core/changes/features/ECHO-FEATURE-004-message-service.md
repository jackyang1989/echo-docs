# ECHO-FEATURE-004: Message 服务实现

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-004
- **Feature Name**: Message 服务实现（Week 3-4）
- **Status**: Completed
- **Priority**: P0 (Critical)
- **Author**: AI Agent
- **Created Date**: 2026-02-03
- **Updated Date**: 2026-02-03
- **Applicable Version**: 1.0.0

## 2. 变更描述 (Description)

实现 Week 3-4 核心 Message 服务，支持完整的消息收发功能。包括 5 个核心 API：sendMessage、getHistory、getDialogs、readHistory、deleteMessages。

遵循文档中的两条铁律：
- **铁律 A**: pts 必须原子分配一次、绑定消息内容一起落库
- **铁律 B**: getDifference 是"回放更新日志"，不是查消息表

## 3. 变更内容 (Changes)

### 3.1 数据模型 (`internal/model`)
- [x] `Message` 结构体（消息存储）
- [x] `Dialog` 结构体（对话信息）
- [x] `UserPts` 结构体（用户 pts 状态）
- [x] `PendingUpdate` 结构体（pending_updates 日志）
- [x] 定义 `PeerType`、`MessageType`、`UpdateType` 常量

### 3.2 数据访问层 (`internal/repository`)
- [x] `PtsRepository` - 原子 pts 分配（铁律 A）
- [x] `MessageRepository` - 消息 CRUD
- [x] `DialogRepository` - 对话 CRUD  
- [x] `PendingUpdateRepository` - 更新日志（铁律 B）

### 3.3 业务逻辑层 (`internal/service/message`)
- [x] `SendMessage()` - 发送消息 + pts 分配 + pending_updates 写入
- [x] `GetHistory()` - 获取历史消息
- [x] `GetDialogs()` - 获取对话列表
- [x] `ReadHistory()` - 标记已读 + 生成 updateReadHistory
- [x] `DeleteMessages()` - 删除消息 + 生成 updateDeleteMessages

### 3.4 服务入口 (`cmd/message`)
- [x] HTTP 服务启动（端口 9002）
- [x] 5 个 REST API 端点

### 3.5 Gateway 集成
- [x] `MessageServiceClient` HTTP 客户端
- [x] RPC Router 扩展（5 个 MTProto handlers）

## 4. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 行数 | 说明 |
|---------|---------|------|------|
| `internal/model/message.go` | 新增 | ~100 | Message/Dialog/UserPts/PendingUpdate 模型 |
| `internal/repository/pts_repo.go` | 新增 | ~120 | 原子 pts 分配（铁律 A 核心） |
| `internal/repository/message_repo.go` | 新增 | ~230 | 消息 CRUD |
| `internal/repository/dialog_repo.go` | 新增 | ~230 | 对话 CRUD |
| `internal/repository/pending_update_repo.go` | 新增 | ~100 | pending_updates 日志（铁律 B 核心） |
| `internal/service/message/service.go` | 新增 | ~280 | 消息业务逻辑 |
| `cmd/message/main.go` | 新增 | ~280 | HTTP 服务入口 |
| `internal/gateway/message_client.go` | 新增 | ~270 | Gateway HTTP 客户端 |
| `internal/gateway/rpc_router.go` | 修改 | +170 | 添加 5 个消息 handlers |
| `internal/gateway/server.go` | 修改 | +3 | 添加 message 服务 URL |

## 5. API 端点

| 方法 | 路径 | 功能 |
|-----|------|------|
| POST | `/message/send` | 发送消息 |
| POST | `/message/getHistory` | 获取历史消息 |
| POST | `/message/getDialogs` | 获取对话列表 |
| POST | `/message/readHistory` | 标记已读 |
| POST | `/message/delete` | 删除消息 |
| GET | `/health` | 健康检查 |

## 6. MTProto RPC Handlers（新增）

| Handler | 说明 |
|---------|------|
| `TLMessagesSendMessage` | 发送消息 |
| `TLMessagesGetHistory` | 获取历史 |
| `TLMessagesGetDialogs` | 获取对话列表 |
| `TLMessagesReadHistory` | 标记已读 |
| `TLMessagesDeleteMessages` | 删除消息 |

## 7. 构建验证

```bash
# Message 服务构建成功
$ go build ./cmd/message/...
# 无错误

# Gateway 构建成功  
$ go build ./cmd/gateway/...
# 无错误
```

## 8. 依赖变更

无新增依赖，复用现有：
- `github.com/lib/pq`（PostgreSQL 驱动）

## 9. 回滚计划 (Rollback Plan)

```bash
# 停止 Message 服务
pkill -f message

# 删除新增文件
rm -rf internal/model/message.go
rm -rf internal/repository/pts_repo.go
rm -rf internal/repository/message_repo.go
rm -rf internal/repository/dialog_repo.go
rm -rf internal/repository/pending_update_repo.go
rm -rf internal/service/message/
rm -rf cmd/message/
rm -rf internal/gateway/message_client.go

# 恢复 rpc_router.go 和 server.go
git checkout internal/gateway/rpc_router.go
git checkout internal/gateway/server.go
```

## 10. 相关链接 (References)

- [ECHO-FEATURE-003 Auth 服务](./ECHO-FEATURE-003-auth-service.md)
- [ECHO执行方案-精简版.md - 3.9 getDifference 完整实现](../../../../ECHO执行方案-精简版.md)
- [铁律 A & B - pts 和 pending_updates 设计](../../../../ECHO执行方案-精简版.md)
