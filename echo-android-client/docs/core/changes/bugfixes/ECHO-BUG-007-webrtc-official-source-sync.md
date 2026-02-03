# [ECHO-BUG-007] WebRTC 官方源码同步与导入路径修正

## 1. 问题描述

在之前的 WebRTC 补丁（ECHO-BUG-006）之后，编译仍然失败，共有 **50 个编译错误**。根本原因是：
1. `org.webrtc` 目录被污染，包含修改过的/不完整的源码
2. `google-webrtc` Maven 依赖与本地源码冲突
3. 官方 Telegram 源码与 Echo 重构后的包结构之间存在导入路径不匹配

**影响：**
- Android 客户端编译失败，共 50 个错误
- WebRTC 相关功能（视频通话、屏幕共享）无法使用

## 2. 根本原因分析

### 2.1 被污染的 WebRTC 源码
`org.webrtc` 目录包含以下混合内容：
- 原始 Telegram 源码
- 之前修复尝试的部分补丁
- 签名错误的修改文件

### 2.2 导入路径不匹配
官方 Telegram WebRTC 源码使用：
```java
import org.telegram.messenger.FileLog;
import org.telegram.messenger.AndroidUtilities;
import org.telegram.ui.Stories.LivePlayer;
```

Echo 项目使用：
```java
package com.iecho.messenger;  // 核心消息类
package com.echo.ui;          // UI 组件
```

### 2.3 缺少对象引用
`GroupCallMiniTextureView.java` 调用 `getRenderBufferBitmap()` 时没有指定对象：
```java
// 错误：裸方法调用（被当作 this.getRenderBufferBitmap）
getRenderBufferBitmap((bitmap, rotation1) -> { ... });

// 正确：方法存在于 textureView.renderer 上
textureView.renderer.getRenderBufferBitmap((bitmap, rotation1) -> { ... });
```

## 3. 解决方案设计

### 阶段 1：干净恢复
1. 删除被污染的 `org.webrtc` 目录
2. 从 `Telegram-master` 复制官方源码
3. 移除 `google-webrtc` Maven 依赖

### 阶段 2：机械性导入重写（仅限 org.webrtc）
| 原始路径 | 替换为 | 受影响文件数 |
|---------|--------|-------------|
| `org.telegram.messenger` | `com.iecho.messenger` | 12 |
| `org.telegram.ui` | `com.echo.ui` | 2 |

### 阶段 3：Bug 修复（仅限 com.echo）
修复 `GroupCallMiniTextureView.java` 中缺少的对象引用

## 4. 实现细节

### 4.1 执行的命令

```bash
# 阶段 1：干净恢复
rm -rf TMessagesProj/src/main/java/org/webrtc
cp -r ../Telegram-master/TMessagesProj/src/main/java/org/webrtc TMessagesProj/src/main/java/org/webrtc

# 移除 Maven 依赖
# TMessagesProj/build.gradle:
# - implementation 'org.webrtc:google-webrtc:1.0.30039'
# + // implementation 'org.webrtc:google-webrtc:1.0.30039'

# 阶段 2：导入重写（仅 org.webrtc）
python3 -c "
import pathlib, re
root = pathlib.Path('TMessagesProj/src/main/java/org/webrtc')
for p in root.rglob('*.java'):
    s = p.read_text()
    s = re.sub(r'\borg\.telegram\.messenger\b', 'com.iecho.messenger', s)
    s = re.sub(r'\borg\.telegram\.ui\b', 'com.echo.ui', s)
    p.write_text(s)
"

# 阶段 3：Bug 修复
perl -0777 -i -pe 's/\n\s*getRenderBufferBitmap\(/\n              textureView.renderer.getRenderBufferBitmap(/g' \
  TMessagesProj/src/main/java/com/echo/ui/Components/voip/GroupCallMiniTextureView.java
```

### 4.2 修改的文件

**org.webrtc 导入重写（14 个文件）：**
- `AndroidVideoDecoder.java`
- `Camera1Session.java`
- `Camera2Session.java`
- `EglRenderer.java`
- `GlGenericDrawer.java`
- `HardwareVideoEncoder.java`
- `OrientationHelper.java`
- `ScreenCapturerAndroid.java`
- `TextureViewRenderer.java`
- `YuvConverter.java`
- `audio/WebRtcAudioTrack.java`
- `voiceengine/WebRtcAudioEffects.java`
- `voiceengine/WebRtcAudioRecord.java`
- `voiceengine/WebRtcAudioTrack.java`

**Bug 修复（1 个文件）：**
- `com/echo/ui/Components/voip/GroupCallMiniTextureView.java:1575`

## 5. 错误修复进度

| 阶段 | 错误数 | 操作 |
|-----|--------|-----|
| 初始（被污染） | 50 | 从 Telegram-master 干净恢复 |
| 恢复后 | 50 | 导入重写：`org.telegram.messenger` → `com.iecho.messenger` |
| messenger 重写后 | 5 | 导入重写：`org.telegram.ui` → `com.echo.ui` |
| ui 重写后 | 1 | 修复 `getRenderBufferBitmap` 对象引用 |
| 最终 | **0** ✅ | 编译成功 |

## 6. 验证结果

### 编译结果
```
BUILD SUCCESSFUL in 2m 5s
61 actionable tasks: 30 executed, 1 from cache, 30 up-to-date
```

### APK 输出
```
TMessagesProj_App/build/outputs/apk/afat/debug/app.apk
```

## 7. 提交记录

| 提交 | 描述 |
|------|-----|
| `chore: unify package name to com.iecho.messenger` | 暂存已有的重命名 |
| `fix(webrtc): rewrite messenger imports to com.iecho` | 12 个文件，16 处替换 |
| `fix(webrtc): rewrite ui imports to match com.echo` | 2 个文件，2 处替换 |
| `fix(voip): correct getRenderBufferBitmap call` | 1 个文件，1 处修复 |

## 8. 回滚方案

```bash
git checkout main -- TMessagesProj/src/main/java/org/webrtc
git checkout main -- TMessagesProj/build.gradle
git checkout main -- TMessagesProj/src/main/java/com/echo/ui/Components/voip/GroupCallMiniTextureView.java
```

## 9. 经验教训

1. **不要补丁官方源码** - 从上游恢复，然后做机械性导入重写
2. **包重命名必须完整** - `org.telegram.messenger` 和 `org.telegram.ui` 都需要更新
3. **验证方法归属** - `getRenderBufferBitmap` 并不缺失，只是调用时对象引用错误
