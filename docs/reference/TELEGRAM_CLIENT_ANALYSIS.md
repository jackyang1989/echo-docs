# Telegram Android 客户端源码分析

**源码位置**: `/Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./Telegram-master`  
**分析日期**: 2026-01-27

---

## 📊 版本信息

### 当前版本
- **更新日期**: 2024年11月20日
- **版本号**: 11.4.2 (5469)
- **API Layer**: 221 ⚠️
- **编译 SDK**: 35 (Android 15)
- **最低 SDK**: 21 (Android 5.0)
- **目标 SDK**: 35

### 版本对比

| 项目 | Telegram 客户端 | Echo Server | 状态 |
|------|----------------|-----------------|------|
| API Layer | 221 | 220 | ⚠️ 不匹配 |
| 更新时间 | 2024-11-20 | 未知 | 客户端较新 |

**问题**: API Layer 不匹配（221 vs 220）

---

## 🔍 关键配置文件分析

### 1. BuildVars.java

**位置**: `TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java`

**关键配置**:
```java
public class BuildVars {
    // API 配置
    public static int APP_ID = 4;
    public static String APP_HASH = "014b35b6184100b085b0d0572f9b5103";
    
    // 这些是 Telegram 官方的测试 API 凭证
    // 需要替换为自己的
    
    // Google Play 相关
    public static String PLAYSTORE_APP_URL = "https://play.google.com/store/apps/details?id=org.telegram.messenger";
    
    // 华为商店
    public static String HUAWEI_STORE_URL = "https://appgallery.huawei.com/app/C101184875";
    
    // Google 认证
    public static String GOOGLE_AUTH_CLIENT_ID = "760348033671-81kmi3pi84p11ub8hp9a1funsv0rn2p9.apps.googleusercontent.com";
    
    // SafetyNet（Google 身份验证）
    public static String SAFETYNET_KEY = "AIzaSyDqt8P-7F7CPCseMkOiVRgb1LY8RN1bvH8";
    
    // SMS 验证码哈希
    public static String getSmsHash() {
        return ApplicationLoader.isStandaloneBuild() ? "w0lkcmTZkKh" : 
               (DEBUG_VERSION ? "O2P2z+/jBpJ" : "oLeq9AcOZkT");
    }
}
```

### 2. TLRPC.java

**位置**: `TMessagesProj/src/main/java/org/telegram/tgnet/TLRPC.java`

**API Layer 定义**:
```java
public static final int LAYER = 221;  // ⚠️ 与 Echo 220 不匹配
```

### 3. ConnectionsManager.java

**位置**: `TMessagesProj/src/main/java/org/telegram/tgnet/ConnectionsManager.java`

**连接初始化**:
```java
init(SharedConfig.buildVersion(), 
     TLRPC.LAYER,           // API Layer 221
     BuildVars.APP_ID,      // APP ID
     deviceModel, 
     systemVersion, 
     appVersion, 
     langCode, 
     systemLangCode, 
     configPath, 
     FileLog.getNetworkLogPath(), 
     pushString, 
     fingerprint, 
     timezoneOffset, 
     getUserConfig().getClientUserId(), 
     userPremium, 
     enablePushConnection);
```

---

## ⚠️ 关键问题

### 1. API Layer 不匹配 🔴 高风险

**问题**:
- Telegram 客户端: Layer 221
- Echo Server: Layer 220

**影响**:
- 可能导致协议不兼容
- 某些新功能可能无法使用
- 可能出现连接失败

**解决方案**:

#### 选项 A: 降级客户端（推荐）
```java
// 修改 TLRPC.java
public static final int LAYER = 220;  // 改为 220
```

#### 选项 B: 升级 Echo
- 等待 Echo 更新到 Layer 221
- 或者自己修改 Echo 代码

#### 选项 C: 测试兼容性
- 先测试 Layer 221 客户端能否连接 Layer 220 服务器
- Telegram 协议通常向后兼容

### 2. 版本严重过时 � 高风险

**问题**:
- 源码更新于 2024-11-20
- 距今已 **14个月**（2026-01-27）
- 缺少大量新功能和安全修复
- 可能存在已知安全漏洞
- API Layer 可能已经过时

**解决方案**:
```bash
# ⚠️ 必须更新到最新版本
cd /Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./

# 重新克隆最新代码
git clone https://github.com/DrKLO/Telegram.git Telegram-2026-latest
cd Telegram-2026-latest

# 查看最新版本信息
git log -1 --format="%H %ci %s"

# 检查最新的 API Layer
grep "LAYER" TMessagesProj/src/main/java/org/telegram/tgnet/TLRPC.java
```

**重要性**: 🔴 极高
- 14个月的差距意味着可能有数百个更新
- 安全漏洞修复
- 新功能添加
- 协议更新
- Bug 修复

### 3. 需要自己的 API 凭证 🟡 中风险

**问题**:
- 当前使用的是 Telegram 官方测试凭证
- `APP_ID = 4` 和 `APP_HASH = "014b35b6184100b085b0d0572f9b5103"`
- 这些凭证有使用限制

**解决方案**:
1. 访问 https://my.telegram.org
2. 登录并创建应用
3. 获取自己的 API_ID 和 API_HASH
4. 替换 BuildVars.java 中的值

---

## 🔧 需要修改的地方

### 必须修改

#### 1. 服务器地址

**需要找到并修改服务器配置**:

```bash
# 搜索服务器地址配置
cd /Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./Telegram-master
grep -r "149.154" .  # Telegram 官方 IP
grep -r "telegram.org" .
grep -r "DC" TMessagesProj/src/main/java/org/telegram/tgnet/
```

**可能的位置**:
- `ConnectionsManager.java` - 连接管理
- `Datacenter.java` - 数据中心配置
- Native 代码 (C++) - 可能在 JNI 层

#### 2. API Layer

```java
// TMessagesProj/src/main/java/org/telegram/tgnet/TLRPC.java
public static final int LAYER = 220;  // 改为 220 匹配 Echo
```

#### 3. API 凭证

```java
// TMessagesProj/src/main/java/org/telegram/messenger/BuildVars.java
public static int APP_ID = YOUR_APP_ID;  // 替换为你的
public static String APP_HASH = "YOUR_APP_HASH";  // 替换为你的
```

### 可选修改

#### 4. 品牌化

- Logo: `TMessagesProj/src/main/res/drawable*/`
- 应用名称: `TMessagesProj/src/main/res/values/strings.xml`
- 包名: `build.gradle` 中的 `applicationId`
- 配色: `TMessagesProj/src/main/res/values/colors.xml`

#### 5. 移除不需要的功能

- Google Play Billing
- Huawei Store 集成
- Telegram Passport
- 频道推荐

---

## 📁 项目结构

```
Telegram-master/
├── TMessagesProj/              # 主项目（核心代码）
│   ├── src/main/java/
│   │   └── org/telegram/
│   │       ├── messenger/      # 消息处理
│   │       │   ├── BuildVars.java      # ⚠️ 配置文件
│   │       │   ├── MessagesController.java
│   │       │   └── ...
│   │       ├── tgnet/          # 网络层
│   │       │   ├── TLRPC.java          # ⚠️ API Layer
│   │       │   ├── ConnectionsManager.java  # ⚠️ 连接管理
│   │       │   └── ...
│   │       └── ui/             # UI 层
│   ├── src/main/res/           # 资源文件
│   └── jni/                    # Native 代码 (C++)
│
├── TMessagesProj_App/          # Google Play 版本
├── TMessagesProj_AppHuawei/    # 华为版本
├── TMessagesProj_AppStandalone/ # 独立版本
└── build.gradle                # 构建配置
```

---

## 🔍 下一步调查

### 1. 查找服务器地址配置（最重要）

```bash
cd /Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./Telegram-master

# 搜索数据中心配置
find . -name "*.java" -exec grep -l "datacenter\|Datacenter\|DC" {} \;

# 搜索 IP 地址
grep -r "149.154" TMessagesProj/src/

# 搜索域名
grep -r "telegram.org" TMessagesProj/src/

# 检查 Native 代码
ls -la TMessagesProj/jni/
```

### 2. 检查证书验证

```bash
# 搜索证书相关代码
grep -r "certificate\|Certificate\|SSL\|TLS" TMessagesProj/src/main/java/org/telegram/tgnet/

# 搜索证书固定
grep -r "pinning\|Pinning" TMessagesProj/src/
```

### 3. 检查 Native 层

```bash
# 查看 JNI 代码
ls -la TMessagesProj/jni/
cat TMessagesProj/jni/tgnet/ConnectionsManager.cpp | head -100
```

---

## 🎯 验证计划

### Phase 0.1: 客户端源码分析（本周）

#### Day 1-2: 查找服务器配置
- [ ] 找到所有服务器地址配置
- [ ] 找到数据中心配置
- [ ] 检查是否有硬编码的 IP/域名
- [ ] 检查 Native 层配置

#### Day 3-4: 修改配置
- [ ] 修改 API Layer 为 220
- [ ] 修改服务器地址为 Echo
- [ ] 申请自己的 API 凭证
- [ ] 修改 BuildVars.java

#### Day 5-7: 编译测试
- [ ] 配置 Android Studio
- [ ] 编译 APK
- [ ] 安装到测试设备
- [ ] 测试连接 Echo Server

---

## 📝 已知问题清单

### 🔴 高优先级（必须立即处理）

1. **版本严重过时** ⚠️ 最紧急
   - 源码: 2024-11-20
   - 当前: 2026-01-27
   - 差距: 14个月
   - 行动: 立即更新到最新版本

2. **API Layer 可能不匹配**
   - 客户端: 221
   - 服务器: 220
   - 需要: 降级客户端或升级服务器

2. **服务器地址未知**
   - 需要找到配置位置
   - 可能在 Java 层或 Native 层

3. **API 凭证**
   - 需要申请自己的 APP_ID 和 APP_HASH

### 🟡 中优先级

4. **版本较旧**
   - 2024-11-20 的代码
   - 建议更新到最新版

5. **证书验证**
   - 需要检查是否有证书固定
   - 可能需要移除验证

### 🟢 低优先级

6. **品牌化**
   - Logo 替换
   - 名称修改
   - 配色调整

---

## 💡 建议

### 立即执行

1. **更新源码到最新版本**
   ```bash
   cd /Users/jianouyang/.gemini/antigravity/scratch/order-management-system/./
   git clone https://github.com/DrKLO/Telegram.git Telegram-latest
   cd Telegram-latest
   git log -1  # 查看最新提交
   ```

2. **查找服务器配置**
   - 这是最关键的一步
   - 必须找到才能继续

3. **申请 API 凭证**
   - 访问 https://my.telegram.org
   - 创建应用获取凭证

### 风险评估

**如果找不到服务器配置**:
- 可能配置在 Native 层（C++）
- 需要修改 JNI 代码
- 难度会大幅增加

**如果 API Layer 不兼容**:
- 可能需要修改 Echo
- 或者降级客户端
- 或者等待 Echo 更新

---

## 🔗 参考资源

- Telegram Android 源码: https://github.com/DrKLO/Telegram
- Telegram API 文档: https://core.telegram.org/api
- MTProto 协议: https://core.telegram.org/mtproto
- 申请 API 凭证: https://my.telegram.org
- Echo 客户端指南: `echo-server-source/clients/echo-android.md`

---

## 总结

**当前状态**: 源码已下载，但需要深入分析

**关键问题**:
1. ⚠️ API Layer 不匹配（221 vs 220）
2. ⚠️ 服务器地址配置未找到
3. ⚠️ 版本较旧（2个月前）

**下一步**:
1. 更新到最新版本
2. 查找服务器配置
3. 修改 API Layer
4. 申请 API 凭证
5. 编译测试

**预计时间**: 1-2周（如果顺利）
