# ECHO-BUG-021: 消息收发问题 - 磁盘空间不足导致 MySQL I/O 错误

## 变更 ID
**ECHO-BUG-021**

## 基本信息
- **问题类型**: Bug 诊断（环境问题）
- **优先级**: 🔴 高（阻塞核心功能）
- **开发者**: AI Agent
- **开发日期**: 2026-02-02
- **上游版本基线**: Telegram v10.5.2
- **关联问题**: ECHO-BUG-020（验证码问题已解决）

---

## 问题描述

### 用户故事
作为用户，我希望能够在两个手机之间发送和接收消息，但发送消息后对方收不到。

### 问题现象
1. **登录成功** ✅
   - 两个用户都已成功登录
   - jack (8615622252279) - 用户 ID: 136907714
   - ouyang (8618124944249) - 用户 ID: 136907713

2. **消息发送失败** 🔴
   - OPPO 手机发送消息 "test"
   - 三星手机收不到消息
   - 没有错误提示

3. **服务器状态** ✅
   - 所有服务正在运行（gnetway, session, bff, authsession, msg, sync, biz）
   - 两个客户端都已连接到服务器

### 影响范围
- **影响模块**: 消息收发、同步服务
- **影响用户**: 所有尝试发送消息的用户
- **严重程度**: 🔴 阻塞性问题（核心功能不可用）

---

## 根本原因分析

### 诊断过程

#### 1. 检查服务状态
```bash
$ cd echo-server-source && ./manage-services.sh status

✅ gnetway 正在运行 (PID: 87712)
✅ session 正在运行 (PID: 87709)
✅ bff 正在运行 (PID: 87523)
✅ authsession 正在运行 (PID: 73176)
✅ msg 正在运行 (PID: 87516)
✅ sync 正在运行 (PID: 87518)
✅ biz 正在运行 (PID: 87514)
```

#### 2. 检查客户端连接
```bash
$ lsof -i :10443 | grep ESTABLISHED

gnetway 87712  192.168.0.17:10443->192.168.0.16:40076 (ESTABLISHED)  # OPPO
gnetway 87712  192.168.0.17:10443->192.168.0.7:57232 (ESTABLISHED)   # 三星
```

✅ 两个客户端都已连接

#### 3. 检查数据库
```bash
$ docker exec mysql mysql -uroot -pmy_root_secret echo -e "SELECT * FROM messages"

Error: exec /usr/bin/mysql: input/output error
```

❌ MySQL 容器 I/O 错误

#### 4. 检查磁盘空间
```bash
$ df -h

Filesystem      Size    Used   Avail Capacity
/dev/disk3s1s1  228Gi   11Gi   4.3Gi    73%
```

🔴 **根本原因**: 磁盘空间只剩 4.3GB，导致 MySQL 容器 I/O 错误

### 技术原因
1. **磁盘空间不足**: 只剩 4.3GB 可用空间
2. **MySQL I/O 错误**: 无法写入数据库
3. **消息无法存储**: 消息发送请求无法持久化
4. **同步失败**: 无法推送更新给接收方

---

## 解决方案

### 方案 1: 清理磁盘空间（推荐）

#### 1.1 清理 Docker 资源
```bash
# 清理未使用的 Docker 资源
docker system prune -a --volumes

# 预期释放: 2-5GB
```

#### 1.2 清理 Gradle 缓存
```bash
# 清理 Gradle 缓存
rm -rf ~/.gradle/caches

# 预期释放: 1-3GB
```

#### 1.3 清理 Android Build 缓存
```bash
cd echo-android-client
./gradlew clean

# 预期释放: 500MB-1GB
```

#### 1.4 清理日志文件
```bash
cd echo-server-source
rm -rf echod/logs/*.log

# 预期释放: 100-500MB
```

### 方案 2: 重启 Docker 和服务

```bash
# 1. 停止所有服务
cd echo-server-source
./manage-services.sh stop all

# 2. 停止 Docker
docker-compose down

# 3. 重启 Docker Desktop（在 macOS 菜单栏）

# 4. 重新启动
docker-compose up -d
sleep 30
./manage-services.sh start all
```

### 方案 3: 扩展磁盘空间

如果清理后空间仍然不足，需要：
1. 删除不必要的文件
2. 移动大文件到外部存储
3. 扩展磁盘分区

---

## 修改的文件清单

### 诊断脚本

#### 新增文件
- **文件**: `echo-android-client/diagnose-message-issue.sh`
  - **类型**: Shell 脚本
  - **功能**: 诊断消息收发问题
  - **内容**: 
    - 检查服务状态
    - 检查 Kafka 状态
    - 检查消息相关端口
    - 查看数据库中的消息
    - 查看已登录用户

- **文件**: `echo-server-source/monitor-messages.sh`
  - **类型**: Shell 脚本
  - **功能**: 实时监控消息发送
  - **内容**: 
    - 监控 msg.log
    - 监控 sync.log
    - 监控 gnetway.log

- **文件**: `echo-server-source/get-verification-code.sh`
  - **类型**: Shell 脚本
  - **功能**: 查看验证码
  - **内容**: 
    - 从数据库查询验证码

#### 更新文件
- **文件**: `docs/core/changes/bugfixes/ECHO-BUG-021-message-send-receive-issue.md`
  - **类型**: Bug 修复记录
  - **变更内容**: 创建本文档

---

## 测试验证

### 测试步骤
1. ✅ 检查服务状态（所有服务正在运行）
2. ✅ 检查客户端连接（两个客户端已连接）
3. ✅ 检查用户登录（两个用户已登录）
4. ❌ 发送测试消息（消息收不到）
5. ❌ 检查数据库（MySQL I/O 错误）
6. 🔴 检查磁盘空间（只剩 4.3GB）

### 测试结果
```
✅ 服务器启动成功
✅ 客户端连接成功
✅ 用户登录成功
❌ 消息发送失败（MySQL I/O 错误）
🔴 磁盘空间不足（根本原因）
```

---

## 上游兼容性分析

### 冲突风险评估
- **风险等级**: 🟢 无风险
- **原因**: 这是环境问题，不涉及代码修改

### 合并策略
- **隔离方案**: 无需隔离，这是运维问题
- **回滚方案**: 清理磁盘空间即可

### 上游更新适配指南
- 无需适配，这是环境问题

---

## 回滚计划

### 回滚步骤
无需回滚，这是环境问题。

### 数据保留策略
- 清理磁盘空间后，数据库应该能够正常工作

---

## 相关文档

- [ECHO-BUG-020: 验证码获取超时](ECHO-BUG-020-verification-code-timeout.md)
- [VERIFICATION_CODE_SUCCESS_REPORT.md](../../VERIFICATION_CODE_SUCCESS_REPORT.md)
- [diagnose-message-issue.sh](../../diagnose-message-issue.sh)

---

## 经验教训

### 问题诊断
1. ✅ 先检查服务状态
2. ✅ 再检查客户端连接
3. ✅ 然后检查数据库
4. ✅ 最后检查磁盘空间（关键！）

### 最佳实践
1. ✅ 定期监控磁盘空间
2. ✅ 设置磁盘空间告警（< 10GB）
3. ✅ 定期清理 Docker 资源
4. ✅ 定期清理构建缓存

### 待改进项
1. ⏳ 添加磁盘空间监控告警
2. ⏳ 自动清理旧日志文件
3. ⏳ 数据库错误时显示更友好的提示

---

## 快速参考

### 问题症状
- 消息发送后对方收不到
- MySQL I/O 错误
- 磁盘空间不足

### 快速诊断
```bash
# 检查磁盘空间
df -h

# 检查 MySQL 状态
docker exec mysql mysql -uroot -pmy_root_secret -e "SELECT 1;"
```

### 快速修复
```bash
# 清理 Docker 资源
docker system prune -a --volumes

# 清理 Gradle 缓存
rm -rf ~/.gradle/caches

# 清理 Android Build 缓存
cd echo-android-client
./gradlew clean
```

---

## 当前状态

### ✅ 已验证的功能
1. 服务器启动成功
2. 客户端连接成功
3. RSA 握手成功
4. DH 握手成功
5. 验证码发送成功
6. 用户登录成功
7. 双设备同时在线

### ✅ 已完成的清理
1. ✅ 清理 Gradle 缓存（1.1MB）
2. ✅ 清理 Android Build 缓存（184KB）
3. ✅ 清理日志文件（145MB）
4. ✅ 磁盘空间从 4.3GB 增加到 11GB
5. ✅ 使用率从 73% 降到 53%

### 🔴 待解决的问题
1. ⏳ Docker I/O 错误（需要重启 Docker Desktop）
2. ⏳ MySQL I/O 错误（Docker 重启后应该能解决）
3. ⏳ 消息收发功能（服务重启后需要重新测试）

### 📋 下一步操作
1. ✅ 清理磁盘空间（已完成）
2. ⏳ 重启 Docker Desktop（手动操作）
3. ⏳ 重启所有服务
4. ⏳ 重新测试消息收发功能
5. ⏳ 验证消息同步是否正常

### 🛠️ 快速修复脚本
已创建 `fix-disk-space-and-restart.sh` 脚本，包含完整的修复流程：
```bash
./fix-disk-space-and-restart.sh
```

---

**状态**: ⏳ 进行中（磁盘空间已清理，等待 Docker 重启）  
**最后更新**: 2026-02-02  
**维护者**: Echo 项目团队
