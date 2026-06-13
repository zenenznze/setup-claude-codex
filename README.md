# setup-claude-codex

Linux 上一键配置 Claude Code / CodeX 的交互式脚本。

脚本按目标工具隔离处理：
- 配置 Claude Code 时，只清理 Claude 相关环境变量残留，不删除 CodeX 配置。
- 配置 CodeX 时，只清理 CodeX 相关环境变量残留，不删除 Claude 配置。
- 新配置直接写入工具自己的配置文件，不再把 API Key 写入 shell rc 环境变量。

## 可用脚本

| 脚本 | 用途 | API 地址 |
|------|------|----------|
| `setup.sh` | Claude Code / CodeX 主脚本 | `https://api.459695.xyz` |
| `setup-deepseek.sh` | Claude Code → DeepSeek 直连 | `https://api.deepseek.com/anthropic` |
| `setup-codex-tuzi.sh` | CodeX → tuzi 提供商 | `https://api.tu-zi.com/coding` |
| `setup-sub2api.sh` | Claude Code / CodeX → Sub2API 自建网关 | `https://sub2api.joe.heiyu.space` |

## 用法

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup.sh
chmod +x setup.sh
./setup.sh
```

脚本会交互式询问：
1. 选择配置 **Claude Code**（DeepSeek 模型）还是 **CodeX**（GPT-5.5 模型）
2. 输入对应工具的 API Key / Token

### 配置 Claude Code

API 地址: `https://api.459695.xyz`

写入 `~/.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.459695.xyz",
    "ANTHROPIC_AUTH_TOKEN": "<你的 Token>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL_NAME": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1M]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash[1M]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash"
  },
  "includeCoAuthoredBy": false
}
```

配置前会从常见 shell rc 文件中清理 `ANTHROPIC_*` 和 `CLAUDE_CODE_*` 环境变量残留。

验证命令：
```bash
test -f ~/.claude/settings.json && echo OK
claude --version
claude /status
```

### DeepSeek 直连临时脚本

如果不想经过中转 API，可以直接使用 DeepSeek 官方 endpoint：

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-deepseek.sh
chmod +x setup-deepseek.sh
./setup-deepseek.sh
```

API 地址: `https://api.deepseek.com/anthropic`

写入 `~/.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "<你的 DeepSeek API Key>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]"
  },
  "includeCoAuthoredBy": false
}
```

验证命令与上方 Claude Code 配置相同。

### 配置 CodeX

- 提供商: `custom`（`https://api.459695.xyz`）
- 认证文件: `~/.codex/auth.json`
- 配置文件: `~/.codex/config.toml`
- 模型: `gpt-5.5`
- reasoning_effort: `xhigh`

写入 `~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "<你的 API Key>"
}
```

写入 `~/.codex/config.toml`：

```toml
model_provider = "custom"
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
disable_response_storage = true

[model_providers]
[model_providers.custom]
name = "custom"
wire_api = "responses"
requires_openai_auth = true
base_url = "https://api.459695.xyz"

[features]
goals = true
```

配置前会从常见 shell rc 文件中清理 `OPENAI_API_KEY` 和 `CODEX_HOME` 环境变量残留。

验证命令：
```bash
test -f ~/.codex/auth.json && test -f ~/.codex/config.toml && echo OK
codex --version
codex /status
codex exec "hello"
```

### Sub2API 自建网关脚本

如果你的 Sub2API 实例运行在 `https://sub2api.joe.heiyu.space`，可以直接使用：

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-sub2api.sh
chmod +x setup-sub2api.sh
./setup-sub2api.sh
```

API 地址: `https://sub2api.joe.heiyu.space`

脚本同样支持交互式选择 Claude Code 或 CodeX。

**Claude Code 配置** — 写入 `~/.claude/settings.json`：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://sub2api.joe.heiyu.space",
    "ANTHROPIC_AUTH_TOKEN": "<你的 Sub2API Key>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash[1m]",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash[1m]"
  },
  "includeCoAuthoredBy": false
}
```

**CodeX 配置** — 写入 `~/.codex/auth.json` + `~/.codex/config.toml`：

```json
// ~/.codex/auth.json
{
  "OPENAI_API_KEY": "<你的 Sub2API Key>"
}
```

```toml
# ~/.codex/config.toml
model_provider = "custom"
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
disable_response_storage = true

[model_providers]
[model_providers.custom]
name = "custom"
wire_api = "responses"
requires_openai_auth = true
base_url = "https://sub2api.joe.heiyu.space"

[features]
goals = true
```

> Sub2API 需要在后台创建 API Key 并分配到对应平台分组（Anthropic 分组用于 Claude Code，OpenAI 分组用于 CodeX）。
