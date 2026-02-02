#!/bin/bash
# 编译进度监控脚本（改进版 - 避免误报）
# 每 30 秒检查一次，仅在持续增长时预警

echo "🔍 开始监控编译进度..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚠️  注意事项："
echo "   • U-state 偶发 1-2 个属于正常抖动"
echo "   • 只有持续增长才是危险信号"
echo "   • Ctrl+C 停止监控（不会影响构建）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COUNTER=0
PREV_UE=0
UE_RISING_COUNT=0

while true; do
    COUNTER=$((COUNTER + 1))
    TIMESTAMP=$(date '+%H:%M:%S')
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "[$TIMESTAMP] 检查 #$COUNTER"
    
    # 1. UE 进程数量（智能判断）
    UE_COUNT=$(ps axo stat,comm | egrep "aarch64-linux-android|clang|ninja|ld" | awk '$1 ~ /U/ {c++} END{print c+0}')
    
    # 判断趋势
    if [ "$UE_COUNT" -eq 0 ]; then
        echo "✅ U-state: $UE_COUNT (完美)"
        UE_RISING_COUNT=0
    elif [ "$UE_COUNT" -ge 10 ]; then
        echo "🚨 U-state: $UE_COUNT (严重！建议立即停止构建)"
        UE_RISING_COUNT=$((UE_RISING_COUNT + 1))
    elif [ "$UE_COUNT" -gt "$PREV_UE" ]; then
        UE_RISING_COUNT=$((UE_RISING_COUNT + 1))
        if [ "$UE_RISING_COUNT" -ge 3 ]; then
            echo "⚠️  U-state: $UE_COUNT (连续 ${UE_RISING_COUNT} 次上升，考虑停止)"
        else
            echo "⚠️  U-state: $UE_COUNT (上升中 ${UE_RISING_COUNT}/3)"
        fi
    else
        echo "✓  U-state: $UE_COUNT (可能是正常抖动)"
        UE_RISING_COUNT=0
    fi
    
    PREV_UE=$UE_COUNT
    
    # 2. 磁盘空间
    DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
    echo "💾 磁盘可用: $DISK_AVAIL"
    
    # 3. 日志最后几行
    if [ -f /tmp/gradle-final.log ]; then
        LOG_LINES=$(wc -l < /tmp/gradle-final.log | tr -d ' ')
        echo "📝 日志行数: $LOG_LINES"
        echo "━━ 最后 3 行 ━━"
        tail -n 3 /tmp/gradle-final.log | sed 's/^/   /'
    else
        echo "📝 等待构建开始..."
    fi
    
    echo ""
    sleep 30
done
