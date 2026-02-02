# Telegram API 核心概念参考

**版本**: 1.0.0  
**更新日期**: 2026-01-30  
**来源**: [Telegram 官方 API 文档](https://core.telegram.org/api)

> **Echo 项目说明**: 本文档整理自 Telegram 官方 API，作为 Echo 二次开发的技术参考。
> Echo 计划使用**邮箱注册**替代手机号注册，相关改造点已在文档中标注。

---

## 1. 用户认证 (User Authorization)

### 1.1 标准登录流程（手机号）

```
┌──────────────┐    ┌────────────────┐    ┌─────────────────┐
│ 用户输入手机号 │ →  │ auth.sendCode   │ →  │ 发送验证码       │
│              │    │ (请求发送验证码)  │    │ (SMS/来电/App内) │
└──────────────┘    └────────────────┘    └─────────────────┘
                                                   │
                                                   ▼
┌──────────────┐    ┌────────────────┐    ┌─────────────────┐
│ 完成登录      │ ←  │ auth.signIn     │ ←  │ 用户输入验证码    │
│              │    │ (验证码验证)     │    │                 │
└──────────────┘    └────────────────┘    └─────────────────┘
```

### 1.2 验证码类型

| 类型 | 说明 | API 标识 |
|------|------|----------|
| SMS | 短信验证码 | `auth.sentCodeTypeSms` |
| Call | 语音电话播报 | `auth.sentCodeTypeCall` |
| FlashCall | 来电显示包含验证码 | `auth.sentCodeTypeFlashCall` |
| App | 已登录设备推送 | `auth.sentCodeTypeApp` |

### 1.3 新用户注册

当 `auth.signIn` 返回 `auth.authorizationSignUpRequired` 时：
1. 收集用户信息（姓名）
2. 同意服务条款
3. 调用 `auth.signUp` 完成注册

### 🔧 Echo 改造: 邮箱注册

> **计划改造**: 使用邮箱替代手机号

改造要点：
- 服务端需修改 `auth.sendCode` 逻辑，支持邮箱发送验证码
- 客户端 `LoginActivity` 需增加邮箱输入界面
- 数据库 `users` 表需增加 `email` 字段
- 参考 Telegram 已有的邮箱验证 API: `account.sendVerifyEmailCode`

---

## 2. 双因素认证 (2FA)

### 2.1 触发条件

用户启用 2FA 后，`auth.signIn` 返回错误：
```
SESSION_PASSWORD_NEEDED
```

### 2.2 2FA 流程

```
┌─────────────────┐     ┌───────────────────┐
│ 输入验证码       │ →   │ SESSION_PASSWORD  │
│ auth.signIn     │     │ _NEEDED 错误       │
└─────────────────┘     └───────────────────┘
                                │
                                ▼
┌─────────────────┐     ┌───────────────────┐
│ 完成 2FA 登录    │ ←   │ 用户输入 2FA 密码   │
│ auth.checkPassword    │ (SRP 协议加密)     │
└─────────────────┘     └───────────────────┘
```

### 2.3 SRP 协议

Telegram 使用 **SRP (Secure Remote Password)** 协议：
- 密码**不以明文传输**
- 服务端存储密码哈希的验证器
- 客户端使用密码生成证明，服务端验证

相关 API：
- `account.getPassword` - 获取 2FA 配置
- `auth.checkPassword` - 验证密码
- `account.updatePasswordSettings` - 设置/修改密码

---

## 3. 更新机制 (Updates)

### 3.1 概述

Telegram 使用**长连接推送**通知客户端事件，而非轮询。

### 3.2 常见更新类型

| 更新 | 说明 |
|------|------|
| `updateNewMessage` | 收到新消息 |
| `updateMessageID` | 临时消息 ID → 正式 ID |
| `updateDeleteMessages` | 消息被删除 |
| `updateUserTyping` | 对方正在输入 |
| `updateUserStatus` | 用户在线/离线状态 |
| `updateChatParticipants` | 群成员变化 |
| `updateReadHistoryInbox` | 消息被对方已读 |

### 3.3 pts 机制（防丢失）

每个更新携带 `pts`（序列号），用于检测是否有遗漏：

```java
// 伪代码
int local_pts = 131;  // 本地存储

// 收到更新: pts = 132, pts_count = 1
if (local_pts + pts_count == pts) {
    // 正常应用更新
    local_pts = pts;
} else if (local_pts + pts_count < pts) {
    // 有遗漏! 调用 getDifference 补齐
    callGetDifference();
} else {
    // 重复更新，忽略
}
```

### 3.4 获取遗漏更新

```
updates.getDifference(pts, date, qts)
```
返回自 `pts` 以来的所有更新。

---

## 4. 端对端加密 (Secret Chat)

### 4.1 概述

Secret Chat 使用 **MTProto 2.0** 端对端加密，**服务端无法解密**。

### 4.2 加密参数

| 参数 | 值 |
|------|-----|
| 对称加密 | AES-256-IGE |
| 哈希算法 | SHA-256 |
| 密钥交换 | Diffie-Hellman |
| 前向安全 | 支持 PFS |

### 4.3 与普通聊天对比

| 对比项 | 普通聊天 | Secret Chat |
|-------|---------|------------|
| 加密方式 | 客户端-服务端 | 端对端 |
| 服务端解密 | ✅ 能 | ❌ 不能 |
| 多设备同步 | ✅ 支持 | ❌ 仅单设备 |
| 云端存储 | ✅ 有 | ❌ 无 |
| 消息撤回 | 仅撤回自己 | 双方同时删除 |
| 截图通知 | ❌ 无 | ✅ 有 |

### 4.4 密钥生成流程

```
1. A 调用 messages.requestEncryption 发起加密聊天请求
2. B 收到 updateEncryption
3. B 调用 messages.acceptEncryption 接受请求
4. 双方使用 DH 算法计算共享密钥
5. 显示密钥可视化图案供用户验证
```

---

## 5. 频道与群组 (Channels & Groups)

### 5.1 类型对比

| 类型 | 技术标识 | 成员上限 | 发言权限 | 用途 |
|------|----------|---------|---------|------|
| **频道** | `channel` (broadcast) | 无限 | 仅管理员 | 广播/公告 |
| **超级群** | `channel` (megagroup) | 200,000 | 所有成员 | 社区讨论 |
| **巨型群** | `channel` (gigagroup) | 无限 | 仅管理员 | 超大型社区 |
| **普通群** | `chat` | 200 | 所有成员 | 小型群聊 |

### 5.2 技术实现细节

```javascript
// 判断类型
if (chat.broadcast) {
    // 频道
} else if (chat.megagroup) {
    if (chat.gigagroup) {
        // 巨型群
    } else {
        // 超级群
    }
} else {
    // 普通群
}
```

### 5.3 权限系统

频道/超级群使用 `chatAdminRights` 和 `chatBannedRights` 管理权限：

**管理员权限 (chatAdminRights)**:
- `change_info` - 修改群信息
- `post_messages` - 发送消息（仅频道）
- `delete_messages` - 删除消息
- `ban_users` - 封禁用户
- `invite_users` - 邀请用户
- `pin_messages` - 置顶消息
- `add_admins` - 添加管理员

**成员限制 (chatBannedRights)**:
- `send_messages` - 禁止发消息
- `send_media` - 禁止发媒体
- `send_stickers` - 禁止发贴纸
- `embed_links` - 禁止链接预览

---

## 6. 文件传输

### 6.1 上传流程

大文件分块上传：

```
1. 计算文件 MD5
2. 分块（每块最大 512KB）
3. 逐块调用 upload.saveFilePart
4. 所有块上传完成后，获得 file_id
5. 发送消息时使用 file_id
```

### 6.2 下载流程

```
1. 从消息中获取 file_id 和 file_reference
2. 调用 upload.getFile 下载
3. 支持断点续传（指定 offset）
```

### 6.3 CDN 加速

Telegram 对热门文件使用 CDN：
- `upload.getFile` 可能返回 `upload.fileCdnRedirect`
- 需要从 CDN 节点下载
- 下载后需验证哈希

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-01-30 | 初始版本，整理自 Telegram 官方文档 |
