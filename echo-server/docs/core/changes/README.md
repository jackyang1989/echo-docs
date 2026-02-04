# Echo Server 变更记录文档

本目录包含 Echo Server 的所有自定义功能、Bug 修复和性能优化的详细记录。

**重要说明**: Echo Server 是 100% 自研的服务端，只复用 Teamgram Gateway 处理 MTProto 协议。

## 📁 目录结构

```
docs/changes/
├── CHANGELOG.md                    # 变更总览（必读）
├── README.md                       # 本文件
├── features/                       # 新增功能记录
│   ├── ECHO-FEATURE-TEMPLATE.md   # 功能变更模板
│   ├── ECHO-FEATURE-001-xxx.md    # 具体功能记录
│   └── ...
├── bugfixes/                       # Bug 修复记录
│   ├── ECHO-BUG-001-xxx.md
│   └── ...
├── optimizations/                  # 性能优化记录
│   ├── ECHO-OPT-001-xxx.md
│   └── ...
└── merge-reports/                  # 上游合并报告
    ├── merge-teamgram-gateway-vX.X.X.md
    └── ...
```

## 🎯 使用指南

### 开发新功能时

1. **复制模板**
   ```bash
   cp features/ECHO-FEATURE-TEMPLATE.md features/ECHO-FEATURE-XXX-功能名.md
   ```

2. **填写变更记录**
   - 按照模板的 10 个必填项逐一填写
   - 确保信息完整、准确

3. **更新 CHANGELOG.md**
   - 在 `[Unreleased]` 章节添加变更条目
   - 关联变更 ID 和详细文档

4. **提交代码时**
   - 在 PR 描述中引用变更 ID
   - 附上变更记录文档链接

### 修复 Bug 时

1. 在 `bugfixes/` 目录创建 `ECHO-BUG-XXX-问题描述.md`
2. 记录问题原因、修复方案、测试结果
3. 更新 CHANGELOG.md

### 性能优化时

1. 在 `optimizations/` 目录创建 `ECHO-OPT-XXX-优化项.md`
2. 记录优化前后的性能对比数据
3. 更新 CHANGELOG.md

### 合并上游更新时

1. 在 `merge-reports/` 目录创建合并报告
2. 记录合并过程、冲突解决、测试结果
3. 更新所有受影响功能的变更记录
4. 更新 CHANGELOG.md 的基线版本

**注意**: Echo Server 只复用 Teamgram Gateway，业务层 100% 自研，因此上游更新主要关注 Gateway 部分。

## 📋 变更 ID 规则

### 格式
- **功能**: `ECHO-FEATURE-XXX`
- **Bug**: `ECHO-BUG-XXX`
- **优化**: `ECHO-OPT-XXX`

### 编号规则
- 从 001 开始递增
- 全局唯一，不可重复使用
- 即使功能被移除，ID 也不可重用

### 示例
```
ECHO-FEATURE-001  # 第一个功能
ECHO-FEATURE-002  # 第二个功能
ECHO-BUG-001      # 第一个 Bug 修复
ECHO-OPT-001      # 第一个性能优化
```

## ✅ 变更记录必填项

每个变更记录必须包含以下 10 个部分：

1. ✅ **变更概述** - 基本信息
2. ✅ **功能描述** - 用户故事和功能范围
3. ✅ **技术实现细节** - 修改的文件和代码
4. ✅ **数据库变更** - PostgreSQL Schema 变更
5. ✅ **API 变更** - 新增或修改的 gRPC/HTTP 接口
6. ✅ **配置变更** - Feature Flag 和配置项
7. ✅ **依赖变更** - 新增或升级的 Go 依赖
8. ✅ **测试覆盖** - 单元测试、集成测试、手动测试
9. ✅ **上游兼容性分析** - Gateway 更新冲突风险和合并策略
10. ✅ **回滚计划** - 如何快速回滚

## 🔍 查找变更记录

### 按功能名称查找
```bash
grep -r "功能名称" features/
```

### 按文件路径查找
```bash
grep -r "internal/service/auth" features/
```

### 按开发者查找
```bash
grep -r "开发者名称" features/
```

### 按日期查找
```bash
grep -r "2026-02-04" features/
```

## 📊 变更统计

查看变更统计：
```bash
# 统计功能数量
ls -1 features/ECHO-FEATURE-*.md 2>/dev/null | wc -l

# 统计 Bug 修复数量
ls -1 bugfixes/ECHO-BUG-*.md 2>/dev/null | wc -l

# 统计优化数量
ls -1 optimizations/ECHO-OPT-*.md 2>/dev/null | wc -l
```

## 🏗️ Echo Server 架构说明

### 自研部分（100%）
- **Auth 服务** - 认证和授权
- **User 服务** - 用户信息管理
- **Message 服务** - 消息和对话管理
- **Sync 服务** - 状态同步

### 复用部分
- **Gateway** - MTProto 协议处理（复用 Teamgram Gateway）

### 上游更新策略
- Gateway 更新：关注 Teamgram Gateway 的更新
- 业务层：100% 自研，不依赖上游

## 🔗 相关文档

- [AGENTS.md](../../../AGENTS.md) - 品牌命名规则和架构规范
- [系统架构设计](../architecture/system-design.md) - Echo Server 架构设计
- [模块设计文档](../architecture/module-design.md) - 模块职责和依赖
- [API 契约文档](../architecture/api-contracts.md) - 接口规范

## ⚠️ 重要提醒

**所有代码变更必须有对应的变更记录！**

缺失变更记录可能导致：
- PR 审查不通过
- Gateway 更新无法合并
- 功能丢失或冲突
- 技术债务累积

**宁可开发慢一点，也不允许缺失变更记录。**

---

## 🔗 相关核心文档

- **[核心文档索引](../README.md)** - `docs/core/README.md` - 核心文档目录说明和保护规则（🔴 必读）
- **[AGENTS.md](../../../AGENTS.md)** - 品牌命名规则、架构规范、变更追踪规范（🔴 必读）

---

**文档路径**: `echo-server/docs/core/changes/`  
**文档级别**: 🔴 核心文档（禁止删除）  
**维护者**: Echo 项目团队  
**最后更新**: 2026-02-04
