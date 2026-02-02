# 🚀 Echo 双手机测试快速参考

## ✅ 当前状态

- ✅ **服务器**: 正在运行 (192.168.0.17:10443)
- ✅ **APK**: 已安装到两台设备
  - 设备 A: PDEM10 (OnePlus)
  - 设备 B: SM_S9180 (Samsung)
- ✅ **验证码**: 12345 (固定)

---

## 📱 测试步骤（超简化版）

### 1️⃣ 手机 A - 注册第一个用户

```
1. 打开 Echo 应用
2. 输入手机号: +86 138 0000 0001
3. 输入验证码: 12345
4. 设置名字: Alice
5. 完成注册
```

### 2️⃣ 手机 B - 注册第二个用户

```
1. 打开 Echo 应用
2. 输入手机号: +86 138 0000 0002
3. 输入验证码: 12345
4. 设置名字: Bob
5. 完成注册
```

### 3️⃣ 手机 A - 添加联系人

```
1. 点击右上角搜索图标
2. 输入: +8613800000002
3. 点击搜索结果
4. 点击 "Add Contact"
```

### 4️⃣ 发送消息测试

```
手机 A:
1. 打开与 Bob 的聊天
2. 输入: 你好，Bob！
3. 点击发送

手机 B:
1. 查看是否收到消息
2. 回复: 你好，Alice！
```

---

## 🔧 常用命令

### 监控服务器（实时）
```bash
./monitor-two-phones-test.sh
```

### 查看 BFF 日志
```bash
tail -f echo-server-source/logs/bff.log
```

### 查看数据库用户
```bash
mysql -h 127.0.0.1 -u root -pmy_root_secret echo -e "SELECT id, phone, first_name FROM users;"
```

### 查看最近消息
```bash
mysql -h 127.0.0.1 -u root -pmy_root_secret echo -e "SELECT user_id, peer_id, message FROM messages ORDER BY id DESC LIMIT 10;"
```

### 重启服务（如果需要）
```bash
cd echo-server-source/echod/bin
pkill -f gnetway && ./gnetway -f=../etc/gnetway.yaml &
pkill -f session && ./session -f=../etc/session.yaml &
pkill -f bff && ./bff -f=../etc/bff.yaml &
```

---

## 🐛 快速排查

### 问题: 无法连接服务器
```bash
# 检查服务是否运行
ps aux | grep gnetway | grep -v grep

# 检查端口
lsof -i :10443

# 重启 gnetway
cd echo-server-source/echod/bin
pkill -f gnetway
./gnetway -f=../etc/gnetway.yaml &
```

### 问题: 验证码错误
```bash
# 查看 authsession 日志
tail -f echo-server-source/logs/authsession.log

# 重启 authsession
cd echo-server-source/echod/bin
pkill -f authsession
./authsession -f=../etc/authsession.yaml &
```

### 问题: 消息发送失败
```bash
# 查看 BFF 日志
tail -f echo-server-source/logs/bff.log

# 查看 session 日志
tail -f echo-server-source/logs/session.log

# 重启相关服务
cd echo-server-source/echod/bin
pkill -f session && ./session -f=../etc/session.yaml &
pkill -f bff && ./bff -f=../etc/bff.yaml &
```

---

## 📊 测试检查清单

- [ ] 手机 A 成功注册 (+86 138 0000 0001)
- [ ] 手机 B 成功注册 (+86 138 0000 0002)
- [ ] 手机 A 可以搜索到手机 B
- [ ] 手机 A 添加手机 B 为联系人
- [ ] 手机 A → 手机 B 发送消息成功
- [ ] 手机 B 收到消息
- [ ] 手机 B → 手机 A 发送消息成功
- [ ] 手机 A 收到消息
- [ ] 消息状态正确显示（✓ 或 ✓✓）
- [ ] 在线状态正确显示

---

## 🎯 测试场景

### 场景 1: 基础聊天
```
1. 用户 A 发送: "你好"
2. 用户 B 回复: "你好"
3. 互相发送 5 条消息
```

### 场景 2: 表情符号
```
1. 用户 A 发送: "😀 👍 ❤️"
2. 验证用户 B 正确显示
```

### 场景 3: 离线消息
```
1. 用户 B 关闭应用
2. 用户 A 发送 3 条消息
3. 用户 B 重新打开应用
4. 验证所有消息都收到
```

---

## 📞 需要帮助？

查看详细文档:
```bash
cat docs/temp/ECHO-TWO-PHONES-TESTING-GUIDE.md
```

或者直接问我！😊
