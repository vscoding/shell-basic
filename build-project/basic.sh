#!/bin/bash

function EXPORT_ROOT_URI() {
  # Colors
  local -r GREEN='\033[0;32m'
  local -r RED='\033[0;31m'
  local -r YELLOW='\033[1;33m'
  local -r NC='\033[0m'

  log_info() { echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${NC}"; }
  log_warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${NC}"; }
  log_error() { echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${NC}"; }

  # Constant URIs
  local -r PRIMARY_TEST_URL="https://code.kubectl.net"
  local -r PRIMARY_ROOT_URI="https://dev.kubectl.net"
  local -r GITLAB_ROOT_URI="https://gitlab.com/vscoding/build-project/-/raw/main"
  local -r WORKER_ROOT_URI="https://dev.kubectl.org"

  # Validate existing ROOT_URI
  function CHECK_ROOT_URI() {
    case "${ROOT_URI:-}" in
      "$PRIMARY_ROOT_URI" | "$GITLAB_ROOT_URI" | "$WORKER_ROOT_URI")
        export ROOT_URI="$ROOT_URI"
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  }

  # If user already set valid ROOT_URI → done
  if CHECK_ROOT_URI; then
    log_info "ROOT_URI is already set to a valid value: $ROOT_URI"
    return 0
  fi

  # Detect environment
  local NULL_DEV
  if [[ "$OSTYPE" == "msys" || -n "${MSYSTEM:-}" ]]; then
    export MSYS_NO_PATHCONV=1
    NULL_DEV="NUL"
    log_info "Detected Windows Git Bash Environment, using NUL"
  else
    NULL_DEV="/dev/null"
    log_info "Detected Non-Windows Environment, using /dev/null"
  fi

  log_info "Starting network connectivity check..."

  # Network check
  local -r MAX_RETRIES=3
  local responses=()
  local attempt response

  for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    response=$(curl -m 5 -sSL -I -w "%{http_code}" -o "$NULL_DEV" "$PRIMARY_TEST_URL" | tr -d '\r\n')

    if [[ "$response" == "200" ]]; then
      export ROOT_URI="$PRIMARY_ROOT_URI"
      log_info "Primary address connected successfully, ROOT_URI=$ROOT_URI"
      return 0
    fi

    responses+=("$response")

    if ((attempt < MAX_RETRIES)); then
      log_warn "Attempt $attempt failed (status: $response), retrying in 1 second..."
      sleep 1
    fi
  done

  # Fallback
  log_error "Primary address connection failed, attempts: ${responses[*]}"
  export ROOT_URI="$WORKER_ROOT_URI"
  log_info "Switched to fallback address: ROOT_URI=$ROOT_URI"

  return 0
}

EXPORT_ROOT_URI
