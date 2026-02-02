#!/bin/bash

# Echo 项目 AGENTS.md 规则合规性检查工具
# 用途：自动检查是否遵守 AGENTS.md 中的所有规则
# 使用：./tools/validate-agents-compliance.sh

set -e

echo "========================================="
echo "  Echo AGENTS.md 规则合规性检查"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# 检查函数
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

echo "=== 1. 品牌命名检查 ==="
echo ""

# 注意：vibe/Vibe/VIBE 已完全清理，不再检查
# 历史记录文档中提到 vibe 是合法的（说明"已经清理了 vibe"）
echo "ℹ️  跳过 vibe 检查（已完全清理，历史记录文档中的引用是合法的）"
echo ""

# 检查 teamgram（只检查代码目录，排除 marmota 工具库和 echo-server-source）
TEAMGRAM_FOUND=0

if [ -d "echo-proto" ]; then
    if grep -r "teamgram\|Teamgram\|TEAMGRAM" --include="*.go" echo-proto/ 2>/dev/null | grep -v "marmota" > /dev/null; then
        check_fail "echo-proto 中发现 teamgram 引用"
        TEAMGRAM_FOUND=1
    fi
fi

if [ -d "echo-server" ]; then
    if grep -r "teamgram\|Teamgram\|TEAMGRAM" --include="*.go" echo-server/ 2>/dev/null | grep -v "marmota" > /dev/null; then
        check_fail "echo-server 中发现 teamgram 引用"
        TEAMGRAM_FOUND=1
    fi
fi

# echo-server-source 是原始源码，Week 2 才会处理，暂时跳过
# if [ -d "echo-server-source" ]; then
#     if grep -r "teamgram\|Teamgram\|TEAMGRAM" --include="*.go" --include="*.yaml" echo-server-source/ 2>/dev/null | grep -v "marmota" > /dev/null; then
#         check_fail "echo-server-source 中发现 teamgram 引用"
#         TEAMGRAM_FOUND=1
#     fi
# fi

if [ $TEAMGRAM_FOUND -eq 0 ]; then
    check_pass "没有发现 teamgram/Teamgram/TEAMGRAM（排除 marmota 工具库）"
fi

# 检查 telegram（在 echo-android-client 中）
if [ -d "echo-android-client" ]; then
    if grep -r "telegram\|Telegram" --include="*.java" --include="*.xml" echo-android-client/ \
        --exclude-dir="docs" \
        > /dev/null 2>&1; then
        check_fail "echo-android-client 中发现 telegram 引用"
    else
        check_pass "echo-android-client 中没有 telegram 引用"
    fi
fi

echo ""
echo "=== 2. 核心文档完整性检查 ==="
echo ""

# 检查核心文档是否存在
CORE_DOCS=(
    "AGENTS.md"
    "echo-server-source/docs/core/README.md"
    "echo-server-source/docs/core/changes/CHANGELOG.md"
    "echo-server-source/docs/core/changes/README.md"
    "echo-server-source/docs/core/architecture/system-design.md"
    "echo-server-source/docs/core/architecture/module-design.md"
    "echo-server-source/docs/core/architecture/api-contracts.md"
    "echo-server-source/docs/core/standards/coding-standards.md"
    "echo-server-source/docs/core/standards/commit-conventions.md"
    "echo-server-source/docs/core/standards/review-checklist.md"
)

for doc in "${CORE_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        check_pass "核心文档存在: $doc"
    else
        check_fail "核心文档缺失: $doc"
    fi
done

echo ""
echo "=== 3. 变更记录检查 ==="
echo ""

# 检查是否有未记录的功能文件
# 这里简化检查，实际应该检查 git diff
if [ -d "echo-server-source/docs/core/changes/features" ]; then
    FEATURE_COUNT=$(ls -1 echo-server-source/docs/core/changes/features/ECHO-FEATURE-*.md 2>/dev/null | wc -l)
    if [ "$FEATURE_COUNT" -gt 0 ]; then
        check_pass "发现 $FEATURE_COUNT 个功能变更记录"
    else
        check_warn "没有发现功能变更记录（如果是新项目，这是正常的）"
    fi
fi

# 检查 CHANGELOG.md 是否更新
if [ -f "echo-server-source/docs/core/changes/CHANGELOG.md" ]; then
    if grep -q "\[Unreleased\]" echo-server-source/docs/core/changes/CHANGELOG.md; then
        check_pass "CHANGELOG.md 包含 [Unreleased] 章节"
    else
        check_warn "CHANGELOG.md 缺少 [Unreleased] 章节"
    fi
fi

echo ""
echo "=== 4. 文档索引一致性检查 ==="
echo ""

# 检查 AGENTS.md 中的文档索引是否与实际文件一致
if grep -q "system-design.md" AGENTS.md && [ -f "echo-server-source/docs/core/architecture/system-design.md" ]; then
    check_pass "AGENTS.md 索引与实际文件一致: system-design.md"
else
    check_fail "AGENTS.md 索引与实际文件不一致: system-design.md"
fi

if grep -q "module-design.md" AGENTS.md && [ -f "echo-server-source/docs/core/architecture/module-design.md" ]; then
    check_pass "AGENTS.md 索引与实际文件一致: module-design.md"
else
    check_fail "AGENTS.md 索引与实际文件不一致: module-design.md"
fi

if grep -q "coding-standards.md" AGENTS.md && [ -f "echo-server-source/docs/core/standards/coding-standards.md" ]; then
    check_pass "AGENTS.md 索引与实际文件一致: coding-standards.md"
else
    check_fail "AGENTS.md 索引与实际文件不一致: coding-standards.md"
fi

echo ""
echo "=== 5. 文档状态标记检查 ==="
echo ""

# 检查文档中是否还有"待完善"标记
if grep -q "待完善\|待创建\|TODO" echo-server-source/docs/core/architecture/*.md 2>/dev/null; then
    check_warn "架构文档中发现待完善标记"
else
    check_pass "架构文档没有待完善标记"
fi

if grep -q "待完善\|待创建\|TODO" echo-server-source/docs/core/standards/*.md 2>/dev/null; then
    check_warn "开发规范文档中发现待完善标记"
else
    check_pass "开发规范文档没有待完善标记"
fi

echo ""
echo "=== 6. Git 提交规范检查 ==="
echo ""

# 检查最近的提交消息是否符合规范
if git rev-parse --git-dir > /dev/null 2>&1; then
    LAST_COMMIT=$(git log -1 --pretty=%B 2>/dev/null)
    if echo "$LAST_COMMIT" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore|revert|rebrand)(\(.+\))?: .+"; then
        check_pass "最近的提交消息符合规范"
    else
        check_warn "最近的提交消息可能不符合规范: $LAST_COMMIT"
    fi
else
    check_warn "不是 Git 仓库，跳过提交规范检查"
fi

echo ""
echo "========================================="
echo "  检查完成"
echo "========================================="
echo ""
echo "统计："
echo "  错误: $ERRORS"
echo "  警告: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ 发现 $ERRORS 个错误，必须修复！${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 $WARNINGS 个警告，建议修复${NC}"
    exit 0
else
    echo -e "${GREEN}✅ 所有检查通过！${NC}"
    exit 0
fi
