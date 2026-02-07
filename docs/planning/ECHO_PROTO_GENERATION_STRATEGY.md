# Echo Proto 生成策略

**文档版本**: 1.0  
**最后更新**: 2026-02-07  
**状态**: 方案设计

---

## 🎯 问题分析

### 当前困境

- ✅ **echo-android-client**: **668 个 API** (100% 完整)
  - TLRPC.java: 417 个
  - tl/*.java: 251 个
- ❌ **echo-proto (旧)**: 约 150 个 API (22% 完整) - **已放弃**
- ✅ **决策**: 放弃 teamgram-proto，从 TLRPC.java 生成完整 668 个 API

### 解决方案：从 TLRPC.java 自动生成 ✅

**优点**:
- ✅ TLRPC.java 是权威来源（客户端用什么，服务端就实现什么）
- ✅ 100% 完整（**668 个 API**）
- ✅ 与客户端完全一致（零版本漂移）
- ✅ 自动生成工具 - 写一次，以后 Telegram 更新可以自动同步
- ✅ 一劳永逸
- ✅ 避免人工错误

**预计工作量**: 
- 生成器开发: 2-3 周
- 生成代码验证: 1 周
- **总计**: 3-4 周

---

## ✅ 实施方案

### 核心理由

1. **TLRPC.java 是权威来源**
   - 客户端用什么，服务端就实现什么
   - 保证 100% 兼容性

2. **自动生成工具**
   - 写一次，以后 Telegram 更新可以自动同步
   - 直接生成完整 668 个 API（不是补 550 个缺失）

3. **避免版本漂移**
   - 自动生成保证与客户端完全一致

4. **长期收益**
   - 初始投入 3-4 周
   - 避免了 6-9 个月的手动工作
   - 未来更新只需重新运行生成器

---

## 🔧 实施方案

### 整体流程

```
TLRPC.java (700 API)
    │
    ▼
[1. 解析工具]
    │
    ▼
TL Schema (中间格式)
    │
    ▼
[2. 代码生成器] - 一次性生成所有代码
    │
    ├─▶ Proto files (协议定义)
    ├─▶ Go structs (数据结构)
    ├─▶ RPC 路由注册 (rpc_router_generated.go)
    ├─▶ Handler 骨架 (业务逻辑模板)
    ├─▶ 序列化/反序列化代码 ⭐ 新增
    ├─▶ Constructor ID 常量 ⭐ 新增
    ├─▶ 类型转换辅助函数 ⭐ 新增
    └─▶ 单元测试骨架 ⭐ 新增
```

**关键点**：生成器一次性生成所有代码，包括辅助代码！

---

## 📋 详细实施步骤

### 第一阶段：解析 TLRPC.java (1 周)

#### 目标
从 TLRPC.java 提取所有 API 定义，生成中间格式（TL Schema）

#### 输入
- `echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/TLRPC.java`
- `echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/tl/*.java`

#### 输出
- `tl-schema.json` - 中间格式，包含所有 API 定义

#### 实现方式

**方案 1: 使用 Java 解析器**
```go
// 使用 go-java-parser 或类似工具
type TLMethod struct {
    Name       string            // "messages_sendMessage"
    Module     string            // "messages"
    Method     string            // "sendMessage"
    Request    []TLField         // 请求参数
    Response   string            // 返回类型
    Constructor int32            // TL constructor ID
}

type TLField struct {
    Name     string
    Type     string
    Optional bool
    Flags    int
}
```

**方案 2: 使用正则表达式**
```go
// 解析类定义
pattern := `public static class (TL_\w+) extends TLObject`

// 解析字段
fieldPattern := `public (\w+) (\w+);`

// 解析 constructor
constructorPattern := `public static final int constructor = (0x[0-9a-fA-F]+);`
```

#### 示例输出 (tl-schema.json)
```json
{
  "methods": [
    {
      "name": "messages_sendMessage",
      "module": "messages",
      "method": "sendMessage",
      "constructor": "0x280d096f",
      "request": [
        {
          "name": "peer",
          "type": "InputPeer",
          "optional": false
        },
        {
          "name": "message",
          "type": "string",
          "optional": false
        },
        {
          "name": "random_id",
          "type": "long",
          "optional": false
        }
      ],
      "response": "Updates"
    }
  ],
  "types": [
    {
      "name": "InputPeer",
      "constructors": [
        "inputPeerEmpty",
        "inputPeerSelf",
        "inputPeerChat",
        "inputPeerUser",
        "inputPeerChannel"
      ]
    }
  ]
}
```

---

### 第二阶段：生成 Go 代码 (1 周)

#### 目标
从 TL Schema 生成 Go 数据结构和 Proto 文件

#### 输入
- `tl-schema.json`

#### 输出
- `echo-proto/mtproto/*.proto` - Protocol Buffers 定义
- `echo-server/internal/model/*.go` - Go 数据结构
- `echo-server/internal/handler/*.go` - API 处理器骨架
- `echo-server/internal/gateway/rpc_router_generated.go` - RPC 路由注册
- `echo-server/internal/model/constructors.go` - **Constructor ID 常量** ⭐
- `echo-server/internal/model/serialization.go` - **序列化/反序列化** ⭐
- `echo-server/internal/model/converters.go` - **类型转换辅助函数** ⭐

#### 生成器实现

**1. 生成 Proto 文件**
```go
const protoTemplate = `
syntax = "proto3";
package mtproto;

message TL_{{.Name}} {
    TLConstructor constructor = 1;
    {{range .Fields}}
    {{.Type}} {{.Name}} = {{.Number}};
    {{end}}
}
`
```

**2. 生成 Go Struct**
```go
const structTemplate = `
package model

type {{.Name}} struct {
    {{range .Fields}}
    {{.Name}} {{.GoType}} ` + "`json:\"{{.JsonName}}\"`" + `
    {{end}}
}

func (m *{{.Name}}) GetConstructor() int32 {
    return {{.Constructor}}
}
`
```

**3. 生成 Constructor ID 常量** ⭐ 新增
```go
const constructorTemplate = `
// Code generated by tlrpc-codegen. DO NOT EDIT.
package model

const (
    // Auth 模块
    Constructor_auth_sendCode      = 0xa677244f
    Constructor_auth_signUp        = 0x80eee427
    Constructor_auth_signIn        = 0x8d52a951
    
    // Messages 模块
    Constructor_messages_sendMessage = 0x280d096f
    Constructor_messages_getDialogs  = 0x72ccc23d
    
    // ... 700 个 Constructor ID
)

// ConstructorName 返回 Constructor ID 对应的名称（用于调试）
var ConstructorName = map[int32]string{
    0xa677244f: "auth.sendCode",
    0x80eee427: "auth.signUp",
    // ... 700 个映射
}
`
```

**4. 生成序列化/反序列化代码** ⭐ 新增
```go
const serializationTemplate = `
// Code generated by tlrpc-codegen. DO NOT EDIT.
package model

// Serialize 序列化为字节流
func (m *{{.Name}}) Serialize() ([]byte, error) {
    buf := new(bytes.Buffer)
    
    // 写入 Constructor ID
    binary.Write(buf, binary.LittleEndian, m.GetConstructor())
    
    {{range .Fields}}
    // 写入字段: {{.Name}}
    {{if eq .Type "string"}}
    writeString(buf, m.{{.Name}})
    {{else if eq .Type "int32"}}
    binary.Write(buf, binary.LittleEndian, m.{{.Name}})
    {{else if eq .Type "int64"}}
    binary.Write(buf, binary.LittleEndian, m.{{.Name}})
    {{end}}
    {{end}}
    
    return buf.Bytes(), nil
}

// Deserialize 从字节流反序列化
func (m *{{.Name}}) Deserialize(data []byte) error {
    buf := bytes.NewReader(data)
    
    // 读取 Constructor ID
    var constructor int32
    binary.Read(buf, binary.LittleEndian, &constructor)
    if constructor != m.GetConstructor() {
        return fmt.Errorf("invalid constructor: expected %x, got %x", m.GetConstructor(), constructor)
    }
    
    {{range .Fields}}
    // 读取字段: {{.Name}}
    {{if eq .Type "string"}}
    m.{{.Name}} = readString(buf)
    {{else if eq .Type "int32"}}
    binary.Read(buf, binary.LittleEndian, &m.{{.Name}})
    {{else if eq .Type "int64"}}
    binary.Read(buf, binary.LittleEndian, &m.{{.Name}})
    {{end}}
    {{end}}
    
    return nil
}
`
```

**5. 生成类型转换辅助函数** ⭐ 新增
```go
const converterTemplate = `
// Code generated by tlrpc-codegen. DO NOT EDIT.
package model

// ToProto 转换为 Proto 类型
func (m *{{.Name}}) ToProto() *mtproto.TL_{{.Name}} {
    return &mtproto.TL_{{.Name}}{
        Constructor: m.GetConstructor(),
        {{range .Fields}}
        {{.Name}}: m.{{.Name}},
        {{end}}
    }
}

// FromProto 从 Proto 类型转换
func {{.Name}}FromProto(p *mtproto.TL_{{.Name}}) *{{.Name}} {
    return &{{.Name}}{
        {{range .Fields}}
        {{.Name}}: p.{{.Name}},
        {{end}}
    }
}
`
```

**6. 生成 RPC 路由注册**
```go
const routerTemplate = `
// Code generated by tlrpc-codegen. DO NOT EDIT.
package gateway

// RegisterRPCRoutes 注册所有 RPC 路由（自动生成）
func (s *Server) RegisterRPCRoutes() {
    {{range .Methods}}
    s.rpcHandlers[{{.Constructor}}] = s.handle{{.Name}}
    {{end}}
}

{{range .Methods}}
func (s *Server) handle{{.Name}}(ctx context.Context, req *mtproto.TL_{{.RequestType}}) (*mtproto.{{.ResponseType}}, error) {
    return s.{{.Module}}Handler.{{.Method}}(ctx, req)
}
{{end}}
`
```

**7. 生成单元测试骨架** ⭐ 新增
```go
const testTemplate = `
// Code generated by tlrpc-codegen. DO NOT EDIT.
package model

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func Test{{.Name}}_Serialize(t *testing.T) {
    obj := &{{.Name}}{
        {{range .Fields}}
        {{.Name}}: {{.TestValue}},
        {{end}}
    }
    
    data, err := obj.Serialize()
    assert.NoError(t, err)
    assert.NotEmpty(t, data)
    
    // 反序列化验证
    obj2 := &{{.Name}}{}
    err = obj2.Deserialize(data)
    assert.NoError(t, err)
    assert.Equal(t, obj, obj2)
}

func Test{{.Name}}_Constructor(t *testing.T) {
    obj := &{{.Name}}{}
    assert.Equal(t, int32({{.Constructor}}), obj.GetConstructor())
}
`
```

---

### 第三阶段：生成 RPC 路由注册 (3 天) ⭐ 关键

#### 目标
自动生成 RPC 路由注册代码，**一次性注册所有 668 个 API**

#### 输出
- `echo-server/internal/gateway/rpc_router_generated.go` - 自动生成的路由注册

#### 为什么需要自动生成路由

**当前问题**：
- 手动注册 668 个 API 路由 = 700 行重复代码
- 容易遗漏或写错
- 维护成本高

**自动生成的好处**：
- ✅ 一次性生成 700 个路由注册
- ✅ 保证不遗漏任何 API
- ✅ Constructor ID 自动匹配
- ✅ 类型安全

#### 生成的代码示例

```go
// Code generated by tlrpc-codegen. DO NOT EDIT.
package gateway

import (
    "context"
    "github.com/jackyang1989/echo-proto/mtproto"
    "github.com/jackyang1989/echo-server/internal/handler"
)

// RegisterRPCRoutes 注册所有 RPC 路由（自动生成）
func (s *Server) RegisterRPCRoutes() {
    // Auth 模块 (15 个 API)
    s.rpcHandlers[0xa677244f] = s.handleAuthSendCode
    s.rpcHandlers[0x80eee427] = s.handleAuthSignUp
    s.rpcHandlers[0x8d52a951] = s.handleAuthSignIn
    // ... 其他 12 个

    // Messages 模块 (200+ 个 API)
    s.rpcHandlers[0x280d096f] = s.handleMessagesSendMessage
    s.rpcHandlers[0x72ccc23d] = s.handleMessagesGetDialogs
    // ... 其他 200+ 个

    // Users 模块 (50+ 个 API)
    s.rpcHandlers[0x0d91a548] = s.handleUsersGetUsers
    s.rpcHandlers[0xca30a5b1] = s.handleUsersGetFullUser
    // ... 其他 50+ 个

    // 总共 668 个 API 路由
}

// Auth 模块 Handler
func (s *Server) handleAuthSendCode(ctx context.Context, req *mtproto.TL_auth_sendCode) (*mtproto.TL_auth_sentCode, error) {
    return s.authHandler.SendCode(ctx, req)
}

func (s *Server) handleAuthSignUp(ctx context.Context, req *mtproto.TL_auth_signUp) (*mtproto.TL_auth_authorization, error) {
    return s.authHandler.SignUp(ctx, req)
}

// Messages 模块 Handler
func (s *Server) handleMessagesSendMessage(ctx context.Context, req *mtproto.TL_messages_sendMessage) (*mtproto.Updates, error) {
    return s.messagesHandler.SendMessage(ctx, req)
}

// ... 其他 697 个 handler
```

#### 使用方式

在 `server_gnet.go` 中调用：
```go
func (s *Server) Start() error {
    // 注册所有 RPC 路由（自动生成）
    s.RegisterRPCRoutes()
    
    // 启动服务器
    return s.engine.Start()
}
```
package gateway

// Auto-generated by tlrpc-codegen
// DO NOT EDIT

func (s *Server) registerGeneratedRoutes() {
    {{range .Modules}}
    // {{.Name}} module ({{.Count}} methods)
    {{range .Methods}}
    s.router.Register("{{.FullName}}", s.handle{{.HandlerName}})
    {{end}}
    {{end}}
}

{{range .Modules}}
{{range .Methods}}
func (s *Server) handle{{.HandlerName}}(ctx context.Context, req []byte) ([]byte, error) {
    var request model.TL_{{.RequestType}}
    if err := request.Decode(req); err != nil {
        return nil, err
    }
    
    response, err := s.{{.Module}}Handler.{{.Method}}(ctx, &request)
    if err != nil {
        return nil, err
    }
    
    return response.Encode()
}
{{end}}
{{end}}
`
```

---

### 第四阶段：验证和测试 (1 周)

#### 验证步骤

1. **编译验证**
   ```bash
   cd echo-proto
   protoc --go_out=. --go-grpc_out=. mtproto/*.proto
   
   cd echo-server
   go build ./...
   ```

2. **API 数量验证**
   ```bash
   # 统计生成的 API 数量
   grep -r "rpc " echo-proto/mtproto/*.proto | wc -l
   # 应该输出: 700
   ```

3. **类型完整性验证**
   ```bash
   # 检查所有类型是否都有定义
   ./tools/validate-types.sh
   ```

4. **客户端兼容性测试**
   ```bash
   # 使用客户端测试基础 API
   ./test-client-compatibility.sh
   ```

---

## � 类型映射表

### Java → Go 基础类型

| Java 类型 | Go 类型 | TL 类型 | 序列化方式 |
|----------|--------|---------|-----------|
| `int` | `int32` | `int` | 4 bytes LE |
| `long` | `int64` | `long` | 8 bytes LE |
| `boolean` | `bool` | `Bool` | TL_boolTrue/False |
| `String` | `string` | `string` | length + bytes |
| `byte[]` | `[]byte` | `bytes` | length + bytes |
| `double` | `float64` | `double` | 8 bytes LE |

### 复杂类型映射

| Java 类型 | Go 类型 | 说明 |
|----------|--------|------|
| `ArrayList<T>` | `[]T` | TL Vector |
| `HashMap<K,V>` | `map[K]V` | 少见，按需处理 |
| `TLObject` | `interface{}` | 动态类型 |
| `InputPeer` | `*InputPeer` | 抽象基类 → 指针 |
| `flags & N` | `optional` | 可选字段 |

### Flags 处理规则

```java
// Java 代码
if ((flags & 1) != 0) {
    something = stream.readString(exception);
}
```

映射为 Go：
```go
// Go 代码
type TL_xxx struct {
    Flags     int32
    Something *string `tl:"flag:0"` // bit 0
}
```

---

## ⚠️ 已知难点

### 1. Flags 可选字段处理

**问题**：TLRPC.java 大量使用 `flags & N` 模式
```java
if ((flags & 2) != 0) {
    reply_to_msg_id = stream.readInt32(exception);
}
```

**解决方案**：
- 解析 `if ((flags & N) != 0)` 模式
- 提取 bit 位置和字段名
- 生成带 `tl:"flag:N"` 标签的 Go struct

### 2. 层版本兼容 (Layer)

**问题**：存在大量 `TL_xxx_layerXXX` 类
```java
TL_chatPhoto_layer115
TL_chatPhoto_layer126
TL_chatPhoto_layer127
TL_chatPhoto  // 最新版本
```

**解决方案**：
- 只生成最新版本（无 `_layerXXX` 后缀）
- Layer 版本类用于向后兼容解析
- 记录当前 LAYER = 221

### 3. 嵌套类型和 Vector

**问题**：
```java
public ArrayList<MessageEntity> entities = new ArrayList<>();
```

**解决方案**：
- 识别 `ArrayList<T>` 模式
- 提取内部类型 T
- 生成 `[]T` 类型

### 4. 抽象类和多态

**问题**：
```java
public abstract class InputPeer extends TLObject { }
public static class TL_inputPeerUser extends InputPeer { }
public static class TL_inputPeerChat extends InputPeer { }
```

**解决方案**：
- 抽象类 → Go interface
- 具体类 → 实现 interface 的 struct
- TLdeserialize 方法 → Constructor switch

### 5. Constructor ID 提取

**问题**：Constructor ID 分散在各处
```java
public static final int constructor = 0x4345be73;
```

**解决方案**：
- 正则提取：`constructor = (0x[0-9a-fA-F]+)`
- 建立 Constructor → Type 映射表
- 验证无重复

---

## 🔄 增量更新策略

### 为什么需要增量更新

- Telegram 频繁更新（每几周一次）
- 全量重新生成会覆盖手动修改
- 需要保留已实现的业务逻辑

### 增量更新流程

```
1. 解析新版 TLRPC.java → new_schema.json
2. 加载旧版 schema → old_schema.json
3. 对比差异 → diff.json
   - 新增 API
   - 删除 API
   - 修改字段
4. 只生成变化的部分
5. 人工审核变更
```

### 差异检测逻辑

```go
type SchemaDiff struct {
    Added   []TLMethod   // 新增的 API
    Removed []TLMethod   // 删除的 API
    Changed []MethodDiff // 字段变化的 API
}

type MethodDiff struct {
    Name        string
    AddedFields []TLField
    RemovedFields []TLField
    ChangedFields []FieldDiff
}
```

### 生成模式

| 模式 | 命令 | 说明 |
|------|------|------|
| 全量生成 | `./tlrpc-codegen generate --mode=full` | 首次生成 |
| 增量生成 | `./tlrpc-codegen generate --mode=incremental` | 更新时 |
| 仅报告 | `./tlrpc-codegen diff --report-only` | 查看变更 |

### 保护文件

```yaml
# config.yaml
protected_files:
  - internal/handler/auth_impl.go    # 已实现的业务逻辑
  - internal/handler/messages_impl.go
  
regenerate_files:
  - internal/model/*.go              # 数据结构可重新生成
  - internal/gateway/rpc_router_generated.go
```

---

## �🛠️ 生成器工具设计

### 工具结构

```
tools/tlrpc-codegen/
├── main.go                 # 主程序
├── parser/
│   ├── java_parser.go     # 解析 TLRPC.java
│   ├── schema.go          # TL Schema 数据结构
│   └── validator.go       # 验证解析结果
├── generator/
│   ├── proto_gen.go       # 生成 .proto 文件
│   ├── go_gen.go          # 生成 Go 代码
│   ├── handler_gen.go     # 生成 Handler 骨架
│   └── router_gen.go      # 生成路由注册
├── templates/
│   ├── proto.tmpl
│   ├── struct.tmpl
│   ├── handler.tmpl
│   └── router.tmpl
└── config.yaml            # 生成器配置
```

### 使用方式

```bash
# 1. 解析 TLRPC.java
./tlrpc-codegen parse \
  --input echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/TLRPC.java \
  --output tl-schema.json

# 2. 生成代码
./tlrpc-codegen generate \
  --schema tl-schema.json \
  --output-proto echo-proto/mtproto \
  --output-go echo-server/internal/model \
  --output-handler echo-server/internal/handler

# 3. 验证
./tlrpc-codegen validate \
  --schema tl-schema.json \
  --proto-dir echo-proto/mtproto

# 4. 一键生成（推荐）
./tlrpc-codegen all \
  --input echo-android-client/TMessagesProj/src/main/java/com/echo/tgnet/TLRPC.java \
  --output-dir .
```

---

## 📊 工作量估算

### 详细分工

| 阶段 | 任务 | 工作量 | 产出 |
|------|------|--------|------|
| **第一阶段** | 解析 TLRPC.java | 5 天 | tl-schema.json |
| | - 设计 Schema 格式 | 1 天 | |
| | - 实现 Java 解析器 | 3 天 | |
| | - 验证解析结果 | 1 天 | |
| **第二阶段** | 生成 Go 代码 | 5 天 | .proto + .go |
| | - 设计模板 | 1 天 | |
| | - 实现 Proto 生成器 | 2 天 | |
| | - 实现 Go 生成器 | 2 天 | |
| **第三阶段** | 生成路由注册 | 3 天 | router.go |
| | - 设计路由结构 | 1 天 | |
| | - 实现路由生成器 | 2 天 | |
| **第四阶段** | 验证和测试 | 5 天 | 测试报告 |
| | - 编译验证 | 1 天 | |
| | - API 数量验证 | 1 天 | |
| | - 类型完整性验证 | 2 天 | |
| | - 客户端兼容性测试 | 1 天 | |
| **总计** | | **18 天** | **完整代码** |

### 对比手动方式

| 方案 | 初始工作量 | 维护成本 | 版本同步 | 错误率 |
|------|-----------|---------|---------|--------|
| **手动补充** | 6-9 个月 | 高 | 困难 | 高 |
| **自动生成** | 3-4 周 | 低 | 自动 | 低 |

---

## 🎯 长期收益

### 1. 版本同步

**Telegram 更新时**:
```bash
# 1. 更新客户端
cd echo-android-client
git pull upstream master

# 2. 重新生成
cd ../tools/tlrpc-codegen
./tlrpc-codegen all --input ../../echo-android-client/...

# 3. 编译验证
cd ../../echo-server
go build ./...

# 总耗时: 1-2 小时
```

### 2. 零版本漂移

- ✅ 客户端和服务端始终使用相同的 API 定义
- ✅ 不会出现"客户端有但服务端没有"的情况
- ✅ 不会出现"服务端实现了但客户端不用"的情况

### 3. 降低维护成本

- ✅ 不需要手动维护 668 个 API
- ✅ 不需要手动同步 Telegram 更新
- ✅ 不需要担心人工错误

### 4. 提高开发效率

- ✅ 新功能开发只需实现业务逻辑
- ✅ 不需要手动编写数据结构和路由
- ✅ 代码生成器保证一致性

---

## 📝 实施建议

### 立即开始

1. **Week 1**: 实现 TLRPC.java 解析器
2. **Week 2**: 实现代码生成器
3. **Week 3**: 生成代码并验证
4. **Week 4**: 测试和优化

### 并行工作

- 生成器开发期间，可以继续使用现有的 echo-proto
- 生成器完成后，一次性替换
- 降低风险，不影响现有开发

### 渐进式迁移

1. **第一步**: 生成所有代码
2. **第二步**: 保留现有实现，新增生成的骨架
3. **第三步**: 逐步迁移现有实现到新结构
4. **第四步**: 删除旧代码

---

## 🚀 总结

### 为什么采用这个方案

1. **权威来源**: TLRPC.java 是客户端使用的真实定义
2. **100% 完整**: 保证所有 668 个 API 都有
3. **自动同步**: Telegram 更新时只需重新运行生成器
4. **长期收益**: 初始投入 3-4 周，避免 6-9 个月手动工作
5. **零漂移**: 客户端和服务端始终一致

### 下一步行动

1. ✅ 立即开始开发生成器
2. ✅ 3-4 周完成
3. ✅ 一次性生成完整 668 个 API 定义（放弃不完整的 teamgram-proto）
4. ✅ 未来 Telegram 更新自动同步

---

**最后更新**: 2026-02-07  
**维护者**: Echo 项目团队  
**状态**: 🚀 推荐立即实施


---

## 📚 补充：TDLib 作为参考 (2026-02-08)

### 什么是 TDLib

[TDLib](https://github.com/tdlib/td) 是 Telegram 官方的跨平台客户端库，包含：
- `td_api.tl` - 标准 TL Schema 定义
- 代码生成器 (`generate_java.py`, `generate_c.py`)
- 完整的 MTProto 实现

### 三层参考架构

```
┌─────────────────────────────────────────────────┐
│  Layer 1: 主要来源 (TLRPC.java + tl/*.java)     │
│  - 与 echo-android-client 完全一致              │
│  - 保证客户端-服务端兼容性                       │
│  - 668 个 API (100% 完整)                        │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Layer 2: 验证和补充 (TDLib td_api.tl)          │
│  - 验证 API 定义的正确性                         │
│  - 理解 TL 语法和类型系统                        │
│  - 参考代码生成器实现                            │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│  Layer 3: 协议参考 (Telegram API Schema)        │
│  - 理解 API 语义                                 │
│  - 补充文档注释                                  │
└─────────────────────────────────────────────────┘
```

### 如何使用

**克隆 TDLib**：
```bash
git clone https://github.com/tdlib/td.git tdlib
```

**在生成器中的作用**：
1. 验证从 TLRPC.java 提取的 API 定义是否正确
2. 学习如何解析 TL 语法和处理复杂类型
3. 参考官方代码生成器实现 (`generate_java.py`)

---

**文档更新**: 2026-02-08  
**更新内容**: 新增 TDLib 作为参考资源
