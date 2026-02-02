# Echo IM - 完全品牌化指南

**日期**: 2026-01-27  
**目标**: 将 Echo Server 完全品牌化为 Echo

---

## 🎯 品牌化原则

### 必须替换的内容

**所有出现 "echo" 的地方都要替换为 "echo"**

包括但不限于：
- ✅ Go 源码（.go 文件）
- ✅ 配置文件（.yaml, .json）
- ✅ 文档（.md, .txt）
- ✅ 注释
- ✅ 日志信息
- ✅ 错误信息
- ✅ 包名和导入路径
- ✅ 常量和变量名
- ✅ 数据库名
- ✅ 容器名
- ✅ 文件名和目录名

---

## 🔧 自动化品牌化脚本

### 完整替换脚本

**文件**: `echo-rebrand.sh`

```bash
#!/bin/bash

# Echo 品牌化脚本
# 用途: 将 Echo Server 完全品牌化为 Echo

set -e

echo "=========================================="
echo "  Echo 品牌化工具"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ECHO_DIR="/Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./echo-server-source"

# 检查目录
if [ ! -d "$ECHO_DIR" ]; then
    echo -e "${RED}错误: Echo 目录不存在${NC}"
    exit 1
fi

cd "$ECHO_DIR"

echo -e "${YELLOW}警告: 此操作将修改所有文件中的 'echo' 为 'echo'${NC}"
echo -e "${YELLOW}建议先备份源码！${NC}"
echo ""
read -p "是否继续? (yes/no) " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "已取消"
    exit 0
fi

echo ""
echo -e "${GREEN}开始品牌化...${NC}"
echo ""

# 1. 替换 Go 源码中的内容
echo -e "${YELLOW}[1/8] 替换 Go 源码...${NC}"
find . -type f -name "*.go" -not -path "./vendor/*" -not -path "./.git/*" | while read file; do
    # 替换包名
    sed -i '' 's/package echo/package echo/g' "$file"
    
    # 替换导入路径
    sed -i '' 's|github.com/echo/echo-server|github.com/echo/echo-server|g' "$file"
    
    # 替换变量名和常量
    sed -i '' 's/Echo/Echo/g' "$file"
    sed -i '' 's/echo/echo/g' "$file"
    sed -i '' 's/ECHO/ECHO/g' "$file"
    
    echo "  处理: $file"
done
echo -e "${GREEN}✓ Go 源码替换完成${NC}"
echo ""

# 2. 替换配置文件
echo -e "${YELLOW}[2/8] 替换配置文件...${NC}"
find . -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -not -path "./.git/*" | while read file; do
    sed -i '' 's/echo/echo/g' "$file"
    sed -i '' 's/Echo/Echo/g' "$file"
    sed -i '' 's/ECHO/ECHO/g' "$file"
    echo "  处理: $file"
done
echo -e "${GREEN}✓ 配置文件替换完成${NC}"
echo ""

# 3. 替换 SQL 文件
echo -e "${YELLOW}[3/8] 替换 SQL 文件...${NC}"
find . -type f -name "*.sql" -not -path "./.git/*" | while read file; do
    sed -i '' 's/echo/echodb/g' "$file"
    sed -i '' 's/Echo/Echo/g' "$file"
    echo "  处理: $file"
done
echo -e "${GREEN}✓ SQL 文件替换完成${NC}"
echo ""

# 4. 替换 Markdown 文档
echo -e "${YELLOW}[4/8] 替换文档...${NC}"
find . -type f -name "*.md" -not -path "./.git/*" | while read file; do
    sed -i '' 's/Echo/Echo/g' "$file"
    sed -i '' 's/echo/echo/g' "$file"
    echo "  处理: $file"
done
echo -e "${GREEN}✓ 文档替换完成${NC}"
echo ""

# 5. 替换 Makefile
echo -e "${YELLOW}[5/8] 替换 Makefile...${NC}"
find . -type f -name "Makefile*" -not -path "./.git/*" | while read file; do
    sed -i '' 's/echo/echo/g' "$file"
    sed -i '' 's/Echo/Echo/g' "$file"
    echo "  处理: $file"
done
echo -e "${GREEN}✓ Makefile 替换完成${NC}"
echo ""

# 6. 替换 Shell 脚本
echo -e "${YELLOW}[6/8] 替换 Shell 脚本...${NC}"
find . -type f -name "*.sh" -not -path "./.git/*" | while read file; do
    sed -i '' 's/echo/echo/g' "$file"
    sed -i '' 's/Echo/Echo/g' "$file"
    echo "  处理: $file"
done
echo -e "${GREEN}✓ Shell 脚本替换完成${NC}"
echo ""

# 7. 替换 go.mod
echo -e "${YELLOW}[7/8] 替换 go.mod...${NC}"
if [ -f "go.mod" ]; then
    sed -i '' 's|github.com/echo/echo-server|github.com/echo/echo-server|g' go.mod
    echo "  处理: go.mod"
fi
echo -e "${GREEN}✓ go.mod 替换完成${NC}"
echo ""

# 8. 重命名目录（可选）
echo -e "${YELLOW}[8/8] 检查需要重命名的目录...${NC}"
find . -type d -name "*echo*" -not -path "./.git/*" | while read dir; do
    newdir=$(echo "$dir" | sed 's/echo/echo/g')
    if [ "$dir" != "$newdir" ]; then
        echo "  重命名: $dir -> $newdir"
        mv "$dir" "$newdir"
    fi
done
echo -e "${GREEN}✓ 目录重命名完成${NC}"
echo ""

echo -e "${GREEN}=========================================="
echo "  品牌化完成！"
echo "==========================================${NC}"
echo ""
echo "统计信息:"
echo "  Go 文件: $(find . -name "*.go" -not -path "./vendor/*" -not -path "./.git/*" | wc -l | tr -d ' ')"
echo "  配置文件: $(find . \( -name "*.yaml" -o -name "*.yml" -o -name "*.json" \) -not -path "./.git/*" | wc -l | tr -d ' ')"
echo "  SQL 文件: $(find . -name "*.sql" -not -path "./.git/*" | wc -l | tr -d ' ')"
echo ""
echo "下一步:"
echo "  1. 检查替换结果: git diff"
echo "  2. 测试编译: make"
echo "  3. 提交更改: git add . && git commit -m 'Rebrand to Echo'"
echo ""
```

---

## 📝 手动检查清单

### 1. Go 源码检查

**检查项**:
```bash
# 搜索残留的 echo
grep -r "echo" --include="*.go" . | grep -v vendor | grep -v ".git"

# 搜索残留的 Echo
grep -r "Echo" --include="*.go" . | grep -v vendor | grep -v ".git"

# 搜索残留的 ECHO
grep -r "ECHO" --include="*.go" . | grep -v vendor | grep -v ".git"
```

**应该返回**: 无结果

### 2. 配置文件检查

```bash
# 检查 YAML 文件
grep -r "echo" --include="*.yaml" --include="*.yml" .

# 检查 JSON 文件
grep -r "echo" --include="*.json" .
```

**应该返回**: 无结果

### 3. 数据库名检查

```bash
# 检查 SQL 文件
grep -r "echo" --include="*.sql" .
```

**应该全部替换为**: `echodb`

### 4. 导入路径检查

```bash
# 检查 go.mod
cat go.mod | grep echo
```

**应该返回**: 无结果

### 5. 文档检查

```bash
# 检查 Markdown 文件
grep -r "echo" --include="*.md" . | grep -v ".git"
```

**应该返回**: 无结果（除了说明性文档）

---

## 🔍 关键文件替换示例

### 1. go.mod

**原始**:
```go
module github.com/echo/echo-server

go 1.21

require (
    github.com/echo/proto v1.0.0
)
```

**替换后**:
```go
module github.com/echo/echo-server

go 1.21

require (
    github.com/echo/proto v1.0.0
)
```

### 2. 配置文件 (session.yaml)

**原始**:
```yaml
Name: echo.session

Mysql:
  Datasource: echo:echo@tcp(mysql:3306)/echo?charset=utf8mb4

Etcd:
  Hosts:
    - etcd:2379
  Key: echo.session
```

**替换后**:
```yaml
Name: echo.session

Mysql:
  Datasource: echo_admin:${MYSQL_PASSWORD}@tcp(echo-db:3306)/echodb?charset=utf8mb4

Etcd:
  Hosts:
    - echo-registry:2379
  Key: echo.session
```

### 3. Go 源码示例

**原始**:
```go
package echo

import (
    "github.com/echo/echo-server/app/service/biz/user"
)

const (
    EchoVersion = "1.0.0"
    ServiceName     = "echo.session"
)

func NewEchoServer() *Server {
    log.Info("Starting Echo server...")
    return &Server{
        name: "echo",
    }
}
```

**替换后**:
```go
package echo

import (
    "github.com/echo/echo-server/app/service/biz/user"
)

const (
    EchoVersion = "1.0.0"
    ServiceName    = "echo.session"
)

func NewEchoServer() *Server {
    log.Info("Starting Echo server...")
    return &Server{
        name: "echo",
    }
}
```

### 4. SQL 文件

**原始**:
```sql
CREATE DATABASE IF NOT EXISTS echo CHARACTER SET utf8mb4;

USE echo;

CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    -- echo user table
);
```

**替换后**:
```sql
CREATE DATABASE IF NOT EXISTS echodb CHARACTER SET utf8mb4;

USE echodb;

CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    -- echo user table
);
```

---

## 🚀 执行步骤

### Step 1: 备份源码

```bash
cd /Users/jianouyang/.gemini/antigravity/scratch/echo

# 创建备份
cp -r echo-server-source echo-server-source.backup

echo "✅ 备份完成"
```

### Step 2: 执行品牌化脚本

```bash
cd /Users/jianouyang/.gemini/antigravity/scratch/order-management-system

# 创建脚本
cat > echo-rebrand.sh << 'EOF'
[脚本内容见上方]
EOF

# 添加执行权限
chmod +x echo-rebrand.sh

# 执行
./echo-rebrand.sh
```

### Step 3: 验证替换结果

```bash
cd ./echo-server-source

# 检查是否还有 echo 残留
echo "检查 Go 文件..."
grep -r "echo" --include="*.go" . | grep -v vendor | grep -v ".git" | wc -l

echo "检查配置文件..."
grep -r "echo" --include="*.yaml" --include="*.yml" . | wc -l

echo "检查 SQL 文件..."
grep -r "echo" --include="*.sql" . | wc -l

# 应该全部返回 0
```

### Step 4: 测试编译

```bash
cd ./echo-server-source

# 清理旧的构建
make clean

# 重新编译
make

# 检查编译结果
echo "✅ 编译成功" || echo "❌ 编译失败"
```

### Step 5: 提交更改（可选）

```bash
cd ./echo-server-source

# 查看更改
git diff

# 提交
git add .
git commit -m "Rebrand: Echo → Echo"
```

---

## ⚠️ 注意事项

### 1. 不要替换的内容

某些第三方库的引用不需要替换：
```go
// ✅ 保持不变
import "github.com/zeromicro/go-zero/core/conf"
import "google.golang.org/grpc"
```

### 2. 注释中的说明

如果注释是说明来源，可以保留：
```go
// ✅ 可以保留
// Based on Echo Server (https://github.com/echo/echo-server)
// Modified for Echo IM
```

### 3. 文档中的引用

在文档中提到原始项目时可以保留：
```markdown
✅ 可以保留
Echo is based on Echo Server, an open-source MTProto implementation.
```

---

## 📊 品牌化检查表

完成后确认：

- [ ] 所有 .go 文件中的 echo 已替换
- [ ] 所有 .yaml/.yml 文件中的 echo 已替换
- [ ] 所有 .sql 文件中的 echo 已替换
- [ ] go.mod 中的导入路径已更新
- [ ] 配置文件中的服务名已更新
- [ ] 数据库名已更新为 echodb
- [ ] 容器名已更新为 echo-*
- [ ] 编译成功
- [ ] 测试通过

---

## 🔄 回滚方案

如果出现问题，可以快速回滚：

```bash
cd /Users/jianouyang/.gemini/antigravity/scratch/echo

# 删除修改后的版本
rm -rf echo-server-source

# 恢复备份
cp -r echo-server-source.backup echo-server-source

echo "✅ 已回滚到原始版本"
```

---

## ✅ 总结

### 品牌化范围

**必须替换**:
- ✅ 所有代码中的 echo → echo
- ✅ 所有配置中的 echo → echo
- ✅ 所有文档中的 Echo → Echo
- ✅ 所有数据库名 echo → echodb
- ✅ 所有服务名 echo.* → echo.*

**可以保留**:
- ✅ 第三方库引用
- ✅ 说明来源的注释
- ✅ 文档中的历史引用

### 下一步

1. 执行品牌化脚本
2. 验证替换结果
3. 测试编译
4. 部署测试

---

**最后更新**: 2026-01-27  
**状态**: 品牌化指南完成
