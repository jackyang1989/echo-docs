# Echo 项目文档与工具

本仓库包含 Echo 项目的共享文档、开发规范和自动化工具。

## 📚 仓库结构

```
echo-docs/
├── AGENTS.md                          # 🔴 核心规范文档（品牌命名、架构规范、强制执行机制）
├── docs/                              # 项目文档目录
│   ├── architecture/                  # 架构设计文档
│   ├── branding/                      # 品牌指南
│   ├── configuration/                 # 配置文档
│   ├── planning/                      # 规划文档
│   ├── reference/                     # 参考文档
│   └── temp/                          # 临时文档
├── tools/                             # 自动化工具
│   ├── diagnostics/                   # 诊断工具
│   ├── testing/                       # 测试工具
│   ├── validate-agents-compliance.sh  # 合规性检查工具
│   └── watch-core-docs.sh             # 文档监控工具
├── *.sh                               # 项目级脚本
└── *.md                               # 项目级文档
```

## 🎯 核心文档

### 开发计划文档

**Echo 项目采用分阶段开发计划**：

| 阶段 | 权威文档 | 位置 | 说明 |
|------|---------|------|------|
| **Week 1-8** | `ECHO执行方案-精简版.md` (v5.0) | 本仓库 | Gateway、登录、消息、同步、MVP 完善 |
| **Week 9-36** | `ECHO_DEVELOPMENT_PLAN_V2.md` (v2.0) | [主仓库](https://github.com/jackyang1989/echo/blob/main/ECHO_DEVELOPMENT_PLAN_V2.md) | IM 增强、推送、后台、广场 |

**注意**：
- Week 1-8 使用本仓库的 `ECHO执行方案-精简版.md`（更详细的代码示例和验收标准）
- Week 9-36 使用主仓库的 `ECHO_DEVELOPMENT_PLAN_V2.md`（长期路线图）
- 两份文档互补，不冲突

### AGENTS.md - 必读规范文档

**所有 AI Agent 和开发者在开始工作前必须阅读 `AGENTS.md`！**

该文档包含：
- ✅ **品牌命名规则**：Echo 品牌命名规范，禁止使用旧名称（Vibe/Teamgram/Telegram）
- ✅ **架构与执行规范**：IM 内核保护、单向依赖、功能降级、版本化等硬规则
- ✅ **代码变更追踪规范**：变更记录文档化、上游兼容性分析、回滚计划
- ✅ **核心文档索引**：快速查找核心开发文档
- ✅ **强制执行机制**：自动化合规性检查工具和流程

## 🛠️ 工具和脚本

### 合规性检查工具

```bash
# 运行完整合规性检查
./tools/validate-agents-compliance.sh

# 检查品牌命名
./check-branding.sh
```

### 自动提交工具

```bash
# 安装自动提交服务（每 15 分钟自动提交）
./setup-auto-commit.sh install

# 查看服务状态
./setup-auto-commit.sh status

# 查看日志
./setup-auto-commit.sh logs
```

### 部署工具

```bash
# 部署 Echo 到 macOS 本地环境
./deploy-echo-mac.sh

# 快速部署
./quick-deploy.sh
```

## 📖 文档分类

### 架构文档
- `docs/architecture/ARCHITECTURE_DEPLOYMENT.md` - 架构与部署

**已归档的旧版架构文档**（与 v5 执行方案冲突）：
- `docs/archive/ECHO_ARCHITECTURE.md` - 旧版架构设计（已归档）
- `docs/archive/ECHO_DESIGN_PRINCIPLES.md` - 旧版设计原则（已归档）

### 品牌文档
- `docs/branding/ECHO_BRANDING_GUIDE.md` - 品牌指南
- `docs/branding/ECHO_INDEX.md` - 品牌索引

### 配置文档
- `docs/configuration/ECHO_DEPLOYMENT_CONFIG.md` - 部署配置
- `docs/configuration/ECHO_SECURITY_CONFIG.md` - 安全配置

### 规划文档
- `docs/planning/ECHO_ADMIN_PANEL.md` - 管理面板设计
- `docs/planning/ECHO_SQUARE_DESIGN.md` - 广场功能设计
- `docs/planning/ECHO_FEATURE_ROADMAP.md` - 功能范围（580/601 个 API）
- `docs/planning/ECHO_UNSUPPORTED_FEATURES.md` - 不支持的 4% 功能
- `docs/planning/ECHO_MEDIA_STORAGE_STRATEGY.md` - 媒体存储策略（v2.0.0）
- `docs/planning/ECHO_STORAGE_PERMISSION_MODEL.md` - 存储与权限模型

**已归档的旧版规划文档**：
- `docs/archive/ECHO_DEVELOPMENT_ROADMAP.md` - 旧版开发路线图（1月版本，已归档）
- `docs/archive/NEXT_STEPS.md` - 一次性操作指南（已归档）
- `docs/archive/ECHO_COMPLETE_DEVELOPMENT_PLAN.md` - 旧版开发计划（已归档）
- `docs/archive/ECHO_COMPLETE_PLANNING_SUMMARY.md` - 旧版规划总结（已归档）
- `docs/archive/ECHO_SERVER_REBUILD_PLAN.md` - 服务端重建计划（已归档）
- `docs/archive/ECHO_CLIENT_DEVELOPMENT_GUIDE.md` - 客户端开发指南（已归档）
- `docs/archive/ECHO_START_HERE.md` - 旧版入门指南（已归档）

### 参考文档
- `docs/reference/ECHO_ANDROID_CLIENT_REBRAND.md` - Android 客户端重命名
- `docs/reference/ECHO_TELEGRAM_API_REFERENCE.md` - Telegram API 参考
- `docs/reference/ECHO_TELEGRAM_FEATURES_MAPPING.md` - Telegram 功能映射

## 🔗 相关仓库

- **echo-server**: https://github.com/jackyang1989/echo-server (Echo 服务端 - 100% 自研)
- **echo-proto**: https://github.com/jackyang1989/echo-proto (Echo 协议库)
- **echo-android**: https://github.com/jackyang1989/echo-android (Echo Android 客户端 - Private)
- **echo-docs**: https://github.com/jackyang1989/echo-docs (本仓库 - 文档与工具)

## 📋 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/jackyang1989/echo-docs.git
cd echo-docs
```

### 2. 阅读核心规范

```bash
# 阅读 AGENTS.md（必读）
cat AGENTS.md

# 查看自动提交指南
cat AUTO_COMMIT_GUIDE.md
```

### 3. 运行合规性检查

```bash
# 检查品牌命名合规性
./check-branding.sh

# 运行完整合规性检查
./tools/validate-agents-compliance.sh
```

## ⚠️ 重要提醒

### 核心文档保护规则

- 🔴 **禁止删除** `docs/core/` 目录下的任何文档
- 🔴 **禁止移动** 核心文档到其他目录
- 🔴 **禁止混入** 非核心文档（临时文档、运营文档、测试报告）
- ✅ **必须版本控制** 所有核心文档

### 品牌命名规则

- ✅ **使用 "Echo"** 作为项目名称
- ❌ **禁止使用** "Vibe" / "Teamgram" / "Telegram"（旧名称）
- ✅ **遵守命名规范** 文档、脚本、代码、配置文件

### 架构铁律

- ✅ **IM 内核不可污染** - 非 IM 功能必须旁路化
- ✅ **单向依赖原则** - 业务模块不得直接写入 IM 核心
- ✅ **功能可降级** - 所有新功能必须配 Feature Flag
- ✅ **契约版本化** - 事件/接口必须版本化

## 📄 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-02-02 | 初始版本，从主项目分离文档和工具 |

---

**最后更新**: 2026-02-02  
**维护者**: Echo 项目团队  
**状态**: 生效中 ✅
