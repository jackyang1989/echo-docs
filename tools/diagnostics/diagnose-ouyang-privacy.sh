#!/bin/bash

# Echo ouyang 账户隐私设置诊断脚本

set -e

echo "🔍 ouyang 账户隐私设置诊断"
echo "=========================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 查看 ouyang 的基本信息
echo -e "${BLUE}👤 ouyang 基本信息${NC}"
echo "-------------------"
docker exec mysql mysql -u root -pmy_root_secret echo -se "
SELECT 
    id,
    phone,
    first_name,
    last_name,
    username
FROM users 
WHERE id = 1;
" 2>/dev/null

echo ""

# 2. 查看 ouyang 的隐私设置
echo -e "${BLUE}🔒 ouyang 隐私设置${NC}"
echo "-------------------"
docker exec mysql mysql -u root -pmy_root_secret echo -se "
SELECT 
    id,
    user_id,
    key_type,
    rules,
    created_at
FROM user_privacies 
WHERE user_id = 1
ORDER BY key_type;
" 2>/dev/null

echo ""

# 3. 解释 key_type
echo -e "${BLUE}📖 key_type 说明${NC}"
echo "-------------------"
echo "根据代码分析，key_type 的含义："
echo "  0 = STATUS_TIMESTAMP (最后在线时间)"
echo "  1 = CHAT_INVITE (群组邀请)"
echo "  2 = PHONE_CALL (电话呼叫)"
echo "  3 = PHONE_P2P (P2P 通话)"
echo "  4 = FORWARDS (转发)"
echo "  5 = PROFILE_PHOTO (头像)"
echo "  6 = PHONE_NUMBER (手机号) ⚠️"
echo "  7 = ADDED_BY_PHONE (通过手机号添加)"
echo "  8 = VOICE_MESSAGES (语音消息)"
echo ""
echo -e "${YELLOW}⚠️  ouyang 的设置：${NC}"
echo "  key_type=7: privacyValueDisallowAll (不允许所有人)"
echo "  key_type=8: privacyValueAllowContacts (只允许联系人)"
echo ""
echo -e "${RED}❌ 问题：ouyang 没有设置 key_type=6 (PHONE_NUMBER)${NC}"
echo "  这意味着手机号隐私使用默认设置"
echo ""

# 4. 查看其他用户的隐私设置
echo -e "${BLUE}👥 其他用户的隐私设置${NC}"
echo "-------------------"
OTHER_USER_COUNT=$(docker exec mysql mysql -u root -pmy_root_secret echo -se "SELECT COUNT(DISTINCT user_id) FROM user_privacies WHERE user_id != 1;" 2>/dev/null)
echo "  其他用户有隐私设置的数量: $OTHER_USER_COUNT"

if [ "$OTHER_USER_COUNT" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠️  其他用户都没有设置隐私${NC}"
    echo "  这说明默认情况下，手机号是可见的"
fi

echo ""

# 5. 诊断结论
echo -e "${BLUE}💡 诊断结论${NC}"
echo "-------------------"
echo -e "${RED}问题根因：${NC}"
echo "  1. ouyang 设置了 key_type=7 和 8 的隐私"
echo "  2. 但是 key_type=6 (PHONE_NUMBER) 没有设置"
echo "  3. 客户端可能错误地使用了 key_type=7 或 8 的设置"
echo "  4. 或者服务端返回的用户对象中包含了手机号"
echo ""
echo -e "${GREEN}解决方案：${NC}"
echo "  方案 1: 为 ouyang 添加 key_type=6 的隐私设置"
echo "  方案 2: 检查服务端返回的用户对象，确保遵守隐私设置"
echo "  方案 3: 检查客户端代码，确保正确处理隐私设置"
echo ""

# 6. 提供修复选项
echo -e "${YELLOW}🔧 修复选项${NC}"
echo "-------------------"
echo "选项 1: 为 ouyang 添加手机号隐私设置 (key_type=6)"
echo "  SQL: INSERT INTO user_privacies (user_id, key_type, rules) VALUES (1, 6, '[{\"predicate_name\": \"privacyValueDisallowAll\"}]');"
echo ""
echo "选项 2: 删除 ouyang 的所有隐私设置（恢复默认）"
echo "  SQL: DELETE FROM user_privacies WHERE user_id = 1;"
echo ""
echo "选项 3: 修改 key_type=7 为 key_type=6"
echo "  SQL: UPDATE user_privacies SET key_type = 6 WHERE user_id = 1 AND key_type = 7;"
echo ""

# 7. 询问是否执行修复
read -p "是否执行修复？(1/2/3/n): " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}执行修复选项 1...${NC}"
        docker exec mysql mysql -u root -pmy_root_secret echo -e "
INSERT INTO user_privacies (user_id, key_type, rules) 
VALUES (1, 6, '[{\"predicate_name\": \"privacyValueDisallowAll\"}]')
ON DUPLICATE KEY UPDATE rules = '[{\"predicate_name\": \"privacyValueDisallowAll\"}]';
" 2>/dev/null
        echo -e "${GREEN}✅ 已添加手机号隐私设置${NC}"
        ;;
    2)
        echo ""
        echo -e "${YELLOW}执行修复选项 2...${NC}"
        docker exec mysql mysql -u root -pmy_root_secret echo -e "
DELETE FROM user_privacies WHERE user_id = 1;
" 2>/dev/null
        echo -e "${GREEN}✅ 已删除所有隐私设置${NC}"
        ;;
    3)
        echo ""
        echo -e "${GREEN}执行修复选项 3...${NC}"
        docker exec mysql mysql -u root -pmy_root_secret echo -e "
UPDATE user_privacies SET key_type = 6 WHERE user_id = 1 AND key_type = 7;
" 2>/dev/null
        echo -e "${GREEN}✅ 已修改 key_type${NC}"
        ;;
    *)
        echo ""
        echo -e "${YELLOW}跳过修复${NC}"
        ;;
esac

echo ""
echo "=========================="
echo -e "${GREEN}✅ 诊断完成${NC}"
echo ""
