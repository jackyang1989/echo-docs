#!/bin/bash

# Echo 双手机测试监控脚本
# 用途: 实时监控服务器日志和数据库状态

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Echo 双手机测试监控${NC}"
echo "======================="
echo ""
echo "按 Ctrl+C 退出监控"
echo ""

# 创建临时文件用于存储上次的用户数量
LAST_USER_COUNT_FILE="/tmp/echo_last_user_count"
LAST_MESSAGE_COUNT_FILE="/tmp/echo_last_message_count"

# 初始化计数
if [ ! -f "$LAST_USER_COUNT_FILE" ]; then
    echo "0" > "$LAST_USER_COUNT_FILE"
fi
if [ ! -f "$LAST_MESSAGE_COUNT_FILE" ]; then
    echo "0" > "$LAST_MESSAGE_COUNT_FILE"
fi

# 监控函数
monitor_loop() {
    while true; do
        clear
        echo -e "${BLUE}🔍 Echo 双手机测试监控${NC}"
        echo "======================="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # 1. 服务器状态
        echo -e "${GREEN}📡 服务器状态${NC}"
        echo "-------------------"
        if ps aux | grep -E "gnetway" | grep -v grep > /dev/null; then
            echo -e "  gnetway:     ${GREEN}✅ 运行中${NC}"
        else
            echo -e "  gnetway:     ${RED}❌ 未运行${NC}"
        fi
        
        if ps aux | grep -E "session" | grep -v grep | grep -v nsurlsession > /dev/null; then
            echo -e "  session:     ${GREEN}✅ 运行中${NC}"
        else
            echo -e "  session:     ${RED}❌ 未运行${NC}"
        fi
        
        if ps aux | grep -E "bff" | grep -v grep > /dev/null; then
            echo -e "  bff:         ${GREEN}✅ 运行中${NC}"
        else
            echo -e "  bff:         ${RED}❌ 未运行${NC}"
        fi
        
        if ps aux | grep -E "authsession" | grep -v grep > /dev/null; then
            echo -e "  authsession: ${GREEN}✅ 运行中${NC}"
        else
            echo -e "  authsession: ${RED}❌ 未运行${NC}"
        fi
        
        if ps aux | grep -E "echod/bin/media" | grep -v grep > /dev/null; then
            echo -e "  media:       ${GREEN}✅ 运行中${NC}"
        else
            echo -e "  media:       ${RED}❌ 未运行${NC}"
        fi
        
        echo ""
        
        # 2. 数据库统计
        echo -e "${GREEN}📊 数据库统计${NC}"
        echo "-------------------"
        
        # 用户数量
        CURRENT_USER_COUNT=$(mysql -h 127.0.0.1 -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM users WHERE deleted = 0;" 2>/dev/null || echo "0")
        LAST_USER_COUNT=$(cat "$LAST_USER_COUNT_FILE")
        
        if [ "$CURRENT_USER_COUNT" -gt "$LAST_USER_COUNT" ]; then
            echo -e "  用户数量: ${GREEN}$CURRENT_USER_COUNT${NC} (${GREEN}+$((CURRENT_USER_COUNT - LAST_USER_COUNT))${NC})"
            echo "$CURRENT_USER_COUNT" > "$LAST_USER_COUNT_FILE"
        else
            echo "  用户数量: $CURRENT_USER_COUNT"
        fi
        
        # 消息数量
        CURRENT_MESSAGE_COUNT=$(mysql -h 127.0.0.1 -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM messages;" 2>/dev/null || echo "0")
        LAST_MESSAGE_COUNT=$(cat "$LAST_MESSAGE_COUNT_FILE")
        
        if [ "$CURRENT_MESSAGE_COUNT" -gt "$LAST_MESSAGE_COUNT" ]; then
            echo -e "  消息数量: ${GREEN}$CURRENT_MESSAGE_COUNT${NC} (${GREEN}+$((CURRENT_MESSAGE_COUNT - LAST_MESSAGE_COUNT))${NC})"
            echo "$CURRENT_MESSAGE_COUNT" > "$LAST_MESSAGE_COUNT_FILE"
        else
            echo "  消息数量: $CURRENT_MESSAGE_COUNT"
        fi
        
        # 对话数量
        DIALOG_COUNT=$(mysql -h 127.0.0.1 -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM user_dialogs;" 2>/dev/null || echo "0")
        echo "  对话数量: $DIALOG_COUNT"
        
        echo ""
        
        # 3. 最近注册的用户
        echo -e "${GREEN}👥 最近注册的用户${NC}"
        echo "-------------------"
        mysql -h 127.0.0.1 -u root -pmy_root_secret echo -se "
            SELECT 
                id,
                phone,
                CONCAT(first_name, ' ', last_name) AS name,
                FROM_UNIXTIME(registered_at) AS registered_time
            FROM users 
            WHERE deleted = 0 
            ORDER BY id DESC 
            LIMIT 5;
        " 2>/dev/null | while IFS=$'\t' read -r id phone name time; do
            if [ "$id" != "id" ]; then
                echo "  ID: $id | 手机: $phone | 姓名: $name"
            fi
        done
        
        echo ""
        
        # 4. 最近的消息
        echo -e "${GREEN}💬 最近的消息 (最新 5 条)${NC}"
        echo "-------------------"
        mysql -h 127.0.0.1 -u root -pmy_root_secret echo -se "
            SELECT 
                user_id,
                peer_type,
                peer_id,
                LEFT(message, 50) AS message_preview,
                FROM_UNIXTIME(date) AS send_time
            FROM messages 
            ORDER BY id DESC 
            LIMIT 5;
        " 2>/dev/null | while IFS=$'\t' read -r user_id peer_type peer_id msg time; do
            if [ "$user_id" != "user_id" ]; then
                echo "  用户 $user_id → 类型 $peer_type (ID: $peer_id)"
                echo "    消息: $msg"
                echo ""
            fi
        done
        
        # 5. 最近的日志
        echo -e "${GREEN}📝 最近的 BFF 日志 (最新 3 条)${NC}"
        echo "-------------------"
        if [ -f "echo-server-source/logs/bff.log" ]; then
            tail -3 echo-server-source/logs/bff.log | while read -r line; do
                echo "  $line"
            done
        else
            echo "  日志文件不存在"
        fi
        
        echo ""
        echo -e "${YELLOW}💡 提示: 按 Ctrl+C 退出监控${NC}"
        
        # 每 3 秒刷新一次
        sleep 3
    done
}

# 捕获 Ctrl+C
trap 'echo -e "\n\n${GREEN}✅ 监控已停止${NC}\n"; exit 0' INT

# 开始监控
monitor_loop
