# Echo 项目快速参考指南

## 📋 文档概述

本文档提供 Echo 项目开发和部署的快速参考信息。

**最后更新**: 2026-02-01  
**适用对象**: 开发者、运维人员、AI Agent

---

## 🚀 快速开始

### 环境要求
- macOS (开发环境)
- Docker Desktop
- Android Studio
- JDK 17
- Android NDK
- Go 1.21+

### 一键启动（开发环境）

```bash
# 1. 启动服务器
cd echo-server-source
docker-compose up -d
cd echod/bin && ./manage-services.sh start

# 2. 配置并编译 Android 客户端
cd echo-android-client
./configure-server.sh --lan $(ipconfig getifaddr en0)
./gradlew :TMessagesProj:assembleAfatDebug

# 3. 安装到真机
adb install -r TMessagesProj/build/outputs/apk/afat/debug/app-afat-arm64-v8a-debug.apk
```

---

## 🔑 关键信息

### 服务器配置
- **Gnetway 端口**: 10443
- **MySQL 端口**: 3306
- **Redis 端口**: 6380
- **MySQL 密码**: `my_root_secret`
- **数据库名**: `echo`

### 客户端配置
- **包名**: `com.echo.messenger`
- **应用名**: Echo
- **编译目标**: `assembleAfatDebug` (arm64-v8a)

### 开发环境登录
- **验证码**: 固定值 `12345`（测试模式）
- **手机号**: 任意（如 `+8613800138000`）

---

## 📁 重要目录结构

```
echo-server-source/
├── echod/
│   ├── bin/           # 服务可执行文件
│   ├── etc/           # 配置文件
│   └── logs/          # 日志文件
├── docs/core/         # 核心文档（🔴 禁止删除）
│   ├── changes/       # 变更记录
│   ├── architecture/  # 架构设计
│   └── standards/     # 开发规范
└── manage-services.sh # 服务管理脚本

echo-android-client/
├── TMessagesProj/
│   ├── jni/           # Native 代码
│   └── src/main/      # Java/Kotlin 代码
├── docs/core/         # 核心文档（🔴 禁止删除）
│   ├── changes/       # 变更记录
│   ├── architecture/  # 架构设计
│   └── standards/     # 开发规范
├── configure-server.sh # 服务器配置脚本
└── update-server-ip.sh # IP 更新脚本
```

---

## 🔧 常用命令

### 服务器管理

```bash
# 启动所有服务
cd echo-server-source/echod/bin
./manage-services.sh start

# 停止所有服务
./manage-services.sh stop

# 重启所有服务
./manage-services.sh restart

# 查看服务状态
./manage-services.sh status

# 启动单个服务
./manage-services.sh start gnetway

# 查看服务日志
tail -f ../logs/gnetway.log
tail -f ../logs/authsession.log
tail -f ../logs/biz/biz.log
```

### Android 编译

```bash
# 完整编译（强制重新编译 Native）
./gradlew :TMessagesProj:assembleAfatDebug --rerun-tasks

# 快速编译（不重新编译 Native）
./gradlew :TMessagesProj:assembleAfatDebug

# 清理编译产物
./gradlew clean

# 安装到真机
adb install -r TMessagesProj/build/outputs/apk/afat/debug/app-afat-arm64-v8a-debug.apk
```

### 诊断工具

```bash
# 服务器连接诊断
cd echo-server-source
./diagnose-connection.sh

# 查询验证码
./get-verification-code.sh <phone_number> <auth_key_id>

# 监控验证码
./watch-verification-code.sh

# 查看客户端日志
adb logcat | grep -E "ConnectionsManager|Handshake|LoginActivity"
```

### 数据库操作

```bash
# 连接 MySQL
docker exec -it mysql mysql -uroot -pmy_root_secret echo

# 查看用户
SELECT id, phone, username, created_at FROM users ORDER BY created_at DESC LIMIT 10;

# 查看 Auth Keys
SELECT auth_key_id, user_id, created_at FROM auth_keys ORDER BY created_at DESC LIMIT 10;

# 连接 Redis
docker exec -it redis redis-cli

# 查看验证码
KEYS phone_codes_*
GET phone_codes_<auth_key_id>_<phone_number>
```

---

## 🐛 常见问题

### 问题 1: 真机无法连接服务器

**症状**: 客户端显示 "Connecting..."，无法连接

**解决**:
```bash
# 1. 检查 Mac IP 地址
ipconfig getifaddr en0

# 2. 更新客户端配置
cd echo-android-client
./configure-server.sh --lan <your_mac_ip>

# 3. 重新编译
./gradlew :TMessagesProj:assembleAfatDebug --rerun-tasks
```

**相关文档**: [ECHO-BUG-017](../echo-android-client/docs/core/changes/bugfixes/ECHO-BUG-017-server-address-hardcoded.md)

### 问题 2: 验证码验证失败

**症状**: 输入验证码后提示 "You entered the wrong code"

**解决**: 使用固定验证码 `12345`（测试模式）

**相关文档**: [ECHO-BUG-020](../echo-server-source/docs/core/changes/bugfixes/ECHO-BUG-020-verification-code-validation.md)

### 问题 3: DH 握手失败

**症状**: 客户端日志显示 "dh_gen_retry"

**解决**:
```bash
# 1. 检查 authsession.yaml 配置
cat echo-server-source/echod/etc/authsession.yaml | grep DSN

# 2. 确保 MySQL 密码正确
# DSN: root:my_root_secret@tcp(127.0.0.1:3306)/echo?charset=utf8mb4&parseTime=true

# 3. 重启 authsession 服务
cd echo-server-source/echod/bin
./manage-services.sh restart authsession
```

**相关文档**: [ECHO-BUG-019](../echo-server-source/docs/core/changes/bugfixes/ECHO-BUG-019-authsession-mysql-password.md)

### 问题 4: 注册失败

**症状**: 输入用户名后提示错误

**解决**:
```bash
# 1. 检查 biz.yaml 配置
cat echo-server-source/echod/etc/biz.yaml | grep DSN

# 2. 确保 MySQL 密码正确
# DSN: root:my_root_secret@tcp(127.0.0.1:3306)/echo?charset=utf8mb4&parseTime=true

# 3. 重启 biz 服务
cd echo-server-source/echod/bin
./manage-services.sh restart biz
```

**相关文档**: [ECHO-BUG-021](../echo-server-source/docs/core/changes/bugfixes/ECHO-BUG-021-registration-mysql-connection.md)

---

## 📝 开发规范

### 代码变更流程

1. **开发前**:
   - 运行 `./tools/validate-agents-compliance.sh`
   - 查阅相关变更记录文档
   - 创建新的变更记录文档

2. **开发中**:
   - 添加代码注释标记（ECHO-XXX-XXX）
   - 实时更新变更记录文档
   - 定期运行合规性检查

3. **开发后**:
   - 完善变更记录文档（10 个必填项）
   - 更新 CHANGELOG.md
   - 提交时引用变更 ID

### 变更 ID 规则

- **功能**: ECHO-FEATURE-001, ECHO-FEATURE-002, ...
- **Bug**: ECHO-BUG-001, ECHO-BUG-002, ...
- **优化**: ECHO-OPT-001, ECHO-OPT-002, ...

### Git 提交规范

```bash
# 功能开发
git commit -m "feat: [ECHO-FEATURE-XXX] 添加快捷回复功能"

# Bug 修复
git commit -m "fix: [ECHO-BUG-XXX] 修复真机连接问题"

# 性能优化
git commit -m "perf: [ECHO-OPT-XXX] 优化消息列表渲染"
```

---

## 🔗 重要文档链接

### 核心规范
- [AGENTS.md](../AGENTS.md) - 品牌命名规则和架构规范（🔴 必读）
- [强制执行机制](../ECHO_AI_AGENT_ENFORCEMENT.md) - AI Agent 强制执行规则
- [强制执行总结](../ECHO_ENFORCEMENT_SUMMARY.md) - 实施总结

### 核心文档索引
- [服务端核心文档](../echo-server-source/docs/core/README.md)
- [Android 客户端核心文档](../echo-android-client/docs/core/README.md)

### 变更记录
- [服务端 CHANGELOG](../echo-server-source/docs/core/changes/CHANGELOG.md)
- [Android 客户端 CHANGELOG](../echo-android-client/docs/core/changes/CHANGELOG.md)

### 架构设计
- [服务端架构设计](../echo-server-source/docs/core/architecture/system-design.md)
- [Android 客户端架构设计](../echo-android-client/docs/core/architecture/system-design.md)

### 开发规范
- [服务端编码规范](../echo-server-source/docs/core/standards/coding-standards.md)
- [服务端提交规范](../echo-server-source/docs/core/standards/commit-conventions.md)
- [服务端审查清单](../echo-server-source/docs/core/standards/review-checklist.md)

### 问题解决
- [真机连接完整解决方案](../docs/temp/ECHO-REAL-DEVICE-CONNECTION-COMPLETE.md)
- [配置本地服务器](../echo-android-client/配置本地服务器.md)
- [连接问题诊断](../echo-android-client/连接问题诊断.md)

---

## 🎯 开发检查清单

### 开发前
- [ ] 运行 `./tools/validate-agents-compliance.sh`
- [ ] 查阅 AGENTS.md 相关章节
- [ ] 查阅核心文档索引
- [ ] 创建变更记录文档

### 开发中
- [ ] 添加代码注释标记（ECHO-XXX-XXX）
- [ ] 实时更新变更记录文档
- [ ] 遵循编码规范
- [ ] 定期运行合规性检查

### 提交前
- [ ] 完善变更记录文档（10 个必填项）
- [ ] 更新 CHANGELOG.md
- [ ] 运行 `./tools/validate-agents-compliance.sh`
- [ ] 运行 `./check-branding.sh`
- [ ] 编写测试用例
- [ ] 运行测试套件

### PR 审查
- [ ] 变更记录完整性检查
- [ ] 代码质量检查
- [ ] 上游兼容性检查
- [ ] 测试覆盖检查

---

## 📞 获取帮助

### 文档查询
1. 查阅 [AGENTS.md](../AGENTS.md) 核心规范
2. 查阅 [核心文档索引](../echo-server-source/docs/core/README.md)
3. 搜索相关变更记录文档

### 问题诊断
1. 运行诊断工具 `./diagnose-connection.sh`
2. 查看服务日志 `tail -f echod/logs/*.log`
3. 查看客户端日志 `adb logcat`

### 联系方式
- 项目维护者: Echo 项目团队
- 文档反馈: 更新 AGENTS.md 或创建 Issue

---

**最后更新**: 2026-02-01  
**维护者**: Echo 项目团队  
**版本**: v1.0.0
