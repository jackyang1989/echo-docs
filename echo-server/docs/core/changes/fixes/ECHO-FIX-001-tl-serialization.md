# ECHO-FIX-001: UpdateLog 的 TL 序列化修复

**日期**: 2026-02-05
**作者**: Antigravity Agent
**状态**: ✅ 已完成
**优先级**: P0 (基石修复)

## 1. 背景与问题
此前，`update_log` 表将更新存储为 `JSON` blobs（例如 `{"type": "updateNewMessage", ...}`）。这违反了 **项目宪法** (`AGENTS.md` 第 6 节) 和 **权威约束** (`SSOT`)：
- **协议不匹配**: MTProto 要求严格的 TL 二进制序列化。
- **数据损坏风险**: JSON 存储容易出现 Schema 漂移和类型丢失（例如 `int64` vs `float64`）。
- **虚假实现**: `getDifference` 必须从 Map 重构 TL 对象，这既容易出错又低效。

## 2. 实施变更

### 2.1 存储层
- **Schema**: 确认 `update_log.update_blob` 为 `BYTEA` 类型。
- **序列化**: 从 `json.Marshal` 切换为 `mtproto.Encode()`。
- **反序列化**: 从 `json.Unmarshal` 切换为 `mtproto.Decode()`。

### 2.2 服务层
- **Message Service (`internal/service/message/service.go`)**:
  - `SendMessage`: 现在构造 `mtproto.TLUpdateNewMessage` (包装 `TLMessage`) 并在 DB 插入前编码为二进制。
  - 使用了特定的结构体字段 (`Message_MESSAGE`, `Pts_INT32`) 以满足 `mtproto` 生成代码的要求。

- **Sync Service (`internal/service/sync/service.go`)**:
  - `deserializeUpdateBlob`: 现在返回填充了 `Blob` 字段的 `model.Update`，并将类型设置为 `Type="mtproto_binary"`。

- **Gateway (`internal/gateway/rpc_router.go`)**:
  - `buildDifferenceUpdates`: 添加了检查 `u.Blob` 的逻辑。
  - 使用 `mtproto.NewDecodeBuf` 解码二进制 blob。
  - 类型断言为 `*mtproto.TLUpdateNewMessage` 以提取用户 hydration 所需的 `Message` (使用 `t.Data2.Message_MESSAGE` 路径)。

## 3. 合规性检查
- **宪法 (AGENTS.md)**: 合规。移除了"虚假"的 JSON 实现。强制执行了严格的协议一致性。
- **权威约束**: 合规。没有发明新的 TL 类型。使用了标准的 `mtproto.Update` 定义。
- **编码规范**: 合规。使用了标准的错误处理和日志记录。

## 4. 验证
- **编译**: 通过 (`go build ./cmd/gateway/main.go`)。
- **逻辑**: 验证了 `SendMessage` 写入二进制数据，且 `getDifference` 能正确解码。

## 5. 下一步
- 实现 Push 的 **AES-IGE 加密** (ECHO-FIX-002)。
- 重构 Pts 分配以保证原子性 (ECHO-FIX-003)。
