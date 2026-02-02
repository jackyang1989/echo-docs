# Echo · 广场功能设计

**日期**: 2026-01-28  
**版本**: 1.0  
**优先级**: P2（运营扩展）

---

## 🎯 核心定位

### 三层架构

```
广场 (Square)     = 公共表达层 (Public Broadcast)
群/频道 (Spaces)  = 主题空间 (Themed Spaces)
私聊 (IM)         = 私密关系 (Private Messaging)
```

### 核心原则

1. **公开与私密不冲突** - 公开内容必须是"用户主动公开"
2. **群内容默认不公开** - 需要群主/频道主主动开启同步
3. **评论是"回应表达"，不是"争夺话语权"** - 单层评论，无盖楼，无热评
4. **不做曝光竞技场** - 不以粉丝数作为主要分发逻辑
5. **沉淀优先** - 核心 KPI 是收藏率、转发率、回流率，而非点赞数

---

## 📊 功能优先级总览

### 🟥 P0 - 最小可用版本（没有这些就不成立）

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 1 | 发布 | 个人广播 | 直接发布到广场 |
| 2 | 发布 | 群/频道同步 | 可选同步到广场 |
| 3 | 信息流 | 推荐流 | 默认信息流 |
| 4 | 信息流 | 最新流 | 纯时间线 |
| 5 | 互动 | 点赞/收藏/转发 | 基础互动 |
| 6 | 互动 | 举报 | 治理底座 |
| 7 | 来源标识 | Context Tag | 清晰显示来源 |
| 8 | 治理 | 拉黑/屏蔽 | 用户侧控制 |

### 🟧 P1 - 体验增强（开始"好用、耐用"）

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 9 | 内容控制 | 不感兴趣 | 降低相似内容 |
| 10 | 浏览发现 | 最新/热门切换 | 弱算法 |
| 11 | 互动 | 轻评论 | 单层评论，无盖楼 |
| 12 | 回流 | 广场↔群 | 去群里讨论 |
| 13 | 个人页 | 公开内容展示 | 克制但可用 |

### 🟨 P2 - 规模后再加

| # | 模块 | 功能 | 说明 |
|---|------|------|------|
| 14 | 推荐 | 多语言/地区化 | 本地化推荐 |
| 15 | 创作者工具 | 数据面板 | 曝光、互动统计 |
| 16 | 高级治理 | 信誉分/反刷 | 防刷赞/搬运 |
| 17 | 高级发现 | 相似推荐 | 冷启动探索 |

---

## 🟥 P0 功能详细设计

### 1️⃣ 发布 - 两种并列路径

#### A. 个人广播（默认）

**发布入口**:
```typescript
interface PersonalBroadcast {
  // 内容
  contentType: 'text' | 'image' | 'video' | 'mixed';
  text?: string;                // 最多 5000 字
  images?: string[];            // 最多 9 张
  video?: string;               // 单个视频
  
  // 草稿
  isDraft: boolean;
  draftId?: string;
  
  // 来源标识
  source: 'personal';           // 固定为 personal
}
```

**操作功能**:
- 发布到广场
- 保存草稿
- 删除自己的内容
- 轻编辑（限时修错字，保留编辑标记）

**限制**:
- 新用户冷却期（24小时内不能发布）
- 频率限制（每小时最多 5 条）
- 内容审核（敏感词过滤）


#### B. 群/频道同步（可选来源）

**前提条件**:
- 群/频道开启「允许同步到广场」
- 用户在发布时主动勾选「同步到广场」

**同步内容**:
```typescript
interface ChatSyncContent {
  // 来源信息
  source: 'chat' | 'channel';
  sourceChatId: string;
  sourceChatTitle: string;
  sourceChatUsername?: string;
  
  // 内容（与个人广播相同）
  contentType: 'text' | 'image' | 'video' | 'mixed';
  text?: string;
  images?: string[];
  video?: string;
  
  // 同步设置
  syncToSquare: boolean;        // 用户主动勾选
  showSourceLink: boolean;      // 显示来源链接
}
```

**来源标识**:
- 清晰显示「来自 ×× 群/频道」
- 点击来源可进入群/频道说明页
- 展示「去群里讨论 / 加入 / 订阅」入口

**限制**:
- 只有群主/管理员可以开启同步
- 同步内容不展示群内连续聊天上下文
- 只展示单条内容（摘要形式）

---

### 2️⃣ 广场信息流 (Feed)

#### 推荐流（默认）

**算法逻辑**:
```typescript
interface RecommendationFeed {
  // 候选源
  candidates: {
    inNetwork: Post[];          // 已加入的群/频道内容
    outNetwork: Post[];         // 全站探索内容
  };
  
  // 过滤规则
  filters: {
    blacklist: string[];        // 黑名单用户/来源
    riskControl: boolean;       // 风控过滤
    deduplication: boolean;     // 去重
    timeDecay: boolean;         // 时间衰减
  };
  
  // 评分因子
  scoringFactors: {
    recency: number;            // 时效性
    likes: number;              // 点赞数
    reposts: number;            // 转发数
    saves: number;              // 收藏数（高权重）
    dwell: number;              // 停留时长
    joinClicks: number;         // 入群点击（仅群内容）
    reports: number;            // 举报数（负权重）
    blocks: number;             // 拉黑数（负权重）
  };
  
  // 多样性约束
  diversity: {
    maxPerAuthor: number;       // 同作者每屏最多 m 条
    maxPerSource: number;       // 同来源每屏最多 n 条
    exploreRatio: number;       // 探索内容占比
  };
}
```

**展示形式**:
- 瀑布流布局
- 图文混排
- 视频自动播放（静音）
- 懒加载

#### 最新流（纯时间线）

**排序规则**:
- 按发布时间倒序
- 不做算法推荐
- 不做热度排序

**用途**:
- 查看最新内容
- 避免算法茧房

---

### 3️⃣ 基础互动 (Engagement)

#### 点赞（公开）

```typescript
interface Like {
  postId: string;
  userId: string;
  likedAt: Date;
  
  // 统计
  likeCount: number;            // 点赞总数
}
```

**特性**:
- 公开可见
- 可取消
- 不显示点赞用户列表（避免社交压力）

#### 收藏（私有）

```typescript
interface Save {
  postId: string;
  userId: string;
  savedAt: Date;
  
  // 收藏夹
  folderId?: string;
  folderName?: string;
}
```

**特性**:
- 私有不可见
- 可分类收藏
- 高权重信号（算法重要指标）


#### 转发/分享

```typescript
interface Repost {
  postId: string;
  userId: string;
  repostType: 'to_square' | 'to_chat' | 'copy_link';
  
  // 转发到广场
  repostToSquare?: {
    comment?: string;           // 转发评论
    repostedAt: Date;
  };
  
  // 转发到群/频道
  repostToChat?: {
    chatId: string;
    chatTitle: string;
    repostedAt: Date;
  };
}
```

**转发类型**:
1. **转发到广场** - 带评论转发
2. **转发到群/频道** - 卡片形式
3. **复制链接** - 分享到外部

#### 举报

```typescript
interface Report {
  postId: string;
  reportedBy: string;
  reason: 'spam' | 'harassment' | 'violence' | 'pornography' | 'illegal' | 'other';
  description?: string;
  reportedAt: Date;
  
  // 处理状态
  status: 'pending' | 'reviewing' | 'resolved' | 'dismissed';
  handledBy?: string;
  handledAt?: Date;
}
```

**举报原因**:
- 垃圾信息
- 骚扰
- 暴力内容
- 色情内容
- 违法信息
- 其他

---

### 4️⃣ Context Tag（来源标识）

#### 来源类型

```typescript
interface SourceTag {
  type: 'personal' | 'chat' | 'channel';
  
  // 个人广播
  personal?: {
    userId: string;
    username: string;
    displayName: string;
  };
  
  // 群/频道同步
  chatOrChannel?: {
    chatId: string;
    chatTitle: string;
    chatUsername?: string;
    chatType: 'group' | 'supergroup' | 'channel';
    memberCount: number;
    description?: string;
  };
}
```

#### 展示形式

**个人广播**:
```
┌─────────────────────────────────┐
│ 👤 @username                    │
│    个人广播                      │
│                                 │
│ [内容]                          │
└─────────────────────────────────┘
```

**群/频道同步**:
```
┌─────────────────────────────────┐
│ 📢 来自 技术交流群               │
│    @tech_chat · 1.2K 成员       │
│    [去群里讨论] [加入群组]       │
│                                 │
│ [内容]                          │
└─────────────────────────────────┘
```

#### 点击来源

**个人广播** → 用户个人页  
**群/频道同步** → 群/频道说明页

**群/频道说明页**:
```typescript
interface ChatInfoPage {
  chatId: string;
  chatTitle: string;
  chatUsername?: string;
  description: string;
  memberCount: number;
  
  // 操作按钮
  actions: {
    join: boolean;              // 加入群组
    subscribe: boolean;         // 订阅频道
    viewInApp: boolean;         // 在应用中查看
  };
  
  // 不强制入群即可浏览
  requireJoin: false;
}
```

---

### 5️⃣ 治理底座 (Safety Baseline)

#### 拉黑用户

```typescript
interface BlockUser {
  blockedUserId: string;
  blockedBy: string;
  blockedAt: Date;
  
  // 效果
  effects: {
    hideSquareContent: boolean; // 不再看到对方广场内容
    hideComments: boolean;      // 不再看到对方评论
    preventInteraction: boolean;// 对方无法与我互动
  };
}
```

#### 屏蔽来源

```typescript
interface BlockSource {
  sourceType: 'chat' | 'channel';
  sourceId: string;
  blockedBy: string;
  blockedAt: Date;
  
  // 效果
  effects: {
    hideSquareContent: boolean; // 不看该群/频道的公开同步内容
    hideRecommendations: boolean;// 不推荐该群/频道
  };
}
```

#### 频控（防刷屏）

```typescript
interface RateLimit {
  // 发帖限制
  postLimit: {
    maxPerHour: number;         // 每小时最多 5 条
    maxPerDay: number;          // 每天最多 20 条
  };
  
  // 转发限制
  repostLimit: {
    maxPerHour: number;         // 每小时最多 10 次
  };
  
  // 评论限制
  commentLimit: {
    maxPerHour: number;         // 每小时最多 30 条
  };
  
  // 新号限制
  newUserRestrictions: {
    cooldownHours: number;      // 冷却期 24 小时
    uploadLimit: boolean;       // 限制上传图片/视频
    linkLimit: boolean;         // 限制外链
  };
}
```

---

## 🟧 P1 功能详细设计

### 6️⃣ 用户侧内容控制

#### 不感兴趣

```typescript
interface NotInterested {
  postId: string;
  userId: string;
  reason?: 'not_relevant' | 'seen_too_much' | 'dont_like_author' | 'other';
  markedAt: Date;
  
  // 效果
  effects: {
    hideThisPost: boolean;      // 隐藏这条内容
    reduceSimilar: boolean;     // 降低相似内容
    reduceSameAuthor: boolean;  // 降低同作者内容
  };
}
```

#### 屏蔽某用户的广场内容

```typescript
interface MuteUserSquare {
  mutedUserId: string;
  mutedBy: string;
  mutedAt: Date;
  
  // 与拉黑的区别
  differences: {
    canStillChat: boolean;      // 仍可私聊
    canStillInGroup: boolean;   // 仍可在同一群
    onlyHideSquare: boolean;    // 只隐藏广场内容
  };
}
```


---

### 7️⃣ 浏览与发现（克制版）

#### 最新 / 热门切换

```typescript
interface FeedMode {
  mode: 'recommended' | 'latest' | 'hot';
  
  // 推荐流（默认）
  recommended: {
    algorithm: 'personalized';
    factors: ['saves', 'reposts', 'dwell', 'joinClicks'];
  };
  
  // 最新流
  latest: {
    sortBy: 'publishedAt';
    order: 'desc';
  };
  
  // 热门流（弱算法）
  hot: {
    timeWindow: '24h' | '7d' | '30d';
    sortBy: 'hotScore';
    hotScoreFormula: 'saves * 3 + reposts * 2 + likes * 1 - reports * 10';
  };
}
```

#### 内容类型筛选

```typescript
interface ContentFilter {
  contentTypes: ('text' | 'image' | 'video' | 'mixed')[];
  
  // 筛选选项
  filters: {
    textOnly: boolean;          // 只看文字
    withImages: boolean;        // 包含图片
    withVideos: boolean;        // 包含视频
  };
}
```

#### 来源筛选（可选）

```typescript
interface SourceFilter {
  sourceTypes: ('personal' | 'chat' | 'channel')[];
  
  // 按群/频道筛选
  specificSources?: {
    chatId: string;
    chatTitle: string;
  }[];
}
```

---

### 8️⃣ 轻评论（单层，无盖楼）

#### 评论设计原则

> **评论是"回应表达"，不是"争夺话语权"**

**核心特性**:
1. **单层评论** - 所有评论在同一层
2. **不盖楼** - 不支持评论回复评论
3. **无热评** - 不做"最热评论"排序
4. **回应作者** - 心智引导：回应内容，不是写给观众

#### 评论数据结构

```typescript
interface Comment {
  commentId: string;
  postId: string;
  userId: string;
  username: string;
  
  // 评论内容
  text: string;                 // 最多 500 字
  createdAt: Date;
  
  // 编辑
  edited: boolean;
  editedAt?: Date;
  
  // 互动（克制）
  likeCount: number;            // 可点赞，但不作为排序依据
  
  // 状态
  status: 'normal' | 'hidden' | 'deleted';
  hiddenReason?: string;
}
```

#### 评论排序

```typescript
interface CommentSorting {
  sortBy: 'time' | 'author_first';
  
  // 按时间（默认）
  time: {
    order: 'asc' | 'desc';      // 默认 asc（最早的在前）
  };
  
  // 作者优先 + 时间
  authorFirst: {
    authorComments: Comment[];  // 作者的评论置顶
    otherComments: Comment[];   // 其他评论按时间排序
  };
}
```

**不做的**:
- ❌ 最热评论
- ❌ 点赞最多的评论置顶
- ❌ 评论回复评论（盖楼）
- ❌ 评论区权力结构

#### UI 设计

**输入框提示**:
```
「回应这条内容…」
```

**而不是**:
```
「写下你的看法」
「发表评论」
```

**评论展示**:
```
┌─────────────────────────────────┐
│ 👤 @username · 2小时前          │
│    这是一条评论内容              │
│    👍 12                        │
└─────────────────────────────────┘
```

#### 评论与群/私聊的关系

**评论的作用**:
- "我对你说的话有反应，但这段话不值得占用一个群"

**当出现以下情况时**:
- 多轮对话
- 明确主题
- 多人参与

**正确的引导**:
```
「去群里继续讨论」
「创建一个群继续聊」
```

**评论是缓冲层，不是终点**

---

### 9️⃣ 广场 ↔ 群回流

#### 对"群/频道同步内容"的回流

```typescript
interface ChatBackflow {
  // 强展示
  actions: {
    goToChat: {
      label: '去群里讨论';
      action: 'open_chat';
      chatId: string;
    };
    joinChat: {
      label: '加入群组' | '订阅频道';
      action: 'join_chat';
      chatId: string;
    };
  };
  
  // 统计
  metrics: {
    viewCount: number;          // 浏览数
    joinClickCount: number;     // 点击"加入"次数
    joinSuccessCount: number;   // 成功加入数
    joinCVR: number;            // 加入转化率
  };
}
```

#### 对"个人广播"的回流（可选）

```typescript
interface PersonalBackflow {
  // 弱引导，不强制绑定
  relatedChats?: {
    chatId: string;
    chatTitle: string;
    relevance: number;          // 相关度
    reason: string;             // 推荐理由
  }[];
  
  // 不以粉丝关系作为主分发逻辑
  followRelation: {
    useForDistribution: false;  // 不用于分发
    useForPersonalization: true;// 仅用于个性化
  };
}
```

---

### 🔟 个人页（克制但可用）

#### 个人页设计

```typescript
interface UserProfilePage {
  userId: string;
  username: string;
  displayName: string;
  bio?: string;
  avatar?: string;
  
  // 统计（克制）
  stats: {
    postCount: number;          // 发布数
    // 不显示粉丝数
    // 不显示点赞总数
  };
  
  // 公开内容
  publicPosts: Post[];          // 广场内容
  
  // 关注（可选）
  followable: boolean;
  followerCount?: number;       // 可选显示
  followingCount?: number;      // 可选显示
}
```

**不以粉丝关系作为广场主分发逻辑**:
- 关注只影响个性化推荐
- 不影响内容曝光权重
- 避免曝光内卷

---

## 🎯 核心 KPI

### 内容价值指标

```typescript
interface ContentKPI {
  // 有效停留
  dwell: {
    avgDwellTime: number;       // 平均停留时长（秒）
    completionRate: number;     // 完整浏览率
  };
  
  // 收藏率（高权重）
  saveRate: {
    saves: number;
    views: number;
    saveRate: number;           // saves / views
  };
  
  // 转发率
  repostRate: {
    reposts: number;
    views: number;
    repostRate: number;         // reposts / views
  };
  
  // 回流率（对群内容）
  joinRate: {
    joinClicks: number;
    joinSuccess: number;
    views: number;
    joinCTR: number;            // joinClicks / views
    joinCVR: number;            // joinSuccess / joinClicks
  };
  
  // 低举报率（负向指标）
  reportRate: {
    reports: number;
    views: number;
    reportRate: number;         // reports / views（越低越好）
  };
}
```

### 平台健康指标

```typescript
interface PlatformHealthKPI {
  // 内容质量
  contentQuality: {
    avgSaveRate: number;        // 平均收藏率
    avgRepostRate: number;      // 平均转发率
    avgReportRate: number;      // 平均举报率
  };
  
  // 用户活跃
  userEngagement: {
    dau: number;                // 日活
    avgSessionTime: number;     // 平均会话时长
    returnRate: number;         // 次日留存
  };
  
  // 回流效果
  backflowEffect: {
    avgJoinCTR: number;         // 平均入群点击率
    avgJoinCVR: number;         // 平均入群转化率
    newGroupMembers: number;    // 通过广场加入的新成员
  };
}
```


---

## 📐 推荐算法设计

### Phase 0 - 规则推荐（P0 同步上线）

#### 候选集 (Candidates)

借鉴 X 的 in-network / out-of-network 思路，但实现轻量：

```typescript
interface CandidatePool {
  // IN: 用户已加入的群/频道公开内容
  inNetwork: {
    source: 'joined_chats';
    posts: Post[];
    weight: number;             // 权重：0.6
  };
  
  // OUT-1: 全站个人广播内容池
  outNetworkPersonal: {
    source: 'all_personal_posts';
    posts: Post[];
    weight: number;             // 权重：0.2
  };
  
  // OUT-2: 全站群/频道同步内容池
  outNetworkChats: {
    source: 'all_chat_posts';
    posts: Post[];
    weight: number;             // 权重：0.2
  };
}
```

#### 过滤 (Filters)

```typescript
interface ContentFilters {
  // 黑名单过滤
  blacklist: {
    blockedUsers: string[];
    blockedSources: string[];
    mutedUsers: string[];
  };
  
  // 风控过滤
  riskControl: {
    lowReputationUsers: boolean;    // 低信誉账号降权
    highRiskContent: boolean;       // 高风险内容拦截
    spamDetection: boolean;         // 垃圾内容检测
  };
  
  // 去重与反刷屏
  deduplication: {
    sameAuthorDecay: {
      enabled: boolean;
      maxConsecutive: number;       // 同作者连续出现上限
      decayFactor: number;          // 衰减系数
    };
    sameSourceDecay: {
      enabled: boolean;
      maxConsecutive: number;       // 同来源连续出现上限
      decayFactor: number;
    };
  };
  
  // 时效策略
  timeDecay: {
    enabled: boolean;
    halfLife: number;               // 半衰期（小时）
    formula: 'exponential' | 'linear';
  };
}
```

#### 评分 (Scoring) - 线性可解释

```typescript
interface ScoringModel {
  // 评分公式
  formula: string;  // Score = w1·Recency + w2·Likes + w3·Reposts + w4·Saves + ...
  
  // 权重配置
  weights: {
    recency: number;                // w1 = 1.0
    likes: number;                  // w2 = 0.5
    reposts: number;                // w3 = 2.0
    saves: number;                  // w4 = 3.0 (高权重)
    dwell: number;                  // w5 = 1.5
    followAffinity: number;         // w6 = 0.3 (低权重，可选)
    joinClicks: number;             // w7 = 5.0 (仅对群/频道内容)
    reports: number;                // w8 = -10.0 (强负权重)
    blocks: number;                 // w9 = -15.0 (强负权重)
    spamRisk: number;               // w10 = -20.0 (强负权重)
  };
  
  // 权重原则
  principles: {
    savesOverLikes: boolean;        // 收藏权重 > 点赞权重
    joinClicksHighest: boolean;     // 入群点击权重最高（仅群内容）
    strongNegative: boolean;        // 举报/拉黑/垃圾强负权重
    followAffinityLow: boolean;     // 关注亲和度只做微调
  };
}
```

**评分计算示例**:
```typescript
function calculateScore(post: Post, user: User): number {
  const recencyScore = calculateRecency(post.publishedAt);
  const likesScore = post.likeCount * 0.5;
  const repostsScore = post.repostCount * 2.0;
  const savesScore = post.saveCount * 3.0;
  const dwellScore = post.avgDwellTime * 1.5;
  const followScore = isFollowing(user, post.author) ? 0.3 : 0;
  const joinScore = post.sourceType === 'chat' ? post.joinClickCount * 5.0 : 0;
  const reportPenalty = post.reportCount * -10.0;
  const blockPenalty = post.blockCount * -15.0;
  const spamPenalty = post.spamRiskScore * -20.0;
  
  return recencyScore + likesScore + repostsScore + savesScore + dwellScore 
         + followScore + joinScore + reportPenalty + blockPenalty + spamPenalty;
}
```

#### 选取 (Selector)

```typescript
interface ContentSelector {
  // TopK 选择
  topK: {
    k: number;                      // 每次加载 20 条
    minScore: number;               // 最低分数阈值
  };
  
  // 多样性约束
  diversity: {
    maxPerAuthor: number;           // 同作者每屏最多 2 条
    maxPerSource: number;           // 同来源每屏最多 3 条
    exploreRatio: number;           // 探索位占比 20%
  };
  
  // 探索位
  exploration: {
    enabled: boolean;
    ratio: number;                  // 0.2 (20%)
    strategy: 'random' | 'new_author' | 'new_source';
  };
}
```

---

### Phase 1 - 轻量学习（P1 上线后）

#### 模型 A: 价值预测

```typescript
interface ValuePredictionModel {
  modelType: 'logistic_regression' | 'gradient_boosting';
  
  // 预测目标
  targets: {
    p_save: number;               // 收藏概率
    p_repost: number;             // 转发概率
    p_dwell: number;              // 停留时长预测
    p_reply: number;              // 评论概率（可选）
  };
  
  // 特征
  features: {
    // 内容特征
    contentLength: number;
    hasImages: boolean;
    hasVideo: boolean;
    imageCount: number;
    
    // 作者特征
    authorPostCount: number;
    authorAvgSaveRate: number;
    authorReputation: number;
    
    // 来源特征（如果是群/频道）
    sourceMemberCount?: number;
    sourceActivityLevel?: number;
    
    // 时间特征
    hourOfDay: number;
    dayOfWeek: number;
    
    // 用户特征
    userInterestMatch: number;
    userHistoricalEngagement: number;
  };
}
```

#### 模型 B: 回流预测（对群内容）

```typescript
interface BackflowPredictionModel {
  modelType: 'logistic_regression';
  
  // 预测目标
  targets: {
    p_join_click: number;         // 点击"加入"概率
    p_join_success: number;       // 成功加入概率
  };
  
  // 特征
  features: {
    // 群/频道特征
    memberCount: number;
    activityLevel: number;
    contentQuality: number;
    
    // 内容特征
    contentRelevance: number;
    contentQuality: number;
    
    // 用户特征
    userJoinedGroupCount: number;
    userInterestMatch: number;
  };
}
```

#### 模型 C: 风险预测

```typescript
interface RiskPredictionModel {
  modelType: 'random_forest';
  
  // 预测目标
  targets: {
    p_report: number;             // 被举报概率
    p_block: number;              // 被拉黑概率
    p_spam: number;               // 垃圾内容概率
  };
  
  // 特征
  features: {
    // 内容特征
    hasExternalLinks: boolean;
    linkCount: number;
    suspiciousKeywords: number;
    
    // 作者特征
    authorAge: number;            // 账号年龄
    authorReportHistory: number;
    authorReputationScore: number;
    
    // 行为特征
    postFrequency: number;
    recentPostCount: number;
  };
}
```

#### 最终打分（多目标加权）

```typescript
interface MultiObjectiveScoring {
  formula: string;  // Score = a·p_save + b·p_repost + c·p_dwell + d·p_join_success - e·p_report - f·p_block - g·p_spam
  
  weights: {
    a: number;  // 3.0 (收藏)
    b: number;  // 2.0 (转发)
    c: number;  // 1.5 (停留)
    d: number;  // 5.0 (入群成功，仅群内容)
    e: number;  // -10.0 (举报)
    f: number;  // -15.0 (拉黑)
    g: number;  // -20.0 (垃圾)
  };
  
  // 不把"粉丝数"作为核心特征
  excludedFeatures: ['followerCount', 'followingCount'];
  
  // 让推荐学习"内容价值 + 回流价值"
  objectives: ['content_value', 'backflow_value'];
}
```

---

### Phase 2 - 规模后再上大模型（P2 以后）

#### 两塔召回

```typescript
interface TwoTowerRecall {
  // 用户塔
  userTower: {
    embedding: number[];          // 用户向量
    features: ['interests', 'behavior', 'demographics'];
  };
  
  // 内容塔
  contentTower: {
    embedding: number[];          // 内容向量
    features: ['text', 'images', 'source', 'author'];
  };
  
  // 相似度计算
  similarity: 'cosine' | 'dot_product';
  
  // 召回策略
  recall: {
    similarContent: Post[];       // 相似内容
    similarCommunities: Chat[];   // 相似社群
  };
}
```

#### 更复杂排序器

参考 X 的工程与分层，但保持目标函数：沉淀优先

```typescript
interface AdvancedRanker {
  // 多阶段排序
  stages: {
    stage1: 'candidate_generation';  // 候选生成
    stage2: 'coarse_ranking';        // 粗排
    stage3: 'fine_ranking';          // 精排
    stage4: 'diversity_rerank';      // 多样性重排
  };
  
  // 保持目标函数
  objective: 'maximize_saves_and_backflow';
  
  // 不变原则
  principles: {
    noFollowerCountBias: boolean;    // 不偏向高粉丝数
    contentValueFirst: boolean;      // 内容价值优先
    backflowValueHigh: boolean;      // 回流价值高权重
  };
}
```

---

### 算法配置项（运营/风控可控）

```typescript
interface AlgorithmConfig {
  // 探索占比
  exploreRatio: number;           // 0.2 (20%)
  
  // 多样性约束
  authorCap: number;              // 单作者每屏上限 2
  sourceCap: number;              // 单来源每屏上限 3
  
  // 新号限制
  newUserThrottle: {
    cooldownHours: number;        // 24
    uploadLimit: boolean;         // true
    linkLimit: boolean;           // true
  };
  
  // 风险阈值
  riskFloor: number;              // 风险分超过阈值不进广场
  
  // 回流权重
  joinWeight: number;             // 5.0 (对群内容最高)
  
  // 时间衰减
  recencyHalfLife: number;        // 24 (小时)
  
  // 可调参数
  tunable: {
    saveWeight: [2.0, 4.0];       // 可调范围
    repostWeight: [1.0, 3.0];
    joinWeight: [3.0, 7.0];
  };
}
```

---

## 🗄️ 数据库设计

### 核心表结构

```sql
-- 广场内容表
CREATE TABLE square_posts (
  post_id VARCHAR(255) PRIMARY KEY,
  author_id VARCHAR(255) NOT NULL,
  
  -- 来源
  source_type VARCHAR(20) NOT NULL,  -- personal, chat, channel
  source_id VARCHAR(255),            -- 群/频道 ID（如果是同步内容）
  
  -- 内容
  content_type VARCHAR(20) NOT NULL, -- text, image, video, mixed
  text TEXT,
  images TEXT[],                     -- 图片 URL 数组
  video VARCHAR(255),
  
  -- 状态
  status VARCHAR(20) DEFAULT 'published',  -- draft, published, hidden, deleted
  
  -- 互动统计
  like_count INTEGER DEFAULT 0,
  save_count INTEGER DEFAULT 0,
  repost_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  view_count INTEGER DEFAULT 0,
  
  -- 回流统计（仅群/频道内容）
  join_click_count INTEGER DEFAULT 0,
  join_success_count INTEGER DEFAULT 0,
  
  -- 治理
  report_count INTEGER DEFAULT 0,
  block_count INTEGER DEFAULT 0,
  
  -- 算法
  hot_score DECIMAL(10, 2) DEFAULT 0,
  quality_score DECIMAL(10, 2) DEFAULT 0,
  
  -- 时间
  published_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  -- 索引
  INDEX idx_author (author_id),
  INDEX idx_source (source_type, source_id),
  INDEX idx_published (published_at DESC),
  INDEX idx_hot_score (hot_score DESC),
  INDEX idx_status (status)
);

-- 评论表
CREATE TABLE square_comments (
  comment_id VARCHAR(255) PRIMARY KEY,
  post_id VARCHAR(255) NOT NULL,
  user_id VARCHAR(255) NOT NULL,
  
  -- 内容
  text TEXT NOT NULL,
  
  -- 互动
  like_count INTEGER DEFAULT 0,
  
  -- 状态
  status VARCHAR(20) DEFAULT 'normal',  -- normal, hidden, deleted
  edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP,
  
  -- 时间
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- 索引
  INDEX idx_post (post_id, created_at),
  INDEX idx_user (user_id),
  FOREIGN KEY (post_id) REFERENCES square_posts(post_id)
);

-- 互动记录表
CREATE TABLE square_interactions (
  interaction_id SERIAL PRIMARY KEY,
  post_id VARCHAR(255) NOT NULL,
  user_id VARCHAR(255) NOT NULL,
  
  -- 互动类型
  interaction_type VARCHAR(20) NOT NULL,  -- like, save, repost, view, join_click
  
  -- 元数据
  metadata JSONB,
  
  -- 时间
  created_at TIMESTAMP DEFAULT NOW(),
  
  -- 索引
  INDEX idx_post_user (post_id, user_id, interaction_type),
  INDEX idx_user_type (user_id, interaction_type, created_at),
  UNIQUE (post_id, user_id, interaction_type)
);

-- 用户控制表
CREATE TABLE square_user_controls (
  user_id VARCHAR(255) PRIMARY KEY,
  
  -- 拉黑/屏蔽
  blocked_users TEXT[],
  blocked_sources TEXT[],
  muted_users TEXT[],
  
  -- 不感兴趣
  not_interested_posts TEXT[],
  
  -- 更新时间
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 群/频道同步设置表
CREATE TABLE square_chat_sync_settings (
  chat_id VARCHAR(255) PRIMARY KEY,
  
  -- 同步设置
  sync_enabled BOOLEAN DEFAULT FALSE,
  auto_sync BOOLEAN DEFAULT FALSE,
  
  -- 权限
  allowed_users TEXT[],           -- 允许同步的用户
  
  -- 统计
  synced_post_count INTEGER DEFAULT 0,
  total_join_count INTEGER DEFAULT 0,
  
  -- 时间
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```


---

## 🎨 前端页面设计

### 页面结构

```
Echo Square/
├── /square                     # 广场首页
│   ├── 推荐流（默认）
│   ├── 最新流
│   └── 热门流
│
├── /square/post/:id            # 帖子详情页
│   ├── 内容展示
│   ├── 评论列表
│   └── 相关推荐
│
├── /square/publish             # 发布页
│   ├── 个人广播
│   └── 群/频道同步
│
├── /square/user/:id            # 用户个人页
│   ├── 公开内容
│   └── 统计信息
│
└── /square/chat/:id            # 群/频道说明页
    ├── 基本信息
    ├── 公开内容
    └── 加入/订阅按钮
```

### 组件设计

#### PostCard 组件

```typescript
interface PostCardProps {
  post: {
    postId: string;
    author: {
      userId: string;
      username: string;
      displayName: string;
      avatar: string;
    };
    source: {
      type: 'personal' | 'chat' | 'channel';
      chatId?: string;
      chatTitle?: string;
    };
    content: {
      type: 'text' | 'image' | 'video' | 'mixed';
      text?: string;
      images?: string[];
      video?: string;
    };
    stats: {
      likeCount: number;
      saveCount: number;
      repostCount: number;
      commentCount: number;
    };
    publishedAt: Date;
  };
  
  // 操作回调
  onLike: () => void;
  onSave: () => void;
  onRepost: () => void;
  onComment: () => void;
  onReport: () => void;
  onBlock: () => void;
}
```

#### CommentList 组件

```typescript
interface CommentListProps {
  postId: string;
  comments: Comment[];
  sortBy: 'time' | 'author_first';
  
  // 操作回调
  onSubmitComment: (text: string) => void;
  onLikeComment: (commentId: string) => void;
  onReportComment: (commentId: string) => void;
}
```

---

## 🔐 权限与安全

### 发布权限

```typescript
interface PublishPermissions {
  // 新用户限制
  newUser: {
    cooldownHours: number;        // 24 小时冷却期
    canUploadImages: boolean;     // 限制上传图片
    canUploadVideos: boolean;     // 限制上传视频
    canPostLinks: boolean;        // 限制外链
  };
  
  // 频率限制
  rateLimit: {
    maxPostsPerHour: number;      // 每小时 5 条
    maxPostsPerDay: number;       // 每天 20 条
    maxRepostsPerHour: number;    // 每小时 10 次
    maxCommentsPerHour: number;   // 每小时 30 条
  };
  
  // 内容审核
  moderation: {
    sensitiveWordFilter: boolean;
    imageModeration: boolean;
    videoModeration: boolean;
  };
}
```

### 群/频道同步权限

```typescript
interface ChatSyncPermissions {
  // 谁可以开启同步
  canEnableSync: 'creator' | 'admin' | 'all';
  
  // 谁可以同步内容
  canSyncContent: 'creator' | 'admin' | 'all' | 'whitelist';
  
  // 白名单
  whitelist: string[];
  
  // 审核
  requireApproval: boolean;
}
```

---

## 📊 管理后台功能

### 广场内容池管理

**路由**: `/admin/square/pool`

```typescript
interface SquareContentManagement {
  // 内容列表
  contentList: {
    postId: string;
    author: string;
    sourceType: string;
    status: string;
    hotScore: number;
    viewCount: number;
    reportCount: number;
    publishedAt: Date;
  }[];
  
  // 操作
  actions: {
    approve: (postId: string) => void;
    reject: (postId: string, reason: string) => void;
    hide: (postId: string, reason: string) => void;
    delete: (postId: string, reason: string) => void;
    pin: (postId: string) => void;
    adjustHotScore: (postId: string, score: number) => void;
  };
}
```

### 广场审核队列

**路由**: `/admin/square/moderation`

```typescript
interface SquareModerationQueue {
  // 待审核内容
  pendingReviews: {
    postId: string;
    author: string;
    content: string;
    riskLevel: 'low' | 'medium' | 'high';
    riskReasons: string[];
    submittedAt: Date;
  }[];
  
  // 操作
  actions: {
    approve: (postId: string) => void;
    reject: (postId: string, reason: string) => void;
    requestModification: (postId: string, note: string) => void;
    markRisk: (postId: string, level: string) => void;
  };
}
```

### 算法配置

**路由**: `/admin/square/algorithm`

```typescript
interface AlgorithmConfiguration {
  // 权重配置
  weights: {
    saves: number;
    reposts: number;
    dwell: number;
    joinClicks: number;
    reports: number;
    blocks: number;
  };
  
  // 多样性配置
  diversity: {
    exploreRatio: number;
    authorCap: number;
    sourceCap: number;
  };
  
  // 风控配置
  riskControl: {
    riskFloor: number;
    newUserCooldown: number;
  };
  
  // 操作
  actions: {
    updateWeights: (weights: Record<string, number>) => void;
    resetToDefault: () => void;
    exportConfig: () => void;
    importConfig: (config: AlgorithmConfig) => void;
  };
}
```

---

## 🚀 实施路线图

### Phase 1: P0 核心功能（4-5 周）

**Week 1-2: 基础架构**
- ✅ 数据库设计与迁移
- ✅ 后端 API 开发（发布、信息流、互动）
- ✅ 前端基础组件（PostCard、CommentList）

**Week 3: 发布与信息流**
- ✅ 个人广播发布
- ✅ 群/频道同步发布
- ✅ 推荐流（规则推荐）
- ✅ 最新流

**Week 4: 互动与治理**
- ✅ 点赞/收藏/转发
- ✅ 举报功能
- ✅ 拉黑/屏蔽
- ✅ Context Tag（来源标识）

**Week 5: 测试与优化**
- ✅ 功能测试
- ✅ 性能优化
- ✅ 安全测试

**验收标准**:
- 可以发布个人广播
- 可以同步群/频道内容到广场
- 推荐流和最新流正常工作
- 基础互动功能完整
- 治理功能可用

---

### Phase 2: P1 体验增强（2-3 周）

**Week 6: 内容控制与发现**
- ✅ 不感兴趣功能
- ✅ 最新/热门切换
- ✅ 内容类型筛选

**Week 7: 评论与回流**
- ✅ 轻评论功能（单层，无盖楼）
- ✅ 广场↔群回流
- ✅ 个人页

**Week 8: 算法优化**
- ✅ 轻量学习模型（价值预测、回流预测、风险预测）
- ✅ 多目标加权排序

**验收标准**:
- 用户可以控制内容偏好
- 评论功能完整且克制
- 回流功能有效
- 算法推荐质量提升

---

### Phase 3: P2 规模化（按需）

**创作者工具**:
- 数据面板（曝光、互动、回流统计）
- 置顶帖/系列帖
- 内容管理

**高级治理**:
- 信誉分系统
- 反刷赞/反搬运
- 冷却机制

**高级发现**:
- 相似群/频道推荐
- 新内容冷启动探索池
- 多语言/地区化推荐

---

## ✅ 总结

### 核心原则（必须遵守）

1. **广场 = 公共表达层，群/频道 = 主题空间，私聊 = 私密关系**
2. **公开与私密不冲突；公开内容必须是"用户主动公开"**
3. **评论是"回应表达"，不是"争夺话语权"**
4. **不做曝光竞技场 - 不以粉丝数作为主要分发逻辑**
5. **沉淀优先 - 核心 KPI 是收藏率、转发率、回流率**

### 评论设计要点

- ✅ 单层评论（不盖楼）
- ✅ 无热评排序
- ✅ 回应作者，不是写给观众
- ✅ 评论是缓冲层，不是终点
- ✅ 多轮对话 → 引导去群里讨论

### 推荐算法要点

**Phase 0 (P0)**:
- 规则推荐：候选集 + 过滤 + 评分 + 选取
- 线性可解释：收藏权重 > 点赞权重
- 回流权重最高（仅群/频道内容）
- 强负权重：举报/拉黑/垃圾

**Phase 1 (P1)**:
- 轻量学习：价值预测 + 回流预测 + 风险预测
- 多目标加权：沉淀优先
- 不把粉丝数作为核心特征

**Phase 2 (P2)**:
- 两塔召回 + 复杂排序器
- 参考 X 的工程思想，但保持目标函数

### X 算法参考

**仓库链接**: https://github.com/xai-org/x-algorithm

**参考内容**:
- 候选源拆分（in-network / out-of-network）
- Mixer/Pipeline 分层思想
- 多目标加权方法

**不照搬**:
- 不复刻其训练/Serving 的重工程
- 保持 Echo 的目标函数：沉淀优先
- 避免曝光竞技场

### 下一步行动

1. ✅ 完成广场功能设计文档
2. 🔄 更新 IA 文档，添加广场相关页面
3. 🔄 更新 ECHO_ADMIN_PANEL.md 中的 P2 广场功能
4. ⏳ 开始 Phase 1 开发（P0 核心功能）

---

**最后更新**: 2026-01-28  
**状态**: 广场功能设计完成，可直接用于开发

