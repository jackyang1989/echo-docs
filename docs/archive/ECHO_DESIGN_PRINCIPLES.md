# Echo IM - 设计原则

**日期**: 2026-01-27  
**核心理念**: 零侵入、完全解耦、易于维护

---

## 🎯 核心设计原则

### 1. 零侵入原则 ⭐⭐⭐

**Echo Server 保持原样，不做任何修改**

```
❌ 错误做法：修改 Echo 源码
  - 修改 Go 代码添加新功能
  - 修改数据库表结构
  - 修改 API 接口

✅ 正确做法：外部扩展
  - Echo Server 作为黑盒使用
  - 所有扩展功能在 Echo Business Server 实现
  - 通过标准接口（gRPC/Kafka/HTTP）通信
```

**好处**:
- ✅ Echo 可以随时升级，不影响扩展功能
- ✅ 出问题时可以快速回滚
- ✅ 降低维护成本
- ✅ 保持系统稳定性

---

### 2. 完全解耦原则 ⭐⭐⭐

**三层架构，层与层之间完全独立**

```
┌─────────────────────────────────────────┐
│  客户端层 (Client)                       │
│  - 可以独立升级                          │
│  - 不依赖业务层                          │
└─────────────────────────────────────────┘
              ↓ 标准 MTProto 协议
┌─────────────────────────────────────────┐
│  核心 IM 层 (Echo Server)            │
│  - 独立运行                              │
│  - 不知道业务层存在                       │
│  - 可以随时升级/替换                      │
└─────────────────────────────────────────┘
              ↓ 标准接口（只读）
┌─────────────────────────────────────────┐
│  业务扩展层 (Echo Business Server)    │
│  - 独立部署                              │
│  - 可以停止而不影响 IM 核心功能           │
│  - 可以独立升级                          │
└─────────────────────────────────────────┘
```

**关键点**:
- Echo Server 不依赖 Echo Business Server
- Echo Business Server 停止，IM 核心功能仍然正常
- 两者通过标准接口通信，互不影响

---

### 3. 只读监听原则 ⭐⭐⭐

**Echo Business Server 只监听，不修改 Echo 数据**

```typescript
// ❌ 错误：直接修改 Echo 数据库
await echoDB.query('UPDATE users SET email = ? WHERE id = ?', [email, userId]);

// ✅ 正确：维护自己的数据库
await echoDB.query('INSERT INTO user_emails (user_id, email) VALUES (?, ?)', [userId, email]);
```

**数据流向**:
```
Echo DB (只读) → Echo Business Server → Echo DB (读写)
```

**实现方式**:
1. **CDC (Change Data Capture)**: 监听 Echo 数据库变化
2. **Kafka 事件**: 订阅 Echo 发出的事件
3. **gRPC 流**: 订阅 Echo 的更新流
4. **定时轮询**: 定期查询 Echo 数据（最后选择）

---

### 4. 独立数据库原则 ⭐⭐⭐

**每个服务使用独立的数据库**

```
Echo Server:
  - MySQL: echodb (IM 核心数据)
  - Redis: echo-cache (会话缓存)

Echo Business Server:
  - PostgreSQL: echo_business (业务数据)
  - Redis: echo-business-cache (业务缓存)
```

**数据分类**:

| 数据类型 | 存储位置 | 访问方式 |
|---------|---------|---------|
| 用户基本信息 | Echo DB | 只读 |
| 消息内容 | Echo DB | 只读 |
| 群组信息 | Echo DB | 只读 |
| 邮箱绑定 | Echo DB | 读写 |
| 设备 Token | Echo DB | 读写 |
| 推送记录 | Echo DB | 读写 |
| 分析数据 | Echo DB | 读写 |

---

### 5. 事件驱动原则 ⭐⭐

**通过事件实现松耦合**

```typescript
// Echo 发生事件
Echo Server → Kafka Topic: echo.events

// Echo Business Server 订阅事件
@Injectable()
export class EchoEventListener {
  @OnEvent('echo.message.new')
  async handleNewMessage(event: NewMessageEvent) {
    // 1. 检查用户是否在线
    const isOnline = await this.checkUserOnline(event.userId);
    
    // 2. 如果离线，发送推送
    if (!isOnline) {
      await this.pushService.sendPush(event.userId, event.message);
    }
    
    // 3. 记录到分析数据库
    await this.analyticsService.recordMessage(event);
  }
}
```

**好处**:
- ✅ Echo 不需要知道有推送服务
- ✅ 推送服务可以随时启动/停止
- ✅ 可以添加更多监听器而不影响现有功能

---

### 6. 配置驱动原则 ⭐⭐

**所有功能通过配置启用/禁用**

```yaml
# config/production.yaml
echo:
  # 核心 IM（必需）
  echo:
    enabled: true
    host: echo-gateway
    port: 10443
  
  # 业务扩展（可选）
  modules:
    auth:
      enabled: true
      email:
        enabled: true
        provider: sendgrid
      sms:
        enabled: false  # 可以关闭
    
    push:
      enabled: true
      fcm:
        enabled: true
      apns:
        enabled: false  # iOS 未准备好，先关闭
    
    admin:
      enabled: true
    
    analytics:
      enabled: false  # 暂时不需要
    
    storage:
      telegram_bot:
        enabled: false  # 暂时不需要
```

**运行时控制**:
```typescript
// 模块自动根据配置启用/禁用
@Module({
  imports: [
    ConfigModule.forRoot(),
    // 条件导入
    ...(config.get('modules.auth.enabled') ? [AuthModule] : []),
    ...(config.get('modules.push.enabled') ? [PushModule] : []),
    ...(config.get('modules.admin.enabled') ? [AdminModule] : []),
  ],
})
export class AppModule {}
```

---

### 7. 降级保护原则 ⭐⭐⭐

**业务层故障不影响 IM 核心功能**

```typescript
// 推送服务故障处理
@Injectable()
export class PushService {
  async sendPush(userId: string, message: any): Promise<void> {
    try {
      await this.fcmProvider.send(token, message);
    } catch (error) {
      // 推送失败，记录日志，但不抛出异常
      this.logger.error('Push failed', error);
      
      // 降级：存储到数据库，稍后重试
      await this.pushQueueRepo.save({
        userId,
        message,
        status: 'failed',
        retryCount: 0,
      });
    }
  }
}

// 认证服务故障处理
@Injectable()
export class AuthService {
  async sendVerificationCode(email: string): Promise<void> {
    try {
      await this.emailProvider.send(email, code);
    } catch (error) {
      // 邮件服务故障，降级到备用服务
      this.logger.error('Primary email service failed', error);
      
      try {
        await this.backupEmailProvider.send(email, code);
      } catch (backupError) {
        // 备用服务也失败，返回友好错误
        throw new ServiceUnavailableException('邮件服务暂时不可用，请稍后再试');
      }
    }
  }
}
```

**降级策略**:
1. **推送失败**: 存储到队列，稍后重试
2. **邮件失败**: 切换到备用服务
3. **分析失败**: 记录日志，不影响主流程
4. **管理后台故障**: 不影响用户使用

---

### 8. 版本兼容原则 ⭐⭐

**支持 Echo 升级而不影响业务层**

```typescript
// 使用版本适配器
@Injectable()
export class EchoAdapter {
  constructor(private config: ConfigService) {}

  async getMessage(messageId: string): Promise<Message> {
    const version = this.config.get('echo.version');
    
    if (version === '1.0') {
      return this.getMessageV1(messageId);
    } else if (version === '2.0') {
      return this.getMessageV2(messageId);
    }
    
    // 默认使用最新版本
    return this.getMessageV2(messageId);
  }

  private async getMessageV1(messageId: string): Promise<Message> {
    // 旧版本 API
    const data = await this.grpcClient.getMessage({ id: messageId });
    return this.transformV1ToCommon(data);
  }

  private async getMessageV2(messageId: string): Promise<Message> {
    // 新版本 API
    const data = await this.grpcClient.getMessageV2({ messageId });
    return this.transformV2ToCommon(data);
  }
}
```

---

### 9. 监控可观测原则 ⭐⭐

**完整的监控和日志**

```typescript
// 每个关键操作都有日志和指标
@Injectable()
export class PushService {
  constructor(
    private logger: Logger,
    private metrics: MetricsService,
  ) {}

  async sendPush(userId: string, message: any): Promise<void> {
    const startTime = Date.now();
    
    try {
      this.logger.log(`Sending push to user ${userId}`);
      await this.fcmProvider.send(token, message);
      
      // 记录成功指标
      this.metrics.increment('push.sent.success');
      this.metrics.timing('push.duration', Date.now() - startTime);
      
    } catch (error) {
      this.logger.error(`Push failed for user ${userId}`, error);
      
      // 记录失败指标
      this.metrics.increment('push.sent.failed');
      
      throw error;
    }
  }
}
```

**监控指标**:
- 推送成功率
- 邮件发送成功率
- API 响应时间
- 错误率
- 队列长度

---

### 10. 文档驱动原则 ⭐

**完整的 API 文档和架构文档**

```typescript
// 使用 Swagger 自动生成 API 文档
@ApiTags('认证')
@Controller('auth')
export class AuthController {
  @Post('send-code')
  @ApiOperation({ summary: '发送验证码' })
  @ApiResponse({ status: 200, description: '发送成功' })
  @ApiResponse({ status: 429, description: '请求过于频繁' })
  async sendCode(@Body() dto: SendCodeDto) {
    return this.authService.sendVerificationCode(dto.email);
  }
}
```

---

## 📐 架构决策记录 (ADR)

### ADR-001: 为什么不修改 Echo 源码？

**决策**: 不修改 Echo 源码，所有扩展功能在外部实现

**理由**:
1. **可升级性**: Echo 升级时不需要 merge 代码
2. **稳定性**: 不引入新的 bug
3. **维护性**: 降低维护成本
4. **责任分离**: IM 核心和业务逻辑分离

**替代方案**: 修改 Echo 源码
- ❌ 升级困难
- ❌ 维护成本高
- ❌ 容易引入 bug

---

### ADR-002: 为什么使用独立数据库？

**决策**: Echo Business Server 使用独立的 PostgreSQL 数据库

**理由**:
1. **数据隔离**: 业务数据和 IM 数据分离
2. **性能**: 不影响 IM 核心性能
3. **扩展性**: 可以独立扩展
4. **安全性**: 降低数据泄露风险

**替代方案**: 共享 Echo 的 MySQL
- ❌ 耦合度高
- ❌ 性能影响
- ❌ 升级困难

---

### ADR-003: 为什么使用事件驱动？

**决策**: 通过 Kafka 事件实现模块间通信

**理由**:
1. **解耦**: 模块间松耦合
2. **异步**: 不阻塞主流程
3. **可靠性**: 消息不丢失
4. **可扩展**: 易于添加新监听器

**替代方案**: 直接调用
- ❌ 耦合度高
- ❌ 同步阻塞
- ❌ 扩展困难

---

## ✅ 实施检查清单

### 开发阶段
- [ ] Echo Server 零修改
- [ ] 使用独立数据库
- [ ] 所有扩展功能可配置
- [ ] 完整的错误处理
- [ ] 降级保护机制
- [ ] 日志和监控

### 测试阶段
- [ ] Echo Business Server 停止，IM 仍然可用
- [ ] 推送服务故障，消息仍然可以收发
- [ ] 邮件服务故障，不影响已登录用户
- [ ] Echo 升级，业务层不受影响

### 部署阶段
- [ ] 独立部署
- [ ] 独立扩展
- [ ] 独立监控
- [ ] 独立备份

---

## 🎯 总结

### 核心原则（必须遵守）

1. **零侵入**: 不修改 Echo 源码
2. **完全解耦**: 三层架构独立
3. **只读监听**: 不修改 Echo 数据
4. **独立数据库**: 业务数据独立存储
5. **降级保护**: 业务层故障不影响 IM

### 好处

- ✅ **可维护性**: 降低维护成本
- ✅ **可扩展性**: 易于添加新功能
- ✅ **稳定性**: IM 核心功能不受影响
- ✅ **灵活性**: 可以随时启用/禁用功能
- ✅ **可升级性**: Echo 可以随时升级

### 下一步

1. 按照这些原则搭建 Echo Business Server
2. 实现第一个模块（邮件认证）
3. 验证架构设计的正确性
4. 逐步添加其他模块

---

**最后更新**: 2026-01-27  
**状态**: 设计原则确定
