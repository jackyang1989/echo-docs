# Echo 安全配置指南

**日期**: 2026-01-27  
**重要**: 部署时使用通用名称，避免暴露 Echo 品牌信息

---

## 🔒 安全原则

### 为什么要使用通用名称？

1. **安全性**: 避免被识别为特定项目，降低被针对性攻击的风险
2. **隐私性**: 底层基础设施不应暴露品牌信息
3. **灵活性**: 未来可以更换品牌名称而不影响底层服务
4. **专业性**: 使用标准技术术语，避免品牌混淆

### 命名策略

```
对外暴露层（客户端）: Echo（用户看到的）
    ↓
中间业务层（NestJS）: 使用通用技术名称
    ↓
底层基础设施（服务器）: 使用完全通用的名称 ⭐
```

**禁止使用的名称**:
- ❌ echo, echo-*, echo_*
- ❌ telegram, telegram-*

**推荐使用的名称（与 Echo 相关）**:
- ✅ echo-*, echo_*（Echo 相关服务）
- ✅ kc-*, kc_*（Echo 缩写）
- ✅ chat-*, im-*（通用聊天/即时通讯）
- ✅ api-*, ws-*（API/WebSocket）

---

## 📝 服务器配置清单

### 1. 数据库配置

**❌ 不要使用**:
```yaml
database: echo
username: echo
password: echo
```

**✅ 推荐使用**:
```yaml
database: echodb
username: echo_admin
password: 7xK9#mP2$vL5@qR8  # 随机生成的强密码
```

**生成强密码**:
```bash
# Mac 生成随机密码
openssl rand -base64 24
# 输出示例: 3nF8kL2pQ9xM7vR5tY1wZ4bN6cH0jS8a
```

### 2. Redis 配置

**❌ 不要使用**:
```yaml
password: echo_redis
password: redis123
```

**✅ 推荐使用**:
```yaml
password: 9mN4#pL7$xK2@vR5
```

### 3. MinIO 配置

**❌ 不要使用**:
```yaml
access_key: minio
access_key: echo
secret_key: minio123
bucket: echo-files
```

**✅ 推荐使用**:
```yaml
access_key: echo_storage
secret_key: 5tY8#nM3$pL9@xK7
buckets:
  - echo-documents
  - echo-photos
  - echo-videos
  - echo-encrypted
```

### 4. Kafka 配置

**❌ 不要使用**:
```yaml
topic: echo.messages
group: echo-consumers
```

**✅ 推荐使用**:
```yaml
topic: echo.events
group: echo-processors
```

### 5. 服务名称

**❌ 不要使用**:
```yaml
services:
  - echo-gateway
  - echo-session
  - echo-bff
```

**✅ 推荐使用**:
```yaml
services:
  - echo-gateway
  - echo-session
  - echo-bff
  - echo-api
```

### 6. 容器名称

**❌ 不要使用**:
```yaml
containers:
  - mysql
  - redis
  - minio
  - kafka
  - etcd
```

**✅ 推荐使用**:
```yaml
containers:
  - echo-db
  - echo-cache
  - echo-storage
  - echo-queue
  - echo-registry
```

### 7. 域名配置

**❌ 不要使用**:
```
echo-api.example.com
echo-ws.example.com
```

**✅ 推荐使用**:
```
api.echo.im
ws.echo.im
或
echo-api.example.com
echo-ws.example.com
```

---

## 🔧 配置文件修改

### Echo Server 配置

#### 1. docker-compose-env.yaml

**原始配置**:
```yaml
services:
  mysql:
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: echo
      MYSQL_USER: echo
      MYSQL_PASSWORD: echo
```

**修改为**:
```yaml
services:
  mysql:
    container_name: msgdb
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}  # 从 .env 读取
      MYSQL_DATABASE: msgdb
      MYSQL_USER: msgadmin
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - msgdb_data:/var/lib/mysql

  redis:
    container_name: msgcache
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - msgcache_data:/data

  minio:
    container_name: msgstorage
    environment:
      MINIO_ROOT_USER: ${MINIO_ACCESS_KEY}
      MINIO_ROOT_PASSWORD: ${MINIO_SECRET_KEY}
    volumes:
      - msgstorage_data:/data

  kafka:
    container_name: msgqueue
    environment:
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://msgqueue:9092
    volumes:
      - msgqueue_data:/var/lib/kafka/data

  etcd:
    container_name: msgregistry
    volumes:
      - msgregistry_data:/etcd-data

volumes:
  msgdb_data:
  msgcache_data:
  msgstorage_data:
  msgqueue_data:
  msgregistry_data:
```

#### 2. 创建 .env 文件

**位置**: `echo-server-source/.env`

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=R8xK2#mP9$vL5@qT7
MYSQL_PASSWORD=7xK9#mP2$vL5@qR8

# Redis 配置
REDIS_PASSWORD=9mN4#pL7$xK2@vR5

# MinIO 配置
MINIO_ACCESS_KEY=storage_admin
MINIO_SECRET_KEY=5tY8#nM3$pL9@xK7

# Kafka 配置
KAFKA_PASSWORD=3nF8#kL2$pQ9@xM7
```

**生成 .env 文件脚本**:
```bash
#!/bin/bash
# generate-env.sh

cat > .env << EOF
# 自动生成的安全配置
# 生成时间: $(date)

# 数据库配置
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)
MYSQL_PASSWORD=$(openssl rand -base64 24)

# Redis 配置
REDIS_PASSWORD=$(openssl rand -base64 24)

# MinIO 配置
MINIO_ACCESS_KEY=storage_admin
MINIO_SECRET_KEY=$(openssl rand -base64 24)

# Kafka 配置
KAFKA_PASSWORD=$(openssl rand -base64 24)
EOF

echo "✅ .env 文件已生成"
echo "⚠️  请妥善保管此文件，不要提交到 Git"
```

#### 3. Echo 服务配置

**修改**: `echod/etc/session.yaml`

```yaml
Name: msg.session  # 不要用 echo.session

Mysql:
  Datasource: msgadmin:${MYSQL_PASSWORD}@tcp(msgdb:3306)/msgdb?charset=utf8mb4

Redis:
  - Host: msgcache:6379
    Pass: ${REDIS_PASSWORD}
    Type: node

Etcd:
  Hosts:
    - msgregistry:2379
  Key: msg.session
```

**修改**: `echod/etc/bff.yaml`

```yaml
Name: msg.bff

Mysql:
  Datasource: msgadmin:${MYSQL_PASSWORD}@tcp(msgdb:3306)/msgdb?charset=utf8mb4

Redis:
  - Host: msgcache:6379
    Pass: ${REDIS_PASSWORD}
    Type: node

Kafka:
  Brokers:
    - msgqueue:9092
  Topic: msg.events
```

---

## 🚀 部署脚本更新

### 更新 echo-deploy-local-mac.sh

```bash
#!/bin/bash

set -e

echo "=========================================="
echo "  消息服务器 - Mac 本地部署"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 .env 文件
ECHO_DIR="/Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./echo-server-source"
cd "$ECHO_DIR"

if [ ! -f ".env" ]; then
    echo -e "${YELLOW}未找到 .env 文件，正在生成...${NC}"
    
    cat > .env << EOF
# 自动生成的安全配置
# 生成时间: $(date)

# 数据库配置
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)
MYSQL_PASSWORD=$(openssl rand -base64 24)

# Redis 配置
REDIS_PASSWORD=$(openssl rand -base64 24)

# MinIO 配置
MINIO_ACCESS_KEY=storage_admin
MINIO_SECRET_KEY=$(openssl rand -base64 24)

# Kafka 配置
KAFKA_PASSWORD=$(openssl rand -base64 24)
EOF
    
    echo -e "${GREEN}✓ .env 文件已生成${NC}"
    echo -e "${YELLOW}⚠️  请妥善保管 .env 文件${NC}"
    echo ""
fi

# 加载环境变量
source .env

echo -e "${YELLOW}[1/10] 检查 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker 已就绪${NC}"
echo ""

echo -e "${YELLOW}[2/10] 启动依赖服务...${NC}"
docker-compose -f docker-compose-env.yaml down 2>/dev/null || true
docker-compose -f docker-compose-env.yaml up -d
echo -e "${GREEN}✓ 依赖服务已启动${NC}"
echo ""

echo -e "${YELLOW}[3/10] 等待服务启动 (30秒)...${NC}"
sleep 30
echo -e "${GREEN}✓ 服务启动完成${NC}"
echo ""

echo -e "${YELLOW}[4/10] 初始化数据库...${NC}"
docker exec -i msgdb mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS msgdb CHARACTER SET utf8mb4;" 2>/dev/null || true
echo -e "${GREEN}✓ 数据库已创建${NC}"
echo ""

echo -e "${YELLOW}[5/10] 执行 SQL 迁移...${NC}"
cd echod/sql
for f in *.sql; do
    if [ -f "$f" ]; then
        echo "  执行: $f"
        docker exec -i msgdb mysql -uroot -p${MYSQL_ROOT_PASSWORD} msgdb < "$f" 2>/dev/null || true
    fi
done
cd ../..
echo -e "${GREEN}✓ SQL 迁移完成${NC}"
echo ""

echo -e "${YELLOW}[6/10] 配置 MinIO...${NC}"
docker exec msgstorage mc alias set local http://localhost:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} 2>/dev/null || true

for bucket in media-docs media-photos media-videos media-encrypted; do
    docker exec msgstorage mc mb local/$bucket 2>/dev/null || true
    echo "  创建: $bucket"
done
echo -e "${GREEN}✓ MinIO 配置完成${NC}"
echo ""

echo -e "${YELLOW}[7/10] 编译服务器...${NC}"
if make > /tmp/msg-server-build.log 2>&1; then
    echo -e "${GREEN}✓ 编译成功${NC}"
else
    echo -e "${RED}错误: 编译失败${NC}"
    echo "查看日志: /tmp/msg-server-build.log"
    exit 1
fi
echo ""

echo -e "${GREEN}=========================================="
echo "  部署完成！"
echo "==========================================${NC}"
echo ""
echo "配置信息已保存在 .env 文件中"
echo "⚠️  请妥善保管，不要泄露"
echo ""
echo "启动服务器:"
echo "  cd $ECHO_DIR/echod/bin"
echo "  ./runall2.sh"
echo ""
```

---

## 📋 安全检查清单

部署前请确认：

- [ ] 所有密码都是随机生成的强密码（至少 24 字符）
- [ ] .env 文件已添加到 .gitignore
- [ ] 数据库名称不包含 "echo" 或 "echo"
- [ ] 容器名称使用通用名称（msg-*）
- [ ] MinIO bucket 名称不包含品牌信息
- [ ] Kafka topic 名称使用通用名称
- [ ] 服务名称不暴露业务信息
- [ ] 域名配置使用通用子域名

---

## 🔐 密码管理

### 推荐工具

1. **1Password** / **Bitwarden** - 密码管理器
2. **Vault** (HashiCorp) - 企业级密钥管理
3. **AWS Secrets Manager** - 云端密钥管理

### 密码存储

**本地开发**:
```bash
# .env 文件（不要提交到 Git）
echo-server-source/.env
```

**生产环境**:
```bash
# 使用环境变量或密钥管理服务
export MYSQL_PASSWORD=$(vault kv get -field=password secret/msgdb)
```

---

## 🚨 安全提醒

1. **永远不要**在代码中硬编码密码
2. **永远不要**将 .env 文件提交到 Git
3. **定期更换**生产环境密码（每 90 天）
4. **使用不同的密码**用于不同的服务
5. **启用双因素认证**（如果服务支持）
6. **限制网络访问**（防火墙规则）
7. **定期备份**配置文件和密码

---

## 📝 .gitignore 配置

确保以下文件不被提交：

```gitignore
# 环境变量
.env
.env.local
.env.production

# 密码文件
**/passwords.txt
**/secrets.txt

# 配置备份
*.backup
*.bak

# 日志文件
*.log
```

---

## ✅ 总结

**关键原则**:
1. Echo 层使用通用名称（msg-*）
2. 所有密码随机生成，至少 24 字符
3. 配置文件不包含品牌信息
4. .env 文件不提交到 Git
5. 定期更换密码

**命名示例**:
- ❌ echo-db, echo-redis, echo-api
- ✅ msgdb, msgcache, msg-api

**下一步**: 执行更新后的部署脚本
