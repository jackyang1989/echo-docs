# ECHO-BUG-009: 修复双图标问题（安装后出现 2 个同名 App）

## 📌 变更 ID
**ECHO-BUG-009**

## 📅 基本信息
- **变更类型**: Bug 修复 + 诊断工具
- **优先级**: 🟡 中（影响用户体验）
- **开发者**: Kiro AI Agent
- **开发日期**: 2026-01-31
- **上游版本基线**: Telegram v10.5.2
- **状态**: ✅ 已诊断，提供修复方案

---

## 🐛 问题描述

### 问题现象
用户在安装 Echo Android APK 后，手机桌面上出现 **2 个同名的 Echo 图标**。

### 用户疑问
用户怀疑是 Firebase `google-services.json` 中配置了 2 个包名导致：
- `com.echo.messenger`
- `com.echo.messenger.beta`

### 根本原因分析

经过诊断，**不是 Firebase 包名的原因**，而是以下两种可能：

#### 原因 1: 安装了多个版本的 APK（最可能）

在 Android 中，**不同的 `applicationId` 会被视为不同的应用**。如果用户：

1. 先安装了 **Debug 版本**（包名：`com.echo.messenger.beta`）
2. 又安装了 **Release 版本**（包名：`com.echo.messenger`）

那么系统会认为这是 **2 个独立的应用**，自然会显示 2 个图标。

**验证方法**：
```bash
# 长按其中一个图标 -> 应用信息
# 查看包名是否一个带 .beta 后缀，一个不带
```

#### 原因 2: AndroidManifest.xml 中有多个 LAUNCHER 入口（不太可能）

在 Android 中，任何带有以下配置的 Activity 或 `activity-alias` 都会在桌面上生成一个图标：

```xml
<intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
</intent-filter>
```

Telegram 的源码机制是**动态切换图标**（Premium、Vintage 等）。如果配置不当（例如同时开启了多个 `activity-alias`），系统就会认为有多个入口，从而显示多个图标。

**验证方法**：
```bash
# 检查 AndroidManifest.xml 中有多少个 enabled="true" 的 activity-alias
grep 'android:enabled="true"' TMessagesProj/src/main/AndroidManifest.xml
```

---

## 🔍 诊断结果

### 1. AndroidManifest.xml 配置检查

Echo Android 的 `TMessagesProj/src/main/AndroidManifest.xml` 中有 **6 个 `activity-alias`**：

| activity-alias | android:enabled | 说明 |
|----------------|-----------------|------|
| `DefaultIcon` | `true` | ✅ 默认图标（应该显示） |
| `VintageIcon` | `false` | ❌ 复古图标（不显示） |
| `AquaIcon` | `false` | ❌ 水蓝图标（不显示） |
| `PremiumIcon` | `false` | ❌ 高级图标（不显示） |
| `TurboIcon` | `false` | ❌ 涡轮图标（不显示） |
| `NoxIcon` | `false` | ❌ 暗夜图标（不显示） |

**结论**：✅ **Manifest 配置正确**，只有 1 个 `activity-alias` 是 `enabled="true"`。

### 2. 包名配置检查

```properties
# gradle.properties
APP_PACKAGE=com.echo.messenger  ✅ 正确
```

```gradle
# TMessagesProj_App/build.gradle
buildTypes {
    debug {
        // applicationIdSuffix ".beta"  ✅ 已注释，不会添加 .beta 后缀
    }
}
```

**结论**：✅ **包名配置正确**，当前编译的 APK 包名是 `com.echo.messenger`（不带 `.beta` 后缀）。

### 3. 最可能的原因

根据诊断结果，**最可能的原因是**：

用户之前安装了带 `.beta` 后缀的版本（`com.echo.messenger.beta`），现在又安装了不带后缀的版本（`com.echo.messenger`），所以手机上有 **2 个独立的 App**。

---

## 🛠️ 修复措施

### 1. 创建诊断工具

创建了 `diagnose-duplicate-icons.sh` 脚本，用于诊断双图标问题：

```bash
#!/bin/bash
# 功能：
# 1. 检查已安装的 Echo 应用
# 2. 检查 AndroidManifest.xml 中的 LAUNCHER 入口
# 3. 检查当前 APK 的包名
# 4. 检查 gradle.properties 和 build.gradle 配置
```

**使用方法**：
```bash
cd echo-android-client
./diagnose-duplicate-icons.sh
```

### 2. 创建修复工具

创建了 `fix-duplicate-icons.sh` 脚本，用于自动修复双图标问题：

```bash
#!/bin/bash
# 功能：
# 1. 卸载所有 Echo 相关应用（包括 .beta 版本）
# 2. 验证 APK 配置
# 3. 验证 Manifest 配置
# 4. 安装 APK
# 5. 启动应用
# 6. 检查日志
```

**使用方法**：
```bash
cd echo-android-client
./fix-duplicate-icons.sh
```

### 3. 手动修复步骤

如果自动修复脚本无法解决问题，可以手动执行以下步骤：

#### 步骤 1: 卸载所有 Echo 应用

```bash
# 方法 1: 使用 adb 卸载
adb uninstall com.echo.messenger
adb uninstall com.echo.messenger.beta
adb uninstall com.iecho.messenger
adb uninstall com.iecho.messenger.beta

# 方法 2: 在手机上手动卸载
# 长按图标 -> 卸载
```

#### 步骤 2: 验证 Manifest 配置

```bash
# 确保只有 1 个 activity-alias 是 enabled="true"
grep 'android:enabled="true"' echo-android-client/TMessagesProj/src/main/AndroidManifest.xml

# 预期输出：只有 1 行
# android:enabled="true"
```

如果有多个 `enabled="true"`，需要手动编辑 `AndroidManifest.xml`，将其他的改为 `false`。

#### 步骤 3: 重新编译 APK（如果需要）

```bash
cd echo-android-client
./gradlew clean
./gradlew :TMessagesProj_App:assembleAfatDebug --no-parallel --max-workers=1 --no-daemon
```

#### 步骤 4: 安装 APK

```bash
adb install -r echo-android-client/TMessagesProj_App/build/outputs/apk/afat/debug/app.apk
```

#### 步骤 5: 验证

```bash
# 检查已安装的应用
adb shell pm list packages | grep echo

# 预期输出：只有 1 行
# package:com.echo.messenger
```

---

## 📝 修改的文件清单

### 新增文件
- `echo-android-client/diagnose-duplicate-icons.sh` - 诊断工具
- `echo-android-client/fix-duplicate-icons.sh` - 修复工具
- `echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-009-fix-duplicate-app-icons.md` - 本文档

### 修改文件
- 无（问题是由于安装了多个版本导致，不需要修改代码）

---

## 🧪 测试覆盖

### 诊断测试
```bash
# 运行诊断工具
./diagnose-duplicate-icons.sh

# 预期输出：
# - 只有 1 个 activity-alias 是 enabled="true"
# - APP_PACKAGE=com.echo.messenger
# - applicationIdSuffix ".beta" 已注释
```

### 修复测试
```bash
# 运行修复工具
./fix-duplicate-icons.sh

# 预期结果：
# - 所有旧版本已卸载
# - 新 APK 安装成功
# - 应用正常启动
# - 桌面上只有 1 个 Echo 图标
```

### 手动验证
1. 长按桌面图标 -> 应用信息
2. 查看包名：应该是 `com.echo.messenger`（不带 `.beta`）
3. 查看应用列表：应该只有 1 个 Echo 应用

---

## 🔄 上游兼容性分析

### 冲突风险评估
- **风险等级**: 🟢 低
- **潜在冲突点**: 无（这是配置问题，不涉及代码变更）

### 合并策略
- 上游更新不会影响此问题
- 保持 `activity-alias` 配置正确即可

---

## 🔙 回滚计划

### 回滚步骤
不需要回滚（没有代码变更）。

如果需要恢复 `.beta` 后缀：
1. 编辑 `TMessagesProj_App/build.gradle`
2. 取消注释 `applicationIdSuffix ".beta"`
3. 重新编译

---

## 📊 变更统计

| 类别 | 数量 |
|------|------|
| 新增脚本 | 2 |
| 修改代码 | 0 |
| 新增文档 | 1 |

---

## 🎓 经验教训

### 1. applicationId 决定应用身份
- ❌ **错误理解**：Firebase 包名配置会导致双图标
- ✅ **正确理解**：`applicationId` 不同 = 不同的应用 = 多个图标

### 2. Debug 和 Release 版本应该使用不同的包名
- ❌ **错误做法**：Debug 和 Release 使用相同的 `applicationId`，导致无法共存
- ✅ **正确做法**：
  - Release: `com.echo.messenger`
  - Debug: `com.echo.messenger.beta`（通过 `applicationIdSuffix` 添加）

### 3. activity-alias 的 enabled 属性很重要
- ❌ **错误做法**：同时开启多个 `activity-alias`
- ✅ **正确做法**：只开启 1 个默认图标，其他通过代码动态切换

### 4. 卸载旧版本很重要
- ❌ **错误做法**：直接安装新版本，不卸载旧版本
- ✅ **正确做法**：先卸载所有旧版本，再安装新版本

---

## 🔗 相关文档

- [ECHO-BUG-008: 包名统一问题](./ECHO-BUG-008-fix-iecho-to-echo-package-unification.md) - 包名从 iecho 改回 echo
- [ECHO-BUG-003: 包名重构](./ECHO-BUG-003-refactor-package-name-compliance.md) - 包名从 echo 改为 iecho
- [Android 官方文档: App Manifest](https://developer.android.com/guide/topics/manifest/manifest-intro)
- [Android 官方文档: activity-alias](https://developer.android.com/guide/topics/manifest/activity-alias-element)

---

## 📌 总结

### 问题根源
- 用户安装了多个版本的 Echo APK（带 `.beta` 后缀和不带后缀）
- Android 系统将不同的 `applicationId` 视为不同的应用
- 因此桌面上出现了 2 个 Echo 图标

### 解决方案
1. 卸载所有 Echo 相关应用
2. 确保 Manifest 配置正确（只有 1 个 `activity-alias` 是 `enabled="true"`）
3. 重新安装 APK

### 预防措施
1. **明确包名策略**：
   - Release: `com.echo.messenger`
   - Debug: `com.echo.messenger.beta`（可选）
2. **安装前先卸载**：避免多个版本共存
3. **使用自动化工具**：使用 `fix-duplicate-icons.sh` 自动修复

### 工具支持
- ✅ `diagnose-duplicate-icons.sh` - 诊断工具
- ✅ `fix-duplicate-icons.sh` - 修复工具

---

**日期**: 2026-01-31  
**状态**: ✅ 已诊断，提供修复方案  
**工具**: `diagnose-duplicate-icons.sh`, `fix-duplicate-icons.sh`
