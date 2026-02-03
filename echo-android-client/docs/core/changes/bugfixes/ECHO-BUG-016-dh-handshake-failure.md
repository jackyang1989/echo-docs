# ECHO-BUG-016: DH 握手失败导致无法连接到 Echo 服务器

## 变更 ID
**ECHO-BUG-016**

## 基本信息

| 项目 | 内容 |
|------|------|
| **Bug 名称** | DH 握手失败导致无法连接到 Echo 服务器 |
| **变更类型** | Bug 调查 |
| **优先级** | 高 (High) |
| **影响范围** | Android 客户端与 Echo 服务器连接 |
| **开发者** | AI Agent |
| **开发日期** | 2026-02-01 |
| **上游版本基线** | Telegram v10.5.2 / Teamgram v1.2.3 |
| **状态** | 🔍 调查中 |

---

## 1. 问题描述

### 1.1 问题现象

Android 客户端能够连接到 Echo 服务器（192.168.0.17:10443），RSA 公钥验证通过，但在 Diffie-Hellman (DH) 密钥交换阶段失败，导致无法完成握手，无法获取验证码。

**用户体验**：
- 输入手机号后一直转圈
- 无法进入验证码输入界面
- 无任何错误提示

### 1.2 客户端日志

```
02-01 02:06:44.178 18011 18079 D tgnet   : connection(0xb400006ea6c2ed00, account0, dc2, type 1) received message len 72 equal to packet size
02-01 02:06:44.178 18011 18079 E tgnet   : process handshake
02-01 02:06:44.178 18011 18079 D tgnet   : account0 dc2 handshake: retry DH, type = 0
02-01 02:06:44.178 18011 18079 D tgnet   : account0 dc2 handshake: begin, type = 0
02-01 02:06:44.183 18011 18079 D tgnet   : connection(0xb400006ea6c2ed00, account0, dc2, type 1) received message len 84 equal to packet size
02-01 02:06:44.183 18011 18079 E tgnet   : process handshake
02-01 02:06:44.245 18011 18079 D tgnet   : connection(0xb400006ea6c2ed00, account0, dc2, type 1) received message len 652 equal to packet size
02-01 02:06:44.245 18011 18079 E tgnet   : process handshake
02-01 02:06:44.286 18011 18079 D tgnet   : connection(0xb400006ea6c2ed00, account0, dc2, type 1) received message len 72 equal to packet size
02-01 02:06:44.286 18011 18079 E tgnet   : process handshake
02-01 02:06:44.286 18011 18079 D tgnet   : account0 dc2 handshake: retry DH, type = 0
```

**关键错误**：`retry DH` - 客户端不断重试 DH 密钥交换

### 1.3 问题分析

**握手流程**：
1. ✅ TCP 连接建立成功（客户端能连接到 192.168.0.17:10443）
2. ✅ RSA 公钥验证通过（不再报 "can't find valid server public key"）
3. ❌ DH 密钥交换失败（服务器返回的 DH 参数未通过客户端验证）

**可能的原因**：
1. **服务器 DH 参数生成问题**：
   - DH 素数 (p) 不符合安全要求
   - DH 生成元 (g) 不正确
   - 服务器随机数 (b) 生成有问题

2. **客户端 DH 验证过于严格**：
   - Telegram 客户端对 DH 参数有严格的安全检查
   - 可能检查 p 是否为安全素数
   - 可能检查 g^b mod p 的范围

3. **MTProto 协议版本不匹配**：
   - Echo 服务器使用的 MTProto 版本与客户端不兼容
   - DH 参数格式不一致

---

## 2. 已完成的工作

### 2.1 服务器地址配置

✅ 已将 ConnectionsManager.cpp 中的服务器地址从 `127.0.0.1` 改为 `192.168.0.17`

**修改位置**：
- 文件：`echo-android-client/TMessagesProj/jni/tgnet/ConnectionsManager.cpp`
- 行号：1820-1865
- 修改数量：8 处

### 2.2 RSA 公钥配置

✅ 已将 Echo 服务器的 RSA 公钥添加到客户端

**修改位置**：
- 文件：`echo-android-client/TMessagesProj/jni/tgnet/Handshake.cpp`
- 行号：377-386

**Echo 服务器公钥**：
```
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEAvKLEOWTzt9Hn3/9Kdp/RdHcEhzmd8xXeLSpHIIzaXTLJDw8BhJy1
jR/iqeG8Je5yrtVabqMSkA6ltIpgylH///FojMsX1BHu4EPYOXQgB0qOi6kr08iX
ZIH9/iOPQOWDsL+Lt8gDG0xBy+sPe/2ZHdzKMjX6O9B4sOsxjFrk5qDoWDrioJor
AJ7eFAfPpOBf2w73ohXudSrJE0lbQ8pCWNpMY8cB9i8r+WBitcvouLDAvmtnTX7a
khoDzmKgpJBYliAY4qA73v7u5UIepE8QgV0jCOhxJCPubP8dg+/PlLLVKyxU5Cdi
QtZj2EMy4s9xlNKzX8XezE0MHEa6bQpnFwIDAQAB
-----END RSA PUBLIC KEY-----
```

**指纹**：`0xa9e071c1771060cd`

### 2.3 服务器启动

✅ Echo 服务器所有核心服务已启动：
- gnetway (PID 35130) - 监听 `*:10443`
- session (PID 35134)
- bff (PID 35136)
- authsession (PID 35146)

---

## 3. 待调查的问题

### 3.1 服务器端调查

需要检查 Echo 服务器的 DH 参数生成逻辑：

1. **查找 DH 参数生成代码**：
   ```bash
   grep -r "DH\|diffie" echo-server-source/app/interface/gnetway/
   ```

2. **检查服务器日志**：
   - gnetway 日志中是否有 DH 相关错误
   - 是否记录了握手失败的原因

3. **对比 Teamgram 官方服务器**：
   - Teamgram 官方服务器 (43.155.11.190:10443) 的 DH 参数
   - 是否有配置文件可以调整 DH 参数

### 3.2 客户端端调查

需要检查客户端的 DH 验证逻辑：

1. **查找 DH 验证代码**：
   ```bash
   grep -r "retry DH" echo-android-client/TMessagesProj/jni/tgnet/
   ```

2. **分析 Handshake.cpp 中的 DH 验证**：
   - 哪些条件会导致 "retry DH"
   - 是否可以放宽验证条件（仅用于开发测试）

3. **对比 Teamgram Android 客户端**：
   - teamgram-android 项目的 DH 验证逻辑
   - 是否有不同的配置

---

## 4. 可能的解决方案

### 4.1 方案 1：修复服务器 DH 参数生成

**适用场景**：如果服务器 DH 参数生成有问题

**步骤**：
1. 找到服务器 DH 参数生成代码
2. 确保生成安全素数 (safe prime)
3. 确保生成元 g 正确（通常为 2 或 3）
4. 重新编译服务器
5. 重启服务器测试

**优点**：根本解决问题
**缺点**：需要修改服务器代码并重新编译

### 4.2 方案 2：放宽客户端 DH 验证（仅开发测试）

**适用场景**：快速验证其他功能

**步骤**：
1. 找到客户端 DH 验证代码
2. 临时注释掉部分安全检查
3. 重新编译客户端
4. 测试连接

**优点**：快速验证
**缺点**：
- 降低安全性（仅用于开发）
- 不是长期解决方案

### 4.3 方案 3：使用 Teamgram 官方客户端

**适用场景**：验证服务器是否正常

**步骤**：
1. 编译 teamgram-android 项目
2. 修改服务器地址为 192.168.0.17
3. 测试连接

**优点**：
- 验证服务器是否正常
- 如果能连接，说明问题在我们的客户端配置

**缺点**：
- 需要额外编译
- 不解决根本问题

### 4.4 方案 4：使用 Teamgram 官方服务器（临时）

**适用场景**：快速验证客户端功能

**步骤**：
1. 修改 ConnectionsManager.cpp 服务器地址为 `43.155.11.190`
2. 重新编译客户端
3. 测试连接

**优点**：
- 快速验证客户端功能
- 确认客户端编译配置正确

**缺点**：
- 依赖外部服务器
- 不是最终方案

---

## 5. 下一步行动

### 5.1 立即行动

1. **查找客户端 DH 验证代码**：
   ```bash
   grep -rn "retry DH" echo-android-client/TMessagesProj/jni/tgnet/
   ```

2. **查找服务器 DH 参数生成代码**：
   ```bash
   find echo-server-source -name "*.go" -exec grep -l "DH\|diffie" {} \;
   ```

3. **启用服务器详细日志**：
   - 修改 gnetway.yaml 日志级别为 debug
   - 重启服务器
   - 查看详细握手日志

### 5.2 后续计划

1. **对比 Teamgram 官方实现**：
   - 研究 Teamgram 服务器的 DH 实现
   - 研究 Teamgram Android 客户端的 DH 验证

2. **咨询 Teamgram 社区**：
   - 在 Teamgram GitHub 提 Issue
   - 询问是否有已知的 DH 握手问题

3. **考虑使用 Teamgram 官方客户端**：
   - 如果我们的客户端配置有问题
   - 可以先使用官方客户端验证服务器

---

## 6. 相关文档

### 6.1 相关变更记录

- **ECHO-BUG-013**: 修复真机无法连接到 Echo 服务器
  - 路径: `echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-013-fix-real-device-connection.md`
  - 关联: 服务器地址配置

### 6.2 参考文档

- [MTProto 协议文档](https://core.telegram.org/mtproto)
- [Diffie-Hellman 密钥交换](https://core.telegram.org/mtproto/auth_key)
- [Teamgram GitHub](https://github.com/teamgram/teamgram-server)

---

## 7. 技术细节

### 7.1 MTProto 握手流程

1. **req_pq_multi**：客户端请求 PQ 分解
2. **resPQ**：服务器返回 PQ 和服务器 nonce
3. **req_DH_params**：客户端请求 DH 参数
4. **server_DH_params_ok**：服务器返回 DH 参数（p, g, g_a）
5. **set_client_DH_params**：客户端发送 g_b
6. **dh_gen_ok**：服务器确认，握手完成

**当前失败阶段**：步骤 4-5 之间，客户端收到 DH 参数后验证失败

### 7.2 DH 参数安全检查

客户端通常会检查：
1. **p 是否为安全素数**：p = 2q + 1，其中 q 也是素数
2. **g 是否为有效生成元**：通常为 2, 3, 4, 5, 6, 7
3. **g_a 和 g_b 的范围**：1 < g_a < p-1, 1 < g_b < p-1
4. **g_a 和 g_b 不能太小**：防止小子群攻击

---

## 8. 临时解决方案

在找到根本原因之前，可以使用以下临时方案：

### 8.1 使用 Teamgram 官方服务器

修改 `ConnectionsManager.cpp`：
```cpp
datacenter->addAddressAndPort("43.155.11.190", 10443, 0, "");
```

### 8.2 等待 Teamgram 社区支持

在 Teamgram GitHub 提 Issue，描述问题并请求帮助。

---

## 9. 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| 1.0.0 | 2026-02-01 | AI Agent | 初始版本，记录 DH 握手失败问题 |

---

**最后更新**: 2026-02-01  
**维护者**: Echo 项目团队  
**状态**: 🔍 调查中

---

## 附录：调试命令

### 查看客户端日志
```bash
adb logcat | grep -E "tgnet|handshake|DH"
```

### 查看服务器日志
```bash
tail -f echo-server-source/echod/logs/gnetway.log
tail -f echo-server-source/echod/logs/session.log
```

### 检查服务器状态
```bash
ps aux | grep -E "gnetway|session|bff|authsession"
lsof -i :10443
```

### 检查网络连接
```bash
# 从 Android 设备测试连接
adb shell ping -c 3 192.168.0.17
adb shell nc -zv 192.168.0.17 10443
```
