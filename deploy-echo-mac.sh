#!/bin/bash

# Echo 本地部署脚本 (macOS)
# 用于在 Mac 上部署 Echo 服务端和 Telegram Android 客户端

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="${SCRIPT_DIR}/echo-server-source"
CLIENT_DIR="${SCRIPT_DIR}/Telegram-master"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Echo 本地部署脚本 (macOS)${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查必要工具
check_requirements() {
    echo -e "\n${YELLOW}[1/6] 检查系统依赖...${NC}"
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: 未安装 Docker${NC}"
        echo "请访问 https://docs.docker.com/desktop/install/mac-install/ 安装 Docker Desktop"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! docker compose version &> /dev/null; then
        echo -e "${RED}错误: Docker Compose 不可用${NC}"
        exit 1
    fi
    
    # 检查 Docker 是否运行
    if ! docker info &> /dev/null; then
        echo -e "${RED}错误: Docker 未运行，请启动 Docker Desktop${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker 已安装并运行${NC}"
    
    # 检查 Java (Android 开发需要)
    if ! command -v java &> /dev/null; then
        echo -e "${YELLOW}警告: 未检测到 Java，Android 客户端编译需要 JDK 17+${NC}"
        echo "建议安装: brew install openjdk@17"
    else
        echo -e "${GREEN}✓ Java 已安装${NC}"
    fi
    
    # 检查 Android Studio (可选)
    if [ -d "/Applications/Android Studio.app" ]; then
        echo -e "${GREEN}✓ Android Studio 已安装${NC}"
    else
        echo -e "${YELLOW}警告: 未检测到 Android Studio${NC}"
        echo "Android 客户端开发建议安装 Android Studio"
    fi
}

# 部署服务端依赖
deploy_server_dependencies() {
    echo -e "\n${YELLOW}[2/6] 部署服务端依赖 (MySQL, Redis, Kafka, etcd, MinIO)...${NC}"
    
    cd "${SERVER_DIR}"
    
    # 停止并清理旧容器
    echo "停止旧容器..."
    docker compose -f docker-compose-env.yaml down 2>/dev/null || true
    
    # 启动依赖服务
    echo "启动依赖服务..."
    docker compose -f docker-compose-env.yaml up -d
    
    echo -e "${GREEN}✓ 依赖服务已启动${NC}"
    echo "  - MySQL: 127.0.0.1:3306 (用户: root, 密码: my_root_secret)"
    echo "  - Redis: 127.0.0.1:6379"
    echo "  - Kafka: 127.0.0.1:9092"
    echo "  - etcd: 127.0.0.1:2379"
    echo "  - MinIO: 127.0.0.1:9000 (控制台: 127.0.0.1:9001)"
}

# 等待服务就绪
wait_for_services() {
    echo -e "\n${YELLOW}[3/6] 等待服务就绪...${NC}"
    
    # 等待 MySQL
    echo -n "等待 MySQL 启动..."
    for i in {1..30}; do
        if docker exec mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
            echo -e " ${GREEN}✓${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # 等待 Redis
    echo -n "等待 Redis 启动..."
    for i in {1..30}; do
        if docker exec redis redis-cli ping 2>/dev/null | grep -q PONG; then
            echo -e " ${GREEN}✓${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # 等待 MinIO
    echo -n "等待 MinIO 启动..."
    for i in {1..30}; do
        if curl -s http://127.0.0.1:9000/minio/health/live &>/dev/null; then
            echo -e " ${GREEN}✓${NC}"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    sleep 5
    echo -e "${GREEN}✓ 所有服务已就绪${NC}"
}

# 初始化数据库
init_database() {
    echo -e "\n${YELLOW}[4/6] 初始化数据库...${NC}"
    
    cd "${SERVER_DIR}"
    
    # 检查数据库是否已初始化
    if docker exec mysql mysql -uroot -pmy_root_secret -e "USE echo; SELECT COUNT(*) FROM users;" 2>/dev/null; then
        echo -e "${YELLOW}数据库已存在，跳过初始化${NC}"
        return
    fi
    
    echo "执行数据库初始化脚本..."
    
    # 等待 MySQL 完全就绪
    sleep 5
    
    # 数据库初始化会通过 docker-compose-env.yaml 中的 volume 自动执行
    # SQL 文件在 ./echod/sql 目录会被自动挂载到容器的 /docker-entrypoint-initdb.d/
    
    echo -e "${GREEN}✓ 数据库初始化完成${NC}"
}

# 初始化 MinIO buckets
init_minio() {
    echo -e "\n${YELLOW}[5/6] 初始化 MinIO 存储桶...${NC}"
    
    cd "${SERVER_DIR}"
    
    # 等待 minio_mc 容器完成初始化
    sleep 5
    
    # 检查 minio_init.sh 脚本
    if [ -f "minio_init.sh" ]; then
        echo -e "${GREEN}✓ MinIO 初始化脚本已执行${NC}"
    else
        echo -e "${YELLOW}警告: minio_init.sh 不存在，需要手动创建存储桶${NC}"
        echo "需要创建的存储桶: documents, encryptedfiles, photos, videos"
    fi
}

# 构建并启动服务端
build_and_start_server() {
    echo -e "\n${YELLOW}[6/6] 构建并启动 Echo 服务端...${NC}"
    
    cd "${SERVER_DIR}"
    
    # 检查 Go 环境
    if ! command -v go &> /dev/null; then
        echo -e "${RED}错误: 未安装 Go${NC}"
        echo "请安装 Go 1.21+: brew install go"
        exit 1
    fi
    
    echo "Go 版本: $(go version)"
    
    # 构建服务
    echo "构建服务..."
    make clean
    make
    
    # 启动服务
    echo "启动 Echo 服务..."
    cd echod/bin
    
    # 后台启动
    nohup ./runall2.sh > ../../logs/echo.log 2>&1 &
    
    echo -e "${GREEN}✓ Echo 服务已启动${NC}"
    echo "  - Gateway: 127.0.0.1:10443"
    echo "  - HTTP API: 127.0.0.1:8801"
    echo "  - 日志文件: ${SERVER_DIR}/echod/logs/echo.log"
}

# 显示客户端配置说明
show_client_instructions() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}  服务端部署完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    echo -e "\n${YELLOW}Android 客户端配置步骤:${NC}"
    echo "1. 打开 Android Studio"
    echo "2. 打开项目: ${CLIENT_DIR}"
    echo "3. 配置 API 凭证:"
    echo "   - 访问 https://my.telegram.org 获取 api_id 和 api_hash"
    echo "   - 编辑文件: ${CLIENT_DIR}/TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java"
    echo "   - 填写 API_ID 和 API_HASH"
    echo ""
    echo "4. 修改服务器地址:"
    echo "   - 在 BuildVars.java 中设置:"
    echo "     PRODUCTION_SERVER = \"127.0.0.1:10443\""
    echo ""
    echo "5. 配置 Firebase (可选):"
    echo "   - 访问 https://console.firebase.google.com/"
    echo "   - 下载 google-services.json 到 ${CLIENT_DIR}/TMessagesProj/"
    echo ""
    echo "6. 编译运行:"
    echo "   - 在 Android Studio 中点击 Run"
    echo "   - 或使用命令: cd ${CLIENT_DIR} && ./gradlew assembleDebug"
    
    echo -e "\n${YELLOW}服务管理命令:${NC}"
    echo "  查看服务状态: docker compose -f ${SERVER_DIR}/docker-compose-env.yaml ps"
    echo "  查看日志: docker compose -f ${SERVER_DIR}/docker-compose-env.yaml logs -f"
    echo "  停止服务: docker compose -f ${SERVER_DIR}/docker-compose-env.yaml down"
    echo "  重启服务: docker compose -f ${SERVER_DIR}/docker-compose-env.yaml restart"
    
    echo -e "\n${YELLOW}访问地址:${NC}"
    echo "  MinIO 控制台: http://127.0.0.1:9001 (用户: minio, 密码: miniostorage)"
    echo "  MySQL: 127.0.0.1:3306 (用户: root, 密码: my_root_secret)"
    
    echo -e "\n${YELLOW}默认验证码: 12345${NC}"
}

# 主流程
main() {
    check_requirements
    deploy_server_dependencies
    wait_for_services
    init_database
    init_minio
    
    # 询问是否构建服务端
    echo -e "\n${YELLOW}是否现在构建并启动 Echo 服务端? (需要 Go 1.21+)${NC}"
    read -p "输入 y 继续，n 跳过: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_and_start_server
    else
        echo -e "${YELLOW}跳过服务端构建，你可以稍后手动执行:${NC}"
        echo "  cd ${SERVER_DIR}"
        echo "  make"
        echo "  cd echod/bin && ./runall2.sh"
    fi
    
    show_client_instructions
}

# 执行主流程
main
