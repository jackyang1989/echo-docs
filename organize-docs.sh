#!/bin/bash

# Echo 项目文档整理脚本
# 根据 AGENTS.md 规则将文档移动到相应目录

set -e

echo "========================================="
echo "  Echo 项目文档整理工具"
echo "========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否在项目根目录
if [ ! -f "AGENTS.md" ]; then
    echo -e "${RED}错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

echo -e "${BLUE}📋 创建目录结构...${NC}"

# 创建目录结构
mkdir -p docs/temp
mkdir -p docs/reference
mkdir -p docs/architecture
mkdir -p docs/planning
mkdir -p docs/configuration
mkdir -p docs/branding
mkdir -p docs/enforcement

echo -e "${GREEN}✓ 目录结构创建完成${NC}"
echo ""

# 移动临时文档
echo -e "${YELLOW}🟡 移动临时文档到 docs/temp/${NC}"
temp_docs=(
    "ECHO_SESSION_SUMMARY.md"
    "ECHO_FINAL_UPDATE_SUMMARY.md"
    "ECHO_DOCUMENTATION_SUMMARY.md"
    "ECHO_REBRAND_SUMMARY.md"
    "ECHO_MIGRATION_VERIFICATION.md"
    "ECHO_NEXT_STEPS.md"
    "ECHO_TODO.md"
    "BRANDING_STATUS.md"
    "ECHO_BRANDING_STATUS.md"
    "ECHO_AGENTS_IMPROVEMENTS.md"
    "enforcement_section_temp.md"
)

for doc in "${temp_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/temp/
        echo "  ✓ $doc → docs/temp/"
    fi
done

# 移动参考文档
echo ""
echo -e "${YELLOW}🟢 移动参考文档到 docs/reference/${NC}"
reference_docs=(
    "ECHO_TELEGRAM_FEATURES_MAPPING.md"
    "TELEGRAM_CLIENT_ANALYSIS.md"
    "ECHO_ANDROID_CLIENT_REBRAND.md"
)

for doc in "${reference_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/reference/
        echo "  ✓ $doc → docs/reference/"
    fi
done

# 移动架构文档
echo ""
echo -e "${YELLOW}🔵 移动架构文档到 docs/architecture/${NC}"
architecture_docs=(
    "ECHO_ARCHITECTURE.md"
    "ECHO_DESIGN_PRINCIPLES.md"
    "ARCHITECTURE_DEPLOYMENT.md"
)

for doc in "${architecture_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/architecture/
        echo "  ✓ $doc → docs/architecture/"
    fi
done

# 移动规划文档
echo ""
echo -e "${YELLOW}🟣 移动规划文档到 docs/planning/${NC}"
planning_docs=(
    "ECHO_DEVELOPMENT_ROADMAP.md"
    "ECHO_ADMIN_IA.md"
    "ECHO_ADMIN_IA_PART2.md"
    "ECHO_ADMIN_PANEL.md"
    "ECHO_SQUARE_DESIGN.md"
)

for doc in "${planning_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/planning/
        echo "  ✓ $doc → docs/planning/"
    fi
done

# 移动配置文档
echo ""
echo -e "${YELLOW}🟠 移动配置文档到 docs/configuration/${NC}"
config_docs=(
    "ECHO_DEPLOYMENT_CONFIG.md"
    "ECHO_SECURITY_CONFIG.md"
)

for doc in "${config_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/configuration/
        echo "  ✓ $doc → docs/configuration/"
    fi
done

# 移动品牌文档
echo ""
echo -e "${YELLOW}🎨 移动品牌文档到 docs/branding/${NC}"
branding_docs=(
    "ECHO_BRANDING_GUIDE.md"
    "ECHO_INDEX.md"
)

for doc in "${branding_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/branding/
        echo "  ✓ $doc → docs/branding/"
    fi
done

# 移动强制执行文档
echo ""
echo -e "${YELLOW}📚 移动强制执行文档到 docs/enforcement/${NC}"
enforcement_docs=(
    "ECHO_AI_AGENT_ENFORCEMENT.md"
    "ECHO_ENFORCEMENT_SUMMARY.md"
)

for doc in "${enforcement_docs[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/enforcement/
        echo "  ✓ $doc → docs/enforcement/"
    fi
done

# 创建 README 文件
echo ""
echo -e "${BLUE}📝 创建目录说明文件...${NC}"

cat > docs/README.md << 'EOF'
# Echo 项目文档目录

本目录包含 Echo 项目的所有非核心文档。

## 📁 目录结构

### temp/ - 临时文档
会议记录、临时笔记、草稿等临时性质的文档。

### reference/ - 参考文档
技术分析、功能映射、参考指南等参考性质的文档。

### architecture/ - 架构文档
系统架构设计、设计原则等架构相关文档。

### planning/ - 规划文档
开发路线图、功能设计、管理后台设计等规划文档。

### configuration/ - 配置文档
部署配置、安全配置等配置相关文档。

### branding/ - 品牌文档
品牌指南、品牌索引等品牌相关文档。

### enforcement/ - 强制执行文档
AI Agent 强制执行机制、规则执行总结等文档。

## ⚠️ 重要说明

本目录下的文档**不是核心开发文档**。

核心开发文档存放在：
- `echo-server-source/docs/core/` - 服务端核心文档
- `echo-android-client/docs/core/` - Android 客户端核心文档

核心文档包括：
- 代码变更记录（changes/）
- 架构设计文档（architecture/）
- 开发规范文档（standards/）

详见 [AGENTS.md](../AGENTS.md) 中的核心文档索引章节。
EOF

echo "  ✓ docs/README.md"

# 显示保留在根目录的文档
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  文档整理完成！${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${BLUE}📋 保留在根目录的核心文档：${NC}"
echo "  • AGENTS.md - 品牌命名规则和架构规范"
echo "  • ECHO_START_HERE.md - 项目入口"
echo "  • DEPLOYMENT_GUIDE_MAC.md - 部署指南"
echo "  • QUICK_START.md - 快速开始"
echo "  • README_DEPLOYMENT.md - 部署说明"
echo "  • START_HERE_部署.md - 部署入口"
echo "  • 部署说明_中文.md - 中文部署"
echo ""
echo -e "${BLUE}📁 新的文档目录结构：${NC}"
echo "  docs/"
echo "  ├── temp/          - 临时文档（11 个文件）"
echo "  ├── reference/     - 参考文档（3 个文件）"
echo "  ├── architecture/  - 架构文档（3 个文件）"
echo "  ├── planning/      - 规划文档（5 个文件）"
echo "  ├── configuration/ - 配置文档（2 个文件）"
echo "  ├── branding/      - 品牌文档（2 个文件）"
echo "  └── enforcement/   - 强制执行文档（2 个文件）"
echo ""
echo -e "${YELLOW}⚠️  注意事项：${NC}"
echo "  1. 核心文档（docs/core/）未被移动，保持原样"
echo "  2. 项目根目录保留了必要的入口和部署文档"
echo "  3. 所有文档已按类型分类到 docs/ 子目录"
echo "  4. 建议将这些更改提交到版本控制"
echo ""
echo -e "${GREEN}✓ 完成！${NC}"
