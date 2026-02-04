# ECHO-BUG-029: PostgreSQL 用户 ID 序列不同步

## 基本信息

| 字段 | 值 |
|------|-----|
| **变更 ID** | ECHO-BUG-029 |
| **变更类型** | Bug 修复 |
| **日期** | 2026-02-04 |
| **影响模块** | Auth Service / User Repository |
| **优先级** | P0 - 阻塞登录 |
| **状态** | ✅ 已修复 |

## 问题描述

### 症状
用户在完成验证码验证后，进入昵称设置页面输入名称后，无法完成注册流程。客户端显示报错：

```
failed to create user: pq: duplicate key value 
violates unique constraint "users_pkey" (23505)
```

### 根本原因
PostgreSQL `users_id_seq` 序列的 `last_value` 与 `users` 表中已存在的最大 ID 不同步。

数据库中已有 2 个测试用户（id=1 和 id=2），但序列的 `last_value` 也是 2，导致下次插入时尝试使用 ID=2（已存在），触发主键冲突。

### 触发条件
- 使用 `INSERT ... RETURNING id`（正确方式）
- 但数据库初始化时直接插入了带 ID 的测试用户
- 导致序列值没有跟随更新

## 修复方案

### 手动修复步骤
通过 `SELECT nextval('users_id_seq')` 让序列前进到下一个可用值（3），使后续插入不再冲突。

### 长期解决方案
在数据库初始化脚本中，如果手动插入带 ID 的测试数据，必须同步更新序列：

```sql
-- 插入测试数据后，同步序列
SELECT setval('users_id_seq', (SELECT COALESCE(MAX(id), 0) FROM users));
```

## 影响范围

- **影响文件**：无代码修改，仅数据库状态修复
- **影响范围**：Auth Service - 新用户注册流程
- **客户端版本**：所有版本

## 验证结果

1. ✅ 修复后用户成功完成注册
2. ✅ OPPO 设备登录成功
3. ✅ Samsung 设备登录成功

## 预防措施

1. 在 `sql/schema.sql` 中添加序列同步语句
2. 在数据库初始化脚本中检查序列一致性
3. 添加数据库完整性检查命令

## 相关链接

- 关联变更：无
- 上游对比：N/A（Echo 自研）
