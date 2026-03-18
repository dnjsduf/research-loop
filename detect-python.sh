#!/bin/bash
# detect-python.sh — Python 3 자동 감지
# source ./detect-python.sh 로 호출하면 PYTHON3 변수에 경로가 설정됨

detect_python3() {
  # 1. 이미 동작하는 python3가 있으면 사용
  if command -v python3 &>/dev/null && python3 --version &>/dev/null; then
    PYTHON3="python3"
    return 0
  fi

  # 2. python이 3.x인지 확인
  if command -v python &>/dev/null; then
    local ver
    ver=$(python --version 2>&1 | grep -oE '3\.[0-9]+')
    if [ -n "$ver" ]; then
      PYTHON3="python"
      return 0
    fi
  fi

  # 3. 알려진 경로 탐색 (Windows/Linux/Mac)
  local candidates=(
    "/c/Python314/python.exe"
    "/c/Python313/python.exe"
    "/c/Python312/python.exe"
    "/c/Python311/python.exe"
    "/c/Python310/python.exe"
    "/usr/bin/python3"
    "/usr/local/bin/python3"
    "/opt/homebrew/bin/python3"
  )

  for p in "${candidates[@]}"; do
    if [ -x "$p" ]; then
      PYTHON3="$p"
      # PATH에도 추가 (python3 심볼릭 링크 활용)
      export PATH="$(dirname "$p"):$PATH"
      return 0
    fi
  done

  # 4. 못 찾음
  echo -e "\033[0;31mError: Python 3를 찾을 수 없습니다.\033[0m" >&2
  echo "설치 후 다시 실행하거나, PYTHON3 환경변수를 설정하세요:" >&2
  echo "  export PYTHON3=/path/to/python3" >&2
  return 1
}

# 사용자가 PYTHON3를 이미 설정했으면 존중
if [ -z "$PYTHON3" ]; then
  detect_python3
fi

# python3 명령이 PYTHON3를 가리키도록 alias (스크립트 내 호환성)
if [ -n "$PYTHON3" ] && [ "$PYTHON3" != "python3" ]; then
  export PATH="$(dirname "$PYTHON3"):$PATH"
fi
