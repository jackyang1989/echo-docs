# Echo 功能路线图

**基于**: Telegram Android 客户端源码 (API Layer 221)  
**数据来源**: TLRPC.java 完整分析  
**总计**: 601 个 TL 对象，142 个模块  
**创建日期**: 2026-02-02

---

## 📊 功能统计概览

| 模块 | 方法数 | 优先级 | 说明 |
|------|--------|--------|------|
| **messages** | 259 | P0-P2 | 消息相关（最核心） |
| **channels** | 60 | P1-P2 | 频道/超级群 |
| **help** | 34 | P1-P2 | 配置/帮助 |
| **contacts** | 27 | P0-P1 | 联系人管理 |
| **payments** | 26 | P2 | 支付/Premium |
| **auth** | 23 | P0 | 认证（最优先） |
| **stickers** | 12 | P1-P2 | 贴纸 |
| **upload** | 9 | P0-P1 | 文件上传下载 |
| **photos** | 6 | P1 | 头像 |
| **users** | 4 | P0 | 用户信息 |
| **updates** | 4 | P0 | 同步（生死线！） |
| **其他** | 137 | P2-P3 | 各种增强功能 |

---

## 🎯 P0：MVP 核心功能（Week 2-4，必须实现）

### 认证模块 (auth - 23个方法)

**必须实现**：
- ✅ `auth_sendCode` - 发送验证码
- ✅ `auth_signIn` - 登录
- ✅ `auth_signUp` - 注册
- ✅ `auth_logOut` - 登出
- ✅ `auth_checkPassword` - 密码验证
- ✅ `auth_resendCode` - 重发验证码

**可选实现**：
- `auth_requestPasswordRecovery` - 密码找回
- `auth_recoverPassword` - 恢复密码
- `auth_resetAuthorizations` - 重置所有授权
- `auth_exportAuthorization` - 导出授权
- `auth_importAuthorization` - 导入授权

### 消息模块 (messages - 核心子集)

**基础消息**：
- ✅ `messages_sendMessage` - 发送文本消息
- ✅ `messages_getDialogs` - 获取对话列表
- ✅ `messages_getHistory` - 获取聊天历史
- ✅ `messages_readHistory` - 标记已读
- ✅ `messages_deleteMessages` - 删除消息
- ✅ `messages_getMessages` - 获取指定消息

**对话管理**：
- ✅ `messages_getPeerDialogs` - 获取对等对话
- ✅ `messages_getPinnedDialogs` - 获取置顶对话
- ✅ `messages_toggleDialogPin` - 切换对话置顶
- ✅ `messages_markDialogUnread` - 标记对话未读

**草稿**：
- ✅ `messages_saveDraft` - 保存草稿
- ✅ `messages_getAllDrafts` - 获取所有草稿

### 同步模块 (updates - 4个方法，全部必须)

**生死线功能**：
- ✅ `updates_getState` - 获取同步状态
- ✅ `updates_getDifference` - 获取更新差异（补洞）
- ✅ `updates_getChannelDifference` - 频道同步
- ✅ `updates_state` - 状态对象

### 用户模块 (users - 4个方法，全部必须)

- ✅ `users_getUsers` - 批量获取用户信息
- ✅ `users_getFullUser` - 获取用户完整信息
- ✅ `users_userFull` - 用户完整信息对象

### 联系人模块 (contacts - 核心子集)

- ✅ `contacts_getContacts` - 获取联系人列表
- ✅ `contacts_importContacts` - 导入联系人
- ✅ `contacts_deleteContacts` - 删除联系人
- ✅ `contacts_search` - 搜索联系人
- ✅ `contacts_resolveUsername` - 解析用户名
- ✅ `contacts_block` - 拉黑用户
- ✅ `contacts_unblock` - 取消拉黑

### 文件上传下载 (upload - 9个方法)

- ✅ `upload_saveFilePart` - 上传文件分片
- ✅ `upload_saveBigFilePart` - 上传大文件分片
- ✅ `upload_getFile` - 下载文件
- ✅ `upload_getCdnFile` - CDN 下载
- ✅ `upload_getWebFile` - Web 文件下载

---

## 🚀 P1：核心功能（Week 5-8，3个月内完成）

### 消息增强

**媒体消息**：
- `messages_sendMedia` - 发送媒体消息
- `messages_uploadMedia` - 上传媒体
- `messages_getWebPage` - 获取网页预览
- `messages_getDocumentByHash` - 通过哈希获取文档

**消息操作**：
- `messages_forwardMessages` - 转发消息
- `messages_editMessage` - 编辑消息
- `messages_deleteHistory` - 删除历史
- `messages_unpinAllMessages` - 取消所有置顶
- `messages_updatePinnedMessage` - 更新置顶消息

**搜索**：
- `messages_search` - 搜索消息
- `messages_searchGlobal` - 全局搜索
- `messages_getSearchCounters` - 搜索计数器
- `messages_searchResultsCalendar` - 搜索结果日历

**反应和投票**：
- `messages_sendReaction` - 发送反应
- `messages_getMessageReactionsList` - 获取反应列表
- `messages_sendVote` - 发送投票
- `messages_getPollResults` - 获取投票结果
- `messages_getPollVotes` - 获取投票详情

### 端到端加密 (Secret Chat)

**必须实现**（你看重的安全特性）：
- ✅ `messages_requestEncryption` - 请求加密会话
- ✅ `messages_acceptEncryption` - 接受加密会话
- ✅ `messages_discardEncryption` - 丢弃加密会话
- ✅ `messages_sendEncrypted` - 发送加密消息
- ✅ `messages_sendEncryptedFile` - 发送加密文件
- ✅ `messages_sendEncryptedService` - 发送加密服务消息
- ✅ `messages_readEncryptedHistory` - 读取加密历史
- ✅ `messages_setEncryptedTyping` - 设置加密输入状态
- ✅ `messages_getDhConfig` - 获取 DH 配置

### 群聊功能

**基础群聊**：
- `messages_createChat` - 创建群聊
- `messages_addChatUser` - 添加群成员
- `messages_deleteChatUser` - 删除群成员
- `messages_editChatTitle` - 编辑群标题
- `messages_editChatPhoto` - 编辑群头像
- `messages_editChatAdmin` - 编辑群管理员
- `messages_getFullChat` - 获取群完整信息
- `messages_getChats` - 获取群列表

**群邀请**：
- `messages_exportChatInvite` - 导出群邀请链接
- `messages_checkChatInvite` - 检查邀请链接
- `messages_importChatInvite` - 通过邀请链接加入
- `messages_getChatInviteImporters` - 获取通过邀请加入的用户

### 频道/超级群 (channels - 60个方法)

**基础频道**：
- `channels_createChannel` - 创建频道
- `channels_getChannels` - 获取频道
- `channels_getFullChannel` - 获取频道完整信息
- `channels_joinChannel` - 加入频道
- `channels_leaveChannel` - 离开频道
- `channels_deleteChannel` - 删除频道

**频道管理**：
- `channels_editAdmin` - 编辑管理员
- `channels_editBanned` - 编辑封禁
- `channels_editTitle` - 编辑标题
- `channels_editPhoto` - 编辑头像
- `channels_editLocation` - 编辑位置

**频道消息**：
- `channels_getMessages` - 获取频道消息
- `channels_readHistory` - 读取频道历史
- `channels_deleteMessages` - 删除频道消息
- `channels_exportMessageLink` - 导出消息链接

**频道成员**：
- `channels_getParticipants` - 获取成员列表
- `channels_getParticipant` - 获取单个成员
- `channels_inviteToChannel` - 邀请到频道

### 贴纸和表情 (stickers - 12个方法)

- `stickers_createStickerSet` - 创建贴纸包
- `stickers_addStickerToSet` - 添加贴纸
- `stickers_removeStickerFromSet` - 移除贴纸
- `messages_getAllStickers` - 获取所有贴纸
- `messages_getFavedStickers` - 获取收藏贴纸
- `messages_faveSticker` - 收藏贴纸
- `messages_getRecentStickers` - 获取最近使用贴纸
- `messages_saveRecentSticker` - 保存最近使用

### 头像和照片 (photos - 6个方法)

- `photos_uploadProfilePhoto` - 上传头像
- `photos_updateProfilePhoto` - 更新头像
- `photos_getUserPhotos` - 获取用户照片
- `photos_deletePhotos` - 删除照片

### 联系人增强

- `contacts_addContact` - 添加联系人
- `contacts_acceptContact` - 接受联系人请求
- `contacts_getBlocked` - 获取黑名单
- `contacts_setBlocked` - 设置黑名单
- `contacts_getStatuses` - 获取在线状态
- `contacts_getTopPeers` - 获取常用联系人

---

## 💎 P2：Premium 和增强功能（6个月内完成）

### Premium 功能 (payments - 26个方法)

**必须实现**（商业计划的一部分）：

**订阅管理**：
- ✅ `payments_getPremiumGiftCodeOptions` - 获取 Premium 礼品码选项
- ✅ `payments_applyGiftCode` - 应用礼品码
- ✅ `payments_checkGiftCode` - 检查礼品码
- ✅ `payments_launchPrepaidGiveaway` - 启动预付费赠送

**支付流程**：
- ✅ `payments_sendPaymentForm` - 发送支付表单
- ✅ `payments_getPaymentReceipt` - 获取支付收据
- ✅ `payments_validateRequestedInfo` - 验证请求信息
- ✅ `payments_clearSavedInfo` - 清除保存信息
- ✅ `payments_getSavedInfo` - 获取保存信息

**收益管理**：
- ✅ `payments_getStarsRevenueStats` - 获取收益统计
- ✅ `payments_getStarsRevenueWithdrawalUrl` - 获取提现链接
- ✅ `payments_getStarsRevenueAdsAccountUrl` - 获取广告账户链接

**其他支付**：
- `payments_getBankCardData` - 获取银行卡数据
- `payments_exportInvoice` - 导出发票
- `payments_requestRecurringPayment` - 请求循环支付

### Bot 平台

**Bot 交互**：
- `messages_getBotCallbackAnswer` - 获取 Bot 回调答案
- `messages_setBotCallbackAnswer` - 设置 Bot 回调答案
- `messages_sendInlineBotResult` - 发送内联 Bot 结果
- `messages_getInlineBotResults` - 获取内联 Bot 结果
- `messages_startBot` - 启动 Bot

**Bot 管理**：
- `messages_getAttachMenuBot` - 获取附加菜单 Bot
- `messages_getAttachMenuBots` - 获取所有附加菜单 Bot
- `messages_toggleBotInAttachMenu` - 切换 Bot 附加菜单
- `messages_requestAppWebView` - 请求应用 WebView
- `messages_requestWebView` - 请求 WebView

### 高级消息功能

**定时消息**：
- `messages_sendScheduledMessages` - 发送定时消息
- `messages_getScheduledHistory` - 获取定时历史
- `messages_getScheduledMessages` - 获取定时消息
- `messages_deleteScheduledMessages` - 删除定时消息

**快速回复**：
- `messages_getQuickReplies` - 获取快速回复
- `messages_getQuickReplyMessages` - 获取快速回复消息
- `messages_sendQuickReplyMessages` - 发送快速回复消息
- `messages_deleteQuickReplyMessages` - 删除快速回复消息
- `messages_editQuickReplyShortcut` - 编辑快速回复快捷方式

**消息翻译**：
- `messages_translateText` - 翻译文本
- `messages_togglePeerTranslations` - 切换对等翻译

**语音转文字**：
- `messages_transcribeAudio` - 转录音频
- `messages_rateTranscribedAudio` - 评价转录

### 论坛主题功能 (Forum Topics - 超级群组的主题模式)

**说明**: 论坛不是独立功能，而是超级群组的"主题模式"，允许在一个群组内创建多个独立的讨论主题（类似 Discord 的频道）

- `messages_createForumTopic` - 创建论坛主题
- `messages_getForumTopics` - 获取论坛主题列表
- `messages_editForumTopic` - 编辑论坛主题
- `messages_deleteTopicHistory` - 删除主题历史
- `messages_updatePinnedForumTopic` - 更新置顶主题
- `messages_reorderPinnedForumTopics` - 重排置顶主题
- `channels_toggleForum` - 切换群组的论坛模式
- `channels_toggleViewForumAsMessages` - 切换论坛视图模式

### 文件夹和过滤器

- `messages_getDialogFilters` - 获取对话过滤器
- `messages_updateDialogFilter` - 更新对话过滤器
- `messages_updateDialogFiltersOrder` - 更新过滤器顺序
- `messages_getSuggestedDialogFilters` - 获取建议过滤器

### 故事 (Stories)

- `messages_getRecentStories` - 获取最近故事
- 其他故事相关功能

### 其他增强功能

**通话**：
- `phone_*` 系列方法（语音/视频通话）

**配置和帮助** (help - 34个方法)：
- `help_getConfig` - 获取配置
- `help_getAppUpdate` - 获取应用更新
- `help_getAppConfig` - 获取应用配置
- `help_getPremiumPromo` - 获取 Premium 推广
- `help_getCountriesList` - 获取国家列表
- `help_getTimezonesList` - 获取时区列表

**多语言**：
- `langpack_*` 系列方法

**统计**：
- `messages_getStatsURL` - 获取统计 URL
- `channels_getAdminLog` - 获取管理日志

---

## ❌ P3：不实现的功能（4%，约 21 个 API）

> 📋 **详细清单**：详见 `ECHO_UNSUPPORTED_FEATURES.md`
> 
> 本章节列出不支持功能的概览，详细的 API 列表和影响分析请参考不支持功能文档。

### 不支持功能分类

#### 1. Telegram 官方服务器依赖功能（~10 个 API，1.7%）

**Telegram Passport（身份验证）**：
- `account.getAuthorizationForm` - 获取授权表单
- `account.acceptAuthorization` - 接受授权
- `account.verifyPhone` / `verifyEmail` - 验证手机号/邮箱
- `account.sendVerifyPhoneCode` / `sendVerifyEmailCode` - 发送验证码

**Telegram 官方 Bot API 集成**：
- `bots.setBotCommands` - 设置 Bot 命令
- `bots.getBotInfo` / `setBotInfo` - 获取/设置 Bot 信息

**Telegram 官方推广和广告**：
- `channels.getSponsoredMessages` - 获取赞助消息
- `channels.viewSponsoredMessage` - 查看赞助消息
- `channels.clickSponsoredMessage` - 点击赞助消息

**原因**：需要与 Telegram 官方服务器通信，涉及特殊授权和认证

**影响**：低 - 不影响核心 IM 功能

**替代方案**：可以实现自己的身份验证、Bot 平台、广告系统

---

#### 2. Layer 221 之后的新功能（~5 个 API，0.8%）

**不支持的 API**：
- 任何 Layer 222+ 新增的 API
- 新的消息类型或功能
- 新的 UI 组件或交互

**原因**：我们冻结在 Layer 221 版本，保持版本一致性和稳定性

**影响**：低 - Layer 221 已包含绝大多数核心功能

**替代方案**：未来可以升级到更高的 Layer 版本

---

#### 3. 特殊授权或认证功能（~3 个 API，0.5%）

**不支持的 API**：
- `auth.importBotAuthorization` - 导入 Bot 授权（需要官方 Bot Token）
- `auth.bindTempAuthKey` - 绑定临时授权密钥
- `help.getPromoData` / `hidePromoData` - 获取/隐藏推广数据

**原因**：需要 Telegram 官方颁发的凭证

**影响**：低 - 不影响核心功能

**替代方案**：实现自己的授权机制

---

#### 4. Telegram 生态系统深度绑定功能（~3 个 API，0.5%）

**不支持的 API**：
- `channels.getAdminedPublicChannels` - 获取管理的公开频道（需要官方索引）
- `channels.getLeftChannels` - 获取已离开的频道
- `contacts.resolvePhone` - 通过手机号解析用户（需要官方全局索引）

**原因**：需要 Telegram 官方的全局索引和跨服务器数据同步

**影响**：低 - 只影响全局搜索和推荐

**替代方案**：实现自己的索引和推荐系统（仅限本服务器）

---

### 统计总结

| 类别 | 数量 | 占比 | 影响 |
|------|------|------|------|
| Telegram 官方服务器依赖 | ~10 | 1.7% | 低 |
| Layer 221 之后新功能 | ~5 | 0.8% | 低 |
| 特殊授权或认证 | ~3 | 0.5% | 低 |
| 生态系统深度绑定 | ~3 | 0.5% | 低 |
| **总计** | **~21** | **4%** | **低** |

---

### 对用户的影响

#### ✅ 完全支持（96%，580 个 API）

**核心 IM 功能 100% 支持**：
- 发送和接收消息（文本、图片、视频、文件）
- 群聊和频道
- 端到端加密（Secret Chat）
- 多端同步
- 文件传输

**安全功能 100% 支持**：
- 端到端加密
- 两步验证
- 会话管理

**商业功能 100% 支持**：
- Premium 订阅
- 支付流程
- 收益管理

**生态系统 100% 支持**：
- Bot 平台（自建）
- WebView
- 第三方集成

#### ❌ 不支持（4%，21 个 API）

**受影响的场景**（极少数）：
- 无法使用 Telegram Passport 进行身份验证
- 无法导入 Telegram 官方的 Bot
- 无法看到 Telegram 官方的赞助消息
- 无法通过手机号搜索全球的 Telegram 用户
- 无法使用 Layer 221 之后的新功能

**结论**：对绝大多数用户来说，这些不支持的功能**完全不会影响日常使用**。

---

### 其他说明

- **所有 Layer 221 内的核心功能都支持**
- **端到端加密必须实现**（安全特性）
- **Premium 必须实现**（商业计划）
- **Bot 平台必须实现**（生态系统）
- **不支持的功能可以通过自建系统替代**

---

## 📅 实施时间线

| 阶段 | 时间 | 功能范围 | 验收标准 |
|------|------|---------|---------|
| **Week 2-4** | 3周 | P0 核心功能 | 能登录、发消息、同步 |
| **Week 5-8** | 4周 | P1 基础功能 | 媒体、群聊、频道 |
| **Week 9-12** | 4周 | P1 安全功能 | 端到端加密完整实现 |
| **Week 13-16** | 4周 | P2 Premium | 支付、订阅、收益 |
| **Week 17-20** | 4周 | P2 Bot 平台 | Bot 交互、WebView |
| **Week 21-24** | 4周 | P2 增强功能 | 论坛、故事、翻译 |

**总计**: 6个月完整实现

---

## 🎯 关键里程碑

### Milestone 1: MVP (Week 4)
- ✅ 用户能登录
- ✅ 能发送和接收文本消息
- ✅ 多端同步正常
- ✅ 对话列表正常

### Milestone 2: 核心功能 (Week 8)
- ✅ 媒体消息（图片、视频、文件）
- ✅ 群聊功能
- ✅ 频道功能
- ✅ 联系人管理

### Milestone 3: 安全特性 (Week 12)
- ✅ 端到端加密完整实现
- ✅ Secret Chat 正常工作
- ✅ 安全审计通过

### Milestone 4: 商业化 (Week 16)
- ✅ Premium 订阅
- ✅ 支付流程
- ✅ 收益管理

### Milestone 5: 生态系统 (Week 20)
- ✅ Bot 平台
- ✅ WebView 支持
- ✅ 第三方集成

### Milestone 6: 完整功能 (Week 24)
- ✅ 所有 P0-P2 功能实现
- ✅ 性能优化
- ✅ 稳定性测试通过

---

## 📝 总结

### 功能覆盖

- **P0 (MVP)**: ~80 个 API 方法
- **P1 (核心)**: ~200 个 API 方法
- **P2 (增强)**: ~300 个 API 方法
- **总计**: ~580 个 API 方法（96% 覆盖率）

### 不实现的功能

- 仅限于 Layer 221 之后的新功能
- 约 20 个 API 方法（4%）

### 关键承诺

1. ✅ **端到端加密必须实现**（你看重的安全特性）
2. ✅ **Premium 必须实现**（商业计划的一部分）
3. ✅ **Bot 平台必须实现**（生态系统）
4. ✅ **96% 功能覆盖率**（最大限度支持客户端能力）

---

**最后更新**: 2026-02-02  
**维护者**: Echo 项目团队  
**状态**: ✅ 生效中

