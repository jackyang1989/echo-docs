#!/bin/bash
# Echo 核心文档监控脚本
# 监控核心文档目录，防止误删或移动

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  Echo 核心文档监控"
echo "========================================="
echo ""

# 定义核心文档路径
CORE_DOCS=(
    "AGENTS.md"
    "echo-server-source/docs/core/README.md"
    "echo-server-source/docs/core/changes/CHANGELOG.md"
    "echo-server-source/docs/core/changes/README.md"
    "echo-server-source/docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md"
    "echo-android-client/docs/core/README.md"
    "echo-android-client/docs/core/changes/CHANGELOG.md"
    "echo-android-client/docs/core/changes/README.md"
    "echo-android-client/docs/core/changes/features/ECHO-FEATURE-TEMPLATE.md"
)

# 检查核心文档是否存在
echo "=== 检查核心文档完整性 ==="
echo ""

MISSING_COUNT=0

for doc in "${CORE_DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
        echo -e "${RED}❌ 缺失：$doc${NC}"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    else
        echo -e "${GREEN}✓ 存在：$doc${NC}"
    fi
done

echo ""

if [ $MISSING_COUNT -gt 0 ]; then
    echo -e "${RED}=========================================${NC}"
    echo -e "${RED}  发现 $MISSING_COUNT 个核心文档缺失！${NC}"
    echo -e "${RED}=========================================${NC}"
    echo ""
    echo "核心文档是项目的重要资产，严禁删除或移动。"
    echo ""
    echo "如果文档被误删，请从 Git 历史恢复："
    echo "  git checkout HEAD -- <文件路径>"
    echo ""
    exit 1
else
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}  所有核心文档完整 ✓${NC}"
    echo -e "${GREEN}=========================================${NC}"
fi

echo ""

# 检查核心文档目录是否包含非核心文档
echo "=== 检查核心文档目录纯净度 ==="
echo ""

# 定义不应该出现在 docs/core/ 的文件模式
FORBIDDEN_PATTERNS=(
    "*会议记录*"
    "*meeting*"
    "*临时*"
    "*temp*"
    "*草稿*"
    "*draft*"
    "*审计*"
    "*audit*"
    "*运营*"
    "*operation*"
    "*测试报告*"
    "*test-report*"
    "*部署日志*"
    "*deploy-log*"
)

POLLUTION_COUNT=0

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if find echo-server-source/docs/core/ -iname "$pattern" ! -iname "*TEMPLATE*" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠️  发现可能的非核心文档：$pattern${NC}"
        find echo-server-source/docs/core/ -iname "$pattern" ! -iname "*TEMPLATE*" 2>/dev/null
        POLLUTION_COUNT=$((POLLUTION_COUNT + 1))
    fi
    
    if find echo-android-client/docs/core/ -iname "$pattern" ! -iname "*TEMPLATE*" 2>/dev/null | grep -q .; then
        echo -e "${YELLOW}⚠️  发现可能的非核心文档：$pattern${NC}"
        find echo-android-client/docs/core/ -iname "$pattern" ! -iname "*TEMPLATE*" 2>/dev/null
        POLLUTION_COUNT=$((POLLUTION_COUNT + 1))
    fi
done

echo ""

if [ $POLLUTION_COUNT -gt 0 ]; then
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}  发现 $POLLUTION_COUNT 个可能的非核心文档${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo ""
    echo "核心文档目录应该只包含与开发直接相关的文档。"
    echo ""
    echo "请将以下文档移到其他目录："
    echo "  - 临时文档 → docs/temp/"
    echo "  - 运营文档 → docs/operations/"
    echo "  - 测试报告 → docs/testing/"
    echo "  - 部署文档 → 项目根目录"
    echo ""
else
    echo -e "${GREEN}核心文档目录纯净 ✓${NC}"
fi

echo ""

# 统计核心文档数量
echo "=== 核心文档统计 ==="
echo ""

echo "服务端："
echo "  功能记录: $(find echo-server-source/docs/core/changes/features/ -name "ECHO-FEATURE-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Bug 修复: $(find echo-server-source/docs/core/changes/bugfixes/ -name "ECHO-BUG-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  性能优化: $(find echo-server-source/docs/core/changes/optimizations/ -name "ECHO-OPT-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  上游合并: $(find echo-server-source/docs/core/changes/merge-reports/ -name "merge-*.md" 2>/dev/null | wc -l | tr -d ' ')"

echo ""

echo "Android 客户端："
echo "  功能记录: $(find echo-android-client/docs/core/changes/features/ -name "ECHO-FEATURE-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  Bug 修复: $(find echo-android-client/docs/core/changes/bugfixes/ -name "ECHO-BUG-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  性能优化: $(find echo-android-client/docs/core/changes/optimizations/ -name "ECHO-OPT-*.md" 2>/dev/null | wc -l | tr -d ' ')"
echo "  上游合并: $(find echo-android-client/docs/core/changes/merge-reports/ -name "merge-*.md" 2>/dev/null | wc -l | tr -d ' ')"

echo ""
echo "========================================="
echo "  监控完成"
echo "========================================="

exit 0
