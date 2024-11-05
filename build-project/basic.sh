#!/bin/bash
# shellcheck disable=SC2086 disable=SC2034  disable=SC2155
function getRootUri() {
  local GREEN='\033[0;32m' # 绿色
  local RED='\033[0;31m'   # 红色
  local NC='\033[0m'

  local response=$(curl -m 3 -s -o /dev/null -w "%{http_code}" https://code.kubectl.net)
  if [ $response -eq 200 ]; then
    # echo -e "${GREEN}Success: HTTP status code is 200. <https://code.kubectl.net>${NC}"
    # ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main
    export ROOT_URI=https://dev.kubectl.net
  else
    echo -e "${RED}Failed: HTTP status code is not 200, but $response.${NC}"
    export ROOT_URI=https://gitlab.com/iprt/build-project/-/raw/main
  fi

  echo -e "${GREEN}ROOT_URI=$ROOT_URI${NC}"

}
getRootUri
