# Echo Proto 生成策略

**文档版本**: 1.0  
**最后更新**: 2026-02-07  
**状态**: 方案设计

---

## 🎯 问题分析

### 当前困境

- ✅ **echo-android-client**: 700 个 API (100% 完整)
- ❌ **echo-proto**: 约 150 个 API (21% 完整)
- 🔴 **缺口**: 约 550 个 API 需要补充

### 两个选择

#### 选项 A：继续用 teamgram-proto 手动补齐

**优点**:
- ✅ 已有 Go 代码结构
- ✅ 熟悉现有代码
- ✅ 可以渐进式补充

**缺点**:
- ❌ 需要手动补充 550 个 API（工作量巨大）
- ❌ teamgram 更新慢，可能跟不上 Telegram
- ❌ 容易出现版本漂移
- ❌ 维护成本高
- ❌ 人工编写容易出错

**预计工作量**: 6-9 个月

---

#### 选项 B：从 TLRPC.java 自动生成 ✅ 推荐

**优点**:
- ✅ TLRPC.java 是权威来源（客户端用什么，服务端就实现什么）
- ✅ 100% 完整（700 个 API）
- ✅ 与客户端完全一致（零版本漂移）
- ✅ 自动生成工具 - 写一次，以后 Telegram 更新可以自动同步
- ✅ 一劳永逸
- ✅ 避免人工错误

**缺点**:
- ⚠️ 需要写生成器（初始工作量）
- ⚠️ 需要理解 TLRPC.java 结构
- ⚠️ 需要设计生成规则

**预计工作量**: 
- 生成器开发: 2-3 周
- 生成代码验证: 1 周
- **总计**: 3-4 周

---

## ✅ 推荐方案：选项 B

### 核心理由

1. **TLRPC.java 是权威来源**
   - 客户端用什么，服务端就实现什么
   - 保证 100% 兼容性

2. **自动生成工具**
   - 写一次，以后 Telegram 更新可以自动同步
   - 避免手动维护 550 个 API

3. **避免版本漂移**
   - teamgram 可能跟不上 Telegram 更新
   - 自动生成保证与客户端完全一致

4. **长期收益**
   - 初始投入 3-4 周
   - 但避免了 6-9 个月的手动工作
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
    ├─▶ Proto files (gRPC 协议定义)
    ├─▶ Go structs (服务端数据结构)
    ├─▶ RPC 路由注册 (rpc_router_generated.go) ⭐
    ├─▶ API Handler 骨架 (handler 模板)
    └─▶ 测试代码骨架
```

**关键点**：生成器一次性生成所有代码，包括 RPC 路由注册！

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

#### 生成器实现

**1. 生成 Proto 文件**
```go
// 模板
const protoTemplate = `
syntax = "proto3";

package mtproto;

// {{.Comment}}
message TL_{{.Name}} {
    TLConstructor constructor = 1;
    {{range .Fields}}
    {{.Type}} {{.Name}} = {{.Number}};
    {{end}}
}

service RPC{{.Module}} {
    {{range .Methods}}
    rpc {{.Name}}(TL_{{.RequestType}}) returns ({{.ResponseType}}) {}
    {{end}}
}
`

// 生成代码
func GenerateProto(schema *TLSchema) string {
    tmpl := template.Must(template.New("proto").Parse(protoTemplate))
    var buf bytes.Buffer
    tmpl.Execute(&buf, schema)
    return buf.String()
}
```

**2. 生成 Go Struct**
```go
// 模板
const structTemplate = `
package model

// {{.Comment}}
// Constructor: {{.Constructor}}
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

**3. 生成 Handler 骨架**
```go
// 模板
const handlerTemplate = `
package handler

import (
    "context"
    "github.com/jackyang1989/echo-server/internal/model"
)

// {{.Comment}}
// API: {{.Module}}.{{.Method}}
func (h *{{.Module}}Handler) {{.Method}}(ctx context.Context, req *model.TL_{{.RequestType}}) (*model.{{.ResponseType}}, error) {
    // TODO: Implement {{.Module}}.{{.Method}}
    return nil, errors.New("not implemented")
}
`
```

---

### 第三阶段：生成路由注册 (3 天)

#### 目标
自动生成 API 路由注册代码

#### 输出
- `echo-server/internal/gateway/rpc_router_generated.go`

#### 生成器实现

```go
const routerTemplate = `
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

## 🛠️ 生成器工具设计

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

- ✅ 不需要手动维护 700 个 API
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

### 为什么选择选项 B

1. **权威来源**: TLRPC.java 是客户端使用的真实定义
2. **100% 完整**: 保证所有 700 个 API 都有
3. **自动同步**: Telegram 更新时只需重新运行生成器
4. **长期收益**: 初始投入 3-4 周，避免 6-9 个月手动工作
5. **零漂移**: 客户端和服务端始终一致

### 下一步行动

1. ✅ 立即开始开发生成器
2. ✅ 3-4 周完成
3. ✅ 一次性解决 550 个 API 缺失问题
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
│  - 700 个 API (100% 完整)                        │
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
