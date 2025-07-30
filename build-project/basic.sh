#!/bin/bash

#set -euo pipefail

function EXPORT_ROOT_URI() {
  local -r PRIMARY_TEST_URL="https://code.kubectl.net"
  local -r PRIMARY_ROOT_URI="https://dev.kubectl.net"
  local -r GITLAB_ROOT_URI="https://gitlab.com/svcops/build-project/-/raw/main"

  # Initialize colors (Git Bash compatible)
  local -r GREEN='\033[0;32m'
  local -r RED='\033[0;31m'
  local -r YELLOW='\033[1;33m'
  local -r NC='\033[0m'

  log_info() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${NC}"; }
  log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${NC}"; }
  log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${NC}"; }

  # Detect environment - Fixed variable check
  if [[ "$OSTYPE" == "msys" ]] || [[ "${MSYSTEM:-}" != "" ]]; then
    log_info "Detected Windows Git Bash Environment"
    export MSYS_NO_PATHCONV=1
  else
    log_info "Detected Non-Windows Environment"
  fi

  log_info "Starting network connectivity check..."

  local -r MAX_RETRIES=3
  local responses=()
  for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    local response="-1"
    response=$(curl -m 3 -sSL -w "%{http_code}" -o /dev/null "$PRIMARY_TEST_URL")
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
