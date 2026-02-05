# ECHO-FIX-003: 原子化 Pts 分配

**日期**: 2026-02-05
**作者**: Antigravity Agent
**状态**: ✅ 已完成
**优先级**: P0 (基石修复)

## 1. 背景与问题
此前，`AllocatePts` (PTS 递增) 和 `CreateUpdate` (写入更新日志) 是分离的数据库操作。如果前者成功后系统崩溃或后者失败，会导致 PTS 空洞和状态不一致（幽灵消息）。为满足"宪法"对状态一致性 (Consistency) 的严格要求，必须确保二者原子化。

## 2. 实施变更

### 2.1 Repository 层事务支持
-   **TxManager**: 引入 `TxManager` 接口及 `PostgresTxManager` 实现，支持将 `sql.Tx` 注入 `context.Context`。
-   **DBExecutor**: 引入 `GetExecutor(ctx, db)` 辅助函数，所有 Repository 方法现在优先从 Context 获取事务执行器，否则回退到 DB 连接。
-   **受影响 Repositories**:
    -   `PtsRepository`: `AllocatePts`, `InitUserPts` 等。
    -   `PendingUpdateRepository`: `Create`, `DeleteOldUpdates` 等。
    -   `DialogRepository`: `UpdateReadInbox`, `UpdateDialog` 等。
    -   `MessageRepository`: `Create`, `DeleteMessages`。
    -   `UpdateLogRepository` (New): 新建此 Repo 替代 `pgxpool` 直接操作，统一使用 `*sql.DB` 事务体系。

### 2.2 Service 层重构 (MessageService)
-   **SendMessage**:
    -   移除 `db *pgxpool.Pool`，改为注入 `TxManager` 和 `UpdateLogRepository`。
    -   使用 `txManager.RunInTx` 包裹以下全流程：
        1.  `ptsRepo.AllocatePts` (原子递增)
        2.  `pendingUpdateRepo.Create` (写入旧兼容表)
        3.  `updateLogRepo.Create` (写入 SSOT 表)
    -   只有事务提交成功后，才触发异步 Gateway 推送。
-   **ReadHistory** & **DeleteMessages**:
    -   同样应用了事务包裹，确保状态变更 (如 unread_count 更新) 与 PTS 分配和日志记录的原子性。

### 2.3 启动入口 (cmd/message)
-   初始化 `TxManager` 和 `UpdateLogRepository`。
-   移除 `pgxpool` 连接池，消除分布式事务隐患。

## 3. 合规性检查
-   **宪法**: 符合。实现了强一致性的状态变更。
-   **编码规范**: 符合。

## 4. 验证
-   **编译**: 通过。
-   **逻辑**: 代码审查确认所有关键写操作均在 `RunInTx` 闭包内，且 Repositories 正确使用了 `GetExecutor`。

## 5. 下一步
-   **ECHO-FIX-004**: 补全 `getDifference` 逻辑。
