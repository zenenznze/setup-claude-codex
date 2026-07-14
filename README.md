# setup-claude-codex

Linux 上一键配置 Claude Code / CodeX 的交互式脚本。

## 快速开始

```bash
curl -O https://gitea.joe.heiyu.space/joe/setup-claude-codex/raw/branch/main/setup.sh
chmod +x setup.sh
./setup.sh
```

`setup.sh` 是统一入口，交互式引导完成配置：

1. **选择工具** — Claude Code 或 CodeX
2. **选择提供商** — 根据工具列出可用目标
3. **输入 API Key** — 自动写入对应配置文件

## 可用提供商

| 工具 | 提供商 | API 地址 |
|------|--------|----------|
| Claude Code | `api.459695.xyz`（默认） | `https://api.459695.xyz` |
| Claude Code | DeepSeek 直连 | `https://api.deepseek.com/anthropic` |
| Claude Code | Sub2API 自建网关 | `https://sub2api.joe.heiyu.space` |
| CodeX | `api.459695.xyz`（默认，gpt-5.6-luna） | `https://api.459695.xyz` |
| CodeX | tuzi | `https://api.tu-zi.com/coding` |
| CodeX | Sub2API 自建网关 | `https://sub2api.joe.heiyu.space` |

## 独立专项脚本

如需绕过交互菜单直接使用特定提供商，也可用专项脚本：

| 脚本 | 用途 | API 地址 |
|------|------|----------|
| `setup-deepseek.sh` | Claude Code → DeepSeek 直连 | `https://api.deepseek.com/anthropic` |
| `setup-sub2api.sh` | Claude Code / CodeX → Sub2API | `https://sub2api.joe.heiyu.space` |
| `setup-codex-tuzi.sh` | CodeX → tuzi | `https://api.tu-zi.com/coding` |

## 配置 Claude Code

写入 `~/.claude/settings.json`，以默认提供商为例：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.459695.xyz",
    "ANTHROPIC_AUTH_TOKEN": "<你的 Token>",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash[1M]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN": "1"
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

### DeepSeek 直连

选择 DeepSeek 提供商后，API 地址为 `https://api.deepseek.com/anthropic`，使用你的 DeepSeek API Key。

### Sub2API

选择 Sub2API 提供商后，API 地址为 `https://sub2api.joe.heiyu.space`。
需要在 Sub2API 后台创建 API Key，选择 **Anthropic 分组**。

## 配置 CodeX

写入 `~/.codex/auth.json`：

```json
{
  "OPENAI_API_KEY": "<你的 API Key>"
}
```

写入 `~/.codex/config.toml`（默认提供商）：

```toml
model_provider = "custom"
model = "gpt-5.6-luna"
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

### tuzi 提供商

- `base_url`: `https://api.tu-zi.com/coding`
- `model_reasoning_effort`: `medium`

### Sub2API

- `base_url`: `https://sub2api.joe.heiyu.space`
- 需要在 Sub2API 后台创建 API Key，选择 **OpenAI 分组**

## 设计原则

- 配置 Claude Code 时只清理 Claude 相关环境变量，不删除 CodeX 配置
- 配置 CodeX 时只清理 CodeX 相关环境变量，不删除 Claude 配置
- 新配置直接写入工具自己的配置文件，不再把 API Key 写入 shell rc 环境变量
- 所有 Claude Code 配置均包含 `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1`，默认禁用全屏 TUI 模式
