# Teamgram 清理计划

## 📋 背景

在开发 Echo 项目过程中，我们使用了 Teamgram 作为参考项目。但现在 Echo 新版服务端已经开发完成（100% 自研），继续保留 Teamgram 相关文件会造成混淆。

## 🎯 清理目标

**避免混淆，明确项目边界**

### 问题

1. **目录名称混淆**
   - `echo-server-source` 看起来像是 Echo 的源码，实际是 Teamgram
   - `teamgram-server` 是 Teamgram 原版，但很少使用

2. **脚本混淆**
   - `start-teamgram-services.sh` 可能被误用
   - 导致启动错误的服务

3. **Docker 容器混淆**
   - Teamgram 使用 MySQL
   - Echo 使用 PostgreSQL
   - 两者不兼容

## 🗑️ 要删除的内容

### 1. 目录

| 目录 | 说明 | 大小 | 删除原因 |
|------|------|------|---------|
| `echo-server-source/` | Teamgram 修改版 | ~500MB | 名称混淆，已不使用 |
| `teamgram-server/` | Teamgram 原版 | ~500MB | 很少使用，可从 GitHub 重新获取 |

### 2. 脚本

| 脚本 | 说明 | 删除原因 |
|------|------|---------|
| `start-teamgram-services.sh` | 启动 Teamgram 服务 | 会启动错误的服务 |
| `test-auth-flow.sh` | 测试 Teamgram 认证流程 | 针对 Teamgram，不适用于 Echo |

## ✅ 保留的内容

### Echo 核心项目

| 项目 | 说明 | 状态 |
|------|------|------|
| `echo-server/` | Echo 新版服务端（100% 自研） | ✅ 保留 |
| `echo-android-client/` | Echo Android 客户端 | ✅ 保留 |
| `echo-proto/` | Echo 协议定义 | ✅ 保留 |
| `echo-docs/` | Echo 文档 | ✅ 保留 |

### 参考项目

| 项目 | 说明 | 状态 |
|------|------|------|
| `Telegram-master/` | Telegram 官方客户端源码 | ✅ 保留（参考） |

## 🔄 如果需要重新获取

### Teamgram 原版

```bash
git clone https://github.com/teamgram/teamgram-server.git
```

### 为什么可以安全删除

1. **Echo 已自研完成**
   - Gateway 已实现
   - Auth/User/Message/Sync 服务已实现
   - 不再依赖 Teamgram 代码

2. **可以随时重新获取**
   - Teamgram 是开源项目
   - 可以从 GitHub 重新克隆

3. **文档已保留**
   - 重要的参考信息已记录在 Echo 文档中
   - 不会丢失知识

## 📝 清理步骤

### 自动清理（推荐）

```bash
./cleanup-teamgram.sh
```

### 手动清理

```bash
# 1. 删除目录
rm -rf echo-server-source
rm -rf teamgram-server

# 2. 删除脚本
rm -f start-teamgram-services.sh
rm -f test-auth-flow.sh

# 3. 更新 .gitignore
echo "teamgram-server/" >> .gitignore
echo "echo-server-source/" >> .gitignore
```

## 🎯 清理后的项目结构

```
echo/
├── echo-server/          # Echo 新版服务端（100% 自研）✅
├── echo-android-client/  # Echo Android 客户端 ✅
├── echo-proto/           # Echo 协议定义 ✅
├── echo-docs/            # Echo 文档 ✅
├── Telegram-master/      # Telegram 官方源码（参考）✅
├── start-echo-services.sh # 启动 Echo 服务 ✅
└── ...
```

## ✅ 清理后的好处

1. **项目结构清晰**
   - 只保留 Echo 相关的代码
   - 参考项目明确标识

2. **避免混淆**
   - 不会误启动 Teamgram 服务
   - 不会误用 Teamgram 脚本

3. **减少磁盘占用**
   - 删除约 1GB 的冗余代码

4. **提高开发效率**
   - 不需要在多个项目间切换
   - 专注于 Echo 开发

## 🚀 清理后的下一步

1. **启动 Echo 新版服务端**
   ```bash
   ./start-echo-services.sh
   ```

2. **测试基础功能**
   - 登录
   - 发送消息
   - 接收消息

3. **继续开发**
   - 完成 P0-3 阶段（消息发送）
   - 完成 P0-4 阶段（消息接收）

## 📞 如果遇到问题

如果清理后发现需要参考 Teamgram 代码：

1. **查看 Echo 文档**
   - `echo-docs/` 中已记录重要参考信息

2. **在线查看**
   - GitHub: https://github.com/teamgram/teamgram-server

3. **重新克隆**
   - 如果确实需要，可以重新克隆到临时目录

---

**最后更新**: 2026-02-04 22:40  
**状态**: 待执行
