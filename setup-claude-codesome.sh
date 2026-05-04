#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Code 一键清理旧配置 & 配置脚本 (Linux)
# 方案: Codesome (https://cc.codesome.ai)
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
echo " 方案: Codesome"
echo "============================================"
echo ""

# ---- 0. 索取 API Key ----
if [[ -n "${1:-}" ]]; then
	API_KEY="$1"
else
	read -rsp "请输入你的 Codesome API Key (sk-...): " API_KEY
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
log "开始清理旧配置（包括 dpsk 模型环境变量）..."

# 2a. 清理当前终端环境变量
for var in \
	ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
	ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
	ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_SUBAGENT_MODEL \
	CLAUDE_CODE_EFFORT_LEVEL CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC \
	CLAUDE_CODE_ATTRIBUTION_HEADER \
	SUB2API_API_KEY CODESOME_API_KEY CODEX_HOME; do
	unset "$var" 2>/dev/null || true
done

# 2b. 清理 shell 配置文件中的旧 ANTHROPIC_ / CLAUDE_CODE_ / dpsk 行
for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv; do
	if [[ -f "$f" ]]; then
		sed -i.bak -E \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_BASE_URL/d' \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_AUTH_TOKEN/d' \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_MODEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_DEFAULT_OPUS_MODEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_DEFAULT_SONNET_MODEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_DEFAULT_HAIKU_MODEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_SUBAGENT_MODEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_EFFORT_LEVEL/d' \
			-e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC/d' \
			-e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_ATTRIBUTION_HEADER/d' \
			-e '/^[[:space:]]*export[[:space:]]+SUB2API_API_KEY/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODESOME_API_KEY/d' \
			-e '/^[[:space:]]*unset[[:space:]]+CODEX_HOME/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODEX_HOME/d' \
			-e '/^[[:space:]]*ANTHROPIC_/d' \
			-e '/^[[:space:]]*CLAUDE_CODE_/d' \
			-e '/# ---- Claude Code via sub2api/d' \
			"$f"
	fi
done

# 2c. 清理旧配置文件
rm -f ~/.claude/config.json
rm -f ~/.claude/settings.json

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
log "写入 Claude Code (Codesome) 环境变量到 $TARGET_RC ..."

# 对 key 做 shell 单引号转义
ESCAPED_KEY=$(printf "%s" "$API_KEY" | sed "s/'/'\\\\''/g")

cat >> "$TARGET_RC" <<EOF

# ---- Claude Code via Codesome ----
export ANTHROPIC_BASE_URL="https://cc.codesome.ai"
export ANTHROPIC_AUTH_TOKEN='${ESCAPED_KEY}'
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
EOF

# ---- 4. 生效 ----
log "使配置生效..."
# shellcheck disable=SC1090
source "$TARGET_RC" 2>/dev/null || true

export ANTHROPIC_BASE_URL="https://cc.codesome.ai"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# ---- 5. 验证 ----
echo ""
echo "============================================"
echo " 配置完成，验证如下:"
echo "============================================"
echo "ANTHROPIC_BASE_URL                    = ${ANTHROPIC_BASE_URL:-未设置}"
echo "ANTHROPIC_AUTH_TOKEN                  = ${ANTHROPIC_AUTH_TOKEN:0:12}..."
echo "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = ${CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC:-未设置}"
echo ""

# 检查是否还残留 dpsk 模型变量
HAS_DPSK_MODEL=false
for var in ANTHROPIC_MODEL ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_SUBAGENT_MODEL CLAUDE_CODE_EFFORT_LEVEL; do
	if [[ -n "${!var:-}" ]]; then
		warn "残留 dpsk 变量: $var = ${!var}"
		HAS_DPSK_MODEL=true
	fi
done
if [[ "$HAS_DPSK_MODEL" == false ]]; then
	log "dpsk 模型变量已全部清除"
fi

log "全部完成！新开一个终端，输入 claude 即可使用。"
log "API 地址: https://cc.codesome.ai"
