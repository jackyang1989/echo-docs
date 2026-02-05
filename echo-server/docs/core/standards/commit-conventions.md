# Echo Server 提交规范（Commit Conventions）

提交信息必须清晰、可追溯，并与变更记录对应。

## 1. 格式
```
type(scope): [ECHO-XXX] 变更概要
```

## 2. type 列表
- feat: 新功能
- fix: Bug 修复
- docs: 文档更新
- style: 代码格式（不影响逻辑）
- refactor: 重构（不改变行为）
- perf: 性能优化
- test: 测试相关
- chore: 构建/依赖/杂项
- revert: 回滚
- rebrand: 品牌命名修正

## 3. scope 建议
- gateway / auth / user / message / sync / storage / config / docs

## 4. 变更 ID
- 新功能使用 `ECHO-FEATURE-XXX`
- Bug 修复使用 `ECHO-BUG-XXX`
- 性能优化使用 `ECHO-OPT-XXX`

## 5. 示例
```
feat(gateway): [ECHO-FEATURE-012] 支持 getDifference 基础路径
fix(auth): [ECHO-BUG-021] 修复验证码过期判断错误
docs(core): [ECHO-DOCS-003] 更新核心文档索引
```

## 6. 规则
- 禁止 WIP、临时性描述。
- 提交信息必须与 `docs/core/changes/` 中记录一致。

