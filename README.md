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

## Base URL：两种环境

sub2api 方案的脚本（dpsk / codex-sub2api）支持两种运行环境，通过第二参数切换：

| 环境 | 参数 | Base URL | 适用场景 |
|------|------|----------|----------|
| **LightOS**（默认） | `lightos` 或不传 | `http://host.lzcapp:8888` | 懒猫虚拟环境内部 |
| **Zen** | `zen` 或 `wsl` | `https://sub2api.zen.heiyu.space` | WSL / 普通 Linux |

> **Zen 环境前置条件**：需要先配好 hclient 组网，否则 `sub2api.zen.heiyu.space` 不可达。详见 `hclient` skill。

---

## 1. setup-claude-dpsk.sh

配置 Claude Code，使用 sub2api 的 deepseek-v4 模型。

### 快速使用

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-claude-dpsk.sh
chmod +x setup-claude-dpsk.sh
# LightOS（默认）
./setup-claude-dpsk.sh
# Zen / WSL
./setup-claude-dpsk.sh "" zen
```

也可以直接传 key：

```bash
# LightOS
./setup-claude-dpsk.sh "你的apikey"
# Zen / WSL
./setup-claude-dpsk.sh "你的apikey" zen
```

### 写入的环境变量

| 变量 | LightOS | Zen |
|------|---------|-----|
| `ANTHROPIC_BASE_URL` | `http://host.lzcapp:8888` | `https://sub2api.zen.heiyu.space` |
| `ANTHROPIC_AUTH_TOKEN` | 你输入的 key | 你输入的 key |
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-v4-pro[1m]` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-v4-pro[1m]` | `deepseek-v4-pro[1m]` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-v4-flash` | `deepseek-v4-flash` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` | `deepseek-v4-flash` |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` | `max` |

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
# LightOS（默认）
./setup-codex-sub2api.sh
# Zen / WSL
./setup-codex-sub2api.sh "" zen
```

也可以直接传 key：

```bash
# LightOS
./setup-codex-sub2api.sh "你的apikey"
# Zen / WSL
./setup-codex-sub2api.sh "你的apikey" zen
```

### 写入内容

- `~/.codex/config.toml` — CodeX 主配置（模型 gpt-5.5，provider sub2api，base_url 随环境变化）
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
- sub2api 脚本额外支持第二参数选环境：`./xxx.sh "key" zen`

### Zen 环境前置条件

在 WSL 或普通 Linux 上使用 `zen` 模式前，需要 hclient 组网已通：

```bash
# 检查 hclient 状态
wsl -d Ubuntu-20.04 -e systemctl is-active hclient.service
# 验证 sub2api 可达
curl -s -o /dev/null -w '%{http_code}' https://sub2api.zen.heiyu.space
```

返回 200 即表示可达。hclient 配置详见 `hclient` skill。
