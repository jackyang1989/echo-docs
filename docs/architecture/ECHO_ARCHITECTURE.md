# Echo IM - 架构设计

**日期**: 2026-01-27  
**版本**: 1.0

---

## 🏗️ 整体架构

### 三层架构设计

```
┌─────────────────────────────────────────────────────────┐
│  Layer 1: 客户端层 (Client Layer)                        │
│  - Echo Android/iOS/Desktop                          │
│  - 用户直接交互                                           │
└─────────────────────────────────────────────────────────┘
                        ↓ MTProto 2.0
┌─────────────────────────────────────────────────────────┐
│  Layer 2: 核心 IM 层 (Core IM Layer)                     │
│  - Echo Server (Go)                                 │
│  - 基础消息、群组、文件功能                                │
│  - 不修改源码，保持可升级性                                │
└─────────────────────────────────────────────────────────┘
                        ↓ HTTP/gRPC/Kafka
┌─────────────────────────────────────────────────────────┐
│  Layer 3: 业务扩展层 (Business Extension Layer)          │
│  - Echo Business Server (NestJS)                     │
│  - 模块化扩展功能                                         │
│  - 独立部署、独立升级                                      │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 模块化架构设计

### Echo Business Server 模块结构

```
echo-business-server/
├── src/
│   ├── core/                          # 核心模块
│   │   ├── config/                    # 配置管理
│   │   ├── database/                  # 数据库连接
│   │   ├── redis/                     # Redis 连接
│   │   └── logger/                    # 日志服务
│   │
│   ├── modules/                       # 业务模块（模块化）
│   │   │
│   │   ├── auth/                      # 认证模块 ⭐
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── strategies/
│   │   │   │   ├── email-verification.strategy.ts
│   │   │   │   └── sms-verification.strategy.ts
│   │   │   ├── providers/
│   │   │   │   ├── sendgrid.provider.ts
│   │   │   │   └── twilio.provider.ts
│   │   │   └── dto/
│   │   │       ├── send-code.dto.ts
│   │   │       └── verify-code.dto.ts
│   │   │
│   │   ├── push/                      # 推送通知模块 ⭐
│   │   │   ├── push.module.ts
│   │   │   ├── push.controller.ts
│   │   │   ├── push.service.ts
│   │   │   ├── listeners/
│   │   │   │   ├── message.listener.ts
│   │   │   │   └── kafka.listener.ts
│   │   │   ├── providers/
│   │   │   │   ├── fcm.provider.ts
│   │   │   │   └── apns.provider.ts
│   │   │   └── entities/
│   │   │       └── device-token.entity.ts
│   │   │
│   │   ├── admin/                     # 管理后台模块 ⭐
│   │   │   ├── admin.module.ts
│   │   │   ├── dashboard/
│   │   │   ├── users/
│   │   │   ├── messages/
│   │   │   └── analytics/
│   │   │
│   │   ├── analytics/                 # 数据分析模块 ⭐
│   │   │   ├── analytics.module.ts
│   │   │   ├── analytics.service.ts
│   │   │   └── reports/
│   │   │
│   │   ├── storage/                   # 文件存储模块 ⭐
│   │   │   ├── storage.module.ts
│   │   │   ├── storage.service.ts
│   │   │   ├── providers/
│   │   │   │   ├── minio.provider.ts
│   │   │   │   └── telegram-bot.provider.ts
│   │   │   └── dto/
│   │   │
│   │   └── echo-bridge/          # Echo 桥接模块 ⭐
│   │       ├── bridge.module.ts
│   │       ├── bridge.service.ts
│   │       ├── grpc-client.service.ts
│   │       └── kafka-consumer.service.ts
│   │
│   ├── shared/                        # 共享模块
│   │   ├── decorators/
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── pipes/
│   │   └── utils/
│   │
│   └── main.ts                        # 应用入口
│
├── config/                            # 配置文件
│   ├── default.yaml
│   ├── development.yaml
│   └── production.yaml
│
├── docker-compose.yml                 # Docker 配置
├── Dockerfile
├── package.json
└── tsconfig.json
```

---

## 🔌 模块化设计原则

### 1. 独立性原则

每个模块都是独立的 NestJS Module，可以：
- ✅ 独立开发
- ✅ 独立测试
- ✅ 独立部署（微服务）
- ✅ 按需启用/禁用

**示例**:
```typescript
// app.module.ts
@Module({
  imports: [
    CoreModule,
    AuthModule,              // 可选：邮件/短信认证
    PushModule,              // 可选：推送通知
    AdminModule,             // 可选：管理后台
    AnalyticsModule,         // 可选：数据分析
    StorageModule,           // 可选：文件存储
    EchoBridgeModule,    // 必需：与 Echo 通信
  ],
})
export class AppModule {}
```

### 2. 接口抽象原则

使用接口和策略模式，方便切换实现：

**示例 - 邮件服务**:
```typescript
// auth/interfaces/email-provider.interface.ts
export interface IEmailProvider {
  sendVerificationCode(email: string, code: string): Promise<void>;
}

// auth/providers/sendgrid.provider.ts
@Injectable()
export class SendGridProvider implements IEmailProvider {
  async sendVerificationCode(email: string, code: string): Promise<void> {
    // SendGrid 实现
  }
}

// auth/providers/aws-ses.provider.ts
@Injectable()
export class AwsSesProvider implements IEmailProvider {
  async sendVerificationCode(email: string, code: string): Promise<void> {
    // AWS SES 实现
  }
}

// auth/auth.module.ts
@Module({
  providers: [
    {
      provide: 'EMAIL_PROVIDER',
      useClass: process.env.EMAIL_PROVIDER === 'ses' 
        ? AwsSesProvider 
        : SendGridProvider,
    },
  ],
})
export class AuthModule {}
```

### 3. 配置驱动原则

所有模块通过配置文件启用/禁用：

**config/default.yaml**:
```yaml
modules:
  auth:
    enabled: true
    email:
      provider: sendgrid  # sendgrid | aws-ses
      enabled: true
    sms:
      provider: twilio    # twilio | aliyun
      enabled: false      # 可选功能，默认关闭
  
  push:
    enabled: true
    fcm:
      enabled: true
    apns:
      enabled: true
  
  admin:
    enabled: true
    port: 3001
  
  analytics:
    enabled: false        # 可选功能
  
  storage:
    enabled: true
    telegram_bot:
      enabled: false      # 可选功能
```

### 4. 事件驱动原则

模块间通过事件通信，降低耦合：

```typescript
// echo-bridge/events/message.event.ts
export class NewMessageEvent {
  constructor(
    public readonly messageId: string,
    public readonly userId: string,
    public readonly content: string,
  ) {}
}

// echo-bridge/bridge.service.ts
@Injectable()
export class BridgeService {
  constructor(private eventEmitter: EventEmitter2) {}

  async onNewMessage(message: any) {
    // 发布事件
    this.eventEmitter.emit(
      'message.new',
      new NewMessageEvent(message.id, message.userId, message.content),
    );
  }
}

// push/listeners/message.listener.ts
@Injectable()
export class MessageListener {
  @OnEvent('message.new')
  async handleNewMessage(event: NewMessageEvent) {
    // 发送推送通知
    await this.pushService.sendPush(event.userId, event.content);
  }
}
```

---

## 🔐 认证模块详细设计

### 模块结构

```
auth/
├── auth.module.ts                     # 模块定义
├── auth.controller.ts                 # HTTP 控制器
├── auth.service.ts                    # 业务逻辑
│
├── strategies/                        # 认证策略
│   ├── verification.strategy.ts       # 抽象策略
│   ├── email-verification.strategy.ts # 邮件验证
│   └── sms-verification.strategy.ts   # 短信验证
│
├── providers/                         # 第三方服务提供者
│   ├── email/
│   │   ├── sendgrid.provider.ts
│   │   └── aws-ses.provider.ts
│   └── sms/
│       ├── twilio.provider.ts
│       └── aliyun.provider.ts
│
├── guards/                            # 守卫
│   └── verification.guard.ts
│
├── dto/                               # 数据传输对象
│   ├── send-code.dto.ts
│   ├── verify-code.dto.ts
│   └── resend-code.dto.ts
│
└── entities/                          # 数据库实体
    └── verification-code.entity.ts
```

### 核心代码

**auth.module.ts**:
```typescript
import { Module, DynamicModule } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({})
export class AuthModule {
  static forRoot(): DynamicModule {
    return {
      module: AuthModule,
      imports: [ConfigModule],
      providers: [
        AuthService,
        // 动态注册邮件提供者
        {
          provide: 'EMAIL_PROVIDER',
          useFactory: (config: ConfigService) => {
            const provider = config.get('modules.auth.email.provider');
            if (provider === 'aws-ses') {
              return new AwsSesProvider(config);
            }
            return new SendGridProvider(config);
          },
          inject: [ConfigService],
        },
        // 动态注册短信提供者（可选）
        {
          provide: 'SMS_PROVIDER',
          useFactory: (config: ConfigService) => {
            if (!config.get('modules.auth.sms.enabled')) {
              return null;
            }
            const provider = config.get('modules.auth.sms.provider');
            if (provider === 'aliyun') {
              return new AliyunProvider(config);
            }
            return new TwilioProvider(config);
          },
          inject: [ConfigService],
        },
        EmailVerificationStrategy,
        SmsVerificationStrategy,
      ],
      controllers: [AuthController],
      exports: [AuthService],
    };
  }
}
```

**auth.service.ts**:
```typescript
@Injectable()
export class AuthService {
  constructor(
    @Inject('EMAIL_PROVIDER') private emailProvider: IEmailProvider,
    @Inject('SMS_PROVIDER') private smsProvider: ISmsProvider | null,
    private redis: Redis,
    private config: ConfigService,
  ) {}

  async sendVerificationCode(
    identifier: string,
    type: 'email' | 'sms' = 'email',
  ): Promise<void> {
    // 生成验证码
    const code = this.generateCode();
    
    // 检查冷却期
    const cooldownKey = `cooldown:${type}:${identifier}`;
    const cooldown = await this.redis.get(cooldownKey);
    if (cooldown) {
      throw new BadRequestException('请等待 60 秒后再试');
    }

    // 发送验证码
    if (type === 'email') {
      await this.emailProvider.sendVerificationCode(identifier, code);
    } else if (type === 'sms') {
      if (!this.smsProvider) {
        throw new BadRequestException('短信验证未启用');
      }
      await this.smsProvider.sendVerificationCode(identifier, code);
    }

    // 存储验证码（5分钟过期）
    const codeKey = `code:${type}:${identifier}`;
    await this.redis.setex(codeKey, 300, code);
    
    // 设置冷却期（60秒）
    await this.redis.setex(cooldownKey, 60, '1');
  }

  async verifyCode(
    identifier: string,
    code: string,
    type: 'email' | 'sms' = 'email',
  ): Promise<boolean> {
    const codeKey = `code:${type}:${identifier}`;
    const storedCode = await this.redis.get(codeKey);
    
    if (!storedCode) {
      throw new BadRequestException('验证码已过期');
    }
    
    if (storedCode !== code) {
      throw new BadRequestException('验证码错误');
    }
    
    // 验证成功，删除验证码
    await this.redis.del(codeKey);
    return true;
  }

  private generateCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}
```

---

## 🔔 推送通知模块详细设计

### 模块结构

```
push/
├── push.module.ts
├── push.controller.ts
├── push.service.ts
│
├── listeners/                         # 事件监听器
│   ├── message.listener.ts            # 监听新消息
│   └── kafka.listener.ts              # 监听 Kafka 事件
│
├── providers/                         # 推送提供者
│   ├── fcm.provider.ts                # Firebase Cloud Messaging
│   └── apns.provider.ts               # Apple Push Notification
│
├── entities/
│   └── device-token.entity.ts         # 设备 Token 存储
│
└── dto/
    ├── register-token.dto.ts
    └── send-push.dto.ts
```

### 核心代码

**push.service.ts**:
```typescript
@Injectable()
export class PushService {
  constructor(
    @Inject('FCM_PROVIDER') private fcmProvider: IFcmProvider,
    @Inject('APNS_PROVIDER') private apnsProvider: IApnsProvider,
    @InjectRepository(DeviceToken)
    private deviceTokenRepo: Repository<DeviceToken>,
  ) {}

  async sendPush(userId: string, message: any): Promise<void> {
    // 获取用户的所有设备 Token
    const tokens = await this.deviceTokenRepo.find({
      where: { userId, isActive: true },
    });

    // 并行发送推送
    await Promise.all(
      tokens.map(async (token) => {
        try {
          if (token.platform === 'android') {
            await this.fcmProvider.send(token.token, message);
          } else if (token.platform === 'ios') {
            await this.apnsProvider.send(token.token, message);
          }
        } catch (error) {
          // 如果 Token 无效，标记为失效
          if (error.code === 'invalid-token') {
            token.isActive = false;
            await this.deviceTokenRepo.save(token);
          }
        }
      }),
    );
  }

  async registerToken(
    userId: string,
    token: string,
    platform: 'android' | 'ios',
  ): Promise<void> {
    // 检查 Token 是否已存在
    let deviceToken = await this.deviceTokenRepo.findOne({
      where: { token },
    });

    if (deviceToken) {
      // 更新用户 ID 和状态
      deviceToken.userId = userId;
      deviceToken.isActive = true;
      deviceToken.lastUsedAt = new Date();
    } else {
      // 创建新 Token
      deviceToken = this.deviceTokenRepo.create({
        userId,
        token,
        platform,
        isActive: true,
      });
    }

    await this.deviceTokenRepo.save(deviceToken);
  }
}
```

**message.listener.ts**:
```typescript
@Injectable()
export class MessageListener {
  constructor(private pushService: PushService) {}

  @OnEvent('message.new')
  async handleNewMessage(event: NewMessageEvent) {
    // 检查用户是否在线
    const isOnline = await this.checkUserOnline(event.userId);
    
    if (!isOnline) {
      // 用户离线，发送推送通知
      await this.pushService.sendPush(event.userId, {
        title: event.senderName,
        body: event.content,
        data: {
          messageId: event.messageId,
          chatId: event.chatId,
        },
      });
    }
  }

  private async checkUserOnline(userId: string): Promise<boolean> {
    // 从 Redis 检查用户在线状态
    // 实现逻辑...
    return false;
  }
}
```

---

## 🌉 Echo 桥接模块

### 通信方式

```
Echo Business Server ←→ Echo Server

方式 1: gRPC（推荐）
  - 高性能
  - 类型安全
  - 双向流

方式 2: Kafka 事件
  - 异步通信
  - 解耦
  - 可靠性高

方式 3: HTTP API
  - 简单
  - 易于调试
  - 适合简单场景
```

### 桥接服务

**bridge.service.ts**:
```typescript
@Injectable()
export class BridgeService implements OnModuleInit {
  private grpcClient: any;

  constructor(
    private eventEmitter: EventEmitter2,
    private config: ConfigService,
  ) {}

  async onModuleInit() {
    // 连接 Echo gRPC
    const host = this.config.get('echo.grpc.host');
    const port = this.config.get('echo.grpc.port');
    
    this.grpcClient = new EchoClient(`${host}:${port}`);
    
    // 订阅消息更新
    this.subscribeToUpdates();
  }

  private subscribeToUpdates() {
    this.grpcClient.subscribeUpdates((update: any) => {
      // 将 Echo 事件转换为内部事件
      switch (update.type) {
        case 'new_message':
          this.eventEmitter.emit('message.new', new NewMessageEvent(update));
          break;
        case 'user_online':
          this.eventEmitter.emit('user.online', new UserOnlineEvent(update));
          break;
        // ... 其他事件
      }
    });
  }

  async sendMessage(userId: string, chatId: string, content: string): Promise<void> {
    // 调用 Echo API 发送消息
    await this.grpcClient.sendMessage({
      userId,
      chatId,
      content,
    });
  }
}
```

---

## 📊 部署架构

### 开发环境

```
Mac 本地:
  - Echo Server (Docker)
  - Echo Business Server (npm run dev)
  - PostgreSQL (Docker)
  - Redis (Docker)
```

### 生产环境

```
VPS 1: Echo Server
  - Docker Swarm / Kubernetes
  - MySQL (主从复制)
  - Redis (哨兵模式)
  - MinIO (分布式)
  - Kafka (3节点)

VPS 2: Echo Business Server
  - Docker Swarm / Kubernetes
  - PostgreSQL (主从复制)
  - Redis (独立实例)

负载均衡:
  - Nginx
  - SSL 证书
```

---

## ✅ 总结

### 模块化优势

1. **灵活性**: 按需启用/禁用功能
2. **可维护性**: 模块独立，易于维护
3. **可扩展性**: 新功能作为新模块添加
4. **可测试性**: 模块独立测试
5. **可部署性**: 可以拆分为微服务

### 下一步

1. ✅ 完成 Echo Server 部署
2. 🔄 搭建 Echo Business Server 框架
3. 🔄 实现认证模块（邮件验证）
4. ⏳ 实现推送通知模块
5. ⏳ 实现管理后台模块

---

**最后更新**: 2026-01-27  
**状态**: 架构设计完成
