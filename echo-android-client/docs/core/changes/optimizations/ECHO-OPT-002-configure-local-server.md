# ECHO-OPT-002: 配置 Android 客户端连接本地服务器

## 变更类型
优化 (Optimization)

## 变更日期
2026-01-30

## 变更范围
- **项目**: Echo Android 客户端 (echo-android-client)
- **影响范围**: 网络连接配置
- **严重程度**: 🔴 Critical

---

## 问题描述

### 背景
默认配置指向 Telegram 官方服务器，需要修改为本地部署的 Echo 服务器。

### 原始配置
```cpp
// ConnectionsManager.cpp - initDatacenters()
datacenter->addAddressAndPort("149.154.175.50", 443, 0, "");  // Telegram DC1
datacenter->addAddressAndPort("149.154.167.51", 443, 0, "");  // Telegram DC2
datacenter->addAddressAndPort("149.154.175.100", 443, 0, ""); // Telegram DC3
datacenter->addAddressAndPort("149.154.167.91", 443, 0, "");  // Telegram DC4
datacenter->addAddressAndPort("149.154.171.5", 443, 0, "");   // Telegram DC5
```

### 目标配置
所有数据中心指向本地 Echo 服务器：
- **地址**: 127.0.0.1
- **端口**: 10443（Echo gnetway 监听端口）

---

## 解决方案

### 修改文件
**文件**: `TMessagesProj/jni/tgnet/ConnectionsManager.cpp`  
**函数**: `initDatacenters()`  
**行数**: 1814-1873

### 代码变更

#### 修改前
```cpp
void ConnectionsManager::initDatacenters() {
    Datacenter *datacenter;
    if (!testBackend) {
        if (datacenters.find(1) == datacenters.end()) {
            datacenter = new Datacenter(instanceNum, 1);
            datacenter->addAddressAndPort("149.154.175.50", 443, 0, "");
            datacenter->addAddressAndPort("2001:b28:f23d:f001::a", 443, 1, "");
            datacenters[1] = datacenter;
        }
        // ... DC 2-5 同样配置 ...
    }
}
```

#### 修改后
```cpp
void ConnectionsManager::initDatacenters() {
    Datacenter *datacenter;
    // Modified for Echo: all datacenters point to local server
    if (!testBackend) {
        if (datacenters.find(1) == datacenters.end()) {
            datacenter = new Datacenter(instanceNum, 1);
            datacenter->addAddressAndPort("127.0.0.1", 10443, 0, "");
            datacenters[1] = datacenter;
        }
        // ... DC 2-5 全部指向 127.0.0.1:10443 ...
    }
}
```

### 变更统计

| 数据中心 | 原始地址 | 新地址 | 原始端口 | 新端口 |
|---------|---------|--------|---------|--------|
| DC1 | 149.154.175.50 | 127.0.0.1 | 443 | 10443 |
| DC2 | 149.154.167.51 | 127.0.0.1 | 443 | 10443 |
| DC3 | 149.154.175.100 | 127.0.0.1 | 443 | 10443 |
| DC4 | 149.154.167.91 | 127.0.0.1 | 443 | 10443 |
| DC5 | 149.154.171.5 | 127.0.0.1 | 443 | 10443 |

**移除项**: 所有 IPv6 地址（不需要）

---

## 技术细节

### MTProto 连接流程

```
Android 客户端
    ↓
ConnectionsManager::initDatacenters()
    ↓
创建 Datacenter 对象（127.0.0.1:10443）
    ↓
建立 TCP 连接
    ↓
MTProto 握手
    ↓
Echo gnetway (本地服务器)
```

### 配置优先级

1. **硬编码配置**（当前修改）- 最高优先级
2. 本地存储的配置
3. 服务器推送的配置

### 影响范围

**受影响的连接类型**：
- Generic Connection（通用连接）
- Media Connection（媒体连接）
- Push Connection（推送连接）
- Download Connection（下载连接）
- Upload Connection（上传连接）

---

## 构建说明

### 重新编译要求

⚠️ **必须重新编译** native 代码才能生效

### 编译步骤

#### 使用 Android Studio
```
1. File → Open → echo-android-client
2. Build → Build Bundle(s) / APK(s) → Build APK(s)
3. 等待编译完成（首次约5-10分钟）
```

#### 使用命令行
```bash
cd echo-android-client
./gradlew assembleAfatDebug
```

**输出路径**:  
`TMessagesProj/build/outputs/apk/afat/debug/app-afat-debug.apk`

### 环境要求

| 工具 | 版本 | 说明 |
|------|------|------|
| Android Studio | Hedgehog+ | IDE |
| Android SDK | API 35 | SDK Platform |
| NDK | 27.2.12479018 | Native 编译 |
| CMake | 3.22.1+ | 构建工具 |
| JDK | 17+ | Java 编译器 |

---

## 验证测试

### 前置条件
✅ Echo 服务端运行在 127.0.0.1:10443

```bash
# 验证服务端
$ nc -zv 127.0.0.1 10443
Connection to 127.0.0.1 port 10443 [tcp/*] succeeded!

$ ps aux | grep gnetway
jianouyang  28212  ./gnetway -f=../etc/gnetway.yaml
```

### 测试步骤

1. **安装 APK**
   ```bash
   adb install app-afat-debug.apk
   ```

2. **启动应用**
   - 打开 Echo 应用

3. **测试连接**
   - 输入手机号
   - 观察网络请求

4. **查看日志**
   ```bash
   adb logcat | grep -i "connection\|datacenter"
   ```

### 预期结果

✅ 连接到 127.0.0.1:10443  
✅ MTProto 握手成功  
✅ 接收服务器响应  

---

## 配置对比

### 开发环境 vs 生产环境

| 环境 | 服务器地址 | 端口 | 用途 |
|------|-----------|------|------|
| **本地开发** | 127.0.0.1 | 10443 | ✅ 当前配置 |
| **内网测试** | 192.168.x.x | 10443 | 需修改 |
| **生产环境** | your-domain.com | 443 | 需修改 |

### 切换到生产环境

修改 `ConnectionsManager.cpp` 中的地址：

```cpp
// 生产环境配置示例
datacenter->addAddressAndPort("echo.example.com", 443, 0, "");
```

---

## 影响评估

### 正面影响
1. **✅ 本地开发** - 可独立测试完整流程
2. **✅ 隐私保护** - 数据不发送到外部服务器
3. **✅ 快速迭代** - 服务端客户端联调方便

### 限制
1. **🔴 仅限本机** - 其他设备无法连接
2. **⚠️ 需重新编译** - 每次地址变更都需重编译
3. **⚠️ 调试专用** - 不适合分发给用户

### 安全注意
- ⚠️ 127.0.0.1 仅限本机访问
- ⚠️ 生产环境必须使用 HTTPS (443)
- ⚠️ 不要在公网暴露未加密的 10443 端口

---

## 后续工作

### 短期改进
- [ ] 支持通过配置文件修改服务器地址
- [ ] 添加多环境切换功能（Debug/Release）
- [ ] 实现动态服务器发现

### 中期改进
- [ ] 支持域名解析
- [ ] 实现 DNS-over-HTTPS
- [ ] 添加服务器健康检查

### 长期规划
- [ ] 支持多服务器负载均衡
- [ ] 实现智能 DC 选择
- [ ] CDN 加速支持

---

## 相关文档
- [BUILD.md](../../BUILD.md) - 编译说明
- [system-design.md](../architecture/system-design.md) - 系统架构
- [ECHO-OPT-001](./ECHO-OPT-001-fix-import-paths.md) - 服务端导入路径修复

---

**变更编号**: ECHO-OPT-002  
**创建日期**: 2026-01-30  
**作者**: AI Assistant  
**审核状态**: ⏳ 待审核
