#!/bin/bash

# Echo 双手机测试准备脚本
# 用途: 快速准备双手机测试环境

set -e

echo "🚀 Echo 双手机测试准备"
echo "======================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 检查服务器状态
echo "📡 检查服务器状态..."
if ps aux | grep -E "(gnetway|session|bff|authsession|media)" | grep -v grep > /dev/null; then
    echo -e "${GREEN}✅ 服务器正在运行${NC}"
    echo ""
    echo "运行中的服务:"
    ps aux | grep -E "(gnetway|session|bff|authsession|media)" | grep -v grep | awk '{print "  - " $11}'
else
    echo -e "${RED}❌ 服务器未运行${NC}"
    echo "请先启动服务器:"
    echo "  cd echo-server-source/echod/bin"
    echo "  ./start-all.sh"
    exit 1
fi

echo ""

# 2. 检查 APK 文件
echo "📦 检查 APK 文件..."
APK_PATH="echo-android-client/TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    APK_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$APK_PATH")
    echo -e "${GREEN}✅ APK 文件存在${NC}"
    echo "  文件大小: $APK_SIZE"
    echo "  构建时间: $APK_DATE"
else
    echo -e "${RED}❌ APK 文件不存在${NC}"
    echo "请先构建 APK:"
    echo "  cd echo-android-client"
    echo "  ./gradlew :TMessagesProj_AppHuawei:assembleAfatDebug"
    exit 1
fi

echo ""

# 3. 复制 APK 到桌面
echo "📋 复制 APK 到桌面..."
cp "$APK_PATH" ~/Desktop/Echo-Test.apk
echo -e "${GREEN}✅ APK 已复制到桌面: ~/Desktop/Echo-Test.apk${NC}"

echo ""

# 4. 检查 ADB 连接
echo "📱 检查 ADB 连接..."
if command -v adb &> /dev/null; then
    DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device$" | wc -l | tr -d ' ')
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ 检测到 $DEVICE_COUNT 台设备${NC}"
        echo ""
        echo "连接的设备:"
        adb devices | grep "device$" | awk '{print "  - " $1}'
        echo ""
        echo -e "${YELLOW}💡 提示: 可以使用以下命令安装 APK:${NC}"
        echo "  adb install -r ~/Desktop/Echo-Test.apk"
    else
        echo -e "${YELLOW}⚠️  未检测到 ADB 设备${NC}"
        echo "请通过以下方式安装 APK:"
        echo "  1. 将 ~/Desktop/Echo-Test.apk 传输到手机"
        echo "  2. 在手机上点击 APK 文件安装"
    fi
else
    echo -e "${YELLOW}⚠️  未安装 ADB${NC}"
    echo "请通过以下方式安装 APK:"
    echo "  1. 将 ~/Desktop/Echo-Test.apk 传输到手机"
    echo "  2. 在手机上点击 APK 文件安装"
fi

echo ""

# 5. 显示网络配置
echo "🌐 网络配置信息..."
MAC_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
echo "  服务器 IP: ${GREEN}$MAC_IP${NC}"
echo "  服务器端口: ${GREEN}10443${NC}"
echo "  验证码: ${GREEN}12345${NC} (固定)"

echo ""

# 6. 显示测试账号建议
echo "👥 测试账号建议..."
echo "  手机 A: ${GREEN}+86 138 0000 0001${NC} (用户名: Alice)"
echo "  手机 B: ${GREEN}+86 138 0000 0002${NC} (用户名: Bob)"

echo ""

# 7. 显示快速命令
echo "⚡ 快速命令..."
echo "  查看服务器日志:"
echo "    tail -f echo-server-source/logs/bff.log"
echo ""
echo "  安装到手机 (ADB):"
echo "    adb install -r ~/Desktop/Echo-Test.apk"
echo ""
echo "  查看数据库用户:"
echo "    mysql -h 127.0.0.1 -u root -pmy_root_secret echo -e 'SELECT id, phone, first_name FROM users;'"

echo ""

# 8. 显示文档链接
echo "📚 测试文档..."
echo "  详细测试指南: ${GREEN}docs/temp/ECHO-TWO-PHONES-TESTING-GUIDE.md${NC}"

echo ""
echo "✅ 准备完成！现在可以开始测试了。"
echo ""
