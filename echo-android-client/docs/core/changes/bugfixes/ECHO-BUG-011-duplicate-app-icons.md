# ECHO-BUG-011: 安装后出现双图标

---

## 📋 基本信息

| 属性 | 值 |
|------|-----|
| **Bug ID** | ECHO-BUG-011 |
| **发现日期** | 2026-01-31 |
| **最后更新** | 2026-01-31 |
| **状态** | 🔴 未解决 |
| **优先级** | 🔴 高 |
| **影响范围** | 用户体验 |

---

## 🐛 问题描述

安装 Echo APK 后，设备上出现两个 "Echo Beta" 图标：
1. **正常图标** - 应用主图标
2. **快捷方式图标** - 右下角有圆形标记（快捷方式徽章）

两个图标名称相同，点击都打开同一个应用。

---

## 🔍 诊断记录

### 1. APK Manifest 分析

**检查命令**:
```bash
~/Library/Android/sdk/build-tools/35.0.0/aapt2 dump xmltree app.apk --file AndroidManifest.xml | grep -c "android.intent.category.LAUNCHER"
```

**结果**: APK 内只有 **1 个 LAUNCHER** 活动

**activity-alias 状态**:
| 别名 | enabled 状态 |
|------|-------------|
| DefaultIcon | true ✅ |
| VintageIcon | false (已删除) |
| AquaIcon | false (已删除) |
| PremiumIcon | false (已删除) |
| TurboIcon | false (已删除) |
| NoxIcon | false (已删除) |

### 2. 系统 Launcher 查询

**检查命令**:
```bash
adb shell "pm query-activities --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER | grep echo"
```

**结果**: 只有 `com.echo.messenger/.DefaultIcon`

### 3. 已尝试修复

| 尝试 | 操作 | 结果 |
|------|------|------|
| 1 | 删除 5 个备用图标 activity-alias | ❌ 失败 |
| 2 | 禁用 `MediaDataController.buildShortcuts()` | ❌ 失败 |
| 3 | 卸载后清理并重新安装 | ❌ 失败 |

---


## � 尝试方案记录 (已全部回滚)

以下方案均尝试解决 Samsung 设备上的“应用分身/双图标”问题，但均未成功或被否决：

### 1. 禁用备用 Alias (Phase 1)
- **操作**: 在 Manifest 中注释掉除 `DefaultIcon` 外的所有 `activity-alias`。
- **结果**: 失败。双图标依然存在（一个正常，一个带角标）。

### 2. 禁用动态快捷方式代码 (2026-01-31)
- **操作**: 修改 `MediaDataController.buildShortcuts` 强制返回。
- **结果**: 用户否决。虽然可能解决图标问题，但导致长按菜单功能丢失，不可接受。

### 3. 修改动态快捷方式 Intent (2026-01-31)
- **操作**: 修改 `buildShortcuts` 创建的 Intent，使其指向 `DefaultIcon` 而非 `LaunchActivity`。
- **结果**: 失败。可能因为系统缓存或逻辑无效。

### 4. 修正 shortcuts.xml Target (2026-01-31)
- **操作**: 将 `shortcuts.xml` 中的 `share-target` 指向修改为 `DefaultIcon`。
- **结果**: 失败。双图标依旧。

### 5. 诊断：禁用静态 Shortcuts (2026-01-31)
- **操作**: 在 Manifest 中注释掉 `android.app.shortcuts` meta-data。
- **结果**: 失败。即使没有静态 shortcuts 引用，双图标（克隆应用）依然存在。这排除了 `shortcuts.xml` 是根本原因的可能性。

### 6. 移除 LaunchActivity MAIN Action (2026-01-31)
- **操作**: 移除 `LaunchActivity` 的 `MAIN` intent-filter，仅保留 Alias 作为入口。
- **结果**: 失败/用户反馈无效。

### 7. 彻底移除 Alias (Plan F)
- **操作**: 移除 `DefaultIcon` alias，直接将 `LaunchActivity` 设为 Launcher。
- **结果**: 放弃执行/用户失去信心要求回滚。

## 结论
**问题根源确认**: Samsung OneUI Launcher 特定问题。
- **OPPO 测试**: 安装还原版代码后，仅显示 **1 个图标** (正常)。
- **Samsung 测试**: 同样代码显示 **2 个图标** (App + Clone)。

这证实了当前代码结构（Activity + Alias）在标准 Android 系统上是正确的。Samsung 系统可能对非白名单包名（`com.echo.messenger`）的 `LaunchActivity` (带 MAIN Action) 进行了激进的入口扫描。

**决策**: 鉴于修改 Manifest 结构（移除 Alias）可能导致其他副作用且被用户回滚，目前保持代码为**官方原版配置**。此问题被标记为 Samsung 设备特定行为，暂不进一步修复。

1. **其他快捷方式创建代码**
   - `NotificationsController` 中可能有快捷方式创建
   - `ContactsController` 可能在添加联系人时创建快捷方式
   - 首次启动时的初始化代码

2. **Samsung 特有功能**
   - Game Launcher 自动创建快捷方式
   - Edge Panel 功能
   - Good Lock 模块

3. **installLocation 设置**
   - 检查 `android:installLocation` 是否影响

4. **shortcutManagerCompat**
   - 检查是否有其他地方调用 `pushDynamicShortcut`

---

## 🔗 相关文件

- [ECHO-FEATURE-010](./ECHO-FEATURE-010-telegram-to-echo-rebrand.md) - 品牌重塑变更
- `MediaDataController.java` line 4934
- `AndroidManifest.xml`

---

## 📝 更新历史

| 日期 | 更新内容 |
|------|----------|
| 2026-01-31 | 创建 bug 记录 |
| 2026-01-31 | 记录两次修复尝试，均失败 |
