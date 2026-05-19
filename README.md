# setup-claude-codex

Linux 上一键配置 Claude Code / CodeX 的脚本集合。

---

## 主脚本：setup-claude-dpsk.sh

配置 Claude Code + deepseek-v4，默认走 459695 API。

```bash
curl -O https://raw.githubusercontent.com/zenenznze/setup-claude-codex/main/setup-claude-dpsk.sh
chmod +x setup-claude-dpsk.sh
./setup-claude-dpsk.sh
```

或直接传 key：`./setup-claude-dpsk.sh "你的apikey"`

写入的变量：`ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL`、`CLAUDE_CODE_SUBAGENT_MODEL`、`CLAUDE_CODE_EFFORT_LEVEL`

### 环境切换

`./setup-claude-dpsk.sh [apikey] [459695|lightos|zen]`

| 参数 | Base URL |
|------|----------|
| `459695`（默认） | `https://api.459695.xyz` |
| `lightos` | `http://host.lzcapp:8888` |
| `zen` | `https://sub2api.zen.heiyu.space` |

---

## 其他脚本

| 脚本 | 用途 |
|------|------|
| `setup-codex-sub2api.sh` | CodeX + sub2api（支持 459695/lightos/zen） |
