# 变更记录模板

> 本文件为变更记录模板，复制此文件并重命名为实际的变更 ID

---

## 变更 ID: ECHO-FEATURE-XXX

### 1. 变更概述（Change Summary）

- **功能名称**: [功能名称]
- **变更类型**: 新增功能 / 修改功能 / Bug 修复 / 性能优化
- **优先级**: 高 / 中 / 低
- **开发者**: [开发者名称或 AI Agent ID]
- **开发日期**: YYYY-MM-DD
- **上游版本基线**: Telegram vX.X.X

---

### 2. 功能描述（Feature Description）

#### 用户故事
作为 [用户角色]，我希望 [功能描述]，以便 [使用目的]

#### 功能范围
- 功能点 1
- 功能点 2
- 功能点 3

#### UI/UX 变更
[描述界面变更]

---

### 3. 技术实现细节（Technical Implementation）

#### Android 客户端 (echo-android-client)

##### 新增文件
- `路径/文件名.java` - 文件说明
- `路径/文件名.xml` - 文件说明

##### 修改文件
- `路径/文件名.java`
  - **行号**: 1234-1256
  - **变更内容**: [具体变更]
  - **变更原因**: [为什么要改]

---

### 4. 数据库变更（Database Changes）

#### 新增表
```sql
CREATE TABLE table_name (
  -- Schema definition
);
```

#### 修改表
- **表名**: `table_name`
- **变更**: [具体变更]
- **迁移脚本**: `路径/migrate-YYYYMMDD-xxx.sql`

---

### 5. API 变更（API Changes）

#### 新增 API 端点
- **端点**: `POST /api/v1/xxx`
- **请求体**: 
  ```json
  {
    "field": "value"
  }
  ```
- **响应**: 
  ```json
  {
    "result": "success"
  }
  ```

---

### 6. 配置变更（Configuration Changes）

#### Feature Flag 配置
- **Key**: `FEATURE_XXX_ENABLED`
- **默认值**: `false`
- **控制维度**: 全局、用户白名单、客户端版本
- **配置文件**: `路径/配置文件.yaml`

#### 环境变量
- **新增**: `ECHO_XXX_CONFIG=value`
- **说明**: [变量说明]

---

### 7. 依赖变更（Dependency Changes）

#### 新增依赖
- **Android**: 
  - `implementation 'group:artifact:version'` (用途说明)

#### 依赖版本升级
- 无 / [具体升级]

---

### 8. 测试覆盖（Test Coverage）

#### 单元测试
- `TestClassName.java` - 测试说明

#### 集成测试
- [测试场景描述]

#### 手动测试清单
- [ ] 测试项 1
- [ ] 测试项 2
- [ ] Feature Flag 关闭后功能不可见

---

### 9. 上游兼容性分析（Upstream Compatibility）

#### 冲突风险评估
- **风险等级**: 低 / 中 / 高
- **潜在冲突点**:
  - [文件名] 的 [具体位置] 可能与上游更新冲突

#### 合并策略
- **隔离方案**: 
  - [如何隔离实现]
  
- **回滚方案**:
  - [如何快速回滚]

#### 上游更新适配指南
当 Telegram 官方更新时：
1. 检查 [关键文件] 是否变更
2. 如有冲突，[处理方案]
3. 验证 [关键功能] 兼容性
4. 运行完整测试套件

---

### 10. 回滚计划（Rollback Plan）

#### 回滚步骤
1. 设置 Feature Flag `FEATURE_XXX_ENABLED=false`
2. 执行数据库回滚脚本（如有）
3. 重新部署不包含此功能的版本
4. 验证 IM 核心功能正常

#### 数据保留策略
- [数据如何处理]

---

## 代码注释标记示例

```java
// ECHO-FEATURE-XXX: [功能名称] - START
// Added by: [开发者]
// Date: YYYY-MM-DD
// Description: [简要说明]

// 代码实现

// ECHO-FEATURE-XXX: [功能名称] - END
```

---

## 上游更新适配历史

### 适配 Telegram vX.X.X (YYYY-MM-DD)
- **冲突文件**: [文件列表]
- **解决方案**: [如何解决]
- **测试结果**: 通过 / 失败

---

**创建日期**: YYYY-MM-DD  
**最后更新**: YYYY-MM-DD  
**维护者**: [开发者名称]
