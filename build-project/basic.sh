#!/bin/bash

#set -euo pipefail

function EXPORT_ROOT_URI() {
  # Initialize colors (Git Bash compatible)
  local -r GREEN='\033[0;32m'
  local -r RED='\033[0;31m'
  local -r YELLOW='\033[1;33m'
  local -r NC='\033[0m'

  log_info() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${NC}"; }
  log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${NC}"; }
  log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${NC}"; }

  local -r PRIMARY_TEST_URL="https://code.kubectl.net"
  local -r PRIMARY_ROOT_URI="https://dev.kubectl.net"
  local -r GITLAB_ROOT_URI="https://gitlab.com/svcops/build-project/-/raw/main"

  function CHECK_ROOT_URI() {
    # 判断 ROOT_URI 是否已设置，并且是否是定义的 PRIMARY_ROOT_URI 或 GITLAB_ROOT_URI
    if [[ -z "${ROOT_URI:-}" ]] || [[ "$ROOT_URI" != "$PRIMARY_ROOT_URI" && "$ROOT_URI" != "$GITLAB_ROOT_URI" ]]; then
      log_info "ROOT_URI is not set or is not one of the predefined URIs, proceeding with network check..."
      return 1
    else
      export ROOT_URI=$ROOT_URI
      return 0
    fi
  }

  if CHECK_ROOT_URI; then
    log_info "ROOT_URI is already set to a valid value: $ROOT_URI"
    return 0
  fi

  # Detect environment - Fixed variable check
  if [[ "$OSTYPE" == "msys" ]] || [[ "${MSYSTEM:-}" != "" ]]; then
    export MSYS_NO_PATHCONV=1
    local NULL_DEV="NUL"
    log_info "Detected Windows Git Bash Environment, using NUL for null device"
  else
    local NULL_DEV="/dev/null"
    log_info "Detected Non-Windows Environment, using /dev/null for null device"
  fi

  log_info "Starting network connectivity check..."

  local -r MAX_RETRIES=3
  local responses=()
  for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    local response="-1"
    response=$(curl -m 5 -sSL -I -w "%{http_code}" -o $NULL_DEV "$PRIMARY_TEST_URL" | tr -d '\r\n')
    if [ "$response" == "200" ]; then
      export ROOT_URI=$PRIMARY_ROOT_URI
      log_info "Primary address connected successfully, ROOT_URI=$ROOT_URI"
      return 0
    elif [[ $attempt -lt $MAX_RETRIES ]]; then
      responses+=("$response")
      log_warn "Attempt ${attempt} failed (status code: $response), retrying in 1 second..."
      sleep 1
    fi
  done

  log_error "Primary address connection failed, all attempt status codes: ${responses[*]}"
  export ROOT_URI=$GITLAB_ROOT_URI
  log_info "Switched to fallback address: ROOT_URI=$ROOT_URI"
  return 0
}

EXPORT_ROOT_URI
