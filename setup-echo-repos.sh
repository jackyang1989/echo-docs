#!/bin/bash
# Echo 仓库设置脚本 - 修正依赖风险
# 目标：将所有上游依赖 Fork 到自己的仓库，避免删库风险

set -e

echo "🚀 开始设置 Echo 仓库..."

# =====================================================
# 步骤 1：设置 echo-proto（MTProto 协议库）
# =====================================================
echo ""
echo "📦 步骤 1：设置 echo-proto"
echo "----------------------------------------"

cd echo-proto

# 检查当前 remote
echo "当前 remote 配置："
git remote -v

# 添加上游仓库（用于后续更新）
if ! git remote | grep -q "upstream"; then
    echo "添加 upstream remote..."
    git remote add upstream https://github.com/teamgram/proto.git
fi

# 设置自己的仓库为 origin
echo "设置 origin 为你的仓库..."
git remote set-url origin https://github.com/jackyang1989/echo-proto.git

# 获取当前 commit hash
CURRENT_COMMIT=$(git log -1 --format="%H")
echo "当前 commit: $CURRENT_COMMIT"

# 打 tag 固定版本（Layer 221）
echo "打 tag v1.0.0-layer221..."
git tag -f v1.0.0-layer221
git tag -f v1.0.0  # 也打一个简短版本

echo "✅ echo-proto 配置完成"
echo "请手动执行以下命令推送到你的仓库："
echo "  cd echo-proto"
echo "  git push -u origin main"
echo "  git push origin v1.0.0-layer221"
echo "  git push origin v1.0.0"

# =====================================================
# 步骤 2：设置 echo-server
# =====================================================
echo ""
echo "📦 步骤 2：设置 echo-server"
echo "----------------------------------------"

cd ../echo-server

# 检查当前 remote
echo "当前 remote 配置："
git remote -v || echo "尚未初始化 git"

# 初始化 git（如果还没有）
if [ ! -d ".git" ]; then
    echo "初始化 git 仓库..."
    git init
    git add .
    git commit -m "Initial commit - Week 1 Gateway implementation"
fi

# 设置自己的仓库为 origin
echo "设置 origin 为你的仓库..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/jackyang1989/echo-server.git

echo "✅ echo-server 配置完成"
echo "请手动执行以下命令推送到你的仓库："
echo "  cd echo-server"
echo "  git push -u origin main"

# =====================================================
# 步骤 3：修改 echo-server 的 go.mod
# =====================================================
echo ""
echo "📦 步骤 3：修改 echo-server 的 go.mod"
echo "----------------------------------------"

cd ../echo-server

echo "修改 go.mod 使用你自己的 echo-proto..."

# 备份原 go.mod
cp go.mod go.mod.backup

# 修改 module 名称
sed -i '' 's|module github.com/echo/echo-server|module github.com/jackyang1989/echo-server|g' go.mod

# 修改 replace 指向你的仓库
cat > go.mod.new << 'EOF'
module github.com/jackyang1989/echo-server

go 1.21

require (
	// Database
	github.com/jackc/pgx/v5 v5.5.5

	// WebSocket
	github.com/gobwas/httphead v0.1.0
	github.com/gobwas/ws v1.3.1

	// Network
	github.com/panjf2000/gnet/v2 v2.3.3
	github.com/pkg/errors v0.9.1

	// Logging
	github.com/rs/zerolog v1.31.0
	github.com/stretchr/testify v1.9.0

	// Protocol - 使用你自己的 Fork
	github.com/jackyang1989/echo-proto v1.0.0

	github.com/valyala/bytebufferpool v1.0.0

	// gRPC
	google.golang.org/grpc v1.65.0

	// Crypto & Utils
	google.golang.org/protobuf v1.36.5
	gopkg.in/yaml.v3 v3.0.1
)

require (
	github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
	github.com/gobwas/pool v0.2.1 // indirect
	github.com/kr/pretty v0.3.1 // indirect
	github.com/mattn/go-colorable v0.1.13 // indirect
	github.com/mattn/go-isatty v0.0.19 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	go.uber.org/atomic v1.7.0 // indirect
	go.uber.org/multierr v1.6.0 // indirect
	go.uber.org/zap v1.21.0 // indirect
	golang.org/x/crypto v0.23.0 // indirect
	golang.org/x/net v0.25.0 // indirect
	golang.org/x/sync v0.8.0 // indirect
	golang.org/x/sys v0.26.0 // indirect
	golang.org/x/text v0.19.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240528184218-531527333157 // indirect
	gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c // indirect
	gopkg.in/natefinch/lumberjack.v2 v2.2.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
)

// 暂时使用本地路径，推送到 GitHub 后改为远程
replace github.com/jackyang1989/echo-proto => ../echo-proto
EOF

mv go.mod.new go.mod

echo "✅ go.mod 已更新"
echo "原 go.mod 已备份为 go.mod.backup"

# =====================================================
# 步骤 4：批量替换 import 路径
# =====================================================
echo ""
echo "📦 步骤 4：批量替换 import 路径"
echo "----------------------------------------"

echo "替换所有 Go 文件中的 import 路径..."

# 替换 teamgram/proto 为 jackyang1989/echo-proto
find . -name "*.go" -type f -exec sed -i '' 's|github.com/teamgram/proto|github.com/jackyang1989/echo-proto|g' {} +

# 替换 echo/echo-server 为 jackyang1989/echo-server
find . -name "*.go" -type f -exec sed -i '' 's|github.com/echo/echo-server|github.com/jackyang1989/echo-server|g' {} +

echo "✅ import 路径已更新"

# =====================================================
# 总结
# =====================================================
echo ""
echo "🎉 设置完成！"
echo "========================================"
echo ""
echo "📋 下一步操作："
echo ""
echo "1. 推送 echo-proto 到你的 GitHub："
echo "   cd echo-proto"
echo "   git push -u origin main"
echo "   git push origin v1.0.0-layer221"
echo "   git push origin v1.0.0"
echo ""
echo "2. 推送 echo-server 到你的 GitHub："
echo "   cd echo-server"
echo "   git add ."
echo "   git commit -m 'fix: update imports to use forked repos'"
echo "   git push -u origin main"
echo ""
echo "3. 修改 echo-server/go.mod 的 replace："
echo "   将 'replace github.com/jackyang1989/echo-proto => ../echo-proto'"
echo "   改为 'replace github.com/jackyang1989/echo-proto => github.com/jackyang1989/echo-proto v1.0.0'"
echo "   或者直接删除 replace 行（使用远程版本）"
echo ""
echo "4. 运行 go mod tidy："
echo "   cd echo-server"
echo "   export GOPROXY=https://goproxy.cn,direct"
echo "   go mod tidy"
echo ""
echo "⚠️  重要提示："
echo "- 现在你的代码依赖你自己的 Fork，不再依赖上游"
echo "- 即使上游删库，你的项目也不受影响"
echo "- 后续需要更新时，从 upstream 拉取更新即可"
echo ""
