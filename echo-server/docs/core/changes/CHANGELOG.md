# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [ECHO-FEATURE-009] Post-Auth RPC 初始化桩实现 (2026-02-05) ✨ NEW
  - 实现 8 个核心初始化 RPC（如 `account.getThemes`, `messages.getDialogFilters`）
  - 解决客户端登录后 UI 卡死/转圈问题
  - 确保完全兼容多版本客户端协议（DialogFilters 双版本支持）
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

### Fixed
- [ECHO-BUG-044] 会话变更审计：echo-server 子模块指针漂移 & Gateway 登录链路相关改动汇总 (2026-02-07) 🟡 记录
  - 超级仓库 `echo-server` gitlink 从 `71b9b99a...` 漂移到 `413a5733...`（用于追溯本次会话变更）
  - 记录子模块提交范围内的关键改动点与环境事实（DB 端口/缺表风险、运行时产物混入提交等）
- [ECHO-BUG-043] Gateway 层级钳制缺失导致响应对象空编码 & rpc_error seqno 为 0 (2026-02-06) 🟡 待验收
  - `invokeWithLayer`/Pre-Auth 统一钳制到 Layer 221，避免 `GetClazzID` 返回 0 造成空编码
  - `rpc_error` 响应使用正确的 msg_id/seqno（content-related）
  - 增加 Gateway 契约测试验证 unsupported layer 会写空
- [ECHO-BUG-029] AuthKey 删除后未正确处理导致客户端卡住 (2026-02-06) ✅ 已修复
  - 修复退出登录后无法重新登录的问题
  - 当 AuthKey 被删除后，服务端正确关闭连接
  - 强制客户端重新进行 DH 握手
  - 修改文件：`internal/gateway/server_gnet.go`
- [ECHO-BUG-042] 接收方 updateNewMessage 的 peer_id 错误导致消息不可见/方向异常 (2026-02-06) 🟡 待验收
  - 修复接收方更新的 `peer_id`（应指向发送者）
  - 一次性修复历史 `update_log` 中错误的 `peer_id`
- [ECHO-BUG-041] Settings 页 Chat Folders 缺失 & 用户昵称显示为手机号 (2026-02-06) ✅ 已解决
  - 实现 `messages.getDialogFilters` (兼容两版本后缀) 激活 Chat Folders 入口
  - 增强 `User` 对象构造，填充 `Status` 字段，修复昵称显示降级问题
- [ECHO-BUG-040] auth.sendCode/resendCode 响应类型/flags 不兼容 & account.updateStatus 未实现导致登录页弹错 (2026-02-05) 🟡 待验收
  - Gateway 从 Auth 响应提取 `code_type/length/next_type/timeout`，构造带正确 flags 的 `auth.sentCode`
  - `account.updateStatus` 返回 `boolTrue`，避免客户端弹 `METHOD_NOT_IMPL`
- [ECHO-BUG-039] 消息更新二进制编码错误 & 实时推送解析不兼容 (2026-02-05) ✅ 已解决
  - Message 服务统一生成 TL 二进制更新并写入 update_log（含发送者）
  - PushHandler 兼容 TL binary 与 legacy JSON，避免实时更新丢失
  - Gateway 解码支持 updateReadHistory/updateDeleteMessages
- [ECHO-BUG-038] 预授权未恢复已登录会话 & FutureSalts 封装调用丢失 (2026-02-05) ✅ 已解决
  - Pre-Auth 阶段恢复授权不再依赖 `permAuthKeyId`
  - `invokeWithLayer/initConnection` 内部的 `get_future_salts` 在 Pre-Auth 直接处理
  - 登录页 `AUTH_KEY_UNREGISTERED` 弹窗被静默处理
- [ECHO-BUG-037] 自身用户未标记 Self 导致设置页/昵称异常 (2026-02-05) ✅ 已解决
  - `User` 对象对当前用户设置 `Self=true`
  - 设置页恢复完整入口，昵称显示一致
- [ECHO-BUG-036] 会话未绑定 user_id 导致预授权循环 & RPC 静默丢弃 (2026-02-05) ✅ 已解决
  - `BindUser` 校验 rowsAffected，缺失则返回错误
  - 预授权绑定失败时创建真实 session 记录并重试绑定
  - Pre-Auth 非白名单 RPC 明确返回 `AUTH_KEY_UNREGISTERED`
- [ECHO-BUG-035] 实时推送未加密导致无效 & P0 RPC 缺失 (2026-02-05) ✅ 已解决
  - push 发送改为合法 MTProto Updates（加密、回填 Users/State）
  - 补齐 Phase 1 P0 RPC（messages/account/contacts）
  - account.registerDevice 落库 push_tokens
- [ECHO-BUG-034] messages.getPeerDialogs 缺失 Users 导致昵称显示为手机号 (2026-02-05) ✅ 已解决
  - `messages.getPeerDialogs` 补齐 `Users/Messages/State`
  - 对话顶部昵称显示一致
- [ECHO-BUG-033] getDifference 回放缺失消息体 & 历史查询方向错误导致聊天转圈 (2026-02-05) ✅ 已解决
  - Gateway 构造完整 `updateNewMessage` 并回填 Users
  - `messages.getHistory` 改为双向查询，双方可见会话历史
  - Emoji/Archived Sticker RPC 返回合法空集合或明确错误
- [ECHO-BUG-032] Session 使用 auth_key_id 选择错误导致预授权读取失败 (2026-02-05) ✅ 已解决
  - 症状：预授权阶段出现 Session 不存在/无法读取
  - 原因：Session 表以 auth_key_id 作为主键，但逻辑使用 permAuthKeyId 写入/读取
  - 修复：统一使用当前连接的 auth_key_id 进行 Session 读写
- [ECHO-BUG-031] 客户端初始化 API 请求被 Gateway 拦截 (2026-02-05) ✅ 已解决
  - 症状：登录后/重装后 App UI 卡顿，无法加载配置
  - 原因：Pre-Auth 白名单未覆盖初始化 RPC + 未实现 RPC 采用 stub/空结果
  - 修复：补齐白名单并在 Pre-Auth/RPC Router 返回 `METHOD_NOT_IMPLEMENTED`
- [ECHO-BUG-030] auth.initPasskeyLogin RPC 未处理 (2026-02-04) ✅ 已解决
  - Layer 219+ 新增 RPC，导致 Samsung 设备无法进入验证码页面
  - 在 `rpc_router.go` 和 `server_gnet.go` 返回 `METHOD_NOT_IMPLEMENTED`
  - 客户端收到错误后回退到传统短信验证流程
- [ECHO-BUG-029] PostgreSQL 用户 ID 序列不同步 (2026-02-04) ✅ 已解决
  - 用户注册时报 `duplicate key violates unique constraint "users_pkey"`
  - 原因：`users_id_seq` 序列与已有最大 ID 不同步
  - 通过 `nextval('users_id_seq')` 修复序列值
- [ECHO-BUG-028] 登录后 Post-Auth 路由缺失 user_id (2026-02-04) ✅ 已解决
- [ECHO-BUG-026] RSA 私钥与客户端公钥不匹配 (2026-02-04) ✅ 已解决
  - 诊断发现服务器私钥与客户端编译时嵌入的公钥不匹配
  - 从 `echo-server-source/echod/bin/server_pkcs1.key` 复制正确私钥
  - DH 握手成功，但仍需解决 Pre-Auth RPC 问题
- [ECHO-BUG-024] Gateway RPC 响应发送逻辑缺失 (2026-02-04) ✅ 已解决
  - 修复 server_gnet.go 第 360-370 行 RPC 响应发送逻辑
  - 客户端连接问题已由 ECHO-BUG-025 解决
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
- [ECHO-FEATURE-009](features/ECHO-FEATURE-009-post-auth-rpc-stubs.md) - Post-Auth RPC 初始化桩实现 (2026-02-05) ✨ NEW
- [ECHO-FEATURE-008](features/ECHO-FEATURE-008-users-getfulluser.md) - Week6 用户模块 - users.getFullUser 完整信息 (2026-02-04)
- [ECHO-FEATURE-006](features/ECHO-FEATURE-006-e2e-test-report.md) - Week 5-6 E2E 测试报告 (2026-02-03) ✨ NEW
- [ECHO-FEATURE-005](features/ECHO-FEATURE-005-sync-service.md) - Sync 服务实现 (2026-02-03)
- [ECHO-FEATURE-004](features/ECHO-FEATURE-004-message-service.md) - Message 服务实现 (2026-02-03)
- [ECHO-FEATURE-003](features/ECHO-FEATURE-003-auth-service.md) - Auth 服务实现 (2026-02-02)
- [ECHO-FEATURE-002](features/ECHO-FEATURE-002-gateway-config-verification.md) - Gateway 服务配置与验证 (2026-02-02)
- [ECHO-FEATURE-001](features/ECHO-FEATURE-001-gnet-v2-api-adaptation.md) - gnet v2 API 适配 (2026-02-02)

### Bug 修复 (Bug Fixes)
- [ECHO-BUG-043](bugfixes/ECHO-BUG-043-gateway-layer-clamp-and-rpc-error-seqno.md) - Gateway 层级钳制缺失导致响应对象空编码 & rpc_error seqno 为 0 (2026-02-06)
- [ECHO-BUG-029](bugfixes/ECHO-BUG-029-authkey-deletion-not-handled.md) - AuthKey 删除后未正确处理导致客户端卡住 (2026-02-06) ✅ 已修复
- [ECHO-BUG-041](bugfixes/ECHO-BUG-041-settings-chat-folders-and-user-status.md) - Settings 页 Chat Folders 缺失 & 用户昵称显示为手机号 (2026-02-06)
- [ECHO-BUG-033](bugfixes/ECHO-BUG-033-updates-diff-and-history.md) - getDifference 回放缺失消息体 & 历史查询方向错误导致聊天转圈 (2026-02-05)
- [ECHO-BUG-025](bugfixes/ECHO-BUG-025-pre-auth-rpc-whitelist.md) - Pre-Auth RPC 白名单机制 (2026-02-04) 🔴 P0
- [ECHO-BUG-024](bugfixes/ECHO-BUG-024-gateway-rpc-response-not-sent.md) - Gateway RPC 响应发送逻辑缺失 (2026-02-04) ⏳ 部分解决

### 性能优化 (Optimizations)
- 暂无

### 上游合并 (Merge Reports)
- 暂无

---

**最后更新**: 2026-02-06  
**当前版本**: 0.1.0 (Week 1 完成)  
**下一版本**: 0.2.0 (Week 2 - 业务层实现)
