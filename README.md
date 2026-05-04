# setup-claude-codex

Linux 上一键清理旧配置并配置 Claude Code / CodeX 的脚本集合。

---

## 脚本列表

| 脚本 | 用途 | 方案 |
|------|------|------|
| `setup-claude-dpsk.sh` | Claude Code (cc) | sub2api / dpsk |
| `setup-claude-codesome.sh` | Claude Code (cc) | Codesome |
| `setup-codex-sub2api.sh` | CodeX | sub2api |
| `setup-codex-codesome.sh` | CodeX | Codesome |

---

## 1. setup-claude-dpsk.sh

配置 Claude Code，使用 sub2api 的 deepseek-v4 模型。

### 快速使用

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-claude-dpsk.sh
chmod +x setup-claude-dpsk.sh
./setup-claude-dpsk.sh
```

也可以直接传 key：

```bash
./setup-claude-dpsk.sh "你的apikey"
```

### 写入的环境变量

| 变量 | 值 |
|------|-----|
| `ANTHROPIC_BASE_URL` | `http://host.lzcapp:8888` |
| `ANTHROPIC_AUTH_TOKEN` | 你输入的 key |
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` |

### 验证

```bash
claude
```

---

## 2. setup-claude-codesome.sh

配置 Claude Code，使用 Codesome 官方 API 地址（`https://cc.codesome.ai`）。

### 快速使用

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-claude-codesome.sh
chmod +x setup-claude-codesome.sh
./setup-claude-codesome.sh
```

也可以直接传 key：

```bash
./setup-claude-codesome.sh "sk-..."
```

### 写入的环境变量

| 变量 | 值 |
|------|-----|
| `ANTHROPIC_BASE_URL` | `https://cc.codesome.ai` |
| `ANTHROPIC_AUTH_TOKEN` | 你输入的 key |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` |

> 与 dpsk 方案不同，此方案不设置 `ANTHROPIC_MODEL` 等模型覆盖变量。脚本会自动清理之前 dpsk 方案残留的模型环境变量。

### 验证

```bash
claude
```

---

## 3. setup-codex-sub2api.sh

配置 CodeX（OpenAI CLI），使用 sub2api 方案，模型 gpt-5.5。

### 快速使用

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-codex-sub2api.sh
chmod +x setup-codex-sub2api.sh
./setup-codex-sub2api.sh
```

也可以直接传 key：

```bash
./setup-codex-sub2api.sh "你的apikey"
```

### 写入内容

- `~/.codex/config.toml` — CodeX 主配置（模型 gpt-5.5，provider sub2api）
- shell 配置中写入 `CODEX_HOME` 和 `SUB2API_API_KEY`

### 验证

```bash
codex
```

---

## 4. setup-codex-codesome.sh

配置 CodeX（OpenAI CLI），使用 Codesome 方案，模型 gpt-5.5。

### 快速使用

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-codex-codesome.sh
chmod +x setup-codex-codesome.sh
./setup-codex-codesome.sh
```

也可以直接传 key：

```bash
./setup-codex-codesome.sh "sk-..."
```

### 写入内容

- `~/.codex/config.toml` — CodeX 主配置（模型 gpt-5.5，provider codesome，地址 `https://cc.codesome.ai/v1`）
- shell 配置中写入 `CODEX_HOME` 和 `CODESOME_API_KEY`

### 验证

```bash
codex
```

---

## 通用说明

全部脚本均：

- **交互式**：运行后只需输入 API Key，其余全自动
- 自动检测 bash / zsh
- 先清理旧配置（环境变量、shell 配置文件、残留 JSON/TOML），再写入新配置
- 支持命令行参数传 key，方便自动化：`./xxx.sh "key"`
