---
name: git-pr-workflow
description: Standardize git commit/push and GitHub PR workflow with review gates. Use when the user asks to commit code, push, open/create a PR, or wants PR review/audit/checklist. Uses Conventional Commits and gh CLI, prompts for reviewers, targets base branch main by default.
---

# Git 提交 + PR 审核工作流（GitHub/gh）

## 适用场景（触发词）

- 用户提到：提交/commit、暂存区/staged、push、开 PR / pull request、合并、review/审核、检查改动、发布前自检

## 约定

- **提交规范**：优先使用 Conventional Commits（`type(scope): subject`）
- **目标分支**：默认 `main`
- **Reviewers**：创建 PR 时需要交互询问（可多选/可为空）
- **安全要求**：不要提交 `.env` 等敏感文件；PR 中必须明确测试方式/风险点

## 工作流（必须按顺序执行）

### 1) 预检：确认仓库状态与变更范围

- 运行并阅读：
  - `git status`
  - `git diff`（未暂存）
  - `git diff --staged`（已暂存）
  - `git log -10 --oneline`（风格参考）
- 若存在可疑敏感文件（如 `.env`、密钥、证书），**停止**并提示用户处理。

### 2) 分支策略：避免直接在 main 上做特性开发

- 若当前在 `main` 且存在业务/功能/较大变更：
  - 新建分支：`git checkout -b <branch-name>`
  - 分支名建议：`feat/...`、`fix/...`、`chore/...`、`docs/...`
- 若只是小修复且用户明确允许，也可在 `main` 上提交（但仍推荐分支）。

### 3) 生成 commit message（Conventional Commits）

- 根据 diff 内容选择 `type`：
  - `feat`/`fix`/`docs`/`refactor`/`perf`/`test`/`build`/`ci`/`chore`/`revert`
- `scope`：
  - 按模块/目录：如 `android`、`build`、`docs`、`repo`
- `subject`：
  - 一句话描述“目的”，避免含糊（不要只写 update/fix bug）
- 推荐模板：
  - 标题：`type(scope): subject`
  - 正文：1–5 行解释 why + 关键影响（可选）

### 4) 提交（仅提交用户期望的内容）

- 若用户说“提交暂存区”：只 `git commit`（不要额外 `git add`）
- 若用户说“把改动都提交”：先 `git add ...` 再提交
- 提交后必须 `git status` 确认干净或符合预期。

### 5) 推送到远端

- 先确认远端：`git remote -v`
- 推送：
  - 首次推送分支：`git push -u origin HEAD`
  - 已有上游：`git push`

### 6) 创建 PR（GitHub + gh）

- 创建前确认：
  - base 分支默认 `main`
  - PR 标题：尽量与 commit 标题对齐（更可读）
- 收集 reviewers（交互询问，可为空）
- 使用 `gh pr create` 创建 PR：
  - 标题：一句话
  - Body：必须包含 Summary + Test plan + Risk/Notes

建议 PR Body 模板：

```markdown
## Summary
- <1-3 条要点：改动目的与范围>

## Test plan
- [ ] 本地构建/运行通过（写明命令）
- [ ] 核心路径手工验证（写明步骤）

## Risk / Notes
- <潜在风险、回滚方式、兼容性影响>
```

### 7) PR 审核机制（自检门禁）

在 PR 创建后，必须完成以下自检并在 PR 描述或评论中体现：

- **变更正确性**
  - [ ] 变更与需求一致，边界条件考虑到位
  - [ ] 无明显回归风险（关键路径已验证）
- **代码质量**
  - [ ] 命名清晰、结构合理、无重复逻辑
  - [ ] 错误处理与日志足够（若适用）
- **安全与合规**
  - [ ] 无 `.env`/密钥/证书/私人域名等敏感信息进入仓库
  - [ ] 仅提交必要文件（避免 dist、构建产物等）
- **可维护性**
  - [ ] README/文档同步更新（若影响使用方式）
  - [ ] 变更影响范围已在 PR Summary 说明
- **可验证性**
  - [ ] 写清楚 Test plan（可复现）
  - [ ] 若无法自动化测试，说明原因与替代验证方式

## 常用命令速查

- 变更检查：`git status` / `git diff` / `git diff --staged`
- 提交：`git commit -m "..."`
- 推送：`git push -u origin HEAD`
- 创建 PR：`gh pr create --base main --title "..." --body "..."`
- 查看 PR：`gh pr view --web`

