#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CodeX 一键清理旧配置 & 配置脚本 (Linux)
# 方案: sub2api
#
# 用法: ./setup-codex-sub2api.sh [apikey] [lightos|zen]
#   lightos (默认): 懒猫虚拟环境，base_url = http://host.lzcapp:8888/v1
#   zen:            WSL / 普通 Linux，base_url = https://sub2api.zen.heiyu.space/v1
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
	BASE_URL="https://sub2api.zen.heiyu.space/v1"
else
	BASE_URL="http://host.lzcapp:8888/v1"
fi

echo "============================================"
echo " CodeX 一键配置脚本 (Linux)"
echo " 方案: sub2api"
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
for var in SUB2API_API_KEY CODESOME_API_KEY CODEX_HOME; do
	unset "$var" 2>/dev/null || true
done

# 3b. 清理 shell 配置文件中的旧 CodeX 相关行
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

# 3c. 删除旧 CodeX 配置
rm -f ~/.codex/config.toml

# 3d. 验证清理
RC_FILES=(~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile ~/.zprofile ~/.zshenv)
RESIDUE=$(grep -nE 'SUB2API|CODESOME|CODEX_HOME' "${RC_FILES[@]}" 2>/dev/null || true)
if [[ -z "$RESIDUE" ]]; then
	log "旧配置已清理干净"
else
	warn "仍有残留，请手动检查:"
	echo "$RESIDUE"
fi

# ---- 4. 写入 CodeX config.toml ----
log "写入 CodeX 配置文件 (base_url: $BASE_URL)..."
mkdir -p ~/.codex

cat > ~/.codex/config.toml <<EOF
model = "gpt-5.5"
review_model = "gpt-5.5"
model_reasoning_effort = "xhigh"
model_provider = "sub2api"
disable_response_storage = true
network_access = "enabled"
check_for_update_on_startup = false
model_context_window = 1000000
model_auto_compact_token_limit = 900000

[model_providers.sub2api]
name = "Sub2API"
base_url = "${BASE_URL}"
wire_api = "responses"
env_key = "SUB2API_API_KEY"
EOF

chmod 600 ~/.codex/config.toml
log "~/.codex/config.toml 已创建"

# ---- 5. 写入环境变量到 shell 配置 ----
log "写入环境变量到 $TARGET_RC ..."

# 对 key 做 shell 单引号转义
ESCAPED_KEY=$(printf "%s" "$API_KEY" | sed "s/'/'\\\\''/g")

cat >> "$TARGET_RC" <<EOF

# ---- CodeX via sub2api ----
unset CODEX_HOME
export CODEX_HOME="\$HOME/.codex"
export SUB2API_API_KEY='${ESCAPED_KEY}'
EOF

# ---- 6. 生效 ----
log "使配置生效..."
# shellcheck disable=SC1090
source "$TARGET_RC" 2>/dev/null || true

export CODEX_HOME="$HOME/.codex"
export SUB2API_API_KEY="$API_KEY"

# ---- 7. 验证 ----
echo ""
echo "============================================"
echo " 配置完成，验证如下:"
echo "============================================"
echo "CODEX_HOME       = ${CODEX_HOME:-未设置}"
echo "SUB2API_API_KEY  = ${SUB2API_API_KEY:0:12}..."
echo ""

if [[ -f ~/.codex/config.toml ]]; then
	log "~/.codex/config.toml 存在"
else
	err "~/.codex/config.toml 缺失"
fi

if [[ -n "${CODEX_HOME:-}" ]] && [[ -n "${SUB2API_API_KEY:-}" ]]; then
	log "环境变量已生效"
else
	warn "环境变量未在当前终端生效，新开终端即可"
fi

echo ""
log "全部完成！新开一个终端，输入 codex 即可使用。"
log "模型: gpt-5.5，提供商: sub2api"
