# Echo Android Client 变更日志

本文档记录 Echo Android Client 的所有自定义功能、Bug 修复和性能优化。

## 版本说明

- **基线版本**: Telegram v10.5.2
- **当前版本**: Echo Android Client v1.0.0
- **最后更新**: 2026-01-30

---

## [Unreleased]

### Bug 修复
- [ECHO-BUG-023](bugfixes/ECHO-BUG-023-samsung-clone-app-icon.md) 三星设备克隆应用图标问题 (2026-02-03)
  - 问题：三星设备安装后显示"克隆应用"图标
  - 原因：`adb install` 自动安装到 DUAL_APP 用户空间
  - 解决：使用 `adb install --user 0` 安装
  - 附带修改：移除 t.me 域名、tg://→echo://、tgb://→echob://
- [ECHO-BUG-020](bugfixes/ECHO-BUG-020-verification-code-timeout.md) 验证码获取超时 - 服务器未运行 (2026-02-02)
  - 问题：点击"获取验证码"一直转圈，无法进入验证码输入界面
  - 原因：Echo 服务器（gnetway）未启动，端口 10443 未监听
  - 解决：启动 Echo 服务器核心服务
  - 工具：创建 fix-verification-code.sh 快速诊断脚本
- [ECHO-BUG-019](bugfixes/ECHO-BUG-019-verify-real-device-connection.md) 验证 Android 真机连接配置与编译环境修复 (2026-02-02)
  - 验证 IP 配置 (192.168.0.17) 正确
  - 诊断并清理磁盘空间（释放 9GB+）以解决编译失败问题
- [ECHO-BUG-022] 修改用户名域名配置为 iecho.app (2026-02-01)
  - 客户端：使用动态 linkPrefix 替代硬编码域名
  - 服务端：修改 config.json 中的 me_url_prefix
  - 验证：用户名设置页面显示 iecho.app/username
- [ECHO-BUG-018] 修复 RSA 公钥缺失导致握手失败 (2026-02-01)
  - 问题：客户端找不到 Echo 服务器的 RSA 公钥（指纹 0xa9e071c1771060cd）
  - 解决：从服务器日志提取 RSA 公钥并添加到 Handshake.cpp
  - 验证：RSA 验证成功，DH 握手完成
- [ECHO-BUG-017] 修复服务器地址硬编码问题 (2026-02-01)
  - 问题：服务器 IP 硬编码为 127.0.0.1，真机无法访问
  - 解决：修改为 Mac 局域网 IP 192.168.0.17
  - 工具：创建 update-server-ip.sh 和 configure-server.sh 脚本
- [ECHO-BUG-015] 记录 TMessagesProj_AppStandalone 模块编译失败 (2026-02-01)
  - 缺少 27 个字符串和 Drawable 资源
  - 提供 3 个解决方案（添加资源、移除功能、使用华为版本）
  - 推荐使用华为版本替代（已编译成功）
  - 详细记录问题分析和后续优化建议
- [ECHO-BUG-014] 修复 Native 库文件为空导致应用闪退 (2026-02-01)
  - 问题：运行 clean 后重新编译，native 库文件为空（0B）
  - 解决：强制重新编译 native 库（使用 --rerun-tasks）
  - 验证：native 库文件大小正常（376MB → 57MB after strip）
- [ECHO-BUG-013] 修复真机无法连接到 Echo 服务器 (2026-02-01)
  - 将服务器地址从 127.0.0.1 改为 Mac 局域网 IP 192.168.0.17
  - 新增 update-server-ip.sh 脚本方便修改服务器地址
  - 新增 configure-server.sh 脚本支持多种使用场景
  - 新增连接诊断文档和工具
- [ECHO-BUG-012] 启用测试后端（登录临时方案）(2026-01-31)

### 计划中的功能
- 待添加

---

## [1.0.0] - 2026-01-30

### 基线版本
- 基于 Telegram v10.5.2
- 完成品牌重命名 Telegram → Echo
- 包名: org.telegram.* → com.echo.*
- 应用名称: Telegram → Echo
- 所有 UI 文本已更新

### 合规性改进
- 完全移除 Telegram 品牌引用
- 符合中国地区合规要求
- 独立品牌标识

---

## 变更记录索引

### 新增功能 (Features)
- 暂无自定义功能

### Bug 修复 (Bug Fixes)
- [ECHO-BUG-020](bugfixes/ECHO-BUG-020-verification-code-timeout.md) - 验证码获取超时 - 服务器未运行 (2026-02-02)
- [ECHO-BUG-018](bugfixes/ECHO-BUG-018-rsa-public-key-missing.md) - 修复 RSA 公钥缺失导致握手失败 (2026-02-01)
- [ECHO-BUG-017](bugfixes/ECHO-BUG-017-server-address-hardcoded.md) - 修复服务器地址硬编码问题 (2026-02-01)
- [ECHO-BUG-009](bugfixes/ECHO-BUG-009-fix-duplicate-app-icons.md) - 修复双图标问题（安装后出现 2 个同名 App）；提供诊断和修复工具 (2026-01-31)
- [ECHO-BUG-008](bugfixes/ECHO-BUG-008-fix-iecho-to-echo-package-unification.md) - 修复 iecho → echo 包名统一问题（JNI 包名不匹配导致闪退）(2026-01-31)
- [ECHO-BUG-006](bugfixes/ECHO-BUG-006-fix-webrtc-dependencies.md) - 修复 WebRTC 依赖缺失及 LivePlayerView 编译错误 (2026-01-31)
- [ECHO-BUG-005](bugfixes/ECHO-BUG-005-android-build-ue-processes.md) - 诊断并记录 Android 编译失败（193 个 UE 进程）；需 macOS 重启 + 单线程 CMake 编译 (2026-01-31)
- [ECHO-BUG-004](bugfixes/ECHO-BUG-004-complete-compliance-cleanup.md) - 完成所有应用变体的配置文件合规性清理 (2026-01-30)
- [ECHO-BUG-003](bugfixes/ECHO-BUG-003-refactor-package-name-compliance.md) - 重构包名以符合合规性要求 (2026-01-30)
- [ECHO-BUG-002](bugfixes/ECHO-BUG-002-fix-google-services-and-compliance.md) - 修复 Google Services 配置及合规性清洗 (2026-01-30)
- [ECHO-BUG-001](bugfixes/ECHO-BUG-001-fix-gradle-build-errors.md) - 修复 Gradle 构建配置和依赖缺失问题 (2026-01-30)

### 性能优化 (Optimizations)
- [ECHO-OPT-002](optimizations/ECHO-OPT-002-configure-local-server.md) - 配置Android客户端连接本地服务器 (2026-01-30)
- [ECHO-OPT-003](optimizations/ECHO-OPT-003-gradle-performance-tuning.md) - Gradle 构建性能优化（针对 16GB RAM） (2026-01-30)

### 上游合并 (Upstream Merges)
- 暂无

---

## 如何添加变更记录

1. 在对应目录创建变更文档：
   - 新增功能: `features/ECHO-FEATURE-XXX-功能名.md`
   - Bug 修复: `bugfixes/ECHO-BUG-XXX-问题描述.md`
   - 性能优化: `optimizations/ECHO-OPT-XXX-优化项.md`

2. 在本文件的 `[Unreleased]` 章节添加条目

3. 发布版本时，将 `[Unreleased]` 内容移至新版本章节

---

## 变更 ID 规则

- **功能**: ECHO-FEATURE-001, ECHO-FEATURE-002, ...
- **Bug**: ECHO-BUG-001, ECHO-BUG-002, ...
- **优化**: ECHO-OPT-001, ECHO-OPT-002, ...

变更 ID 全局唯一，不可重复使用。

---

**维护者**: Echo 项目团队  
**联系方式**: 参见项目 README
