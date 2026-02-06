# [ECHO-BUG-043] Gateway 层级钳制缺失导致响应对象空编码 & rpc_error seqno 为 0

**状态**: 🟡 已实现（待验收）  
**优先级**: P0（影响登录页稳定性与初始化状态机）  
**日期**: 2026-02-06  
**作者**: AI Agent (Codex)

## 1) 变更概述

在 Gateway 中修复两类协议封装问题：

1. `invokeWithLayer` 解析后未钳制 `clientLayer`，导致 layer > 221 时 `GetClazzID(...) == 0`，对象被空编码，客户端持续重试 `help.getConfig`。
2. `rpc_error` 响应 `Seqno=0`，违反 content-related 消息规范，可能触发客户端状态机异常与重试风暴。

## 2) 功能描述

目标：保证所有 Gateway 端的 MTProto 响应在 **Layer 221** 基线下可稳定编码，并确保错误响应的 msg_id/seqno 符合协议语义，从而避免登录/初始化阶段的无限重试与转圈。

## 3) 技术实现细节

- 新增 `clampClientLayer` 并在以下路径统一钳制到 `Layer 221`：
  - 连接建立默认层级（`newConnContext`）
  - `tryGetInvokeWithLayer` 解析后的层级
  - Pre-Auth `help.getConfig` 响应前
- `rpc_error` 响应使用与成功响应一致的 `respMsgId` 与 `respSeqno`（奇数、递增）。
- 增加契约测试：
  - `clampClientLayer` 行为验证
  - `help.getConfig` / `auth.sentCode` 在 **不支持层级** 下编码长度为 0（证明不钳制会导致空响应）

涉及文件：
- `echo-server/internal/gateway/conn.go`
- `echo-server/internal/gateway/server_gnet.go`
- `echo-server/internal/gateway/mtproto_contract_test.go`

## 4) 数据库变更

无。

## 5) API 变更

无新增或修改 TL/MTProto schema。仅修复响应封装与层级约束，不改变对外协议定义。

## 6) 配置变更

无。

## 7) 依赖变更

无。

## 8) 测试覆盖

- ✅ `go test ./internal/gateway -count=1`
- ⚠️ `go test ./...` 失败：`internal/e2e/TestGetDifference_E2E`（与本改动无关的既有失败）

## 9) 上游兼容性分析

未改动 TL schema，未引入新构造器；仅在 Gateway 内部修复编码与 seqno 语义。与上游 Gateway 兼容，不影响后续合并策略。

## 10) 回滚计划

若需回滚：

1. 回退以下文件变更：
   - `echo-server/internal/gateway/conn.go`
   - `echo-server/internal/gateway/server_gnet.go`
   - `echo-server/internal/gateway/mtproto_contract_test.go`
2. 重新编译 Gateway 并重启服务。
