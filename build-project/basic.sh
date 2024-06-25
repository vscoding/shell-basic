#!/bin/bash
# shellcheck disable=SC2086
response=$(curl -m 3 -s -o /dev/null -w "%{http_code}" https://code.kubectl.net)
if [ $response -eq 200 ]; then
  echo "Success: HTTP status code is 200 <https://code.kubectl.net>"
  ROOT_URI=https://code.kubectl.net/devops/build-project/raw/branch/main
else
  echo "Failed: HTTP status code is not 200, but $response"
  ROOT_URI=https://gitlab.com/iprt/build-project/-/raw/main
fi

echo "root uri is $ROOT_URI"
