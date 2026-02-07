# [ECHO-BUG-044] 会话变更审计：echo-server 子模块指针漂移 & Gateway 登录链路相关改动汇总

**状态**: 🟡 审计记录（非功能验收单）  
**优先级**: P0（用于止血与可追溯性）  
**日期**: 2026-02-07  
**作者**: AI Agent (Codex)

## 1) 变更概述

本记录用于回答“本次会话到底改了什么”，并把可复现的差异落到 `docs/core/changes/`，避免后续排查无法追溯。

以超级仓库 `/Users/jianouyang/Project/echo` 为准，本次会话产生的**唯一可观测工作区差异**为：

- `echo-server` gitlink（子模块指针）从 `71b9b99a9a298a04ce899e9177f14b720a2bdbf1` 漂移到 `413a5733696addb319d7058cc89d9b35bcbcfbc4`（当前未提交到超级仓库）。

子模块指针漂移覆盖了一组“自动提交”记录（commit message 均为 `chore: 自动提交 - 2026-02-07 ...`），其中包含与登录/初始化相关的代码与配置改动，以及大量运行时产物文件（日志、pid、备份等）。

## 2) 功能描述

本次会话的目标本应聚焦在登录/初始化稳定性（`help.getConfig` 风暴、`auth.sendCode` 进入率、Layer 兼容与 Passkey RPC 行为）。

但在没有明确“服务是否常驻运行、DB 端口是否一致、子模块指针是否可控”的前提下，会导致现象反复、验收口径失真。因此先补齐“变更审计记录”，为后续按宪法修复提供可追溯基础。

## 3) 技术实现细节

### 3.0 审计口径（重要）

本记录不推断“谁写了哪些提交”，只记录当前工作区能被命令复现的差异与证据。所有结论均可由本记录给出的命令复验。

### 3.1 超级仓库（/Users/jianouyang/Project/echo）差异

`echo-server` gitlink 发生变化：

- old: `71b9b99a9a298a04ce899e9177f14b720a2bdbf1`
- new: `413a5733696addb319d7058cc89d9b35bcbcfbc4`

可复现命令：

```bash
cd /Users/jianouyang/Project/echo
git diff -- echo-server
```

补充说明：

- 当前超级仓库根目录不存在 `.gitmodules` 文件，因此 `git submodule status` 会报：
  - `fatal: no submodule mapping found in .gitmodules ...`
  这会直接影响“子模块状态取证”的标准流程，后续需要补齐或明确该仓库不以 submodule 机制管理。

### 3.2 echo-server 子模块（/Users/jianouyang/Project/echo/echo-server）差异摘要

在 `71b9b99..413a573` 范围内，`git diff --stat` 显示的关键改动（节选）：

- `internal/gateway/server_gnet.go`（57 行变更）
- `configs/gateway.yaml`（DB 端口等配置 4 行变更）
- `gateway` 二进制变更
- 大量运行时产物被纳入提交：`gateway.log*`、`*.pid`、`auth.log.*`、`message.log.*`、`sync.log.*`、`user.log.*`、`backups/*`

可复现命令：

```bash
cd /Users/jianouyang/Project/echo/echo-server
git diff --stat 71b9b99..413a573
git diff --name-only 71b9b99..413a573
```

### 3.3 Passkey RPC 行为（现状）

`auth.initPasskeyLogin` 当前在 `rpc_router.go` 内返回**真实 MTProto rpc_error**（`METHOD_NOT_IMPL`），让客户端回退到短信链路（符合既有 TL 语义，不引入新构造器）。

参考（已有历史记录）：
- `ECHO-BUG-030-auth-init-passkey-login.md`

现状代码位置：
- `echo-server/internal/gateway/rpc_router.go`（`case *mtproto.TLAuthInitPasskeyLogin`）

### 3.4 本次会话执行过的关键取证/运维命令（摘要）

为追溯与复现，本次会话中使用过的高频命令类型如下（不含所有参数细节）：

- 代码/变更取证：`git status`、`git diff`、`git log`、`rg`
- 端口/进程取证：`lsof`、`ps`、`kill`
- DB 取证（只读）：`psql ... -c "SELECT ..."`
- Android 取证：`adb logcat`、`adb shell ...`

## 4) 数据库变更

本次会话未执行任何 DDL/DML 变更，仅做了读查询取证。

但**当前环境事实**（会直接影响服务是否能跑）是：

- 仅发现本机 Postgres 监听 `127.0.0.1:5432`。
- 未发现 `127.0.0.1:5433` 的监听者（与“宿主机 5433”口径不一致）。
- `echo` 数据库在 `5432` 存在，但当前 `public` schema 表数量为 `0`（意味着服务即便连上 DB，也会缺表报错或无法完成链路）。

可复现命令（只读）：

```bash
lsof -nP -iTCP:5432 -sTCP:LISTEN
lsof -nP -iTCP:5433 -sTCP:LISTEN
PGPASSWORD=echo123 psql -h 127.0.0.1 -p 5432 -U echo -d echo -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';"
```

## 5) API 变更

无新增 TL schema、无新增 constructor。该范围内的改动应仅涉及已有 TL 语义对象与 rpc_error。

## 6) 配置变更

在子模块提交范围内，`configs/gateway.yaml` 出现 DB 端口相关变更（需与实际 DB 监听端口保持一致；且必须符合“配置 SSOT / 不在 main.go 硬编码”的宪法约束）。

## 7) 依赖变更

无。

## 8) 测试覆盖

已有与 Gateway Layer 相关的契约测试/单测（详见 `ECHO-BUG-043`）用于约束：

- `clampClientLayer(0)` 不会返回 0
- 防止 `layer=0` 导致编码体为空造成客户端重试风暴

（本记录不代替功能验收；功能验收需在“服务常驻 + DB 一致 + 端口可达”的前提下执行。）

## 9) 上游兼容性分析

本记录本身不引入协议变化；如子模块提交中包含协议兼容行为（例如 Passkey RPC 返回 `METHOD_NOT_IMPL`），也属于 Telegram 既有错误码语义，客户端可按上游行为回退到 SMS 登录。

## 10) 回滚计划

若需要把超级仓库回到变更前状态（仅回滚 gitlink，不动子模块历史）：

1. 在超级仓库将 `echo-server` 指针回退到 `71b9b99a...`（按团队 Git 策略操作）
2. 重新拉起服务并按验收脚本验证

若需要清理“子模块提交中混入的运行时产物”（日志/pid/备份），应单独开变更记录进行：从 Git 层面移除、并调整启动脚本确保运行时产物不进入版本控制。
