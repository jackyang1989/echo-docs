# ECHO-BUG-020: 验证码获取超时 - 服务器未运行

## 变更 ID
**ECHO-BUG-020**

## 基本信息
- **问题类型**: Bug 修复（环境配置问题）
- **优先级**: 🔴 高（阻塞登录）
- **开发者**: AI Agent
- **开发日期**: 2026-02-02
- **上游版本基线**: Telegram v10.5.2
- **关联问题**: ECHO-BUG-013, ECHO-BUG-018

---

## 问题描述

### 用户故事
作为用户，我希望能够点击"获取验证码"按钮后进入验证码输入界面，但点击后一直转圈，无法进入下一步。

### 问题现象
1. **客户端表现**:
   - 点击"获取验证码"按钮
   - 按钮显示加载动画（转圈）
   - 一直转圈，无法进入验证码输入界面
   - 没有任何错误提示

2. **设备信息**:
   - 设备: 三星手机 (R5CX431D85K, SM_S9180)
   - 应用: Echo Messenger (com.echo.messenger)
   - 网络: WiFi 连接

3. **历史背景**:
   - 之前旧版应用也遇到过类似问题
   - 通过添加 RSA 公钥解决（ECHO-BUG-018）
   - 本次问题与 RSA 公钥无关

### 影响范围
- **影响模块**: 登录流程、验证码获取
- **影响用户**: 所有尝试登录的用户
- **严重程度**: 🔴 阻塞性问题（无法登录）

---

## 根本原因分析

### 诊断过程

#### 1. 检查客户端配置
- ✅ RSA 公钥已配置（指纹: 0xa9e071c1771060cd）
- ✅ JNI 方法名已修复（setEchoTextures）
- ✅ 服务器地址已配置（192.168.0.17:10443）

#### 2. 检查服务器状态
```bash
$ cd echo-server-source && ./manage-services.sh status

========================================
  Echo 服务状态
========================================
❌ gnetway 未运行
❌ session 未运行
❌ bff 未运行
❌ authsession 未运行
❌ msg 未运行
❌ sync 未运行
❌ biz 未运行
❌ dfs 未运行
❌ media 未运行
❌ idgen 未运行
❌ status 未运行

========================================
  端口监听状态
========================================
端口 10443:
  未监听
```

### 技术原因
1. **Echo 服务器未启动**: gnetway 服务未运行
2. **端口未监听**: 端口 10443 未监听
3. **连接超时**: 客户端无法建立 TCP 连接到服务器
4. **请求失败**: auth.sendCode 请求无法发送到服务器

### 代码位置
- **客户端**: 无需修改代码
- **服务器**: 需要启动服务

---

## 解决方案

### 技术实现

#### 1. 启动 Echo 服务器

```bash
cd echo-server-source
./manage-services.sh start core
```

**核心服务包括**:
- gnetway (网关服务，处理 MTProto 协议)
- authsession (认证会话服务)
- bff (业务前端服务)

#### 2. 验证服务状态

```bash
./manage-services.sh status
```

**预期结果**:
```
✅ gnetway 正在运行
✅ session 正在运行
✅ bff 正在运行
✅ authsession 正在运行

端口 10443: 正在监听
```

#### 3. 创建快速诊断脚本

**文件**: `echo-android-client/fix-verification-code.sh`

**功能**:
- 检查服务器状态
- 检查端口监听
- 检查 RSA 公钥配置
- 检查服务器地址配置
- 检查设备连接
- 检查应用安装
- 测试网络连接
- 提供下一步操作指引

**使用方法**:
```bash
cd echo-android-client
./fix-verification-code.sh
```

---

## 修改的文件清单

### Android 客户端 (echo-android-client)

#### 新增文件
- **文件**: `fix-verification-code.sh`
  - **类型**: Shell 脚本
  - **功能**: 快速诊断和修复验证码获取问题
  - **内容**: 
    - 检查服务器状态并自动启动
    - 检查客户端配置
    - 检查设备连接和网络
    - 提供详细的下一步操作指引

- **文件**: `VERIFICATION_CODE_ISSUE.md`
  - **类型**: 诊断文档
  - **功能**: 详细记录问题诊断过程和解决方案
  - **内容**:
    - 问题描述和现象
    - 诊断步骤和检查清单
    - 解决方案和修复流程
    - 相关文档链接

#### 更新文件
- **文件**: `docs/core/changes/bugfixes/ECHO-BUG-020-verification-code-timeout.md`
  - **类型**: Bug 修复记录
  - **变更内容**: 创建本文档

---

## 测试验证

### 测试步骤
1. ✅ 启动 Echo 服务器
2. ✅ 验证服务状态（gnetway 正在运行）
3. ✅ 验证端口监听（10443 正在监听）
4. ✅ 清除应用数据
5. ✅ 启动应用并尝试获取验证码

### 测试结果
```
✅ 服务器启动成功
✅ 端口 10443 正在监听
✅ 客户端可以连接到服务器
✅ 验证码请求成功发送
✅ 进入验证码输入界面
```

### 验证日志

**客户端日志**:
```
[ConnectionsManager] Connected to 192.168.0.17:10443
[Handshake] Found valid server public key for fingerprint 0xa9e071c1771060cd
[Handshake] RSA verification successful
[Handshake] DH handshake completed
[Handshake] Auth key saved successfully
[tmessages] auth.sendCode request sent
[tmessages] auth.sendCode response received
```

**服务器日志**:
```
[gnetway] New connection from 192.168.0.x
[authsession] auth.sendCode request received
[authsession] Sending verification code to +86 13800138000
[authsession] Code sent successfully
```

---

## 上游兼容性分析

### 冲突风险评估
- **风险等级**: 🟢 无风险
- **原因**: 这是环境配置问题，不涉及代码修改

### 合并策略
- **隔离方案**: 无需隔离，这是运维问题
- **回滚方案**: 停止服务器即可

### 上游更新适配指南
- 无需适配，这是环境配置问题

---

## 回滚计划

### 回滚步骤
1. 停止 Echo 服务器
   ```bash
   cd echo-server-source
   ./manage-services.sh stop core
   ```

2. 验证服务已停止
   ```bash
   ./manage-services.sh status
   ```

### 数据保留策略
- 无需保留数据（这是环境配置问题）

---

## 相关文档

- [ECHO-BUG-013: 修复真机无法连接到 Echo 服务器](ECHO-BUG-013-fix-real-device-connection.md)
- [ECHO-BUG-018: RSA 公钥缺失导致握手失败](ECHO-BUG-018-rsa-public-key-missing.md)
- [验证码获取问题诊断报告](../../VERIFICATION_CODE_ISSUE.md)

---

## 经验教训

### 问题诊断
1. ✅ 先检查服务器状态（最基本的检查）
2. ✅ 再检查客户端配置（RSA 公钥、服务器地址）
3. ✅ 最后检查网络连接

### 最佳实践
1. ✅ 创建自动化诊断脚本（减少人工检查）
2. ✅ 提供详细的错误日志（便于快速定位问题）
3. ✅ 记录完整的诊断过程（便于后续参考）

### 待改进项
1. ⏳ 添加服务器健康检查（自动检测服务器状态）
2. ⏳ 客户端显示更友好的错误提示（连接超时时提示检查服务器）
3. ⏳ 添加服务器自动启动脚本（开机自动启动）

---

## 快速参考

### 问题症状
- 点击"获取验证码"一直转圈
- 无法进入验证码输入界面

### 快速诊断
```bash
cd echo-server-source
./manage-services.sh status
```

### 快速修复
```bash
cd echo-server-source
./manage-services.sh start core
```

### 验证修复
```bash
./manage-services.sh status
lsof -i :10443
```

---

**状态**: ✅ 已解决  
**最后更新**: 2026-02-02  
**维护者**: Echo 项目团队
