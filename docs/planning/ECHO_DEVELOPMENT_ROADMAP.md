# Echo IM - 开发路线图

**项目名称**: Echo（原 Echo）  
**日期**: 2026-01-27  
**目标**: 构建无需 VPN 的 WeChat 替代品

---

## 📋 项目概述

### 核心价值主张
- ✅ 国际化 IM 平台（支持全球用户）
- ✅ 完整的 IM 功能（消息、群组、文件）
- ✅ 自主可控的服务器
- ✅ 企业级功能扩展

### 技术架构

```
Echo Android Client (Layer 221)
    ↓ MTProto 2.0
Echo Server (Go, Layer 220)
    ↓ HTTP/gRPC
Echo Business Server (NestJS)
    ├─ 短信验证（阿里云国内 + Twilio 国际）
    ├─ 邮件验证（SendGrid / AWS SES）
    ├─ FCM/APNs 推送通知
    ├─ 管理后台
    └─ 数据分析
```

---

## 🎯 Phase 1: 基础部署（1-2周）

**目标**: 在 Mac 本地成功运行 Echo Server 和客户端

### 1.1 服务器部署 ✅

**任务**:
- [x] 分析 Echo Server 源码
- [ ] 启动依赖服务（MySQL, Redis, etcd, Kafka, MinIO）
- [ ] 初始化数据库
- [ ] 编译 Echo Server
- [ ] 启动服务

**脚本**: `echo-deploy-local-mac.sh`

**验收标准**:
- ✅ 所有依赖服务正常运行
- ✅ Echo Server 启动无错误
- ✅ 可以通过 API 访问服务器

### 1.2 客户端编译

**任务**:
- [ ] 打开 Echo Android 项目
- [ ] 配置 Android Studio
- [ ] 等待 Gradle 同步
- [ ] 编译 APK

**路径**: `./teamgram-android`

**验收标准**:
- ✅ APK 编译成功
- ✅ 无编译错误

### 1.3 连接测试

**任务**:
- [ ] 安装 APK 到 Android 设备
- [ ] 输入手机号注册
- [ ] 使用验证码 12345 登录
- [ ] 测试基础功能

**测试清单**:
- [ ] 注册/登录
- [ ] 发送文本消息
- [ ] 发送图片
- [ ] 创建群组
- [ ] 上传文件

### 1.4 API Layer 兼容性测试

**问题**: 客户端 Layer 221 vs 服务端 Layer 220

**测试方案**:
1. 直接测试 Layer 221 客户端连接 Layer 220 服务端
2. 如果失败，升级服务端到 Layer 221

**决策点**:
- ✅ 兼容 → 继续使用
- ❌ 不兼容 → 执行 Phase 1.5

### 1.5 升级服务端到 Layer 221（可选）

**任务**:
- [ ] 研究 proto-main 库
- [ ] 查找 Echo Server 的 Layer 定义
- [ ] 修改 Go 代码
- [ ] 重新编译测试

**时间**: 1-2 天

---

## 🎯 Phase 2: 认证系统（2-3周）

**目标**: 替换固定验证码 12345，实现真实的短信/邮件验证

### 2.1 需求分析

**当前问题**:
- Echo 默认验证码固定为 12345
- 不适合生产环境
- 无法防止恶意注册

**解决方案**: NestJS 中间层拦截

**注册方式优先级**:
1. 📧 **邮箱注册**（主要方式，必须实现）
   - 国际通用，无地域限制
   - 成本低，易于维护
   - 服务商: SendGrid（推荐）或 AWS SES
     - SendGrid: 免费 100 封/天，易于集成
     - AWS SES: 按量付费 $0.10/1000 封，稳定可靠

2. 📱 **手机号注册**（可选，后期实现）
   - 国内（+86）: 阿里云短信
   - 国际: Twilio（支持 200+ 国家）
   - 成本较高，按需开启

### 2.2 架构设计

```typescript
// 认证流程（邮箱为主）
Client → NestJS Proxy → Echo
         ↓
    1. 用户输入邮箱（或可选手机号）
    2. 生成真实验证码（6位数字）
    3. 发送邮件（SendGrid/AWS SES）或短信（可选）
    4. 存储到 Redis（5分钟过期）
         ↓
    5. 转发请求到 Echo（验证码改为 12345）
         ↓
    6. Echo 验证通过
         ↓
    7. NestJS 二次验证真实验证码
         ↓
    8. 返回成功，创建账号
```

**注册方式**:
- ✅ **邮箱注册**（必须实现，主要方式）
- ⚠️ **手机号注册**（可选，后期添加）

### 2.3 开发任务

#### 2.3.1 NestJS 项目搭建

```bash
mkdir echo-business-server
cd echo-business-server
npm init -y
npm install @nestjs/core @nestjs/common @nestjs/platform-express
npm install @nestjs/config @nestjs/typeorm typeorm pg
npm install redis ioredis
npm install @sendgrid/mail  # 邮件服务（主要）
npm install twilio          # 短信服务（可选）
```

**文件结构**:
```
echo-business-server/
├── src/
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── email-verification.service.ts    # 必须实现
│   │   ├── sms-verification.service.ts      # 可选实现
│   │   └── echo-proxy.service.ts
│   ├── config/
│   │   ├── sendgrid.config.ts
│   │   ├── twilio.config.ts                 # 可选
│   │   └── redis.config.ts
│   └── main.ts
├── .env
└── package.json
```

#### 2.3.2 邮件验证服务（必须实现）⭐

**任务**:
- [ ] 注册 SendGrid 账号（或 AWS SES）
- [ ] 获取 API Key
- [ ] 配置发件人邮箱
- [ ] 实现邮件发送逻辑

**代码**: `src/auth/email-verification.service.ts`

```typescript
import * as sgMail from '@sendgrid/mail';

@Injectable()
export class EmailVerificationService {
  constructor(private configService: ConfigService) {
    sgMail.setApiKey(configService.get('SENDGRID_API_KEY'));
  }

  async sendVerificationCode(email: string): Promise<string> {
    const code = this.generateCode();
    
    const msg = {
      to: email,
      from: 'noreply@echo.im', // 需要在 SendGrid 验证
      subject: 'Echo Verification Code',
      text: `Your verification code is: ${code}. Valid for 5 minutes.`,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>Echo Verification Code</h2>
          <p>Your verification code is:</p>
          <h1 style="color: #4CAF50; font-size: 32px; letter-spacing: 5px;">${code}</h1>
          <p>This code will expire in 5 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
        </div>
      `,
    };

    await sgMail.send(msg);

    // 存储到 Redis（5分钟过期）
    await this.redis.setex(`email:${email}`, 300, code);
    
    return code;
  }

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async verifyCode(email: string, code: string): Promise<boolean> {
    const storedCode = await this.redis.get(`email:${email}`);
    if (!storedCode) {
      throw new BadRequestException('Verification code expired');
    }
    return storedCode === code;
  }

  async resendCode(email: string): Promise<void> {
    // 检查是否在冷却期（60秒）
    const cooldown = await this.redis.get(`email:cooldown:${email}`);
    if (cooldown) {
      throw new BadRequestException('Please wait before requesting a new code');
    }

    await this.sendVerificationCode(email);
    
    // 设置冷却期
    await this.redis.setex(`email:cooldown:${email}`, 60, '1');
  }
}
```

**环境变量** (`.env`):
```env
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@echo.im
```

#### 2.3.3 短信验证服务（可选，后期实现）

**任务**:
- [ ] 注册 Twilio 账号（国际）或阿里云（国内）
- [ ] 获取 API 凭证
- [ ] 申请短信模板
- [ ] 实现 SMS 发送逻辑

**代码**: `src/auth/sms-verification.service.ts`

```typescript
import twilio from 'twilio';

@Injectable()
export class SmsVerificationService {
  private client: twilio.Twilio;

  constructor(private configService: ConfigService) {
    this.client = twilio(
      configService.get('TWILIO_ACCOUNT_SID'),
      configService.get('TWILIO_AUTH_TOKEN'),
    );
  }

  async sendVerificationCode(phone: string): Promise<string> {
    const code = this.generateCode();
    
    await this.client.messages.create({
      body: `Your Echo verification code is: ${code}. Valid for 5 minutes.`,
      from: this.configService.get('TWILIO_PHONE_NUMBER'),
      to: phone,
    });

    // 存储到 Redis（5分钟过期）
    await this.redis.setex(`sms:${phone}`, 300, code);
    
    return code;
  }

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  async verifyCode(phone: string, code: string): Promise<boolean> {
    const storedCode = await this.redis.get(`sms:${phone}`);
    if (!storedCode) {
      throw new BadRequestException('Verification code expired');
    }
    return storedCode === code;
  }
}
```

**环境变量** (`.env`):
```env
# Twilio（国际短信）
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxx
TWILIO_PHONE_NUMBER=+1234567890

# 或阿里云（国内短信）
ALIYUN_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxx
ALIYUN_ACCESS_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxx
```

#### 2.3.4 Echo 代理服务

**任务**:
- [ ] 拦截客户端注册请求
- [ ] 发送真实验证码（邮件为主）
- [ ] 转发请求到 Echo（验证码改为 12345）
- [ ] 二次验证真实验证码

**代码**: `src/auth/echo-proxy.service.ts`

```typescript
@Injectable()
export class EchoProxyService {
  constructor(
    private emailService: EmailVerificationService,
    private smsService: SmsVerificationService, // 可选
    private httpService: HttpService,
    private redis: Redis,
  ) {}

  async sendCode(identifier: string, type: 'email' | 'phone' = 'email'): Promise<void> {
    // 优先使用邮箱注册
    if (type === 'email' || this.isEmail(identifier)) {
      await this.emailService.sendVerificationCode(identifier);
    } else if (type === 'phone' && this.isPhone(identifier)) {
      // 短信为可选功能
      if (!this.smsService) {
        throw new BadRequestException('SMS verification is not available');
      }
      await this.smsService.sendVerificationCode(identifier);
    } else {
      throw new BadRequestException('Invalid identifier format');
    }

    // 转发到 Echo（验证码固定为 12345）
    await this.httpService.post('http://echo-server:11443/auth.sendCode', {
      phone_number: identifier, // Echo 使用 phone_number 字段，但可以是邮箱
    });
  }

  async signIn(identifier: string, code: string, type: 'email' | 'phone' = 'email'): Promise<any> {
    // 验证真实验证码
    let isValid = false;
    
    if (type === 'email' || this.isEmail(identifier)) {
      isValid = await this.emailService.verifyCode(identifier, code);
    } else if (type === 'phone' && this.isPhone(identifier)) {
      if (!this.smsService) {
        throw new BadRequestException('SMS verification is not available');
      }
      isValid = await this.smsService.verifyCode(identifier, code);
    }

    if (!isValid) {
      throw new UnauthorizedException('Invalid verification code');
    }

    // 转发到 Echo（验证码改为 12345）
    const response = await this.httpService.post('http://echo-server:11443/auth.signIn', {
      phone_number: identifier,
      phone_code: '12345',
    });

    // 清除 Redis 中的验证码
    await this.redis.del(`email:${identifier}`);
    await this.redis.del(`sms:${identifier}`);

    return response.data;
  }

  private isEmail(str: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(str);
  }

  private isPhone(str: string): boolean {
    return /^\+?\d{10,15}$/.test(str);
  }
}
```

**Controller**: `src/auth/auth.controller.ts`

```typescript
@Controller('auth')
export class AuthController {
  constructor(private proxyService: EchoProxyService) {}

  @Post('send-code')
  async sendCode(@Body() dto: SendCodeDto) {
    // 默认使用邮箱注册
    const type = dto.type || 'email';
    await this.proxyService.sendCode(dto.identifier, type);
    return { success: true, message: 'Verification code sent' };
  }

  @Post('verify')
  async verify(@Body() dto: VerifyCodeDto) {
    const type = dto.type || 'email';
    const result = await this.proxyService.signIn(dto.identifier, dto.code, type);
    return { success: true, data: result };
  }

  @Post('resend-code')
  async resendCode(@Body() dto: SendCodeDto) {
    const type = dto.type || 'email';
    await this.proxyService.sendCode(dto.identifier, type);
    return { success: true, message: 'Verification code resent' };
  }
}

// DTOs
class SendCodeDto {
  @IsString()
  identifier: string; // 邮箱或手机号

  @IsOptional()
  @IsIn(['email', 'phone'])
  type?: 'email' | 'phone'; // 默认 email
}

class VerifyCodeDto {
  @IsString()
  identifier: string;

  @IsString()
  @Length(6, 6)
  code: string;

  @IsOptional()
  @IsIn(['email', 'phone'])
  type?: 'email' | 'phone';
}
```

### 2.4 客户端修改

**任务**:
- [ ] 修改客户端 API 端点
- [ ] 指向 NestJS 代理服务器
- [ ] 测试注册流程

**修改位置**:
```java
// BuildVars.java 或 ConnectionsManager.java
String AUTH_API_URL = "http://your-nestjs-server:3000/auth";
```

### 2.5 测试

**测试清单**:
- [ ] 手机号注册（接收真实短信）
- [ ] 邮箱注册（接收真实邮件）
- [ ] 验证码过期（5分钟）
- [ ] 验证码错误
- [ ] 重复发送验证码

---

## 🎯 Phase 3: 推送通知（2-3周）

**目标**: 实现离线消息推送（FCM/APNs）

### 3.1 架构设计

```
Echo Server (新消息)
    ↓ MySQL Trigger / Kafka
NestJS Message Listener
    ↓
Push Notification Service
    ├─ FCM (Android)
    ├─ APNs (iOS)
    └─ Web Push
```

### 3.2 开发任务

#### 3.2.1 消息监听器

**方案 A**: MySQL 触发器 + Kafka

```sql
-- MySQL 触发器
CREATE TRIGGER after_message_insert
AFTER INSERT ON messages
FOR EACH ROW
BEGIN
  -- 发送到 Kafka topic: echo.messages
  -- 需要 MySQL UDF 或外部工具
END;
```

**方案 B**: 轮询 Echo 数据库（简单但不优雅）

```typescript
@Injectable()
export class MessageListenerService {
  @Cron('*/5 * * * * *') // 每5秒
  async pollNewMessages() {
    const messages = await this.echoDb.query(`
      SELECT * FROM messages 
      WHERE created_at > NOW() - INTERVAL 5 SECOND
      AND push_sent = 0
    `);

    for (const msg of messages) {
      await this.pushService.sendPush(msg);
      await this.echoDb.query(`
        UPDATE messages SET push_sent = 1 WHERE id = ?
      `, [msg.id]);
    }
  }
}
```

**方案 C**: Echo gRPC API（最优雅）

```typescript
@Injectable()
export class MessageListenerService implements OnModuleInit {
  private grpcClient: any;

  onModuleInit() {
    // 连接 Echo gRPC
    this.grpcClient = new EchoClient('echo-server:50051');
    
    // 订阅消息更新
    this.grpcClient.subscribeUpdates((update) => {
      if (update.type === 'new_message') {
        this.pushService.sendPush(update.message);
      }
    });
  }
}
```

#### 3.2.2 FCM 推送（Android）

**任务**:
- [ ] 注册 Firebase 项目
- [ ] 下载 google-services.json
- [ ] 集成 FCM SDK 到客户端
- [ ] 实现 NestJS FCM 服务

**代码**: `src/push/fcm-push.service.ts`

```typescript
import * as admin from 'firebase-admin';

@Injectable()
export class FcmPushService {
  constructor() {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY,
      }),
    });
  }

  async sendPush(userId: string, message: any): Promise<void> {
    // 获取用户的 FCM token
    const token = await this.getUserFcmToken(userId);
    
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title: message.from_name,
        body: message.text,
      },
      data: {
        message_id: message.id.toString(),
        chat_id: message.chat_id.toString(),
      },
    });
  }

  private async getUserFcmToken(userId: string): Promise<string | null> {
    // 从数据库获取
    const user = await this.db.query('SELECT fcm_token FROM users WHERE id = ?', [userId]);
    return user?.fcm_token;
  }
}
```

#### 3.2.3 APNs 推送（iOS）

**任务**:
- [ ] 申请 Apple Developer 账号
- [ ] 创建 APNs 证书
- [ ] 实现 NestJS APNs 服务

**代码**: `src/push/apns-push.service.ts`

```typescript
import apn from 'apn';

@Injectable()
export class ApnsPushService {
  private provider: apn.Provider;

  constructor() {
    this.provider = new apn.Provider({
      token: {
        key: process.env.APNS_KEY,
        keyId: process.env.APNS_KEY_ID,
        teamId: process.env.APNS_TEAM_ID,
      },
      production: false, // 开发环境
    });
  }

  async sendPush(userId: string, message: any): Promise<void> {
    const token = await this.getUserApnsToken(userId);
    
    if (!token) return;

    const notification = new apn.Notification();
    notification.alert = {
      title: message.from_name,
      body: message.text,
    };
    notification.badge = 1;
    notification.sound = 'default';
    notification.payload = {
      message_id: message.id,
      chat_id: message.chat_id,
    };

    await this.provider.send(notification, token);
  }

  private async getUserApnsToken(userId: string): Promise<string | null> {
    const user = await this.db.query('SELECT apns_token FROM users WHERE id = ?', [userId]);
    return user?.apns_token;
  }
}
```

### 3.3 客户端修改

**任务**:
- [ ] 集成 FCM SDK（Android）
- [ ] 集成 APNs（iOS）
- [ ] 上传 token 到 Echo Business Server
- [ ] 处理推送通知点击

### 3.4 测试

**测试清单**:
- [ ] 应用在后台时接收推送
- [ ] 应用关闭时接收推送
- [ ] 点击推送打开对应聊天
- [ ] 推送内容正确显示
- [ ] 推送角标更新

---

## 🎯 Phase 4: 管理后台（3-4周）

**目标**: 构建 Web 管理后台

### 4.1 功能模块

#### 4.1.1 用户管理
- 用户列表
- 用户详情
- 封禁/解封
- 用户统计

#### 4.1.2 聊天监控
- 聊天记录查看
- 敏感词过滤
- 内容审核

#### 4.1.3 数据分析
- 活跃用户统计
- 消息量统计
- 存储使用情况

#### 4.1.4 系统配置
- 服务器配置
- 推送配置
- 认证配置

### 4.2 技术栈

```
前端: React + Ant Design
后端: NestJS (已有)
数据库: PostgreSQL (Echo 业务数据) + MySQL (Echo 数据)
```

### 4.3 开发任务

**任务**:
- [ ] 搭建 React 项目
- [ ] 实现用户管理模块
- [ ] 实现聊天监控模块
- [ ] 实现数据分析模块
- [ ] 实现系统配置模块

---

## 🎯 Phase 5: 文件中转（1-2周）

**目标**: 利用 Telegram Bot API 存储大文件

### 5.1 架构设计

```
Echo Client (上传大文件)
    ↓
Echo Business Server
    ↓
Telegram Bot API (免费存储)
    ↓
Telegram 官方服务器
```

### 5.2 开发任务

**任务**:
- [ ] 注册 Telegram Bot
- [ ] 实现文件上传到 Bot
- [ ] 实现文件下载代理
- [ ] 客户端集成

---

## 🎯 Phase 6: VPS 部署（2-3周）

**目标**: 部署到生产环境

### 6.1 服务器选择

**推荐配置**:
- CPU: 4核
- 内存: 8GB
- 存储: 100GB SSD
- 带宽: 10Mbps
- 位置: 香港/新加坡

### 6.2 部署架构

```
Nginx (负载均衡 + SSL)
    ↓
Echo Server Cluster (3节点)
    ↓
Echo Business Server (2节点)
    ↓
数据层:
  - MySQL (主从复制)
  - Redis (哨兵模式)
  - MinIO (分布式存储)
  - Kafka (3节点)
```

### 6.3 部署任务

**任务**:
- [ ] 购买 VPS
- [ ] 配置域名和 SSL
- [ ] 部署 Docker Swarm / Kubernetes
- [ ] 部署 Echo Server
- [ ] 部署 Echo Business Server
- [ ] 配置监控（Prometheus + Grafana）
- [ ] 配置日志（ELK Stack）
- [ ] 配置备份

---

## 📊 时间估算总览

| Phase | 任务 | 时间 | 依赖 |
|-------|------|------|------|
| Phase 1 | 基础部署 + 测试 | 1-2周 | - |
| Phase 2 | 认证系统开发 | 2-3周 | Phase 1 |
| Phase 3 | 推送通知开发 | 2-3周 | Phase 1 |
| Phase 4 | 管理后台开发 | 3-4周 | Phase 2 |
| Phase 5 | 文件中转开发 | 1-2周 | Phase 1 |
| Phase 6 | VPS 部署 + 优化 | 2-3周 | All |
| **总计** | | **11-17周** | **(2.5-4个月)** |

---

## 🎯 里程碑

### Milestone 1: MVP（4周）
- ✅ Echo Server 运行
- ✅ 客户端可以连接
- ✅ 基础消息功能

### Milestone 2: 认证系统（7周）
- ✅ 短信/邮件验证
- ✅ 真实用户注册

### Milestone 3: 推送通知（10周）
- ✅ FCM/APNs 推送
- ✅ 离线消息通知

### Milestone 4: 生产就绪（17周）
- ✅ 管理后台
- ✅ VPS 部署
- ✅ 监控和备份

---

## 🚨 风险管理

### 高风险
1. **+86 手机号限制**
   - 风险: Telegram 可能限制 +86 号码
   - 缓解: 主推邮箱注册

2. **客户端检测**
   - 风险: Telegram 客户端可能检测非官方服务器
   - 缓解: 使用 Echo 推荐的 Fork 版本

### 中风险
1. **性能问题**
   - 风险: 大规模用户时性能下降
   - 缓解: 提前规划集群部署

2. **数据迁移**
   - 风险: Echo 升级时 schema 变化
   - 缓解: 版本控制 + 迁移脚本

### 低风险
1. **功能缺失**
   - 风险: 缺少频道、机器人等
   - 缓解: 初期不需要

---

## ✅ 下一步行动

### 本周（Week 1）
1. ✅ 创建 `ECHO_START_HERE.md`
2. ✅ 创建 `echo-deploy-local-mac.sh`
3. 🔄 执行部署脚本
4. 🔄 测试 Echo Server
5. 🔄 编译客户端

### 下周（Week 2）
6. 测试客户端连接
7. 验证基础功能
8. 测试 API Layer 兼容性
9. 开始设计认证系统

---

## 📚 参考资源

- Echo Server: https://github.com/echo/echo-server
- Telegram API: https://core.telegram.org/api
- MTProto 协议: https://core.telegram.org/mtproto
- 阿里云短信: https://www.aliyun.com/product/sms
- 阿里云邮件: https://www.aliyun.com/product/directmail
- Firebase FCM: https://firebase.google.com/docs/cloud-messaging
- Apple APNs: https://developer.apple.com/documentation/usernotifications

---

**最后更新**: 2026-01-27  
**项目状态**: Phase 1 进行中
