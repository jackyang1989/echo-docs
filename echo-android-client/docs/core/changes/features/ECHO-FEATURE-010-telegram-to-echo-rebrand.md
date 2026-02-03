# ECHO-FEATURE-010: Telegram to Echo 品牌重塑

---

## 📋 基本信息

| 属性 | 值 |
|------|-----|
| **变更 ID** | ECHO-FEATURE-010 |
| **变更类型** | 品牌重塑 (Rebrand) |
| **创建日期** | 2026-01-31 |
| **最后更新** | 2026-01-31 |
| **状态** | 🟡 进行中 |
| **优先级** | 🔴 高 |

---

## 🎯 变更目标

将 Echo Android 客户端的所有 "Telegram" 引用替换为 "Echo"，确保：
1. 法律合规性 - 移除所有上游品牌引用
2. 品牌一致性 - 统一使用 Echo 品牌
3. 编译通过 - APK 可正常构建
4. 功能正常 - App 可正常安装运行

---

## 📊 替换策略

### 核心替换规则

| 原始值 | 替换值 | 应用范围 |
|--------|--------|----------|
| `org.telegram` | `com.echo` | Java 包名、JNI 路径 |
| `Telegram` | `Echo` | 类名、字符串、常量 |
| `telegram` | `echo` | 变量名、包名、资源ID |
| `TELEGRAM` | `ECHO` | 常量、枚举 |
| `tg://` | `echo://` | URL Scheme |
| `t.me` | (保留) | 外部链接，暂不替换 |

### 不替换的内容

| 内容类型 | 原因 |
|----------|------|
| 第三方库代码 | 如 WebRTC、ExoPlayer 等 |
| API 协议常量 | MTProto 协议相关 |
| 版权声明中的历史记录 | 保留历史溯源 |
| 文档中的比较说明 | 如 "与 Telegram 相比" |

---

## 📈 替换记录

### 阶段一：包名替换（已完成 ✅）

#### Java 源码包名
- **变更前**: `org.telegram.messenger`, `org.telegram.ui`, `org.telegram.tgnet`
- **变更后**: `com.echo.messenger`, `com.echo.ui`, `com.echo.tgnet`

**修改文件**:
- `TMessagesProj/src/main/java/org/telegram/**` → `TMessagesProj/src/main/java/com/echo/**`
- 所有 Java 文件的 `package` 声明
- 所有 Java 文件的 `import` 语句

#### JNI 函数命名
**关键修复**: JNI 函数名必须与 Java 包名路径完全匹配

| 文件 | 原始 | 修改后 |
|------|------|--------|
| `jni/tgnet/BuffersStorage.cpp` | `Java_org_telegram_tgnet_*` | `Java_com_echo_tgnet_*` |
| `jni/tgnet/ConnectionsManager.cpp` | `Java_org_telegram_tgnet_*` | `Java_com_echo_tgnet_*` |
| `jni/tgnet/NativeByteBuffer.cpp` | `Java_org_telegram_tgnet_*` | `Java_com_echo_tgnet_*` |
| `jni/sqlite_*.c` | `Java_org_telegram_SQLite_*` | `Java_com_echo_SQLite_*` |

### 阶段二：UI 字符串替换（已完成 ✅）

#### strings.xml 资源文件
**修改文件**: `TMessagesProj/src/main/res/values/strings.xml`

| 原始资源名 | 新资源名 |
|-----------|----------|
| `TelegramPremium` | `EchoPremium` |
| `TelegramStars` | `EchoStars` |
| `TelegramTones` | `EchoTones` |
| `UpdateTelegram` | `UpdateEcho` |
| `TelegramBusiness` | `EchoBusiness` |

#### 用户可见字符串
- 所有 "Telegram" 文字替换为 "Echo"
- 某些语言资源可能有遗漏（如阿拉伯语、韩语）

### 阶段三：资源 ID 替换（已完成 ✅）

#### drawable 资源
- `msg_fave_telegram` → `msg_fave_echo`
- Logo 和图标文件保留原文件名（内容已替换）

#### ID 和引用
- `R.string.TelegramPremium` → `R.string.EchoPremium`
- `R.drawable.msg_fave_telegram` → `R.drawable.msg_fave_echo`

---

## 🐛 编译错误及修复方案

### 错误 1: JNI 函数未找到

**错误信息**:
```
java.lang.UnsatisfiedLinkError: No implementation found for void com.echo.tgnet.ConnectionsManager.native_init(...)
```

**原因**: JNI C++ 函数名使用 `org_telegram` 路径，但 Java 包已改为 `com.echo`

**修复方案**:
```cpp
// 修改前
JNIEXPORT void Java_org_telegram_tgnet_ConnectionsManager_native_1init(...)

// 修改后
JNIEXPORT void Java_com_echo_tgnet_ConnectionsManager_native_1init(...)
```

**修改文件**:
- `TMessagesProj/jni/tgnet/BuffersStorage.cpp`
- `TMessagesProj/jni/tgnet/ConnectionsManager.cpp`
- `TMessagesProj/jni/tgnet/NativeByteBuffer.cpp`
- `TMessagesProj/jni/sqlite_*.c`

### 错误 2: 资源 ID 未找到

**错误信息**:
```
error: cannot find symbol R.string.TelegramPremium
```

**原因**: Java 代码引用了已重命名的字符串资源

**修复方案**: 
1. 在 `strings.xml` 中重命名资源
2. 更新所有 Java 文件中的资源引用

### 错误 3: 包名损坏

**错误信息**:
```
error: package org.iecho.appssenger does not exist
```

**原因**: sed 替换时产生的错误包名 (`org.telegram` → `org.iecho.appsenger`)

**修复方案**:
```bash
# 修正错误的包名
sed -i '' 's/org\.iecho\.appssenger/com.echo.messenger/g' *.java
```

---

## ⏳ 待替换内容

### 优先级：高 🔴

| 文件/位置 | 当前状态 | 说明 |
|----------|----------|------|
| 多语言 strings.xml | 部分替换 | 阿拉伯语、韩语等仍有 "تيليجرام" / "텔레그램" |
| shortcuts.xml URL scheme | 未替换 | 仍使用 `tg://` |
| AndroidManifest intent-filter | 未替换 | `tg://` scheme |

### 优先级：中 🟡

| 文件/位置 | 当前状态 | 说明 |
|----------|----------|------|
| Java 代码注释 | 部分保留 | 约 666 处仍含 "telegram" |
| 版权声明 | 保留 | 法律要求保留原版权 |
| API 常量 | 保留 | MTProto 协议相关 |

### 优先级：低 🟢

| 文件/位置 | 当前状态 | 说明 |
|----------|----------|------|
| 测试代码 | 未检查 | 测试类中的字符串 |
| 构建脚本 | 已完成 | gradle 文件 |

---

## 🔧 技术实现细节

### 测试验证码绕过

**目的**: 因无后端配置，添加测试模式允许使用固定验证码

**修改文件**: `TMessagesProj/src/main/java/com/echo/ui/LoginActivity.java`

**修改位置**: `onNextPressed()` 方法, 约 line 4816

**代码变更**:
```java
// === ECHO TEST MODE: 硬编码验证码绕过 ===
// 用于测试目的，输入 123456 可跳过验证
if ("123456".equals(code)) {
    // 测试模式：直接跳过验证，设置假登录状态
    AndroidUtilities.runOnUIThread(() -> {
        try {
            AlertDialog.Builder builder = new AlertDialog.Builder(getParentActivity());
            builder.setTitle("Echo 测试模式");
            builder.setMessage("验证码 123456 已识别（测试模式）\n\n注意：这只是测试绕过，真正的登录需要配置后端服务器。");
            builder.setPositiveButton("确定", null);
            showDialog(builder.create());
        } catch (Exception e) {
            FileLog.e(e);
        }
    });
    nextPressed = false;
    return;
}
// === END ECHO TEST MODE ===
```

---

## 🐞 已知问题

### BUG-001: 双图标问题 🔴 未解决

**症状**: 安装后出现两个 "Echo Beta" 图标，其中一个右下角有圆形标记（快捷方式）

**已尝试修复**:
1. ✅ 删除 AndroidManifest.xml 中的 5 个备用图标 activity-alias
2. ✅ 禁用 `MediaDataController.buildShortcuts()` 方法
3. ❌ 问题仍然存在

**分析**:
- APK 内只有 1 个 LAUNCHER 活动（已验证）
- 禁用了动态快捷方式创建
- 可能是 Samsung 设备特有问题或其他未发现的快捷方式创建代码

**下一步**:
- 搜索其他创建快捷方式的代码
- 检查 `NotificationsController` 等类
- 检查 Samsung 特有功能

---

## 📁 修改文件清单

### Java 文件（主要）
- `com/echo/ui/LoginActivity.java` - 测试验证码绕过
- `com/echo/messenger/MediaDataController.java` - 禁用快捷方式
- 全部 `com/echo/**/*.java` - 包名和导入替换

### JNI 文件
- `jni/tgnet/BuffersStorage.cpp`
- `jni/tgnet/ConnectionsManager.cpp`
- `jni/tgnet/NativeByteBuffer.cpp`
- `jni/sqlite_cursor.c`
- `jni/sqlite_database.c`
- `jni/sqlite_statement.c`

### 资源文件
- `res/values/strings.xml`
- `res/xml/shortcuts.xml`
- `AndroidManifest.xml`

### 配置文件
- `TMessagesProj/build.gradle`
- `TMessagesProj_App/build.gradle`
- `gradle.properties`

---

## 📋 回滚计划

如需回滚：
1. 从 Git 恢复 `AndroidManifest.xml.bak`
2. 重新运行原始包名替换脚本（反向）
3. 重新编译验证

---

## 🔗 相关文档

- [AGENTS.md](../../../../AGENTS.md) - 品牌命名规则
- [ECHO-BUG-008](../bugfixes/ECHO-BUG-008-jni-package-mismatch.md) - JNI 包名不匹配问题

---

## 📝 更新历史

| 日期 | 更新内容 |
|------|----------|
| 2026-01-31 | 初始文档创建，记录品牌重塑过程 |
| 2026-01-31 | 添加双图标问题分析 |
