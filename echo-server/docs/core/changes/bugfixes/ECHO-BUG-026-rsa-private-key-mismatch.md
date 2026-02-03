# ECHO-BUG-026: RSA 私钥不匹配导致握手失败

## 1. 变更详情 (Change Details)

- **Bug ID**: ECHO-BUG-026
- **Bug Name**: RSA 私钥与客户端公钥不匹配
- **Status**: ✅ 已解决
- **Priority**: P0 (Critical - 阻塞所有客户端连接)
- **Author**: AI Agent
- **Created Date**: 2026-02-04
- **Updated Date**: 2026-02-04
- **Session**: 会话 ID 301e08ca-ed8a-4e30-9b95-1d81cfc4764c

## 2. 问题描述 (Problem Description)

### 2.1 问题现象

客户端无法完成 MTProto 握手，DH 参数验证失败，客户端不断重试连接。

### 2.2 日志证据

```
Gateway: AuthKey saved successfully - type: 1 (TempAuthKey)
Gateway: recv unknown msg: {constructor:-990308245}, ignore it  
```

### 2.3 根本原因

服务器使用的 RSA 私钥与客户端编译时嵌入的公钥**不匹配**。

- **客户端期望的公钥指纹**: `0xa9e071c1771060cd`
- **服务器使用的私钥**: 与上述公钥不对应

## 3. 解决方案 (Solution)

### 3.1 诊断过程

1. 检查 `echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-018-rsa-public-key-missing.md`
2. 发现客户端公钥指纹 `0xa9e071c1771060cd`
3. 在 `echo-server-source/echod/bin/server_pkcs1.key` 找到对应私钥
4. 验证私钥与公钥匹配：
   ```bash
   openssl rsa -in server_pkcs1.key -pubout -RSAPublicKey_out
   # 输出与客户端公钥完全一致
   ```

### 3.2 修复操作

```bash
cp /Users/jianouyang/Project/echo/echo-server-source/echod/bin/server_pkcs1.key \
   /Users/jianouyang/Project/echo/echo-server/configs/rsa_keys/rsa_private_key.pem
```

## 4. 文件变更 (File Changes)

| 文件路径 | 变更类型 | 说明 |
|---------|---------|------|
| `configs/rsa_keys/rsa_private_key.pem` | 替换 | 使用与客户端公钥匹配的私钥 |

## 5. 验证结果 (Verification)

修复后 Gateway 日志显示握手成功：

```
Gateway: AuthKey saved successfully - auth_key_id: xxx, type: 1, expires_in: 86400
Gateway: dh_gen_ok
```

## 6. 遗留问题 (Remaining Issues)

虽然 DH 握手成功，但客户端仍无法进入登录页，因为：

- 客户端发送 `help.getConfig` 被 Gateway 拒绝（`permAuthKeyId == 0`）
- 需要实现 Pre-Auth RPC 白名单（见 ECHO-FEATURE-007）

## 7. 相关文档 (Related Documents)

- [ECHO-BUG-016-dh-handshake-failure.md](../../../echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-016-dh-handshake-failure.md)
- [ECHO-BUG-018-rsa-public-key-missing.md](../../../echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-018-rsa-public-key-missing.md)
- [ECHO-FEATURE-007-preauth-rpc-whitelist.md](./features/ECHO-FEATURE-007-preauth-rpc-whitelist.md) - 后续修复

## 8. 经验教训 (Lessons Learned)

1. **RSA 密钥必须配对**: 服务器私钥必须与客户端编译时嵌入的公钥完全匹配
2. **参考历史文档**: `echo-android-client/docs/core/changes/bugfixes/` 中有相关问题的解决记录
3. **单一真相源**: 密钥应从 `echo-server-source/echod/bin/` 获取，这是 Teamgram 官方使用的密钥
