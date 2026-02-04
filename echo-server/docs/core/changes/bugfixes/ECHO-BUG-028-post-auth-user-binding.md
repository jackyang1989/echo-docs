# ECHO-BUG-028: 登录后 Post-Auth 路由缺失 user_id

## 变更 ID
**ECHO-BUG-028**

## 基本信息
- **功能名称**: 登录后 Post-Auth user_id 绑定修复
- **变更类型**: Bug 修复
- **优先级**: 🔴 P0
- **开发者**: Droid
- **开发日期**: 2026-02-04
- **上游版本基线**: Echo Gateway v0.1.0
- **状态**: ✅ 已完成

---

## 问题描述

**现象**：客户端登录成功后进入 Post-Auth 阶段，但 `messages.getDialogs` / `updates.getState` 等 RPC 返回空错误，页面功能无法渲染。

**影响范围**：登录后的所有依赖 user_id 的 RPC（dialogs/history/updates 等），导致首页与联系人页空白。

---

## 根本原因

1. 登录成功后虽然写入了 `sessions.user_id`，但新连接或后续请求的 `ctx.userID` 没有从数据库恢复。
2. `SessionStore.GetSession` 未返回 `user_id` 字段，导致恢复失败。
3. 登录成功后未显式切换 `PreAuthPhaseAuthorized`，后续阶段判定不稳定。

---

## 修复方案

### 修复点 1：登录成功后切换至 Authorized 阶段
在 `bindAuthorizedSession` 中同步设置：
- `ctx.userID = userID`
- `ctx.preAuthPhase = PreAuthPhaseAuthorized`
 - 立即执行 `SessionStore.BindUser`（去除异步提交，避免首次 Post-Auth 读不到 user_id）

### 修复点 2：Session 查询返回 user_id
`SessionStore.GetSession` 查询新增 `user_id` 字段，并回填到 `SessionInfo`。

### 修复点 3：Post-Auth 收包时恢复 user_id
在每次 Post-Auth 消息处理前，如果 `ctx.userID == 0`，从 `sessions` 表恢复 `user_id` 并回填到 `ctx`。

---

## 修改的文件

| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `internal/gateway/server_gnet.go` | 修改 | 登录成功后切换为 `PreAuthPhaseAuthorized`；Post-Auth 请求中自动恢复 `user_id` |
| `internal/gateway/session_store.go` | 修改 | `GetSession` 查询新增 `user_id` 并写入 `SessionInfo` |

---

## 验证结果

- `go test ./...` 通过
- Gateway 日志：登录后不再出现 Pre-Auth 拒绝，Post-Auth RPC 正常进入路由

---

## 运行环境问题记录

- **PostgreSQL 端口不一致（5433 vs 5432）**：已由操作者修正并重启服务，未涉及代码改动。

---

## 回滚计划

1. 回退 `server_gnet.go` 中 `bindAuthorizedSession` 对 `PreAuthPhaseAuthorized` 和 `user_id` 恢复逻辑。
2. 回退 `session_store.go` 的 `user_id` 查询字段。
3. 重启 Gateway 进程。
