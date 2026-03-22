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
MODEL_LIGHT="${MODEL_LIGHT:-sonnet}"

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
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 "$(dirname "$0")/queue-util.py" get-pending-fetch
}

# ── 헬퍼: queue.md 업데이트 (local_path, access_type) ─────────
update_queue_item() {
  local TITLE="$1"
  local LOCAL_PATH="$2"
  local ACCESS_TYPE="$3"

  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$TITLE" "$LOCAL_PATH" "$ACCESS_TYPE" << 'PYEOF'
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
  PDF_URL=$(echo "$RESPONSE" | $PYTHON3 -c "
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
  ENCODED_TITLE=$($PYTHON3 -c "import urllib.parse; print(urllib.parse.quote('$TITLE'))")
  local API_URL="https://api.semanticscholar.org/graph/v1/paper/search?query=${ENCODED_TITLE}&fields=title,openAccessPdf&limit=1"
  local RESPONSE
  RESPONSE=$(curl -sL --max-time 15 "$API_URL" 2>/dev/null)

  local PDF_URL
  PDF_URL=$(echo "$RESPONSE" | $PYTHON3 -c "
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

# ── PMC API → PDF 다운로드 (의생명/생체역학 논문) ─────────────
try_pmc() {
  local TITLE="$1"
  local OUTPUT="$2"

  # research JSON에서 PMID/DOI 조회
  local PMC_INFO
  PMC_INFO=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$TITLE" << 'PMCEOF'
import sys, json, glob, os, re
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
title = sys.argv[1].lower().strip()
for jf in glob.glob("docs/research/*.json"):
    try:
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for p in data.get('papers', []):
            if p.get('title', '').lower().strip() == title:
                pmid = p.get('pmid', '') or p.get('pubmedId', '') or ''
                doi = p.get('doi', '') or ''
                pmc_id = p.get('pmcid', '') or p.get('pmcId', '') or ''
                print(f"PMID={pmid}")
                print(f"DOI={doi}")
                print(f"PMCID={pmc_id}")
                sys.exit(0)
    except:
        continue
print("PMID=")
print("DOI=")
print("PMCID=")
PMCEOF
  ) || PMC_INFO=""

  local PMID DOI PMCID
  PMID=$(echo "$PMC_INFO" | grep "^PMID=" | cut -d= -f2-)
  DOI=$(echo "$PMC_INFO" | grep "^DOI=" | cut -d= -f2-)
  PMCID=$(echo "$PMC_INFO" | grep "^PMCID=" | cut -d= -f2-)

  # PMID로 PMC ID 조회
  if [ -z "$PMCID" ] && [ -n "$PMID" ]; then
    echo -e "  ${BLUE}PMC 시도: PMID=$PMID${NC}"
    local CONV_RESP
    CONV_RESP=$(curl -sL --max-time 15 "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=${PMID}&format=json" 2>/dev/null)
    PMCID=$(echo "$CONV_RESP" | $PYTHON3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for r in data.get('records', []):
        pmcid = r.get('pmcid', '')
        if pmcid:
            print(pmcid)
            break
    else:
        print('')
except:
    print('')
" 2>/dev/null)
  fi

  # DOI로 PMC ID 조회
  if [ -z "$PMCID" ] && [ -n "$DOI" ]; then
    echo -e "  ${BLUE}PMC 시도: DOI=$DOI${NC}"
    local CONV_RESP
    CONV_RESP=$(curl -sL --max-time 15 "https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=${DOI}&format=json" 2>/dev/null)
    PMCID=$(echo "$CONV_RESP" | $PYTHON3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for r in data.get('records', []):
        pmcid = r.get('pmcid', '')
        if pmcid:
            print(pmcid)
            break
    else:
        print('')
except:
    print('')
" 2>/dev/null)
  fi

  if [ -n "$PMCID" ]; then
    # PMC ID에서 숫자만 추출
    local PMC_NUM="${PMCID#PMC}"
    local PDF_URL="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC${PMC_NUM}/pdf/"
    echo -e "  ${BLUE}PMC PDF 시도: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── bioRxiv/medRxiv DOI → PDF 직접 변환 ──────────────────────
try_biorxiv() {
  local URL="$1"
  local TITLE="$2"
  local OUTPUT="$3"

  # URL에서 bioRxiv/medRxiv DOI 감지
  local PDF_URL=""
  if [[ "$URL" =~ (biorxiv\.org|medrxiv\.org)/content/([0-9.]+/[0-9v.]+) ]]; then
    local BASE="${BASH_REMATCH[1]}"
    local DOI_SUFFIX="${BASH_REMATCH[2]}"
    PDF_URL="https://www.${BASE}/content/${DOI_SUFFIX}.full.pdf"
  fi

  # research JSON에서 DOI로도 시도
  if [ -z "$PDF_URL" ]; then
    local DOI_INFO
    DOI_INFO=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$TITLE" << 'BREOF'
import sys, json, glob
title = sys.argv[1].lower().strip()
for jf in glob.glob("docs/research/*.json"):
    try:
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for p in data.get('papers', []):
            if p.get('title', '').lower().strip() == title:
                doi = p.get('doi', '') or ''
                if 'biorxiv' in doi.lower() or 'medrxiv' in doi.lower():
                    print(doi)
                    sys.exit(0)
    except:
        continue
print('')
BREOF
    ) || DOI_INFO=""
    if [ -n "$DOI_INFO" ]; then
      PDF_URL="https://doi.org/${DOI_INFO}.full.pdf"
    fi
  fi

  if [ -n "$PDF_URL" ]; then
    echo -e "  ${BLUE}bioRxiv/medRxiv PDF 시도: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── 웹 검색 → PDF URL 탐색 (최종 폴백) ───────────────────────
try_websearch() {
  local TITLE="$1"
  local OUTPUT="$2"

  echo -e "  ${BLUE}웹 검색 시도: \"$TITLE\"${NC}"

  # Claude WebSearch로 PDF URL 탐색
  local SEARCH_PROMPT="논문 제목: \"${TITLE}\"

이 논문의 무료 전문 PDF를 찾아줘. 아래 순서로 검색:
1. 저자 홈페이지/대학 레포지토리
2. ResearchGate, Academia.edu
3. 정부/기관 오픈 액세스 레포지토리

규칙:
- 반드시 직접 PDF 다운로드가 가능한 URL만 반환
- sci-hub, libgen 등 불법 소스 제외
- 로그인 필요한 페이지 제외
- PDF URL을 찾으면 해당 URL만 한 줄로 출력 (https://...로 시작)
- 못 찾으면 NOT_FOUND 한 줄만 출력"

  local SEARCH_RESULT
  SEARCH_RESULT=$(claude -p "$SEARCH_PROMPT" \
    --model "$MODEL_LIGHT" \
    --allowedTools "WebSearch,WebFetch" \
    --output-format text 2>&1) || SEARCH_RESULT=""

  # 결과에서 PDF URL 추출
  local PDF_URL
  PDF_URL=$(echo "$SEARCH_RESULT" | grep -oE 'https?://[^ ]+\.pdf' | head -1)

  # .pdf 확장자가 URL에 없어도 PDF일 수 있음 — 일반 URL도 시도
  if [ -z "$PDF_URL" ]; then
    PDF_URL=$(echo "$SEARCH_RESULT" | grep -oE 'https?://[^ ]+' | grep -viE 'NOT_FOUND|sci-hub|libgen' | head -1)
  fi

  if [ -n "$PDF_URL" ] && [ "$PDF_URL" != "NOT_FOUND" ]; then
    echo -e "  ${BLUE}웹 검색 PDF 발견: $PDF_URL${NC}"
    if curl -sL --max-time 30 -o "$OUTPUT" "$PDF_URL" && \
       file "$OUTPUT" 2>/dev/null | grep -q "PDF"; then
      return 0
    fi
    rm -f "$OUTPUT"
  fi
  return 1
}

# ── 분야 감지 → 다운로드 순서 결정 ───────────────────────────
# 논문 메타데이터에서 분야 판별하여 최적의 다운로드 순서 반환
detect_field_order() {
  local TITLE="$1"
  local URL="$2"
  local _FIELD_RESULT
  _FIELD_RESULT=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$TITLE" "$URL" << 'DFEOF' 2>/dev/null
import sys, json, glob, re
title = sys.argv[1].lower().strip()
url = sys.argv[2].lower() if len(sys.argv) > 2 else ''

# URL 기반 판별
if 'pubmed' in url or 'ncbi' in url or 'pmc' in url:
    print("biomedical")
    sys.exit(0)
if 'biorxiv' in url or 'medrxiv' in url:
    print("biomedical")
    sys.exit(0)
if 'arxiv' in url:
    print("cs_ai")
    sys.exit(0)

# research JSON에서 메타데이터 기반 판별
for jf in glob.glob("docs/research/*.json"):
    try:
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for p in data.get('papers', []):
            if p.get('title', '').lower().strip() == title:
                doi = (p.get('doi', '') or '').lower()
                venue = (p.get('venue', '') or p.get('journal', '') or '').lower()
                pmid = p.get('pmid', '') or p.get('pubmedId', '') or ''
                # PMID 있으면 의생명
                if pmid:
                    print("biomedical")
                    sys.exit(0)
                # DOI prefix 판별
                if doi.startswith('10.1101'):  # bioRxiv/medRxiv
                    print("biomedical")
                    sys.exit(0)
                if doi.startswith('10.1371') or doi.startswith('10.1016'):  # PLoS, Elsevier
                    print("biomedical")
                    sys.exit(0)
                # venue 키워드
                bio_kw = ['biomedical', 'biomech', 'medical', 'clinical', 'neuro', 'physiol',
                          'anatomy', 'kinesiol', 'rehab', 'sport', 'health', 'plos', 'bmc',
                          'lancet', 'jama', 'nature medicine', 'cell']
                cs_kw = ['arxiv', 'neurips', 'icml', 'iclr', 'cvpr', 'iccv', 'eccv',
                         'aaai', 'acl', 'emnlp', 'ieee', 'acm', 'sigchi']
                for kw in bio_kw:
                    if kw in venue:
                        print("biomedical")
                        sys.exit(0)
                for kw in cs_kw:
                    if kw in venue:
                        print("cs_ai")
                        sys.exit(0)
                break
    except:
        continue
print("default")
DFEOF
  ) || _FIELD_RESULT="default"
  echo "${_FIELD_RESULT:-default}" | tail -1
}

# ── 메인: pending 항목 순회 ───────────────────────────────────
ITEMS=$(get_pending_items)
COUNT=$(echo "$ITEMS" | $PYTHON3 -c "import json,sys; print(len(json.load(sys.stdin)))")

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
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$TITLE" << 'PYEOF' 2>/dev/null || echo ""
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

  # 분야 감지 → 다운로드 순서 결정
  local FIELD_ORDER
  FIELD_ORDER=$(detect_field_order "$TITLE" "$URL") || FIELD_ORDER="default"

  case "$FIELD_ORDER" in
    biomedical)
      # 의생명/생체역학: PMC → Unpaywall → bioRxiv → Semantic Scholar → 웹검색
      if try_pmc "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_unpaywall "$URL" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_biorxiv "$URL" "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_semantic_scholar "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_websearch "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      fi
      ;;
    cs_ai)
      # CS/AI: arXiv → Semantic Scholar → Unpaywall → 웹검색
      if try_arxiv "$URL" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_semantic_scholar "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_unpaywall "$URL" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_websearch "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      fi
      ;;
    *)
      # 기본: arXiv → Unpaywall → Semantic Scholar → PMC → bioRxiv → 웹검색
      if try_arxiv "$URL" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_unpaywall "$URL" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_semantic_scholar "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_pmc "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_biorxiv "$URL" "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      elif try_websearch "$TITLE" "$OUTPUT"; then DOWNLOADED_OK=true
      fi
      ;;
  esac

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
    METHODS="$METHODS, Semantic Scholar, PMC, bioRxiv, WebSearch"

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
echo "$ITEMS" | $PYTHON3 -c "
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
