# Echo Android 客户端重命名指南

## 📋 概述

本文档说明如何将官方 Telegram Android 客户端完全重命名为 Echo Android 客户端。

**重要原因**：
1. **合规性要求**：Telegram 名称在某些地区可能存在法律风险
2. **品牌统一**：与 Echo 服务端保持一致的品牌形象
3. **二次开发**：便于后续的定制化开发和维护
4. **独立性**：不依赖官方 Telegram 更新（官方 2024 年后未更新）

---

## 🎯 重命名范围

### 将要修改的内容

| 项目 | 原名称 | 新名称 |
|------|--------|--------|
| 目录名 | Telegram-master | echo-android-client |
| 包名 | org.telegram.* | com.echo.* |
| 类名前缀 | Telegram* | Echo* |
| 应用名称 | Telegram | Echo |
| 应用 ID | org.telegram.messenger | com.echo.messenger |

### 修改的文件类型
- ✅ Java 源代码 (*.java)
- ✅ Kotlin 源代码 (*.kt)
- ✅ XML 配置文件 (*.xml)
- ✅ Gradle 构建文件 (*.gradle, *.gradle.kts)
- ✅ 资源文件 (strings.xml, etc.)
- ✅ 包目录结构

---

## 🚀 使用方法

### 方法 1：自动化脚本（推荐）

```bash
# 1. 确保在项目根目录
cd /Users/jianouyang/.gemini/antigravity/scratch/vibe

# 2. 运行重命名脚本
./rebrand-telegram-to-echo.sh

# 3. 按提示确认操作
# 输入 "yes" 确认继续

# 4. 等待脚本完成
# 脚本会自动：
#   - 备份原目录到 Telegram-master.backup
#   - 重命名目录为 echo-android-client
#   - 替换所有包名和类名
#   - 更新配置文件
#   - 重组目录结构
```

### 方法 2：手动修改（不推荐）

如果需要手动修改，请参考脚本中的步骤：

1. 备份 Telegram-master 目录
2. 重命名目录
3. 批量替换包名
4. 批量替换类名
5. 更新 XML 配置
6. 更新 Gradle 配置
7. 重组包目录结构

---

## 📝 脚本执行步骤详解

### 步骤 1: 备份原目录
```bash
cp -r Telegram-master Telegram-master.backup
```
- 创建完整备份，防止出错
- 备份位置：`Telegram-master.backup/`

### 步骤 2: 重命名目录
```bash
mv Telegram-master echo-android-client
```
- 新目录名：`echo-android-client/`

### 步骤 3: 替换包名
```bash
# org.telegram → com.echo
find . -type f \( -name "*.java" -o -name "*.kt" \) -exec sed -i '' 's/org\.telegram/com.echo/g' {} +
```
- 所有 Java/Kotlin 文件中的包名
- 示例：`package org.telegram.messenger;` → `package com.echo.messenger;`

### 步骤 4: 替换类名
```bash
# Telegram → Echo
find . -type f \( -name "*.java" -o -name "*.kt" \) -exec sed -i '' 's/Telegram/Echo/g' {} +
```
- 所有类名、变量名、方法名
- 示例：`TelegramApplication` → `EchoApplication`

### 步骤 5: 更新 XML 配置
```bash
find . -type f -name "*.xml" -exec sed -i '' 's/org\.telegram/com.echo/g' {} +
find . -type f -name "*.xml" -exec sed -i '' 's/Telegram/Echo/g' {} +
```
- AndroidManifest.xml
- 布局文件
- 资源文件

### 步骤 6: 更新 Gradle 配置
```bash
find . -type f \( -name "*.gradle" -o -name "*.gradle.kts" \) -exec sed -i '' 's/org\.telegram/com.echo/g' {} +
```
- build.gradle
- settings.gradle
- 应用 ID 和依赖配置

### 步骤 7: 重组目录结构
```bash
mkdir -p TMessagesProj/src/main/java/com/echo
mv TMessagesProj/src/main/java/org/telegram/* TMessagesProj/src/main/java/com/echo/
rm -rf TMessagesProj/src/main/java/org
```
- 创建新的包目录结构
- 移动所有源文件
- 删除旧的目录结构

---

## ✅ 验证重命名结果

### 1. 检查目录结构
```bash
ls -la | grep echo-android-client
# 应该看到: echo-android-client/
```

### 2. 检查包名
```bash
grep -r "org.telegram" echo-android-client/TMessagesProj/src/main/java/
# 应该没有结果
```

### 3. 检查类名
```bash
grep -r "class Telegram" echo-android-client/TMessagesProj/src/main/java/
# 应该没有结果（除了注释）
```

### 4. 检查 AndroidManifest.xml
```bash
cat echo-android-client/TMessagesProj/src/main/AndroidManifest.xml | grep package
# 应该显示: package="com.echo.messenger"
```

---

## 🔧 后续配置

### 1. 在 Android Studio 中打开项目

```bash
# 打开 Android Studio
# File → Open → 选择 echo-android-client 目录
```

### 2. 修改服务器配置

编辑 `BuildVars.java`:
```java
// 修改 API 凭证
public static final int APP_ID = YOUR_API_ID;
public static final String APP_HASH = "YOUR_API_HASH";

// 修改服务器地址
public static final String SERVER_HOST = "your-echo-server.com";
public static final int SERVER_PORT = 443;
```

### 3. 替换应用图标

替换以下目录中的图标文件：
```
echo-android-client/TMessagesProj/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
└── mipmap-xxxhdpi/ic_launcher.png
```

### 4. 修改应用名称

编辑 `strings.xml`:
```xml
<resources>
    <string name="AppName">Echo</string>
    <string name="app_name">Echo</string>
</resources>
```

### 5. 清理和重新构建

```bash
# 在 Android Studio 中
# Build → Clean Project
# Build → Rebuild Project
```

---

## 🐛 常见问题

### Q1: 脚本执行失败怎么办？
**A**: 从备份恢复：
```bash
rm -rf echo-android-client
cp -r Telegram-master.backup Telegram-master
```

### Q2: 编译时出现包名错误？
**A**: 检查是否有遗漏的 org.telegram 引用：
```bash
grep -r "org\.telegram" echo-android-client/
```

### Q3: 应用安装后显示 Telegram？
**A**: 检查 strings.xml 中的应用名称是否已修改

### Q4: 与官方 Telegram 冲突？
**A**: 确保包名已改为 com.echo.messenger，这样可以与官方 Telegram 共存

### Q5: 如何恢复到原始状态？
**A**: 使用备份：
```bash
rm -rf echo-android-client
mv Telegram-master.backup Telegram-master
```

---

## 📊 重命名前后对比

### 目录结构
```
重命名前:
Telegram-master/
└── TMessagesProj/
    └── src/main/java/
        └── org/telegram/
            ├── messenger/
            ├── ui/
            └── ...

重命名后:
echo-android-client/
└── TMessagesProj/
    └── src/main/java/
        └── com/echo/
            ├── messenger/
            ├── ui/
            └── ...
```

### 包名示例
```java
// 重命名前
package org.telegram.messenger;
import org.telegram.ui.ActionBar;

// 重命名后
package com.echo.messenger;
import com.echo.ui.ActionBar;
```

### 类名示例
```java
// 重命名前
public class TelegramApplication extends Application {
    private static TelegramApplication instance;
}

// 重命名后
public class EchoApplication extends Application {
    private static EchoApplication instance;
}
```

---

## 🎯 下一步

完成重命名后，你可以：

1. **配置服务器连接**
   - 修改 BuildVars.java
   - 设置 Echo 服务器地址

2. **定制品牌资源**
   - 替换应用图标
   - 修改启动画面
   - 更新颜色主题

3. **二次开发**
   - 添加自定义功能
   - 修改 UI 界面
   - 集成第三方服务

4. **构建和测试**
   - 生成 APK
   - 在真机上测试
   - 发布到应用商店

---

## 📚 相关文档

- `AGENTS.md` - Echo 品牌命名规则
- `ECHO_BRANDING_STATUS.md` - 品牌重塑状态
- `DEPLOYMENT_GUIDE_MAC.md` - 部署指南
- `QUICK_START.md` - 快速开始

---

## ⚠️ 重要提醒

1. **备份重要**：执行脚本前确保已备份
2. **一次性操作**：重命名完成后不可逆
3. **完整性检查**：重命名后务必验证所有引用
4. **合规性**：确保完全移除 Telegram 引用
5. **测试充分**：在真机上充分测试后再发布

---

**最后更新**: 2026-01-29  
**维护者**: Echo 项目团队  
**状态**: 准备就绪 ✅
