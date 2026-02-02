
## 🛡️ 强制执行机制与工具（Enforcement Mechanisms）

### 重要说明

Echo 项目采用**自动化强制执行机制**，确保所有 AI Agent 和开发者遵守 AGENTS.md 中定义的规则。

**核心理念**：不依赖 AI 记忆，而是通过自动化工具使不合规行为无法通过。

---

### 📚 强制执行文档索引

| 文档类型 | 路径 | 说明 | 重要性 |
|---------|------|------|--------|
| **强制执行机制文档** | `ECHO_AI_AGENT_ENFORCEMENT.md` | 详细的强制执行机制和哲学 | 🔴 必读 |
| **强制执行实施总结** | `ECHO_ENFORCEMENT_SUMMARY.md` | 实施总结和快速参考 | 🔴 必读 |
| **合规性检查工具** | `tools/validate-agents-compliance.sh` | 自动化合规性检查脚本 | 🔴 必用 |
| **品牌命名检查工具** | `check-branding.sh` | 品牌命名合规性检查 | 🔴 必用 |

---

### 🔧 工具和脚本

#### 1. 合规性检查工具

**路径**: `tools/validate-agents-compliance.sh`

**功能**:
- 检查品牌命名合规性（vibe/teamgram/telegram 等旧名称）
- 检查核心文档完整性（docs/core/ 目录）
- 检查变更记录完整性（CHANGELOG.md、变更模板）
- 检查文档索引一致性（AGENTS.md 索引与实际文件）
- 检查文档状态标记（"待完善" vs "✅ 已完善"）
- 检查 Git 提交消息规范

**使用方法**:
```bash
# 运行完整检查
./tools/validate-agents-compliance.sh

# 检查特定类别
./tools/validate-agents-compliance.sh --category branding
./tools/validate-agents-compliance.sh --category core-docs
```

**返回值**:
- `0` - 所有检查通过
- `1` - 发现不合规问题（阻止 CI/CD 流程）

