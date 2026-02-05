# ECHO-FIX-004: 补全 getDifference 逻辑

**日期**: 2026-02-05
**作者**: Antigravity Agent
**状态**: ✅ 已完成
**优先级**: P0 (基石修复)
**关联宪法**: 铁律 B (getDifference 必须回放真实更新)

## 1. 背景与问题
此前 `updates.getDifference` 仅返回 Pts 数字变化或空壳 Update，未返回真实的 Update 内容（如 `updateNewMessage` 及其包含的消息文本）。这导致客户端虽然能检测到 Pts 变化，但无法拉取到离线期间的消息内容，违反了 Echo 宪法关于“状态一致性”的要求。

## 2. 实施变更

### 2.1 Storage Layer (SSOT)
-   **Model**: 在 `internal/model/message.go` 中新增 `UpdateLog` 结构，包含 `UpdateBlob []byte`。
-   **UpdateLogRepository**: 实现 `GetUpdateLogsInRange` 方法，支持按 Pts 范围查询并返回包含二进制 Blob 的完整日志。

### 2.2 Sync Service (Logic)
-   **GetDifference**:
    -   移除旧的 Raw SQL 查询。
    -   调用 `updateLogRepo.GetUpdateLogsInRange` 获取真实 Blob。
    -   不再依赖 `PendingUpdate` 的中间状态（仅作为无 Log 时的 fallback）。
    -   将 TL Binary Blob 传递给 Gateway。

### 2.3 Gateway Layer (Protocol)
-   **RPC Router**:
    -   在 `buildDifferenceUpdates` 中新增对 `mtproto_binary` 类型的处理。
    -   使用 `mtproto.Decode` 解码二进制 Blob，还原为 `*mtproto.Update` 对象。
    -   **实体提取**: 解析解码后的 Update 对象（如 `UpdateNewMessage`），提取其中的 `FromId` 和 `PeerId`，自动填充 `Users` 和 `Chats` 列表，确保客户端能正确渲染消息发送者信息。

## 3. 合规性检查
-   **宪法**: 符合。实现了“唯一真相源”原则，getDifference 现在忠实回放 `update_log`。
-   **编码规范**: 符合。

## 4. 验证
-   **编译**: `cmd/sync` 和 `cmd/gateway` 均编译通过。
-   **逻辑**: 代码审查确认 Update Blob 被正确读取、传输和解码。

## 5. 下一步
-   至此，Week 1-5 的核心协议与同步基石修复 (Fix 001-004) 已全部完成。
-   可以开始进行端到端的连通性测试 (Android Client -> Gateway -> Sync -> DB)。
