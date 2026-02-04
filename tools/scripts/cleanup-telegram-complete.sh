#!/bin/bash

# Echo 项目 - 彻底清理所有 Telegram 引用
# 因为服务端是 100% 自研，可以彻底替换，不需要兼容 Telegram

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Echo - 彻底清理 Telegram 引用${NC}"
echo -e "${GREEN}========================================${NC}"

# 工作目录
ANDROID_SRC="echo-android-client/TMessagesProj/src"

if [ ! -d "$ANDROID_SRC" ]; then
    echo -e "${RED}✗ 找不到 Android 源码目录${NC}"
    exit 1
fi

echo -e "\n${YELLOW}>>> 步骤 1: 备份当前代码${NC}"
cd echo-android-client
git add .
git commit -m "chore: backup before telegram cleanup" || echo "没有变更需要提交"
cd ..
echo -e "${GREEN}✓ 备份完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 2: 替换协议字段值（telegram_xxx → echo_xxx）${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/"telegram_channel"/"echo_channel"/g' \
  -e 's/"telegram_user"/"echo_user"/g' \
  -e 's/"telegram_theme"/"echo_theme"/g' \
  -e 's/"telegram_background"/"echo_background"/g' \
  -e 's/"telegram_story"/"echo_story"/g' \
  -e 's/"telegram_voicechat"/"echo_voicechat"/g' \
  -e 's/"telegram_videochat"/"echo_videochat"/g' \
  -e 's/"telegram_megagroup"/"echo_megagroup"/g' \
  -e 's/"telegram_livestream"/"echo_livestream"/g' \
  -e 's/"telegram_group_boost"/"echo_group_boost"/g' \
  -e 's/"telegram_channel_boost"/"echo_channel_boost"/g' \
  -e 's/"telegram_call"/"echo_call"/g' \
  -e 's/"telegram_premium"/"echo_premium"/g' \
  -e 's/"telegram_chat"/"echo_chat"/g' \
  -e 's/"telegram_channel_direct"/"echo_channel_direct"/g' \
  -e 's/"telegram_bot"/"echo_bot"/g' \
  -e 's/"telegram_album"/"echo_album"/g' \
  -e 's/"telegram_story_album"/"echo_story_album"/g' \
  -e 's/"telegram_stickerset"/"echo_stickerset"/g' \
  -e 's/"telegram_nft"/"echo_nft"/g' \
  -e 's/"telegram_message"/"echo_message"/g' \
  -e 's/"telegram_giftcode"/"echo_giftcode"/g' \
  -e 's/"telegram_community"/"echo_community"/g' \
  -e 's/"telegram_collection"/"echo_collection"/g' \
  -e 's/"telegram_chatlist"/"echo_chatlist"/g' \
  -e 's/"telegram_botapp"/"echo_botapp"/g' \
  -e 's/"telegram_auction"/"echo_auction"/g' \
  -e 's/"telegram_antispam_user_id"/"echo_antispam_user_id"/g' \
  -e 's/"telegram_antispam_group_size_min"/"echo_antispam_group_size_min"/g' \
  {} +
echo -e "${GREEN}✓ 协议字段值替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 3: 替换变量名和字段名${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/telegramPath/echoPath/g' \
  -e 's/telegramCacheTextView/echoCacheTextView/g' \
  -e 's/telegramDatabaseTextView/echoDatabaseTextView/g' \
  -e 's/telegramAntispamUserId/echoAntispamUserId/g' \
  -e 's/telegramAntispamGroupSizeMin/echoAntispamGroupSizeMin/g' \
  -e 's/telegramMaskProvider/echoMaskProvider/g' \
  -e 's/telegramAudioPlayer/echoAudioPlayer/g' \
  {} +
echo -e "${GREEN}✓ 变量名替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 4: 替换包名和常量${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/org\.telegram\.android/com.echo.android/g' \
  -e 's/org\.telegram\.key/com.echo.key/g' \
  -e 's/org\.telegram\.account/com.echo.account/g' \
  -e 's/org\.telegram\.passport/com.echo.passport/g' \
  -e 's/org\.telegram\.start/com.echo.start/g' \
  -e 's/TELEGRAM_VIDEO_CALL/ECHO_VIDEO_CALL/g' \
  -e 's/TELEGRAM_CALL/ECHO_CALL/g' \
  {} +
echo -e "${GREEN}✓ 包名和常量替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 5: 替换域名（telegram.me/dog → iecho.app）${NC}"
find "$ANDROID_SRC" -name "*.xml" -type f -exec sed -i '' \
  -e 's/telegram\.me/iecho.app/g' \
  -e 's/telegram\.dog/iecho.app/g' \
  {} +
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/telegram\.me/iecho.app/g' \
  -e 's/telegram\.dog/iecho.app/g' \
  {} +
echo -e "${GREEN}✓ 域名替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 6: 替换 XML 资源名${NC}"
find "$ANDROID_SRC" -name "*.xml" -type f -exec sed -i '' \
  -e 's/telegram_full_app/echo_full_app/g' \
  {} +
echo -e "${GREEN}✓ XML 资源名替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 7: 替换 Native 方法名${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/setTelegramTextures/setEchoTextures/g' \
  -e 's/a_telegram_sphere/a_echo_sphere/g' \
  -e 's/a_telegram_plane/a_echo_plane/g' \
  -e 's/a_telegram_mask/a_echo_mask/g' \
  {} +
echo -e "${GREEN}✓ Native 方法名替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 8: 替换产品 ID${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/telegram_premium/echo_premium/g' \
  {} +
echo -e "${GREEN}✓ 产品 ID 替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 9: 批量替换类名（Telegram → Echo）${NC}"
echo -e "${YELLOW}⚠️  这是最大规模的替换，可能需要几分钟...${NC}"
find "$ANDROID_SRC" -name "*.java" -type f -exec sed -i '' \
  -e 's/Telegram/Echo/g' \
  {} +
echo -e "${GREEN}✓ 类名替换完成${NC}"

echo -e "\n${YELLOW}>>> 步骤 10: 检查剩余的 telegram 引用${NC}"
REMAINING=$(grep -r "telegram\|Telegram" "$ANDROID_SRC" --include="*.java" --include="*.xml" 2>/dev/null | wc -l)
echo -e "${YELLOW}剩余引用数量: $REMAINING${NC}"

if [ "$REMAINING" -gt 0 ]; then
    echo -e "${YELLOW}剩余引用详情:${NC}"
    grep -r "telegram\|Telegram" "$ANDROID_SRC" --include="*.java" --include="*.xml" 2>/dev/null | head -20
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}清理完成！${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "\n${YELLOW}下一步操作:${NC}"
echo -e "1. 运行合规性检查: ${GREEN}./tools/validate-agents-compliance.sh${NC}"
echo -e "2. 编译验证: ${GREEN}cd echo-android-client && ./gradlew assembleDebug${NC}"
echo -e "3. 提交变更: ${GREEN}cd echo-android-client && git add . && git commit -m 'fix: remove all telegram references for compliance'${NC}"

