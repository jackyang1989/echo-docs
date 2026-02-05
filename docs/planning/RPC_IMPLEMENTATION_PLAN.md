# RPC 补齐实施计划

**项目关联**:
- **所属阶段**: Week 2-4 (P0 核心功能补完) & Week 5-8 (P1 基础功能)
- **父级文档**: `/Users/jianouyang/Project/echo/ECHO执行方案-精简版.md`
- **合规性**: 符合 `ECHO_AUTHORITY_CONSTRAINTS.md` (SSOT, Correctness)

**当前状态**: Gateway 实现 37 个 RPC，客户端需要 200+ 个
**创建日期**: 2026-02-05

---

## 📅 项目阶段映射 (Plan Alignment)

| RPC Phase | 功能范围 | 对应项目阶段 | 优先级 |
|-----------|---------|-------------|--------|
| **Phase 1** (Login Init) | 初始化必需 RPC (Messages/Account) | **Week 2-4 (P0 Fix)** | **Urgent** |
| **Phase 2** (Basic Settings) | 账号设置 (Profile/Privacy) | **Week 2-4 (P0 Fix)** | **High** |
| **Phase 3** (Chat Enhanced) | 搜索、媒体、置顶 | **Week 5-8 (P1)** | Medium |
| **Phase 4** (Group) | 群聊管理 | **Week 5-8 (P1)** | Medium |
| **Phase 5** (Channel) | 频道管理 | **Week 5-8 (P1)** | Medium |
| **Phase 6** (Security) | 高级安全设置 | **Week 9+ (P2)** | Low |

---

## 📊 当前实现状态

| 模块 | 客户端需要 | 已实现 | 覆盖率 |
|------|-----------|--------|--------|
| **Messages** | ~50 | 9 | 18% |
| **Channels** | ~20 | 0 | 0% |
| **Account** | ~140 | 4 | 3% |
| **Contacts** | ~15 | 3 | 20% |
| **Users** | 4 | 2 | 50% |
| **Updates** | 4 | 2 | 50% |
| **Help** | ~15 | 4 | 27% |
| **Photos** | 6 | 0 | 0% |

---

## 🎯 Phase 1: 登录后初始化必需（P0-Urgent）

> [!IMPORTANT]
> 这些 RPC 在登录成功后**立即被调用**，缺失会导致 UI 无法正常加载

### 1.1 Messages 模块补齐

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.getPeerDialogs` | 获取对等对话详情 | 中 |
| `messages.getPeerSettings` | 获取对等设置 | 低 |
| `messages.getPinnedDialogs` | 获取置顶对话 | 中 |
| `messages.getMessages` | 获取指定消息 | 中 |
| `messages.getDialogFilters` | 获取对话过滤器/文件夹 | 低 |
| `messages.getDialogUnreadMarks` | 获取未读标记 | 低 |

### 1.2 Account 模块补齐

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `account.getPassword` | 获取密码设置状态 | 低 |
| `account.getGlobalPrivacySettings` | 获取全局隐私设置 | 低 |
| `account.getContentSettings` | 获取内容设置 | 低 |
| `account.getContactSignUpNotification` | 获取联系人注册通知设置 | 低 |
| `account.registerDevice` | 注册设备（推送通知必需） | 中 |

### 1.3 Contacts 模块补齐

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `contacts.getStatuses` | 获取联系人在线状态 | 低 |
| `contacts.getTopPeers` | 获取常用联系人 | 低 |
| `contacts.resolveUsername` | 解析用户名 | 中 |
| `contacts.getBlocked` | 获取黑名单 | 低 |

---

## 🚀 Phase 2: 基础设置功能（P0-Core）

> 用户点击设置页面时调用的 RPC

### 2.1 个人资料设置

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `account.updateProfile` | 更新个人资料（姓名、简介） | 低 |
| `account.updateUsername` | 更新用户名 | 低 |
| `account.checkUsername` | 检查用户名可用性 | 低 |
| `account.updateStatus` | 更新在线状态 | 低 |
| `photos.uploadProfilePhoto` | 上传头像 | 高 |
| `photos.updateProfilePhoto` | 更新头像 | 中 |
| `photos.getUserPhotos` | 获取用户照片 | 低 |
| `photos.deletePhotos` | 删除照片 | 低 |

### 2.2 隐私设置

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `account.setPrivacy` | 设置隐私规则 | 中 |
| `account.setGlobalPrivacySettings` | 设置全局隐私 | 低 |

### 2.3 通知设置

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `account.updateNotifySettings` | 更新通知设置 | 低 |
| `account.resetNotifySettings` | 重置通知设置 | 低 |
| `account.getNotifyExceptions` | 获取通知例外 | 低 |

---

## 💬 Phase 3: 聊天增强功能（P1）

### 3.1 消息操作

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.search` | 搜索消息 | 高 |
| `messages.searchGlobal` | 全局搜索 | 高 |
| `messages.forwardMessages` | 转发消息 | 中 |
| `messages.editMessage` | 编辑消息 | 中 |
| `messages.sendMedia` | 发送媒体消息 | 高 |
| `messages.uploadMedia` | 上传媒体 | 高 |
| `messages.setTyping` | 设置输入状态 | 低 |

### 3.2 对话管理

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.toggleDialogPin` | 切换对话置顶 | 低 |
| `messages.markDialogUnread` | 标记对话未读 | 低 |
| `messages.reorderPinnedDialogs` | 重排置顶对话 | 低 |
| `messages.deleteHistory` | 删除历史 | 中 |
| `messages.updateDialogFilter` | 更新对话过滤器 | 中 |

### 3.3 草稿功能

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.saveDraft` | 保存草稿 | 低 |
| `messages.getAllDrafts` | 获取所有草稿 | 低 |
| `messages.clearAllDrafts` | 清除所有草稿 | 低 |

---

## 👥 Phase 4: 群聊功能（P1）

### 4.1 基础群聊

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.createChat` | 创建群聊 | 中 |
| `messages.addChatUser` | 添加群成员 | 中 |
| `messages.deleteChatUser` | 删除群成员 | 中 |
| `messages.editChatTitle` | 编辑群标题 | 低 |
| `messages.editChatPhoto` | 编辑群头像 | 中 |
| `messages.editChatAdmin` | 编辑群管理员 | 中 |
| `messages.getFullChat` | 获取群完整信息 | 中 |
| `messages.getChats` | 获取群列表 | 低 |

### 4.2 群邀请

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `messages.exportChatInvite` | 导出群邀请链接 | 中 |
| `messages.checkChatInvite` | 检查邀请链接 | 低 |
| `messages.importChatInvite` | 通过邀请链接加入 | 中 |

---

## 📢 Phase 5: 频道功能（P1）

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `channels.getChannels` | 获取频道列表 | 低 |
| `channels.getFullChannel` | 获取频道完整信息 | 中 |
| `channels.getParticipants` | 获取成员列表 | 中 |
| `channels.getMessages` | 获取频道消息 | 中 |
| `channels.readHistory` | 读取频道历史 | 低 |
| `channels.joinChannel` | 加入频道 | 中 |
| `channels.leaveChannel` | 离开频道 | 低 |
| `channels.createChannel` | 创建频道 | 中 |
| `channels.editAdmin` | 编辑管理员 | 中 |
| `channels.editBanned` | 编辑封禁 | 中 |
| `channels.deleteChannel` | 删除频道 | 中 |
| `updates.getChannelDifference` | 频道同步 | 高 |

---

## 🔐 Phase 6: 安全与账号管理（P2）

| RPC | 功能 | 复杂度 |
|-----|------|--------|
| `account.getPassword` | 获取两步验证状态 | 低 |
| `account.updatePasswordSettings` | 更新密码设置 | 高 |
| `account.changePhone` | 更换手机号 | 高 |
| `account.deleteAccount` | 删除账号 | 中 |
| `account.getAccountTTL` | 获取账号有效期 | 低 |
| `account.setAccountTTL` | 设置账号有效期 | 低 |
| `account.resetAuthorization` | 撤销会话 | 中 |
| `account.setAuthorizationTTL` | 设置会话有效期 | 低 |
| `auth.resetAuthorizations` | 撤销所有会话 | 中 |

---

## 📅 实施时间线

| Phase | 预计时间 | RPC 数量 | 优先级 |
|-------|---------|---------|--------|
| Phase 1 | 3-4 天 | 16 | P0-Urgent |
| Phase 2 | 2-3 天 | 14 | P0-Core |
| Phase 3 | 4-5 天 | 15 | P1 |
| Phase 4 | 3-4 天 | 11 | P1 |
| Phase 5 | 4-5 天 | 12 | P1 |
| Phase 6 | 2-3 天 | 9 | P2 |

**总计**: 约 18-24 天完成核心 RPC 补齐（77 个 RPC）

---

## 🔧 实现建议

### Stub 模式（快速启用 UI）

对于非核心功能，可以先返回空响应让 UI 正常显示：

```go
case *mtproto.TLAccountUpdateProfile:
    // TODO: 实现真实逻辑
    return &mtproto.User{
        Id: ctx.userID,
        // 返回现有用户数据
    }, nil
```

### 优先级判断标准

1. **P0-Urgent**: 缺失会导致 APP 无法正常启动/崩溃
2. **P0-Core**: 缺失会导致核心功能（聊天/设置）无法使用
3. **P1**: 缺失会导致功能入口不可用但不影响基础使用
4. **P2**: 增强功能，可延后实现

---

**最后更新**: 2026-02-05  
**状态**: 待执行
