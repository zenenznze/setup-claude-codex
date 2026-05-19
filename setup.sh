#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 一键配置脚本 (Claude Code / CodeX)
# Claude Code: DeepSeek 模型 (api.459695.xyz)
# CodeX:       GPT-5.5 (api.459695.xyz)
# 交互式选择配置 Claude Code 或 CodeX
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

CLAUDE_BASE_URL="http://api.459695.xyz"
CODEX_BASE_URL="https://api.459695.xyz"

echo "============================================"
echo " 一键配置脚本"
echo "============================================"
echo ""

# ---- 1. 交互选择: Claude or Codex ----
echo "请选择要配置的工具:"
echo "  1) Claude Code（默认 DeepSeek 模型）"
echo "  2) CodeX（默认 GPT-5.5 模型）"
read -rp "输入 1 或 2 [1]: " CHOICE
CHOICE="${CHOICE:-1}"

case "$CHOICE" in
  1|claude|Claude)
    TOOL="claude"
    TOOL_NAME="Claude Code"
    ;;
  2|codex|CodeX)
    TOOL="codex"
    TOOL_NAME="CodeX"
    ;;
  *)
    err "无效选择: $CHOICE"
    exit 1
    ;;
esac

echo ""
echo "配置工具: $TOOL_NAME"
echo ""

# ---- 2. 索取 API Key ----
read -rsp "请输入你的 API Key: " API_KEY
echo ""

if [[ -z "$API_KEY" ]]; then
  err "API Key 不能为空"
  exit 1
fi

# ---- 3. 检测 shell ----
CURRENT_SHELL=$(basename "${SHELL:-/bin/bash}")
case "$CURRENT_SHELL" in
  zsh)  TARGET_RC="$HOME/.zshrc" ;;
  *)    TARGET_RC="$HOME/.bashrc" ;;
esac
log "检测到 shell: $CURRENT_SHELL，配置文件: $TARGET_RC"

# ---- 4. 大扫除：清理残留配置 ----
info "开始清理旧配置..."

# 清理当前终端环境变量
for var in \
  ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL \
  ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL \
  ANTHROPIC_DEFAULT_HAIKU_MODEL CLAUDE_CODE_SUBAGENT_MODEL \
  CLAUDE_CODE_EFFORT_LEVEL CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC \
  OPENAI_API_KEY CODESOME_API_KEY CODEX_HOME; do
  unset "$var" 2>/dev/null || true
done

# 清理 shell 配置文件中的旧配置
for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv; do
  if [[ -f "$f" ]]; then
    sed -i.bak -E \
      -e '/^[[:space:]]*export[[:space:]]+ANTHROPIC_/d' \
      -e '/^[[:space:]]*export[[:space:]]+CLAUDE_CODE_/d' \
      -e '/^[[:space:]]*export[[:space:]]+OPENAI_API_KEY/d' \
      -e '/^[[:space:]]*export[[:space:]]+CODESOME_API_KEY/d' \
      -e '/^[[:space:]]*unset[[:space:]]+CODEX_HOME/d' \
      -e '/^[[:space:]]*export[[:space:]]+CODEX_HOME/d' \
      -e '/^[[:space:]]*ANTHROPIC_/d' \
      -e '/^[[:space:]]*CLAUDE_CODE_/d' \
      "$f"
  fi
done

# 删除旧配置文件
rm -f ~/.claude/config.json
rm -f ~/.claude/settings.json
rm -f ~/.codex/config.toml

# 验证清理
RC_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv)
RESIDUE=$(grep -nE 'ANTHROPIC|CLAUDE_CODE|SUB2API|CODESOME|CODEX_HOME' "${RC_FILES[@]}" 2>/dev/null || true)
if [[ -z "$RESIDUE" ]]; then
  log "旧配置已清理干净"
else
  warn "仍有残留，请手动检查:"
  echo "$RESIDUE"
fi

# ---- 5. 配置目标工具 ----
if [[ "$TOOL" == "claude" ]]; then
  # ---- 5a. 配置 Claude Code ----
  info "写入 Claude Code 环境变量到 $TARGET_RC ..."

  cat >> "$TARGET_RC" <<EOF

# ---- Claude Code via sub2api ----
export ANTHROPIC_BASE_URL="${CLAUDE_BASE_URL}"
export ANTHROPIC_AUTH_TOKEN="${API_KEY}"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-flash"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"
EOF

  # 使配置在当前终端生效
  export ANTHROPIC_BASE_URL="$CLAUDE_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$API_KEY"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-flash"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
  export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
  export CLAUDE_CODE_EFFORT_LEVEL="max"

  echo ""
  echo "============================================"
  echo " 配置完成，验证如下:"
  echo "============================================"
  echo "ANTHROPIC_BASE_URL         = ${ANTHROPIC_BASE_URL:-未设置}"
  echo "ANTHROPIC_AUTH_TOKEN       = ${ANTHROPIC_AUTH_TOKEN:0:12}..."
  echo "ANTHROPIC_DEFAULT_OPUS     = ${ANTHROPIC_DEFAULT_OPUS_MODEL:-未设置}"
  echo "ANTHROPIC_DEFAULT_SONNET   = ${ANTHROPIC_DEFAULT_SONNET_MODEL:-未设置}"
  echo "ANTHROPIC_DEFAULT_HAIKU    = ${ANTHROPIC_DEFAULT_HAIKU_MODEL:-未设置}"
  echo "CLAUDE_CODE_SUBAGENT_MODEL = ${CLAUDE_CODE_SUBAGENT_MODEL:-未设置}"
  echo "CLAUDE_CODE_EFFORT_LEVEL   = ${CLAUDE_CODE_EFFORT_LEVEL:-未设置}"
  echo ""

  log "全部完成！新开一个终端，输入 claude 即可使用。"

else
  # ---- 5b. 配置 CodeX（custom provider） ----
  info "写入 CodeX 配置文件 (custom: ${CODEX_BASE_URL})..."

  mkdir -p ~/.codex

  cat > ~/.codex/config.toml <<EOF
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
model_provider = "custom"

disable_response_storage = true

[model_providers.custom]
name = "custom"
wire_api = "responses"
requires_openai_auth = true
base_url = "${CODEX_BASE_URL}"
EOF

  chmod 600 ~/.codex/config.toml
  log "~/.codex/config.toml 已创建"

  # 写入环境变量
  info "写入环境变量到 $TARGET_RC ..."

  cat >> "$TARGET_RC" <<EOF

# ---- CodeX via custom provider ----
export OPENAI_API_KEY="${API_KEY}"
EOF

  # 使配置在当前终端生效
  export OPENAI_API_KEY="$API_KEY"

  echo ""
  echo "============================================"
  echo " 配置完成，验证如下:"
  echo "============================================"
  echo "OPENAI_API_KEY   = ${OPENAI_API_KEY:0:12}..."

  if [[ -f ~/.codex/config.toml ]]; then
    log "~/.codex/config.toml 存在"
  else
    err "~/.codex/config.toml 缺失"
  fi

  if [[ -n "${OPENAI_API_KEY:-}" ]]; then
    log "环境变量已生效"
  else
    warn "环境变量未在当前终端生效，新开终端即可"
  fi

  echo ""
  log "全部完成！新开一个终端，输入 codex 即可使用。"
  log "模型: gpt-5.5，提供商: custom (${CODEX_BASE_URL})"
fi
