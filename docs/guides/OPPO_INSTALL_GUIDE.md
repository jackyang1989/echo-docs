# 📱 Echo APK 安装指南 - OPPO 手机

**目标**: 将 Echo APK 安装到 OPPO 手机上

---

## 🚀 快速安装（推荐）

### 方法 1: 使用自动安装脚本

```bash
./install-echo-to-oppo.sh
```

脚本会自动：
- ✅ 检查 adb 是否安装
- ✅ 检查设备连接
- ✅ 显示设备信息
- ✅ 卸载旧版本（如果存在）
- ✅ 安装新版本
- ✅ 启动应用

---

## 📋 前置准备

### 1. 安装 adb（如果未安装）

**macOS**:
```bash
brew install android-platform-tools
```

**验证安装**:
```bash
adb version
```

### 2. 开启 OPPO 手机的 USB 调试

**步骤**:
1. 打开 **设置** → **关于手机**
2. 连续点击 **版本号** 7 次（开启开发者模式）
3. 返回 → **其他设置** → **开发者选项**
4. 开启 **USB 调试**
5. 开启 **USB 安装**（如果有）

### 3. 连接手机到电脑

1. 使用 USB 数据线连接手机和电脑
2. 手机上选择 **文件传输** 模式
3. 手机上弹出 USB 调试授权提示时，点击 **允许**
4. 勾选 **始终允许这台电脑进行调试**

### 4. 验证连接

```bash
adb devices
```

应该看到类似输出：
```
List of devices attached
XXXXXXXX    device
```

---

## 🔧 手动安装（备选方案）

### 方法 2: 使用 adb 命令

```bash
# 1. 检查设备连接
adb devices

# 2. 安装 APK
adb install -r -t echo-android-client/TMessagesProj_App/build/outputs/apk/echoMinimal/debug/app.apk

# 3. 启动应用
adb shell am start -n com.echo.messenger/.LaunchActivity
```

### 方法 3: 传输到手机后安装

```bash
# 1. 将 APK 传输到手机
adb push echo-android-client/TMessagesProj_App/build/outputs/apk/echoMinimal/debug/app.apk /sdcard/Download/echo.apk

# 2. 在手机上打开文件管理器
# 3. 找到 Download 文件夹
# 4. 点击 echo.apk 安装
```

---

## ⚠️ OPPO 特殊设置

### 如果安装失败

OPPO 手机有严格的安全设置，可能需要额外配置：

#### 1. 允许安装未知来源应用

**路径**: 设置 → 其他设置 → 设备与隐私 → 安装外部来源应用

**操作**: 找到 **文件管理** 或 **Package Installer**，允许安装

#### 2. 关闭纯净后台

**路径**: 设置 → 电池 → 应用耗电管理

**操作**: 找到 Echo，关闭 **后台冻结**

#### 3. 允许自启动

**路径**: 设置 → 应用管理 → 应用列表 → Echo → 权限

**操作**: 允许 **自启动**

#### 4. 关闭应用行为记录

**路径**: 设置 → 其他设置 → 开发者选项

**操作**: 关闭 **监控 ADB 安装应用**（如果有）

---

## 🔍 故障排查

### 问题 1: adb devices 显示 unauthorized

**原因**: 手机未授权 USB 调试

**解决**:
1. 断开 USB 连接
2. 手机上：设置 → 开发者选项 → 撤销 USB 调试授权
3. 重新连接 USB
4. 手机上点击 **允许**

### 问题 2: adb devices 显示 offline

**原因**: adb 连接异常

**解决**:
```bash
adb kill-server
adb start-server
adb devices
```

### 问题 3: 安装失败 - INSTALL_FAILED_UPDATE_INCOMPATIBLE

**原因**: 已安装的应用签名不同

**解决**:
```bash
# 卸载旧版本
adb uninstall com.echo.messenger

# 重新安装
./install-echo-to-oppo.sh
```

### 问题 4: 安装失败 - INSTALL_FAILED_INSUFFICIENT_STORAGE

**原因**: 手机存储空间不足

**解决**:
1. 清理手机存储空间
2. 删除不需要的应用
3. 清理缓存

### 问题 5: 安装成功但无法启动

**原因**: OPPO 安全限制

**解决**:
1. 设置 → 应用管理 → Echo
2. 允许所有权限
3. 关闭后台冻结
4. 允许自启动

---

## 📱 安装后配置

### 1. 首次启动

1. 打开 Echo 应用
2. 输入手机号: `8618124944249`
3. 点击 **下一步**

### 2. 获取验证码

验证码会在服务器日志中显示：

```bash
# 查看 Auth 服务日志
tail -f echo-server/auth.log
```

你会看到类似输出：
```
📱 [Auth] 验证码已生成: phone=8618124944249, code=12345 (开发模式)
```

### 3. 输入验证码

在 Echo 应用中输入验证码（如 `12345`）

### 4. 完成注册

输入用户名，完成注册

---

## 🎯 验证安装

### 检查应用是否安装

```bash
adb shell pm list packages | grep echo
```

应该看到：
```
package:com.echo.messenger
```

### 查看应用信息

```bash
adb shell dumpsys package com.echo.messenger | grep version
```

### 查看应用日志

```bash
adb logcat | grep -E "Echo|tmessages"
```

---

## 🔄 更新应用

### 方法 1: 覆盖安装

```bash
./install-echo-to-oppo.sh
```

脚本会自动处理覆盖安装

### 方法 2: 手动更新

```bash
# 1. 卸载旧版本
adb uninstall com.echo.messenger

# 2. 安装新版本
adb install -r -t echo-android-client/TMessagesProj_App/build/outputs/apk/echoMinimal/debug/app.apk
```

---

## 📝 常用命令

### 安装相关

```bash
# 安装 APK
adb install -r -t <apk_path>

# 卸载应用
adb uninstall com.echo.messenger

# 查看已安装应用
adb shell pm list packages | grep echo
```

### 调试相关

```bash
# 查看日志
adb logcat | grep Echo

# 清除应用数据
adb shell pm clear com.echo.messenger

# 启动应用
adb shell am start -n com.echo.messenger/.LaunchActivity

# 停止应用
adb shell am force-stop com.echo.messenger
```

### 文件传输

```bash
# 传输文件到手机
adb push <local_file> /sdcard/Download/

# 从手机拉取文件
adb pull /sdcard/Download/<file> .

# 查看手机文件
adb shell ls /sdcard/Download/
```

---

## 🎉 完成！

安装完成后，你应该能够：

- ✅ 在手机上看到 Echo 应用图标
- ✅ 打开应用并看到登录界面
- ✅ 输入手机号并接收验证码
- ✅ 成功登录并使用 Echo

---

## 📞 需要帮助？

如果遇到问题：

1. 查看本文档的 **故障排查** 章节
2. 查看服务器日志：`tail -f echo-server/gateway.log`
3. 查看应用日志：`adb logcat | grep Echo`

---

**祝你使用愉快！** 🎊

