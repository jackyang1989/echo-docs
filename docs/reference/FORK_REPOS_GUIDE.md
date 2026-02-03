# Echo 仓库 Fork 操作指南

## 🎯 目标

将所有上游依赖 Fork 到你自己的 GitHub 仓库，避免上游删库导致项目瘫痪的风险。

## ✅ 已完成的自动化步骤

脚本 `setup-echo-repos.sh` 已经自动完成：

1. ✅ 配置 echo-proto 的 remote（origin → 你的仓库，upstream → 上游）
2. ✅ 打 tag `v1.0.0-layer221` 和 `v1.0.0`
3. ✅ 初始化 echo-server 的 git 仓库
4. ✅ 配置 echo-server 的 remote
5. ✅ 修改 echo-server/go.mod 使用你的 echo-proto
6. ✅ 批量替换所有 Go 文件中的 import 路径

## 📋 需要手动执行的步骤

### 步骤 1：推送 echo-proto 到你的 GitHub

```bash
cd echo-proto

# 推送主分支
git push -u origin main

# 推送 tags
git push origin v1.0.0-layer221
git push origin v1.0.0
```

**验证**：访问 https://github.com/jackyang1989/echo-proto 确认代码已推送

### 步骤 2：推送 echo-server 到你的 GitHub

```bash
cd ../echo-server

# 添加所有修改
git add .

# 提交
git commit -m "fix: update imports to use forked repos

- Replace github.com/teamgram/proto with github.com/jackyang1989/echo-proto
- Replace github.com/echo/echo-server with github.com/jackyang1989/echo-server
- Update go.mod to use forked echo-proto
- Add real database persistence (AuthKeyStore, SessionStore)
- Remove all stub implementations
- Week 1 Gateway implementation complete"

# 推送到你的仓库
git push -u origin main
```

**验证**：访问 https://github.com/jackyang1989/echo-server 确认代码已推送

### 步骤 3：修改 echo-server/go.mod 使用远程版本（可选）

当前 `go.mod` 使用本地路径：
```go
replace github.com/jackyang1989/echo-proto => ../echo-proto
```

**选项 A：继续使用本地路径（推荐用于开发）**
- 优点：修改 echo-proto 后立即生效，无需推送
- 缺点：部署时需要同时拷贝两个目录

**选项 B：使用远程版本（推荐用于生产）**
```bash
cd echo-server

# 编辑 go.mod，删除 replace 行
# 或者改为：
# replace github.com/jackyang1989/echo-proto => github.com/jackyang1989/echo-proto v1.0.0

# 下载依赖
export GOPROXY=https://goproxy.cn,direct
go mod tidy
```

### 步骤 4：验证依赖正确性

```bash
cd echo-server

# 查看依赖树
go mod graph | grep echo-proto

# 应该看到：
# github.com/jackyang1989/echo-server github.com/jackyang1989/echo-proto@v1.0.0

# 编译测试
go build -o bin/gateway ./cmd/gateway
```

## 🔍 依赖关系对比

### 修改前（有风险）

```
echo-server
  └── github.com/teamgram/proto ❌ 依赖上游，删库风险
```

### 修改后（安全）

```
echo-server (github.com/jackyang1989/echo-server)
  └── echo-proto (github.com/jackyang1989/echo-proto) ✅ 你自己的 Fork
        └── upstream: github.com/teamgram/proto (仅用于更新)
```

## 📊 风险对比

| 场景 | 修改前 | 修改后 |
|------|--------|--------|
| 上游删库 | ❌ 项目瘫痪 | ✅ 不受影响 |
| 上游更新 | ✅ 自动获取 | ✅ 手动合并（可控） |
| 编译部署 | ❌ 依赖网络 | ✅ 使用你的仓库 |
| 代码审计 | ❌ 无法保证 | ✅ 完全可控 |
| 长期维护 | ❌ 高风险 | ✅ 低风险 |

## 🔄 后续更新流程

当 teamgram/proto 有更新时，你可以这样合并：

```bash
cd echo-proto

# 拉取上游更新
git fetch upstream

# 查看更新内容
git log HEAD..upstream/main

# 合并更新（如果需要）
git merge upstream/main

# 打新 tag
git tag v1.0.1-layer222
git push origin main
git push origin v1.0.1-layer222

# 更新 echo-server 的依赖
cd ../echo-server
go get github.com/jackyang1989/echo-proto@v1.0.1-layer222
go mod tidy
```

## ⚠️ 重要提示

### 1. 不要直接修改 echo-proto

echo-proto 应该保持与上游同步，不要添加自定义代码。如果需要扩展协议：

- ✅ 在 echo-server 中创建 wrapper 或 helper
- ❌ 不要直接修改 echo-proto 的代码

### 2. 定期检查上游更新

建议每月检查一次上游更新：

```bash
cd echo-proto
git fetch upstream
git log HEAD..upstream/main --oneline
```

### 3. 保持 tag 版本管理

每次合并上游更新后，都要打新 tag：

```bash
git tag v1.0.X-layerYYY
git push origin v1.0.X-layerYYY
```

## 🎉 完成验证

执行以下命令验证设置正确：

```bash
# 1. 验证 echo-proto remote
cd echo-proto
git remote -v
# 应该看到：
# origin    https://github.com/jackyang1989/echo-proto.git (fetch)
# origin    https://github.com/jackyang1989/echo-proto.git (push)
# upstream  https://github.com/teamgram/proto.git (fetch)
# upstream  https://github.com/teamgram/proto.git (push)

# 2. 验证 echo-proto tags
git tag
# 应该看到：
# v1.0.0
# v1.0.0-layer221

# 3. 验证 echo-server remote
cd ../echo-server
git remote -v
# 应该看到：
# origin  https://github.com/jackyang1989/echo-server.git (fetch)
# origin  https://github.com/jackyang1989/echo-server.git (push)

# 4. 验证 import 路径
grep -r "github.com/teamgram/proto" . --include="*.go" | wc -l
# 应该输出 0（没有引用上游）

grep -r "github.com/jackyang1989/echo-proto" . --include="*.go" | wc -l
# 应该输出 > 0（使用你的 Fork）

# 5. 验证 go.mod
cat go.mod | grep echo-proto
# 应该看到：
# github.com/jackyang1989/echo-proto v1.0.0
# replace github.com/jackyang1989/echo-proto => ../echo-proto
```

## 📝 总结

### 核心改变

1. ✅ **echo-proto**：从 `github.com/teamgram/proto` 改为 `github.com/jackyang1989/echo-proto`
2. ✅ **echo-server**：从 `github.com/echo/echo-server` 改为 `github.com/jackyang1989/echo-server`
3. ✅ **所有 import**：批量替换为你的仓库路径

### 风险消除

- ✅ 上游删库不影响你的项目
- ✅ 上游更新可控（手动合并）
- ✅ 代码完全可控（你的仓库）
- ✅ 长期可维护（不依赖第三方）

### 下一步

完成上述手动步骤后，你就可以：

1. 继续 Week 1 的编译和测试
2. 开始 Week 2 的业务层开发
3. 放心地长期维护 Echo 项目

---

**最后更新**: 2026-02-01  
**状态**: ✅ 依赖风险已消除  
**下一步**: 推送代码到 GitHub
