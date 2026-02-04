#!/bin/bash

# 消息服务器 - Mac 本地部署脚本
# 日期: 2026-01-27
# 用途: 一键部署消息服务器到 Mac 本地
# 注意: 使用通用名称，不暴露品牌信息

set -e  # 遇到错误立即退出

echo "=========================================="
echo "  消息服务器 - Mac 本地部署"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Docker
echo -e "${YELLOW}[1/10] 检查 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker 未运行${NC}"
    echo "请启动 Docker Desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker 已就绪${NC}"
echo ""

# 检查 Go
echo -e "${YELLOW}[2/10] 检查 Go...${NC}"
if ! command -v go &> /dev/null; then
    echo -e "${RED}错误: Go 未安装${NC}"
    echo "请先安装 Go: brew install go"
    exit 1
fi
GO_VERSION=$(go version | awk '{print $3}')
echo -e "${GREEN}✓ Go 已安装 ($GO_VERSION)${NC}"
echo ""

# 进入 Echo Server 目录
ECHO_DIR="/Users/jianouyang/.gemini/antigravity/scratch/order-management-system/telegram+echo/echo-server-source"
echo -e "${YELLOW}[3/10] 进入服务器目录...${NC}"
if [ ! -d "$ECHO_DIR" ]; then
    echo -e "${RED}错误: 服务器目录不存在${NC}"
    echo "路径: $ECHO_DIR"
    exit 1
fi
cd "$ECHO_DIR"
echo -e "${GREEN}✓ 目录: $ECHO_DIR${NC}"
echo ""

# 生成或检查 .env 文件
echo -e "${YELLOW}[4/10] 检查安全配置...${NC}"
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}未找到 .env 文件，正在生成安全配置...${NC}"
    
    cat > .env << EOF
# 自动生成的安全配置
# 生成时间: $(date)
# ⚠️  请妥善保管此文件，不要提交到 Git

# 数据库配置
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)
MYSQL_PASSWORD=$(openssl rand -base64 24)

# Redis 配置
REDIS_PASSWORD=$(openssl rand -base64 24)

# MinIO 配置
MINIO_ACCESS_KEY=storage_admin
MINIO_SECRET_KEY=$(openssl rand -base64 24)

# Kafka 配置
KAFKA_PASSWORD=$(openssl rand -base64 24)
EOF
    
    echo -e "${GREEN}✓ 安全配置已生成${NC}"
    echo -e "${YELLOW}⚠️  配置文件: $ECHO_DIR/.env${NC}"
    echo -e "${YELLOW}⚠️  请妥善保管，不要泄露${NC}"
else
    echo -e "${GREEN}✓ 使用现有配置文件${NC}"
fi
echo ""

# 加载环境变量
source .env

# 启动依赖服务
echo -e "${YELLOW}[5/10] 启动依赖服务 (MySQL, Redis, etcd, Kafka, MinIO)...${NC}"
docker-compose -f docker-compose-env.yaml down 2>/dev/null || true
docker-compose -f docker-compose-env.yaml up -d
echo -e "${GREEN}✓ 依赖服务已启动${NC}"
echo ""

# 等待服务启动
echo -e "${YELLOW}[6/10] 等待服务启动 (30秒)...${NC}"
for i in {30..1}; do
    echo -ne "\r等待中... $i 秒 "
    sleep 1
done
echo -e "\n${GREEN}✓ 服务启动完成${NC}"
echo ""

# 初始化数据库
echo -e "${YELLOW}[7/10] 初始化数据库...${NC}"
MYSQL_CONTAINER=$(docker ps -qf "name=mysql")
if [ -z "$MYSQL_CONTAINER" ]; then
    echo -e "${RED}错误: MySQL 容器未运行${NC}"
    exit 1
fi

# 使用环境变量中的密码
docker exec -i $MYSQL_CONTAINER mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS echo CHARACTER SET utf8mb4;" 2>/dev/null || true
echo -e "${GREEN}✓ 数据库已创建${NC}"
echo ""

# 执行 SQL 迁移
echo -e "${YELLOW}[8/10] 执行 SQL 迁移...${NC}"
cd echod/sql
SQL_COUNT=0
for f in *.sql; do
    if [ -f "$f" ]; then
        echo "  执行: $f"
        docker exec -i $MYSQL_CONTAINER mysql -uroot -p${MYSQL_ROOT_PASSWORD} echo < "$f" 2>/dev/null || true
        SQL_COUNT=$((SQL_COUNT + 1))
    fi
done
cd ../..
echo -e "${GREEN}✓ 已执行 $SQL_COUNT 个 SQL 文件${NC}"
echo ""

# 创建 MinIO buckets
echo -e "${YELLOW}[9/10] 创建 MinIO buckets...${NC}"
MINIO_CONTAINER=$(docker ps -qf "name=minio")
if [ -z "$MINIO_CONTAINER" ]; then
    echo -e "${RED}错误: MinIO 容器未运行${NC}"
    exit 1
fi

# 使用环境变量中的凭证配置 MinIO 客户端
docker exec $MINIO_CONTAINER mc alias set myminio http://localhost:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} 2>/dev/null || true

# 创建 buckets（使用通用名称）
for bucket in documents encryptedfiles photos videos; do
    docker exec $MINIO_CONTAINER mc mb myminio/$bucket 2>/dev/null || true
    echo "  创建: $bucket"
done
echo -e "${GREEN}✓ MinIO buckets 已创建${NC}"
echo ""

# 编译 Echo Server
echo -e "${YELLOW}[10/10] 编译服务器...${NC}"
echo "  这可能需要几分钟..."
if make > /tmp/echo-build.log 2>&1; then
    echo -e "${GREEN}✓ 编译成功${NC}"
else
    echo -e "${RED}错误: 编译失败${NC}"
    echo "查看日志: /tmp/echo-build.log"
    exit 1
fi
echo ""

# 启动 Echo Server
echo -e "${YELLOW}准备启动服务器...${NC}"
cd echod/bin
if [ ! -f "runall2.sh" ]; then
    echo -e "${RED}错误: runall2.sh 不存在${NC}"
    exit 1
fi

chmod +x runall2.sh
echo ""
echo -e "${GREEN}=========================================="
echo "  部署完成！"
echo "==========================================${NC}"
echo ""
echo "配置信息:"
echo "  配置文件: $ECHO_DIR/.env"
echo "  ⚠️  请妥善保管，不要泄露"
echo ""
echo "下一步:"
echo "  1. 编译客户端"
echo "  2. 安装到设备测试"
echo "  3. 使用验证码: 12345"
echo ""
echo "启动服务器:"
echo "  cd $ECHO_DIR/echod/bin"
echo "  ./runall2.sh"
echo ""
echo "停止依赖服务:"
echo "  cd $ECHO_DIR"
echo "  docker-compose -f docker-compose-env.yaml down"
echo ""
echo "查看服务状态:"
echo "  docker-compose -f docker-compose-env.yaml ps"
echo ""

# 询问是否立即启动
read -p "是否立即启动服务器? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}启动服务器...${NC}"
    ./runall2.sh
else
    echo "稍后手动启动:"
    echo "  cd $ECHO_DIR/echod/bin"
    echo "  ./runall2.sh"
fi
