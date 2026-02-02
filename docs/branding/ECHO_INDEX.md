# Echo 项目文档索引

**最后更新**: 2026-01-30  
**版本**: 1.0

---

## 📚 快速导航

### 🔴 核心必读文档

| 文档 | 说明 | 重要性 |
|------|------|--------|
| [AGENTS.md](AGENTS.md) | 品牌命名规则和架构规范 | 🔴 必读 |
| [ECHO_FINAL_UPDATE_SUMMARY.md](ECHO_FINAL_UPDATE_SUMMARY.md) | AI Agent 强制执行机制总结 | 🔴 必读 |
| [echo-server-source/docs/core/README.md](echo-server-source/docs/core/README.md) | 服务端核心文档索引 | 🔴 必读 |
| [echo-android-client/docs/core/README.md](echo-android-client/docs/core/README.md) | Android 客户端核心文档索引 | 🔴 必读 |

### 🛠️ 强制执行工具

| 工具 | 说明 | 用途 |
|------|------|------|
| [tools/validate-agents-compliance.sh](tools/validate-agents-compliance.sh) | 合规性检查脚本 | 提交前必须运行 |
| [tools/watch-core-docs.sh](tools/watch-core-docs.sh) | 核心文档监控脚本 | 定期运行 |
| [.git/hooks/pre-commit](.git/hooks/pre-commit) | Pre-commit Hook | 自动运行 |
| [.git/hooks/commit-msg](.git/hooks/commit-msg) | Commit-msg Hook | 自动运行 |
| [.github/pull_request_template.md](.github/pull_request_template.md) | PR 模板 | 创建 PR 时使用 |
| [.github/workflows/compliance-check.yml](.github/workflows/compliance-check.yml) | CI/CD 工作流 | 自动运行 |

### 📖 开发规范

| 文档 | 说明 |
|------|------|
| [echo-server-source/docs/core/standards/coding-standards.md](echo-server-source/docs/core/standards/coding-standards.md) | Go 编码规范 |
| [echo-server-source/docs/core/standards/commit-conventions.md](echo-server-source/docs/core/standards/commit-conventions.md) | Git 提交规范 |
| [echo-server-source/docs/core/standards/review-checklist.md](echo-server-source/docs/core/standards/review-checklist.md) | PR 审查清单 |

### 🏗️ 架构文档

| 文档 | 说明 |
|------|------|
| [echo-server-source/docs/core/architecture/system-design.md](echo-server-source/docs/core/architecture/system-design.md) | 系统架构设计 |
| [echo-server-source/docs/core/architecture/module-design.md](echo-server-source/docs/core/architecture/module-design.md) | 模块设计 |
| [echo-server-source/docs/core/architecture/api-contracts.md](echo-server-source/docs/core/architecture/api-contracts.md) | API 契约 |

### 📝 变更追踪

| 文档 | 说明 |
|------|------|
| [echo-server-source/docs/core/changes/README.md](echo-server-source/docs/core/changes/README.md) | 变更记录使用指南 |
| [echo-server-source/docs/core/changes/CHANGELOG.md](echo-server-source/docs/core/changes/CHANGELOG.md) | 服务端变更总览 |
| [echo-android-client/docs/core/changes/CHANGELOG.md](echo-android-client/docs/core/changes/CHANGELOG.md) | Android 客户端变更总览 |
| [echo-server-source/docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md](echo-server-source/docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md) | 功能变更模板 |

### 🚀 部署文档

| 文档 | 说明 |
|------|------|
| [DEPLOYMENT_GUIDE_MAC.md](DEPLOYMENT_GUIDE_MAC.md) | macOS 部署指南（英文） |
| [部署说明_中文.md](部署说明_中文.md) | macOS 部署指南（中文） |
| [QUICK_START.md](QUICK_START.md) | 快速开始指南 |
| [deploy-echo-mac.sh](deploy-echo-mac.sh) | 自动化部署脚本 |
| [quick-deploy.sh](quick-deploy.sh) | 快速部署脚本 |

### 📋 项目历史

| 文档 | 说明 |
|------|------|
| [ECHO_REBRAND_SUMMARY.md](ECHO_REBRAND_SUMMARY.md) | 品牌重命名总结 |
| [ECHO_ANDROID_CLIENT_REBRAND.md](ECHO_ANDROID_CLIENT_REBRAND.md) | Android 客户端重命名记录 |
| [ECHO_ENFORCEMENT_SUMMARY.md](ECHO_ENFORCEMENT_SUMMARY.md) | 强制执行机制总结 |
| [ECHO_AI_AGENT_ENFORCEMENT.md](ECHO_AI_AGENT_ENFORCEMENT.md) | AI Agent 强制执行说明 |

---

## 🎯 快速开始

### 对于新加入的开发者

1. **阅读核心文档**
   ```bash
   cat AGENTS.md
   cat ECHO_FINAL_UPDATE_SUMMARY.md
   ```

2. **运行合规性检查**
   ```bash
   bash tools/validate-agents-compliance.sh
   ```

3. **查看开发规范**
   ```bash
   cat echo-server-source/docs/core/standards/coding-standards.md
   cat echo-server-source/docs/core/standards/commit-conventions.md
   ```

### 对于 AI Agent

1. **必须先运行合规性检查**
   ```bash
   bash tools/validate-agents-compliance.sh
   ```

2. **阅读核心规范**
   - AGENTS.md - 品牌命名和架构规范
   - 核心文档索引 - 了解文档结构
   - 变更记录指南 - 学习如何记录变更

3. **开发前准备**
   - 查阅变更总览
   - 检查是否有类似功能
   - 创建变更记录文档

---

## 🚨 重要提醒

### 项目根目录名称问题 ❌

**当前状态**: 项目根目录仍然是 `vibe`，应该是 `echo`

**必须执行**:
```bash
cd /Users/jianouyang/.gemini/antigravity/scratch
mv vibe echo
cd echo
```

### 强制执行机制

所有代码提交必须通过：
1. ✅ Pre-commit Hook 检查
2. ✅ Commit-msg Hook 检查
3. ✅ CI/CD 自动化检查
4. ✅ PR 模板强制清单
5. ✅ 代码审查

---

## 📞 获取帮助

如果遇到问题：
1. 查阅相关文档
2. 运行 `bash tools/validate-agents-compliance.sh` 检查问题
3. 查看 `ECHO_FINAL_UPDATE_SUMMARY.md` 了解完整流程
4. 联系项目维护者

---

**维护者**: Echo 项目团队  
**最后更新**: 2026-01-30
