#!/bin/bash
# Ralph Wiggum Knowledge Pipeline
# ================================
# 사용법:
#   주제 던지기:    ./ralph.sh "transformer architecture"
#   논문 + URL:     ./ralph.sh "Attention Is All You Need" "https://arxiv.org/abs/1706.03762"
#   반복 수 지정:   ./ralph.sh "transformer architecture" --iterations 20
#   queue만 실행:   ./ralph.sh --run 20
#   Unpaywall:      ./ralph.sh "BERT" --email your@email.com

set -e

# Python 자동 감지
source "$(dirname "$0")/detect-python.sh" || exit 1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── 인자 파싱 ────────────────────────────────────────────────
TOPIC=""
URL=""
MAX_ITERATIONS=10
RUN_ONLY=false
UPDATE_MODE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --run)        RUN_ONLY=true; MAX_ITERATIONS="$2"; shift 2 ;;
    --update)     UPDATE_MODE=true; shift ;;
    --email)      UNPAYWALL_EMAIL="$2"; export UNPAYWALL_EMAIL; shift 2 ;;
    --*)          echo -e "${RED}알 수 없는 옵션: $1${NC}"; exit 1 ;;
    *)
      if   [ -z "$TOPIC" ]; then TOPIC="$1"
      elif [ -z "$URL"   ]; then URL="$1"
      fi
      shift ;;
  esac
done

# ── 사용법 ───────────────────────────────────────────────────
if [ -z "$TOPIC" ] && [ "$RUN_ONLY" = false ]; then
  echo -e "${BLUE}Ralph Knowledge Pipeline${NC}"
  echo ""
  echo "사용법:"
  echo "  ./ralph.sh \"주제 또는 논문 제목\""
  echo "  ./ralph.sh \"Attention Is All You Need\" \"https://arxiv.org/abs/1706.03762\""
  echo "  ./ralph.sh \"transformer architecture\" --iterations 20"
  echo "  ./ralph.sh --run 20"
  echo "  ./ralph.sh \"deep research\" --update        # 기존 주제 최신 정보로 업데이트"
  echo "  ./ralph.sh \"BERT\" --email your@email.com"
  echo ""
  exit 0
fi

# ── 필수 파일 체크 ───────────────────────────────────────────
if [ ! -f "PROMPT.md" ]; then
  echo -e "${RED}Error: PROMPT.md not found${NC}"; exit 1
fi

# ── 자동 생성: queue.md ──────────────────────────────────────
if [ ! -f "queue.md" ]; then
  echo -e "${YELLOW}queue.md 없음. 새로 생성합니다...${NC}"
  cat > queue.md << 'QEOF'
# 지식 DB 처리 대기열 (queue.md)

## 📋 대기 중 (Pending)

papers:

## ✅ 완료 (Done)

done:

## ⚠️ 오류 (Error)

errors:

## 📊 통계

stats:
  total: 0
  pending: 0
  done: 0
  error: 0
  last_updated: ""
QEOF
fi

# ── 자동 생성: activity.md ───────────────────────────────────
if [ ! -f "activity.md" ]; then
  cat > activity.md << 'AEOF'
# 지식 관리 파이프라인 — 실행 로그

## 통계
- 총 처리 문서: 0
- 마지막 실행: -

---

## 세션 로그
AEOF
fi

# 디렉토리 초기화
mkdir -p docs/knowledge docs/reports docs/sources docs/research

# ── Git 자동 초기화 ───────────────────────────────────────────
init_git() {
  if [ ! -d ".git" ]; then
    echo -e "${CYAN}=== Git 저장소 초기화 ===${NC}"
    git init -q
    # .gitignore 생성
    if [ ! -f ".gitignore" ]; then
      cat > .gitignore << 'GIEOF'
fetch-signal.txt
.DS_Store
Thumbs.db
*.pyc
__pycache__/
GIEOF
    fi
    git add -A
    git commit -q -m "init: research-loop pipeline setup"
    echo -e "${GREEN}✓ Git 저장소 생성 완료${NC}"
    echo ""
  fi
}

# Git 커밋 (변경사항 있을 때만)
git_commit() {
  local MSG="$1"
  if [ -d ".git" ]; then
    git add -A 2>/dev/null || true
    if ! git diff --cached --quiet 2>/dev/null; then
      git commit -q -m "$MSG" 2>/dev/null || true
    fi
  fi
}

# Git 푸시 (remote 있을 때만)
git_push() {
  if [ -d ".git" ] && git remote get-url origin &>/dev/null; then
    git push -q 2>/dev/null || true
  fi
}

init_git

# ── queue.md 조작 (queue-util.py 사용) ────────────────────────
QUEUE_UTIL="$(dirname "$0")/queue-util.py"

add_to_queue() {
  local TITLE="$1"
  local TARGET_URL="${2:-null}"
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 "$QUEUE_UTIL" add "$TITLE" "$TARGET_URL" 1 || true
}

# ── fetch-signal.txt 감지 ────────────────────────────────────
# PROMPT Step 3에서 Claude가 fetch-signal.txt를 생성하면
# ralph.sh가 감지해서 fetch-sources.sh 실행 후 신호 파일 삭제
has_fetch_signal() {
  [ -f "fetch-signal.txt" ] && grep -q "FETCH_NEEDED=true" fetch-signal.txt 2>/dev/null
}

run_fetch() {
  echo -e "${CYAN}=== PDF 다운로드 시작 ===${NC}"
  if [ -f "fetch-sources.sh" ]; then
    if [ -n "$UNPAYWALL_EMAIL" ]; then
      bash fetch-sources.sh --email "$UNPAYWALL_EMAIL" || true
    else
      bash fetch-sources.sh || true
    fi
  else
    echo -e "${YELLOW}fetch-sources.sh 없음 — 다운로드 건너뜀${NC}"
  fi
  # 신호 파일 삭제 (다운로드 완료 표시)
  rm -f fetch-signal.txt
  echo -e "${CYAN}=== PDF 다운로드 완료 ===${NC}"
  echo ""
}

get_current_item_info() {
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 "$QUEUE_UTIL" get-item-info || true
}

# ── 헤더 출력 ────────────────────────────────────────────────
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Ralph Knowledge Pipeline${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# ── UPDATE 모드 ───────────────────────────────────────────────
if [ "$UPDATE_MODE" = true ] && [ -n "$TOPIC" ]; then
  echo -e "${CYAN}=== UPDATE 모드: \"$TOPIC\" 최신화 ===${NC}"
  echo ""

  # slug 생성
  UPDATE_SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | \
                sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
                sed 's/^-//' | sed 's/-$//' | cut -c1-60)

  # 기존 문서 확인
  if [ ! -f "docs/knowledge/${UPDATE_SLUG}.md" ]; then
    echo -e "${RED}Error: docs/knowledge/${UPDATE_SLUG}.md 없음. 먼저 일반 리서치를 실행하세요.${NC}"
    echo "  ./ralph.sh \"$TOPIC\""
    exit 1
  fi

  echo -e "${GREEN}✓ 기존 문서 발견: docs/knowledge/${UPDATE_SLUG}.md${NC}"
  echo ""

  # 1. research-engine 캐시 삭제 → 최신 논문 재검색
  if [ -f "docs/research/${UPDATE_SLUG}.json" ]; then
    echo -e "${YELLOW}캐시 삭제: docs/research/${UPDATE_SLUG}.json${NC}"
    rm -f "docs/research/${UPDATE_SLUG}.json"
  fi

  echo -e "${CYAN}=== 최신 논문 탐색 ===${NC}"
  echo ""
  RESEARCH_RESULT=$(bash research-engine.sh "$TOPIC" --max-results 20 --depth 1 --hops 2 2>&1) || true
  echo "$RESEARCH_RESULT"
  echo ""

  # 2. Claude에게 update 지시
  UPDATE_PROMPT="$(cat << UEOF
너는 기존 지식 문서를 최신 정보로 업데이트하는 에이전트야.

## 작업
1. docs/knowledge/${UPDATE_SLUG}.md 와 docs/reports/${UPDATE_SLUG}_report.md 를 읽어.
2. docs/research/${UPDATE_SLUG}.json 을 읽어서 기존 문서에 반영 안 된 최신 논문을 파악해.
3. 웹 검색으로 최신 동향(2025-2026)도 추가 조사해.
4. update.md 의 병합 정책에 따라 기존 문서를 최신화해.
5. verify-knowledge.md 로 검증하고 결과를 출력해.
6. verify-report.md 로 검증하고 결과를 출력해.

## 출력
마지막에 반드시 아래 형식으로 요약:
\`\`\`
🔄 업데이트 완료: ${UPDATE_SLUG}
  - 추가된 내용: {N}개 섹션
  - 새 출처: {N}개
  - knowledge: verify {점수}
  - report: verify {점수}
\`\`\`
UEOF
)"

  echo -e "${CYAN}=== 문서 업데이트 시작 ===${NC}"
  echo ""

  result=$(claude -p "$UPDATE_PROMPT" \
    --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
    --output-format text 2>&1) || true

  echo "$result"
  echo ""

  git_commit "update: ${UPDATE_SLUG} 최신화 완료"
  git_push

  echo -e "${GREEN}======================================${NC}"
  echo -e "${GREEN}   UPDATE 완료: ${UPDATE_SLUG}${NC}"
  echo -e "${GREEN}   ✓ Git 커밋 & 푸시 완료${NC}"
  echo -e "${GREEN}======================================${NC}"
  exit 0
fi

# ── 새 주제 queue에 추가 ─────────────────────────────────────
if [ -n "$TOPIC" ]; then
  echo -e "주제: ${GREEN}$TOPIC${NC}"
  [ -n "$URL" ] && echo -e "URL:  ${GREEN}$URL${NC}"
  echo ""

  RESULT=$(add_to_queue "$TOPIC" "$URL") || RESULT="ERROR"

  case "$RESULT" in
    DUPLICATE) echo -e "${YELLOW}⚠️  이미 queue에 있는 주제입니다. 기존 항목으로 진행합니다.${NC}" ;;
    ADDED)     echo -e "${GREEN}✓ queue에 추가됨: \"$TOPIC\"${NC}" ;;
    *)         echo -e "${YELLOW}⚠️  queue 추가 중 오류. 계속 진행합니다.${NC}" ;;
  esac
  echo ""
fi

# ── 학술 논문 자동 탐색 (research-engine) ─────────────────────
if [ -n "$TOPIC" ] && [ -f "research-engine.sh" ]; then
  echo -e "${CYAN}=== 학술 논문 탐색 시작 ===${NC}"
  echo ""
  RESEARCH_RESULT=$(bash research-engine.sh "$TOPIC" --max-results 30 --depth 1 2>&1) || true
  echo "$RESEARCH_RESULT"

  if echo "$RESEARCH_RESULT" | grep -q "RESEARCH_COMPLETE"; then
    PAPERS_QUEUED=$(echo "$RESEARCH_RESULT" | grep "^PAPERS_QUEUED=" | cut -d= -f2)
    echo ""
    echo -e "${GREEN}✓ 논문 탐색 완료: ${PAPERS_QUEUED}개 논문 queue에 추가${NC}"
  else
    echo -e "${YELLOW}⚠️ 논문 탐색 실패 또는 결과 없음. 계속 진행합니다.${NC}"
  fi
  echo ""
fi

# ── PDF 자동 다운로드 ─────────────────────────────────────────
if [ -f "fetch-sources.sh" ]; then
  echo -e "${CYAN}=== PDF 다운로드 시작 ===${NC}"
  echo ""
  if [ -n "$UNPAYWALL_EMAIL" ]; then
    bash fetch-sources.sh --email "$UNPAYWALL_EMAIL" || true
  else
    bash fetch-sources.sh || true
  fi
  echo ""
fi

# research-engine + fetch 완료 후 커밋
git_commit "research: ${TOPIC:-queue} — 논문 탐색 + PDF 다운로드"

echo -e "최대 반복 횟수: ${GREEN}$MAX_ITERATIONS${NC}"
echo ""

# PROMPT.md 절대 경로 캐싱
PROMPT_PATH="$(cd "$(dirname "PROMPT.md")" && pwd)/PROMPT.md"

echo -e "${YELLOW}2초 후 시작... 중단하려면 Ctrl+C${NC}"
sleep 2
echo ""

# ── 메인 루프 ────────────────────────────────────────────────
for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo -e "${BLUE}--- Iteration $i / $MAX_ITERATIONS ---${NC}"
  echo ""

  # 혹시 이전 루프에서 fetch 신호가 남아있으면 먼저 처리
  if has_fetch_signal; then
    echo -e "${CYAN}이전 fetch 신호 감지 — 다운로드 재시도${NC}"
    run_fetch
  fi

  # ── PDF 수집: docs/sources/ 에서 사용 가능한 PDF 모두 탐색 ──
  FILE_ARGS=""
  PDF_COUNT=0

  # 1. docs/sources/ 폴더의 PDF (종합 리서치용)
  if [ -d "docs/sources" ]; then
    while IFS= read -r -d '' f; do
      if [ "$PDF_COUNT" -lt 5 ]; then
        FILE_ARGS="$FILE_ARGS --file \"$f\""
        PDF_COUNT=$((PDF_COUNT + 1))
      fi
    done < <(find "docs/sources" -name "*.pdf" -print0 2>/dev/null)
  fi

  # 2. 개별 항목의 local_path 또는 pdf_dir (기존 호환)
  if [ "$PDF_COUNT" -eq 0 ]; then
    ITEM_INFO=$(get_current_item_info) || ITEM_INFO=$'\n'
    CURRENT_PDF=$(echo "$ITEM_INFO" | sed -n '1p')
    CURRENT_PDF_DIR=$(echo "$ITEM_INFO" | sed -n '2p')

    if [ -n "$CURRENT_PDF_DIR" ] && [ -d "$CURRENT_PDF_DIR" ]; then
      while IFS= read -r -d '' f; do
        if [ "$PDF_COUNT" -lt 5 ]; then
          FILE_ARGS="$FILE_ARGS --file \"$f\""
          PDF_COUNT=$((PDF_COUNT + 1))
        fi
      done < <(find "$CURRENT_PDF_DIR" -name "*.pdf" -print0 2>/dev/null)
    elif [ -n "$CURRENT_PDF" ] && [ -f "$CURRENT_PDF" ]; then
      FILE_ARGS="--file \"$CURRENT_PDF\""
      PDF_COUNT=1
    fi
  fi

  # PDF 첨부 상태 출력
  if [ "$PDF_COUNT" -gt 0 ]; then
    echo -e "${GREEN}📄 PDF ${PDF_COUNT}개 첨부${NC}"
  else
    echo -e "${YELLOW}📄 PDF 없음 — 웹 검색 + 초록 기반으로 진행${NC}"
  fi
  echo ""

  # Claude 실행
  if [ "$PDF_COUNT" -gt 0 ]; then
    result=$(eval claude -p "\"$(cat PROMPT.md)\"" $FILE_ARGS --allowedTools "'Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash'" --output-format text 2>&1) || true
  else
    result=$(claude -p "$(cat PROMPT.md)" \
      --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
      --output-format text 2>&1) || true
  fi

  echo "$result"
  echo ""

  # ── fetch 신호 감지 → 다운로드 → 같은 iteration 내 재실행 ──
  if has_fetch_signal; then
    run_fetch

    echo -e "${CYAN}=== PDF 확보 완료 → 본격 리서치 재시작 ===${NC}"
    echo ""

    # PDF 경로 갱신 후 Claude 재실행
    CURRENT_PDF=$(get_current_pdf) || CURRENT_PDF=""

    if [ -n "$CURRENT_PDF" ] && [ -f "$CURRENT_PDF" ]; then
      echo -e "${GREEN}📄 PDF 첨부: $CURRENT_PDF${NC}"
      echo ""
      result=$(claude -p "$(cat PROMPT.md)" \
        --file "$CURRENT_PDF" \
        --output-format text 2>&1) || true
    else
      result=$(claude -p "$(cat PROMPT.md)" \
        --output-format text 2>&1) || true
    fi

    echo "$result"
    echo ""
  fi

  # ── WAITING_FOR_FETCH 신호 (fetch 루프 충돌 방지) ───────────
  if [[ "$result" == *"<promise>WAITING_FOR_FETCH</promise>"* ]]; then
    echo -e "${YELLOW}⚠️  예상치 못한 WAITING_FOR_FETCH 신호. fetch 신호 파일 확인 중...${NC}"
    if has_fetch_signal; then
      run_fetch
      echo -e "${CYAN}재시도 중...${NC}"
      continue
    fi
  fi

  # ── 완료 신호 체크 ────────────────────────────────────────
  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo -e "${GREEN}======================================${NC}"
    echo -e "${GREEN}   완료! (${i}번 iteration)${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo ""
    echo "결과물:"
    echo "  docs/knowledge/  — 지식 DB"
    echo "  docs/reports/    — 보고서"
    echo "  docs/sources/    — 원본 PDF"
    echo "  activity.md      — 실행 로그"
    echo "  queue.md         — 처리 이력"
    echo ""
    git_commit "complete: iteration ${i} — 전체 완료"
    git_push
    echo -e "${GREEN}✓ Git 커밋 & 푸시 완료${NC}"
    exit 0
  fi

  # iteration 완료 후 자동 커밋
  git_commit "iteration ${i}: ${TOPIC:-queue} 처리"

  echo -e "${YELLOW}--- Iteration $i 완료 ---${NC}"
  echo ""
done

# ── 최대 반복 도달 ───────────────────────────────────────────
echo ""
echo -e "${RED}최대 반복 횟수 도달 ($MAX_ITERATIONS)${NC}"
echo ""
git_commit "session: ${MAX_ITERATIONS} iterations 완료"
git_push
echo -e "${GREEN}✓ Git 커밋 & 푸시 완료${NC}"
echo ""
echo "남은 항목이 있으면:"
echo "  ./ralph.sh --run 20"
echo ""
exit 1
