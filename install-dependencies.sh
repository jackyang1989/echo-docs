#!/bin/bash
# Echo 开发环境自动安装脚本 (macOS Apple Silicon)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Echo 开发环境安装向导${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查 Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}错误: 未安装 Homebrew${NC}"
    exit 1
fi

echo -e "\n${BLUE}检测到你的系统:${NC}"
echo "  - macOS $(sw_vers -productVersion)"
echo "  - 架构: $(uname -m)"
echo "  - Homebrew: $(brew --version | head -n1)"

# 1. 安装 Go
echo -e "\n${YELLOW}[1/4] 安装 Go 1.21+${NC}"
if command -v go &> /dev/null; then
    echo -e "${GREEN}✓ Go 已安装: $(go version)${NC}"
else
    echo "正在安装 Go..."
    brew install go
    echo -e "${GREEN}✓ Go 安装完成${NC}"
fi

# 2. 安装 Java (OpenJDK 17)
echo -e "\n${YELLOW}[2/4] 安装 Java/JDK 17${NC}"
if command -v java &> /dev/null && java -version 2>&1 | grep -q "17"; then
    echo -e "${GREEN}✓ Java 17 已安装${NC}"
else
    echo "正在安装 OpenJDK 17..."
    brew install openjdk@17
    
    # 配置环境变量
    echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    
    echo -e "${GREEN}✓ Java 17 安装完成${NC}"
fi

# 3. 安装 Docker Desktop
echo -e "\n${YELLOW}[3/4] 安装 Docker Desktop${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker 已安装: $(docker --version)${NC}"
else
    echo "正在下载 Docker Desktop..."
    echo -e "${BLUE}提示: Docker Desktop 需要手动安装${NC}"
    echo ""
    echo "请按照以下步骤操作:"
    echo "1. 访问: https://docs.docker.com/desktop/install/mac-install/"
    echo "2. 下载 'Docker Desktop for Mac with Apple silicon'"
    echo "3. 安装并启动 Docker Desktop"
    echo "4. 等待 Docker 启动完成（菜单栏会显示 Docker 图标）"
    echo ""
    read -p "按回车键继续安装其他软件..."
fi

# 4. 安装 Android Studio
echo -e "\n${YELLOW}[4/4] 安装 Android Studio${NC}"
if [ -d "/Applications/Android Studio.app" ]; then
    echo -e "${GREEN}✓ Android Studio 已安装${NC}"
else
    echo "正在下载 Android Studio..."
    echo -e "${BLUE}提示: Android Studio 需要手动安装${NC}"
    echo ""
    echo "请按照以下步骤操作:"
    echo "1. 访问: https://developer.android.com/studio"
    echo "2. 下载 'Android Studio for Mac (Apple Silicon)'"
    echo "3. 安装 Android Studio"
    echo "4. 首次启动时安装以下组件:"
    echo "   - Android SDK API 35"
    echo "   - Android SDK Build-Tools"
    echo "   - Android NDK 21.4.7075529"
    echo ""
    read -p "按回车键继续..."
fi

# 安装其他有用的工具
echo -e "\n${YELLOW}[可选] 安装其他开发工具${NC}"
read -p "是否安装 MySQL 客户端、Redis 客户端等工具? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "安装 MySQL 客户端..."
    brew install mysql-client
    
    echo "安装 Redis 客户端..."
    brew install redis
    
    echo "安装 wget..."
    brew install wget
    
    echo -e "${GREEN}✓ 开发工具安装完成${NC}"
fi

# 验证安装
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  安装验证${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${BLUE}已安装的软件:${NC}"

if command -v go &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Go: $(go version | awk '{print $3}')"
else
    echo -e "  ${RED}✗${NC} Go: 未安装"
fi

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n1 | awk -F '"' '{print $2}')
    echo -e "  ${GREEN}✓${NC} Java: $JAVA_VERSION"
else
    echo -e "  ${RED}✗${NC} Java: 未安装"
fi

if command -v docker &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Docker: $(docker --version | awk '{print $3}' | tr -d ',')"
    if docker info &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Docker 正在运行"
    else
        echo -e "  ${YELLOW}⚠${NC} Docker 未运行，请启动 Docker Desktop"
    fi
else
    echo -e "  ${RED}✗${NC} Docker: 未安装"
fi

if [ -d "/Applications/Android Studio.app" ]; then
    echo -e "  ${GREEN}✓${NC} Android Studio: 已安装"
else
    echo -e "  ${YELLOW}⚠${NC} Android Studio: 未安装"
fi

# 下一步提示
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  下一步${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}如果 Docker 或 Android Studio 需要手动安装:${NC}"
echo ""
echo "1. Docker Desktop (必需):"
echo "   下载: https://docs.docker.com/desktop/install/mac-install/"
echo "   选择: Docker Desktop for Mac with Apple silicon"
echo ""
echo "2. Android Studio (必需):"
echo "   下载: https://developer.android.com/studio"
echo "   选择: Mac (Apple Silicon)"
echo ""
echo "3. 安装完成后，运行以下命令验证:"
echo "   docker --version"
echo "   docker info"
echo ""
echo "4. 然后运行部署脚本:"
echo "   ./quick-deploy.sh"

echo -e "\n${BLUE}提示: 安装完成后需要重启终端使环境变量生效${NC}"
