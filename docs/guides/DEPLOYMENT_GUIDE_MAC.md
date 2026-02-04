# Echo 本地部署指南 (macOS)

## 概述

本指南帮助你在 Mac 上部署完整的 Echo 系统：
- **服务端**: Echo Server (第三方 MTProto 服务器)
- **客户端**: Telegram Android (修改后连接到本地服务器)

## 前置要求

### 必需软件

1. **Docker Desktop for Mac**
   ```bash
   # 下载安装
   # https://docs.docker.com/desktop/install/mac-install/
   
   # 验证安装
   docker --version
   docker compose version
   ```

2. **Go 1.21+** (用于编译服务端)
   ```bash
   brew install go
   go version
   ```

3. **Android Studio** (用于编译客户端)
   - 下载: https://developer.android.com/studio
   - 需要 JDK 17+
   - Android SDK API 35
   - Android NDK 21.4.7075529

### 可选软件

```bash
# MySQL 客户端 (用于数据库管理)
brew install mysql-client

# Redis 客户端
brew install redis
```

## 快速开始

### 方式一: 使用自动化脚本 (推荐)

```bash
# 1. 进入项目目录
cd /Users/jianouyang/.gemini/antigravity/scratch/echo

# 2. 给脚本添加执行权限
chmod +x deploy-echo-mac.sh

# 3. 运行部署脚本
./deploy-echo-mac.sh
```

脚本会自动：
- ✅ 检查系统依赖
- ✅ 启动 Docker 服务 (MySQL, Redis, Kafka, etcd, MinIO)
- ✅ 初始化数据库
- ✅ 配置 MinIO 存储
- ✅ 构建并启动服务端 (可选)

### 方式二: 手动部署

#### 步骤 1: 启动依赖服务

```bash
cd echo-server-source

# 启动所有依赖服务
docker compose -f docker-compose-env.yaml up -d

# 查看服务状态
docker compose -f docker-compose-env.yaml ps

# 查看日志
docker compose -f docker-compose-env.yaml logs -f
```

等待所有服务启动完成 (约 1-2 分钟)。

#### 步骤 2: 验证服务

```bash
# 检查 MySQL
docker exec mysql mysqladmin ping -h localhost

# 检查 Redis
docker exec redis redis-cli ping

# 检查 MinIO
curl http://127.0.0.1:9000/minio/health/live
```

#### 步骤 3: 初始化 MinIO 存储桶

访问 MinIO 控制台: http://127.0.0.1:9001
- 用户名: `minio`
- 密码: `miniostorage`

创建以下存储桶:
- `documents`
- `encryptedfiles`
- `photos`
- `videos`

或使用脚本自动创建 (如果 `minio_init.sh` 存在)。

#### 步骤 4: 构建服务端

```bash
cd echo-server-source

# 清理旧构建
make clean

# 构建所有服务
make

# 查看构建结果
ls -la echod/bin/
```

#### 步骤 5: 启动服务端

```bash
cd echod/bin

# 启动所有服务
./runall2.sh

# 或后台运行
nohup ./runall2.sh > ../logs/echo.log 2>&1 &

# 查看日志
tail -f ../logs/echo.log
```

## 配置 Android 客户端

### 步骤 1: 获取 Telegram API 凭证

1. 访问 https://my.telegram.org
2. 登录你的 Telegram 账号
3. 进入 "API development tools"
4. 创建应用获取:
   - `api_id` (数字)
   - `api_hash` (字符串)

### 步骤 2: 配置 BuildVars.java

编辑文件: `echo-android-client/TMessagesProj/src/main/java/com/echo/messenger/BuildVars.java`

```java
public class BuildVars {
    // 填写你的 API 凭证
    public static final int APP_ID = YOUR_API_ID;
    public static final String APP_HASH = "YOUR_API_HASH";
    
    // 修改服务器地址指向本地
    public static final String PRODUCTION_SERVER = "127.0.0.1";
    public static final int PRODUCTION_PORT = 10443;
    
    // 其他配置...
}
```

### 步骤 3: 配置 Firebase (可选)

1. 访问 https://console.firebase.google.com/
2. 创建项目
3. 添加 Android 应用:
   - 包名: `org.telegram.messenger`
   - 包名: `org.telegram.messenger.beta`
4. 下载 `google-services.json`
5. 复制到: `echo-android-client/TMessagesProj/google-services.json`

### 步骤 4: 配置签名密钥

```bash
cd echo-android-client/TMessagesProj/config

# 生成新的 keystore (如果需要)
keytool -genkey -v -keystore release.keystore \
  -alias telegram \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

编辑 `gradle.properties`:
```properties
RELEASE_KEY_PASSWORD=your_password
RELEASE_KEY_ALIAS=telegram
RELEASE_STORE_PASSWORD=your_password
```

### 步骤 5: 编译客户端

#### 使用 Android Studio (推荐)

1. 打开 Android Studio
2. File → Open → 选择 `echo-android-client`
3. 等待 Gradle 同步完成
4. 选择 Build Variant: `debug`
5. 点击 Run 或 Build → Build Bundle(s) / APK(s)

#### 使用命令行

```bash
cd echo-android-client

# 编译 Debug 版本
./gradlew assembleDebug

# 编译 Release 版本
./gradlew assembleRelease

# 输出位置
# Debug: TMessagesProj_App/build/outputs/apk/debug/
# Release: TMessagesProj_App/build/outputs/apk/release/
```

### 步骤 6: 安装和测试

```bash
# 连接 Android 设备或启动模拟器
adb devices

# 安装 APK
adb install TMessagesProj_App/build/outputs/apk/debug/app-debug.apk

# 查看日志
adb logcat | grep Telegram
```

## 服务管理

### Docker 服务管理

```bash
cd echo-server-source

# 查看服务状态
docker compose -f docker-compose-env.yaml ps

# 启动服务
docker compose -f docker-compose-env.yaml up -d

# 停止服务
docker compose -f docker-compose-env.yaml down

# 重启服务
docker compose -f docker-compose-env.yaml restart

# 查看日志
docker compose -f docker-compose-env.yaml logs -f [service_name]

# 清理所有数据 (危险!)
docker compose -f docker-compose-env.yaml down -v
rm -rf data/
```

### Echo 服务管理

```bash
cd echo-server-source/echod/bin

# 查看运行的服务
ps aux | grep echo

# 停止所有服务
pkill -f "echod/bin"

# 重启服务
./runall2.sh
```

## 服务端口说明

| 服务 | 端口 | 说明 |
|------|------|------|
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存 |
| etcd | 2379, 2380 | 服务发现 |
| Kafka | 9092 | 消息队列 |
| Zookeeper | 2181 | Kafka 依赖 |
| MinIO | 9000 | 对象存储 API |
| MinIO Console | 9001 | Web 管理界面 |
| Echo Gateway | 10443 | 客户端连接入口 |
| Echo HTTP | 8801 | HTTP API |

## 数据库管理

### 连接数据库

```bash
# 使用 Docker 容器内的 MySQL 客户端
docker exec -it mysql mysql -uroot -pmy_root_secret echo

# 或使用本地 MySQL 客户端
mysql -h 127.0.0.1 -P 3306 -uroot -pmy_root_secret echo
```

### 常用 SQL 命令

```sql
-- 查看所有表
SHOW TABLES;

-- 查看用户
SELECT * FROM users LIMIT 10;

-- 查看消息
SELECT * FROM messages ORDER BY id DESC LIMIT 10;

-- 重置数据库 (危险!)
DROP DATABASE echo;
CREATE DATABASE echo;
```

### 重新初始化数据库

```bash
cd echo-server-source

# 进入容器
docker exec -it mysql bash

# 执行初始化脚本
cd /docker-entrypoint-initdb.d
mysql -uroot -pmy_root_secret echo < 1_echo.sql
mysql -uroot -pmy_root_secret echo < migrate-*.sql
mysql -uroot -pmy_root_secret echo < z_init.sql
```

## 故障排查

### 问题 1: Docker 服务无法启动

```bash
# 检查 Docker 是否运行
docker info

# 检查端口占用
lsof -i :3306
lsof -i :6379
lsof -i :9092

# 清理并重启
docker compose -f docker-compose-env.yaml down
docker system prune -a
docker compose -f docker-compose-env.yaml up -d
```

### 问题 2: 数据库连接失败

```bash
# 检查 MySQL 容器状态
docker logs mysql

# 测试连接
docker exec mysql mysqladmin ping -h localhost

# 重启 MySQL
docker restart mysql
```

### 问题 3: MinIO 存储桶未创建

```bash
# 手动创建存储桶
docker exec -it minio_mc sh

mc alias set local http://minio:9000 minio miniostorage
mc mb local/documents
mc mb local/encryptedfiles
mc mb local/photos
mc mb local/videos
mc policy set download local/documents
mc policy set download local/photos
mc policy set download local/videos
```

### 问题 4: Echo 服务启动失败

```bash
# 查看日志
cd echo-server-source/echod/logs
tail -f *.log

# 检查配置文件
cd echo-server-source/echod/etc
cat *.yaml

# 确保所有依赖服务已启动
docker compose -f docker-compose-env.yaml ps
```

### 问题 5: Android 编译失败

```bash
# 清理 Gradle 缓存
cd echo-android-client
./gradlew clean

# 删除 .gradle 目录
rm -rf .gradle
rm -rf ~/.gradle/caches

# 重新同步
./gradlew --refresh-dependencies
```

## 测试和验证

### 测试服务端

```bash
# 测试 Gateway 端口
nc -zv 127.0.0.1 10443

# 测试 HTTP API
curl http://127.0.0.1:8801/health

# 查看 etcd 服务注册
docker exec etcd etcdctl get --prefix ""
```

### 测试客户端

1. 启动 Android 应用
2. 输入手机号 (任意格式)
3. 输入验证码: `12345` (默认验证码)
4. 创建账号并测试消息发送

## 开发建议

### 修改服务端代码

```bash
cd echo-server-source

# 修改代码后重新编译
make clean
make

# 重启服务
cd echod/bin
pkill -f "echod/bin"
./runall2.sh
```

### 修改客户端代码

1. 在 Android Studio 中修改代码
2. 点击 Run 或使用 `./gradlew assembleDebug`
3. 应用会自动安装到设备

### 调试技巧

```bash
# 服务端日志
tail -f echo-server-source/echod/logs/*.log

# Android 日志
adb logcat | grep -E "Telegram|MTPROTO"

# 网络抓包
tcpdump -i lo0 -n port 10443
```

## 生产部署注意事项

⚠️ 本指南仅用于本地开发测试，生产环境需要额外配置：

1. **安全性**
   - 修改所有默认密码
   - 配置 SSL/TLS 证书
   - 启用防火墙规则
   - 配置 API 访问限制

2. **性能优化**
   - 调整数据库连接池
   - 配置 Redis 持久化
   - 优化 Kafka 分区
   - 使用 CDN 加速

3. **高可用**
   - MySQL 主从复制
   - Redis 集群
   - Kafka 集群
   - 负载均衡

4. **监控告警**
   - 配置 Prometheus + Grafana
   - 日志聚合 (ELK)
   - 错误追踪 (Sentry)

## 参考资源

- Echo Server: https://github.com/echo/echo-server
- Telegram Android: https://github.com/DrKLO/Telegram
- MTProto 协议: https://core.telegram.org/mtproto
- Telegram API: https://core.telegram.org/api

## 获取帮助

如遇到问题:
1. 查看日志文件
2. 检查 GitHub Issues
3. 参考官方文档
4. 加入 Telegram 群组: https://t.me/+TjD5LZJ5XLRlCYLF
