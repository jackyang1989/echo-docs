#!/bin/bash

# 测试服务端返回的用户对象

echo "🧪 测试服务端返回的用户对象"
echo "=========================="
echo ""

# 1. 检查数据库中的数据
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
WHERE id = 1;
" 2>&1 | grep -v "Warning"

echo ""

# 2. 检查隐私设置
echo "🔒 隐私设置:"
echo "-------------------"
docker exec mysql mysql -u root -pmy_root_secret echo -se "
SELECT 
    user_id,
    key_type,
    rules
FROM user_privacies 
WHERE user_id = 1
ORDER BY key_type;
" 2>&1 | grep -v "Warning"

echo ""
echo "key_type 说明:"
echo "  6 = PHONE_NUMBER (手机号)"
echo "  7 = ADDED_BY_PHONE (通过手机号添加)"
echo "  8 = VOICE_MESSAGES (语音消息)"
echo ""

# 3. 检查缓存
echo "💾 Redis 缓存:"
echo "-------------------"
CACHE_EXISTS=$(docker exec redis redis-cli EXISTS "user_data.2#1")
if [ "$CACHE_EXISTS" -eq 1 ]; then
    echo "  ⚠️  缓存存在"
    echo "  建议清除缓存: docker exec redis redis-cli DEL \"user_data.2#1\""
else
    echo "  ✅ 缓存已清除"
fi

echo ""

# 4. 建议的测试步骤
echo "📝 测试步骤:"
echo "-------------------"
echo "1. 在手机上完全退出 Echo 应用（杀掉进程）"
echo "2. 清除应用数据（可选，但推荐）:"
echo "   Settings → Apps → Echo → Storage → Clear Data"
echo "3. 重新打开 Echo 应用"
echo "4. 登录并查看 ouyang 的聊天"
echo ""
echo "如果还是显示手机号，说明问题在服务端的其他地方"
echo ""

# 5. 检查是否有其他用户也有这个问题
echo "🔍 检查其他用户:"
echo "-------------------"
echo "测试步骤:"
echo "1. 让 jack 或 yang 查看自己的个人资料"
echo "2. 看看其他人看到的是昵称还是手机号"
echo "3. 如果其他人也显示手机号，说明是通用问题"
echo "4. 如果只有 ouyang 显示手机号，说明是 ouyang 特有的问题"
echo ""

# 6. 可能的根本原因
echo "💡 可能的根本原因:"
echo "-------------------"
echo "1. 客户端本地缓存了手机号（需要清除应用数据）"
echo "2. 服务端的某个 API 没有正确应用隐私规则"
echo "3. Teamgram v9 的 bug（CheckPrivacy 函数）"
echo "4. 客户端从搜索结果中获取的用户信息"
echo ""

# 7. 终极测试
echo "🎯 终极测试:"
echo "-------------------"
echo "创建一个新用户，看看是否也有同样的问题:"
echo ""
echo "1. 在另一台手机上注册新用户（例如 +86 138 0000 0003）"
echo "2. 设置昵称为 'TestUser'"
echo "3. 设置手机号隐私为 'Nobody'"
echo "4. 让 jack 或 yang 搜索并添加这个新用户"
echo "5. 查看显示的是昵称还是手机号"
echo ""
echo "如果新用户也显示手机号，说明是 Teamgram v9 的通用 bug"
echo "如果新用户显示昵称，说明是 ouyang 账户的特殊问题"
echo ""

echo "=========================="
echo "✅ 测试准备完成"
echo ""
