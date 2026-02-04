# Echo Server API 契约（HTTP 内部接口）

**文档版本**: 1.0.0
**创建日期**: 2026-02-05
**维护者**: Echo 项目团队
**文档级别**: 🔴 核心文档（禁止删除）

---

## 📋 文档说明

本文档定义 Echo Server 内部 HTTP API 契约（Gateway/BFF 调用 Auth/Message/Sync/User 服务）。
契约只描述**已实现**的接口，未实现接口必须返回明确错误（不得 stub）。

---

## ✅ 通用约定

- **协议**: HTTP/JSON
- **编码**: UTF-8
- **错误格式**（统一）：
  ```json
  {"error": "ERROR_CODE"}
  ```
- **成功响应**: 具体接口定义见下文
- **健康检查**: `GET /health`

---

## 1. Auth Service（认证服务）

**入口文件**: `echo-server/cmd/auth/main.go`

### 1.1 发送验证码
- **POST** `/auth/sendCode`
- **Request**:
  ```json
  {"phone_number": "+8613800138000", "api_id": 12345, "api_hash": "xxxx"}
  ```
- **Response**:
  ```json
  {"phone_code_hash": "hash", "type": {"_": "auth.sentCodeTypeSms", "length": 5}, "next_type": "", "timeout": 60}
  ```

### 1.2 登录
- **POST** `/auth/signIn`
- **Request**:
  ```json
  {"phone_number": "+8613800138000", "phone_code_hash": "hash", "phone_code": "12345"}
  ```
- **Response**:
  ```json
  {"_": "auth.authorization", "user": {"id": 1, "first_name": "Echo"}}
  ```

### 1.3 注册
- **POST** `/auth/signUp`
- **Request**:
  ```json
  {"phone_number": "+8613800138000", "phone_code_hash": "hash", "first_name": "Echo", "last_name": ""}
  ```
- **Response**:
  ```json
  {"_": "auth.authorization", "user": {"id": 1, "first_name": "Echo"}}
  ```

### 1.4 退出登录
- **POST** `/auth/logOut`
- **Request**: `{}`
- **Response**:
  ```json
  {"success": true}
  ```

---

## 2. Message Service（消息服务）

**入口文件**: `echo-server/cmd/message/main.go`

### 2.1 发送消息
- **POST** `/message/send`
- **Request**:
  ```json
  {"from_user_id": 1, "peer_type": "user", "peer_id": 2, "message": "hi"}
  ```
- **Response**:
  ```json
  {"message_id": 1001, "pts": 10, "pts_count": 1, "date": 1700000000}
  ```

### 2.2 获取历史
- **POST** `/message/getHistory`
- **Request**:
  ```json
  {"user_id": 1, "peer_type": "user", "peer_id": 2, "offset_id": 0, "limit": 50}
  ```
- **Response**: `messages` 数组（见代码实现）

### 2.3 获取会话列表
- **POST** `/message/getDialogs`
- **Request**:
  ```json
  {"user_id": 1, "offset_date": 0, "offset_id": 0, "offset_peer": 0, "limit": 50}
  ```
- **Response**: `dialogs/messages/users/chats` 组合结构

### 2.4 已读历史
- **POST** `/message/readHistory`
- **Request**:
  ```json
  {"user_id": 1, "peer_type": "user", "peer_id": 2, "max_id": 1000}
  ```
- **Response**:
  ```json
  {"pts": 11, "pts_count": 1}
  ```

### 2.5 删除消息
- **POST** `/message/delete`
- **Request**:
  ```json
  {"user_id": 1, "message_ids": [1,2,3], "revoke": true}
  ```
- **Response**:
  ```json
  {"pts": 12, "pts_count": 1}
  ```

### 2.6 批量拉取消息
- **POST** `/message/getMessages`
- **Request**:
  ```json
  {"user_id": 1, "message_ids": [1,2,3]}
  ```
- **Response**: `messages/users/chats` 组合结构

### 2.7 联系人
- **POST** `/contacts/getContacts`
- **POST** `/contacts/importContacts`
- **POST** `/contacts/search`

---

## 3. Sync Service（同步服务）

**入口文件**: `echo-server/cmd/sync/main.go`

### 3.1 获取状态
- **POST** `/sync/getState`
- **Request**:
  ```json
  {"user_id": 1}
  ```
- **Response**:
  ```json
  {"pts": 10, "qts": 0, "date": 1700000000, "seq": 1}
  ```

### 3.2 拉取差异
- **POST** `/sync/getDifference`
- **Request**:
  ```json
  {"user_id": 1, "pts": 10, "qts": 0, "date": 1700000000}
  ```
- **Response**: `updates/users/chats` 组合结构

---

## 4. User Service（用户服务）

**入口文件**: `echo-server/cmd/user/main.go`

### 4.1 获取用户列表
- **POST** `/user/getUsers`
- **Request**:
  ```json
  {"user_ids": [1,2,3]}
  ```
- **Response**: `users` 数组

### 4.2 获取完整用户信息
- **POST** `/user/getFullUser`
- **Request**:
  ```json
  {"user_id": 1}
  ```
- **Response**: `users.UserFull` + `users.Users`

---

## 5. 健康检查

- **GET** `/health`
- **Response**:
  ```json
  {"status": "ok"}
  ```

---

## 🔗 相关文档

- [系统架构设计](./system-design.md)
- [模块设计文档](./module-design.md)
- [变更记录索引](../changes/README.md)
