# Echo 快速开始指南

## 🚀 一键部署 (推荐)

```bash
# 1. 给脚本添加执行权限
chmod +x deploy-echo-mac.sh configure-android-client.sh

# 2. 部署服务端
./deploy-echo-mac.sh

# 3. 配置客户端
./configure-android-client.sh
```

## 📋 前置要求

- ✅ Docker Desktop (必需)
- ✅ Go 1.21+ (服务端编译)
- ✅ Android Studio (客户端编译)
- ✅ JDK 17+ (Android 开发)

## 🔧 手动部署步骤

### 服务端部署 (5 分钟)

```bash
# 1. 启动依赖服务
cd echo-server-source
docker compose -f docker-compose-env.yaml up -d

# 2. 等待服务就绪 (约 1-2 分钟)
docker compose -f docker-compose-env.yaml ps

# 3. 构建服务端
make clean && make

# 4. 启动服务
cd echod/bin
./runall2.sh
```

### 客户端配置 (10 分钟)

```bash
# 1. 获取 API 凭证
# 访问 https://my.telegram.org

# 2. 编辑配置文件
# 文件: echo-android-client/TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java
# 修改: APP_ID, APP_HASH, 服务器地址

# 3. 编译
cd echo-android-client
./gradlew assembleDebug

# 4. 安装
adb install TMessagesProj_App/build/outputs/apk/debug/app-debug.apk
```

## 🌐 服务地址

| 服务 | 地址 | 凭证 |
|------|------|------|
| MySQL | 127.0.0.1:3306 | root / my_root_secret |
| Redis | 127.0.0.1:6379 | - |
| MinIO Console | http://127.0.0.1:9001 | minio / miniostorage |
| Echo Gateway | 127.0.0.1:10443 | - |
| Echo HTTP | http://127.0.0.1:8801 | - |

## 🔑 默认凭证

- **数据库密码**: `my_root_secret`
- **MinIO 用户**: `minio` / `miniostorage`
- **登录验证码**: `12345`

## 📱 测试登录

1. 启动 Android 应用
2. 输入任意手机号 (如 +1234567890)
3. 输入验证码: `12345`
4. 设置用户名和头像
5. 开始使用！

## 🛠️ 常用命令

### 服务管理

```bash
# 查看服务状态
docker compose -f echo-server-source/docker-compose-env.yaml ps

# 查看日志
docker compose -f echo-server-source/docker-compose-env.yaml logs -f

# 重启服务
docker compose -f echo-server-source/docker-compose-env.yaml restart

# 停止服务
docker compose -f echo-server-source/docker-compose-env.yaml down
```

### 数据库操作

```bash
# 连接数据库
docker exec -it mysql mysql -uroot -pmy_root_secret echo

# 查看用户
docker exec mysql mysql -uroot -pmy_root_secret -e "SELECT * FROM echo.users;"

# 重置数据库
docker exec mysql mysql -uroot -pmy_root_secret -e "DROP DATABASE echo; CREATE DATABASE echo;"
```

### Android 开发

```bash
# 清理构建
cd echo-android-client
./gradlew clean

# 编译 Debug
./gradlew assembleDebug

# 编译 Release
./gradlew assembleRelease

# 查看设备
adb devices

# 安装应用
adb install -r TMessagesProj_App/build/outputs/apk/debug/app-debug.apk

# 查看日志
adb logcat | grep Telegram
```

## 🐛 故障排查

### 问题: Docker 服务无法启动

```bash
# 检查 Docker 状态
docker info

# 检查端口占用
lsof -i :3306
lsof -i :6379

# 清理并重启
docker compose -f echo-server-source/docker-compose-env.yaml down
docker compose -f echo-server-source/docker-compose-env.yaml up -d
```

### 问题: 数据库连接失败

```bash
# 查看 MySQL 日志
docker logs mysql

# 重启 MySQL
docker restart mysql

# 测试连接
docker exec mysql mysqladmin ping
```

### 问题: MinIO 存储桶未创建

访问 MinIO 控制台手动创建:
- http://127.0.0.1:9001
- 创建存储桶: documents, encryptedfiles, photos, videos

### 问题: Android 编译失败

```bash
# 清理缓存
cd echo-android-client
./gradlew clean
rm -rf .gradle
rm -rf ~/.gradle/caches

# 重新同步
./gradlew --refresh-dependencies
```

### 问题: 无法连接服务器

1. 检查服务端是否运行: `ps aux | grep echo`
2. 检查端口是否开放: `nc -zv 127.0.0.1 10443`
3. 查看服务端日志: `tail -f echo-server-source/echod/logs/*.log`
4. 确认客户端配置的服务器地址正确

## 📚 详细文档

- **完整部署指南**: [DEPLOYMENT_GUIDE_MAC.md](DEPLOYMENT_GUIDE_MAC.md)
- **客户端配置**: 运行 `./configure-android-client.sh` 后查看 `echo-android-client/LOCAL_CONFIG.md`
- **Echo 文档**: https://github.com/echo/echo-server
- **Telegram API**: https://core.telegram.org/api

## 🎯 下一步

1. ✅ 完成基础部署
2. 📱 测试客户端登录
3. 💬 测试消息发送
4. 🎨 开始自定义开发
5. 🚀 参考 ECHO_*.md 文档进行品牌定制

## 💡 开发建议

### 服务端开发

```bash
# 修改代码后
cd echo-server-source
make clean && make
cd echod/bin
pkill -f "echod/bin"
./runall2.sh
```

### 客户端开发

1. 在 Android Studio 中修改代码
2. 点击 Run 按钮
3. 应用自动编译并安装到设备

### 调试技巧

```bash
# 实时查看服务端日志
tail -f echo-server-source/echod/logs/*.log

# 实时查看 Android 日志
adb logcat | grep -E "Telegram|MTPROTO"

# 网络抓包
tcpdump -i lo0 -n port 10443
```

## ⚠️ 注意事项

1. **仅用于开发测试**: 本配置不适合生产环境
2. **默认密码**: 生产环境必须修改所有默认密码
3. **API 凭证**: 不要泄露你的 API_ID 和 API_HASH
4. **数据备份**: 定期备份数据库和 MinIO 数据
5. **端口冲突**: 确保所需端口未被占用

## 🆘 获取帮助

- 查看日志文件定位问题
- 参考 [DEPLOYMENT_GUIDE_MAC.md](DEPLOYMENT_GUIDE_MAC.md) 详细说明
- 检查 GitHub Issues
- 加入 Telegram 群组: https://t.me/+TjD5LZJ5XLRlCYLF

---

**祝你部署顺利！🎉**
