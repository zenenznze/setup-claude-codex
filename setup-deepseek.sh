#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 临时脚本：单独配置 Claude Code 使用 DeepSeek 模型
# 请求地址: https://api.deepseek.com/anthropic
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; }
info() { echo -e "${BLUE}[..]${NC} $*"; }

BASE_URL="https://api.deepseek.com/anthropic"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
RC_FILES=(
  "$HOME/.bashrc"
  "$HOME/.bash_profile"
  "$HOME/.zshrc"
  "$HOME/.profile"
  "$HOME/.zprofile"
  "$HOME/.zshenv"
)

mask_secret() {
  local secret="${1:-}"
  if (( ${#secret} <= 12 )); then
    printf '***'
  else
    printf '%s...' "${secret:0:12}"
  fi
}

json_escape() {
  local value="${1:-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

unset_vars() {
  local var
  for var in "$@"; do
    unset "$var" 2>/dev/null || true
  done
}

cleanup_env() {
  info "清理 Claude 相关环境变量残留..."

  unset_vars \
    ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
    ANTHROPIC_DEFAULT_OPUS_MODEL \
    ANTHROPIC_DEFAULT_SONNET_MODEL \
    ANTHROPIC_DEFAULT_SONNET_MODEL_NAME \
    ANTHROPIC_DEFAULT_HAIKU_MODEL \
    CLAUDE_CODE_SUBAGENT_MODEL CLAUDE_CODE_EFFORT_LEVEL \
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC

  local f
  for f in "${RC_FILES[@]}"; do
    if [[ -f "$f" ]]; then
      sed -i.bak -E \
        -e '/^[[:space:]]*#[[:space:]]*----[[:space:]]*Claude Code/d' \
        -e '/^[[:space:]]*(export[[:space:]]+)?ANTHROPIC_[A-Za-z0-9_]*=/d' \
        -e '/^[[:space:]]*(export[[:space:]]+)?CLAUDE_CODE_[A-Za-z0-9_]*=/d' \
        -e '/^[[:space:]]*unset[[:space:]]+ANTHROPIC_[A-Za-z0-9_]*$/d' \
        -e '/^[[:space:]]*unset[[:space:]]+CLAUDE_CODE_[A-Za-z0-9_]*$/d' \
        "$f"
    fi
  done

  rm -f "$HOME/.claude/config.json"
}

check_residue() {
  local pattern="$1"
  local label="$2"
  local residue
  residue=$(grep -nE "$pattern" "${RC_FILES[@]}" 2>/dev/null || true)

  if [[ -z "$residue" ]]; then
    log "$label 环境变量残留已清理"
  else
    warn "$label 仍有环境变量残留，请手动检查:"
    echo "$residue"
  fi
}

echo "============================================"
echo " DeepSeek + Claude Code 临时配置"
echo " 请求地址: ${BASE_URL}"
echo "============================================"
echo ""

read -rsp "请输入你的 DeepSeek API Key: " API_KEY
echo ""

if [[ -z "$API_KEY" ]]; then
  err "API Key 不能为空"
  exit 1
fi

cleanup_env
check_residue 'ANTHROPIC_|CLAUDE_CODE_' "Claude"

info "写入 Claude Code 配置文件: $CLAUDE_SETTINGS ..."
mkdir -p "$HOME/.claude"
API_KEY_JSON=$(json_escape "$API_KEY")

cat > "$CLAUDE_SETTINGS" <<EOF
{
  "env": {
    "ANTHROPIC_BASE_URL": "${BASE_URL}",
    "ANTHROPIC_AUTH_TOKEN": "${API_KEY_JSON}",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro[1m]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-flash[1M]",
    "ANTHROPIC_DEFAULT_SONNET_MODEL_NAME": "deepseek-v4-flash"
  },
  "includeCoAuthoredBy": false
}
EOF

chmod 600 "$CLAUDE_SETTINGS"
log "$CLAUDE_SETTINGS 已创建"

echo ""
echo "============================================"
echo " 配置完成，验证如下:"
echo "============================================"
echo "配置文件                  = $CLAUDE_SETTINGS"
echo "ANTHROPIC_BASE_URL         = ${BASE_URL}"
echo "ANTHROPIC_AUTH_TOKEN       = $(mask_secret "$API_KEY")"
echo "HAIKU                      = deepseek-v4-flash"
echo "OPUS                       = deepseek-v4-pro[1m]"
echo "SONNET                     = deepseek-v4-flash[1M]"
echo "SONNET_MODEL_NAME          = deepseek-v4-flash"
echo ""
echo "验证命令:"
echo "  test -f ~/.claude/settings.json && echo OK"
echo "  claude --version"
echo "  claude /status"

log "全部完成！新开一个终端，输入 claude 即可使用。"
