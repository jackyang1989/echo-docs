# Telegram 引用详细分析

## 📊 统计概览

- **总计**: 666 处引用
- **协议字段值**: ~60 处（webpageType）
- **变量名/字段名**: ~80 处
- **包名/常量**: ~20 处
- **域名**: 4 处
- **XML 资源**: 1 处
- **其他**: ~500 处（主要是 Telegram 类名）

## 🔍 详细分类

### 1. 协议字段值（⚠️ 高风险 - 需要服务端配合）

这些是 MTProto 协议中的 `webpageType` 字段值，**由服务端发送**：

```java
"telegram_story"          // 故事类型
"telegram_voicechat"      // 语音聊天
"telegram_videochat"      // 视频聊天
"telegram_user"           // 用户资料
"telegram_channel"        // 频道
"telegram_theme"          // 主题
"telegram_background"     // 背景
"telegram_stickerset"     // 贴纸集
// ... 等 30 种类型
```

**影响分析**：
- ❌ **不能直接修改** - 服务端会发送这些值
- ✅ **可以映射** - 客户端接收后映射到 Echo 类型

**解决方案**：
```java
// 创建映射函数
private String mapWebpageType(String serverType) {
    // 服务端发送的协议字段值保持不变
    // 但在客户端内部使用 Echo 命名
    if ("telegram_channel".equals(serverType)) {
        return "echo_channel";
    }
    // ... 其他映射
    return serverType;
}
```

### 2. 变量名和字段名（✅ 低风险 - 可以安全替换）

```java
telegramPath              → echoPath
telegramCacheTextView     → echoCacheTextView
telegramDatabaseTextView  → echoDatabaseTextView
telegramAntispamUserId    → echoAntispamUserId
telegramAntispamGroupSizeMin → echoAntispamGroupSizeMin
telegramMaskProvider      → echoMaskProvider
telegramAudioPlayer       → echoAudioPlayer
```

**影响分析**：
- ✅ **可以安全替换** - 只是变量名
- ✅ **不影响功能** - 纯代码层面

### 3. 包名和常量（⚠️ 中风险 - 需要检查依赖）

```java
// Intent Action（用于组件通信）
org.telegram.android.musicplayer.play     → com.echo.android.musicplayer.play
org.telegram.android.musicplayer.pause    → com.echo.android.musicplayer.pause
org.telegram.android.musicplayer.next     → com.echo.android.musicplayer.next
// ... 等

// Deep Link Scheme
org.telegram.key          → com.echo.key
org.telegram.account      → com.echo.account
org.telegram.passport     → com.echo.passport
```

**影响分析**：
- ⚠️ **需要检查** - 可能被其他组件引用
- ⚠️ **需要同步修改** - AndroidManifest.xml 中的声明

**解决方案**：
1. 全局搜索每个常量的使用位置
2. 同步修改所有引用
3. 更新 AndroidManifest.xml

### 4. 域名（⚠️ 中风险 - 需要配置服务端）

```xml
<!-- AndroidManifest.xml -->
<data android:host="telegram.me" />
<data android:host="telegram.dog" />
```

**影响分析**：
- ⚠️ **需要服务端支持** - 服务端需要配置新域名
- ⚠️ **影响分享功能** - 分享链接会使用这个域名

**解决方案**：
1. 注册 Echo 域名：`echo.im`, `echo.app`
2. 服务端配置支持新域名
3. 客户端修改 AndroidManifest.xml

### 5. XML 资源（✅ 低风险 - 可以安全替换）

```xml
<item>telegram_full_app</item>
```

**影响分析**：
- ✅ **可以安全替换** - 只是资源名
- ✅ **不影响功能** - 需要同步修改引用

**解决方案**：
```xml
<item>echo_full_app</item>
```

### 6. 类名（✅ 低风险 - 但数量巨大）

```java
TelegramApplication       → EchoApplication
TelegramConfig           → EchoConfig
TelegramService          → EchoService
// ... 约 500 个类
```

**影响分析**：
- ✅ **可以安全替换** - 只是类名
- ⚠️ **数量巨大** - 需要批量处理

## 🎯 推荐清理策略

### 阶段 1：低风险项（立即执行）

1. ✅ **变量名和字段名** - 全部替换为 echo
2. ✅ **XML 资源名** - telegram_full_app → echo_full_app
3. ✅ **注释** - 添加说明

**预计影响**：无，纯代码层面

### 阶段 2：中风险项（需要测试）

1. ⚠️ **包名和常量** - 替换 Intent Action 和 Deep Link
2. ⚠️ **域名** - 修改为 echo.im（需要服务端配合）

**预计影响**：
- 分享功能需要测试
- 组件通信需要验证

### 阶段 3：高风险项（需要服务端配合）

1. ⚠️ **协议字段值** - 创建映射函数

**预计影响**：
- 需要服务端确认协议字段
- 可能需要服务端同步修改

### 阶段 4：大规模替换（最后执行）

1. ✅ **类名** - 批量替换 Telegram → Echo

**预计影响**：
- 代码量大，需要仔细测试
- 可能影响编译

## 📋 详细执行计划

### Step 1: 创建映射函数（处理协议字段）

```java
// 新建 ProtocolMapper.java
public class ProtocolMapper {
    // 服务端协议字段 → 客户端内部类型
    private static final Map<String, String> WEBPAGE_TYPE_MAP = new HashMap<>();
    
    static {
        // 保持服务端协议字段不变，但映射到 Echo 类型
        WEBPAGE_TYPE_MAP.put("telegram_channel", "echo_channel");
        WEBPAGE_TYPE_MAP.put("telegram_user", "echo_user");
        WEBPAGE_TYPE_MAP.put("telegram_theme", "echo_theme");
        // ... 添加所有映射
    }
    
    public static String mapWebpageType(String serverType) {
        return WEBPAGE_TYPE_MAP.getOrDefault(serverType, serverType);
    }
}
```

### Step 2: 替换变量名和字段名

```bash
# 创建替换脚本
cat > cleanup-variables.sh << 'EOF'
#!/bin/bash

cd echo-android-client/TMessagesProj/src

# 替换变量名
find . -name "*.java" -type f -exec sed -i '' \
  -e 's/telegramPath/echoPath/g' \
  -e 's/telegramCacheTextView/echoCacheTextView/g' \
  -e 's/telegramDatabaseTextView/echoDatabaseTextView/g' \
  -e 's/telegramAntispamUserId/echoAntispamUserId/g' \
  -e 's/telegramAntispamGroupSizeMin/echoAntispamGroupSizeMin/g' \
  -e 's/telegramMaskProvider/echoMaskProvider/g' \
  -e 's/telegramAudioPlayer/echoAudioPlayer/g' \
  {} +

echo "✓ 变量名替换完成"
EOF

chmod +x cleanup-variables.sh
```

### Step 3: 替换包名和常量

```bash
# 替换 Intent Action
find . -name "*.java" -type f -exec sed -i '' \
  -e 's/org\.telegram\.android/com.echo.android/g' \
  -e 's/org\.telegram\.key/com.echo.key/g' \
  -e 's/org\.telegram\.account/com.echo.account/g' \
  -e 's/org\.telegram\.passport/com.echo.passport/g' \
  {} +
```

### Step 4: 修改域名

```xml
<!-- AndroidManifest.xml -->
<!-- 修改前 -->
<data android:host="telegram.me" android:scheme="http"/>
<data android:host="telegram.dog" android:scheme="https"/>

<!-- 修改后 -->
<data android:host="echo.im" android:scheme="http"/>
<data android:host="echo.app" android:scheme="https"/>
```

### Step 5: 替换 XML 资源

```bash
find . -name "*.xml" -type f -exec sed -i '' \
  -e 's/telegram_full_app/echo_full_app/g' \
  {} +
```

### Step 6: 批量替换类名

```bash
# 这个需要最后执行，因为数量巨大
find . -name "*.java" -type f -exec sed -i '' \
  -e 's/Telegram/Echo/g' \
  {} +
```

## ⚠️ 风险评估

### 高风险操作

1. **协议字段值修改** - 可能导致与服务端不兼容
   - **缓解措施**：使用映射函数，保持协议字段不变

2. **域名修改** - 可能影响分享功能
   - **缓解措施**：服务端同步配置新域名

### 中风险操作

1. **包名修改** - 可能影响组件通信
   - **缓解措施**：全局搜索，同步修改所有引用

2. **类名批量替换** - 可能影响编译
   - **缓解措施**：分批替换，每次替换后编译验证

### 低风险操作

1. **变量名替换** - 不影响功能
2. **XML 资源替换** - 不影响功能

## 🧪 测试计划

### 编译测试

```bash
cd echo-android-client
./gradlew clean
./gradlew assembleDebug
```

### 功能测试

1. ✅ 登录功能
2. ✅ 消息发送/接收
3. ✅ 分享功能（测试新域名）
4. ✅ 网页预览（测试协议字段映射）
5. ✅ 音乐播放器（测试 Intent Action）
6. ✅ Deep Link（测试新 scheme）

### 合规性测试

```bash
./tools/validate-agents-compliance.sh
```

## 📝 建议

### 推荐方案：分阶段执行

1. **第一阶段**（立即执行）：
   - 替换变量名和字段名
   - 替换 XML 资源名
   - 添加协议字段映射函数

2. **第二阶段**（需要服务端配合）：
   - 修改域名（需要服务端配置）
   - 替换包名和常量

3. **第三阶段**（最后执行）：
   - 批量替换类名

### 保守方案：只替换必要项

如果担心风险，可以只替换：
- ✅ 变量名和字段名
- ✅ XML 资源名
- ✅ 注释

保留：
- ⚠️ 协议字段值（使用映射）
- ⚠️ 类名（暂时保留）

## 🤔 需要确认的问题

1. **服务端是否支持新域名**？（echo.im, echo.app）
2. **服务端的协议字段值是什么**？（是否也是 telegram_xxx）
3. **是否需要立即清理所有引用**？还是可以分阶段？
4. **是否有测试环境**？可以先在测试环境验证

---

**创建时间**: 2026-02-02  
**状态**: 待确认
