# ECHO-BUG-005: Android 编译失败 - NDK ar 进程死锁 (UE State)

**日期**: 2026-01-31  
**类型**: Bug 修复  
**严重程度**: 严重 (阻塞性)  
**状态**: ✅ 已修复  
**作者**: AI Assistant

---

## 问题概述

多次 Android 编译尝试（总计 5+ 小时）在 C++ 编译/链接阶段无限期挂起。
表现为数以百计的 `aarch64-linux-android-ar` 进程处于 **不可中断等待 (UE - Uninterruptible Wait)** 状态，导致系统负载虽低但编译无法进行，且 `kill -9` 无法终止这些进程。

---

## 根本原因 (Root Cause)

**NDK 工具链在 macOS 上的插件加载死锁。**

1.  **触发点**: `ar` (归档工具) 在处理 `.o` 文件时，尝试加载 `bfd-plugins` 目录下的动态库。
2.  **具体组件**: `LLVMgold.dylib` (LLVM Gold Plugin)。
3.  **证据**:
    *   `sample` 采样显示堆栈卡在 `dyld4::APIs::dlopen_from` -> `LLVMgold.dylib` 初始化 (`llvm::DebugCounter::addCounter`)。
    *   `lsof` 显示卡住的进程打开了 `/lib/bfd-plugins` 目录。
4.  **死锁机制**: 在 macOS 上，当多个 `ar` 进程（即使已限制 CMake 并发，Ninja 仍可能调度）尝试同时加载或初始化该插件时，触发了内核级或文件系统级的锁竞争，导致进程进入 D 状态 (Disk Sleep / Uninterruptible Wait)。

---

## 解决方案

### 1. 禁用 BFD 插件加载 (决定性修复)

重命名 NDK 中的 `bfd-plugins` 目录，阻止 `ar` 加载它可以彻底解决此问题。

```bash
# 执行命令 (根据实际 NDK 版本调整路径)
NDK_BASE="$HOME/Library/Android/sdk/ndk/21.4.7075529"
mv "$NDK_BASE/toolchains/llvm/prebuilt/darwin-x86_64/lib/bfd-plugins" \
   "$NDK_BASE/toolchains/llvm/prebuilt/darwin-x86_64/lib/bfd-plugins.off"
```

### 2. 辅助防御措施

为了保险起见，建议在本地编译时限制并发（尤其是在内存或 I/O 有限的机器上）：

```bash
export CMAKE_BUILD_PARALLEL_LEVEL=1
export NINJA_FLAGS="-j1"
```

---

## 验证结果

应用上述修复后：
1.  **U-state 归零**: 卡住的 `ar` 进程迅速消失（或不再产生）。
2.  **编译推进**: `buildCMakeDebug` 阶段顺利完成，不再产生僵尸进程。

---

## 经验教训

1.  **UE 进程误判**: 最初误认为是内存不足 (OOM) 导致的 Thrashing，实际上是死锁。
2.  **诊断工具价值**: `sample` 和 `lsof` 在定位“不消耗 CPU 但卡住”的进程时比 `top`/`ps` 更具决定性。
3.  **并发控制**: 在 macOS 上编译大型 C++ 项目 (Telegram) 时，NDK 工具链可能存在并发安全性问题。

---

**文档版本**: 2.0 (更新根因)  
**最后更新**: 2026-01-31
