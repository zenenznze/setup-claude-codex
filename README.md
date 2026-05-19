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

### 配置 Claude Code

API 地址: `https://api.459695.xyz`

写入的环境变量：
- `ANTHROPIC_BASE_URL` — API 地址
- `ANTHROPIC_AUTH_TOKEN` — API Key
- `ANTHROPIC_MODEL` — `sonnet`（强制启动模型）
- `ANTHROPIC_DEFAULT_SONNET_MODEL` — `deepseek-v4-flash`
- `ANTHROPIC_DEFAULT_OPUS_MODEL` — `deepseek-v4-pro`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL` — `deepseek-v4-flash`
- `CLAUDE_CODE_SUBAGENT_MODEL` — `deepseek-v4-flash`

验证命令：
```bash
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_MODEL
echo $ANTHROPIC_DEFAULT_SONNET_MODEL
claude --version
claude /status
```

### 配置 CodeX

- 提供商: `custom`（`https://api.459695.xyz/v1`）
- 认证: `env_key = "OPENAI_API_KEY"`
- 模型: `gpt-5.5`
- reasoning_effort: `high`
- 写入 `~/.codex/config.toml` 配置文件
- 写入 `OPENAI_API_KEY` 环境变量

验证命令：
```bash
cat ~/.codex/config.toml
echo $OPENAI_API_KEY
codex --version
codex /status
codex exec "hello"
```
