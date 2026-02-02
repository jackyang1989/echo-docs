# Echo IM - 部署配置指南

**日期**: 2026-01-27  
**用途**: 将 Echo Server 配置为 Echo 品牌

---

## 📋 配置原则

### 命名策略

所有底层服务都使用 **echo** 相关的名称，统一品牌标识。

**使用规则**:
- ✅ echo-*（服务名称）
- ✅ echo_*（数据库用户名）
- ✅ echodb（数据库名）
- ✅ echo.events（Kafka topic）

**禁止使用**:
- ❌ echo, echo-*, echo_*
- ❌ telegram, telegram-*
- ❌ msg-*, chat-*（太通用）

---

## 🔧 配置文件修改

### 1. docker-compose-env.yaml

**位置**: `./echo-server-source/docker-compose-env.yaml`

**完整配置**:
```yaml
version: '3.8'

services:
  mysql:
    image: mysql:5.7
    container_name: echo-db
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: echodb
      MYSQL_USER: echo_admin
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    ports:
      - "3306:3306"
    volumes:
      - echo_db_data:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - echo-network

  redis:
    image: redis:latest
    container_name: echo-cache
    command: redis-server --requirepass ${REDIS_PASSWORD}
    ports:
      - "6379:6379"
    volumes:
      - echo_cache_data:/data
    networks:
      - echo-network

  etcd:
    image: quay.io/coreos/etcd:latest
    container_name: echo-registry
    environment:
      ETCD_NAME: echo-etcd
      ETCD_DATA_DIR: /etcd-data
      ETCD_LISTEN_CLIENT_URLS: http://0.0.0.0:2379
      ETCD_ADVERTISE_CLIENT_URLS: http://echo-registry:2379
      ETCD_LISTEN_PEER_URLS: http://0.0.0.0:2380
      ETCD_INITIAL_ADVERTISE_PEER_URLS: http://echo-registry:2380
      ETCD_INITIAL_CLUSTER: echo-etcd=http://echo-registry:2380
      ETCD_INITIAL_CLUSTER_STATE: new
      ETCD_INITIAL_CLUSTER_TOKEN: echo-cluster
    ports:
      - "2379:2379"
      - "2380:2380"
    volumes:
      - echo_registry_data:/etcd-data
    networks:
      - echo-network

  kafka:
    image: confluentinc/cp-kafka:latest
    container_name: echo-queue
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://echo-queue:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
    ports:
      - "9092:9092"
    volumes:
      - echo_queue_data:/var/lib/kafka/data
    networks:
      - echo-network

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    container_name: echo-zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    volumes:
      - echo_zk_data:/var/lib/zookeeper/data
    networks:
      - echo-network

  minio:
    image: minio/minio:latest
    container_name: echo-storage
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: ${MINIO_ACCESS_KEY}
      MINIO_ROOT_PASSWORD: ${MINIO_SECRET_KEY}
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - echo_storage_data:/data
    networks:
      - echo-network

volumes:
  echo_db_data:
  echo_cache_data:
  echo_registry_data:
  echo_queue_data:
  echo_zk_data:
  echo_storage_data:

networks:
  echo-network:
    driver: bridge
```

---

### 2. 环境变量配置 (.env)

**位置**: `./echo-server-source/.env`

**内容**:
```bash
# Echo IM 配置
# 生成时间: 2026-01-27
# ⚠️  请妥善保管此文件，不要提交到 Git

# 数据库配置
MYSQL_ROOT_PASSWORD=Kc9mN4#pL7$xK2@vR5tY8
MYSQL_PASSWORD=Kc7xK9#mP2$vL5@qR8nM3

# Redis 配置
REDIS_PASSWORD=Kc5tY8#nM3$pL9@xK7mN4

# MinIO 配置
MINIO_ACCESS_KEY=echo_storage
MINIO_SECRET_KEY=Kc3nF8#kL2$pQ9@xM7vR5

# Kafka 配置
KAFKA_PASSWORD=Kc2pL9#xK7$mN4@vR5tY8
```

**自动生成脚本**:
```bash
#!/bin/bash
# generate-echo-env.sh

cat > .env << 'EOF'
# Echo IM 配置
# 生成时间: $(date)
# ⚠️  请妥善保管此文件，不要提交到 Git

# 数据库配置
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
MYSQL_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')

# Redis 配置
REDIS_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')

# MinIO 配置
MINIO_ACCESS_KEY=echo_storage
MINIO_SECRET_KEY=$(openssl rand -base64 24 | tr -d '\n')

# Kafka 配置
KAFKA_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
EOF

# 替换 $(date) 和 $(openssl ...) 为实际值
sed -i '' "s/\$(date)/$(date)/" .env
sed -i '' "s/\$(openssl rand -base64 24 | tr -d '\\\\n')/$(openssl rand -base64 24 | tr -d '\n')/g" .env

echo "✅ .env 文件已生成"
echo "⚠️  请妥善保管，不要提交到 Git"
```

---

### 3. Echo 服务配置

#### session.yaml

**位置**: `echod/etc/session.yaml`

```yaml
Name: echo.session

Mysql:
  Datasource: echo_admin:${MYSQL_PASSWORD}@tcp(echo-db:3306)/echodb?charset=utf8mb4&parseTime=true&loc=Local

Redis:
  - Host: echo-cache:6379
    Pass: ${REDIS_PASSWORD}
    Type: node

Etcd:
  Hosts:
    - echo-registry:2379
  Key: echo.session

Log:
  ServiceName: echo.session
  Mode: file
  Path: logs
  Level: info
```

#### bff.yaml

**位置**: `echod/etc/bff.yaml`

```yaml
Name: echo.bff

Mysql:
  Datasource: echo_admin:${MYSQL_PASSWORD}@tcp(echo-db:3306)/echodb?charset=utf8mb4&parseTime=true&loc=Local

Redis:
  - Host: echo-cache:6379
    Pass: ${REDIS_PASSWORD}
    Type: node

Kafka:
  Brokers:
    - echo-queue:9092
  Topic: echo.events
  Group: echo.bff

Etcd:
  Hosts:
    - echo-registry:2379
  Key: echo.bff

Log:
  ServiceName: echo.bff
  Mode: file
  Path: logs
  Level: info
```

#### gateway.yaml

**位置**: `echod/etc/gateway.yaml`

```yaml
Name: echo.gateway

ListenOn: 0.0.0.0:10443

Etcd:
  Hosts:
    - echo-registry:2379
  Key: echo.gateway

Log:
  ServiceName: echo.gateway
  Mode: file
  Path: logs
  Level: info
```

---

### 4. 数据库初始化

**修改 SQL 文件中的数据库名**:

```bash
# 在所有 SQL 文件中替换数据库名
cd echod/sql
for f in *.sql; do
    sed -i '' 's/USE echo;/USE echodb;/g' "$f"
    sed -i '' 's/CREATE DATABASE IF NOT EXISTS echo/CREATE DATABASE IF NOT EXISTS echodb/g' "$f"
done
```

---

### 5. MinIO Buckets 配置

**Bucket 名称**:
```bash
echo-documents
echo-photos
echo-videos
echo-encrypted
```

**创建脚本**:
```bash
#!/bin/bash
# create-echo-buckets.sh

# 配置 MinIO 客户端
docker exec echo-storage mc alias set echo http://localhost:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}

# 创建 buckets
for bucket in documents photos videos encrypted; do
    docker exec echo-storage mc mb echo/echo-$bucket
    echo "✅ 创建 bucket: echo-$bucket"
done

# 设置公开访问策略（可选）
# docker exec echo-storage mc policy set download echo/echo-photos
```

---

## 🚀 完整部署脚本

**文件**: `echo-deploy-local-mac.sh`

```bash
#!/bin/bash

set -e

echo "=========================================="
echo "  Echo IM - Mac 本地部署"
echo "=========================================="
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0;m'

ECHO_DIR="/Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./echo-server-source"

echo -e "${YELLOW}[1/10] 检查 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker 已就绪${NC}"
echo ""

echo -e "${YELLOW}[2/10] 进入服务器目录...${NC}"
cd "$ECHO_DIR"
echo -e "${GREEN}✓ 目录: $ECHO_DIR${NC}"
echo ""

echo -e "${YELLOW}[3/10] 生成配置文件...${NC}"
if [ ! -f ".env" ]; then
    cat > .env << EOF
# Echo IM 配置
# 生成时间: $(date)
# ⚠️  请妥善保管此文件，不要提交到 Git

# 数据库配置
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
MYSQL_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')

# Redis 配置
REDIS_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')

# MinIO 配置
MINIO_ACCESS_KEY=echo_storage
MINIO_SECRET_KEY=$(openssl rand -base64 24 | tr -d '\n')

# Kafka 配置
KAFKA_PASSWORD=$(openssl rand -base64 24 | tr -d '\n')
EOF
    echo -e "${GREEN}✓ 配置文件已生成${NC}"
else
    echo -e "${GREEN}✓ 使用现有配置${NC}"
fi
source .env
echo ""

echo -e "${YELLOW}[4/10] 启动依赖服务...${NC}"
docker-compose -f docker-compose-env.yaml down 2>/dev/null || true
docker-compose -f docker-compose-env.yaml up -d
echo -e "${GREEN}✓ 依赖服务已启动${NC}"
echo ""

echo -e "${YELLOW}[5/10] 等待服务启动 (30秒)...${NC}"
sleep 30
echo -e "${GREEN}✓ 服务启动完成${NC}"
echo ""

echo -e "${YELLOW}[6/10] 初始化数据库...${NC}"
docker exec -i echo-db mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS echodb CHARACTER SET utf8mb4;" 2>/dev/null || true
echo -e "${GREEN}✓ 数据库已创建${NC}"
echo ""

echo -e "${YELLOW}[7/10] 执行 SQL 迁移...${NC}"
cd echod/sql
for f in *.sql; do
    if [ -f "$f" ]; then
        echo "  执行: $f"
        # 替换数据库名
        sed 's/echo/echodb/g' "$f" | docker exec -i echo-db mysql -uroot -p${MYSQL_ROOT_PASSWORD} echodb 2>/dev/null || true
    fi
done
cd ../..
echo -e "${GREEN}✓ SQL 迁移完成${NC}"
echo ""

echo -e "${YELLOW}[8/10] 配置 MinIO...${NC}"
docker exec echo-storage mc alias set echo http://localhost:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} 2>/dev/null || true
for bucket in documents photos videos encrypted; do
    docker exec echo-storage mc mb echo/echo-$bucket 2>/dev/null || true
    echo "  创建: echo-$bucket"
done
echo -e "${GREEN}✓ MinIO 配置完成${NC}"
echo ""

echo -e "${YELLOW}[9/10] 编译服务器...${NC}"
if make > /tmp/echo-build.log 2>&1; then
    echo -e "${GREEN}✓ 编译成功${NC}"
else
    echo -e "${RED}错误: 编译失败${NC}"
    echo "查看日志: /tmp/echo-build.log"
    exit 1
fi
echo ""

echo -e "${GREEN}=========================================="
echo "  部署完成！"
echo "==========================================${NC}"
echo ""
echo "配置信息:"
echo "  数据库: echodb"
echo "  用户: echo_admin"
echo "  配置文件: $ECHO_DIR/.env"
echo ""
echo "容器列表:"
echo "  - echo-db (MySQL)"
echo "  - echo-cache (Redis)"
echo "  - echo-storage (MinIO)"
echo "  - echo-queue (Kafka)"
echo "  - echo-registry (etcd)"
echo ""
echo "下一步:"
echo "  cd $ECHO_DIR/echod/bin"
echo "  ./runall2.sh"
echo ""
```

---

## ✅ 配置检查清单

部署前确认：

- [ ] docker-compose-env.yaml 中所有容器名为 echo-*
- [ ] 数据库名为 echodb
- [ ] 数据库用户为 echo_admin
- [ ] MinIO buckets 为 echo-*
- [ ] Kafka topic 为 echo.events
- [ ] 服务名称为 echo.session, echo.bff 等
- [ ] .env 文件已生成且不在 Git 中
- [ ] 所有密码都是随机生成的强密码

---

## 📝 .gitignore 配置

确保以下文件不被提交：

```gitignore
# 环境变量
.env
.env.local
.env.production

# 日志
*.log
logs/

# 构建产物
echod/bin/

# 临时文件
*.tmp
*.bak
```

---

**最后更新**: 2026-01-27  
**状态**: 准备部署
