#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Code 一键清理旧配置 & 配置脚本 (Linux)
# 方案: sub2api -> dpsk (deepseek-v4)
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; }

echo "============================================"
echo " Claude Code 一键配置脚本 (Linux)"
echo " 方案: sub2api / dpsk"
echo "============================================"
echo ""

# ---- 0. 索取 API Key ----
if [[ -n "${1:-}" ]]; then
	API_KEY="$1"
else
	read -rsp "请输入你的 sub2api API Key: " API_KEY
	echo ""
fi

if [[ -z "$API_KEY" ]]; then
	err "API Key 不能为空"
	exit 1
fi

# ---- 1. 检测 shell ----
CURRENT_SHELL=$(basename "${SHELL:-/bin/bash}")
case "$CURRENT_SHELL" in
	zsh)  TARGET_RC="$HOME/.zshrc" ;;
	*)    TARGET_RC="$HOME/.bashrc" ;;
esac
log "检测到 shell: $CURRENT_SHELL，配置文件: $TARGET_RC"

# ---- 2. 大扫除：清理残留配置 ----
log "开始清理旧配置..."

# 2a. 清理当前终端环境变量
for var in \
	ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
	ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
	ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_SUBAGENT_MODEL \
	CLAUDE_CODE_EFFORT_LEVEL CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC \
	SUB2API_API_KEY CODESOME_API_KEY CODEX_HOME; do
	unset "$var" 2>/dev/null || true
done

# 2b. 清理 shell 配置文件中的旧 ANTHROPIC_ / CLAUDE_CODE_ 行
for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv; do
	if [[ -f "$f" ]]; then
		sed -i.bak -E \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_/d' \
			-e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_/d' \
			-e '/^[[:space:]]*export[[:space:]]+SUB2API_API_KEY/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODESOME_API_KEY/d' \
			-e '/^[[:space:]]*unset[[:space:]]+CODEX_HOME/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODEX_HOME/d' \
			-e '/^[[:space:]]*ANTHROPIC_/d' \
			-e '/^[[:space:]]*CLAUDE_CODE_/d' \
			"$f"
	fi
done

# 2c. 删除旧配置文件
rm -f ~/.claude/config.json
rm -f ~/.claude/settings.json
rm -f ~/.codex/config.toml

# 2d. 验证清理
RC_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv)
RESIDUE=$(grep -nE 'ANTHROPIC|CLAUDE_CODE|SUB2API|CODESOME|CODEX_HOME' "${RC_FILES[@]}" 2>/dev/null || true)
if [[ -z "$RESIDUE" ]]; then
	log "旧配置已清理干净"
else
	warn "仍有残留，请手动检查:"
	echo "$RESIDUE"
fi

# ---- 3. 写入新配置 ----
log "写入 Claude Code (dpsk) 环境变量到 $TARGET_RC ..."

cat >> "$TARGET_RC" <<'DPSKEOF'

# ---- Claude Code via sub2api (dpsk) ----
export ANTHROPIC_BASE_URL="http://host.lzcapp:8888"
DPSKEOF

# API key 单独追加（避免特殊字符问题）
echo "export ANTHROPIC_AUTH_TOKEN=\"${API_KEY}\"" >> "$TARGET_RC"

cat >> "$TARGET_RC" <<'DPSKEOF'
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"
DPSKEOF

# ---- 4. 生效 ----
log "使配置生效..."
# shellcheck disable=SC1090
source "$TARGET_RC" 2>/dev/null || true

export ANTHROPIC_BASE_URL="http://host.lzcapp:8888"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"

# ---- 5. 验证 ----
echo ""
echo "============================================"
echo " 配置完成，验证如下:"
echo "============================================"
echo "ANTHROPIC_BASE_URL         = ${ANTHROPIC_BASE_URL:-未设置}"
echo "ANTHROPIC_AUTH_TOKEN       = ${ANTHROPIC_AUTH_TOKEN:0:12}..."
echo "ANTHROPIC_MODEL            = ${ANTHROPIC_MODEL:-未设置}"
echo "ANTHROPIC_DEFAULT_OPUS     = ${ANTHROPIC_DEFAULT_OPUS_MODEL:-未设置}"
echo "ANTHROPIC_DEFAULT_SONNET   = ${ANTHROPIC_DEFAULT_SONNET_MODEL:-未设置}"
echo "ANTHROPIC_DEFAULT_HAIKU    = ${ANTHROPIC_DEFAULT_HAIKU_MODEL:-未设置}"
echo "CLAUDE_CODE_SUBAGENT_MODEL = ${CLAUDE_CODE_SUBAGENT_MODEL:-未设置}"
echo "CLAUDE_CODE_EFFORT_LEVEL   = ${CLAUDE_CODE_EFFORT_LEVEL:-未设置}"
echo ""

log "全部完成！新开一个终端，输入 claude 即可使用。"
