#!/bin/bash
# fetch-sources.sh
# ================
# queue.md의 pending 항목을 순회하며 PDF를 자동 다운로드.
# ralph.sh가 메인 루프 시작 전에 이 스크립트를 먼저 실행.
#
# 다운로드 전략 (순서대로 시도):
#   1. arXiv URL → 직접 PDF 다운로드
#   2. Unpaywall API → 오픈 액세스 PDF 검색 (DOI 필요)
#   3. Semantic Scholar API → 오픈 액세스 링크 검색
#   4. 모두 실패 → access_type을 url 또는 limited로 유지
#
# 사용법: ./fetch-sources.sh [--email your@email.com]
# Unpaywall은 이메일 주소가 있어야 API 사용 가능 (무료)

set -e

# Python 자동 감지
source "$(dirname "$0")/detect-python.sh" || exit 1

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SOURCES_DIR="docs/sources"
UNPAYWALL_EMAIL="${UNPAYWALL_EMAIL:-}"

# --email 옵션 파싱
while [[ $# -gt 0 ]]; do
  case $1 in
    --email) UNPAYWALL_EMAIL="$2"; shift 2 ;;
    *) shift ;;
  esac
done

mkdir -p "$SOURCES_DIR"

echo -e "${BLUE}=== fetch-sources: PDF 자동 다운로드 시작 ===${NC}"
echo ""

# ── 헬퍼: queue.md에서 pending 항목 추출 (queue-util.py 통일) ──
get_pending_items() {
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 queue-util.py get-pending-fetch
}

# ── 헬퍼: queue.md 업데이트 (local_path, access_type) ─────────
update_queue_item() {
  local TITLE="$1"
  local LOCAL_PATH="$2"
  local ACCESS_TYPE="$3"

  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 - "$TITLE" "$LOCAL_PATH" "$ACCESS_TYPE" << 'PYEOF'
import sys, re
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')

title       = sys.argv[1]
local_path  = sys.argv[2]
access_type = sys.argv[3]

with open("queue.md", "r", encoding="utf-8") as f:
    content = f.read()

# 해당 title 블록 찾아서 local_path, access_type 갱신
escaped = re.escape(title)
pattern = r'(  - title:\s*["\']?' + escaped + r'["\']?.*?)(local_path:\s*\S+)(.*?)(access_type:\s*\S+)'

def replacer(m):
    return m.group(1) + f'local_path: "{local_path}"' + m.group(3) + f'access_type: {access_type}'

new_content = re.sub(pattern, replacer, content, flags=re.DOTALL)

if new_content != content:
    with open("queue.md", "w", encoding="utf-8") as f:
        f.write(new_content)
    print("updated")
else:
    print("not_found")
PYEOF
}

# ── arXiv URL → PDF 직접 다운로드 ────────────────────────────
try_arxiv() {
  local URL="$1"
  local OUTPUT="$2"

  # arXiv abs URL → pdf URL 변환
  # https://arxiv.org/abs/1706.03762 → https://arxiv.org/pdf/1706.03762
  if [[ "$URL" =~ arxiv\.org/abs/([0-9]+\.[0-9]+) ]]; then
    local ARXIV_ID="${BASH_REMATCH[1]}"
    local PDF_URL="https://arxiv.org/pdf/${ARXIV_ID}"
    echo -e "  ${BLUE}arXiv PDF 시도: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── Unpaywall API → 오픈 액세스 PDF ──────────────────────────
try_unpaywall() {
  local URL="$1"
  local OUTPUT="$2"

  [ -z "$UNPAYWALL_EMAIL" ] && return 1

  # DOI 추출 시도
  local DOI=""
  if [[ "$URL" =~ doi\.org/(.+) ]]; then
    DOI="${BASH_REMATCH[1]}"
  elif [[ "$URL" =~ /doi/(.+) ]]; then
    DOI="${BASH_REMATCH[1]}"
  fi
  [ -z "$DOI" ] && return 1

  echo -e "  ${BLUE}Unpaywall 시도: DOI=$DOI${NC}"
  local API_URL="https://api.unpaywall.org/v2/${DOI}?email=${UNPAYWALL_EMAIL}"
  local RESPONSE
  RESPONSE=$(curl -sL --max-time 15 "$API_URL" 2>/dev/null)

  local PDF_URL
  PDF_URL=$(echo "$RESPONSE" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    loc = data.get('best_oa_location') or {}
    url = loc.get('url_for_pdf') or loc.get('url') or ''
    print(url)
except:
    print('')
" 2>/dev/null)

  if [ -n "$PDF_URL" ] && [ "$PDF_URL" != "None" ]; then
    echo -e "  ${BLUE}오픈 액세스 PDF 발견: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── Semantic Scholar API → 오픈 액세스 링크 ──────────────────
try_semantic_scholar() {
  local TITLE="$1"
  local OUTPUT="$2"

  echo -e "  ${BLUE}Semantic Scholar 시도: \"$TITLE\"${NC}"
  local ENCODED_TITLE
  ENCODED_TITLE=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TITLE'))")
  local API_URL="https://api.semanticscholar.org/graph/v1/paper/search?query=${ENCODED_TITLE}&fields=title,openAccessPdf&limit=1"
  local RESPONSE
  RESPONSE=$(curl -sL --max-time 15 "$API_URL" 2>/dev/null)

  local PDF_URL
  PDF_URL=$(echo "$RESPONSE" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    papers = data.get('data', [])
    if papers:
        oa = papers[0].get('openAccessPdf') or {}
        print(oa.get('url', ''))
    else:
        print('')
except:
    print('')
" 2>/dev/null)

  if [ -n "$PDF_URL" ] && [ "$PDF_URL" != "None" ]; then
    echo -e "  ${BLUE}오픈 액세스 PDF 발견: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── 메인: pending 항목 순회 ───────────────────────────────────
ITEMS=$(get_pending_items)
COUNT=$(echo "$ITEMS" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

if [ "$COUNT" -eq 0 ]; then
  echo -e "${GREEN}다운로드할 새 항목 없음 (이미 모두 처리됨)${NC}"
  echo ""
  exit 0
fi

echo -e "처리할 항목: ${GREEN}${COUNT}개${NC}"
echo ""

# 접근 불가 논문 목록 파일
INACCESSIBLE_FILE="inaccessible-papers.txt"
if [ ! -f "$INACCESSIBLE_FILE" ]; then
  cat > "$INACCESSIBLE_FILE" << 'IAEOF'
# 접근 불가 논문 목록 (Inaccessible Papers)
# ==========================================
# PDF 다운로드에 실패한 유료/비공개 논문 목록입니다.
# 수동으로 확보 후 docs/sources/ 에 넣고 queue.md의 local_path를 업데이트하세요.
# ==========================================

IAEOF
fi

# research JSON에서 논문 상세 정보 조회
lookup_paper_info() {
  local TITLE="$1"
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8 - "$TITLE" << 'PYEOF' 2>/dev/null || echo ""
import sys, json, os, glob
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

title = sys.argv[1].lower().strip()
info = {"authors": "", "year": "", "doi": "", "abstract": ""}

for jf in glob.glob("docs/research/*.json"):
    try:
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for p in data.get('papers', []):
            if p.get('title', '').lower().strip() == title:
                authors = p.get('authors', [])
                info['authors'] = ', '.join(authors[:3])
                if len(authors) > 3:
                    info['authors'] += ' et al.'
                info['year'] = str(p.get('year', ''))
                info['doi'] = p.get('doi', '')
                info['abstract'] = (p.get('abstract', '') or '')[:200]
                break
    except:
        continue

print(f"AUTHORS={info['authors']}")
print(f"YEAR={info['year']}")
print(f"DOI={info['doi']}")
print(f"ABSTRACT={info['abstract']}")
PYEOF
}

# 단일 항목 다운로드 함수
download_one() {
  local TITLE="$1"
  local URL="$2"
  local SAFE_NAME
  SAFE_NAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | \
              sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
              sed 's/^-//' | sed 's/-$//' | cut -c1-60)
  local OUTPUT="${SOURCES_DIR}/${SAFE_NAME}.pdf"

  # 이미 파일 있으면 건너뜀
  if [ -f "$OUTPUT" ]; then
    echo -e "  ${YELLOW}건너뜀: $SAFE_NAME (이미 존재)${NC}"
    update_queue_item "$TITLE" "$OUTPUT" "pdf" > /dev/null
    return
  fi

  local DOWNLOADED_OK=false

  if try_arxiv "$URL" "$OUTPUT"; then
    DOWNLOADED_OK=true
  elif try_unpaywall "$URL" "$OUTPUT"; then
    DOWNLOADED_OK=true
  elif try_semantic_scholar "$TITLE" "$OUTPUT"; then
    DOWNLOADED_OK=true
  fi

  if $DOWNLOADED_OK; then
    local SIZE
    SIZE=$(du -sh "$OUTPUT" 2>/dev/null | cut -f1)
    echo -e "  ${GREEN}✓ $SAFE_NAME ($SIZE)${NC}"
    update_queue_item "$TITLE" "$OUTPUT" "pdf" > /dev/null
  else
    echo -e "  ${YELLOW}✗ $SAFE_NAME — url/limited${NC}"
    rm -f "$OUTPUT"

    # 접근 불가 논문 상세 기록
    local TODAY
    TODAY=$(date +%Y-%m-%d)
    local METHODS="arXiv"
    [ -n "$UNPAYWALL_EMAIL" ] && METHODS="$METHODS, Unpaywall"
    METHODS="$METHODS, Semantic Scholar"

    # research JSON에서 추가 정보 조회
    local PAPER_INFO
    PAPER_INFO=$(lookup_paper_info "$TITLE")
    local P_AUTHORS P_YEAR P_DOI P_ABSTRACT
    P_AUTHORS=$(echo "$PAPER_INFO" | grep "^AUTHORS=" | cut -d= -f2-)
    P_YEAR=$(echo "$PAPER_INFO" | grep "^YEAR=" | cut -d= -f2-)
    P_DOI=$(echo "$PAPER_INFO" | grep "^DOI=" | cut -d= -f2-)
    P_ABSTRACT=$(echo "$PAPER_INFO" | grep "^ABSTRACT=" | cut -d= -f2-)

    {
      echo "---"
      echo "제목: $TITLE"
      [ -n "$P_AUTHORS" ] && echo "저자: $P_AUTHORS"
      [ -n "$P_YEAR" ] && [ "$P_YEAR" != "0" ] && echo "연도: $P_YEAR"
      echo "URL: $URL"
      [ -n "$P_DOI" ] && echo "DOI: $P_DOI"
      [ -n "$P_DOI" ] && echo "DOI링크: https://doi.org/$P_DOI"
      [ -n "$P_ABSTRACT" ] && echo "초록: $P_ABSTRACT..."
      echo "시도 방법: $METHODS"
      echo "실패 날짜: $TODAY"
      echo ""
    } >> "$INACCESSIBLE_FILE"
  fi
}

# 항목 목록을 임시 파일로 저장 (파이프 서브쉘 문제 회피)
ITEM_LIST_FILE=$(mktemp)
echo "$ITEMS" | python3 -c "
import json, sys
items = json.load(sys.stdin)
for item in items:
    # 탭으로 구분: title\turl
    title = item['title'].replace('\t', ' ')
    url = item['url'].replace('\t', ' ')
    print(f'{title}\t{url}')
" > "$ITEM_LIST_FILE"

# 순차 다운로드 (함수 상속 문제 없음, arXiv는 충분히 빠름)
while IFS=$'\t' read -r TITLE URL; do
  [ -z "$TITLE" ] && continue
  download_one "$TITLE" "$URL"
done < "$ITEM_LIST_FILE"

rm -f "$ITEM_LIST_FILE"

# 접근 불가 논문 수 출력
INACCESSIBLE_COUNT=$(grep -c "^제목:" "$INACCESSIBLE_FILE" 2>/dev/null)
INACCESSIBLE_COUNT=${INACCESSIBLE_COUNT:-0}
INACCESSIBLE_COUNT=${INACCESSIBLE_COUNT// /}
if [ "$INACCESSIBLE_COUNT" -gt 0 ] 2>/dev/null; then
  echo -e "${YELLOW}⚠️ 접근 불가 논문: ${INACCESSIBLE_COUNT}개 — ${INACCESSIBLE_FILE} 참조${NC}"
  echo ""
fi

echo -e "${BLUE}=== fetch-sources 완료 ===${NC}"
echo ""
