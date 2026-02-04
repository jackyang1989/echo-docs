#!/bin/bash

# Echo 品牌命名检查脚本
# 用于检查项目中是否还有上游品牌名称（teamgram, telegram）

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Echo 品牌命名检查${NC}"
echo -e "${GREEN}========================================${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

FOUND_ISSUES=0

echo -e "\n${BLUE}检查范围:${NC}"
echo "  - echo-proto/ (协议库)"
echo "  - echo-server/ (服务端)"
echo ""
echo -e "${BLUE}检查文件类型:${NC}"
echo "  - Go 源码 (*.go)"
echo ""
echo -e "${BLUE}说明:${NC}"
echo "  - vibe/Vibe/VIBE 已完全清理，不再检查"
echo "  - 历史记录文档中的引用是合法的"
echo "  - teamgram-android/ 是参考项目，不检查"
echo "  - echo-server-source/ 是原始源码，Week 2 才会处理，暂时跳过"
echo ""
echo ""

# 1. 检查 teamgram (小写) - 只检查代码目录
echo -e "${YELLOW}[1/3] 检查 'teamgram' (小写)...${NC}"
RESULT=""
if [ -d "echo-proto" ]; then
    RESULT="$RESULT$(grep -r "teamgram" --include="*.go" echo-proto/ 2>/dev/null || true)"
fi
if [ -d "echo-server" ]; then
    RESULT="$RESULT$(grep -r "teamgram" --include="*.go" echo-server/ 2>/dev/null || true)"
fi
# echo-server-source 是原始源码，Week 2 才会处理，暂时跳过
# if [ -d "echo-server-source" ]; then
#     RESULT="$RESULT$(grep -r "teamgram" --include="*.go" --include="*.yaml" echo-server-source/ 2>/dev/null | grep -v "marmota" || true)"
# fi

if [ -n "$RESULT" ]; then
    echo -e "${RED}❌ 发现 'teamgram':${NC}"
    echo "$RESULT" | head -20
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo -e "${GREEN}✓ 未发现 'teamgram'${NC}"
fi

# 2. 检查 Teamgram (首字母大写) - 只检查代码目录
echo -e "\n${YELLOW}[2/3] 检查 'Teamgram' (首字母大写)...${NC}"
RESULT=""
if [ -d "echo-proto" ]; then
    RESULT="$RESULT$(grep -r "Teamgram" --include="*.go" echo-proto/ 2>/dev/null || true)"
fi
if [ -d "echo-server" ]; then
    RESULT="$RESULT$(grep -r "Teamgram" --include="*.go" echo-server/ 2>/dev/null || true)"
fi
# echo-server-source 是原始源码，Week 2 才会处理，暂时跳过
# if [ -d "echo-server-source" ]; then
#     RESULT="$RESULT$(grep -r "Teamgram" --include="*.go" --include="*.yaml" echo-server-source/ 2>/dev/null || true)"
# fi

if [ -n "$RESULT" ]; then
    echo -e "${RED}❌ 发现 'Teamgram':${NC}"
    echo "$RESULT" | head -20
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo -e "${GREEN}✓ 未发现 'Teamgram'${NC}"
fi

# 3. 检查 TEAMGRAM (全大写) - 只检查代码目录
echo -e "\n${YELLOW}[3/3] 检查 'TEAMGRAM' (全大写)...${NC}"
RESULT=""
if [ -d "echo-proto" ]; then
    RESULT="$RESULT$(grep -r "TEAMGRAM" --include="*.go" echo-proto/ 2>/dev/null || true)"
fi
if [ -d "echo-server" ]; then
    RESULT="$RESULT$(grep -r "TEAMGRAM" --include="*.go" echo-server/ 2>/dev/null || true)"
fi
# echo-server-source 是原始源码，Week 2 才会处理，暂时跳过
# if [ -d "echo-server-source" ]; then
#     RESULT="$RESULT$(grep -r "TEAMGRAM" --include="*.go" --include="*.yaml" echo-server-source/ 2>/dev/null || true)"
# fi

if [ -n "$RESULT" ]; then
    echo -e "${RED}❌ 发现 'TEAMGRAM':${NC}"
    echo "$RESULT" | head -20
    FOUND_ISSUES=$((FOUND_ISSUES + 1))
else
    echo -e "${GREEN}✓ 未发现 'TEAMGRAM'${NC}"
fi

# 总结
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  检查完成${NC}"
echo -e "${GREEN}========================================${NC}"

if [ $FOUND_ISSUES -eq 0 ]; then
    echo -e "\n${GREEN}✅ 太棒了！没有发现任何上游品牌名称！${NC}"
    echo -e "${GREEN}所有文件都符合 Echo 品牌命名规范。${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  发现 $FOUND_ISSUES 个问题！${NC}"
    echo -e "${YELLOW}请检查上述文件并替换为正确的 Echo 品牌名称。${NC}"
    echo ""
    echo -e "${BLUE}参考 AGENTS.md 了解正确的命名规则。${NC}"
    exit 1
fi
