# Echo 项目文档目录

本目录包含 Echo 项目的所有非核心文档。

## 📁 目录结构

### temp/ - 临时文档
会议记录、临时笔记、草稿等临时性质的文档。

**子目录**：
- `temp/summaries/` - 临时总结文档（开发过程中的完成报告、总结）
- `temp/backups/` - 备份文件（重要文档的备份）

### reference/ - 参考文档
技术分析、功能映射、参考指南等参考性质的文档。

**包含**：
- Telegram API 参考
- TDLib 使用指南
- 仓库迁移指南
- Fork 仓库指南

### architecture/ - 架构文档
系统架构设计、设计原则等架构相关文档。

### planning/ - 规划文档
开发路线图、功能设计、管理后台设计等规划文档。

**包含**：
- Echo 功能路线图
- 不支持的功能列表
- 清理计划
- 下一步计划

### configuration/ - 配置文档
部署配置、安全配置等配置相关文档。

**包含**：
- macOS 部署指南
- 自动提交配置
- GOPRIVATE 设置

### branding/ - 品牌文档
品牌指南、品牌索引等品牌相关文档。

### enforcement/ - 强制执行文档
AI Agent 强制执行机制、规则执行总结等文档。

## ⚠️ 重要说明

本目录下的文档**不是核心开发文档**。

核心开发文档存放在：
- `echo-server/docs/core/` - 服务端核心文档（100% 自研）
- `echo-android-client/docs/core/` - Android 客户端核心文档

核心文档包括：
- 代码变更记录（changes/）
- 架构设计文档（architecture/）
- 开发规范文档（standards/）

详见 [AGENTS.md](../AGENTS.md) 中的核心文档索引章节。

---

## 📋 最近更新

### 2026-02-03 - 根目录文档整理

将根目录的 34 个临时文档、总结文档整理到 `docs/` 目录的合适位置：

- ✅ 20 个临时总结文档 → `docs/temp/summaries/`
- ✅ 1 个备份文件 → `docs/temp/backups/`
- ✅ 6 个规划文档 → `docs/planning/`
- ✅ 3 个配置文档 → `docs/configuration/`
- ✅ 4 个参考文档 → `docs/reference/`

详见：[ROOT_DOCS_ORGANIZATION_COMPLETE.md](temp/summaries/ROOT_DOCS_ORGANIZATION_COMPLETE.md)
