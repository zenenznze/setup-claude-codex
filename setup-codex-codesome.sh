#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CodeX 一键清理旧配置 & 配置脚本 (Linux)
# 方案: Codesome
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; }

echo "============================================"
echo " CodeX 一键配置脚本 (Linux)"
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
log "开始清理旧配置..."

# 2a. 清理当前终端环境变量
for var in SUB2API_API_KEY CODESOME_API_KEY CODEX_HOME; do
	unset "$var" 2>/dev/null || true
done

# 2b. 清理 shell 配置文件中的旧 CodeX 相关行
for f in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv; do
	if [[ -f "$f" ]]; then
		sed -i.bak -E \
			-e '/^[[:space:]]*export[[:space:]]+SUB2API_API_KEY/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODESOME_API_KEY/d' \
			-e '/^[[:space:]]*unset[[:space:]]+CODEX_HOME/d' \
			-e '/^[[:space:]]*export[[:space:]]+CODEX_HOME/d' \
			"$f"
	fi
done

# 2c. 删除旧 CodeX 配置
rm -f ~/.codex/config.toml

# 2d. 验证清理
RC_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv)
RESIDUE=$(grep -nE 'SUB2API|CODESOME|CODEX_HOME' "${RC_FILES[@]}" 2>/dev/null || true)
if [[ -z "$RESIDUE" ]]; then
	log "旧配置已清理干净"
else
	warn "仍有残留，请手动检查:"
	echo "$RESIDUE"
fi

# ---- 3. 写入 CodeX config.toml ----
log "写入 CodeX 配置文件..."
mkdir -p ~/.codex

cat > ~/.codex/config.toml <<'EOF'
model = "gpt-5.5"
review_model = "gpt-5.5"
model_reasoning_effort = "xhigh"
model_provider = "codesome"
disable_response_storage = true
network_access = "enabled"
check_for_update_on_startup = false
model_context_window = 1000000
model_auto_compact_token_limit = 900000

[model_providers.codesome]
name = "Codesome"
base_url = "https://cc.codesome.ai/v1"
wire_api = "responses"
env_key = "CODESOME_API_KEY"
EOF

chmod 600 ~/.codex/config.toml
log "~/.codex/config.toml 已创建"

# ---- 4. 写入环境变量到 shell 配置 ----
log "写入环境变量到 $TARGET_RC ..."

# 对 key 做 shell 单引号转义
ESCAPED_KEY=$(printf "%s" "$API_KEY" | sed "s/'/'\\\\''/g")

cat >> "$TARGET_RC" <<EOF

# ---- CodeX via Codesome ----
unset CODEX_HOME
export CODEX_HOME="\$HOME/.codex"
export CODESOME_API_KEY='${ESCAPED_KEY}'
EOF

# ---- 5. 生效 ----
log "使配置生效..."
# shellcheck disable=SC1090
source "$TARGET_RC" 2>/dev/null || true

export CODEX_HOME="$HOME/.codex"
export CODESOME_API_KEY="$API_KEY"

# ---- 6. 验证 ----
echo ""
echo "============================================"
echo " 配置完成，验证如下:"
echo "============================================"
echo "CODEX_HOME        = ${CODEX_HOME:-未设置}"
echo "CODESOME_API_KEY  = ${CODESOME_API_KEY:0:12}..."
echo ""

if [[ -f ~/.codex/config.toml ]]; then
	log "~/.codex/config.toml 存在"
else
	err "~/.codex/config.toml 缺失"
fi

if [[ -n "${CODEX_HOME:-}" ]] && [[ -n "${CODESOME_API_KEY:-}" ]]; then
	log "环境变量已生效"
else
	warn "环境变量未在当前终端生效，新开终端即可"
fi

echo ""
log "全部完成！新开一个终端，输入 codex 即可使用。"
log "模型: gpt-5.5，提供商: Codesome (https://cc.codesome.ai)"
