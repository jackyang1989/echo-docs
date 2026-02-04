#!/bin/bash

# Echo 项目自动提交脚本
# 每15分钟自动提交所有仓库的变更

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/Users/jianouyang/Project/echo"

# 时间戳
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Echo 自动提交 - $TIMESTAMP${NC}"
echo -e "${GREEN}========================================${NC}"

# 函数：提交单个仓库
commit_repo() {
    local repo_path=$1
    local repo_name=$2
    
    echo -e "\n${YELLOW}>>> 检查仓库: $repo_name${NC}"
    
    if [ ! -d "$repo_path/.git" ]; then
        echo -e "${RED}✗ 不是 Git 仓库，跳过${NC}"
        return
    fi
    
    cd "$repo_path"
    
    # 检查是否有变更
    if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
        echo -e "${GREEN}✓ 没有变更，跳过${NC}"
        return
    fi
    
    # 添加所有变更
    git add .
    
    # 提交
    git commit -m "chore: 自动提交 - $TIMESTAMP

自动提交脚本生成的提交
" || echo -e "${YELLOW}⚠ 提交失败或没有变更${NC}"
    
    # 推送到远程
    echo -e "${YELLOW}推送到远程...${NC}"
    if git push origin main 2>&1; then
        echo -e "${GREEN}✓ 推送成功${NC}"
    else
        echo -e "${RED}✗ 推送失败${NC}"
    fi
}

# 提交各个仓库
commit_repo "$PROJECT_ROOT/echo-proto" "echo-proto"
commit_repo "$PROJECT_ROOT/echo-server" "echo-server"
commit_repo "$PROJECT_ROOT/echo-android-client" "echo-android-client"
commit_repo "$PROJECT_ROOT/echo-docs" "echo-docs"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}自动提交完成 - $TIMESTAMP${NC}"
echo -e "${GREEN}========================================${NC}"
