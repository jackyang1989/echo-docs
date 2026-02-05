# ECHO-BUG-027: 三星手机间歇性连接问题

## 变更 ID
**ECHO-BUG-027**

## 基本信息
- **问题类型**: Bug 修复（客户端连接稳定性）
- **优先级**: 🟡 中（影响用户体验但有临时解决方案）
- **开发者**: AI Agent
- **开发日期**: 2026-02-06
- **上游版本基线**: Telegram v10.5.2
- **关联问题**: ECHO-BUG-020 (验证码超时)

---

## 问题描述

### 用户故事
作为用户，我希望能够稳定地连接到 Echo 服务器并登录，但实际体验是：
- 有时能立刻进入验证码页面
- 有时点击"获取验证码"一直转圈，无法进入验证码页面
- 有时输入验证码后卡住无法登录
- 需要多次重启应用才能成功（前2次失败，第3次成功）

### 问题现象
1. **间歇性连接失败**:
   - 第1次尝试：点击"获取验证码" → 一直转圈 → 超时
   - 第2次尝试：关闭应用重新打开 → 点击"获取验证码" → 一直转圈 → 超时
   - 第3次尝试：关闭应用重新打开 → 点击"获取验证码" → 成功进入验证码页面

2. **设备信息**:
   - 设备: 三星手机 (R5CX431D85K, SM_S9180)
   - 应用: Echo Messenger (com.echo.messenger)
   - 网络: WiFi 连接 (192.168.0.x)
   - 服务器: 192.168.0.17:10443

3. **服务器状态**:
   - ✅ 所有服务运行正常
   - ✅ 端口 10443 正常监听
   - ✅ 验证码生成正常
   - ✅ 用户最终成功登录

### 影响范围
- **影响模块**: 连接管理、Auth 流程
- **影响用户**: 部分用户（特别是三星设备）
- **严重程度**: 🟡 中等（有临时解决方案：多次重启）

---

## 根本原因分析

### 诊断过程

#### 1. 服务器端检查
```bash
# 检查服务状态
$ ps aux | grep echo-server
✅ Gateway (PID: 23263) - 运行中
✅ Auth (PID: 23264) - 运行中
✅ Message (PID: 23265) - 运行中
✅ Sync (PID: 23266) - 运行中
✅ User (PID: 23267) - 运行中

# 检查端口监听
$ lsof -i :10443
✅ 端口 10443 正常监听

# 检查 Auth 日志
$ tail -f echo-server/auth.log
✅ 验证码生成正常
✅ 用户登录成功
```

#### 2. 客户端行为分析
从用户反馈和日志分析：
- **第1次尝试失败**: 客户端发送 auth.sendCode 请求 → 超时 → 无响应
- **第2次尝试失败**: 关闭应用重新打开 → 发送 auth.sendCode 请求 → 超时 → 无响应
- **第3次尝试成功**: 关闭应用重新打开 → 发送 auth.sendCode 请求 → 成功 → 进入验证码页面

#### 3. 网络层分析
从 Gateway 日志分析：
- ✅ 客户端可以建立 TCP 连接
- ✅ 客户端可以完成 DH 握手
- ✅ 客户端可以发送 help.getConfig 请求
- ❌ 客户端发送 auth.sendCode 请求时偶尔超时

### 技术原因

#### 1. 连接池管理问题
**问题**: 客户端连接池中的旧连接未正确关闭，导致新连接建立失败。

**证据**:
- 用户需要多次重启应用才能成功
- 每次重启后，旧连接被强制关闭
- 第3次重启后，连接池完全清空，新连接成功建立

**代码位置**: `ConnectionsManager.java`
- 连接池管理逻辑
- 连接关闭逻辑
- 连接重用逻辑

#### 2. Auth Key 缓存问题
**问题**: 客户端缓存了旧的 Auth Key，导致认证失败。

**证据**:
- 用户需要多次重启应用
- 每次重启后，Auth Key 缓存被清空
- 新的 Auth Key 生成后，连接成功

**代码位置**: `ConnectionsManager.java`
- Auth Key 缓存逻辑
- Auth Key 验证逻辑

#### 3. 超时设置过短
**问题**: 客户端超时设置过短，导致正常请求被误判为超时。

**当前超时设置**:
```java
// DNS 查询超时
httpConnection.setConnectTimeout(1000);  // 1秒
httpConnection.setReadTimeout(2000);     // 2秒

// 配置下载超时
httpConnection.setConnectTimeout(5000);  // 5秒
httpConnection.setReadTimeout(5000);     // 5秒
```

**问题**:
- 1秒连接超时对于本地网络可能足够
- 但对于 Auth 请求（需要数据库查询、验证码生成），可能不够
- 特别是在服务器负载较高时

#### 4. 网络切换延迟
**问题**: 三星设备在网络切换时（WiFi ↔ 移动数据）可能有延迟。

**证据**:
- 问题主要出现在三星设备
- 用户需要多次重启应用
- 每次重启后，网络状态被重新检测

---

## 解决方案

### 方案 A: 增加客户端超时时间（推荐）

#### 优点
- ✅ 简单直接
- ✅ 不影响现有逻辑
- ✅ 可以快速验证效果

#### 缺点
- ⚠️ 可能增加用户等待时间
- ⚠️ 不解决根本问题（连接池管理）

#### 实现方案

**文件**: `echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/ConnectionsManager.java`

**修改位置**: Native 层超时配置（需要修改 C++ 代码）

**建议超时值**:
```cpp
// 当前值（推测）
#define CONNECTION_TIMEOUT 10  // 10秒
#define REQUEST_TIMEOUT 15     // 15秒

// 建议值
#define CONNECTION_TIMEOUT 20  // 20秒
#define REQUEST_TIMEOUT 30     // 30秒
```

**注意**: 这需要修改 JNI 层的 C++ 代码，不在当前 Java 代码范围内。

---

### 方案 B: 改进连接池管理（长期方案）

#### 优点
- ✅ 解决根本问题
- ✅ 提高连接稳定性
- ✅ 减少连接建立次数

#### 缺点
- ⚠️ 实现复杂
- ⚠️ 需要充分测试
- ⚠️ 可能引入新问题

#### 实现方案

**文件**: `echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/ConnectionsManager.java`

**修改内容**:

1. **添加连接状态检查**:
```java
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Check connection state before reuse

private boolean isConnectionValid(int dcId, int connectionType) {
    // 检查连接是否有效
    // 1. 检查 TCP 连接是否存活
    // 2. 检查 Auth Key 是否有效
    // 3. 检查最后活动时间
    return native_isConnectionValid(currentAccount, dcId, connectionType);
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

2. **添加连接清理逻辑**:
```java
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Clean up stale connections

public void cleanupStaleConnections() {
    Utilities.stageQueue.postRunnable(() -> {
        native_cleanupStaleConnections(currentAccount);
    });
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

3. **在应用启动时清理旧连接**:
```java
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Clean up connections on app start

public ConnectionsManager(int instance) {
    super(instance);
    // ... 现有代码 ...
    
    // 清理旧连接
    cleanupStaleConnections();
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

**注意**: 这些方法需要在 JNI 层实现对应的 native 方法。

---

### 方案 C: 添加重试机制（推荐）

#### 优点
- ✅ 简单有效
- ✅ 不需要修改底层逻辑
- ✅ 用户体验好（自动重试）

#### 缺点
- ⚠️ 可能增加服务器负载
- ⚠️ 需要合理设置重试次数

#### 实现方案

**文件**: `echo-android-client/TMessagesProj/src/main/java/com/echo/ui/LoginActivity.java`

**修改内容**:

1. **添加重试逻辑**:
```java
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Add retry mechanism for auth.sendCode

private int sendCodeRetryCount = 0;
private static final int MAX_SEND_CODE_RETRIES = 3;
private static final int RETRY_DELAY_MS = 2000; // 2秒

private void sendCodeWithRetry(String phoneNumber) {
    sendCodeRetryCount = 0;
    sendCodeInternal(phoneNumber);
}

private void sendCodeInternal(String phoneNumber) {
    // 发送 auth.sendCode 请求
    TLRPC.TL_auth_sendCode req = new TLRPC.TL_auth_sendCode();
    req.phone_number = phoneNumber;
    // ... 其他参数 ...
    
    ConnectionsManager.getInstance(currentAccount).sendRequest(req, (response, error) -> {
        if (error != null) {
            // 检查是否是超时错误
            if (error.code == -1000 && sendCodeRetryCount < MAX_SEND_CODE_RETRIES) {
                // 超时，重试
                sendCodeRetryCount++;
                AndroidUtilities.runOnUIThread(() -> {
                    // 显示重试提示
                    showRetryMessage(sendCodeRetryCount);
                    
                    // 延迟后重试
                    AndroidUtilities.runOnUIThread(() -> {
                        sendCodeInternal(phoneNumber);
                    }, RETRY_DELAY_MS);
                });
            } else {
                // 其他错误或重试次数用尽，显示错误
                AndroidUtilities.runOnUIThread(() -> {
                    showErrorMessage(error);
                });
            }
        } else {
            // 成功，进入验证码页面
            AndroidUtilities.runOnUIThread(() -> {
                showCodeEntry();
            });
        }
    });
}

private void showRetryMessage(int retryCount) {
    // 显示重试提示
    String message = String.format("连接超时，正在重试 (%d/%d)...", retryCount, MAX_SEND_CODE_RETRIES);
    // 显示 Toast 或更新 UI
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

2. **添加用户友好的错误提示**:
```java
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Add user-friendly error messages

private void showErrorMessage(TLRPC.TL_error error) {
    String message;
    if (error.code == -1000) {
        // 连接超时
        message = "连接超时，请检查网络连接后重试";
    } else if (error.code == -1001) {
        // 服务器不可达
        message = "无法连接到服务器，请稍后重试";
    } else {
        // 其他错误
        message = "发生错误: " + error.text;
    }
    
    // 显示错误对话框
    AlertDialog.Builder builder = new AlertDialog.Builder(getParentActivity());
    builder.setTitle("连接失败");
    builder.setMessage(message);
    builder.setPositiveButton("重试", (dialog, which) -> {
        sendCodeWithRetry(phoneNumber);
    });
    builder.setNegativeButton("取消", null);
    builder.show();
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

---

### 方案 D: 优化 Auth 服务响应速度（服务端）

#### 优点
- ✅ 从根本上解决问题
- ✅ 提高所有用户体验
- ✅ 减少超时概率

#### 缺点
- ⚠️ 需要修改服务端代码
- ⚠️ 需要数据库优化

#### 实现方案

**文件**: `echo-server/internal/service/auth/service.go`

**优化内容**:

1. **添加数据库连接池**:
```go
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Add database connection pool

// 增加数据库连接池大小
db.SetMaxOpenConns(50)  // 最大打开连接数
db.SetMaxIdleConns(10)  // 最大空闲连接数
db.SetConnMaxLifetime(time.Hour)  // 连接最大生命周期

// ECHO-BUG-027: Intermittent Connection Issue - END
```

2. **添加请求超时控制**:
```go
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Add request timeout control

func (s *AuthService) SendCode(ctx context.Context, req *pb.SendCodeRequest) (*pb.SendCodeResponse, error) {
    // 设置超时上下文
    ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
    defer cancel()
    
    // 执行业务逻辑
    // ...
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

3. **添加性能监控**:
```go
// ECHO-BUG-027: Intermittent Connection Issue - START
// Added by: AI Agent
// Date: 2026-02-06
// Description: Add performance monitoring

func (s *AuthService) SendCode(ctx context.Context, req *pb.SendCodeRequest) (*pb.SendCodeResponse, error) {
    start := time.Now()
    defer func() {
        duration := time.Since(start)
        if duration > 5*time.Second {
            log.Warn().
                Dur("duration", duration).
                Str("phone", req.PhoneNumber).
                Msg("⚠️ [Auth] SendCode slow request")
        }
    }()
    
    // 执行业务逻辑
    // ...
}

// ECHO-BUG-027: Intermittent Connection Issue - END
```

---

## 临时解决方案（用户指引）

在修复代码之前，用户可以使用以下临时解决方案：

### 方法 1: 多次重启应用
1. 完全关闭应用（从后台清除）
2. 等待 5-10 秒
3. 重新打开应用
4. 如果还是转圈，再重复 1-2 次

### 方法 2: 清除应用数据
1. 进入系统设置 → 应用管理
2. 找到 Echo Messenger
3. 点击"清除数据"
4. 重新打开应用并登录

### 方法 3: 切换网络
1. 关闭 WiFi，使用移动数据
2. 或关闭移动数据，使用 WiFi
3. 重新尝试登录

---

## 测试验证

### 测试步骤
1. ✅ 启动 Echo 服务器
2. ✅ 验证服务状态（所有服务运行中）
3. ✅ 验证端口监听（10443 正在监听）
4. ✅ 清除应用数据
5. ✅ 启动应用并尝试获取验证码
6. ✅ 观察是否出现间歇性连接问题

### 测试结果
```
✅ 服务器运行正常
✅ 端口 10443 正在监听
✅ 客户端可以连接到服务器
✅ 验证码请求成功发送
✅ 进入验证码输入界面
⚠️ 偶尔出现连接超时（需要重试）
```

### 验证日志

**Auth 日志**:
```
2026/02/06 00:32:51 📱 [Auth] 验证码已生成: phone=8618124944249, code=80638
2026/02/06 00:33:12 ✅ [Auth] 用户登录成功: phone=8618124944249, user_id=5
2026/02/06 00:40:04 📱 [Auth] 验证码已生成: phone=8618124944249, code=30398
2026/02/06 00:40:14 📱 [Auth] 验证码已生成: phone=8618124944249, code=62746
2026/02/06 00:42:37 📱 [Auth] 验证码已生成: phone=8618124944249, code=67863
2026/02/06 00:49:31 ✅ [Auth] 用户登录成功: phone=8618124944249, user_id=5
2026/02/06 00:53:06 📱 [Auth] 验证码已生成: phone=8618124944249, code=37408
2026/02/06 00:53:43 ✅ [Auth] 用户登录成功: phone=8618124944249, user_id=5
```

**Gateway 日志**:
```
12:56AM INF gateway msg="⚙️ [RPC] help.getConfig (via rpcRouter)"
12:56AM INF gateway msg="✅ [RPC] Response sent to client"
```

---

## 上游兼容性分析

### 冲突风险评估
- **风险等级**: 🟡 中等
- **潜在冲突点**:
  - `ConnectionsManager.java` 的连接管理逻辑可能与上游更新冲突
  - `LoginActivity.java` 的登录流程可能与上游更新冲突

### 合并策略
- **隔离方案**: 
  - 使用代码注释标记（ECHO-BUG-027）
  - 重试逻辑封装在独立方法中
  - 不修改核心连接逻辑
  
- **回滚方案**:
  - 移除重试逻辑
  - 恢复原有超时设置
  - 清除代码注释标记

### 上游更新适配指南
当 Telegram 官方更新时：
1. 检查 `ConnectionsManager.java` 连接管理相关代码是否变更
2. 检查 `LoginActivity.java` 登录流程相关代码是否变更
3. 如有冲突，优先保留上游逻辑，重新集成重试机制
4. 验证重试逻辑仍然有效
5. 运行完整测试套件确保功能正常

---

## 回滚计划

### 回滚步骤
1. 移除重试逻辑代码
2. 恢复原有超时设置
3. 清除代码注释标记（ECHO-BUG-027）
4. 重新编译和测试

### 数据保留策略
- 无需保留数据（这是代码逻辑问题）

---

## 相关文档

- [ECHO-BUG-020: 验证码获取超时](ECHO-BUG-020-verification-code-timeout.md)
- [ECHO-BUG-013: 修复真机无法连接到 Echo 服务器](ECHO-BUG-013-fix-real-device-connection.md)
- [三星手机连接诊断脚本](../../../diagnose-samsung-connection.sh)
- [Auth 超时诊断脚本](../../../diagnose-auth-timeout.sh)

---

## 经验教训

### 问题诊断
1. ✅ 间歇性问题比持续性问题更难诊断
2. ✅ 需要收集多次失败和成功的日志对比
3. ✅ 用户反馈"需要多次重启"是连接池问题的典型症状

### 最佳实践
1. ✅ 添加自动重试机制（提高用户体验）
2. ✅ 添加用户友好的错误提示（减少用户困惑）
3. ✅ 添加性能监控（及时发现慢请求）
4. ✅ 优化服务端响应速度（从根本上解决问题）

### 待改进项
1. ⏳ 实现方案 C（添加重试机制）
2. ⏳ 实现方案 D（优化 Auth 服务响应速度）
3. ⏳ 添加客户端连接状态监控
4. ⏳ 添加服务端性能监控和告警

---

## 快速参考

### 问题症状
- 点击"获取验证码"一直转圈
- 需要多次重启应用才能成功
- 第1-2次失败，第3次成功

### 快速诊断
```bash
# 检查服务器状态
ps aux | grep echo-server

# 检查端口监听
lsof -i :10443

# 实时监控 Auth 日志
tail -f echo-server/auth.log | grep -E "验证码|登录"
```

### 临时解决方案
1. 完全关闭应用（从后台清除）
2. 等待 5-10 秒
3. 重新打开应用
4. 如果还是转圈，再重复 1-2 次

### 长期解决方案
- 实现方案 C: 添加重试机制（推荐）
- 实现方案 D: 优化 Auth 服务响应速度（推荐）

---

**状态**: ⏳ 待修复（已提供临时解决方案）  
**最后更新**: 2026-02-06  
**维护者**: Echo 项目团队
