#!/bin/bash

# Windows Git Bash 兼容版本
function export_root_uri() {
  # 检测运行环境
  local is_git_bash=false
  if [[ "$OSTYPE" == "msys" ]] || [[ "$MSYSTEM" != "" ]]; then
    is_git_bash=true
  fi

  # 配置参数
  local -r PRIMARY_URL="https://code.kubectl.net"
  local -r FALLBACK_URL="https://gitlab.com/svcops/build-project/-/raw/main"
  local -r TARGET_URL="https://dev.kubectl.net"
  local -r MAX_RETRIES=2
  local -r TIMEOUT=5

  # 初始化颜色（Git Bash 兼容）
  local GREEN=''
  local RED=''
  local YELLOW=''
  local NC=''

  if [[ -t 1 ]] && (command -v tput >/dev/null 2>&1 || $is_git_bash); then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
  fi

  # 日志函数
  log_info() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${NC}"; }
  log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${NC}"; }
  log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${NC}"; }

  # 检查 curl 是否可用
  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl 命令不可用，请确保 Git Bash 正确安装"
    return 1
  fi

  log_info "开始网络连通性检查..."
  if $is_git_bash; then
    log_info "检测到 Git Bash 环境"
  fi

  # 连通性检查
  for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    # Git Bash 中 curl 的使用
    local response
    response=$(curl -m $TIMEOUT -s -o /dev/null -w "%{http_code}" "${PRIMARY_URL}" 2>/dev/null)
    local curl_exit_code=$?

    # 处理 curl 执行失败的情况
    if [[ $curl_exit_code -ne 0 ]]; then
      response="000"
    fi

    if [[ $response -eq 200 ]]; then
      export ROOT_URI="${TARGET_URL}"
      log_info "主地址连接成功，ROOT_URI=${ROOT_URI}"
      return 0
    fi

    if [[ $attempt -lt $MAX_RETRIES ]]; then
      log_warn "第 ${attempt} 次尝试失败(状态码: ${response})，1秒后重试..."
      sleep 1
    fi
  done

  # 使用备用地址
  log_error "主地址连接失败，最终状态码: ${response}"
  export ROOT_URI="${FALLBACK_URL}"
  log_info "已切换到备用地址: ROOT_URI=${ROOT_URI}"
}

# 执行函数
export_root_uri
