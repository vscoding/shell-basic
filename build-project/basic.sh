#!/bin/bash

# 设置 ROOT_URI 环境变量
function export_root_uri() {
  local GREEN='\033[0;32m'
  local RED='\033[0;31m'
  local NC='\033[0m'
  local response
  local primary_url="https://code.kubectl.net"
  local fallback_url="https://gitlab.com/svcops/build-project/-/raw/main"
  local target_url="https://dev.kubectl.net"

  # 检查主网站连通性
  response=$(curl -m 3 -s -o /dev/null -w "%{http_code}" "${primary_url}" || echo "000")

  if [[ $response -eq 200 ]]; then
    export ROOT_URI="${target_url}"
    echo -e "${GREEN}ROOT_URI=${ROOT_URI}${NC}"
  else
    echo -e "${RED}连接失败: ${primary_url} 返回状态码 ${response}${NC}"
    export ROOT_URI="${fallback_url}"
    echo -e "${GREEN}使用备用地址: ROOT_URI=${ROOT_URI}${NC}"
  fi
}

# 执行函数
export_root_uri
