# ECHO-BUG-023: 三星设备克隆应用图标问题

## 问题描述

在三星设备上安装 Echo 应用后，应用图标显示为"克隆应用"，或者出现两个图标（主应用 + 克隆应用）。

## 问题日期

2026-02-03

## 问题现象

1. 安装 Echo 后，桌面显示"Echo Beta 克隆应用"
2. 长按图标时弹出"要删除此应用吗？Echo Beta 克隆应用也会被删除"
3. 旧版本有两个图标（主+克隆），新版本只有克隆图标

## 根本原因

**问题与代码无关，是 `adb install` 命令的行为问题。**

使用 `adb install`（不带 `--user` 参数）安装 APK 时，三星设备会自动将应用安装到多个用户空间：
- User 0（主用户）：主应用
- User 95（DUAL_APP）：克隆应用

三星的 `com.samsung.android.da.daagent` 系统应用监听 `PACKAGE_ADDED` 事件，自动将应用复制到 DUAL_APP 用户空间。

## 诊断过程

### 1. 初步调查 - 检查 AndroidManifest.xml 配置

检查了 activity-alias 配置，确认 `DefaultIcon` 正确设置了 `android:enabled="true"` 和 `LAUNCHER` category。

**结果**：配置正确，问题不在此处。

### 2. 检查 Telegram 相关引用

搜索并移除了残留的 Telegram URL scheme：

| 原始值 | 修改后 | 文件 |
|-------|--------|------|
| `t.me` | 移除 | AndroidManifest.xml:258-259 |
| `tg://` | `echo://` | AndroidManifest.xml:272 |
| `tgb://` | `echob://` | AndroidManifest.xml:318 |

**结果**：问题仍然存在，证明不是 URL scheme 导致的。

### 3. 检查本地化字符串

修复了韩语和阿拉伯语中残留的 Telegram 名称：

| 文件 | 原始值 | 修改后 |
|------|--------|--------|
| `values-ko/strings.xml` | 텔레그램 | Echo |
| `values-ar/strings.xml` | تيليجرام | Echo |

**结果**：问题仍然存在，证明不是字符串资源导致的。

### 4. 检查 APK 签名和元数据

使用 `aapt dump badging` 检查 APK：
- 包名：`com.echo.messenger` ✅
- 签名：`CN=Echo, OU=EchoIM, O=Echo` ✅
- 无 Telegram 引用 ✅

**结果**：APK 配置正确。

### 5. 检查设备用户空间

```bash
adb shell pm list users
```

输出：
```
UserInfo{0:机主:4c13} running
UserInfo{95:DUAL_APP:20001010} running
UserInfo{150:Secure Folder:61010} running
```

检查 DUAL_APP 用户：
```bash
adb shell pm list packages --user 95 | grep echo
```

输出：`package:com.echo.messenger`

**结论**：Echo 被自动安装到了 DUAL_APP 用户空间！

### 6. 验证安装方式影响

| 安装方式 | 结果 |
|---------|------|
| `adb install` | ❌ 出现克隆应用 |
| `adb install --user 0` | ✅ 正常 |
| 用户通过 UI 安装 APK | ✅ 正常 |

## 解决方案

### 开发时安装

使用 `--user 0` 参数只安装到主用户：

```bash
adb install --user 0 TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk
```

### 用户安装

用户通过 UI 安装 APK 不会出现此问题，无需特殊处理。

## 修改的文件

### 1. AndroidManifest.xml

**路径**: `TMessagesProj/src/main/AndroidManifest.xml`

**修改内容**:

```diff
# 1. 为 DefaultIcon 添加 icon 属性（第 117-122 行）
  <activity-alias
      android:enabled="true"
      android:name="com.echo.messenger.DefaultIcon"
      android:targetActivity="com.echo.ui.LaunchActivity"
+     android:icon="@mipmap/ic_launcher"
+     android:roundIcon="@mipmap/ic_launcher_round"
      android:exported="true">

# 2. 移除 t.me 域名（第 258-261 行）
- <data android:host="iecho.app" android:scheme="http" />
- <data android:host="iecho.app" android:scheme="https" />
- <data android:host="t.me" android:scheme="http" />
- <data android:host="t.me" android:scheme="https" />
+ <data android:host="iecho.app" android:scheme="http" />
+ <data android:host="iecho.app" android:scheme="https" />

# 3. 更改 URL scheme（第 272 行）
- <data android:scheme="tg" />
+ <data android:scheme="echo" />

# 4. 更改 URL scheme（第 318 行）
- <data android:scheme="tgb" />
+ <data android:scheme="echob" />
```

**注意**：这些修改是为了品牌合规和移除 Telegram 引用，与克隆应用问题无关。建议保留这些修改。

### 2. values-ko/strings.xml

**路径**: `TMessagesProj/src/main/res/values-ko/strings.xml`

**修改内容**:

```diff
- <string name="AppName">텔레그램</string>
- <string name="AppNameBeta">텔레그램</string>
+ <string name="AppName">Echo</string>
+ <string name="AppNameBeta">Echo</string>
```

### 3. values-ar/strings.xml

**路径**: `TMessagesProj/src/main/res/values-ar/strings.xml`

**修改内容**:

```diff
- <string name="AppName">تيليجرام</string>
- <string name="AppNameBeta">(Beta) تيليجرام</string>
+ <string name="AppName">Echo</string>
+ <string name="AppNameBeta">Echo (Beta)</string>
```

### 4. 新增工作流文件

**路径**: `.agent/workflows/install-apk.md`

**内容**: 安装 APK 的标准流程，使用 `--user 0` 参数避免克隆问题。

## 尝试的无效方案

以下方案经过验证，**与问题无关**：

1. ❌ 移除 Telegram URL scheme (t.me, tg://, tgb://)
2. ❌ 修复本地化字符串中的 Telegram 名称
3. ❌ 为 DefaultIcon 添加 icon 属性
4. ❌ 清除 One UI Home 缓存并重启手机
5. ❌ 从 DUAL_APP 用户空间卸载应用（会导致主应用也被删除）

## 总结

| 问题 | 根本原因 | 解决方案 |
|------|---------|---------|
| 三星克隆应用图标 | `adb install` 会自动安装到 DUAL_APP 用户空间 | 使用 `adb install --user 0` |

**重要结论**：
- 此问题与代码/配置无关
- 普通用户通过 UI 安装不会遇到此问题
- 开发时使用 `adb install --user 0` 即可解决

## 验证状态

- [x] 使用 `adb install --user 0` 安装后，无克隆应用
- [x] 用户通过 UI 安装 APK 后，无克隆应用
- [x] 应用可正常启动和使用

## 相关文档

- `.agent/workflows/install-apk.md` - 安装工作流
