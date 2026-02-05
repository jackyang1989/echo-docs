# [ECHO-BUG-039] 消息更新二进制编码错误 & 实时推送解析不兼容

**状态**: ✅ 已解决  
**优先级**: P0（影响消息实时性、昵称显示与方向）  
**日期**: 2026-02-05  
**作者**: AI Agent (Codex)

## 🛑 问题描述

**症状**:
- 发送消息后对方长期收不到，列表/聊天界面不刷新。
- 重新登录后，自己发送的消息显示在左侧（Out=false）。
- 聊天顶部昵称退化为手机号。
- Gateway `push` 返回 200，但客户端无更新。

## 🔍 根因分析

1. **updateNewMessage TL 二进制编码错误**
   - Message 服务将 `TLUpdateNewMessage` 转成 `Update` 后编码，导致消息体丢失。
   - `update_log` 出现长度仅 12 字节的无效 blob，Gateway 解码失败并丢弃更新。

2. **PushHandler 仅支持 JSON 更新**
   - Message/Sync 服务推送的是 TL 二进制 update_blob。
   - PushHandler 以 JSON 解析，无法识别 TL binary，导致实时推送失败。

3. **update_log 混用 JSON/TL**
   - `readHistory/deleteMessages` 仍写 JSON blob。
   - Gateway 优先按 TL 解码，历史 JSON 记录被跳过。

## 🛠 修复方案

1. **统一生成 TL 二进制更新**
   - Message 服务直接编码 `TLUpdateNewMessage`，保证 `message/out/pts` 完整。
   - 为发送者也写入 update_log（铁律 B：所有可见变化必须可回放）。

2. **ReadHistory/DeleteMessages 改为 TL 更新**
   - 使用 `TLUpdateReadHistoryInbox` / `TLUpdateDeleteMessages` 写入 update_log。

3. **PushHandler 兼容 TL binary + 旧 JSON**
   - TL binary 直接走二进制解析路径。
   - JSON 仍按旧格式解析，保持向后兼容。

4. **Gateway 更新解码能力**
   - `buildDifferenceUpdates` 支持 TL UpdateReadHistoryInbox / UpdateDeleteMessages。
   - 识别 legacy JSON blob 并转换为 UpdateResponse。

## ✅ 影响范围

- `echo-server/internal/service/message/service.go`
- `echo-server/internal/gateway/push_handler.go`
- `echo-server/internal/gateway/rpc_router.go`

## ✅ 验证结果

- `update_log` 新增记录可被 TL 解码，长度显著大于 12。
- 实时推送可成功投递更新，`updates.getDifference` 返回完整消息。
- 自己消息方向恢复为右侧，昵称恢复为配置的 first_name。

## 📜 权威约束合规性

- **不修改客户端业务逻辑** ✅  
- **不使用 mock/stub/fake success** ✅  
- **状态一致性可验证** ✅
