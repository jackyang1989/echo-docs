#!/bin/bash

# Echo 消息和隐私问题诊断脚本

set -e

echo "🔍 Echo 消息和隐私问题诊断"
echo "=========================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. 检查关键服务状态
echo -e "${BLUE}📡 检查关键服务状态${NC}"
echo "-------------------"

check_service() {
    local service_name=$1
    local process_pattern=$2
    
    if ps aux | grep "$process_pattern" | grep -v grep > /dev/null; then
        echo -e "  $service_name: ${GREEN}✅ 运行中${NC}"
        return 0
    else
        echo -e "  $service_name: ${RED}❌ 未运行${NC}"
        return 1
    fi
}

check_service "gnetway" "./gnetway -f"
check_service "session" "./session -f"
check_service "bff" "./bff -f"
check_service "msg" "./msg -f"
check_service "sync" "./sync -f"

echo ""

# 2. 检查数据库连接
echo -e "${BLUE}🗄️  检查数据库${NC}"
echo "-------------------"

if docker exec mysql mysql -u root -pmy_root_secret -e "SELECT 1;" > /dev/null 2>&1; then
    echo -e "  MySQL 连接: ${GREEN}✅ 正常${NC}"
else
    echo -e "  MySQL 连接: ${RED}❌ 失败${NC}"
    exit 1
fi

echo ""

# 3. 检查用户信息
echo -e "${BLUE}👥 用户信息${NC}"
echo "-------------------"

docker exec mysql mysql -u root -pmy_root_secret echo -se "
SELECT 
    id,
    phone,
    first_name,
    username,
    deleted
FROM users 
WHERE deleted = 0 
ORDER BY id DESC 
LIMIT 5;
" 2>/dev/null

echo ""

# 4. 检查消息表
echo -e "${BLUE}💬 消息统计${NC}"
echo "-------------------"

MESSAGE_COUNT=$(docker exec mysql mysql -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM messages;" 2>/dev/null)
echo "  消息总数: $MESSAGE_COUNT"

if [ "$MESSAGE_COUNT" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠️  没有消息记录！${NC}"
fi

echo ""

# 5. 检查对话表
echo -e "${BLUE}💭 对话统计${NC}"
echo "-------------------"

DIALOG_COUNT=$(docker exec mysql mysql -u root -pmy_root_secret echo -se "SELECT COUNT(*) FROM dialogs;" 2>/dev/null)
echo "  对话总数: $DIALOG_COUNT"

if [ "$DIALOG_COUNT" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠️  没有对话记录！${NC}"
fi

echo ""

# 6. 检查隐私设置表结构
echo -e "${BLUE}🔒 隐私设置表${NC}"
echo "-------------------"

PRIVACY_TABLES=$(docker exec mysql mysql -u root -pmy_root_secret echo -se "SHOW TABLES LIKE '%privacy%';" 2>/dev/null | grep -v "Tables_in")

if [ -z "$PRIVACY_TABLES" ]; then
    echo -e "  ${RED}❌ 没有找到隐私设置相关表${NC}"
else
    echo "  找到的表:"
    echo "$PRIVACY_TABLES" | while read table; do
        echo "    - $table"
    done
fi

echo ""

# 7. 检查 BFF 日志中的错误
echo -e "${BLUE}📝 BFF 日志检查 (最近 20 行)${NC}"
echo "-------------------"

if [ -f "echo-server-source/logs/bff.log" ]; then
    tail -20 echo-server-source/logs/bff.log | grep -E "(error|Error|ERROR|panic|fatal)" || echo "  没有发现错误"
else
    echo -e "  ${RED}❌ BFF 日志文件不存在${NC}"
fi

echo ""

# 8. 检查 MSG 服务日志
echo -e "${BLUE}📝 MSG 服务日志检查${NC}"
echo "-------------------"

if [ -f "echo-server-source/logs/msg.log" ]; then
    tail -20 echo-server-source/logs/msg.log | grep -E "(error|Error|ERROR|panic|fatal)" || echo "  没有发现错误"
else
    echo -e "  ${YELLOW}⚠️  MSG 日志文件不存在${NC}"
fi

echo ""

# 9. 检查 Kafka 连接
echo -e "${BLUE}📨 Kafka 状态${NC}"
echo "-------------------"

if docker ps | grep kafka > /dev/null; then
    echo -e "  Kafka 容器: ${GREEN}✅ 运行中${NC}"
else
    echo -e "  Kafka 容器: ${RED}❌ 未运行${NC}"
fi

echo ""

# 10. 诊断建议
echo -e "${BLUE}💡 诊断建议${NC}"
echo "-------------------"

if [ "$MESSAGE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}问题 1: 消息无法发送${NC}"
    echo "  可能原因:"
    echo "    1. MSG 服务未运行"
    echo "    2. Kafka 未运行或连接失败"
    echo "    3. BFF → MSG 服务调用失败"
    echo ""
    echo "  解决方案:"
    echo "    1. 检查 MSG 服务: ps aux | grep './msg -f'"
    echo "    2. 检查 Kafka: docker ps | grep kafka"
    echo "    3. 查看 BFF 日志: tail -f echo-server-source/logs/bff.log"
    echo "    4. 查看 MSG 日志: tail -f echo-server-source/logs/msg.log"
    echo ""
fi

if [ -z "$PRIVACY_TABLES" ] || [ "$PRIVACY_TABLES" = "user_global_privacy_settings" ]; then
    echo -e "${YELLOW}问题 2: 隐私设置可能不完整${NC}"
    echo "  可能原因:"
    echo "    1. 数据库 schema 不完整"
    echo "    2. Teamgram v9 版本较旧，隐私功能不完善"
    echo ""
    echo "  解决方案:"
    echo "    1. 检查数据库迁移脚本"
    echo "    2. 查看 Teamgram 文档了解隐私设置实现"
    echo ""
fi

echo -e "${YELLOW}问题 3: 视频头像不支持${NC}"
echo "  说明:"
echo "    Teamgram v9 服务端可能不支持视频头像功能"
echo "    这是 Telegram 较新版本的功能"
echo ""
echo "  解决方案:"
echo "    1. 升级 Teamgram 到最新版本（需要大量测试）"
echo "    2. 暂时禁用客户端的视频头像功能"
echo "    3. 等待 Teamgram 官方支持"
echo ""

echo "=========================="
echo -e "${GREEN}✅ 诊断完成${NC}"
echo ""
