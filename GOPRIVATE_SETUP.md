# Go 私有仓库配置指南

## 背景

由于 `echo-proto` 和 `marmota` 仓库都是私有的，Go 默认会尝试从公共代理和校验和数据库获取模块，这会导致 404 错误。

需要配置 `GOPRIVATE` 环境变量，告诉 Go 这些是私有仓库。

---

## 方法 1: 永久配置（推荐）

### 使用 go env 配置

```bash
# 配置私有仓库列表（逗号分隔）
go env -w GOPRIVATE=github.com/jackyang1989/echo-proto,github.com/jackyang1989/marmota

# 或者使用通配符（推荐）
go env -w GOPRIVATE=github.com/jackyang1989/*

# 查看配置
go env GOPRIVATE
```

**优点**：
- 永久生效
- 所有项目都适用
- 不需要每次设置

---

## 方法 2: Shell 环境变量

### macOS/Linux (zsh)

编辑 `~/.zshrc`：

```bash
# 添加以下行
export GOPRIVATE=github.com/jackyang1989/*

# 保存后重新加载
source ~/.zshrc
```

### macOS/Linux (bash)

编辑 `~/.bashrc` 或 `~/.bash_profile`：

```bash
# 添加以下行
export GOPRIVATE=github.com/jackyang1989/*

# 保存后重新加载
source ~/.bashrc
```

---

## 方法 3: 临时设置（不推荐）

每次编译前设置：

```bash
export GOPRIVATE=github.com/jackyang1989/*
go build -o bin/gateway ./cmd/gateway
```

**缺点**：
- 每次打开新终端都要重新设置
- 容易忘记

---

## 验证配置

### 1. 检查 GOPRIVATE 配置

```bash
go env GOPRIVATE
# 应该输出: github.com/jackyang1989/*
```

### 2. 清理缓存并重新下载

```bash
# 清理模块缓存
go clean -modcache

# 重新下载依赖
cd echo-server
go mod download

# 编译测试
go build -o bin/gateway ./cmd/gateway
```

### 3. 验证依赖

```bash
cd echo-server
go list -m all | grep jackyang1989

# 应该看到:
# github.com/jackyang1989/echo-proto v1.0.2
# github.com/jackyang1989/marmota v1.0.0
```

---

## 常见问题

### Q1: 仍然报 404 错误

**原因**: GOPRIVATE 配置未生效

**解决方案**:
```bash
# 1. 确认配置
go env GOPRIVATE

# 2. 如果为空，重新配置
go env -w GOPRIVATE=github.com/jackyang1989/*

# 3. 清理缓存
go clean -modcache

# 4. 重新下载
cd echo-server
go mod download
```

### Q2: Git 认证失败

**原因**: GitHub 私有仓库需要认证

**解决方案**:

#### 方法 A: 使用 SSH (推荐)

```bash
# 1. 配置 Git 使用 SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"

# 2. 确保 SSH key 已添加到 GitHub
ssh -T git@github.com
# 应该看到: Hi jackyang1989! You've successfully authenticated...
```

#### 方法 B: 使用 Personal Access Token

```bash
# 1. 在 GitHub 创建 Personal Access Token
# Settings → Developer settings → Personal access tokens → Generate new token
# 权限: repo (Full control of private repositories)

# 2. 配置 Git 凭据
git config --global credential.helper store

# 3. 第一次 clone 时输入用户名和 token
# Username: jackyang1989
# Password: <your_personal_access_token>
```

### Q3: go mod tidy 很慢

**原因**: Go 尝试从公共代理下载

**解决方案**:
```bash
# 禁用代理（如果在国内）
go env -w GOPROXY=direct

# 或者使用国内代理但排除私有仓库
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOPRIVATE=github.com/jackyang1989/*
```

---

## 推荐配置（一次性设置）

```bash
# 1. 配置私有仓库
go env -w GOPRIVATE=github.com/jackyang1989/*

# 2. 配置 Git 使用 SSH
git config --global url."git@github.com:".insteadOf "https://github.com/"

# 3. 配置代理（可选，国内用户推荐）
go env -w GOPROXY=https://goproxy.cn,direct

# 4. 验证配置
go env | grep -E "GOPRIVATE|GOPROXY"

# 5. 清理缓存
go clean -modcache

# 6. 测试编译
cd echo-server
go mod download
go build -o bin/gateway ./cmd/gateway
```

---

## CI/CD 配置

如果使用 GitHub Actions，需要在 workflow 中配置：

```yaml
- name: Setup Go
  uses: actions/setup-go@v4
  with:
    go-version: '1.21'

- name: Configure Git for private repos
  run: |
    git config --global url."https://${{ secrets.GH_TOKEN }}@github.com/".insteadOf "https://github.com/"

- name: Set GOPRIVATE
  run: |
    go env -w GOPRIVATE=github.com/jackyang1989/*

- name: Build
  run: |
    cd echo-server
    go build -o bin/gateway ./cmd/gateway
```

需要在 GitHub Secrets 中添加 `GH_TOKEN`（Personal Access Token）。

---

## 总结

**最简单的配置（推荐）**：

```bash
# 一次性执行
go env -w GOPRIVATE=github.com/jackyang1989/*
git config --global url."git@github.com:".insteadOf "https://github.com/"

# 验证
go env GOPRIVATE
ssh -T git@github.com

# 测试
cd echo-server
go clean -modcache
go build -o bin/gateway ./cmd/gateway
```

配置完成后，所有 `github.com/jackyang1989/*` 下的私有仓库都能正常使用了！

---

**创建时间**: 2026-02-02  
**适用于**: macOS, Linux  
**Go 版本**: 1.21+
