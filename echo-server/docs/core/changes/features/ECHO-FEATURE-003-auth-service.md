# ECHO-FEATURE-003: Auth 服务实现

## 1. 变更详情 (Change Details)

- **Feature ID**: ECHO-FEATURE-003
- **Feature Name**: Auth 服务实现
- **Status**: Completed
- **Priority**: P0 (Critical)
- **Author**: AI Agent
- **Created Date**: 2026-02-02
- **Updated Date**: 2026-02-02
- **Applicable Version**: 1.0.0

## 2. 变更描述 (Description)

实现 Week 2 核心 Auth 服务，支持基本的登录/注册流程。包括 5 个 P0 级别 API：sendCode、signIn、signUp、logOut、resendCode。

## 3. 变更内容 (Changes)

### 3.1 数据模型 (`internal/model`)
- [x] 创建 `AuthCode` 结构体（验证码存储）
- [x] 创建 `User` 结构体（用户信息）
- [x] 创建 `Session` 结构体（会话信息）
- [x] 定义 `AuthState` 常量（参考 TDLib）

### 3.2 数据访问层 (`internal/repository`)
- [x] `AuthCodeRepository` 接口 + PostgreSQL/Memory 双实现
- [x] `UserRepository` 接口 + PostgreSQL/Memory 双实现

### 3.3 业务逻辑层 (`internal/service/auth`)
- [x] `SendCode()` - 生成验证码 + 存储
- [x] `SignIn()` - 验证码校验 + 返回用户
- [x] `SignUp()` - 创建用户 + 返回授权
- [x] `LogOut()` - 清理会话
- [x] `ResendCode()` - 重新生成验证码

### 3.4 服务入口 (`cmd/auth`)
- [x] HTTP 服务启动（端口 9001）
- [x] 支持内存模式（-memory 参数）
- [x] 支持 PostgreSQL 模式

### 3.5 Gateway 集成 (Gateway Integration)
- [x] **RPC 路由模块 (`internal/gateway/rpc_router.go`)**: 实现根据 TL schema 定义的请求路由分发。
- [x] **Server 集成 (`internal/gateway/server.go`)**: 在 Server 结构体中通过 `NewRpcRouter` 初始化路由器。
- [x] **消息拦截 (`internal/gateway/server_gnet.go`)**: 在 `onEncryptedMessage` 中识别 Service Message，并通过 `rpcRouter.Route()` 转发给 Auth 服务。
- [x] **请求流转**: `Client` -> `Gateway (:10443)` -> `RpcRouter` -> `AuthService (:9001)`。

## 4. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 说明 |
|---------|---------|------|
| `internal/model/auth.go` | 新增 | 数据模型定义 |
| `internal/repository/auth_code_repo.go` | 新增 | 验证码 CRUD |
| `internal/repository/user_repo.go` | 新增 | 用户 CRUD |
| `internal/service/auth/service.go` | 新增 | 业务逻辑实现 |
| `cmd/auth/main.go` | 新增 | HTTP 服务入口 |
| `internal/gateway/rpc_router.go` | 新增 | Gateway RPC 路由 |
| `internal/gateway/server.go` | 修改 | 添加 rpcRouter 字段 |
| `internal/gateway/server_gnet.go` | 修改 | 集成 RPC 路由调用 |

## 5. API 测试结果

| API | 请求 | 响应 | 状态 |
|-----|------|------|------|
| `POST /auth/sendCode` | `{"phone_number": "+86..."}` | `{"phone_code_hash": "..."}` | ✅ |
| `POST /auth/signIn` | 错误验证码 | `{"error": "PHONE_CODE_INVALID"}` | ✅ |
| `POST /auth/signIn` | 正确验证码（新用户） | `{"_": "auth.authorizationSignUpRequired"}` | ✅ |
| `POST /auth/signUp` | 注册信息 | `{"user": {"id": 1, ...}}` | ✅ |

## 6. 验证命令

```bash
# 启动服务（内存模式）
./bin/auth -memory

# 测试 sendCode
curl -X POST http://localhost:9001/auth/sendCode \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+8613800138000"}'

# 测试 signUp
curl -X POST http://localhost:9001/auth/signUp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+8613800138000", "first_name": "Test"}'
```

## 7. 依赖变更

- 新增：`github.com/lib/pq v1.11.1`（PostgreSQL 驱动）

## 8. 回滚计划 (Rollback Plan)

```bash
# 停止 Auth 服务
pkill -f auth

# 删除新增文件
rm -rf internal/model/auth.go
rm -rf internal/repository/auth_code_repo.go
rm -rf internal/repository/user_repo.go
rm -rf internal/service/auth/
rm -rf cmd/auth/main.go
rm -rf bin/auth
```

## 9. 相关链接 (References)

- [ECHO-FEATURE-002](./ECHO-FEATURE-002-gateway-config-verification.md)
- [Auth 实现计划](../../../../.gemini/antigravity/brain/301e08ca-ed8a-4e30-9b95-1d81cfc4764c/implementation_plan.md)
- [TDLib AuthManager.h](https://github.com/tdlib/td/blob/master/td/telegram/AuthManager.h)
