# Echo 项目文档与工具

本仓库包含 Echo 项目的共享文档、开发规范和自动化工具。

## 📚 仓库结构

```
echo-docs/
├── AGENTS.md                          # 🔴 核心规范文档
├── ECHO执行方案-精简版.md              # 🔴 项目宪法
├── QUICK_START.md                     # 快速开始
├── QUICK_REFERENCE.md                 # 快速参考
├── README.md                          # 本文件
│
├── docs/                              # 项目文档
│   ├── guides/                        # 使用指南
│   ├── reference/                     # 参考文档
│   ├── planning/                      # 规划文档
│   ├── architecture/                  # 架构文档
│   ├── archive/                       # 历史归档
│   └── temp/                          # 临时文档
│
├── echo-server/docs/core/             # 🔴 服务端核心文档
│   ├── changes/                       # 变更记录（Bug、功能、优化）
│   ├── architecture/                  # 架构设计
│   └── standards/                     # 开发规范
│
├── echo-android-client/docs/core/     # 🔴 客户端核心文档
│   ├── changes/                       # 变更记录（Bug、功能、优化）
│   ├── architecture/                  # 架构设计
│   └── standards/                     # 开发规范
│
└── tools/                             # 自动化工具
    ├── validate-agents-compliance.sh  # 合规性检查
    ├── watch-core-docs.sh             # 文档监控
    └── scripts/                       # 实用脚本
```

## 🎯 核心文档

### 必读文档

1. **AGENTS.md** - AI Agent 规则和开发规范（🔴 必读）
   - 品牌命名规则
   - 架构与执行规范
   - 代码变更追踪规范
   - 核心文档索引

2. **ECHO执行方案-精简版.md** - 项目宪法（🔴 必读）
   - Week 1-8 开发计划
   - 技术实施方案
   - 验收标准

### 核心开发文档

**服务端**：`echo-server/docs/core/`
- `changes/` - 所有代码变更记录（Bug、功能、优化）
- `architecture/` - 架构设计文档
- `standards/` - 开发规范文档

**客户端**：`echo-android-client/docs/core/`
- `changes/` - 所有代码变更记录（Bug、功能、优化）
- `architecture/` - 架构设计文档
- `standards/` - 开发规范文档

**重要**：这些核心文档是项目的核心资产，禁止删除或移动！

## 🛠️ 工具和脚本

### 合规性检查

```bash
# 运行完整合规性检查
./tools/validate-agents-compliance.sh

# 检查品牌命名
./tools/scripts/check-branding.sh
```

### 自动提交

```bash
# 安装自动提交服务
./tools/scripts/setup-auto-commit.sh install

# 查看服务状态
./tools/scripts/setup-auto-commit.sh status
```

### 部署工具

```bash
# 部署 Echo 到 macOS
./tools/scripts/deploy-echo-mac.sh

# 快速部署
./tools/scripts/quick-deploy.sh
```

## 📖 文档分类

### docs/guides/ - 使用指南
- AUTO_COMMIT_GUIDE.md - 自动提交指南
- DEPLOYMENT_GUIDE_MAC.md - macOS 部署指南
- GOPRIVATE_SETUP.md - GOPRIVATE 设置

### docs/reference/ - 参考文档
- TELEGRAM_API_COMPLETE_LIST.md - Telegram API 完整列表
- FORK_REPOS_GUIDE.md - Fork 仓库指南
- REPOSITORY_MIGRATION.md - 仓库迁移指南

### docs/planning/ - 规划文档
- ECHO_AUTHORITY_CONSTRAINTS.md - 权威约束清单（P0）
- ECHO_ADMIN_PANEL.md - 管理面板设计
- ECHO_SQUARE_DESIGN.md - 广场功能设计

### docs/archive/ - 历史归档
- 2026-02-phase1/ - Phase 1 历史文档

## 🔗 相关仓库

- **echo-server**: https://github.com/jackyang1989/echo-server
- **echo-proto**: https://github.com/jackyang1989/echo-proto
- **echo-android**: https://github.com/jackyang1989/echo-android (Private)
- **echo-docs**: https://github.com/jackyang1989/echo-docs (本仓库)

## ⚠️ 重要提醒

### 核心文档保护规则

- 🔴 **禁止删除** `docs/core/` 目录下的任何文档
- 🔴 **禁止移动** 核心文档到其他目录
- 🔴 **禁止混入** 非核心文档
- ✅ **必须版本控制** 所有核心文档

### 品牌命名规则

- ✅ 使用 "Echo"
- ❌ 禁止使用 "Vibe" / "Teamgram" / "Telegram"

### 架构铁律

- ✅ IM 内核不可污染
- ✅ 单向依赖原则
- ✅ 功能可降级
- ✅ 契约版本化

---

**最后更新**: 2026-02-04  
**维护者**: Echo 项目团队  
**状态**: 生效中 ✅
