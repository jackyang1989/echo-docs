# Telegram 引用清理方案

## ⚠️ 合规性要求

**硬性要求**：代码中不可以包含任何 Telegram 引用
**原因**：在中国属于违法内容，app 会被标记为恶意软件
**影响范围**：echo-android-client 源码

## 📊 当前状态

- **Telegram（大写）**: 499 处
- **telegram（小写）**: 167 处
- **总计**: 666 处

## 🎯 清理策略

### 1. 协议字段值（不可修改）

这些是 MTProto 协议规范的一部分，服务端会发送这些值：

```java
// ChatMessageCell.java 中的 webpageType 判断
"telegram_channel"
"telegram_user"
"telegram_message"
"telegram_theme"
// ... 等等
```

**解决方案**：
- 保持协议字段值不变（服务端发送的）
- 但要在注释中说明这是协议规范，不是品牌引用

### 2. 域名引用（协议规范）

```xml
<!-- AndroidManifest.xml -->
<data android:host="telegram.me" />
<data android:host="telegram.dog" />
```

**解决方案**：
- 修改为 Echo 自己的域名
- 例如：`echo.im`, `echo.app`

### 3. 类名、变量名、注释

```java
// 例如
TelegramApplication → EchoApplication
telegramConfig → echoConfig
// Telegram API → // Echo API
```

**解决方案**：
- 全部替换为 Echo

### 4. 资源文件

```xml
<item>telegram_full_app</item>
```

**解决方案**：
- 替换为 `echo_full_app`

## 📋 清理步骤

### Step 1: 备份当前代码

```bash
cd echo-android-client
git add .
git commit -m "chore: backup before telegram cleanup"
git push
```

### Step 2: 创建清理脚本

创建 `cleanup-telegram-references.sh` 脚本，分类处理：

1. **类名和变量名**：Telegram → Echo
2. **域名**：telegram.me → echo.im
3. **资源名**：telegram_full_app → echo_full_app
4. **注释**：添加说明协议字段的注释

### Step 3: 执行清理

```bash
./cleanup-telegram-references.sh
```

### Step 4: 验证清理结果

```bash
# 运行合规性检查
./tools/validate-agents-compliance.sh

# 检查编译
cd echo-android-client
./gradlew assembleDebug
```

### Step 5: 提交清理结果

```bash
git add .
git commit -m "fix: remove all telegram references for compliance

- 替换所有类名、变量名中的 Telegram → Echo
- 修改域名 telegram.me → echo.im
- 更新资源名 telegram_full_app → echo_full_app
- 添加协议字段说明注释

合规性要求：代码中不可包含 Telegram 引用
"
git push
```

## 🔍 特殊处理

### 协议字段值的处理

对于协议规范的字段值（如 `"telegram_channel"`），我们需要：

1. **保持字段值不变**（服务端会发送）
2. **添加清晰的注释说明**

```java
// MTProto 协议规范字段值（由服务端定义，不可修改）
// 这些是协议层面的类型标识，不是品牌引用
if ("telegram_channel".equals(webpageType)) {
    // 处理频道类型的网页预览
}
```

### 域名的处理

需要注册 Echo 自己的域名：

- `echo.im` - 主域名
- `echo.app` - 备用域名

然后在 AndroidManifest.xml 中替换：

```xml
<data android:host="echo.im" android:scheme="http"/>
<data android:host="echo.im" android:scheme="https"/>
<data android:host="echo.app" android:scheme="http"/>
<data android:host="echo.app" android:scheme="https"/>
```

## ⚠️ 风险评估

### 高风险项

1. **协议字段值修改** - 可能导致与服务端不兼容
2. **深层链接修改** - 可能影响分享功能

### 低风险项

1. **类名修改** - 只影响代码可读性
2. **注释修改** - 无影响
3. **资源名修改** - 只需同步更新引用

## 📝 清理清单

- [ ] 创建清理脚本
- [ ] 备份当前代码
- [ ] 清理类名和变量名
- [ ] 清理域名引用
- [ ] 清理资源名
- [ ] 添加协议字段注释
- [ ] 运行合规性检查
- [ ] 编译验证
- [ ] 提交清理结果

## 🚀 下一步

1. 用户确认清理方案
2. 创建清理脚本
3. 执行清理
4. 验证结果

---

**创建时间**: 2026-02-02  
**状态**: 待执行
