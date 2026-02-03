# Echo 文档状态登记表

**最后更新**: 2026-02-03  
**版本**: 1.0.0  
**状态**: ✅ 生效中

---

## 📋 文档说明

本文档明确标注所有 Echo 项目文档的状态，解决"应该以哪个文档为准"的问题。

---

## ✅ 权威文档清单（当前生效）

### 🔴 项目宪法级（必读）

| 文档 | 路径 | 版本 | 职责范围 |
|------|------|------|---------|
| **AGENTS.md** | `./AGENTS.md` | v1.6.0 | AI Agent 规则、品牌命名、架构铁律 |
| **ECHO执行方案-精简版.md** | `./ECHO执行方案-精简版.md` | v5.0 | 项目宪法、Week 1-8 计划、P0 接口清单、生死线（updates/pts/getDifference） |

### 🟠 开发计划（分阶段权威）

| 文档 | 路径 | 版本 | 职责范围 |
|------|------|------|---------|
| **ECHO执行方案-精简版.md** | `./ECHO执行方案-精简版.md` | v5.0 | **Week 1-8 详细计划**（更详细的代码示例和验收标准） |
| **ECHO_DEVELOPMENT_PLAN_V2.md** | `/echo/ECHO_DEVELOPMENT_PLAN_V2.md` | v2.0 | **Week 9-36 计划**（IM 增强、推送、后台、广场） |

### 🟡 功能规划（生效中）

| 文档 | 路径 | 状态 | 说明 |
|------|------|------|------|
| **ECHO_FEATURE_ROADMAP.md** | `./docs/planning/ECHO_FEATURE_ROADMAP.md` | ✅ | 功能范围（580/601 个 API） |
| **ECHO_UNSUPPORTED_FEATURES.md** | `./docs/planning/ECHO_UNSUPPORTED_FEATURES.md` | ✅ | 不支持的 4% 功能 |
| **ECHO_MEDIA_STORAGE_STRATEGY.md** | `./docs/planning/ECHO_MEDIA_STORAGE_STRATEGY.md` | ✅ | 媒体存储策略（v2.0.0，权威 Schema） |
| **ECHO_STORAGE_PERMISSION_MODEL.md** | `./docs/planning/ECHO_STORAGE_PERMISSION_MODEL.md` | ✅ | 存储与权限模型（引用 MEDIA_STORAGE） |
| **ECHO_SQUARE_DESIGN.md** | `./docs/planning/ECHO_SQUARE_DESIGN.md` | ✅ | 广场功能设计（P2，Week 29+） |
| **ECHO_ADMIN_PANEL.md** | `./docs/planning/ECHO_ADMIN_PANEL.md` | ✅ | 管理后台设计（P2，Week 21+） |

---

## ⚠️ 冲突文档清单（需要更新或归档）

### 与 v5 执行方案冲突

| 文档 | 路径 | 问题 | 处理建议 |
|------|------|------|---------|
| **ECHO_DESIGN_PRINCIPLES.md** | `./docs/architecture/ECHO_DESIGN_PRINCIPLES.md` | 强调"Echo Server 保持原样不修改/业务都在 NestJS"，与 v5"业务层 100% 自研"冲突 | 🗃️ 归档或更新 |
| **ECHO_ARCHITECTURE.md** | `./docs/architecture/ECHO_ARCHITECTURE.md` | 仍把"Echo Business Server (NestJS)"放在核心图里，容易造成"核心能力旁路化"误解 | 🗃️ 归档或更新 |
| **ECHO_DEVELOPMENT_ROADMAP.md** | `./docs/planning/ECHO_DEVELOPMENT_ROADMAP.md` | 1月旧版 roadmap，与当前计划不一致 | 🗃️ 归档 |
| **NEXT_STEPS.md** | `./docs/planning/NEXT_STEPS.md` | 一次性本机 Docker/I/O 测试的操作指南，不是 roadmap | 🗃️ 归档 |

### 品牌/基线不一致

| 文档 | 路径 | 问题 | 处理建议 |
|------|------|------|---------|
| **QUICK_START.md** | `./QUICK_START.md` | 仍有 org.telegram.* 路径、以 MySQL 为主的部署描述，与 PostgreSQL 基线不一致 | ⚠️ 需要更新 |

---

## 📦 已归档文档清单

| 文档 | 路径 | 归档日期 | 说明 |
|------|------|---------|------|
| ECHO_COMPLETE_DEVELOPMENT_PLAN.md | `./docs/archive/` | 2026-02-03 | 旧版开发计划 |
| ECHO_COMPLETE_PLANNING_SUMMARY.md | `./docs/archive/` | 2026-02-03 | 旧版规划总结 |
| ECHO_SERVER_REBUILD_PLAN.md | `./docs/archive/` | 2026-02-03 | 服务端重建计划 |
| ECHO_CLIENT_DEVELOPMENT_GUIDE.md | `./docs/archive/` | 2026-02-03 | 客户端开发指南 |
| ECHO_START_HERE.md | `./docs/archive/` | 2026-02-03 | 旧版入门指南 |

---

## 🔄 文档更新计划

| 优先级 | 文档 | 行动 | 状态 |
|--------|------|------|------|
| P0 | ECHO_DESIGN_PRINCIPLES.md | 归档或与 v5 对齐 | ⏳ 待处理 |
| P0 | ECHO_ARCHITECTURE.md | 归档或与 v5 对齐 | ⏳ 待处理 |
| P1 | ECHO_DEVELOPMENT_ROADMAP.md | 归档 | ⏳ 待处理 |
| P1 | NEXT_STEPS.md | 归档 | ⏳ 待处理 |
| P2 | QUICK_START.md | 更新为 PostgreSQL 基线 | ⏳ 待处理 |

---

## 📖 正确的阅读路径（最快建立正确上下文）

1. **DOCUMENTATION_INDEX.md** → 权威索引，确认哪些文档是"生效中"
2. **AGENTS.md + ECHO执行方案-精简版.md** → 项目铁律 + Week 1-8 计划 + P0 接口清单
3. **ECHO_FEATURE_ROADMAP.md + ECHO_UNSUPPORTED_FEATURES.md** → 功能范围（580/601）与明确不做的 4%
4. **echo-server/docs/core/architecture/system-design.md + CHANGELOG.md** → 服务端当前架构与已落地变更记录
5. **ECHO_ADMIN_PANEL.md + ECHO_SQUARE_DESIGN.md** → 旁路业务（后看）

---

## 📋 开发计划执行顺序

| 周次 | 权威文档 | 任务 |
|------|---------|------|
| Week 1-8 | `ECHO执行方案-精简版.md` (v5.0) | Gateway、登录、消息、同步、MVP 完善 |
| Week 9-16 | `ECHO_DEVELOPMENT_PLAN_V2.md` (v2.0) | IM 增强功能（媒体、群聊、频道、加密） |
| Week 17-20 | `ECHO_DEVELOPMENT_PLAN_V2.md` (v2.0) | 推送通知系统 |
| Week 21-28 | `ECHO_DEVELOPMENT_PLAN_V2.md` (v2.0) | 后台管理系统 |
| Week 29-36 | `ECHO_DEVELOPMENT_PLAN_V2.md` (v2.0) | 广场功能 |

---

## 📝 当前进度

| 阶段 | 状态 |
|------|------|
| Week 1: Gateway 抽取和验证 | ✅ 已完成 |
| Week 2: 登录模块实现 | ✅ 已完成 |
| **Week 3-4: 消息模块实现** | 🚧 **下一步** |
| Week 5-6: 同步模块实现 | ⏳ 待开始 |
| Week 7-8: IM 核心稳定性测试 | ⏳ 待开始 |

---

**最后更新**: 2026-02-03  
**维护者**: Echo 项目团队  
**状态**: ✅ 生效中
