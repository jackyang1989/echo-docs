# Fork Marmota 工具库计划

## 背景

**问题**: echo-server 依赖 `github.com/teamgram/marmota v0.1.22`，如果上游删库会导致项目无法编译。

**解决方案**: Fork 到用户自己的 GitHub 仓库 `https://github.com/jackyang1989/echo-marmota`

---

## 当前使用情况

### echo-server 依赖

```go
// echo-server/go.mod
require github.com/teamgram/marmota v0.1.22
```

### 使用位置

```go
// echo-server/internal/gateway/server.go
import "github.com/teamgram/marmota/pkg/cache"
```

**使用的包**:
- `pkg/cache` - 缓存工具

---

## Fork 步骤

### 1. Fork 仓库

```bash
# 1. 在 GitHub 上 Fork teamgram/marmota 到 jackyang1989/echo-marmota
# 访问: https://github.com/teamgram/marmota
# 点击 Fork 按钮

# 2. Clone 到本地
cd ~/Desktop/echo
git clone https://github.com/jackyang1989/echo-marmota.git
cd echo-marmota

# 3. 配置 remote
git remote rename origin upstream
git remote add origin https://github.com/jackyang1989/echo-marmota.git

# 4. 查看当前版本
git tag | grep v0.1.22
# 如果没有 tag，查看最新 commit
git log --oneline -10
```

### 2. 品牌重命名

```bash
cd echo-marmota

# 1. 修改 go.mod
sed -i '' 's|module github.com/teamgram/marmota|module github.com/jackyang1989/echo-marmota|g' go.mod

# 2. 替换所有 import 路径
find . -name "*.go" -type f -exec sed -i '' 's|github.com/teamgram/marmota|github.com/jackyang1989/echo-marmota|g' {} +

# 3. 替换版权声明（如果有）
find . -name "*.go" -type f -exec sed -i '' 's|Copyright (c) 2021-present, Teamgram Studio|Copyright (c) 2026-present, Echo Technologies|g' {} +
find . -name "*.go" -type f -exec sed -i '' 's|Copyright (c) 2021-present, NebulaChat Studio|Copyright (c) 2026-present, Echo Technologies|g' {} +

# 4. 提交更改
git add .
git commit -m "rebrand: Teamgram → Echo, update module name to jackyang1989/echo-marmota"

# 5. 打 tag
git tag v1.0.0
git tag v0.1.22-echo  # 保持与上游版本号的对应关系

# 6. 推送到 GitHub
git push origin main
git push origin --tags
```

### 3. 更新 echo-server 依赖

```bash
cd ~/Desktop/echo/echo-server

# 1. 修改 go.mod
# 将 github.com/teamgram/marmota v0.1.22
# 改为 github.com/jackyang1989/echo-marmota v1.0.0

# 2. 更新 import 路径
sed -i '' 's|github.com/teamgram/marmota|github.com/jackyang1989/echo-marmota|g' internal/gateway/server.go

# 3. 更新依赖
go mod tidy

# 4. 测试编译
go build -o bin/gateway ./cmd/gateway

# 5. 提交更改
git add .
git commit -m "deps: replace teamgram/marmota with jackyang1989/echo-marmota v1.0.0"
git push origin main
```

---

## 验证清单

- [ ] Fork 仓库成功
- [ ] 修改 module 名称
- [ ] 替换所有 import 路径
- [ ] 替换版权声明
- [ ] 打 tag v1.0.0
- [ ] 推送到 GitHub
- [ ] 更新 echo-server 依赖
- [ ] 更新 echo-server import 路径
- [ ] 编译成功
- [ ] 运行品牌检查脚本通过

---

## 预期结果

### 依赖关系

```
echo-server (github.com/jackyang1989/echo-server)
├── echo-proto v1.0.1 (github.com/jackyang1989/echo-proto) ✅
├── echo-marmota v1.0.0 (github.com/jackyang1989/echo-marmota) ✅ 新增
├── gnet/v2 (github.com/panjf2000/gnet/v2) ✅
├── pgx/v5 (github.com/jackc/pgx/v5) ✅
└── ... (其他第三方库)
```

### 品牌独立性

| 项目 | 品牌独立性 | 说明 |
|------|-----------|------|
| echo-proto | ✅ 100% | 完全独立，无上游品牌引用 |
| echo-marmota | ✅ 100% | 完全独立，无上游品牌引用 |
| echo-server | ✅ 100% | 完全独立，无上游品牌引用 |

---

## 时间估算

- Fork 和配置: 5 分钟
- 品牌重命名: 10 分钟
- 更新 echo-server: 5 分钟
- 测试验证: 5 分钟

**总计**: 约 25 分钟

---

**创建时间**: 2026-02-02  
**状态**: 待执行  
**优先级**: 高（消除上游删库风险）
