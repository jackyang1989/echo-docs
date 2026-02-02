# Echo 客户端开发指南

## 概述

本文档详细说明如何基于 Telegram 官方客户端源码开发 Echo 客户端。

---

## 一、官方客户端源码

### 1.1 Android 客户端

**源码仓库**: https://github.com/DrKLO/Telegram

**技术栈**:
- 语言: Java
- 构建工具: Gradle
- 最低版本: Android 5.0 (API 21)
- TDLib: 否（使用原生 MTProto 实现）

**特点**:
- ✅ 性能优秀
- ✅ 功能完整
- ✅ 代码质量高
- ✅ 社区活跃

**推荐用于**: Echo Android 客户端（优先开发）

---

### 1.2 iOS 客户端

**源码仓库**: https://github.com/TelegramMessenger/Telegram-iOS

**技术栈**:
- 语言: Swift / Objective-C
- 构建工具: Xcode
- 最低版本: iOS 12.0
- TDLib: 是（已集成）

**特点**:
- ✅ 使用 TDLib（与服务端对接更容易）
- ✅ 代码现代化
- ✅ 官方维护

**推荐用于**: Echo iOS 客户端

---

### 1.3 macOS 客户端

**源码仓库**: https://github.com/overtake/TelegramSwift

**技术栈**:
- 语言: Swift
- 构建工具: Xcode
- 最低版本: macOS 10.13
- TDLib: 是（已集成）

**特点**:
- ✅ 使用 TDLib
- ✅ 纯 Swift 实现
- ⚠️ 社区维护（非官方）

**推荐用于**: Echo macOS 客户端

---

### 1.4 Desktop 客户端

**源码仓库**: https://github.com/telegramdesktop/tdesktop

**技术栈**:
- 语言: C++
- 构建工具: CMake
- 支持平台: Windows, Linux, macOS
- TDLib: 否（使用原生实现）

**特点**:
- ✅ 跨平台
- ✅ 性能优秀
- ⚠️ C++ 代码复杂度高

**推荐用于**: Echo Desktop 客户端（可选）

---

## 二、开发优先级

### 阶段 1: Android 客户端（优先）

**原因**:
- 用户基数大
- 开发相对简单（Java）
- 已有 echo-android-client 基础

**时间**: 2-3 个月

---

### 阶段 2: iOS 客户端

**原因**:
- 高价值用户
- 使用 TDLib（与服务端对接容易）

**时间**: 2-3 个月

---

### 阶段 3: macOS / Desktop 客户端（可选）

**原因**:
- 补充桌面端体验
- 用户需求相对较小

**时间**: 1-2 个月

---

## 三、Android 客户端开发指南

### 3.1 Fork 和初始化

```bash
# 1. Fork 官方仓库
# 访问 https://github.com/DrKLO/Telegram
# 点击 Fork 按钮

# 2. Clone 到本地
git clone https://github.com/YOUR_USERNAME/Telegram.git echo-android-client
cd echo-android-client

# 3. 添加上游仓库
git remote add upstream https://github.com/DrKLO/Telegram.git

# 4. 创建 Echo 分支
git checkout -b echo-main
```

---

### 3.2 必须修改的配置

#### 3.2.1 应用包名

**文件**: `TMessagesProj/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.echo.messenger"  // 原: org.telegram.messenger
        // ...
    }
}
```

#### 3.2.2 服务器地址

**文件**: `TMessagesProj/src/main/java/org/telegram/tgnet/ConnectionsManager.java`

```java
public class ConnectionsManager {
    // 原: 连接到 Telegram 官方服务器
    // 改为: 连接到 Echo 服务器
    
    public static final String ECHO_SERVER_ADDRESS = "api.echo.im";
    public static final int ECHO_SERVER_PORT = 443;
    
    // 禁用 DC 切换
    public static final boolean ENABLE_DC_SWITCH = false;
}
```

#### 3.2.3 API 配置

**文件**: `TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java`

```java
public class BuildVars {
    // 使用 Echo 自己的 API ID 和 Hash
    public static final int APP_ID = YOUR_ECHO_API_ID;
    public static final String APP_HASH = "YOUR_ECHO_API_HASH";
    
    // 禁用 Telegram 官方功能
    public static final boolean USE_OFFICIAL_SERVERS = false;
}
```

#### 3.2.4 品牌相关

**应用名称**:
- `TMessagesProj/src/main/res/values/strings.xml`
- 修改 `app_name` 为 "Echo"

**应用图标**:
- 替换 `TMessagesProj/src/main/res/mipmap-*/` 下的图标文件

**启动页**:
- 修改 `TMessagesProj/src/main/res/drawable/` 下的启动页资源

**主题颜色**:
- 修改 `TMessagesProj/src/main/res/values/colors.xml`

---

### 3.3 登录流程改造

#### 原流程
```
1. 输入手机号
2. 发送 SMS 验证码
3. 输入验证码
4. 登录成功
```

#### Echo 流程
```
1. 选择注册方式:
   - 手机号
   - 邮箱
   - 邀请码
2. 输入账号
3. 发送验证码
4. 输入验证码
5. 设置用户信息（首次注册）
6. 登录成功
```

#### 修改文件

**文件**: `TMessagesProj/src/main/java/org/telegram/ui/LoginActivity.java`

```java
public class LoginActivity extends BaseFragment {
    
    // 添加注册方式选择
    private void showRegistrationTypeSelector() {
        // 1. 手机号
        // 2. 邮箱
        // 3. 邀请码
    }
    
    // 修改验证码发送逻辑
    private void sendVerificationCode(String account, String type) {
        // 调用 Echo 服务器 API
        // auth.sendCode
    }
}
```

---

### 3.4 网络层改造

#### 3.4.1 禁用 DC 切换

**文件**: `TMessagesProj/src/main/java/org/telegram/tgnet/ConnectionsManager.java`

```java
// 禁用自动 DC 切换
private void selectDatacenter() {
    // 原: 根据地理位置选择最近的 DC
    // 改为: 固定连接到 Echo 服务器
    currentDatacenterId = 1;  // 固定 DC ID
    currentDatacenterAddress = ECHO_SERVER_ADDRESS;
    currentDatacenterPort = ECHO_SERVER_PORT;
}
```

#### 3.4.2 修改连接逻辑

```java
// 移除 Telegram 官方 DC 列表
// 只保留 Echo 服务器配置
private static final String[][] datacenters = {
    {"api.echo.im", "443"}  // Echo 服务器
};
```

---

### 3.5 构建和测试

#### 3.5.1 构建 APK

```bash
# Debug 版本
./gradlew assembleDebug

# Release 版本
./gradlew assembleRelease
```

#### 3.5.2 安装测试

```bash
# 安装到设备
adb install -r TMessagesProj/build/outputs/apk/debug/app-debug.apk

# 查看日志
adb logcat | grep Echo
```

---

## 四、iOS 客户端开发指南

### 4.1 Fork 和初始化

```bash
# 1. Fork 官方仓库
# 访问 https://github.com/TelegramMessenger/Telegram-iOS
# 点击 Fork 按钮

# 2. Clone 到本地
git clone https://github.com/YOUR_USERNAME/Telegram-iOS.git echo-ios-client
cd echo-ios-client

# 3. 添加上游仓库
git remote add upstream https://github.com/TelegramMessenger/Telegram-iOS.git

# 4. 创建 Echo 分支
git checkout -b echo-main
```

---

### 4.2 必须修改的配置

#### 4.2.1 Bundle ID

**文件**: `Telegram-iOS.xcodeproj/project.pbxproj`

```
PRODUCT_BUNDLE_IDENTIFIER = com.echo.messenger;
```

#### 4.2.2 TDLib 配置

**文件**: `submodules/TelegramCore/Sources/TelegramEngine.swift`

```swift
// 配置 TDLib 连接到 Echo 服务器
let tdlibParameters = TdlibParameters(
    useTestDc: false,
    databaseDirectory: databasePath,
    filesDirectory: filesPath,
    useFileDatabase: true,
    useChatInfoDatabase: true,
    useMessageDatabase: true,
    useSecretChats: true,
    apiId: YOUR_ECHO_API_ID,
    apiHash: "YOUR_ECHO_API_HASH",
    systemLanguageCode: "en",
    deviceModel: "iPhone",
    systemVersion: UIDevice.current.systemVersion,
    applicationVersion: appVersion,
    enableStorageOptimizer: true,
    ignoreFileNames: false,
    // 关键: 指定 Echo 服务器
    serverAddress: "api.echo.im",
    serverPort: 443
)
```

#### 4.2.3 品牌相关

**应用名称**:
- 修改 `Info.plist` 中的 `CFBundleDisplayName`

**应用图标**:
- 替换 `Images.xcassets/AppIcon.appiconset/` 下的图标

---

### 4.3 构建和测试

```bash
# 1. 安装依赖
pod install

# 2. 打开 Xcode
open Telegram-iOS.xcworkspace

# 3. 选择 Target: Telegram
# 4. 选择设备或模拟器
# 5. 点击 Run (⌘R)
```

---

## 五、客户端开发最佳实践

### 5.1 版本控制

```bash
# 创建功能分支
git checkout -b feature/echo-login

# 提交代码
git add .
git commit -m "feat: [ECHO-CLIENT-001] 实现 Echo 登录流程"

# 推送到远程
git push origin feature/echo-login

# 创建 Pull Request
```

---

### 5.2 代码注释标记

```java
// ECHO-MODIFICATION-START: [ECHO-CLIENT-001] Echo 登录流程
// 修改日期: 2026-02-01
// 修改原因: 支持邮箱和邀请码登录
// 原始代码: 只支持手机号登录

private void showEchoLoginOptions() {
    // Echo 自定义登录逻辑
}

// ECHO-MODIFICATION-END: [ECHO-CLIENT-001]
```

---

### 5.3 保持与上游同步

```bash
# 定期同步上游更新
git fetch upstream
git checkout echo-main
git merge upstream/master

# 解决冲突
# 优先保留 Echo 的修改
# 合并上游的 bug 修复和性能优化
```

---

### 5.4 测试策略

#### 单元测试
- 测试自定义功能
- 测试网络层修改
- 测试登录流程

#### 集成测试
- 测试与 Echo 服务器的通信
- 测试消息收发
- 测试多设备同步

#### 手动测试
- 完整的用户流程测试
- 边缘情况测试
- 性能测试

---

## 六、常见问题

### Q1: 如何处理 Telegram 官方的更新？

**A**: 
1. 定期 fetch 上游更新
2. 评估更新内容（bug 修复、新功能、性能优化）
3. 选择性合并（优先合并 bug 修复和性能优化）
4. 测试 Echo 功能是否受影响
5. 解决冲突，保留 Echo 的修改

---

### Q2: 如何调试网络问题？

**A**:
```bash
# Android
adb logcat | grep -E "ConnectionsManager|MTPROTO"

# iOS
# Xcode Console 查看 TDLib 日志
```

---

### Q3: 如何处理 API 不兼容？

**A**:
1. 记录客户端调用的所有 API
2. 确保服务端实现了这些 API
3. 对于未实现的 API，返回明确的错误
4. 客户端优雅降级

---

## 七、参考资源

### 官方文档
- Telegram Apps: https://telegram.org/apps
- Android 源码: https://github.com/DrKLO/Telegram
- iOS 源码: https://github.com/TelegramMessenger/Telegram-iOS
- TDLib: https://core.telegram.org/tdlib

### 开发工具
- Android Studio: https://developer.android.com/studio
- Xcode: https://developer.apple.com/xcode/

### 社区
- Telegram Developers: @devs
- Android Dev: @AndroidDev
- iOS Dev: @iOSDev

---

**文档版本**: 1.0  
**创建日期**: 2026-02-01  
**负责人**: Echo 项目团队  
**状态**: 开发指南
