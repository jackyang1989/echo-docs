#!/bin/bash

# Echo 自动提交设置脚本

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PLIST_FILE="com.echo.autocommit.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_FILE"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_usage() {
    echo "用法: $0 {install|uninstall|start|stop|status|logs}"
    echo ""
    echo "命令:"
    echo "  install   - 安装自动提交服务（每15分钟执行一次）"
    echo "  uninstall - 卸载自动提交服务"
    echo "  start     - 启动自动提交服务"
    echo "  stop      - 停止自动提交服务"
    echo "  status    - 查看服务状态"
    echo "  logs      - 查看日志"
    echo "  test      - 测试运行一次"
}

install_service() {
    echo -e "${YELLOW}安装自动提交服务...${NC}"
    
    # 创建 LaunchAgents 目录
    mkdir -p "$HOME/Library/LaunchAgents"
    
    # 复制 plist 文件
    cp "$SCRIPT_DIR/$PLIST_FILE" "$PLIST_PATH"
    
    # 加载服务
    launchctl load "$PLIST_PATH"
    
    echo -e "${GREEN}✓ 自动提交服务已安装并启动${NC}"
    echo -e "${GREEN}✓ 每15分钟自动提交一次${NC}"
    echo -e "${YELLOW}查看日志: tail -f $SCRIPT_DIR/logs/auto-commit.log${NC}"
}

uninstall_service() {
    echo -e "${YELLOW}卸载自动提交服务...${NC}"
    
    # 卸载服务
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    
    # 删除 plist 文件
    rm -f "$PLIST_PATH"
    
    echo -e "${GREEN}✓ 自动提交服务已卸载${NC}"
}

start_service() {
    echo -e "${YELLOW}启动自动提交服务...${NC}"
    launchctl load "$PLIST_PATH"
    echo -e "${GREEN}✓ 服务已启动${NC}"
}

stop_service() {
    echo -e "${YELLOW}停止自动提交服务...${NC}"
    launchctl unload "$PLIST_PATH"
    echo -e "${GREEN}✓ 服务已停止${NC}"
}

show_status() {
    echo -e "${YELLOW}检查服务状态...${NC}"
    if launchctl list | grep -q "com.echo.autocommit"; then
        echo -e "${GREEN}✓ 服务正在运行${NC}"
        launchctl list | grep "com.echo.autocommit"
    else
        echo -e "${RED}✗ 服务未运行${NC}"
    fi
}

show_logs() {
    echo -e "${YELLOW}查看最近的日志...${NC}"
    echo -e "${GREEN}=== 标准输出 ===${NC}"
    tail -n 50 "$SCRIPT_DIR/logs/auto-commit.log" 2>/dev/null || echo "暂无日志"
    echo -e "\n${RED}=== 错误输出 ===${NC}"
    tail -n 50 "$SCRIPT_DIR/logs/auto-commit-error.log" 2>/dev/null || echo "暂无错误"
}

test_run() {
    echo -e "${YELLOW}测试运行自动提交脚本...${NC}"
    bash "$SCRIPT_DIR/auto-commit-all.sh"
}

# 主逻辑
case "${1:-}" in
    install)
        install_service
        ;;
    uninstall)
        uninstall_service
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    test)
        test_run
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
