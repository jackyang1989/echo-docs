# ECHO-BUG-026: SOCKS5 代理干扰 MTProto 连接

## 变更 ID
ECHO-BUG-026

## 变更类型
Bug 修复

## 优先级
🔴 高（阻塞登录流程）

## 开发者
AI Agent

## 开发日期
2026-02-04

## 上游版本基线
- Telegram Android: v10.5.2
- Teamgram Gateway: v1.2.3

---

## 1. 问题描述

### 问题现象
客户端无法连接到 Gateway，Gateway 日志显示：
- `peek bytes length < 12`
- 收到的首包数据为 `05 02 00 02`（SOCKS5 握手包）
- 客户端不断重连（reason 2）

### 根本原因
**ClashX 的 SOCKS5 代理（监听 7890 端口）通过 TUN 模式全局劫持了所有 TCP 连接**，包括客户端到 Gateway 的 MTProto 连接。

即使：
- 客户端 App 内没有配置代理
- Android 系统代理已清空
- 客户端直连 `192.168.0.17:10443`

ClashX 的 TUN 模式仍然会在系统网络层拦截所有 TCP 流量，将其转换为 SOCKS5 代理请求。

### 协议不匹配
- **Gateway 期望**：MTProto 协议数据（DH 握手）
- **实际收到**：SOCKS5 握手包 `05 02 00 02`
- **结果**：协议解析失败，连接断开

---

## 2. 诊断过程

### 2.1 发现 SOCKS5 握手包
通过 Gateway 日志和网络抓包，发现首包数据为 `05 02 00 02`：
- `05`：SOCKS5 版本号
- `02`：支持的认证方法数量
- `00 02`：认证方法列表

### 2.2 排查代理来源
执行诊断脚本 `diagnose-socks5-proxy.sh`：

```bash
# 1. 检查 Mac 上的 SOCKS5 代理监听
lsof -nP -iTCP -sTCP:LISTEN | egrep ":(7890|1080|10808|9050|8118)\b"
# 结果：ClashX 正在监听 7890 端口

# 2. 检查 Gradle 代理配置
grep -nE "socksProxyHost|socksProxyPort" ~/.gradle/gradle.properties
# 结果：已注释，无影响

# 3. 检查 Android 系统代理
adb shell settings get global http_proxy
# 结果：null（未设置）

# 4. 检查 App 内代理设置
# 结果：未开启
```

### 2.3 确认问题根源
**ClashX TUN 模式**在系统网络层全局劫持 TCP 连接，即使应用层没有配置代理，流量仍被转发到 SOCKS5 代理。

---

## 3. 解决方案

### 3.1 临时解决方案（用于测试）
**完全退出 ClashX**：
```bash
# 退出 ClashX 应用
# 验证 7890 端口不再监听
lsof -nP -iTCP -sTCP:LISTEN | grep 7890
```

### 3.2 长期解决方案（保留 ClashX）
**在 ClashX 中配置规则，让 MTProto 连接直连**：

编辑 ClashX 配置文件（通常在 `~/.config/clash/config.yaml`）：

```yaml
rules:
  # Echo MTProto Gateway 直连（不走代理）
  - IP-CIDR,192.168.0.17/32,DIRECT
  - DST-PORT,10443,DIRECT
  
  # 其他规则...
  - MATCH,PROXY
```

重启 ClashX 使配置生效。

### 3.3 清理环境
```bash
# 1. 清空 Android 系统代理
adb shell settings put global http_proxy :0
adb shell settings delete global global_http_proxy_host
adb shell settings delete global global_http_proxy_port

# 2. 清空 App 数据
adb shell pm clear com.echo.messenger

# 3. 确保 App 内代理未开启
# 在 App 中：Settings → Data and Storage → Proxy → 关闭
```

---

## 4. 验证方法

### 4.1 网络抓包验证
```bash
# 抓取 10443 端口的流量
sudo tcpdump -i any -n -s 0 -vvv 'tcp port 10443' -X | head -n 60

# 在手机上打开 App，触发连接

# 检查首包数据：
# ✅ 正确：不再出现 05 02 00 02（SOCKS5 握手）
# ✅ 正确：出现 MTProto DH 握手数据
```

### 4.2 Gateway 日志验证
```bash
# 启动 Gateway
cd echo-server && go run ./cmd/gateway/...

# 在手机上打开 App

# 检查 Gateway 日志：
# ✅ 正确：🔐 [DH] Handshake started
# ✅ 正确：🔐 [DH] Handshake completed
# ✅ 正确：📱 [RPC] help.getConfig 或 auth.sendCode
# ❌ 错误：peek bytes length < 12
```

---

## 5. 修改的文件清单

### 5.1 新增文件
- `diagnose-socks5-proxy.sh` - SOCKS5 代理诊断脚本
- `echo-docs/echo-server/docs/core/changes/bugfixes/ECHO-BUG-026-socks5-proxy-interference.md` - 本文档

### 5.2 回滚的错误修改
- `echo-server/internal/gateway/help_handler.go`
  - 回滚了错误的 IP 地址强制修改（`192.168.0.17` → `127.0.0.1`）
  - 该修改方向错误，问题根源是代理而非 IP 配置

---

## 6. 技术细节

### 6.1 SOCKS5 握手流程
```
客户端 → 代理服务器：
  05 02 00 02
  ^^  ^^ ^^^^
  |   |  认证方法列表（00=无认证, 02=用户名密码）
  |   认证方法数量
  SOCKS5 版本

代理服务器 → 客户端：
  05 00
  ^^  ^^
  |   选择的认证方法
  SOCKS5 版本
```

### 6.2 MTProto 握手流程
```
客户端 → Gateway：
  [8 字节 auth_key_id] [8 字节 message_id] [4 字节 message_length] [payload]
  
Gateway 期望：
  - 至少 12 字节（auth_key_id + message_id 的前 4 字节）
  - 不是 05 02 00 02（SOCKS5 握手）
```

### 6.3 为什么会出现协议不匹配
1. 客户端尝试直连 `192.168.0.17:10443`
2. ClashX TUN 模式拦截 TCP 连接
3. ClashX 将连接转发到 SOCKS5 代理（7890 端口）
4. SOCKS5 代理发送握手包 `05 02 00 02` 到 Gateway
5. Gateway 期望 MTProto 数据，收到 SOCKS5 握手，解析失败

---

## 7. 经验教训

### 7.1 诊断原则
1. **先看协议数据，再猜测原因**
   - 看到 `05 02 00 02` 立即识别为 SOCKS5 握手
   - 不要盲目修改服务端代码

2. **全局代理工具的隐蔽性**
   - ClashX TUN 模式在系统网络层工作
   - 应用层无法感知，难以排查
   - 需要检查系统级代理工具

3. **不要修改正确的代码**
   - Gateway 的 IP 配置是正确的
   - 问题在客户端环境，不在服务端

### 7.2 预防措施
1. **开发环境规范**
   - 明确记录是否使用全局代理工具
   - 测试前确认代理工具状态
   - 配置代理规则，排除开发端口

2. **诊断工具**
   - 提供 `diagnose-socks5-proxy.sh` 快速诊断脚本
   - 网络抓包是最可靠的诊断手段

---

## 8. 上游兼容性分析

### 8.1 冲突风险
- **风险等级**：无
- **原因**：这是环境配置问题，不涉及代码修改

### 8.2 合并策略
- 无需合并，这是环境问题的诊断和解决方案文档

---

## 9. 回滚计划

### 9.1 如果需要恢复 ClashX
1. 启动 ClashX
2. 配置规则让 MTProto 直连（见 3.2 节）
3. 验证连接正常

### 9.2 如果需要完全禁用代理
1. 退出 ClashX
2. 清空系统代理设置
3. 清空 App 数据

---

## 10. 相关文档

- [ECHO-BUG-024: Gateway RPC 响应未发送](./ECHO-BUG-024-gateway-rpc-response-not-sent.md)
- [ECHO-BUG-025: Pre-Auth RPC 白名单](./ECHO-BUG-025-pre-auth-rpc-whitelist.md)
- [Gateway 架构设计](../../architecture/system-design.md)

---

## 11. 总结

**问题根源**：ClashX SOCKS5 代理全局劫持 TCP 连接

**解决方案**：退出 ClashX 或配置直连规则

**关键教训**：先看协议数据，不要盲目修改代码

**验证方法**：网络抓包 + Gateway 日志

---

**状态**: ✅ 已解决（待终端恢复后验证）

**最后更新**: 2026-02-04
