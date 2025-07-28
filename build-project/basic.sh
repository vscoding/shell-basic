#!/bin/bash
set -euo pipefail

# Windows Git Bash 兼容版本（修复变量检查）
function EXPORT_ROOT_URI() {

  # 配置参数
  local -r CODE_URL="https://code.kubectl.net"
  local -r GITLAB_URL="https://gitlab.com/svcops/build-project/-/raw/main"
  local -r TARGET_CODE_URL="https://dev.kubectl.net"

  # 初始化颜色（Git Bash 兼容）
  local -r GREEN='\033[0;32m'
  local -r RED='\033[0;31m'
  local -r YELLOW='\033[1;33m'
  local -r NC='\033[0m'

  # 日志函数
  log_info() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${NC}"; }
  log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${NC}"; }
  log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${NC}"; }

  # 检测运行环境 - 修复变量检查
  if [[ "$OSTYPE" == "msys" ]] || [[ "${MSYSTEM:-}" != "" ]]; then
    log_info "检测到 Windows Git Bash 环境"
    export MSYS_NO_PATHCONV=1
  else
    log_info "检测到非 Windows 环境"
  fi

  # 检查 curl 是否可用
  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl 命令不可用，请确保 Git Bash 正确安装"
    return 1
  fi

  log_info "开始网络连通性检查..."

  local -r MAX_RETRIES=3
  local responses=()
  for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    # 使用curl -sSL -I 检测连通性
    local response
    response=$(curl -m 3 -sSL -I "$CODE_URL" | grep -oP 'HTTP/\d\.\d \K\d+')
    if [ "$response" == "200" ]; then
      export ROOT_URI=$TARGET_CODE_URL
      log_info "主地址连接成功，ROOT_URI=$ROOT_URI"
      return 0
    elif [[ $attempt -lt $MAX_RETRIES ]]; then
      responses+=("$response")
      log_warn "第 ${attempt} 次尝试失败(状态码: $response)，1秒后重试..."
      sleep 1
    fi
  done

  log_error "主地址连接失败，所有尝试状态码: ${responses[*]}"
  export ROOT_URI=$GITLAB_URL
  log_info "已切换到备用地址: ROOT_URI=$ROOT_URI"
  return 0
}

EXPORT_ROOT_URI
