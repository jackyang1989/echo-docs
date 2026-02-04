# Echo 自动提交配置指南

## 📋 功能说明

自动提交脚本会每 **15 分钟**自动检查并提交以下仓库的变更：

1. ✅ `echo-proto`
2. ✅ `echo-server`
3. ✅ `echo-android-client`
4. ✅ `echo-docs`

## 🚀 快速开始

### 1. 安装自动提交服务

```bash
./setup-auto-commit.sh install
```

安装后，服务会立即启动，并每15分钟自动运行一次。

### 2. 查看服务状态

```bash
./setup-auto-commit.sh status
```

### 3. 查看日志

```bash
./setup-auto-commit.sh logs
```

或实时查看：

```bash
tail -f logs/auto-commit.log
```

### 4. 测试运行（不等15分钟）

```bash
./setup-auto-commit.sh test
```

## 📖 完整命令列表

| 命令 | 说明 |
|------|------|
| `./setup-auto-commit.sh install` | 安装并启动自动提交服务 |
| `./setup-auto-commit.sh uninstall` | 卸载自动提交服务 |
| `./setup-auto-commit.sh start` | 启动服务 |
| `./setup-auto-commit.sh stop` | 停止服务 |
| `./setup-auto-commit.sh status` | 查看服务状态 |
| `./setup-auto-commit.sh logs` | 查看日志 |
| `./setup-auto-commit.sh test` | 测试运行一次 |

## 🔧 工作原理

### 自动提交流程

1. **检查变更**：检查每个仓库是否有未提交的变更
2. **添加文件**：`git add .` 添加所有变更
3. **提交**：使用时间戳创建提交
4. **推送**：推送到远程仓库的 `main` 分支

### 提交消息格式

```
chore: 自动提交 - 2026-02-02 16:30:00

自动提交脚本生成的提交
```

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `auto-commit-all.sh` | 自动提交脚本（核心逻辑） |
| `setup-auto-commit.sh` | 服务管理脚本 |
| `com.echo.autocommit.plist` | macOS launchd 配置文件 |
| `logs/auto-commit.log` | 标准输出日志 |
| `logs/auto-commit-error.log` | 错误日志 |

## ⚙️ 配置说明

### 修改提交间隔

编辑 `com.echo.autocommit.plist`，修改 `StartInterval` 值（单位：秒）：

```xml
<key>StartInterval</key>
<integer>900</integer>  <!-- 900秒 = 15分钟 -->
```

常用间隔：
- 5分钟：`300`
- 10分钟：`600`
- 15分钟：`900`（默认）
- 30分钟：`1800`
- 1小时：`3600`

修改后需要重新加载服务：

```bash
./setup-auto-commit.sh stop
./setup-auto-commit.sh start
```

### 修改仓库路径

编辑 `auto-commit-all.sh`，修改 `PROJECT_ROOT` 变量：

```bash
PROJECT_ROOT="/Users/jianouyang/Project/echo"
```

## 🐛 故障排查

### 1. 服务未运行

```bash
# 查看状态
./setup-auto-commit.sh status

# 如果未运行，重新启动
./setup-auto-commit.sh start
```

### 2. 推送失败

可能原因：
- ❌ 网络问题
- ❌ GitHub 认证失败
- ❌ 仓库权限不足

解决方法：
```bash
# 查看错误日志
cat logs/auto-commit-error.log

# 手动测试推送
cd echo-server
git push origin main
```

### 3. 查看详细日志

```bash
# 实时查看日志
tail -f logs/auto-commit.log

# 查看错误日志
tail -f logs/auto-commit-error.log

# 查看最近50行
./setup-auto-commit.sh logs
```

### 4. 服务无法启动

```bash
# 检查 plist 文件是否存在
ls -la ~/Library/LaunchAgents/com.echo.autocommit.plist

# 检查脚本权限
ls -la auto-commit-all.sh

# 重新安装
./setup-auto-commit.sh uninstall
./setup-auto-commit.sh install
```

## ⚠️ 注意事项

### 1. Git 认证

确保 Git 已配置好认证：

```bash
# 检查 Git 配置
git config --global user.name
git config --global user.email

# 检查 GitHub 认证
ssh -T git@github.com
# 或
git credential-osxkeychain get
```

### 2. 私有仓库

`echo-android-client` 是私有仓库，确保：
- ✅ SSH key 已添加到 GitHub
- ✅ 或 HTTPS 认证已配置

### 3. 大文件

如果仓库包含大文件（如编译产物），建议：
- 添加到 `.gitignore`
- 或使用 Git LFS

### 4. 冲突处理

自动提交脚本不处理合并冲突，如果发生冲突：
1. 停止自动提交服务
2. 手动解决冲突
3. 重新启动服务

```bash
./setup-auto-commit.sh stop
# 手动解决冲突
./setup-auto-commit.sh start
```

## 🔒 安全建议

1. **不要提交敏感信息**
   - 密码、密钥、Token 等应使用环境变量
   - 添加到 `.gitignore`

2. **定期检查日志**
   ```bash
   ./setup-auto-commit.sh logs
   ```

3. **备份重要数据**
   - 自动提交不能替代手动备份
   - 定期检查远程仓库

## 📞 支持

如有问题，请查看：
- 日志文件：`logs/auto-commit.log`
- 错误日志：`logs/auto-commit-error.log`
- 或手动运行测试：`./setup-auto-commit.sh test`

---

**最后更新**: 2026-02-02  
**版本**: 1.0.0
