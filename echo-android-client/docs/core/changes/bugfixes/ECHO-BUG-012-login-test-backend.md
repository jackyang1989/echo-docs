# ECHO-BUG-012: 启用测试后端 (登录临时方案)

> **状态**: 临时开启 (Temporary Enabled)  
> **创建日期**: 2026-01-31  
> **优先级**: Critical (必须在发布前回滚)

## 问题描述
由于应用包名变更 (`org.telegram` -> `com.echo`)，Google SafetyNet / Play Integrity 验证失败，导致官方短信验证码无法发送至未在 Play Store 上架的改版应用。测试人员无法登录。

## 临时解决方案
强制启用 Telegram 客户端的 **Test Backend** (测试环境) 选项。
这允许使用官方预留的测试手机号进行登录，绕过真实短信验证。

### 修改内容
**文件**: `TMessagesProj/src/main/java/com/echo/ui/LoginActivity.java`

```java
// 修改前
public static final boolean TEST_BACKEND_IN_STORE = false;

// 修改后
public static final boolean TEST_BACKEND_IN_STORE = true;
```

### 使用方法
1. 在登录页 (输入手机号界面) 勾选 **Test Backend** 选项。
2. 使用测试号段: `99966xxxxx` (如 `9996621234`)。
3. 验证码: `22222`。

## 回滚计划
**必须在发布正式版前 revert 此修改**，否则普通用户可能会误入测试环境，且该环境数据不与正式版互通。

```bash
# 回滚命令
git checkout TMessagesProj/src/main/java/com/echo/ui/LoginActivity.java
# 或手动将 true 改回 false
```
