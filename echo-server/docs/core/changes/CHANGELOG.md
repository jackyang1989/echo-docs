# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [ECHO-FEATURE-008] Week6 用户模块 - users.getFullUser 完整信息 (2026-02-04)
  - 补全 Gateway 的 `users.getFullUser` Rpc 路径，使 user 服务返回 `users.UserFull` + `users.Users`。
  - `gnet.UserServiceClient` 增加 `/user/getFullUser` 调用；`requireUserID`/`buildUsersUserFull` 保证 MTProto 响应结构合法。
  - `go test ./internal/gateway` 通过，确保新分支编译；待用户服务运行时可用 curl 验证完整字段。
- [ECHO-FEATURE-006] Week 5-6 E2E 集成测试报告 (2026-02-03) ✨ NEW
  - HTTP API 全链路测试通过（Auth/Message/Sync）
  - 铁律 A & B 验证成功
  - Android 客户端配置完成（待构建问题修复）
- [ECHO-FEATURE-005] Sync 服务实现（Week 5-6）(2026-02-03)
  - 2 个核心 API: getState、getDifference
  - 铁律 B 核心实现（回放 pending_updates 日志）
  - 3 个新增文件 + 4 个修改文件
- [ECHO-FEATURE-004] Message 服务实现（Week 3-4）(2026-02-03)
  - 5 个核心 API: sendMessage、getHistory、getDialogs、readHistory、deleteMessages
  - 遵循铁律 A (原子 pts 分配) 和铁律 B (pending_updates 更新日志)
  - 8 个新增文件 + 2 个修改文件
- [ECHO-FEATURE-003] Auth 服务实现 (2026-02-02)
  - 5 个 API: sendCode、signIn、signUp、logOut、resendCode
- [ECHO-FEATURE-002] Gateway 服务配置与验证 (2026-02-02)
  - RSA 密钥生成（PKCS#1 格式）
  - Fingerprint 计算工具 `tools/fingerprint/main.go`
  - 数据库表 `auth_keys` 和 `server_salts`
- [ECHO-FEATURE-001] gnet v2 API 适配 - 连接管理机制 (2026-02-02)
- 初始化 Echo Server 项目骨架
- 启动 PostgreSQL/Redis/MinIO 基础设施
- 创建核心数据库 Schema（含 updates/pts 表）
- 从 teamgram-server 提取最小 Gateway 代码
- 简化配置，移除 etcd/kafka 依赖
- 项目重命名为 `echo-app`

### Changed
- [ECHO-FEATURE-001] 替换 `ConnId()` 为 `RemoteAddr().String()` (2026-02-02)
- [ECHO-FEATURE-001] 实现连接引用保存和管理 (2026-02-02)
- [ECHO-FEATURE-001] 修复 `asyncRun` 函数（不依赖 Trigger） (2026-02-02)
- 修改 Gateway 监听端口为 10443
- 修改 MinIO 端口为 9010/9011 避免冲突

### Planned
- [ECHO-FEATURE-007] Pre-Auth RPC 白名单机制 (2026-02-04) 🔴 P0 📋 计划中
  - 修复客户端在 TempAuthKey 阶段无法发送 help.getConfig 的问题
  - 实现显式 Pre-Auth RPC 白名单（help.getConfig、help.getNearestDc、help.getAppConfig）
  - 实现本地 help.getConfig 处理器（配置来自 gateway.yaml，不依赖数据库）
  - 白名单采用显式列表 + 单元测试，禁止宽泛匹配
  - 预计新增 4 个文件 + 修改 3 个文件

### Fixed
- [ECHO-BUG-028] 登录后 Post-Auth 路由缺失 user_id (2026-02-04) ✅ 已解决
- [ECHO-BUG-026] RSA 私钥与客户端公钥不匹配 (2026-02-04) ✅ 已解决
  - 诊断发现服务器私钥与客户端编译时嵌入的公钥不匹配
  - 从 `echo-server-source/echod/bin/server_pkcs1.key` 复制正确私钥
  - DH 握手成功，但仍需解决 Pre-Auth RPC 问题
- [ECHO-BUG-024] Gateway RPC 响应发送逻辑缺失 (2026-02-04) ⏳ 部分解决
  - 修复 server_gnet.go 第 360-370 行 RPC 响应发送逻辑
  - 客户端连接问题仍未解决（已被 ECHO-BUG-025 解决）
- [ECHO-FEATURE-001] 修复 gnet v2 API 兼容性问题 (2026-02-02)
- [ECHO-FEATURE-001] 修复编译错误 - 未使用的导入 (2026-02-02)

### Security
- 初始化 RSA 密钥处理逻辑（提取自 teamgram）

---

## [0.1.0] - 2026-02-02

### Week 1 完成

#### 核心功能
- ✅ MTProto 握手流程实现
- ✅ AuthKey 持久化到 PostgreSQL
- ✅ Session 状态管理
- ✅ 连接生命周期管理
- ✅ gnet v2 API 完全适配

#### 依赖独立性
- ✅ Fork `teamgram/proto` 到 `jackyang1989/echo-proto`
- ✅ 修改 module 名称和 import 路径
- ✅ 移除 teamgram-server 依赖
- ✅ 完全独立的依赖关系

#### 品牌独立性
- ✅ 完全替换 Teamgram 为 Echo
- ✅ 统一版权声明: `Copyright (c) 2026-present, Echo Technologies`
- ✅ 更新所有文档和脚本

#### 编译状态
- ✅ 编译成功！生成 68MB 的二进制文件
- ✅ 无编译错误
- ✅ 无未使用的导入

---

## 变更记录索引

### 功能变更 (Features)
- [ECHO-FEATURE-008](features/ECHO-FEATURE-008-users-getfulluser.md) - Week6 用户模块 - users.getFullUser 完整信息 (2026-02-04)
- [ECHO-FEATURE-006](features/ECHO-FEATURE-006-e2e-test-report.md) - Week 5-6 E2E 测试报告 (2026-02-03) ✨ NEW
- [ECHO-FEATURE-005](features/ECHO-FEATURE-005-sync-service.md) - Sync 服务实现 (2026-02-03)
- [ECHO-FEATURE-004](features/ECHO-FEATURE-004-message-service.md) - Message 服务实现 (2026-02-03)
- [ECHO-FEATURE-003](features/ECHO-FEATURE-003-auth-service.md) - Auth 服务实现 (2026-02-02)
- [ECHO-FEATURE-002](features/ECHO-FEATURE-002-gateway-config-verification.md) - Gateway 服务配置与验证 (2026-02-02)
- [ECHO-FEATURE-001](features/ECHO-FEATURE-001-gnet-v2-api-adaptation.md) - gnet v2 API 适配 (2026-02-02)

### Bug 修复 (Bug Fixes)
- [ECHO-BUG-025](bugfixes/ECHO-BUG-025-pre-auth-rpc-whitelist.md) - Pre-Auth RPC 白名单机制 (2026-02-04) 🔴 P0
- [ECHO-BUG-024](bugfixes/ECHO-BUG-024-gateway-rpc-response-not-sent.md) - Gateway RPC 响应发送逻辑缺失 (2026-02-04) ⏳ 部分解决

### 性能优化 (Optimizations)
- 暂无

### 上游合并 (Merge Reports)
- 暂无

---

**最后更新**: 2026-02-02  
**当前版本**: 0.1.0 (Week 1 完成)  
**下一版本**: 0.2.0 (Week 2 - 业务层实现)
