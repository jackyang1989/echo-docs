# Echo 双手机消息测试指南

## 📱 测试目标

在两台真机上安装 Echo 应用，测试用户之间的消息发送和接收功能。

---

## ✅ 前置条件检查

### 1. 服务器状态
```bash
# 检查 Echo 服务是否运行
ps aux | grep -E "(gnetway|session|bff|authsession|media)" | grep -v grep

# 应该看到以下服务：
# ✅ gnetway (端口 10443)
# ✅ session
# ✅ bff
# ✅ authsession
# ✅ media
```

**当前状态**: ✅ 所有服务正常运行

### 2. APK 文件
```bash
# APK 位置
echo-android-client/TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk

# 文件大小: 74.7 MB
# 构建时间: 2026-02-01 03:19:14
```

**当前状态**: ✅ APK 已构建完成

### 3. 网络配置
- **服务器 IP**: `192.168.0.17`
- **服务器端口**: `10443`
- **验证码**: `12345` (固定，测试模式)

---

## 📋 测试步骤

### 步骤 1: 准备 APK 文件

#### 方法 A: 通过 ADB 安装（推荐）

```bash
# 1. 连接第一台手机
adb devices

# 2. 安装 APK
adb install -r echo-android-client/TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk

# 3. 断开第一台手机，连接第二台手机
# 重复步骤 1-2
```

#### 方法 B: 通过文件传输

```bash
# 1. 将 APK 复制到桌面
cp echo-android-client/TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk ~/Desktop/Echo-Test.apk

# 2. 通过以下方式传输到手机：
#    - AirDrop (如果是 iPhone 附近的 Android)
#    - 微信/QQ 文件传输
#    - USB 数据线拷贝
#    - 云盘（百度网盘、Google Drive 等）

# 3. 在手机上找到 APK 文件并安装
```

---

### 步骤 2: 注册第一个用户（手机 A）

1. **打开 Echo 应用**
   - 点击桌面上的 Echo 图标

2. **输入手机号**
   - 格式: `+86 138 0000 0001`
   - 或任意其他手机号（测试环境不验证真实性）

3. **输入验证码**
   - 固定验证码: `12345`
   - 无需等待短信

4. **设置用户信息**
   - 名字: `用户 A` 或 `Alice`
   - 姓氏: (可选)

5. **完成注册**
   - 进入主界面

6. **记录用户信息**
   - 进入 Settings → My Profile
   - 记录用户名（如果有）或手机号

---

### 步骤 3: 注册第二个用户（手机 B）

1. **打开 Echo 应用**

2. **输入不同的手机号**
   - 格式: `+86 138 0000 0002`
   - ⚠️ 必须与手机 A 的号码不同

3. **输入验证码**
   - 固定验证码: `12345`

4. **设置用户信息**
   - 名字: `用户 B` 或 `Bob`
   - 姓氏: (可选)

5. **完成注册**

---

### 步骤 4: 添加联系人

#### 在手机 A 上操作：

1. **打开联系人页面**
   - 点击右上角的 "+" 或搜索图标

2. **搜索用户 B**
   - 输入手机 B 的手机号: `+86 138 0000 0002`
   - 或输入用户名（如果设置了）

3. **添加联系人**
   - 点击搜索结果
   - 点击 "Add Contact" 或 "添加联系人"

---

### 步骤 5: 发送消息测试

#### 测试 1: 文本消息

**手机 A → 手机 B**:
1. 在手机 A 上打开与用户 B 的聊天
2. 输入消息: `你好，这是来自用户 A 的消息`
3. 点击发送

**验证**:
- ✅ 手机 A 显示消息已发送（单勾或双勾）
- ✅ 手机 B 收到消息通知
- ✅ 手机 B 打开聊天，看到消息内容

**手机 B → 手机 A**:
1. 在手机 B 上回复: `收到！这是用户 B 的回复`
2. 点击发送

**验证**:
- ✅ 手机 B 显示消息已发送
- ✅ 手机 A 收到消息

---

#### 测试 2: 表情符号

**手机 A**:
- 发送: `😀 👍 ❤️ 🎉`

**验证**:
- ✅ 手机 B 正确显示表情符号

---

#### 测试 3: 长消息

**手机 B**:
- 发送一段长文本（100+ 字符）

**验证**:
- ✅ 消息完整发送和接收
- ✅ 消息格式正确

---

#### 测试 4: 图片发送（可选）

**手机 A**:
1. 点击附件图标
2. 选择相册中的图片
3. 发送

**验证**:
- ✅ 图片上传成功
- ✅ 手机 B 收到图片
- ✅ 图片可以正常查看

---

#### 测试 5: 消息状态

**观察消息状态变化**:
- ✅ 发送中: 时钟图标
- ✅ 已发送: 单勾 ✓
- ✅ 已送达: 双勾 ✓✓
- ✅ 已读: 双勾变蓝色（如果启用已读回执）

---

### 步骤 6: 高级测试（可选）

#### 测试 6: 群聊功能

1. **创建群组**（手机 A）:
   - 点击 "New Group"
   - 添加用户 B
   - 设置群组名称: `测试群组`

2. **发送群消息**:
   - 手机 A 发送: `这是群消息测试`
   - 手机 B 回复: `收到群消息`

**验证**:
- ✅ 两台手机都能看到群消息
- ✅ 消息顺序正确

---

#### 测试 7: 在线状态

1. **手机 A 查看用户 B 的在线状态**:
   - 打开与用户 B 的聊天
   - 查看顶部状态栏

**验证**:
- ✅ 显示 "online" 或 "last seen recently"

2. **手机 B 退出应用**:
   - 按 Home 键或关闭应用

**验证**:
- ✅ 手机 A 显示用户 B 离线状态

---

#### 测试 8: 消息同步

1. **手机 A 发送多条消息**（手机 B 离线）:
   - 发送 3-5 条消息

2. **手机 B 重新打开应用**:

**验证**:
- ✅ 所有离线消息都能收到
- ✅ 消息顺序正确
- ✅ 未读消息计数正确

---

## 🐛 常见问题排查

### 问题 1: 无法连接服务器

**症状**: 应用显示 "Connecting..." 或 "Waiting for network"

**解决方案**:
```bash
# 1. 检查服务器是否运行
ps aux | grep gnetway | grep -v grep

# 2. 检查端口是否监听
lsof -i :10443

# 3. 检查手机和 Mac 是否在同一局域网
# 手机 WiFi 设置 → 查看 IP 地址（应该是 192.168.0.x）

# 4. 重启 gnetway 服务
cd echo-server-source/echod/bin
pkill -f gnetway
./gnetway -f=../etc/gnetway.yaml &
```

---

### 问题 2: 验证码错误

**症状**: 输入 `12345` 后提示验证码错误

**解决方案**:
```bash
# 1. 检查 authsession 服务日志
tail -f echo-server-source/logs/authsession.log

# 2. 确认验证码配置
grep -r "12345" echo-server-source/echod/etc/

# 3. 重启 authsession 服务
cd echo-server-source/echod/bin
pkill -f authsession
./authsession -f=../etc/authsession.yaml &
```

---

### 问题 3: 消息发送失败

**症状**: 消息一直显示时钟图标，无法发送

**解决方案**:
```bash
# 1. 检查 session 和 bff 服务
ps aux | grep -E "(session|bff)" | grep -v grep

# 2. 查看服务日志
tail -f echo-server-source/logs/bff.log
tail -f echo-server-source/logs/session.log

# 3. 检查 MySQL 连接
docker ps | grep mysql

# 4. 重启相关服务
cd echo-server-source/echod/bin
pkill -f session
pkill -f bff
./session -f=../etc/session.yaml &
./bff -f=../etc/bff.yaml &
```

---

### 问题 4: 无法搜索到对方

**症状**: 搜索手机号或用户名时找不到对方

**解决方案**:
```bash
# 1. 确认用户已注册成功
mysql -h 127.0.0.1 -u root -pmy_root_secret echo -e "SELECT id, phone, first_name FROM users;"

# 2. 检查搜索功能日志
tail -f echo-server-source/logs/bff.log | grep -i search

# 3. 尝试使用完整手机号搜索（包括国家码）
# 例如: +8613800000002
```

---

### 问题 5: 图片无法发送

**症状**: 选择图片后上传失败

**解决方案**:
```bash
# 1. 检查 media 服务
ps aux | grep media | grep -v grep

# 2. 检查 MinIO 服务
docker ps | grep minio

# 3. 查看 media 服务日志
tail -f echo-server-source/logs/media/access.log

# 4. 重启 media 服务
cd echo-server-source/echod/bin
pkill -f media
./media -f=../etc/media.yaml &
```

---

## 📊 测试检查清单

### 基础功能
- [ ] 手机 A 成功注册
- [ ] 手机 B 成功注册
- [ ] 手机 A 可以搜索到手机 B
- [ ] 手机 A 可以添加手机 B 为联系人
- [ ] 手机 A → 手机 B 发送文本消息成功
- [ ] 手机 B → 手机 A 发送文本消息成功
- [ ] 消息状态正确显示（发送中、已发送、已送达）

### 高级功能
- [ ] 表情符号正常显示
- [ ] 长消息正常发送和接收
- [ ] 图片发送和接收正常
- [ ] 在线状态正确显示
- [ ] 离线消息能够同步
- [ ] 群聊功能正常（如果测试）

### 性能测试
- [ ] 消息发送延迟 < 1 秒
- [ ] 消息接收延迟 < 2 秒
- [ ] 应用启动时间 < 5 秒
- [ ] 无明显卡顿或崩溃

---

## 🎯 测试场景建议

### 场景 1: 基础聊天
1. 用户 A 和用户 B 互相发送 10 条消息
2. 验证消息顺序和内容正确

### 场景 2: 快速连发
1. 用户 A 快速发送 5 条消息（不等待发送完成）
2. 验证所有消息都能正确发送和接收

### 场景 3: 离线消息
1. 用户 B 关闭应用
2. 用户 A 发送 3 条消息
3. 用户 B 重新打开应用
4. 验证所有消息都能收到

### 场景 4: 网络切换
1. 用户 A 发送消息时切换 WiFi/移动数据
2. 验证消息能够继续发送

### 场景 5: 多媒体消息
1. 发送图片、视频（如果支持）
2. 验证媒体文件正确上传和下载

---

## 📝 测试记录模板

```
测试日期: 2026-02-01
测试人员: [你的名字]
服务器版本: Echo Server v1.0
客户端版本: Echo Android v1.0

手机 A:
- 型号: [手机型号]
- 系统: Android [版本]
- 手机号: +86 138 0000 0001
- 用户名: 用户 A

手机 B:
- 型号: [手机型号]
- 系统: Android [版本]
- 手机号: +86 138 0000 0002
- 用户名: 用户 B

测试结果:
✅ 基础消息发送: 通过
✅ 消息接收: 通过
✅ 在线状态: 通过
❌ 图片发送: 失败（原因: xxx）

问题记录:
1. [问题描述]
2. [问题描述]

备注:
[其他说明]
```

---

## 🚀 快速开始命令

```bash
# 1. 检查服务器状态
ps aux | grep -E "(gnetway|session|bff)" | grep -v grep

# 2. 复制 APK 到桌面
cp echo-android-client/TMessagesProj_AppHuawei/build/outputs/apk/afat/debug/app-huawei.apk ~/Desktop/Echo-Test.apk

# 3. 通过 ADB 安装（如果手机已连接）
adb install -r ~/Desktop/Echo-Test.apk

# 4. 监控服务器日志
tail -f echo-server-source/logs/bff.log
```

---

## 📞 需要帮助？

如果遇到问题，请提供以下信息：
1. 问题描述
2. 手机型号和系统版本
3. 服务器日志（相关部分）
4. 客户端日志（如果有）
5. 复现步骤

---

**祝测试顺利！** 🎉
