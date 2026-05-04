#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Claude Code 一键清理旧配置 & 配置脚本 (Linux)
# 方案: sub2api -> dpsk (deepseek-v4)
#
# 用法: ./setup-claude-dpsk.sh [apikey] [lightos|zen]
#   lightos (默认): 懒猫虚拟环境，base_url = http://host.lzcapp:8888
#   zen:            WSL / 普通 Linux，base_url = https://sub2api.zen.heiyu.space
#                   (需先配好 hclient 组网)
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; }

# ---- 0. 解析参数 ----
API_KEY=""
ENV_TYPE="lightos"

for arg in "${@}"; do
	case "$arg" in
		lightos|zen|wsl) ENV_TYPE="$arg" ;;
		*) API_KEY="$arg" ;;
	esac
done
[[ "$ENV_TYPE" == "wsl" ]] && ENV_TYPE="zen"

if [[ "$ENV_TYPE" == "zen" ]]; then
	BASE_URL="https://sub2api.zen.heiyu.space"
else
	BASE_URL="http://host.lzcapp:8888"
fi

echo "============================================"
echo " Claude Code 一键配置脚本 (Linux)"
echo " 方案: sub2api / dpsk"
echo " 环境: $ENV_TYPE → $BASE_URL"
echo "============================================"
echo ""

# ---- 1. 索取 API Key ----
if [[ -z "$API_KEY" ]]; then
	read -rsp "请输入你的 sub2api API Key: " API_KEY
	echo ""
fi

if [[ -z "$API_KEY" ]]; then
	err "API Key 不能为空"
	exit 1
fi

# ---- 2. 检测 shell ----
CURRENT_SHELL=$(basename "${SHELL:-/bin/bash}")
case "$CURRENT_SHELL" in
	zsh)  TARGET_RC="$HOME/.zshrc" ;;
	*)    TARGET_RC="$HOME/.bashrc" ;;
esac
log "检测到 shell: $CURRENT_SHELL，配置文件: $TARGET_RC"

# ---- 3. 大扫除：清理残留配置 ----
log "开始清理旧配置..."

# 3a. 清理当前终端环境变量
for var in \
	ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
	ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
	ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_SUBAGENT_MODEL \
	CLAUDE_CODE_EFFORT_LEVEL CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC \
	SUB2API_API_KEY CODESOME_API_KEY CODEX_HOME; do
	unset "$var" 2>/dev/null || true
done

# 3b. 清理 shell 配置文件中的旧 ANTHROPIC_ / CLAUDE_CODE_ 行
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

# 3c. 删除旧配置文件
rm -f ~/.claude/config.json
rm -f ~/.claude/settings.json
rm -f ~/.codex/config.toml

# 3d. 验证清理
RC_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv)
RESIDUE=$(grep -nE 'ANTHROPIC|CLAUDE_CODE|SUB2API|CODESOME|CODEX_HOME' "${RC_FILES[@]}" 2>/dev/null || true)
if [[ -z "$RESIDUE" ]]; then
	log "旧配置已清理干净"
else
	warn "仍有残留，请手动检查:"
	echo "$RESIDUE"
fi

# ---- 4. 写入新配置 ----
log "写入 Claude Code (dpsk) 环境变量到 $TARGET_RC ..."

cat >> "$TARGET_RC" <<DPSKEOF

# ---- Claude Code via sub2api (dpsk) [$ENV_TYPE] ----
export ANTHROPIC_BASE_URL="${BASE_URL}"
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

# ---- 5. 生效 ----
log "使配置生效..."
# shellcheck disable=SC1090
source "$TARGET_RC" 2>/dev/null || true

export ANTHROPIC_BASE_URL="$BASE_URL"
export ANTHROPIC_AUTH_TOKEN="$API_KEY"
export ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"

# ---- 6. 验证 ----
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
