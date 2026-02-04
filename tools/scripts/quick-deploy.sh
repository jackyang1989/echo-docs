#!/bin/bash
# 超简化部署脚本 - 只为本地开发

set -e

echo "🚀 启动 Echo 本地开发环境..."

# 1. 启动 Docker 服务
echo "📦 启动依赖服务..."
cd echo-server-source
docker compose -f docker-compose-env.yaml up -d

# 2. 等待服务就绪
echo "⏳ 等待服务启动（约 2 分钟）..."
sleep 120

# 3. 构建服务端
echo "🔨 构建 Echo 服务..."
make

# 4. 启动服务端
echo "🚀 启动 Echo 服务..."
cd echod/bin
nohup ./runall2.sh > ../logs/echo.log 2>&1 &

echo ""
echo "✅ 服务端已启动！"
echo ""
echo "📱 下一步："
echo "1. 用 Android Studio 打开: Telegram-master"
echo "2. 编辑: TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java"
echo "   - 填入你的 API_ID 和 API_HASH (从 https://my.telegram.org 获取)"
echo "   - 添加: PRODUCTION_SERVER = \"127.0.0.1\""
echo "   - 添加: PRODUCTION_PORT = 10443"
echo "3. 点击 Run 按钮"
echo "4. 登录时验证码输入: 12345"
echo ""
echo "🔍 查看日志: tail -f echo-server-source/echod/logs/*.log"
echo "🛑 停止服务: docker compose -f echo-server-source/docker-compose-env.yaml down"
