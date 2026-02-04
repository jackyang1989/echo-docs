#!/bin/bash

# Echo 项目文档全面修复脚本
# 修复所有文档中的过时信息

set -e

echo "========================================="
echo "  Echo 项目文档全面修复工具"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 项目结构说明：${NC}"
echo ""
echo "正确的项目结构："
echo "  1. echo-server-source/     - Echo 服务端（要部署的）"
echo "  2. teamgram-android/        - 参考项目（仅供参考，不部署）"
echo "  3. echo-android-client/     - Echo Android 客户端（要使用的）"
echo ""
echo "错误的理解："
echo "  ❌ echo-android-echo2 - 这个目录不存在或已重命名"
echo "  ❌ Telegram-master - 这个目录已重命名为 echo-android-client"
echo ""

read -p "确认开始修复？(yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "取消修复"
    exit 0
fi

echo ""
echo -e "${YELLOW}🔧 开始修复文档...${NC}"
echo ""

# 修复 ECHO_START_HERE.md
echo -e "${BLUE}修复 ECHO_START_HERE.md...${NC}"

# 修复客户端描述
sed -i '' 's/echo-android-echo2/teamgram-android/g' ECHO_START_HERE.md
sed -i '' 's/Telegram-master/echo-android-client/g' ECHO_START_HERE.md

# 修复路径
sed -i '' 's|telegram+echo/teamgram-android|teamgram-android|g' ECHO_START_HERE.md
sed -i '' 's|telegram+echo/echo-android-client|echo-android-client|g' ECHO_START_HERE.md
sed -i '' 's|telegram+echo/echo-server-source|echo-server-source|g' ECHO_START_HERE.md

echo "  ✓ ECHO_START_HERE.md"

# 修复 DEPLOYMENT_GUIDE_MAC.md
echo -e "${BLUE}修复 DEPLOYMENT_GUIDE_MAC.md...${NC}"

sed -i '' 's/Telegram-master/echo-android-client/g' DEPLOYMENT_GUIDE_MAC.md
sed -i '' 's|org/telegram/messenger|com/echo/messenger|g' DEPLOYMENT_GUIDE_MAC.md
sed -i '' 's|telegram+echo/|./|g' DEPLOYMENT_GUIDE_MAC.md

echo "  ✓ DEPLOYMENT_GUIDE_MAC.md"

# 修复 QUICK_START.md
if [ -f "QUICK_START.md" ]; then
    echo -e "${BLUE}修复 QUICK_START.md...${NC}"
    sed -i '' 's/Telegram-master/echo-android-client/g' QUICK_START.md
    sed -i '' 's/echo-android-echo2/teamgram-android/g' QUICK_START.md
    sed -i '' 's|telegram+echo/|./|g' QUICK_START.md
    echo "  ✓ QUICK_START.md"
fi

# 修复 README_DEPLOYMENT.md
if [ -f "README_DEPLOYMENT.md" ]; then
    echo -e "${BLUE}修复 README_DEPLOYMENT.md...${NC}"
    sed -i '' 's/Telegram-master/echo-android-client/g' README_DEPLOYMENT.md
    sed -i '' 's/echo-android-echo2/teamgram-android/g' README_DEPLOYMENT.md
    echo "  ✓ README_DEPLOYMENT.md"
fi

# 修复 docs/planning/ 目录
echo -e "${BLUE}修复 docs/planning/ 目录...${NC}"
if [ -d "docs/planning" ]; then
    find docs/planning -name "*.md" -type f -exec sed -i '' 's/echo-android-echo2/teamgram-android/g' {} \;
    find docs/planning -name "*.md" -type f -exec sed -i '' 's/Telegram-master/echo-android-client/g' {} \;
    find docs/planning -name "*.md" -type f -exec sed -i '' 's|telegram+echo/|./|g' {} \;
    echo "  ✓ docs/planning/"
fi

# 修复 docs/reference/ 目录
echo -e "${BLUE}修复 docs/reference/ 目录...${NC}"
if [ -d "docs/reference" ]; then
    # 注意：ECHO_ANDROID_CLIENT_REBRAND.md 是教程，保留 Telegram-master 作为示例
    find docs/reference -name "*.md" -type f ! -name "ECHO_ANDROID_CLIENT_REBRAND.md" -exec sed -i '' 's/echo-android-echo2/teamgram-android/g' {} \;
    find docs/reference -name "*.md" -type f ! -name "ECHO_ANDROID_CLIENT_REBRAND.md" -exec sed -i '' 's|telegram+echo/|./|g' {} \;
    echo "  ✓ docs/reference/"
fi

# 修复 docs/configuration/ 目录
echo -e "${BLUE}修复 docs/configuration/ 目录...${NC}"
if [ -d "docs/configuration" ]; then
    find docs/configuration -name "*.md" -type f -exec sed -i '' 's/echo-android-echo2/teamgram-android/g' {} \;
    find docs/configuration -name "*.md" -type f -exec sed -i '' 's/Telegram-master/echo-android-client/g' {} \;
    find docs/configuration -name "*.md" -type f -exec sed -i '' 's|telegram+echo/|./|g' {} \;
    echo "  ✓ docs/configuration/"
fi

# 修复 docs/branding/ 目录
echo -e "${BLUE}修复 docs/branding/ 目录...${NC}"
if [ -d "docs/branding" ]; then
    find docs/branding -name "*.md" -type f -exec sed -i '' 's/echo-android-echo2/teamgram-android/g' {} \;
    find docs/branding -name "*.md" -type f -exec sed -i '' 's/Telegram-master/echo-android-client/g' {} \;
    find docs/branding -name "*.md" -type f -exec sed -i '' 's|telegram+echo/|./|g' {} \;
    echo "  ✓ docs/branding/"
fi

# 修复 docs/enforcement/ 目录
echo -e "${BLUE}修复 docs/enforcement/ 目录...${NC}"
if [ -d "docs/enforcement" ]; then
    find docs/enforcement -name "*.md" -type f -exec sed -i '' 's/echo-android-echo2/teamgram-android/g' {} \;
    find docs/enforcement -name "*.md" -type f -exec sed -i '' 's/Telegram-master/echo-android-client/g' {} \;
    find docs/enforcement -name "*.md" -type f -exec sed -i '' 's|telegram+echo/|./|g' {} \;
    echo "  ✓ docs/enforcement/"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  文档修复完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""

echo -e "${BLUE}📋 修复总结：${NC}"
echo "  • 客户端名称："
echo "    - echo-android-echo2 → teamgram-android（参考项目）"
echo "    - Telegram-master → echo-android-client（使用的客户端）"
echo ""
echo "  • 路径简化："
echo "    - telegram+echo/ → ./ （相对路径）"
echo ""
echo "  • 包名更新："
echo "    - org/telegram/messenger → com/echo/messenger"
echo ""

echo -e "${YELLOW}⚠️  注意事项：${NC}"
echo "  1. docs/temp/ 目录未修改（历史记录）"
echo "  2. ECHO_ANDROID_CLIENT_REBRAND.md 保留原样（教程）"
echo "  3. 建议运行 ./check-branding.sh 验证"
echo ""

echo -e "${GREEN}✓ 完成！${NC}"
