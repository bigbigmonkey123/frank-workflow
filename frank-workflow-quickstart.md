# Frank Workflow — 开发协作规范

## 术语

| 术语 | 定义 |
|------|------|
| FTW | For The Win — 用户明确授权（"开始/go/确认"） |
| MR | Merge Request（GitLab） |
| Blocking | 必须解决才能推进的发现 |
| Tracked change | 已进入 git 追踪的代码/配置/文档变更 |

## 角色

| 角色 | 职责 | 谁 |
|------|------|----|
| Developer | 实现 + 本地单元测试 | Codex / Backend agent |
| QA | 独立验收 + MR approve/merge | frank_qa / QA agent |
| Reviewer | Pre-dev / Post-dev review gate | Codex review 主力，Grok/Claude 备份（必须独立于执行该任务的 Developer 实例） |
| Scout | 辅助侦查、广域上下文（可选） | Gemini |
| Human | 开发授权(FTW) + 生产部署确认 | 用户本人 |

Reviewer 必须独立于 Developer；实现者不能做最终 review；Developer 不能自己 approve MR。

## 路径

### Compact Path（简单改动）

```
检查 → 最小改动 → 本地测试 → 独立 review → QA 验收 → 报告
```

适用：单文件修改、配置调整、文档更新、无线上影响的改动。命中 Full Gated 风险触发器时，即使只改一个文件也走 Full。

### Full Gated Path（中高风险）

```
调研 → 设计方案 → Pre-dev review → [FTW] → 实现
  → Commit/MR → Post-dev review → QA approve/merge → 部署 gate → 收尾
```

适用：DB schema/migration、auth、支付、部署、跨服务契约、并发、重试、缓存、多文件联动、影响线上行为。

### 例外路径

- **纯查询/诊断**：无 gate，直接执行并报告（保留命令输出/日志作为证据）
- **紧急止血**：需用户授权，执行后立即健康检查，review/QA/回滚记录事后补

## 自动推进（不停不问）

- 普通 `REVISE`（review 轮次预算内）
- 单测/集成/lint/docs/build 失败（当前 changeset 涉及的文件内可修，无需新设计决策）
- Scout advisory 反馈
- 可逆的本地测试
- 代码改动导致的 review 失效 → 自动重新 review

## Hard Stop（必须停下）

- 生产部署 / 流量切换
- 真金白银 / mainnet / 付费资源
- 凭据 / 权限变更
- 破坏性 / 不可逆操作
- 超出批准 scope 的文件或系统
- 发现设计方案被推翻
- 新未审查依赖（有信任影响）
- 需求关键点无法安全推断
- review 多轮仍不收敛（先缩小 diff + 补证据 + fresh review，确认无法收敛后升级 Human）

## Review Gate 规则

**Pre-dev**：中高风险必须先 review 设计方案（scope、非目标、风险、回滚）。Blocking 必须解决后才能开发。

**Post-dev**：Reviewer 收到 exact diff + 开发测试结果 + 回滚方案 + blocking 关闭记录 + docs-impact 检查。有 blocking → `REVISE`。

**失效规则**：approval 绑定到 reviewed 的 commit SHA。后续 deliverable 变更（代码/配置/文档）自动失效，按 Post-dev review → QA 顺序重跑。MR 元数据（标签、描述）变更不触发失效。

**自动 Revision**：`REVISE` 在轮次预算内自动回到实现→re-review，不是暂停点。默认预算：设计/final gate 2 轮，重实现 3 轮。

## Review Monitoring Protocol

每次 review 提交后，发起方必须全程监控 reviewer 状态，禁止 send 后不管。

### 三阶段监控

1. **确认收到**：`send` 后 30 秒内必须观察到 reviewer heartbeat，否则判定未收到（exit 2）
2. **持续监控**：等待期间每 60 秒检查 heartbeat 新鲜度
3. **卡死判定**：heartbeat 超过 5 分钟未更新 → 判定进程卡死（exit 3）

### 恢复策略

卡死发生时按顺序执行：
1. 终止当前 reviewer 进程
2. 降级到备用 reviewer（Codex → Grok → Claude）
3. 备用仍失败 → 上报 Human

### Agent 职责

- 发起 review 时必须启动 `review-monitor` 或等效监控
- 每次 review 结束记录：task_id、耗时、轮次、是否触发重试
- `bridge health <task-id>` 可随时查询单个 review 状态

### 工具

```bash
# 监控脚本（阻塞直到完成或异常）
review-monitor <artifact-root> <task-id> [--receipt-timeout 30] [--check-interval 60] [--stale-threshold 300]

# 即时状态查询
bridge health <task-id>
# 返回: alive|stale|dead|done + age + last_heartbeat
```

## Deploy Gate

Prod 部署属于 Hard Stop，必须满足：

1. Human 明确确认（"部署到 prod"）
2. 部署前备份，汇报备份路径
3. 部署后健康检查（HTTP status、关键日志）
4. MR 中记录回滚方案

## Verdict 格式

```
VERDICT: APPROVED | APPROVED_WITH_RISKS | REVISE
FINDINGS:
RECOMMENDATIONS:
EVIDENCE:
```

- 任何 blocking finding → `REVISE`
- `APPROVED_WITH_RISKS`：可推进，但风险记入 MR 描述并 post-deploy 监控；若含 high 级风险则升级为 Human gate
- Suggestion 可接受或附理由拒绝
