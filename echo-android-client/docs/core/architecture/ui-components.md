# Echo Android 客户端 UI 组件设计

**版本**: 1.0.0  
**更新日期**: 2026-01-30  
**状态**: ✅ 已完善

---

## 1. UI 架构概览

Echo Android 客户端 UI 基于自定义 Fragment 体系，核心是 `BaseFragment` 类。

### UI 层次结构

```
LaunchActivity (主 Activity)
    │
    └── ActionBarLayout (Fragment 容器)
            │
            ├── DialogsActivity (会话列表)
            ├── ChatActivity (聊天界面)
            ├── ProfileActivity (个人资料)
            └── ... (更多 Fragment)
```

---

## 2. 核心 Activity/Fragment

### 2.1 LaunchActivity（主容器）

| 属性 | 说明 |
|------|------|
| 路径 | `com.echo.ui.LaunchActivity` |
| 职责 | 应用主入口，管理 Fragment 栈，处理 Deep Link |
| 导航 | 使用 `ActionBarLayout` 实现 Fragment 导航 |

### 2.2 核心 Fragment 列表

| Fragment | 职责 | 入口 |
|----------|------|------|
| `DialogsActivity` | 会话列表 | 首页 Tab 1 |
| `ChatActivity` | 聊天界面 | 点击会话 |
| `ProfileActivity` | 用户/群组资料 | 点击头像 |
| `ContactsActivity` | 联系人列表 | 首页 Tab 2 |
| `SettingsActivity` | 设置页面 | 首页 Tab 3 |
| `GroupCreateActivity` | 创建群组 | 新建对话 |
| `ChannelCreateActivity` | 创建频道 | 新建对话 |

---

## 3. BaseFragment 体系

### 3.1 BaseFragment 核心方法

```java
public abstract class BaseFragment {
    
    // 创建视图（必须重写）
    public abstract View createView(Context context);
    
    // 生命周期回调
    public void onFragmentCreate() {}
    public void onFragmentDestroy() {}
    public void onResume() {}
    public void onPause() {}
    
    // 返回键处理
    public boolean onBackPressed() { return true; }
    
    // ActionBar 配置
    public ActionBar createActionBar(Context context) {}
    
    // Fragment 导航
    public void presentFragment(BaseFragment fragment) {}
    public void finishFragment() {}
}
```

### 3.2 导航示例

```java
// 打开新页面
presentFragment(new ChatActivity(args));

// 关闭当前页面
finishFragment();

// 替换当前页面
presentFragment(new ProfileActivity(args), true);
```

---

## 4. ActionBar 系统

Echo 使用自定义 ActionBar，而非 Android 原生 Toolbar。

### 4.1 ActionBar 结构

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back  │      Title / Subtitle      │  Menu Items  │
│  按钮     │                            │  ⋮ 更多      │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 使用示例

```java
@Override
public ActionBar createActionBar(Context context) {
    ActionBar actionBar = ActionBar.createActionBar(context);
    actionBar.setBackButtonImage(R.drawable.ic_ab_back);
    actionBar.setTitle("Echo");
    actionBar.setActionBarMenuOnItemClick(new ActionBar.ActionBarMenuOnItemClick() {
        @Override
        public void onItemClick(int id) {
            if (id == -1) {
                finishFragment();
            }
        }
    });
    return actionBar;
}
```

---

## 5. 自定义 View 组件索引

### 5.1 聊天相关

| 组件 | 路径 | 用途 |
|------|------|------|
| `ChatMessageCell` | `com.echo.ui.Cells` | 聊天消息气泡 |
| `ChatActivityEnterView` | `com.echo.ui.Components` | 消息输入框 |
| `RecyclerListView` | `com.echo.ui.Components` | 增强版 RecyclerView |
| `ChatAttachAlert` | `com.echo.ui.Components` | 附件选择器 |

### 5.2 会话列表相关

| 组件 | 路径 | 用途 |
|------|------|------|
| `DialogCell` | `com.echo.ui.Cells` | 会话列表项 |
| `FilterTabsView` | `com.echo.ui.Components` | 文件夹标签栏 |
| `SwipeGestureSettingsView` | `com.echo.ui.Components` | 滑动手势设置 |

### 5.3 通用组件

| 组件 | 路径 | 用途 |
|------|------|------|
| `AvatarDrawable` | `com.echo.ui.Components` | 头像绘制 |
| `BackupImageView` | `com.echo.ui.Components` | 图片加载 View |
| `EmojiView` | `com.echo.ui.Components` | 表情键盘 |
| `PhotoViewer` | `com.echo.ui` | 图片/视频查看器 |
| `AlertDialog` | `com.echo.ui.ActionBar` | 自定义对话框 |
| `BottomSheet` | `com.echo.ui.ActionBar` | 底部弹窗 |

---

## 6. 主题系统 (Theme)

### 6.1 主题类

| 类名 | 职责 |
|------|------|
| `Theme` | 主题管理核心类 |
| `ThemeColors` | 颜色定义 |
| `ThemeInfo` | 主题信息实体 |

### 6.2 使用颜色

```java
// 获取主题颜色
int color = Theme.getColor(Theme.key_actionBarDefault);

// 获取画笔
Paint paint = Theme.chat_actionBackgroundPaint;

// 应用主题
Theme.applyTheme(themeInfo);
```

### 6.3 主题 Key 示例

| Key | 用途 |
|-----|------|
| `key_actionBarDefault` | ActionBar 背景色 |
| `key_windowBackgroundWhite` | 页面背景色 |
| `key_chat_messagePanelBackground` | 输入框背景 |
| `key_chat_outBubble` | 发出消息气泡 |
| `key_chat_inBubble` | 收到消息气泡 |

---

## 7. 动画系统

### 7.1 常用动画类

| 类名 | 用途 |
|------|------|
| `CubicBezierInterpolator` | 贝塞尔曲线插值器 |
| `SpringAnimation` | 弹簧动画 |
| `ValueAnimator` | 数值动画 |

### 7.2 Fragment 过渡动画

Echo 使用自定义 Fragment 过渡，实现流畅的页面切换效果：

```java
// ActionBarLayout 中的过渡实现
private void startLayoutAnimation(boolean open) {
    // 滑动进入/退出动画
}
```

---

## 8. 响应式布局

### 8.1 平板适配

Echo 支持平板的分栏布局：

```
┌─────────────────┬─────────────────────────────────────┐
│                 │                                     │
│   会话列表       │          聊天界面                    │
│   (固定宽度)     │          (自适应)                    │
│                 │                                     │
└─────────────────┴─────────────────────────────────────┘
```

### 8.2 尺寸工具

```java
// dp 转 px
int px = AndroidUtilities.dp(16);

// 屏幕宽度
int width = AndroidUtilities.displaySize.x;

// 是否平板
boolean isTablet = AndroidUtilities.isTablet();
```

---

## 9. 扩展指南

### 9.1 创建自定义 Cell

```java
// ECHO-FEATURE-XXX: 自定义 Cell
public class CustomCell extends FrameLayout {
    
    private TextView textView;
    private ImageView imageView;
    
    public CustomCell(Context context) {
        super(context);
        
        textView = new TextView(context);
        textView.setTextColor(Theme.getColor(Theme.key_windowBackgroundWhiteBlackText));
        addView(textView);
        
        imageView = new ImageView(context);
        addView(imageView);
    }
    
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(
            MeasureSpec.makeMeasureSpec(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(AndroidUtilities.dp(56), MeasureSpec.EXACTLY)
        );
    }
    
    public void setData(String text, int iconRes) {
        textView.setText(text);
        imageView.setImageResource(iconRes);
    }
}
```

### 9.2 创建 BottomSheet

```java
// 创建底部弹窗
BottomSheet.Builder builder = new BottomSheet.Builder(context);
builder.setTitle("选择操作");
builder.setItems(new CharSequence[]{"选项 1", "选项 2"}, (dialog, which) -> {
    // 处理点击
});
builder.show();
```

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-01-30 | 初始版本，基于 Telegram 源码分析 |
