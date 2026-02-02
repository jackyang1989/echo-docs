#!/bin/bash

# 测试服务端返回的用户对象

echo "🔍 测试服务端返回的用户对象"
echo "=========================="
echo ""

# 查看数据库中的用户信息
echo "📊 数据库中的用户信息:"
echo "-------------------"
docker exec mysql mysql -u root -pmy_root_secret echo -se "
SELECT 
    id,
    first_name,
    last_name,
    username,
    phone
FROM users 
WHERE id IN (1, 136907713, 136907714)
ORDER BY id;
" 2>&1 | grep -v "Warning"

echo ""
echo "📝 分析:"
echo "-------------------"
echo "ouyang (id=1):"
echo "  first_name: Jian"
echo "  last_name: Ouyang"
echo "  username: ouyang"
echo "  phone: 8618124944249"
echo ""
echo "jack (id=136907713):"
echo "  first_name: jack"
echo "  last_name: (空)"
echo "  username: (空)"
echo "  phone: 8615622252279"
echo ""
echo "yang (id=136907714):"
echo "  first_name: yang"
echo "  last_name: (空)"
echo "  username: (空)"
echo "  phone: 8613076797674"
echo ""

echo "💡 客户端显示逻辑应该是:"
echo "-------------------"
echo "1. 如果有 username，显示 @username"
echo "2. 否则显示 first_name + last_name"
echo "3. 如果都没有，才显示手机号"
echo ""
echo "按照这个逻辑:"
echo "  ouyang 应该显示: 'ouyang' 或 'Jian Ouyang'"
echo "  jack 应该显示: 'jack'"
echo "  yang 应该显示: 'yang'"
echo ""

echo "🔍 可能的问题:"
echo "-------------------"
echo "1. 客户端没有正确获取 first_name 或 username"
echo "2. 服务端返回的用户对象中这些字段为空"
echo "3. 客户端的显示逻辑有 bug"
echo ""

echo "🧪 建议测试:"
echo "-------------------"
echo "1. 在手机上查看 ouyang 的个人资料页面"
echo "   - 检查是否显示 'Jian Ouyang' 和 '@ouyang'"
echo ""
echo "2. 在聊天列表中查看 ouyang 的名称"
echo "   - 应该显示 'Jian' 或 'ouyang'"
echo "   - 如果显示手机号，说明客户端没有获取到名称"
echo ""
echo "3. 查看 BFF 日志，看服务端返回的用户对象"
echo "   tail -f echo-server-source/logs/bff.log | grep -A 20 'user_id.*1'"
echo ""
