# [ECHO-OPT-004] WebRTC 官方源码同步全程总结

> **时间跨度**: ~10+ 小时  
> **编译尝试**: 数十次  
> **最终结果**: ✅ 编译成功  
> **基线 Tag**: `echo-android-baseline-2026-01`

---

## 1. 问题背景

Echo Android 客户端基于 Telegram 源码重构。包名合规化（`org.telegram` → `com.iecho/com.echo`）后，WebRTC 模块编译失败。

---

## 2. 问题演进

| 阶段 | 错误数 | 尝试方法 | 结果 |
|-----|--------|---------|------|
| 初始 | 50+ | 手动补全缺失方法 | ❌ |
| ECHO-BUG-006 | 30+ | 从 GitHub 下载 WebRTC 类 | ❌ |
| 适配标准库 | 20+ | 修改代码适配 `google-webrtc` AAR | ❌ |
| 干净恢复 | 50 → 5 → 1 → 0 | 从 Telegram-master 复制 + 机械替换 | ✅ |
| JNI 路径修正 | 闪退 → 正常 | 修正 JNI 中硬编码的包路径 | ✅ |

---

## 3. 失败的尝试

### ❌ 手动补全缺失方法
在 `TextureViewRenderer.java` 中添加空方法实现 → 越补越多，永远补不完

### ❌ 使用 Maven 依赖 + 适配代码
保留 `google-webrtc` 依赖，修改调用方 → 用户明确拒绝

### ❌ 混用不同来源的代码
部分从 GitHub，部分从本地 → 产生"污染"代码

---

## 4. 正确解决方案

### 核心原则
> **不要修改官方源码逻辑，只做机械性 import 路径替换**

### 执行步骤

```bash
# 1. 干净恢复
rm -rf TMessagesProj/src/main/java/org/webrtc
cp -r ../Telegram-master/.../org/webrtc TMessagesProj/src/main/java/org/webrtc

# 2. 移除 Maven 依赖
# TMessagesProj/build.gradle: 注释 google-webrtc

# 3. 机械替换 import
org.telegram.messenger → com.iecho.messenger (12文件, 16处)
org.telegram.ui → com.echo.ui (2文件, 2处)

# 4. 修复调用错误
getRenderBufferBitmap(...) → textureView.renderer.getRenderBufferBitmap(...)

# 5. JNI 运行时修正 (Runtime Fix)
由于 Java 层包名修改（`com.echo` vs `com.iecho`），JNI 硬编码路径也需对齐：
- `tgnet`: `com/echo/tgnet`
- `SQLite`: `com/echo/SQLite`
- `messenger`: `com/iecho/messenger`
- `voip`: `com/iecho/messenger/voip`
```

---

## 5. 提交记录

| Commit | 描述 |
|--------|-----|
| `fix(webrtc): rewrite messenger imports` | 12 文件 |
| `fix(webrtc): rewrite ui imports` | 2 文件 |
| `fix(voip): correct getRenderBufferBitmap call` | 1 文件 |
| `fix(jni): correct package path to com/iecho` | 7 文件 (Initial fix) |
| `fix(jni): align tgnet paths to com/echo` | 1 文件 (Final runtime fix) |

---

## 6. 关键经验教训

1. **尊重上游源码** - 不要"修复"官方代码
2. **包名替换必须完整** - `messenger` 和 `ui` 都要替换
3. **验证方法归属** - 报错不一定是缺失，可能是调用对象错误
4. **不要混用代码来源** - 使用单一上游源
5. **用户反馈最重要** - "不要让代码适配标准库"

---

## 7. 相关文档

- [ECHO-BUG-006](./bugfixes/ECHO-BUG-006-fix-webrtc-dependencies.md)
- [ECHO-BUG-007](./bugfixes/ECHO-BUG-007-webrtc-official-source-sync.md)
