# ECHO-BUG-003-refactor-package-name-compliance

## 📌 问题描述
为了确保应用包名的全球唯一性与品牌保护，同时规避常见词汇带来的被抢注风险，需要将应用包名从 `com.echo.messenger` 重构为 `com.iecho.messenger`。

## 🧠 决策背景 (Reasoning)
- **风险规避**: `echo` 与 `messenger` 均为通用行业词汇。使用 `com.echo.messenger` 极易在未来被其他开发者无意中“撞名”抢注。
- **品牌保护**: 为防止 1-3 年后应用上架 Google Play 时发现包名已被占用，采取更具独特性且符合“苹果式”命名规范的 `com.iecho`。
- **技术成本**: 在项目初期（Firebase 迁移阶段）进行重构的成本接近于零，而后期迁移则是灾难性的。

## 🛠️ 修复措施

### 1. 全局搜索并替换 (Codebase Replacement)
- **范围**: `echo-android-client` 全局源代码。
- **内容**: 
    - 替换所有 `com.echo.messenger` 字符串为 `com.iecho.messenger`。
    - 涵盖了: Java 源码、C++ JNI 代码、AndroidManifest.xml、Gradle 脚本。

### 2. 构建配置更新 (Gradle Config)
- **文件**: `gradle.properties`
- **操作**: 将 `APP_PACKAGE` 属性修改为 `com.iecho.messenger`。

### 3. Firebase 服务恢复 (Google Services)
- **文件**: `google-services.json`
- **操作**: 
    - 在 Firebase 控制台注册了 `com.iecho.messenger` (Release) 和 `com.iecho.messenger.beta` (Debug)。
    - 获取并部署了包含双重包名配置的新 JSON 文件。
    - 验证了 SHA-1 指纹一致性。

## ✅ 验证结果
- **构建系统**: Gradle 成功识别新包名并启动编译。
- **JNI 链接**: C++ 层已完成新命名空间的链接。
- **Firebase**: 成功关联新的客户端 ID。

---
**日期**: 2026-01-30
**状态**: ✅ 已修复
