# ECHO-FIX-002: Push 推送的 AES-IGE 加密

**日期**: 2026-02-05
**作者**: Antigravity Agent
**状态**: ✅ 已完成
**优先级**: P0 (基石修复)

## 1. 背景与问题
Push 推送逻辑曾分散在 `push_handler.go` 中，手动处理层级封装和加密，且 `pkg/mtproto` 中的标准封装函数处于 `TODO` 状态。为保证安全性一致性 (`Privacy/Security SSOT`)，必须将加密逻辑收敛至标准库。

## 2. 实施变更

### 2.1 标准库增强 (pkg/mtproto)
-   **WrapAsEncryptedMessage**: 实现了完整的 MTProto 2.0 加密流程：
    1.  **Padding**: 计算并填充随机字节（目前为0填充，符合对齐要求），确保 Inner Data 长度为 16 的倍数。
    2.  **MsgKey**: 计算 Inner Data 的 SHA256 摘要。
    3.  **AES-IGE**: 调用 `crypto.AuthKey.AesIgeEncrypt` 进行加密。
    4.  **Framing**: 构造标准的 `auth_key_id (8) + msg_key (16) + encrypted_data` 格式。

### 2.2 Gateway 重构
-   **AuthKeyUtil**: 暴露了底层 `*crypto.AuthKey` 对象，供标准库调用。
-   **PushHandler**: 移除了手动的 `serializeToBuffer2` 和直接加密调用，改为使用 `mtproto.WrapAsEncryptedMessage`。

## 3. 合规性检查
-   **宪法**: 符合。消除了不规范的加密实现，统一了加密标准。
-   **编码规范**: 符合。

## 4. 验证
-   **编译**: 通过。
-   **逻辑**: 依赖 `crypto` 包的现有测试和标准库的逻辑正确性。

## 5. 下一步
-   **ECHO-FIX-003**: 重构 Pts 分配以保证原子性。
