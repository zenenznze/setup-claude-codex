# setup-claude-codex

Linux 上一键配置 Claude Code / CodeX 的交互式脚本。

## 用法

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup.sh
chmod +x setup.sh
./setup.sh
```

脚本会交互式询问：
1. 选择配置 **Claude Code**（DeepSeek 模型）还是 **CodeX**（GPT-5.5 模型）
2. 输入 API Key

API 地址固定为 `http://api.459695.xyz`，无需额外参数。

### 配置 Claude Code

写入的环境变量：
- `ANTHROPIC_BASE_URL` — API 地址
- `ANTHROPIC_AUTH_TOKEN` — API Key
- `ANTHROPIC_DEFAULT_OPUS_MODEL` — `deepseek-v4-pro[1m]`
- `ANTHROPIC_DEFAULT_SONNET_MODEL` — `deepseek-v4-flash`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` — `deepseek-v4-flash`
- `CLAUDE_CODE_SUBAGENT_MODEL` — `deepseek-v4-flash`
- `CLAUDE_CODE_EFFORT_LEVEL` — `max`

### 配置 CodeX

- 模型: `gpt-5.5`
- 写入 `~/.codex/config.toml` 配置文件
- 写入 `OPENAI_API_KEY` 和 `CODEX_HOME` 环境变量
