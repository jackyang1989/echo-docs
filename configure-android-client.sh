#!/bin/bash

# Android 客户端配置脚本
# 用于配置 Telegram Android 客户端连接到本地 Echo 服务器

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_DIR="${SCRIPT_DIR}/Telegram-master"
BUILD_VARS_FILE="${CLIENT_DIR}/TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Android 客户端配置向导${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查客户端目录
if [ ! -d "${CLIENT_DIR}" ]; then
    echo -e "${RED}错误: 找不到客户端目录 ${CLIENT_DIR}${NC}"
    exit 1
fi

# 获取 API 凭证
echo -e "\n${YELLOW}步骤 1: 配置 Telegram API 凭证${NC}"
echo "请访问 https://my.telegram.org 获取 API 凭证"
echo ""

read -p "请输入 API_ID (数字): " API_ID
read -p "请输入 API_HASH (字符串): " API_HASH

if [ -z "$API_ID" ] || [ -z "$API_HASH" ]; then
    echo -e "${RED}错误: API_ID 和 API_HASH 不能为空${NC}"
    exit 1
fi

# 配置服务器地址
echo -e "\n${YELLOW}步骤 2: 配置服务器地址${NC}"
echo "默认本地服务器: 127.0.0.1:10443"
read -p "使用默认地址? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    SERVER_HOST="127.0.0.1"
    SERVER_PORT="10443"
else
    read -p "请输入服务器地址 (如 192.168.1.100): " SERVER_HOST
    read -p "请输入服务器端口 (默认 10443): " SERVER_PORT
    SERVER_PORT=${SERVER_PORT:-10443}
fi

# 备份原文件
echo -e "\n${YELLOW}步骤 3: 备份和修改配置文件${NC}"

if [ -f "${BUILD_VARS_FILE}" ]; then
    BACKUP_FILE="${BUILD_VARS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "${BUILD_VARS_FILE}" "${BACKUP_FILE}"
    echo -e "${GREEN}✓ 已备份原文件到: ${BACKUP_FILE}${NC}"
else
    echo -e "${RED}错误: 找不到 BuildVars.java 文件${NC}"
    exit 1
fi

# 创建配置说明
cat > "${CLIENT_DIR}/LOCAL_CONFIG.md" << EOF
# 本地配置说明

## API 凭证
- API_ID: ${API_ID}
- API_HASH: ${API_HASH}

## 服务器配置
- 服务器地址: ${SERVER_HOST}
- 服务器端口: ${SERVER_PORT}

## 配置时间
$(date)

## 修改的文件
- ${BUILD_VARS_FILE}

## 恢复原配置
如需恢复原配置，使用备份文件:
\`\`\`bash
cp ${BACKUP_FILE} ${BUILD_VARS_FILE}
\`\`\`

## 手动修改指南

如果自动配置失败，请手动编辑 BuildVars.java:

\`\`\`java
public class BuildVars {
    // 修改这些值
    public static final int APP_ID = ${API_ID};
    public static final String APP_HASH = "${API_HASH}";
    
    // 添加或修改服务器配置
    public static String PRODUCTION_SERVER = "${SERVER_HOST}";
    public static int PRODUCTION_PORT = ${SERVER_PORT};
    
    // 其他配置保持不变...
}
\`\`\`

## 验证码
默认验证码: 12345

## 编译命令
\`\`\`bash
cd ${CLIENT_DIR}
./gradlew assembleDebug
\`\`\`

## 安装命令
\`\`\`bash
adb install TMessagesProj_App/build/outputs/apk/debug/app-debug.apk
\`\`\`
EOF

echo -e "${GREEN}✓ 配置说明已保存到: ${CLIENT_DIR}/LOCAL_CONFIG.md${NC}"

# 显示下一步操作
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  配置完成！${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}重要提示:${NC}"
echo "1. 请手动编辑文件: ${BUILD_VARS_FILE}"
echo "   修改以下内容:"
echo "   - APP_ID = ${API_ID}"
echo "   - APP_HASH = \"${API_HASH}\""
echo "   - 添加服务器配置 (参考 LOCAL_CONFIG.md)"
echo ""
echo "2. 配置 Firebase (可选):"
echo "   - 访问 https://console.firebase.google.com/"
echo "   - 下载 google-services.json"
echo "   - 复制到: ${CLIENT_DIR}/TMessagesProj/"
echo ""
echo "3. 编译应用:"
echo "   cd ${CLIENT_DIR}"
echo "   ./gradlew assembleDebug"
echo ""
echo "4. 安装到设备:"
echo "   adb install TMessagesProj_App/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "5. 测试登录:"
echo "   - 输入任意手机号"
echo "   - 验证码: 12345"

echo -e "\n${YELLOW}详细配置说明请查看: ${CLIENT_DIR}/LOCAL_CONFIG.md${NC}"
