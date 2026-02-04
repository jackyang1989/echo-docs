#!/bin/bash

# Echo 项目根目录清理脚本
# 删除冗余文档、旧脚本和临时文件

echo "🧹 开始清理 Echo 项目根目录..."

# 1. 删除冗余文档
echo "📄 删除冗余文档..."
rm -f "AGENTS_UPDATE_SUMMARY.md"
rm -f "ECHO_AI_AGENT_ENFORCEMENT.md"
rm -f "ECHO_ENFORCEMENT_SUMMARY.md"
rm -f "ECHO_SERVER_REBUILD_DOCS_SUMMARY.md"
rm -f "OUYANG-PHONE-NUMBER-ISSUE-ANALYSIS.md"
rm -f "README_DEPLOYMENT.md"
rm -f "部署说明_中文.md"
rm -f "文档清理和AGENTS修改计划.md"

# 2. 删除旧的重命名脚本
echo "🔧 删除旧的重命名脚本..."
rm -f "echo-rebrand-old.sh"
rm -f "echo-rebrand-teamgram.sh"
rm -f "echo-rebrand.sh"
rm -f "rebrand-teamgram-to-echo.sh"
rm -f "rebrand-telegram-to-echo.sh"
rm -f "rebrand-to-echo.sh"

# 3. 删除临时日志文件
echo "📋 删除临时日志文件..."
rm -f "auto-commit-stderr.log"
rm -f "auto-commit-stdout.log"
rm -f "auto-commit.log"

# 4. 移动测试/诊断脚本到 tools/ 目录
echo "📦 移动测试/诊断脚本到 tools/ 目录..."
mkdir -p tools/testing
mkdir -p tools/diagnostics

mv -f "diagnose-messaging-issues.sh" tools/diagnostics/ 2>/dev/null || true
mv -f "diagnose-ouyang-privacy.sh" tools/diagnostics/ 2>/dev/null || true
mv -f "monitor-build.sh" tools/testing/ 2>/dev/null || true
mv -f "monitor-message-sending.sh" tools/testing/ 2>/dev/null || true
mv -f "monitor-two-phones-test.sh" tools/testing/ 2>/dev/null || true
mv -f "prepare-two-phones-test.sh" tools/testing/ 2>/dev/null || true
mv -f "test-server-response.sh" tools/testing/ 2>/dev/null || true
mv -f "test-user-object.sh" tools/testing/ 2>/dev/null || true

# 5. 删除 .DS_Store 文件
echo "🗑️  删除 .DS_Store 文件..."
find . -name ".DS_Store" -type f -delete

echo ""
echo "✅ 清理完成！"
echo ""
echo "📊 清理统计："
echo "  - 删除冗余文档: 8 个"
echo "  - 删除旧脚本: 6 个"
echo "  - 删除临时日志: 3 个"
echo "  - 移动测试脚本: 8 个"
echo ""
echo "⚠️  需要手动确认的目录："
echo "  - echo-server-source/ (旧服务端，已被 echo-server 替代？)"
echo "  - Telegram-master/ (旧客户端，已被 echo-android-client 替代？)"
echo ""
echo "如需删除这些目录，请手动执行："
echo "  rm -rf echo-server-source/"
echo "  rm -rf Telegram-master/"
