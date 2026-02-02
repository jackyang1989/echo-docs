# AGENTS.md 改进建议和待办事项

**创建日期**: 2026-01-30  
**状态**: 待执行

---

## 🚨 紧急问题（必须立即修复）

### 1. 项目根目录名称未更新

**问题**：
- 当前目录：`/Users/jianouyang/.gemini/antigravity/scratch/vibe`
- 应该改为：`echo` 或 `echo-project`

**影响**：
- 与品牌命名规则不一致
- 可能导致路径引用混乱
- 影响项目专业性

**解决方案**：
```bash
# 方案 1: 重命名目录（推荐）
cd /Users/jianouyang/.gemini/antigravity/scratch/
mv vibe echo

# 方案 2: 如果有 Git 远程仓库，需要同步更新
cd echo
git remote -v  # 检查远程仓库
# 如果需要，更新远程仓库名称
```

**注意事项**：
- 重命名前确保没有正在运行的进程
- 更新所有硬编码的绝对路径
- 通知团队成员更新本地路径

---

### 2. AGENTS.md 中的 Emoji 显示问题

**问题**：
- 第 31 行：`## ? 核心文档索引` - emoji 显示为 `?`
- 第 40 行：`### ?📁 核心文档目录结构` - emoji 显示为 `?`

**原因**：
- 可能是编码问题或 emoji 不兼容

**解决方案**：
```markdown
# 修改前
## ? 核心文档索引（Critical Documents Index）
### ?📁 核心文档目录结构

# 修改后
## 📚 核心文档索引（Critical Documents Index）
### 📁 核心文档目录结构
```

---

## 📝 重要改进建议

### 3. 添加"快速开始"章节

**建议**：在 AGENTS.md 开头添加快速导航，方便新 AI Agent 快速上手。

**位置**：在"文档目的"之后，"核心品牌名称"之前

**内容**：
```markdown
## 🚀 快速开始（Quick Start for AI Agents）

### 新 AI Agent 必读清单

如果你是第一次处理 Echo 项目，请按以下顺序阅读：

1. ✅ **[核心品牌名称](#核心品牌名称)** - 了解 Echo 品牌规则（5 分钟）
2. ✅ **[核心文档索引](#核心文档索引)** - 了解核心文档位置（5 分钟）
3. ✅ **[架构与执行规范](#架构与执行规范)** - 了解架构铁律（10 分钟）
4. ✅ **[代码变更追踪规范](#代码变更追踪规范)** - 了解如何记录变更（10 分钟）

### 常见任务快速指南

| 任务 | 跳转章节 | 预计时间 |
|------|---------|---------|
| 开发新功能 | [代码变更文档化要求](#代码变更文档化要求) | 30 分钟 |
| 修复 Bug | [Bug 修复记录](#bugfixes) | 15 分钟 |
| 性能优化 | [优化记录](#optimizations) | 20 分钟 |
| 合并上游更新 | [上游更新合并流程](#上游更新合并流程) | 60 分钟 |
| 创建文档 | [文档命名规则](#文档文件命名) | 5 分钟 |
| 编写脚本 | [脚本命名规则](#shell-脚本命名) | 5 分钟 |

### 紧急情况处理

- 🚨 **发现旧品牌名称**：运行 `./check-branding.sh` 检查
- 🚨 **上游更新冲突**：查阅 [上游更新合并流程](#上游更新合并流程)
- 🚨 **功能需要回滚**：查阅变更记录中的回滚计划
- 🚨 **不确定是否影响 IM 核心**：查阅 [IM 内核不可污染](#im-内核不可污染)
```

---

### 4. 添加"术语表"章节

**建议**：统一项目中的专业术语，避免混淆。

**位置**：在文档末尾，"版本历史"之前

**内容**：
```markdown
## 📖 术语表（Glossary）

### 项目相关术语

| 术语 | 英文 | 说明 |
|------|------|------|
| Echo | Echo | 项目主品牌名称 |
| IM 内核 | IM Core | 即时通讯核心功能，包括消息投递、会话管理等 |
| 旁路化 | Bypass | 业务功能不直接修改 IM 核心，而是通过事件、API 等方式集成 |
| 上游 | Upstream | Telegram 官方客户端或 Teamgram 服务端的原始代码库 |
| 变更记录 | Change Log | 记录代码变更的详细文档 |
| Feature Flag | Feature Flag | 功能开关，用于控制功能的启用/禁用 |
| 降级 | Degradation | 功能关闭后的备用方案 |
| 回滚 | Rollback | 撤销代码变更，恢复到之前的状态 |

### 技术术语

| 术语 | 英文 | 说明 |
|------|------|------|
| BFF | Backend For Frontend | 后端为前端服务层 |
| gRPC | gRPC | Google 开发的高性能 RPC 框架 |
| Schema | Schema | 数据库表结构定义 |
| 迁移脚本 | Migration Script | 数据库结构变更的 SQL 脚本 |
| 契约 | Contract | API 接口的定义和约定 |
| 版本化 | Versioning | 为接口、事件添加版本号，保证兼容性 |

### 文档术语

| 术语 | 英文 | 说明 |
|------|------|------|
| 核心文档 | Core Documents | 存放在 `docs/core/` 的开发核心文档 |
| 变更 ID | Change ID | 唯一标识一个变更的 ID，如 ECHO-FEATURE-001 |
| 上游合并报告 | Upstream Merge Report | 记录合并上游更新的详细报告 |
| 硬规则 | Hard Rule | 必须严格遵守的规则，违反会导致严重后果 |
```

---

### 5. 添加"常见问题"章节

**建议**：收集常见问题和解答，减少重复询问。

**位置**：在"术语表"之后

**内容**：
```markdown
## ❓ 常见问题（FAQ）

### 品牌命名相关

**Q1: 为什么要从 Telegram 改名为 Echo？**
A: 合规性要求。Telegram 名称在中国地区可能被拦截，且我们需要独立品牌进行二次开发。

**Q2: teamgram-android 目录为什么不改名？**
A: 这是参考项目，仅供参考，不是我们要部署的项目，保持原名便于追踪上游更新。

**Q3: 发现代码中还有 Telegram 引用怎么办？**
A: 运行 `./check-branding.sh` 检查，如果在 `echo-android-client` 中发现，需要修改；如果在 `teamgram-android` 中，不需要修改。

### 架构规范相关

**Q4: 什么是"IM 内核不可污染"？**
A: IM 内核只负责消息投递、会话管理等核心功能，业务功能（如广场、推荐）必须旁路化实现，不能直接修改 IM 核心代码。

**Q5: 如何判断功能是否影响 IM 内核？**
A: 问自己：如果这个功能出错，会不会影响用户发送/接收消息？如果会，说明影响了 IM 内核。

**Q6: Feature Flag 必须配置吗？**
A: 是的，所有新功能必须配置 Feature Flag，默认关闭，确保可降级、可回滚。

### 变更记录相关

**Q7: 为什么必须记录代码变更？**
A: 为了后期能够追踪和合并 Telegram/Teamgram 上游更新，避免自定义功能丢失。

**Q8: 变更记录的 10 个必填项太多了，可以简化吗？**
A: 不可以。这 10 个项目是经过精心设计的，缺少任何一项都会影响后期维护。

**Q9: 功能被移除后，变更记录可以删除吗？**
A: 不可以。即使功能被移除，变更记录也是历史资产，必须保留。

**Q10: 如何快速创建变更记录？**
A: 复制模板文件：
```bash
cp docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md \
   docs/core/changes/features/ECHO-FEATURE-XXX-功能名.md
```

### 上游更新相关

**Q11: 多久需要合并一次上游更新？**
A: 建议每 3-6 个月检查一次上游更新，根据变更内容决定是否合并。

**Q12: 上游更新冲突怎么办？**
A: 查阅变更记录中的"上游兼容性分析"，按照合并策略处理。优先保留上游逻辑，重新集成自定义功能。

**Q13: 如何知道上游有更新？**
A: 定期访问 Telegram 和 Teamgram 的 GitHub 仓库，查看 Release 和 Changelog。

### 文档管理相关

**Q14: 核心文档可以移动到其他目录吗？**
A: 不可以。核心文档路径在 AGENTS.md 中有明确索引，移动会导致引用失效。

**Q15: 临时文档应该放在哪里？**
A: 放在 `docs/temp/` 或个人目录，不要放在 `docs/core/` 中。

**Q16: 如何备份核心文档？**
A: 核心文档已纳入 Git 版本控制，定期 push 到远程仓库即可。
```

---

### 6. 添加"工具和脚本"章节

**建议**：列出项目中的所有工具脚本，方便快速使用。

**位置**：在"常见问题"之后

**内容**：
```markdown
## 🛠️ 工具和脚本（Tools & Scripts）

### 品牌检查工具

#### check-branding.sh
检查项目中是否有遗漏的旧品牌名称。

```bash
# 使用方法
./check-branding.sh

# 输出示例
✓ 未发现 'vibe'
✓ 未发现 'Vibe'
✓ 未发现 'teamgram'
✅ 太棒了！没有发现任何旧品牌名称！
```

**检查范围**：
- Markdown 文档 (*.md)
- Shell 脚本 (*.sh)
- Go 源码 (*.go)
- Java 源码 (*.java)
- YAML 配置 (*.yaml, *.yml)
- SQL 脚本 (*.sql)

**排除目录**：
- teamgram-android/ (参考项目)
- Telegram-master.backup/ (备份)
- .git/, node_modules/, vendor/

---

### 重命名工具

#### rebrand-to-echo.sh
将所有 Vibe 品牌名称替换为 Echo。

```bash
# 使用方法
./rebrand-to-echo.sh

# 功能
- 重命名所有 VIBE_*.md 为 ECHO_*.md
- 替换所有 vibe/Vibe/VIBE 为 echo/Echo/ECHO
```

#### rebrand-teamgram-to-echo.sh
将服务端的 Teamgram 品牌名称替换为 Echo。

```bash
# 使用方法
./rebrand-teamgram-to-echo.sh

# 功能
- 重命名 teamgram-server-source 为 echo-server-source
- 替换所有 teamgram/Teamgram/TEAMGRAM 为 echo/Echo/ECHO
- 更新数据库名称、配置文件、Go 源码
```

#### rebrand-telegram-to-echo.sh
将 Android 客户端的 Telegram 品牌名称替换为 Echo。

```bash
# 使用方法
./rebrand-telegram-to-echo.sh

# 功能
- 重命名 Telegram-master 为 echo-android-client
- 替换所有 telegram/Telegram 为 echo/Echo
- 更改包名 org.telegram.* 为 com.echo.*
- 更新所有 XML、Gradle、资源文件
```

---

### 部署工具

#### deploy-echo-mac.sh
在 macOS 上部署 Echo 服务端。

```bash
# 使用方法
./deploy-echo-mac.sh

# 功能
- 检查依赖（Go, Docker, MySQL）
- 初始化数据库
- 启动 Echo 服务
```

#### configure-android-client.sh
配置 Echo Android 客户端。

```bash
# 使用方法
./configure-android-client.sh

# 功能
- 配置 API ID 和 API Hash
- 配置服务器地址
- 生成签名密钥
```

---

### 依赖安装工具

#### install-dependencies.sh
安装开发所需的依赖。

```bash
# 使用方法
./install-dependencies.sh

# 功能
- 安装 Go 1.25.6
- 安装 Java 17
- 配置环境变量
```

---

### 变更记录工具（建议开发）

#### create-change.sh（待开发）
快速创建变更记录。

```bash
# 建议用法
./tools/create-change.sh --type feature --name "Quick Reply Template"

# 输出
Created: docs/core/changes/features/ECHO-FEATURE-003-quick-reply-template.md
Updated: docs/core/changes/CHANGELOG.md
```

#### scan-custom-code.sh（待开发）
扫描自定义代码标记。

```bash
# 建议用法
./tools/scan-custom-code.sh

# 输出
Found 15 custom code blocks:
- ECHO-FEATURE-001: 5 blocks in ChatActivity.java
- ECHO-FEATURE-002: 3 blocks in MessagesController.java
```

#### check-upstream.sh（待开发）
检查上游更新。

```bash
# 建议用法
./tools/check-upstream.sh --source telegram

# 输出
Current: v10.5.2
Latest: v10.6.0
Changes: 127 commits, 45 files changed
Risk: Medium (ChatActivity.java modified)
```

---

### 工具开发建议

建议创建 `tools/` 目录，存放所有辅助工具：

```
tools/
├── create-change.sh          # 创建变更记录
├── scan-custom-code.sh       # 扫描自定义代码
├── check-upstream.sh         # 检查上游更新
├── validate-change.sh        # 验证变更记录完整性
└── generate-report.sh        # 生成变更统计报告
```
```

---

### 7. 完善"AI Agent 使用指南"

**建议**：添加更具体的 AI Agent 行为规范。

**位置**：在现有"AI Agent 使用指南"章节中补充

**内容**：
```markdown
### AI Agent 禁止行为清单

❌ **严禁**以下行为：

1. **删除核心文档**
   - 不得删除 `docs/core/` 下的任何文档
   - 不得删除任何变更记录（即使功能已移除）

2. **跳过变更记录**
   - 不得在没有变更记录的情况下修改代码
   - 不得使用"临时修改"、"快速修复"等理由跳过记录

3. **污染 IM 内核**
   - 不得在 IM 核心代码中直接添加业务逻辑
   - 不得修改消息投递、会话管理等核心流程

4. **使用旧品牌名称**
   - 不得在新代码中使用 Vibe、Teamgram、Telegram 等旧名称
   - 不得创建包含旧品牌名称的文件或目录

5. **混入非核心文档**
   - 不得在 `docs/core/` 中存放临时文档、测试报告等
   - 不得将运营文档、商业计划等放入核心文档目录

6. **忽略 Feature Flag**
   - 不得在没有 Feature Flag 的情况下上线新功能
   - 不得将 Feature Flag 默认设置为"开启"

7. **破坏性修改接口**
   - 不得在不升版本的情况下修改 API 接口
   - 不得隐式改变字段含义或结构

8. **提交不完整的 PR**
   - 不得提交缺少变更记录的 PR
   - 不得提交未通过品牌检查的 PR

### AI Agent 推荐行为

✅ **推荐**以下行为：

1. **主动检查**
   - 开发前主动运行 `./check-branding.sh`
   - 提交前主动检查变更记录完整性

2. **提前规划**
   - 开发前先创建变更记录文档
   - 设计时考虑上游兼容性

3. **保持隔离**
   - 优先使用新类、新方法实现功能
   - 使用设计模式实现功能扩展

4. **及时更新**
   - 每修改一个文件，立即更新变更记录
   - 发现问题立即记录和报告

5. **清晰沟通**
   - 在 PR 中清晰说明变更原因和影响
   - 在代码注释中标注变更 ID

6. **持续学习**
   - 定期查阅 AGENTS.md 更新
   - 学习其他变更记录的最佳实践
```

---

## 📊 文档质量改进

### 8. 添加目录（Table of Contents）

**建议**：在 AGENTS.md 开头添加完整目录，方便快速导航。

**位置**：在"文档目的"之后

**内容**：
```markdown
## 📑 目录（Table of Contents）

### 核心章节
1. [快速开始](#快速开始)
2. [核心品牌名称](#核心品牌名称)
3. [核心文档索引](#核心文档索引)
4. [命名规则详解](#命名规则详解)
5. [品牌名称对照表](#品牌名称对照表)
6. [禁止使用的名称](#禁止使用的名称)
7. [检查清单](#检查清单)

### 架构规范
8. [架构与执行规范](#架构与执行规范)
   - [架构与模块边界规范](#架构与模块边界规范)
   - [可降级与功能开关规范](#可降级与功能开关规范)
   - [契约与版本化规范](#契约与版本化规范)
   - [架构变更执行清单](#架构变更执行清单)
   - [推送与搜索治理](#推送与搜索治理)

### 变更追踪
9. [代码变更追踪与上游兼容性规范](#代码变更追踪与上游兼容性规范)
   - [代码变更文档化要求](#代码变更文档化要求)
   - [变更记录文档结构](#变更记录文档结构)
   - [AI Agent 开发规范](#ai-agent-开发规范)
   - [上游更新合并流程](#上游更新合并流程)
   - [代码审查清单](#代码审查清单)

### 附录
10. [术语表](#术语表)
11. [常见问题](#常见问题)
12. [工具和脚本](#工具和脚本)
13. [更名历史](#更名历史)
14. [版本历史](#版本历史)
```

---

### 9. 添加"文档维护"章节

**建议**：明确 AGENTS.md 本身的维护规则。

**位置**：在"版本历史"之后

**内容**：
```markdown
## 📝 文档维护（Document Maintenance）

### AGENTS.md 维护规则

#### 谁可以修改 AGENTS.md？

- ✅ 项目 Leader
- ✅ 架构师
- ✅ 经过授权的高级开发者
- ⚠️ AI Agent（仅限补充内容，不得删除现有规则）

#### 何时需要更新 AGENTS.md？

必须更新的情况：
1. 新增架构规范或硬规则
2. 修改品牌命名规则
3. 调整核心文档结构
4. 发现规则冲突或不清晰
5. 添加新的工具或脚本

建议更新的情况：
1. 补充常见问题
2. 添加最佳实践案例
3. 更新术语表
4. 完善使用指南

#### 如何更新 AGENTS.md？

1. **创建分支**
   ```bash
   git checkout -b update-agents-md
   ```

2. **修改文档**
   - 遵循现有格式和风格
   - 使用清晰的标题和章节
   - 添加示例和说明

3. **更新版本号**
   - 在"版本历史"中添加新版本
   - 说明变更内容

4. **提交 PR**
   - PR 标题：`docs: update AGENTS.md - [变更说明]`
   - PR 描述：详细说明修改原因和影响范围
   - 标签：`documentation`, `critical`

5. **团队评审**
   - 至少 2 人评审
   - 确保没有冲突或歧义
   - 合并后通知所有团队成员

#### AGENTS.md 备份策略

- ✅ 每次重大更新后，创建 Git tag
- ✅ 定期备份到团队共享目录
- ✅ 保留历史版本，不得删除

### 相关文档的维护

#### 核心文档（docs/core/）

- 由开发者和 AI Agent 共同维护
- 每次代码变更必须更新对应的变更记录
- 定期审查文档完整性

#### 项目级文档（根目录）

- 由项目 Leader 维护
- 重大变更需要团队评审
- 保持与 AGENTS.md 一致

#### 临时文档（docs/temp/）

- 由创建者自行维护
- 定期清理过期文档
- 不纳入核心文档管理
```

---

## ✅ 执行计划

### 立即执行（紧急）

1. ✅ **重命名项目根目录**
   ```bash
   cd /Users/jianouyang/.gemini/antigravity/scratch/
   mv vibe echo
   ```

2. ✅ **修复 AGENTS.md 中的 emoji 显示问题**
   - 第 31 行：`## ?` → `## 📚`
   - 第 40 行：`### ?📁` → `### 📁`

### 短期执行（本周内）

3. ✅ 添加"快速开始"章节
4. ✅ 添加"目录"章节
5. ✅ 添加"术语表"章节
6. ✅ 添加"常见问题"章节
7. ✅ 添加"工具和脚本"章节
8. ✅ 完善"AI Agent 使用指南"
9. ✅ 添加"文档维护"章节

### 中期执行（本月内）

10. ⏳ 开发变更记录工具（create-change.sh）
11. ⏳ 开发代码扫描工具（scan-custom-code.sh）
12. ⏳ 开发上游检测工具（check-upstream.sh）
13. ⏳ 创建 `tools/` 目录并整理工具脚本

### 长期执行（持续）

14. ⏳ 收集和补充常见问题
15. ⏳ 完善术语表
16. ⏳ 添加更多最佳实践案例
17. ⏳ 定期审查和更新 AGENTS.md

---

## 📊 改进效果评估

### 预期效果

1. **新 AI Agent 上手时间**：从 60 分钟缩短到 30 分钟
2. **变更记录完整率**：从 70% 提升到 95%
3. **品牌命名错误率**：从 5% 降低到 0%
4. **上游合并成功率**：从 60% 提升到 90%
5. **文档查找时间**：从 10 分钟缩短到 2 分钟

### 评估指标

- ✅ 所有 PR 都有完整的变更记录
- ✅ 品牌检查工具零报错
- ✅ 核心文档零误删
- ✅ 上游更新合并顺利
- ✅ 团队成员满意度提升

---

**创建者**: AI Assistant  
**审核者**: 待指定  
**状态**: 待执行
