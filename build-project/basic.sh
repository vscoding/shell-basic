#!/bin/bash
# shellcheck disable=SC2086
GREEN='\033[0;32m' # 绿色
RED='\033[0;31m'   # 红色
NC='\033[0m'

response=$(curl -m 3 -s -o /dev/null -w "%{http_code}" https://code.kubectl.net)
if [ $response -eq 200 ]; then
  echo -e "${GREEN}Success: HTTP status code is 200. <https://code.kubectl.net>${NC}"
  ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main
else
  echo -e "${RED}Failed: HTTP status code is not 200, but $response.${NC}"
  ROOT_URI=https://gitlab.com/iprt/build-project/-/raw/main
fi

echo -e "${GREEN}ROOT_URI=$ROOT_URI${NC}"
