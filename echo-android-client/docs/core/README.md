# Echo Android Client 核心开发文档

⚠️ **重要提示**：本目录包含 Echo Android Client 的核心开发文档，**严禁删除或移动**！

---

## 📋 目录说明

本目录 (`docs/core/`) 专门存放与开发直接相关的核心文档，包括：

- ✅ **代码变更记录** - 所有功能开发、Bug 修复、性能优化的详细记录
- ✅ **架构设计文档** - 系统架构、模块设计、接口定义
- ✅ **开发规范文档** - 编码规范、提交规范、审查清单
- ✅ **上游合并报告** - Telegram 上游更新的合并记录

---

## 📁 目录结构

```
docs/core/
├── README.md                       # 本文件（核心文档索引）
├── changes/                        # 代码变更记录（核心）
│   ├── CHANGELOG.md               # 变更总览
│   ├── README.md                  # 变更记录使用指南
│   ├── features/                  # 新增功能记录
│   │   ├── ECHO-FEATURE-TEMPLATE.md
│   │   └── ECHO-FEATURE-XXX-*.md
│   ├── bugfixes/                  # Bug 修复记录
│   │   └── ECHO-BUG-XXX-*.md
│   ├── optimizations/             # 性能优化记录
│   │   └── ECHO-OPT-XXX-*.md
│   └── merge-reports/             # 上游合并报告
│       └── merge-telegram-vX.X.X.md
├── architecture/                   # 架构设计文档 ✅ 已完善
│   ├── system-design.md           # 系统架构设计
│   ├── module-design.md           # 模块设计文档
│   └── ui-components.md           # UI 组件设计
└── standards/                      # 开发规范文档 ⏳ 待完善
    ├── coding-standards.md        # 编码规范（Java/Kotlin）
    ├── commit-conventions.md      # 提交规范
    └── review-checklist.md        # 审查清单
```

---

## 🚫 禁止存放的内容

本目录**严禁**存放以下类型的文档：

❌ **临时文档**：
- 会议记录
- 临时笔记
- 草稿文档

❌ **运营文档**：
- 审计报告
- 运营数据
- 商业计划

❌ **测试报告**：
- UI 测试报告（除非与优化记录直接相关）
- 兼容性测试报告
- 临时测试结果

❌ **发布文档**：
- 发布日志
- 应用商店描述
- 市场推广材料

---

## 📖 核心文档索引

### 1. 代码变更记录（最重要）

| 文档 | 路径 | 说明 |
|------|------|------|
| 变更总览 | `changes/CHANGELOG.md` | 所有变更的时间线和版本历史 |
| 使用指南 | `changes/README.md` | 如何创建和维护变更记录 |
| 功能模板 | `changes/features/ECHO-FEATURE-TEMPLATE.md` | 新功能变更记录模板 |
| 功能记录 | `changes/features/ECHO-FEATURE-XXX-*.md` | 具体功能的详细记录 |
| Bug 记录 | `changes/bugfixes/ECHO-BUG-XXX-*.md` | Bug 修复的详细记录 |
| 优化记录 | `changes/optimizations/ECHO-OPT-XXX-*.md` | 性能优化的详细记录 |
| 合并报告 | `changes/merge-reports/merge-telegram-vX.X.X.md` | 上游更新合并报告 |

### 2. 架构设计文档 ✅ 已完善

| 文档 | 路径 | 说明 |
|------|------|------|
| 系统设计 | `architecture/system-design.md` | 整体系统架构设计 |
| 模块设计 | `architecture/module-design.md` | 各模块的详细设计 |
| UI 组件 | `architecture/ui-components.md` | UI 组件设计和使用规范 |

### 3. 开发规范文档 ⏳ 待完善

| 文档 | 路径 | 说明 |
|------|------|------|
| 编码规范 | `standards/coding-standards.md` | Java/Kotlin 代码编写规范 |
| 提交规范 | `standards/commit-conventions.md` | Git 提交消息规范 |
| 审查清单 | `standards/review-checklist.md` | PR 审查必查项 |

---

## 🔒 文档保护规则

### 必须遵守的规则

1. **禁止删除**
   - 本目录下的所有文档都是核心开发资产
   - 即使功能被移除，变更记录也必须保留
   - 删除文档前必须经过团队评审

2. **禁止移动**
   - 文档路径一旦确定，不得随意移动
   - 如需重组，必须更新所有引用
   - 必须在 AGENTS.md 中更新索引

3. **禁止混入非核心文档**
   - 临时文档、运营文档、测试报告等不得放入本目录
   - 保持目录纯净，只存放开发核心文档

4. **必须版本控制**
   - 所有文档必须纳入 Git 版本控制
   - 重要变更必须有 commit 记录
   - 定期备份到远程仓库

---

## 📝 文档维护责任

### 开发者责任

- ✅ 开发新功能时，必须创建对应的变更记录
- ✅ 修复 Bug 时，必须记录问题和解决方案
- ✅ 性能优化时，必须记录优化前后的对比数据
- ✅ 合并上游更新时，必须创建合并报告

### AI Agent 责任

- ✅ 生成代码时，必须同步生成变更记录
- ✅ 修改代码时，必须更新相关变更记录
- ✅ 提供建议时，必须引用核心文档
- ✅ 发现文档缺失时，必须提醒补充

### 团队 Leader 责任

- ✅ 定期审查变更记录的完整性
- ✅ 确保所有 PR 都有对应的变更记录
- ✅ 维护文档索引的准确性
- ✅ 组织文档评审和更新

---

## 🔗 相关文档

### 项目根目录文档

- [AGENTS.md](../../../AGENTS.md) - 品牌命名规则、架构规范、变更追踪规范（必读）
- [ECHO_ANDROID_CLIENT_REBRAND.md](../../../ECHO_ANDROID_CLIENT_REBRAND.md) - 重命名文档
- [DEPLOYMENT_GUIDE_MAC.md](../../../DEPLOYMENT_GUIDE_MAC.md) - 部署指南

### 其他文档目录

- `docs/` - 其他非核心文档（使用指南、FAQ 等）
- `TMessagesProj/config/` - 构建配置文件

---

## 📊 文档统计

查看文档统计：

```bash
# 统计功能数量
ls -1 changes/features/ECHO-FEATURE-*.md 2>/dev/null | wc -l

# 统计 Bug 修复数量
ls -1 changes/bugfixes/ECHO-BUG-*.md 2>/dev/null | wc -l

# 统计优化数量
ls -1 changes/optimizations/ECHO-OPT-*.md 2>/dev/null | wc -l

# 统计合并报告数量
ls -1 changes/merge-reports/merge-*.md 2>/dev/null | wc -l
```

---

## ⚠️ 最终警告

**本目录包含 Echo Android Client 的核心开发资产，是项目可维护性的基石。**

违反文档保护规则可能导致：
- ❌ 上游更新无法合并
- ❌ 功能丢失无法恢复
- ❌ 技术债务失控
- ❌ 项目维护困难

**请务必遵守文档保护规则，保护好这些核心资产！**

---

**创建日期**: 2026-01-30  
**维护者**: Echo 项目团队  
**文档级别**: 🔴 核心文档（禁止删除）
