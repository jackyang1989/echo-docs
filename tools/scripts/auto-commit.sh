#!/bin/bash

# Echo 项目自动提交脚本
# 每 15 分钟自动提交一次更改

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志文件
LOG_FILE="auto-commit.log"

# 记录日志
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "  Echo 自动提交脚本启动"
log "========================================="

# 检查是否有更改
if [[ -z $(git status -s) ]]; then
    log "没有更改需要提交"
    exit 0
fi

# 显示更改
log "检测到以下更改："
git status -s | tee -a "$LOG_FILE"

# 添加所有更改
log "添加更改到暂存区..."
git add .

# 生成提交消息
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
CHANGED_FILES=$(git diff --cached --name-only | wc -l | tr -d ' ')

COMMIT_MSG="chore: auto-commit at $TIMESTAMP

- Changed files: $CHANGED_FILES
- Auto-committed by auto-commit.sh"

# 提交
log "提交更改..."
git commit -m "$COMMIT_MSG"

# 推送到远程（如果配置了）
if git remote | grep -q origin; then
    log "推送到远程仓库..."
    if git push origin main 2>&1 | tee -a "$LOG_FILE"; then
        log "✓ 推送成功"
    else
        log "⚠ 推送失败，将在下次重试"
    fi
else
    log "未配置远程仓库，跳过推送"
fi

log "✓ 自动提交完成"
log "========================================="
