# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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
- [ECHO-FEATURE-003](features/ECHO-FEATURE-003-auth-service.md) - Auth 服务实现 (2026-02-02)
- [ECHO-FEATURE-002](features/ECHO-FEATURE-002-gateway-config-verification.md) - Gateway 服务配置与验证 (2026-02-02)
- [ECHO-FEATURE-001](features/ECHO-FEATURE-001-gnet-v2-api-adaptation.md) - gnet v2 API 适配 (2026-02-02)

### Bug 修复 (Bug Fixes)
- 暂无

### 性能优化 (Optimizations)
- 暂无

### 上游合并 (Merge Reports)
- 暂无

---

**最后更新**: 2026-02-02  
**当前版本**: 0.1.0 (Week 1 完成)  
**下一版本**: 0.2.0 (Week 2 - 业务层实现)
