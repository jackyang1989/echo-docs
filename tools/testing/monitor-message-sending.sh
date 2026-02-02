#!/bin/bash

# Echo 消息发送实时监控脚本
# 用途: 在发送消息时实时查看所有相关日志

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Echo 消息发送实时监控${NC}"
echo "=============================="
echo ""
echo -e "${YELLOW}💡 提示: 现在在手机上发送消息，观察日志输出${NC}"
echo ""
echo "按 Ctrl+C 退出监控"
echo ""
echo "=============================="
echo ""

# 创建临时文件用于存储上次的消息数量
LAST_MESSAGE_COUNT_FILE="/tmp/echo_last_message_count_monitor"
echo "0" > "$LAST_MESSAGE_COUNT_FILE"

# 监控函数
monitor_logs() {
    # 使用 tail -f 监控多个日志文件
    tail -f \
        echo-server-source/logs/bff.log \
        echo-server-source/logs/msg/msg.log \
        echo-server-source/logs/sync.log \
        2>/dev/null | while read -r line; do
        
        # 高亮显示关键词
        if echo "$line" | grep -qi "error\|Error\|ERROR\|panic\|fatal"; then
            echo -e "${RED}[ERROR] $line${NC}"
        elif echo "$line" | grep -qi "sendMessage\|SendMessage\|message\.send"; then
            echo -e "${GREEN}[MESSAGE] $line${NC}"
        elif echo "$line" | grep -qi "inbox\|Inbox"; then
            echo -e "${BLUE}[INBOX] $line${NC}"
        elif echo "$line" | grep -qi "sync\|Sync"; then
            echo -e "${YELLOW}[SYNC] $line${NC}"
        else
            echo "$line"
        fi
        
        # 每隔一段时间检查数据库
        if [ $((RANDOM % 10)) -eq 0 ]; then
            CURRENT_COUNT=$(docker exec mysql mysql -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM messages;" 2>/dev/null || echo "0")
            LAST_COUNT=$(cat "$LAST_MESSAGE_COUNT_FILE")
            
            if [ "$CURRENT_COUNT" -gt "$LAST_COUNT" ]; then
                echo -e "${GREEN}✅ 数据库更新: 消息数量从 $LAST_COUNT 增加到 $CURRENT_COUNT${NC}"
                echo "$CURRENT_COUNT" > "$LAST_MESSAGE_COUNT_FILE"
            fi
        fi
    done
}

# 捕获 Ctrl+C
trap 'echo -e "\n\n${GREEN}✅ 监控已停止${NC}\n"; rm -f "$LAST_MESSAGE_COUNT_FILE"; exit 0' INT

# 开始监控
monitor_logs
