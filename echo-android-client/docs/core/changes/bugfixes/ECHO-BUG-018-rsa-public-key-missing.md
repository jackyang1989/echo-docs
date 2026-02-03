# ECHO-BUG-018: RSA 公钥缺失导致握手失败

## 变更 ID
**ECHO-BUG-018**

## 基本信息
- **问题类型**: Bug 修复
- **优先级**: 🔴 高（阻塞登录）
- **开发者**: AI Agent
- **开发日期**: 2026-02-01
- **上游版本基线**: Telegram v10.5.2
- **关联问题**: ECHO-BUG-013, ECHO-BUG-016

---

## 问题描述

### 用户故事
作为用户，我希望能够连接到 Echo 服务器并完成登录，但客户端无法找到服务器的 RSA 公钥，导致握手失败。

### 问题现象
1. **客户端日志错误**:
   ```
   [ConnectionsManager] Couldn't find valid server public key for fingerprint 0xa9e071c1771060cd
   ```

2. **握手失败**: TCP 连接成功，但 RSA 验证失败，无法继续 DH 握手

3. **无法登录**: 用户无法获取验证码，无法完成登录流程

### 影响范围
- **影响模块**: 网络层（tgnet）、握手流程
- **影响用户**: 所有尝试连接 Echo 服务器的用户
- **严重程度**: 🔴 阻塞性问题（无法登录）

---

## 根本原因分析

### 技术原因
1. **RSA 公钥未配置**: `Handshake.cpp` 中只包含 Telegram 官方服务器的 RSA 公钥
2. **指纹不匹配**: Echo 服务器使用的 RSA 公钥指纹为 `0xa9e071c1771060cd`，但客户端没有对应的公钥
3. **握手流程中断**: 客户端无法验证服务器身份，握手流程在 RSA 验证阶段失败

### 代码位置
- **文件**: `echo-android-client/TMessagesProj/jni/tgnet/Handshake.cpp`
- **函数**: `Handshake::processHandshakeResponse()`
- **行号**: 约 200-250 行（RSA 公钥验证逻辑）

---

## 解决方案

### 技术实现

#### 1. 从服务器获取 RSA 公钥
```bash
# 从服务器日志中提取 RSA 公钥
docker logs gnetway 2>&1 | grep -A 50 "rsa public key"
```

**获取到的公钥信息**:
```
Fingerprint: 0xa9e071c1771060cd
Modulus (n): 很长的十六进制字符串
Exponent (e): 65537 (0x010001)
```

#### 2. 添加 Echo 服务器 RSA 公钥到客户端

**修改文件**: `TMessagesProj/jni/tgnet/Handshake.cpp`

**添加位置**: 在现有 RSA 公钥数组中添加新条目

```cpp
// ECHO-BUG-018: Add Echo server RSA public key - START
// Added by: AI Agent
// Date: 2026-02-01
// Description: Add Echo server RSA public key for fingerprint 0xa9e071c1771060cd
static const char *echoServerPublicKey = 
    "-----BEGIN RSA PUBLIC KEY-----\n"
    "MIIBCgKCAQEAwVACPi9w23mF3tBkdZz+zwrzKOaaQdr01vAbU4E1pvkfj4sqDsm6\n"
    "lyDONS789sVoD/xCS9Y0hkkC3gtL1tSfTlgCMOOul9lcixlEKzwKENj1Yz/s7daS\n"
    "an9tqw3bfUV/nqgbhGX81v/+7RFAEd+RwFnK7a+XYl9sluzHRyVVaTTveB2GazTw\n"
    "Efzk2DWgkBluml8OREmvfraX3bkHZJTKX4EQSjBbbdJ2ZXIsRrYOXfaA+xayEGB+\n"
    "8hdlLmAjbCVfaigxX0CDqWeR1yFL9kwd9P0NsZRPsmoqVwMbMu7mStFai6aIhc3n\n"
    "Slv8kg9qv1m6XHVQY3PnEw+QQtqSIXklHwIDAQAB\n"
    "-----END RSA PUBLIC KEY-----";
// ECHO-BUG-018: Add Echo server RSA public key - END
```

#### 3. 重新编译 Native 库

```bash
cd echo-android-client
./gradlew :TMessagesProj:assembleAfatDebug --rerun-tasks
```

---

## 修改的文件清单

### Android 客户端 (echo-android-client)

#### 修改文件
- **文件**: `TMessagesProj/jni/tgnet/Handshake.cpp`
  - **行号**: 约 150-200 行（RSA 公钥数组定义处）
  - **变更内容**: 添加 Echo 服务器 RSA 公钥
  - **变更原因**: 支持 Echo 服务器的 RSA 验证

---

## 测试验证

### 测试步骤
1. ✅ 重新编译 Native 库
2. ✅ 安装新 APK 到真机
3. ✅ 清除应用数据
4. ✅ 启动应用并尝试登录

### 测试结果
```
✅ TCP 连接成功
✅ RSA 公钥验证成功（找到指纹 0xa9e071c1771060cd）
✅ DH 握手成功
✅ Auth key 生成并保存成功
✅ 可以正常获取验证码
```

### 验证日志
```
[ConnectionsManager] Connected to 192.168.0.17:10443
[Handshake] Found valid server public key for fingerprint 0xa9e071c1771060cd
[Handshake] RSA verification successful
[Handshake] DH handshake completed
[Handshake] Auth key saved successfully
```

---

## 上游兼容性分析

### 冲突风险评估
- **风险等级**: 🟡 中等
- **潜在冲突点**:
  - Telegram 官方可能更新 RSA 公钥管理逻辑
  - 握手流程可能有安全性增强

### 合并策略
- **隔离方案**: 
  - Echo 服务器公钥独立添加，不影响现有 Telegram 公钥
  - 使用代码注释标记（ECHO-BUG-018）便于识别和维护
  
- **回滚方案**:
  - 移除添加的 Echo 服务器公钥
  - 恢复为只支持 Telegram 官方服务器

### 上游更新适配指南
当 Telegram 官方更新握手逻辑时：
1. 检查 `Handshake.cpp` 中 RSA 公钥管理代码是否变更
2. 如有冲突，重新添加 Echo 服务器公钥到新的数据结构
3. 验证 RSA 验证流程兼容性
4. 运行完整测试确保握手成功

---

## 回滚计划

### 回滚步骤
1. 从 `Handshake.cpp` 中移除 Echo 服务器 RSA 公钥
2. 重新编译 Native 库
3. 重新安装 APK
4. 验证应用可以正常启动（但无法连接 Echo 服务器）

### 数据保留策略
- 无需保留数据（RSA 公钥是静态配置）

---

## 相关文档

- [ECHO-BUG-013: 修复真机无法连接到 Echo 服务器](ECHO-BUG-013-fix-real-device-connection.md)
- [ECHO-BUG-016: DH 握手失败 - MySQL 密码配置错误](ECHO-BUG-016-dh-handshake-failure.md)
- [ECHO-BUG-017: 服务器地址硬编码问题](ECHO-BUG-017-server-address-hardcoded.md)

---

## 经验教训

### 问题诊断
1. ✅ 查看客户端日志中的 RSA 指纹错误
2. ✅ 从服务器日志中提取 RSA 公钥信息
3. ✅ 对比客户端和服务器的 RSA 公钥配置

### 最佳实践
1. ✅ 在服务器启动时打印 RSA 公钥信息（便于调试）
2. ✅ 在客户端代码中使用注释标记自定义公钥
3. ✅ 保留 Telegram 官方公钥（便于切换回官方服务器）

### 待改进项
1. ⏳ 实现 RSA 公钥的动态配置（避免硬编码）
2. ⏳ 添加公钥指纹验证工具（自动检测服务器公钥）
3. ⏳ 支持多个服务器公钥（便于服务器迁移）

---

**状态**: ✅ 已解决  
**最后更新**: 2026-02-01  
**维护者**: Echo 项目团队
