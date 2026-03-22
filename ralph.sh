#!/bin/bash
# Ralph Wiggum Knowledge Pipeline
# ================================
# 사용법:
#   주제 던지기:    ./ralph.sh "transformer architecture"
#   논문 + URL:     ./ralph.sh "Attention Is All You Need" "https://arxiv.org/abs/1706.03762"
#   반복 수 지정:   ./ralph.sh "transformer architecture" --iterations 20
#   queue만 실행:   ./ralph.sh --run 20
#   Unpaywall:      ./ralph.sh "BERT" --email your@email.com
#
# 에러 자동 복구:
#   내장 recovery 시스템이 에러 감지 → 자동 복구 → 재시도
#   새 에러는 error-patterns.json에 자동 학습됨
#   --max-retries N  최대 재시도 횟수 (기본 3)
#   --no-recovery    복구 시스템 비활성화 (디버깅용)

set -eo pipefail
trap 'echo "[FATAL] line $LINENO exit $? cmd: $BASH_COMMAND" >&2' ERR

_RALPH_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ══════════════════════════════════════════════════════════════
# Recovery 래퍼 — --_inner 없이 호출되면 자기 자신을 래핑하여 실행
# ══════════════════════════════════════════════════════════════
if [[ " $* " != *" --_inner "* ]] && [[ " $* " != *" --no-recovery "* ]]; then

  # --max-retries, --no-recovery 파싱
  _MAX_RETRIES=3
  _PASSTHROUGH_ARGS=()
  _NEXT=""
  for _arg in "$@"; do
    case "$_arg" in
      --max-retries) _NEXT="retries" ;;
      --no-recovery) ;; # 여기 안 옴 (위 조건에서 걸림)
      *)
        if [ "$_NEXT" = "retries" ]; then
          _MAX_RETRIES="$_arg"; _NEXT=""
        else
          _PASSTHROUGH_ARGS+=("$_arg")
        fi ;;
    esac
  done

  _LOG_DIR="${_RALPH_SCRIPT_DIR}/.recovery-logs"
  _ERROR_DB="${_RALPH_SCRIPT_DIR}/error-patterns.json"
  mkdir -p "$_LOG_DIR"

  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

  # Python 감지 (recovery용)
  _PY3=""
  for _p in /c/Users/kbg52/AppData/Local/Programs/Python/Python312/python.exe \
            /c/Python314/python.exe python3 python; do
    if "$_p" --version &>/dev/null 2>&1; then _PY3="$_p"; break; fi
  done

  # ── 에러 DB 초기화 ──────────────────────────────────────────
  if [ ! -f "$_ERROR_DB" ]; then
    cat > "$_ERROR_DB" << 'INITJSON'
{
  "_meta": { "version": 2, "last_updated": "" },
  "builtin": [
    { "id": "subtopic_cd",     "pattern": "cd:.*subtopics/.*No such file or directory", "fix": "fix_subtopic_dirs", "severity": "critical", "seen_count": 0 },
    { "id": "marker_fail",     "pattern": "변환 실패", "fix": "fix_marker", "severity": "warning", "seen_count": 0 },
    { "id": "queue_util_miss", "pattern": "can't open file.*queue-util\\.py", "fix": "fix_queue_util", "severity": "critical", "seen_count": 0 },
    { "id": "python_missing",  "pattern": "Python was not found", "fix": "fix_noop", "severity": "fatal", "seen_count": 0 },
    { "id": "api_rate_limit",  "pattern": "rate.?limit|usage.?limit|429|529|overloaded|capacity", "fix": "fix_rate_limit", "severity": "transient", "seen_count": 0 },
    { "id": "permission",      "pattern": "Permission denied", "fix": "fix_permissions", "severity": "critical", "seen_count": 0 },
    { "id": "disk_full",       "pattern": "No space left on device", "fix": "fix_noop", "severity": "fatal", "seen_count": 0 },
    { "id": "git_lock",        "pattern": "Unable to create.*\\.lock", "fix": "fix_git_lock", "severity": "critical", "seen_count": 0 },
    { "id": "subtopics_json",  "pattern": "FileNotFoundError.*subtopics\\.json", "fix": "fix_subtopics_json", "severity": "critical", "seen_count": 0 },
    { "id": "module_missing",  "pattern": "ModuleNotFoundError: No module named", "fix": "fix_module", "severity": "critical", "seen_count": 0 },
    { "id": "conn_error",      "pattern": "ConnectionError|ConnectionRefused|ConnectionReset|ECONNREFUSED", "fix": "fix_rate_limit", "severity": "transient", "seen_count": 0 },
    { "id": "timeout",         "pattern": "TimeoutError|timed? ?out|ETIMEDOUT", "fix": "fix_rate_limit", "severity": "transient", "seen_count": 0 },
    { "id": "silent_exit",    "pattern": "\\[FATAL\\] line [0-9]+ exit [0-9]+ cmd:", "fix": "fix_silent_exit", "severity": "critical", "seen_count": 0 }
  ],
  "learned": []
}
INITJSON
  fi

  # ── 복구 함수들 ────────────────────────────────────────────
  _fix_subtopic_dirs() {
    local WD="$1"
    echo -e "${YELLOW}  [복구] subtopics 디렉토리 재생성${NC}"
    if [ -f "${WD}/subtopics.json" ] && [ -n "$_PY3" ]; then
      PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $_PY3 -X utf8 -c "
import json, os
with open('${WD}/subtopics.json','r',encoding='utf-8') as f: data=json.load(f)
for leaf in data.get('leaves',[]):
    p=leaf.get('path','')
    if p: os.makedirs(os.path.join('${WD}','subtopics',p),exist_ok=True)
" 2>/dev/null || true
    fi
  }
  _fix_queue_util() {
    local WD="$1"
    echo -e "${YELLOW}  [복구] queue-util.py 배포${NC}"
    [ -f "${_RALPH_SCRIPT_DIR}/queue-util.py" ] && \
      cp "${_RALPH_SCRIPT_DIR}/queue-util.py" "${WD}/queue-util.py" 2>/dev/null || true
    find "${WD}/subtopics" -mindepth 1 -maxdepth 3 -type d 2>/dev/null | while read d; do
      cp "${_RALPH_SCRIPT_DIR}/queue-util.py" "$d/queue-util.py" 2>/dev/null || true
    done
  }
  _fix_rate_limit() {
    local DELAY="${_RETRY_DELAY:-30}"
    echo -e "${YELLOW}  [복구] rate limit — ${DELAY}초 대기${NC}"
    sleep "$DELAY"
    _RETRY_DELAY=$(( DELAY * 2 ))
    if [ "${_RETRY_DELAY}" -gt 300 ]; then _RETRY_DELAY=300; fi
  }
  _fix_permissions() {
    local WD="$1"
    echo -e "${YELLOW}  [복구] lock 파일 정리${NC}"
    find "$WD" -name "*.lock" -delete 2>/dev/null || true
  }
  _fix_git_lock() {
    local WD="$1"
    echo -e "${YELLOW}  [복구] git lock 제거${NC}"
    rm -f "${WD}/.git/index.lock" "${WD}/.git/refs/heads/"*.lock 2>/dev/null || true
  }
  _fix_subtopics_json() {
    echo -e "${YELLOW}  [복구] subtopics.json 누락 → --no-split 추가${NC}"
    if [[ ! " ${_PASSTHROUGH_ARGS[*]} " =~ " --no-split " ]]; then
      _PASSTHROUGH_ARGS+=("--no-split")
    fi
  }
  _fix_module() {
    echo -e "${YELLOW}  [복구] Python 모듈 설치 시도${NC}"
    local MOD
    MOD=$(grep -oP "No module named '\K[^']+" "$_ATTEMPT_LOG" 2>/dev/null | tail -1)
    [ -n "$MOD" ] && [ -n "$_PY3" ] && $_PY3 -m pip install "$MOD" 2>/dev/null || true
  }
  _fix_marker() {
    echo -e "${YELLOW}  [복구] marker 확인 — 없으면 JSON 기반 진행${NC}"
  }
  _fix_silent_exit() {
    local WD="$1"
    echo -e "${YELLOW}  [복구] set -e 조용한 종료 감지 — 문제 라인 분석${NC}"
    # [FATAL] 로그에서 라인 번호와 명령 추출
    local FATAL_LINE
    FATAL_LINE=$(grep -oP '\[FATAL\] line \K[0-9]+' "$_ATTEMPT_LOG" 2>/dev/null | tail -1)
    local FATAL_CMD
    FATAL_CMD=$(grep -oP '\[FATAL\].*cmd: \K.*' "$_ATTEMPT_LOG" 2>/dev/null | tail -1)
    if [ -n "$FATAL_LINE" ]; then
      echo -e "${YELLOW}    라인: ${FATAL_LINE}, 명령: ${FATAL_CMD}${NC}"
      # [ ] && ... 패턴이면 자동 수정 시도
      local SRC_LINE
      SRC_LINE=$(sed -n "${FATAL_LINE}p" "${_RALPH_SCRIPT_DIR}/ralph.sh" 2>/dev/null)
      if echo "$SRC_LINE" | grep -qE '^\s*\[.*\] && ' 2>/dev/null; then
        echo -e "${GREEN}    → [ ] && 패턴 발견! if/then/fi로 자동 수정${NC}"
        # 원본 라인을 if/then/fi로 변환
        local INDENT CONDITION ACTION
        INDENT=$(echo "$SRC_LINE" | grep -oP '^\s*')
        CONDITION=$(echo "$SRC_LINE" | sed -E 's/^\s*(\[.*\]) && .*/\1/')
        ACTION=$(echo "$SRC_LINE" | sed -E 's/^\s*\[.*\] && (.*)/\1/' | sed 's/\\$//')
        # 다음 줄이 continuation이면 합치기
        local NEXT_LINE
        NEXT_LINE=$(sed -n "$((FATAL_LINE+1))p" "${_RALPH_SCRIPT_DIR}/ralph.sh" 2>/dev/null)
        if echo "$SRC_LINE" | grep -q '\\$'; then
          ACTION="${ACTION} ${NEXT_LINE}"
          sed -i "${FATAL_LINE}s|.*|${INDENT}if ${CONDITION}; then|" "${_RALPH_SCRIPT_DIR}/ralph.sh"
          sed -i "$((FATAL_LINE+1))s|.*|${INDENT}  ${ACTION}\n${INDENT}fi|" "${_RALPH_SCRIPT_DIR}/ralph.sh"
        else
          sed -i "${FATAL_LINE}s|.*|${INDENT}if ${CONDITION}; then ${ACTION}; fi|" "${_RALPH_SCRIPT_DIR}/ralph.sh"
        fi
        echo -e "${GREEN}    → ralph.sh:${FATAL_LINE} 자동 수정 완료${NC}"
        return 0
      fi
      echo -e "${YELLOW}    → 자동 수정 불가 — 수동 확인 필요 (ralph.sh:${FATAL_LINE})${NC}"
    fi
    return 1
  }
  _fix_noop() {
    echo -e "${RED}  [복구 불가] 수동 조치 필요${NC}"
    return 1
  }

  # ── 에러 분석 + 복구 ───────────────────────────────────────
  _analyze_and_fix() {
    local LOG="$1" WD="$2"
    local FOUND=0 FIXED=0

    echo -e "\n${CYAN}=== 에러 분석 ===${NC}"

    # 1) 패턴 DB 매칭
    if [ -n "$_PY3" ] && [ -f "$_ERROR_DB" ]; then
      local MATCHES
      MATCHES=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $_PY3 -X utf8 - "$LOG" "$_ERROR_DB" << 'MATCHEOF'
import json, re, sys
log_file, db_file = sys.argv[1], sys.argv[2]
with open(log_file,'r',encoding='utf-8',errors='replace') as f: log=f.read()
with open(db_file,'r',encoding='utf-8') as f: db=json.load(f)
from datetime import datetime
for section in ['builtin','learned']:
    for e in db.get(section,[]):
        try:
            hits = len(re.findall(e['pattern'], log, re.IGNORECASE))
        except: hits=0
        if hits > 0:
            e['seen_count'] = e.get('seen_count',0) + hits
            e['last_seen'] = datetime.now().isoformat()
            print(f"{e['id']}|{hits}|{e.get('fix','fix_noop')}|{e.get('severity','unknown')}")
db['_meta']['last_updated'] = datetime.now().isoformat()
with open(db_file,'w',encoding='utf-8') as f: json.dump(db,f,ensure_ascii=False,indent=2)
MATCHEOF
      ) || true

      while IFS='|' read -r eid count fix sev; do
        if [ -z "$eid" ]; then continue; fi
        FOUND=$((FOUND + 1))
        local SC="${YELLOW}"
        if [[ "$sev" == "fatal" || "$sev" == "critical" ]]; then SC="${RED}"; fi
        if [[ "$sev" == "unknown" ]]; then SC="${MAGENTA}"; fi
        echo -e "${SC}  ✗ [${eid}] ${count}건 (${sev})${NC}"

        # 복구 시도
        local fn="_${fix}"
        if type "$fn" &>/dev/null 2>&1; then
          if $fn "$WD" 2>/dev/null; then
            echo -e "${GREEN}    → 복구 성공${NC}"
            FIXED=$((FIXED + 1))
          else
            echo -e "${YELLOW}    → 복구 실패${NC}"
          fi
        fi
      done <<< "$MATCHES"
    fi

    # 2) [HEALTH] 태그 분석
    local H_OK=0 H_FAIL=0
    while IFS= read -r hline; do
      local clean step status
      clean=$(echo "$hline" | sed 's/\x1b\[[0-9;]*m//g')
      status=$(echo "$clean" | sed 's/\[HEALTH\] //' | cut -d'|' -f2 | xargs)
      step=$(echo "$clean" | sed 's/\[HEALTH\] //' | cut -d'|' -f1 | xargs)
      case "$status" in
        OK)   H_OK=$((H_OK + 1)) ;;
        FAIL) H_FAIL=$((H_FAIL + 1)); FOUND=$((FOUND + 1)) ;;
      esac
    done < <(grep "\[HEALTH\]" "$LOG" 2>/dev/null || true)
    if [ "$H_OK" -gt 0 ] || [ "$H_FAIL" -gt 0 ]; then
      echo -e "${CYAN}  프로세스: ${GREEN}${H_OK} OK${NC} / ${RED}${H_FAIL} FAIL${NC}"
    fi

    # 3) 미지 에러 학습
    if [ -n "$_PY3" ] && [ -f "$_ERROR_DB" ]; then
      local LEARNED
      LEARNED=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $_PY3 -X utf8 - "$LOG" "$_ERROR_DB" << 'LEARNEOF'
import json, re, sys
from collections import Counter
from datetime import datetime
log_file, db_file = sys.argv[1], sys.argv[2]
with open(log_file,'r',encoding='utf-8',errors='replace') as f: lines=f.readlines()
with open(db_file,'r',encoding='utf-8') as f: db=json.load(f)
existing=[e['pattern'] for s in ['builtin','learned'] for e in db.get(s,[])]
sigs=[r'(?i)(error|fatal|fail|exception|traceback|errno)',r'(?i)(✗|FAIL|ERROR)',r'exit (?:code )?[1-9]',r'(?i)no such file|not found|cannot|unable to']
errs=[]
for l in lines:
    c=re.sub(r'\x1b\[[0-9;]*m','',l.strip())
    if not c: continue
    for s in sigs:
        if re.search(s,c):
            matched=False
            for p in existing:
                try:
                    if re.search(p,c,re.IGNORECASE): matched=True; break
                except: continue
            if not matched: errs.append(c)
            break
groups=Counter()
examples={}
for e in errs:
    k=e[:50]; groups[k]+=1
    if k not in examples: examples[k]=e
count=0
for k,c in groups.most_common(10):
    if c<2: continue
    ex=examples[k]
    p=re.sub(r'/[a-zA-Z0-9_/\-.]+/','.+/',ex)
    p=re.sub(r'\b\d{2,}\b',r'\\d+',p)
    if len(p)<15: continue
    nid=f"learned_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{count}"
    db['learned'].append({"id":nid,"pattern":p,"description":f"자동학습: {ex[:80]}","fix":"fix_noop","severity":"unknown","seen_count":c,"first_seen":datetime.now().isoformat(),"example":ex[:200]})
    count+=1
    print(f"  + [{nid}] ({c}회) {ex[:60]}")
if count>0:
    db['_meta']['last_updated']=datetime.now().isoformat()
    with open(db_file,'w',encoding='utf-8') as f: json.dump(db,f,ensure_ascii=False,indent=2)
    print(f"  → {count}개 새 패턴 학습 완료")
LEARNEOF
      ) || true
      if [ -n "$LEARNED" ]; then echo -e "${MAGENTA}${LEARNED}${NC}"; fi
    fi

    echo -e "${CYAN}  감지: ${FOUND}개 / 복구: ${FIXED}개${NC}"
    return 0
  }

  # ── 결과 요약 ──────────────────────────────────────────────
  _summarize() {
    local WD="$1"
    if [ ! -d "$WD" ]; then return; fi
    echo -e "\n${CYAN}=== 결과 요약 ===${NC}"
    local kc rc pc mc
    kc=$(find "$WD" -path "*/knowledge/*.md" 2>/dev/null | wc -l)
    rc=$(find "$WD" -path "*/reports/*.md" 2>/dev/null | wc -l)
    pc=$(find "$WD" -name "*.pdf" 2>/dev/null | wc -l)
    mc=$(find "$WD" -path "*/sources_md/*.md" 2>/dev/null | wc -l)
    echo -e "  knowledge: ${GREEN}${kc// /}개${NC}  reports: ${GREEN}${rc// /}개${NC}  PDF: ${GREEN}${pc// /}개${NC}  PDF→MD: ${GREEN}${mc// /}개${NC}"
    if [ -f "$_ERROR_DB" ] && [ -n "$_PY3" ]; then
      local lc
      lc=$($_PY3 -c "import json;print(len(json.load(open('$_ERROR_DB'))['learned']))" 2>/dev/null) || lc="?"
      echo -e "  학습된 에러 패턴: ${MAGENTA}${lc}개${NC}"
    fi
  }

  # ═══════════════════════ 메인 루프 ═══════════════════════════

  # 주제 추출 (TOPIC_SLUG 계산용)
  _TOPIC=""
  for _a in "${_PASSTHROUGH_ARGS[@]}"; do
    if [[ "$_a" != --* ]] && [ -z "$_TOPIC" ]; then _TOPIC="$_a"; fi
  done
  _SLUG=$(echo "$_TOPIC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g;s/--*/-/g;s/^-//;s/-$//' | cut -c1-60)
  if [ -z "$_SLUG" ]; then _SLUG=$(echo -n "$_TOPIC" | md5sum | cut -c1-12); fi
  _WORK_DIR="${_RALPH_SCRIPT_DIR}/${_SLUG}"
  _RETRY_DELAY=15

  echo -e "${CYAN}══════════════════════════════════════${NC}"
  echo -e "${CYAN}   Ralph Knowledge Pipeline${NC}"
  echo -e "${CYAN}   (auto-recovery: ${GREEN}ON${CYAN}, max-retries: ${GREEN}${_MAX_RETRIES}${CYAN})${NC}"
  echo -e "${CYAN}══════════════════════════════════════${NC}"

  for ((_retry=0; _retry<=_MAX_RETRIES; _retry++)); do
    if [ "$_retry" -gt 0 ]; then
      echo -e "\n${YELLOW}=== 재시도 ${_retry}/${_MAX_RETRIES} (${_RETRY_DELAY}초 후) ===${NC}"
      sleep "$_RETRY_DELAY"
    fi

    _ATTEMPT_LOG="${_LOG_DIR}/attempt_${_retry}_$(date +%H%M%S).log"

    echo -e "${BLUE}▶ 실행 시작 (시도 $((_retry+1))/$((_MAX_RETRIES+1)))${NC}"

    _EXIT=0
    set +eo pipefail  # recovery 래퍼: 에러를 잡아서 분석해야 하므로 비활성화
    bash "$0" "${_PASSTHROUGH_ARGS[@]}" --_inner 2>&1 | tee "$_ATTEMPT_LOG"
    _EXIT=${PIPESTATUS[0]}  # bash(파이프 첫 번째)의 exit code
    set -eo pipefail

    if [ "$_EXIT" -eq 0 ]; then
      echo -e "\n${GREEN}✓ 정상 완료!${NC}"
      _summarize "$_WORK_DIR"
      exit 0
    fi

    echo -e "\n${RED}✗ 실패 (exit: ${_EXIT})${NC}"
    _analyze_and_fix "$_ATTEMPT_LOG" "$_WORK_DIR"

    if [ "$((_retry + 1))" -gt "$_MAX_RETRIES" ]; then
      echo -e "\n${RED}✗ 최대 재시도(${_MAX_RETRIES}) 초과${NC}"
      _summarize "$_WORK_DIR"
      exit 1
    fi
  done
  exit 1
fi

# ══════════════════════════════════════════════════════════════
# 여기서부터 실제 파이프라인 로직 (--_inner 모드)
# ══════════════════════════════════════════════════════════════

# --_inner 플래그 제거 (인자에서)
_CLEAN_ARGS=()
for _a in "$@"; do
  if [ "$_a" != "--_inner" ]; then _CLEAN_ARGS+=("$_a"); fi
done
set -- "${_CLEAN_ARGS[@]}"

# Python 자동 감지
source "$(dirname "$0")/detect-python.sh" || exit 1

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
MAGENTA='\033[0;35m'

# ── 프로세스 헬스체크 시스템 ────────────────────────────────────
# 형식: [HEALTH] step_name | status | message
health_check() {
  local STEP="$1" STATUS="$2" MESSAGE="$3"
  echo -e "${MAGENTA}[HEALTH] ${STEP} | ${STATUS} | ${MESSAGE}${NC}"
  if [ "$STATUS" = "FAIL" ]; then
    echo -e "${MAGENTA}[HEALTH-DIAG] ${STEP} | cwd=$(pwd) | pid=$$ | $(date -Iseconds)${NC}"
  fi
}

# 단계별 복구 시도 (파이프라인 내부에서 즉시 복구)
try_self_heal() {
  local STEP="$1" ERROR_MSG="$2" WORK_DIR="${3:-.}"
  case "$STEP" in
    phase2-batch)
      if echo "$ERROR_MSG" | grep -q "No such file or directory"; then
        local MISSING_DIR
        MISSING_DIR=$(echo "$ERROR_MSG" | grep -oP "cd: \K[^ ]+")
        if [ -n "$MISSING_DIR" ]; then
          mkdir -p "$MISSING_DIR" 2>/dev/null && {
            health_check "$STEP" "RETRY" "디렉토리 생성 후 재시도: $MISSING_DIR"
            return 0
          }
        fi
      fi ;;
    research-engine)
      if echo "$ERROR_MSG" | grep -qiE "429|rate.?limit|overloaded"; then
        health_check "$STEP" "RETRY" "API rate limit — 60초 대기"
        sleep 60; return 0
      fi ;;
    fetch-sources)
      if echo "$ERROR_MSG" | grep -qiE "timeout|connection|ECONNREFUSED"; then
        health_check "$STEP" "RETRY" "네트워크 에러 — 30초 대기"
        sleep 30; return 0
      fi ;;
    marker)
      health_check "$STEP" "WARN" "PDF→MD 변환 실패 — JSON 기반 진행"
      return 1 ;;
  esac
  return 1
}

# ── 모델 설정 ─────────────────────────────────────────────────
# 작업 복잡도별 모델 배정 (토큰 비용 최적화)
#   HEAVY: 종합 리서치, 문서 생성, UPDATE — 고품질 필요
#   LIGHT: MECE 분할, 연관성 검증, 웹검색, ping — 구조화된 간단 작업
MODEL_HEAVY="sonnet"    # 메인 루프, UPDATE
MODEL_LIGHT="sonnet"    # split-topic, relevance, websearch, ping

# ── 인자 파싱 ────────────────────────────────────────────────
TOPIC=""
URL=""
MAX_ITERATIONS=10
RUN_ONLY=false
UPDATE_MODE=false
NO_SPLIT=false
PARALLEL=5

while [[ $# -gt 0 ]]; do
  case $1 in
    --iterations) MAX_ITERATIONS="$2"; shift 2 ;;
    --run)        RUN_ONLY=true; MAX_ITERATIONS="$2"; shift 2 ;;
    --update)     UPDATE_MODE=true; shift ;;
    --email)      UNPAYWALL_EMAIL="$2"; export UNPAYWALL_EMAIL; shift 2 ;;
    --no-split)   NO_SPLIT=true; shift ;;
    --parallel)   PARALLEL="$2"; if [ "$PARALLEL" -gt 5 ]; then PARALLEL=5; fi; shift 2 ;;
    --model-heavy) MODEL_HEAVY="$2"; shift 2 ;;
    --model-light) MODEL_LIGHT="$2"; shift 2 ;;
    --max-retries) shift 2 ;;  # recovery 래퍼에서 처리됨
    --no-recovery) shift ;;    # recovery 래퍼에서 처리됨
    --_inner)      shift ;;    # 내부 플래그
    --*)          echo -e "${RED}알 수 없는 옵션: $1${NC}"; exit 1 ;;
    *)
      if   [ -z "$TOPIC" ]; then TOPIC="$1"
      elif [ -z "$URL"   ]; then URL="$1"
      fi
      shift ;;
  esac
done

# 모델 변수 export (fetch-sources.sh 등 자식 프로세스에서 사용)
export MODEL_HEAVY MODEL_LIGHT

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
  echo "  ./ralph.sh \"semiconductor\" --parallel 5    # MECE 분할 후 최대 5개 병렬"
  echo "  ./ralph.sh \"semiconductor\" --no-split      # 분할 없이 단일 주제로 실행"
  echo "  ./ralph.sh \"topic\" --model-heavy opus      # 메인 루프 모델 변경 (기본: sonnet)"
  echo "  ./ralph.sh \"topic\" --model-light sonnet    # 보조 작업 모델 변경 (기본: haiku)"
  echo ""
  exit 0
fi

# ── 필수 파일 체크 ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="${SCRIPT_DIR}/prompts"

if [ ! -f "${PROMPTS_DIR}/PROMPT.md" ]; then
  echo -e "${RED}Error: prompts/PROMPT.md not found${NC}"; exit 1
fi

# ── 주제별 디렉토리 격리 ─────────────────────────────────────
# --no-split(서브토픽)이나 --run(queue 이어서)이 아닌 경우,
# 주제 slug로 작업 디렉토리를 만들어서 격리
if [ -n "$TOPIC" ] && [ "$NO_SPLIT" = false ] && [ "$RUN_ONLY" = false ]; then
  TOPIC_SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | \
               sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
               sed 's/^-//' | sed 's/-$//' | cut -c1-60)
  # 한글 등 비ASCII만 있으면 slug가 빈 문자열 → MD5 폴백
  if [ -z "$TOPIC_SLUG" ]; then
    TOPIC_SLUG=$(echo -n "$TOPIC" | md5sum | cut -c1-12)
  fi
  TOPIC_DIR="${SCRIPT_DIR}/${TOPIC_SLUG}"
  mkdir -p "$TOPIC_DIR"
  cd "$TOPIC_DIR"
  echo -e "${CYAN}작업 디렉토리: ${TOPIC_DIR}${NC}"
  echo ""
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

# ── 파이프라인 리포트 시스템 ──────────────────────────────────
REPORT_FILE="pipeline-report.txt"

init_report() {
  cat > "$REPORT_FILE" << REOF
=== Pipeline Report ===
시작: $(date '+%Y-%m-%d %H:%M:%S')
주제: ${TOPIC:-"--run 모드"}
모드: ${UPDATE_MODE:+UPDATE}${RUN_ONLY:+RUN}

REOF
}

# 기능별 성공/실패 기록
report_step() {
  local STEP="$1"
  local STATUS="$2"  # OK / FAIL / SKIP / WARN
  local DETAIL="$3"
  local ICON=""
  case "$STATUS" in
    OK)   ICON="✅" ;;
    FAIL) ICON="❌" ;;
    SKIP) ICON="⏭️" ;;
    WARN) ICON="⚠️" ;;
  esac
  echo "[$ICON $STATUS] $STEP — $DETAIL" >> "$REPORT_FILE"
  # FAIL이면 터미널에도 즉시 출력
  if [ "$STATUS" = "FAIL" ]; then
    echo -e "${RED}[$STATUS] $STEP — $DETAIL${NC}"
  fi
}

# 최종 리포트 출력
print_report() {
  echo "" >> "$REPORT_FILE"
  echo "종료: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"

  # docs/ 파일 수 카운트
  local K_COUNT R_COUNT S_COUNT PDF_COUNT INAC_COUNT
  K_COUNT=$(find docs/knowledge -name "*.md" 2>/dev/null | wc -l)
  R_COUNT=$(find docs/reports -name "*.md" 2>/dev/null | wc -l)
  S_COUNT=$(find docs/sources -name "*.pdf" 2>/dev/null | wc -l)
  PDF_COUNT=${S_COUNT// /}
  INAC_COUNT=$(grep -c "^제목:" inaccessible-papers.txt 2>/dev/null || true)
  INAC_COUNT=${INAC_COUNT:-0}
  INAC_COUNT=${INAC_COUNT// /}

  {
    echo ""
    echo "=== 결과 요약 ==="
    echo "knowledge 문서: ${K_COUNT}개"
    echo "report 문서:    ${R_COUNT}개"
    echo "다운로드 PDF:   ${PDF_COUNT}개"
    echo "접근 불가 논문: ${INAC_COUNT}개"
  } >> "$REPORT_FILE"

  echo ""
  echo -e "${CYAN}=== 파이프라인 리포트 ===${NC}"
  cat "$REPORT_FILE"
  echo -e "${CYAN}=========================${NC}"
  echo ""
}

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
docs/sources/*.pdf
GIEOF
    fi
    git add -A
    git commit -q -m "init: research-loop pipeline setup"
    echo -e "${GREEN}✓ Git 저장소 생성 완료${NC}"
    echo ""
  fi
}

# Git 커밋 (변경사항 있을 때만, --no-split 서브토픽에서는 스킵)
git_commit() {
  if [ "$NO_SPLIT" = true ]; then return 0; fi
  local MSG="$1"
  if [ -d ".git" ]; then
    git add -A 2>/dev/null || true
    if ! git diff --cached --quiet 2>/dev/null; then
      git commit -q -m "$MSG" 2>/dev/null || true
    fi
  fi
}

# Git 푸시 (remote 있을 때만, --no-split 서브토픽에서는 스킵)
git_push() {
  if [ "$NO_SPLIT" = true ]; then return 0; fi
  if [ -d ".git" ] && git remote get-url origin &>/dev/null; then
    git push -q 2>/dev/null || true
  fi
}

# ── 인덱스 생성 — 리서치 완료 후 구조 파악용 ────────────────────
generate_index() {
  local INDEX_FILE="INDEX.md"
  echo -e "${CYAN}=== 인덱스 생성 ===${NC}"

  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 << 'IDXEOF'
import os, json, glob, re
from datetime import datetime

lines = []
lines.append("# Research Index")
lines.append("")
lines.append(f"생성 시각: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
lines.append("")

# 주제 정보
if os.path.exists("subtopics.json"):
    with open("subtopics.json", "r", encoding="utf-8") as f:
        st = json.load(f)
    root = st.get("root", "")
    leaves = st.get("leaves", [])
    tree = st.get("tree", {})
    lines.append(f"## 주제: {root}")
    lines.append("")
    lines.append(f"서브토픽 {len(leaves)}개")
    lines.append("")

    # 트리 구조
    lines.append("### 토픽 트리")
    lines.append("```")
    def print_tree(topic, depth=0):
        indent = "  " * depth
        children = tree.get(topic, [])
        if children:
            lines.append(f"{indent}📂 {topic}")
            for c in children:
                print_tree(c, depth + 1)
        else:
            lines.append(f"{indent}📄 {topic}")
    print_tree(root)
    lines.append("```")
    lines.append("")

# knowledge 문서 목록
lines.append("## Knowledge 문서")
lines.append("")
k_files = sorted(glob.glob("docs/knowledge/*.md"))
if k_files:
    for kf in k_files:
        name = os.path.basename(kf)
        # 파일 첫 줄에서 제목 추출
        title = name
        try:
            with open(kf, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("# "):
                        title = line[2:]
                        break
        except:
            pass
        size_kb = os.path.getsize(kf) / 1024
        lines.append(f"- [{title}](docs/knowledge/{name}) ({size_kb:.0f}KB)")
    lines.append("")
else:
    lines.append("(없음)")
    lines.append("")

# report 문서 목록
lines.append("## Reports")
lines.append("")
r_files = sorted(glob.glob("docs/reports/*.md"))
if r_files:
    for rf in r_files:
        name = os.path.basename(rf)
        title = name
        try:
            with open(rf, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("# "):
                        title = line[2:]
                        break
        except:
            pass
        size_kb = os.path.getsize(rf) / 1024
        lines.append(f"- [{title}](docs/reports/{name}) ({size_kb:.0f}KB)")
    lines.append("")
else:
    lines.append("(없음)")
    lines.append("")

# 논문 통계
lines.append("## 논문 데이터")
lines.append("")
json_files = glob.glob("docs/research/*.json")
total_papers = 0
paper_titles = []
for jf in sorted(json_files):
    try:
        with open(jf, "r", encoding="utf-8") as f:
            data = json.load(f)
        papers = data.get("papers", [])
        total_papers += len(papers)
        fname = os.path.basename(jf)
        lines.append(f"- `{fname}` — {len(papers)}편")
        for p in papers[:5]:
            t = p.get("title", "N/A")
            paper_titles.append(t)
    except:
        continue
lines.append(f"\n총 **{total_papers}편** 논문 수집")
lines.append("")

# PDF/MD 현황
pdf_count = len(glob.glob("docs/sources/*.pdf"))
md_count = len(glob.glob("docs/sources_md/*.md"))
lines.append("## PDF / Markdown")
lines.append("")
lines.append(f"- PDF 다운로드: {pdf_count}개")
lines.append(f"- PDF→MD 변환: {md_count}개")
lines.append("")

if pdf_count > 0:
    lines.append("| 파일 | 크기 | MD 변환 |")
    lines.append("|------|------|---------|")
    for pdf in sorted(glob.glob("docs/sources/*.pdf")):
        name = os.path.basename(pdf)
        slug = name.replace(".pdf", "")
        size_mb = os.path.getsize(pdf) / (1024*1024)
        has_md = "✓" if os.path.exists(f"docs/sources_md/{slug}.md") else "✗"
        lines.append(f"| {name[:60]} | {size_mb:.1f}MB | {has_md} |")
    lines.append("")

# 파일 구조
lines.append("## 파일 구조")
lines.append("```")
for root_dir, dirs, files in os.walk("docs"):
    # subtopics 내부는 스킵
    level = root_dir.replace("docs", "").count(os.sep)
    indent = "  " * level
    lines.append(f"{indent}📁 {os.path.basename(root_dir)}/")
    sub_indent = "  " * (level + 1)
    for f in sorted(files)[:20]:
        lines.append(f"{sub_indent}📄 {f}")
    if len(files) > 20:
        lines.append(f"{sub_indent}... (+{len(files)-20}개)")
lines.append("```")

with open("INDEX.md", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print(f"INDEX.md 생성 완료 ({len(k_files)} knowledge, {len(r_files)} reports, {total_papers} papers)")
IDXEOF

  if [ -f "$INDEX_FILE" ]; then
    echo -e "${GREEN}  ✓ INDEX.md 생성 완료${NC}"
    health_check "index" "OK" "INDEX.md 생성"
  else
    echo -e "${YELLOW}  ⚠ INDEX.md 생성 실패${NC}"
  fi
}

# --no-split (서브토픽 독립 실행)이면 git 비활성화
if [ "$NO_SPLIT" = false ]; then
  init_git
fi

# ── queue.md 조작 (queue-util.py 사용) ────────────────────────
QUEUE_UTIL="$(dirname "$0")/queue-util.py"

add_to_queue() {
  local TITLE="$1"
  local TARGET_URL="${2:-null}"
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 "$QUEUE_UTIL" add "$TITLE" "$TARGET_URL" 1 || true
}

# ── fetch-signal.txt 감지 ────────────────────────────────────
# PROMPT Step 3에서 Claude가 fetch-signal.txt를 생성하면
# ralph.sh가 감지해서 fetch-sources.sh 실행 후 신호 파일 삭제
has_fetch_signal() {
  if [ -f "fetch-signal.txt" ] && grep -q "FETCH_NEEDED=true" fetch-signal.txt 2>/dev/null; then
    return 0
  fi
  return 1
}

run_fetch() {
  echo -e "${CYAN}=== PDF 다운로드 시작 ===${NC}"
  if [ -f "${SCRIPT_DIR}/fetch-sources.sh" ]; then
    if [ -n "$UNPAYWALL_EMAIL" ]; then
      bash "${SCRIPT_DIR}/fetch-sources.sh" --email "$UNPAYWALL_EMAIL" || true
    else
      bash "${SCRIPT_DIR}/fetch-sources.sh" || true
    fi
  else
    echo -e "${YELLOW}fetch-sources.sh 없음 — 다운로드 건너뜀${NC}"
  fi
  # 신호 파일 삭제 (다운로드 완료 표시)
  rm -f fetch-signal.txt
  echo -e "${CYAN}=== PDF 다운로드 완료 ===${NC}"
  echo ""
  # PDF → Markdown 변환
  convert_pdfs_to_md
}

# ── PDF → Markdown 변환 (marker-pdf, GPU) ───────────────────
MARKER_PYTHON="/c/Users/kbg52/marker-env/Scripts/python.exe"
MARKER_SINGLE="/c/Users/kbg52/marker-env/Scripts/marker_single.exe"

convert_pdfs_to_md() {
  if [ ! -f "$MARKER_SINGLE" ]; then
    echo -e "${YELLOW}⚠ marker 미설치 — PDF→MD 변환 스킵${NC}"
    return
  fi
  if [ ! -d "docs/sources" ]; then return; fi

  local count=0
  local total
  total=$(find "docs/sources" -name "*.pdf" 2>/dev/null | wc -l)
  total=${total// /}
  if [ "$total" -eq 0 ]; then return; fi

  mkdir -p "docs/sources_md"
  echo -e "${CYAN}=== PDF → Markdown 변환 (marker, GPU) ===${NC}"

  for pdf in docs/sources/*.pdf; do
    [ -f "$pdf" ] || continue
    local basename
    basename=$(basename "$pdf" .pdf)
    # 이미 변환된 파일 스킵
    if [ -f "docs/sources_md/${basename}.md" ]; then
      count=$((count + 1))
      continue
    fi
    count=$((count + 1))
    # 10MB 초과 PDF는 marker 스킵 (GPU 메모리/시간 문제)
    local filesize
    filesize=$(wc -c < "$pdf" 2>/dev/null || echo 0)
    if [ "$filesize" -gt 10485760 ]; then
      echo -e "  ${YELLOW}⏭ 스킵 (${filesize} bytes > 10MB): ${basename}${NC}"
      continue
    fi
    echo -e "  ${BLUE}▶ [${count}/${total}] ${basename}${NC}"
    # 짧은 임시 디렉토리명 사용 (Windows 260자 경로 제한 방지)
    local tmpdir="docs/sources_md/_t${count}"
    timeout 600 "$MARKER_SINGLE" "$pdf" --output_dir "$tmpdir" 2>>"docs/sources_md/marker_errors.log" || {
      echo -e "  ${YELLOW}✗ 변환 실패 (타임아웃 또는 에러): ${basename}${NC}"
      rm -rf "$tmpdir"
      continue
    }
    # marker 출력 폴더에서 .md 파일을 sources_md/로 이동
    local md_file
    md_file=$(find "$tmpdir" -name "*.md" -type f 2>/dev/null | head -1)
    if [ -n "$md_file" ]; then
      mv "$md_file" "docs/sources_md/${basename}.md"
      echo -e "  ${GREEN}✓ ${basename}.md$(wc -c < "docs/sources_md/${basename}.md" | awk '{printf " (%dKB)", $1/1024}')${NC}"
    fi
    rm -rf "$tmpdir"
  done

  local md_count
  md_count=$(find "docs/sources_md" -name "*.md" 2>/dev/null | wc -l)
  md_count=${md_count// /}
  echo -e "${GREEN}=== 변환 완료: ${md_count}개 Markdown ===${NC}"
  echo ""
}

get_current_item_info() {
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 "$QUEUE_UTIL" get-item-info || true
}

get_current_pdf() {
  # docs/sources/에서 가장 최근 다운로드된 PDF 경로 반환
  if [ -d "docs/sources" ]; then
    find "docs/sources" -name "*.pdf" -printf '%T@ %p\n' 2>/dev/null | \
      sort -rn | head -1 | cut -d' ' -f2-
  fi
}

# ── 헤더 출력 ────────────────────────────────────────────────
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Ralph Knowledge Pipeline${NC}"
echo -e "${BLUE}======================================${NC}"
echo -e "  모델: heavy=${GREEN}${MODEL_HEAVY}${NC} / light=${GREEN}${MODEL_LIGHT}${NC}"

init_report
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
  RESEARCH_RESULT=$(bash "${SCRIPT_DIR}/research-engine.sh" "$TOPIC" --max-results 20 --depth 1 --hops 2 2>&1) || true
  echo "$RESEARCH_RESULT"
  if echo "$RESEARCH_RESULT" | grep -q "RESEARCH_COMPLETE"; then
    FOUND=$(echo "$RESEARCH_RESULT" | grep "^PAPERS_FOUND=" | cut -d= -f2)
    report_step "research-engine" "OK" "${FOUND}개 논문 발견"
    health_check "research-engine" "OK" "${FOUND}개 논문"
  else
    report_step "research-engine" "FAIL" "탐색 실패 또는 결과 없음"
    health_check "research-engine" "FAIL" "탐색 실패"
    # self-heal 시도
    if try_self_heal "research-engine" "$RESEARCH_RESULT"; then
      RESEARCH_RESULT=$(bash "${SCRIPT_DIR}/research-engine.sh" "$TOPIC" --max-results 20 --depth 1 --hops 2 2>&1) || true
      echo "$RESEARCH_RESULT"
    fi
  fi
  echo ""

  # 1.5. PDF 다운로드
  if [ -f "${SCRIPT_DIR}/fetch-sources.sh" ]; then
    echo -e "${CYAN}=== PDF 다운로드 ===${NC}"
    FETCH_EXIT=0
    bash "${SCRIPT_DIR}/fetch-sources.sh" || FETCH_EXIT=$?
    DL_COUNT=$(find docs/sources -name "*.pdf" 2>/dev/null | wc -l)
    DL_COUNT=${DL_COUNT// /}
    if [ "$DL_COUNT" -gt 0 ] 2>/dev/null; then
      report_step "fetch-sources" "OK" "PDF ${DL_COUNT}개 다운로드"
      health_check "fetch-sources" "OK" "PDF ${DL_COUNT}개"
    else
      report_step "fetch-sources" "WARN" "PDF 0개 — 초록 기반 진행"
      _FS_STATUS="WARN"; if [ "$FETCH_EXIT" -ne 0 ]; then _FS_STATUS="FAIL"; fi
      health_check "fetch-sources" "$_FS_STATUS" "PDF 0개 (exit=$FETCH_EXIT)"
    fi
    echo ""
  fi

  # 2. Claude에게 update 지시
  UPDATE_PROMPT="$(cat << UEOF
너는 기존 지식 문서를 최신 정보로 업데이트하는 에이전트야.

## 작업
1. docs/knowledge/${UPDATE_SLUG}.md 와 docs/reports/${UPDATE_SLUG}_report.md 를 읽어.
2. docs/research/${UPDATE_SLUG}.json 을 읽어서 기존 문서에 반영 안 된 최신 논문을 파악해.
3. 웹 검색으로 최신 동향(2025-2026)도 추가 조사해.
4. prompts/update.md 의 병합 정책에 따라 기존 문서를 최신화해.
5. prompts/verify-knowledge.md 로 검증하고 결과를 출력해.
6. prompts/verify-report.md 로 검증하고 결과를 출력해.
7. queue.md에서 source_of: "${UPDATE_SLUG}" 인 pending 항목이 있으면 모두 status: done으로 변경해 (종합 문서에 반영됐으므로).

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

  # 소스 수집 (MD 우선, PDF 폴백) — 배열 방식
  UPDATE_FILE_ARGS=()
  UPDATE_PDF_COUNT=0
  if [ -d "docs/sources_md" ]; then
    while IFS= read -r -d '' f; do
      if [ "$UPDATE_PDF_COUNT" -lt 5 ]; then
        UPDATE_FILE_ARGS+=(--file "$f")
        UPDATE_PDF_COUNT=$((UPDATE_PDF_COUNT + 1))
      fi
    done < <(find "docs/sources_md" -name "*.md" -print0 2>/dev/null)
  fi
  if [ "$UPDATE_PDF_COUNT" -eq 0 ] && [ -d "docs/sources" ]; then
    while IFS= read -r -d '' f; do
      if [ "$UPDATE_PDF_COUNT" -lt 5 ]; then
        UPDATE_FILE_ARGS+=(--file "$f")
        UPDATE_PDF_COUNT=$((UPDATE_PDF_COUNT + 1))
      fi
    done < <(find "docs/sources" -name "*.pdf" -print0 2>/dev/null)
  fi

  if [ "$UPDATE_PDF_COUNT" -gt 0 ]; then
    echo -e "${GREEN}📄 소스 ${UPDATE_PDF_COUNT}개 첨부${NC}"
  fi
  result=$(claude -p "$UPDATE_PROMPT" \
    "${UPDATE_FILE_ARGS[@]}" \
    --model "$MODEL_HEAVY" \
    --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
    --output-format text 2>&1) || true

  echo "$result"
  echo ""

  if echo "$result" | grep -q "업데이트 완료"; then
    report_step "claude-update" "OK" "문서 업데이트 완료"
  else
    report_step "claude-update" "WARN" "업데이트 결과 불명확"
  fi

  git_commit "update: ${UPDATE_SLUG} 최신화 완료"
  git_push
  report_step "git" "OK" "커밋 & 푸시"

  print_report
  exit 0
fi

# ── 새 주제 queue에 추가 ─────────────────────────────────────
if [ -n "$TOPIC" ]; then
  echo -e "주제: ${GREEN}$TOPIC${NC}"
  if [ -n "$URL" ]; then echo -e "URL:  ${GREEN}$URL${NC}"; fi
  echo ""

  RESULT=$(add_to_queue "$TOPIC" "$URL") || RESULT="ERROR"

  case "$RESULT" in
    DUPLICATE) echo -e "${YELLOW}⚠️  이미 queue에 있는 주제입니다. 기존 항목으로 진행합니다.${NC}" ;;
    ADDED)     echo -e "${GREEN}✓ queue에 추가됨: \"$TOPIC\"${NC}" ;;
    *)         echo -e "${YELLOW}⚠️  queue 추가 중 오류. 계속 진행합니다.${NC}" ;;
  esac
  echo ""
fi

# ── 학술 논문 탐색 + PDF 다운로드 (분할 전 실행) ─────────────────
if [ -n "$TOPIC" ] && [ "$NO_SPLIT" = false ] && [ -f "${SCRIPT_DIR}/research-engine.sh" ]; then
  echo -e "${CYAN}=== 학술 논문 탐색 시작 ===${NC}"
  echo ""
  # (리프별 research-engine은 Phase 1.5에서 실행 — 분할 전 넓은 주제 탐색 제거)
  echo -e "${YELLOW}MECE 분할 후 리프별 탐색으로 전환됨 — 넓은 주제 선행 탐색 스킵${NC}"
  echo ""
fi

# ── MECE 주제 분할 + 병렬 실행 ─────────────────────────────────
if [ -n "$TOPIC" ] && [ "$NO_SPLIT" = false ] && [ "$RUN_ONLY" = false ]; then
  echo -e "${CYAN}=== MECE 주제 분할 ===${NC}"
  echo ""

  SUBTOPICS_JSON="subtopics.json"

  # Phase 1: 재귀 분할 (트리 생성)
  # subtopics.json 초기화
  cat > "$SUBTOPICS_JSON" << 'SJEOF'
{
  "root": "",
  "tree": {},
  "leaves": []
}
SJEOF

  # 재귀 분할 함수
  split_topic_recursive() {
    local CURRENT_TOPIC="$1"
    local DEPTH="$2"
    local PARENT_PATH="$3"  # 폴더 경로 (예: subtopics/semiconductor/fabrication)

    # 깊이 상한 체크
    if [ "$DEPTH" -ge 2 ]; then
      echo -e "${YELLOW}  깊이 상한(2) 도달: \"$CURRENT_TOPIC\" → 리프 노드${NC}"
      # 리프 노드로 등록
      PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" "$CURRENT_TOPIC" "$PARENT_PATH" << 'LEAFEOF'
import json, sys
jf, topic, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(jf, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['leaves'].append({"topic": topic, "path": path})
with open(jf, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
LEAFEOF
      return
    fi

    # Claude에게 분할 요청
    local SPLIT_PROMPT
    SPLIT_PROMPT=$(sed "s|{{TOPIC}}|${CURRENT_TOPIC}|g" "${PROMPTS_DIR}/split-topic.md")
    local SPLIT_RESULT
    SPLIT_RESULT=$(claude -p "$SPLIT_PROMPT" --model "$MODEL_LIGHT" --output-format text 2>&1) || true

    # JSON 배열 파싱
    local SUBTOPICS
    SUBTOPICS=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SPLIT_RESULT" 2>/dev/null << 'PARSEEOF'
import json, sys, re
raw = sys.argv[1]
# JSON 배열 추출 (```json ... ``` 또는 순수 배열)
m = re.search(r'\[.*?\]', raw, re.DOTALL)
if m:
    arr = json.loads(m.group())
    if isinstance(arr, list):
        for item in arr:
            print(item)
    else:
        print("PARSE_ERROR")
else:
    print("PARSE_ERROR")
PARSEEOF
    ) || SUBTOPICS="PARSE_ERROR"

    # 파싱 실패 → 분할 스킵
    if [ "$SUBTOPICS" = "PARSE_ERROR" ] || [ -z "$SUBTOPICS" ]; then
      echo -e "${YELLOW}  분할 스킵 (파싱 실패 또는 빈 응답): \"$CURRENT_TOPIC\"${NC}"
      # 리프 노드로 등록
      PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" "$CURRENT_TOPIC" "$PARENT_PATH" << 'LEAFEOF2'
import json, sys
jf, topic, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(jf, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['leaves'].append({"topic": topic, "path": path})
with open(jf, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
LEAFEOF2
      return
    fi

    # 빈 배열 (구체적 주제) → 리프 노드
    local LINE_COUNT
    LINE_COUNT=$(echo "$SUBTOPICS" | grep -c "." || true)
    if [ "$LINE_COUNT" -eq 0 ]; then
      echo -e "${GREEN}  구체적 주제 → 리프 노드: \"$CURRENT_TOPIC\"${NC}"
      PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" "$CURRENT_TOPIC" "$PARENT_PATH" << 'LEAFEOF3'
import json, sys
jf, topic, path = sys.argv[1], sys.argv[2], sys.argv[3]
with open(jf, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['leaves'].append({"topic": topic, "path": path})
with open(jf, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
LEAFEOF3
      return
    fi

    # 서브토픽 있음 → 트리에 등록 + 폴더 생성 + 재귀
    echo -e "${GREEN}  \"$CURRENT_TOPIC\" → ${LINE_COUNT}개 서브토픽 분할${NC}"

    # 트리에 등록
    PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" "$CURRENT_TOPIC" "$SUBTOPICS" << 'TREEEOF'
import json, sys
jf, topic = sys.argv[1], sys.argv[2]
subs = sys.argv[3].strip().split('\n')
with open(jf, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['tree'][topic] = [s.strip() for s in subs if s.strip()]
with open(jf, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
TREEEOF

    # 각 서브토픽에 대해 재귀 분할
    # fd3으로 읽어서 내부 heredoc의 stdin 소비 방지
    while IFS= read -r sub <&3; do
      sub="$(echo "$sub" | tr -d '\r')"
      [ -z "$sub" ] && continue
      # slug 생성
      local SUB_SLUG
      SUB_SLUG=$(echo "$sub" | tr '[:upper:]' '[:lower:]' | \
                 sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
                 sed 's/^-//' | sed 's/-$//' | cut -c1-60)
      # Git Bash 경로 변환 방지: 선행 / 없이 상대경로 유지
      if [ -z "$PARENT_PATH" ]; then
        local SUB_PATH="${SUB_SLUG}"
      else
        local SUB_PATH="${PARENT_PATH}/${SUB_SLUG}"
      fi
      mkdir -p "subtopics/${SUB_PATH}"
      echo -e "  $( printf '%*s' $((DEPTH * 2)) '' )├── $sub"
      split_topic_recursive "$sub" $((DEPTH + 1)) "$SUB_PATH"
    done 3<<< "$SUBTOPICS"
  }

  # 루트 주제의 slug
  ROOT_SLUG=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]' | \
              sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | \
              sed 's/^-//' | sed 's/-$//' | cut -c1-60)

  # subtopics.json 루트 설정
  PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" "$TOPIC" << 'ROOTEOF'
import json, sys
jf, topic = sys.argv[1], sys.argv[2]
with open(jf, 'r', encoding='utf-8') as f:
    data = json.load(f)
data['root'] = topic
with open(jf, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
ROOTEOF

  # 재귀 분할 시작
  split_topic_recursive "$TOPIC" 0 ""

  # 리프 노드 개수 확인
  LEAF_COUNT=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 -c "
import json
with open('$SUBTOPICS_JSON', 'r', encoding='utf-8') as f:
    data = json.load(f)
print(len(data['leaves']))
" 2>/dev/null) || LEAF_COUNT=0

  echo ""

  if [ "$LEAF_COUNT" -le 1 ]; then
    # 분할 없음 또는 단일 리프 → 기존 흐름 유지
    echo -e "${GREEN}✓ 분할 불필요 — 단일 주제로 진행${NC}"
    report_step "mece-split" "SKIP" "구체적 주제, 분할 없음"
    echo ""
  else
    # Phase 2: 리프 노드 병렬 실행
    echo -e "${CYAN}=== 서브토픽 병렬 실행 (${LEAF_COUNT}개 리프, ${PARALLEL}개 동시) ===${NC}"
    echo ""
    report_step "mece-split" "OK" "${LEAF_COUNT}개 리프 노드 생성"

    # 리프 노드 목록 추출
    LEAF_LIST=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" << 'LLEOF'
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    data = json.load(f)
for leaf in data['leaves']:
    print(leaf['topic'] + '|||' + leaf['path'])
LLEOF
    )

    # 디버그: 리프 목록 확인
    LEAF_LINE_COUNT=$(echo "$LEAF_LIST" | wc -l)
    echo -e "${YELLOW}  [DEBUG] LEAF_LIST: ${LEAF_LINE_COUNT}줄${NC}"
    echo "$LEAF_LIST" | head -10 | while IFS= read -r dbg; do echo "    $dbg"; done

    # ── Phase 1.5: 리프별 논문 탐색 + Claude 연관성 검증 + 일괄 PDF 다운로드 ──
    echo ""
    echo -e "${CYAN}=== Phase 1.5: 리프별 논문 탐색 + 연관성 검증 ===${NC}"
    echo ""

    # A. 각 리프 토픽별 research-engine 실행 (순차)
    LEAF_RE_OK=0
    LEAF_RE_FAIL=0
    while IFS= read -r leaf_line <&6; do
      [ -z "$leaf_line" ] && continue
      LEAF_TOPIC="${leaf_line%%|||*}"
      echo -e "${BLUE}  ▶ research-engine: \"$LEAF_TOPIC\"${NC}"
      RE_OUT=$(bash "${SCRIPT_DIR}/research-engine.sh" "$LEAF_TOPIC" --max-results 10 --depth 1 2>&1) || true
      if echo "$RE_OUT" | grep -q "RESEARCH_COMPLETE"; then
        RE_FOUND=$(echo "$RE_OUT" | grep "^PAPERS_FOUND=" | cut -d= -f2)
        echo -e "${GREEN}    ✓ ${RE_FOUND}개 논문 발견${NC}"
        LEAF_RE_OK=$((LEAF_RE_OK + 1))
      else
        echo -e "${YELLOW}    ✗ 탐색 실패 또는 결과 없음${NC}"
        LEAF_RE_FAIL=$((LEAF_RE_FAIL + 1))
      fi
    done 6<<< "$LEAF_LIST"
    report_step "phase1.5-research" "OK" "${LEAF_RE_OK}개 성공, ${LEAF_RE_FAIL}개 실패"
    echo ""

    # B. Claude 연관성 검증 — research JSON 파일별 배치 검증
    echo -e "${CYAN}  Claude 연관성 검증 시작 (파일별 배치)...${NC}"

    # 리프 토픽 목록 추출
    LEAF_TOPICS_STR=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 -c "
import json
with open('$SUBTOPICS_JSON','r',encoding='utf-8') as f: data=json.load(f)
print(', '.join(l['topic'] for l in data['leaves']))
" 2>/dev/null) || LEAF_TOPICS_STR="$TOPIC"

    # research JSON 파일 목록
    RESEARCH_FILES=$(find docs/research -name "*.json" 2>/dev/null | sort)
    TOTAL_REMOVED=0
    BATCH_OK=0
    BATCH_FAIL=0
    BATCH_TOTAL=0

    for RJSON in $RESEARCH_FILES; do
      BATCH_TOTAL=$((BATCH_TOTAL + 1))
      RJSON_NAME=$(basename "$RJSON")

      # 논문 요약 추출 (파일 1개만)
      BATCH_SUMMARY=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$RJSON" << 'BSEOF'
import json, sys, os
jf = sys.argv[1]
try:
    with open(jf, 'r', encoding='utf-8') as f:
        data = json.load(f)
    papers = data.get('papers', [])
    if not papers:
        sys.exit(1)
    lines = [f"=== {os.path.basename(jf)} ({len(papers)}편) ==="]
    for i, p in enumerate(papers):
        title = p.get('title', 'N/A')
        abstract = (p.get('abstract', '') or '')[:150]
        score = p.get('score', 0)
        lines.append(f"  [{i}] score={score:.2f} | {title}")
        if abstract:
            lines.append(f"      초록: {abstract}...")
    lines.append(f"\n총 {len(papers)}편")
    print('\n'.join(lines))
except:
    sys.exit(1)
BSEOF
      ) || { echo -e "${YELLOW}    ⚠ ${RJSON_NAME}: 파싱 실패 — 스킵${NC}"; continue; }

      PAPER_COUNT=$(echo "$BATCH_SUMMARY" | grep -c "^\s*\[" 2>/dev/null || echo "0")
      if [ "$PAPER_COUNT" -eq 0 ]; then
        continue
      fi

      echo -e "${BLUE}    ▶ [${BATCH_TOTAL}] ${RJSON_NAME} (${PAPER_COUNT}편)${NC}"

      # Claude 요청 (파일 1개 단위)
      BATCH_PROMPT="$(cat << BPEOF
너는 학술 논문 연관성 검증 전문가야.

## 주제
루트: $TOPIC
서브토픽: $LEAF_TOPICS_STR

## 작업
아래 논문 목록에서 루트 주제 및 서브토픽과 관련 없는 논문을 식별해.
제목과 초록을 기반으로 판단하고, 제거할 논문의 인덱스를 JSON 배열로 반환.

## 판단 기준
- 서브토픽 중 어느 것과도 관련 없는 논문 → 제거
- 주제와 무관한 동음이의어 논문 → 제거
- 관련성이 약하지만 참고할 만한 논문 → 유지

## 논문 목록
$BATCH_SUMMARY

## 출력 형식 (JSON만 출력, 다른 텍스트 금지)
\`\`\`json
[제거할_인덱스_배열]
\`\`\`
비관련 논문이 없으면 빈 배열 [] 을 반환해.
BPEOF
      )"

      BATCH_RESPONSE=$(claude -p "$BATCH_PROMPT" --model "$MODEL_LIGHT" --output-format text 2>&1) || BATCH_RESPONSE=""

      if [ -z "$BATCH_RESPONSE" ]; then
        echo -e "${YELLOW}      ⚠ Claude 응답 없음 — 스킵${NC}"
        BATCH_FAIL=$((BATCH_FAIL + 1))
        continue
      fi

      # 응답에서 인덱스 배열 추출 → JSON에서 제거
      REMOVED=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$BATCH_RESPONSE" "$RJSON" << 'RMEOF'
import json, sys, re

raw = sys.argv[1]
jf = sys.argv[2]

# JSON 배열 추출
m = re.search(r'\[[\s\S]*?\]', raw)
if not m:
    print("0")
    sys.exit(0)

try:
    indices = json.loads(m.group())
    if not isinstance(indices, list) or not indices:
        print("0")
        sys.exit(0)
    indices_set = set(int(i) for i in indices if isinstance(i, (int, str)) and str(i).isdigit())
except:
    print("0")
    sys.exit(0)

try:
    with open(jf, 'r', encoding='utf-8') as f:
        data = json.load(f)
    papers = data.get('papers', [])
    original = len(papers)
    data['papers'] = [p for idx, p in enumerate(papers) if idx not in indices_set]
    removed = original - len(data['papers'])
    if removed > 0:
        with open(jf, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    print(removed)
except:
    print("0")
RMEOF
      ) || REMOVED=0
      REMOVED=${REMOVED// /}

      if [ "$REMOVED" -gt 0 ] 2>/dev/null; then
        echo -e "${GREEN}      ✓ ${REMOVED}개 비관련 논문 제거${NC}"
        TOTAL_REMOVED=$((TOTAL_REMOVED + REMOVED))
      fi
      BATCH_OK=$((BATCH_OK + 1))
    done

    if [ "$BATCH_TOTAL" -gt 0 ]; then
      echo -e "${GREEN}  ✓ 연관성 검증 완료: ${BATCH_OK}/${BATCH_TOTAL} 배치 성공, 총 ${TOTAL_REMOVED}개 제거${NC}"
      _REL_STATUS="OK"
      if [ "$BATCH_FAIL" -gt 0 ]; then _REL_STATUS="WARN"; fi
      health_check "phase1.5-relevance" "$_REL_STATUS" \
        "${BATCH_OK}/${BATCH_TOTAL} 배치, ${TOTAL_REMOVED}개 제거"
      report_step "phase1.5-relevance" "OK" "${TOTAL_REMOVED}개 비관련 논문 제거 (${BATCH_OK}/${BATCH_TOTAL} 배치)"
    else
      echo -e "${YELLOW}  ⚠ 검증할 논문 없음 — 스킵${NC}"
      report_step "phase1.5-relevance" "SKIP" "논문 0편"
    fi
    echo ""

    # C. 정제된 논문 일괄 PDF 다운로드
    echo -e "${CYAN}  일괄 PDF 다운로드 시작...${NC}"
    if [ -f "${SCRIPT_DIR}/fetch-sources.sh" ]; then
      if [ -n "$UNPAYWALL_EMAIL" ]; then
        bash "${SCRIPT_DIR}/fetch-sources.sh" --email "$UNPAYWALL_EMAIL" || true
      else
        bash "${SCRIPT_DIR}/fetch-sources.sh" || true
      fi
      PDF_DL=$(find docs/sources -name "*.pdf" 2>/dev/null | wc -l)
      PDF_DL=${PDF_DL// /}
      echo -e "${GREEN}  ✓ PDF ${PDF_DL}개 확보${NC}"
      report_step "phase1.5-fetch" "OK" "PDF ${PDF_DL}개"
      # PDF → Markdown 변환
      convert_pdfs_to_md
    else
      echo -e "${YELLOW}  fetch-sources.sh 없음 — 다운로드 스킵${NC}"
      report_step "phase1.5-fetch" "SKIP" "스크립트 없음"
    fi

    git_commit "phase1.5: ${TOPIC} — 리프별 탐색 + 연관성 검증 + PDF 다운로드 + MD 변환"
    echo ""
    echo -e "${CYAN}=== Phase 1.5 완료 → Phase 2 병렬 실행 시작 ===${NC}"
    echo ""

    # ── 배치 병렬 실행 함수 ──
    # 인자: leaf_line 목록 (topic|||path), 라벨
    COMPLETED=0
    FAILED=0
    FAILED_LEAVES=()  # 재시도용

    run_batches() {
      local INPUT_LIST="$1"
      local LABEL="$2"
      local BATCH_NUM=0
      local RUNNING=0
      local PIDS=()
      local BTOPICS=()
      local BPATHS=()

      while IFS= read -r leaf_line <&4; do
        [ -z "$leaf_line" ] && continue
        local LEAF_TOPIC="${leaf_line%%|||*}"
        local LEAF_PATH="$(echo "${leaf_line##*|||}" | tr -d '\r')"
        local LEAF_DIR="subtopics/${LEAF_PATH}"

        echo -e "${BLUE}  ▶ ${LABEL} 시작: \"$LEAF_TOPIC\"${NC}"

        (
          if ! cd "$LEAF_DIR" 2>/dev/null; then
            echo "ERROR: cd '$LEAF_DIR' 실패 — 디렉토리 생성 후 재시도" >&2
            mkdir -p "$LEAF_DIR"
            cd "$LEAF_DIR" || { echo "FATAL: '$LEAF_DIR' 접근 불가" >&2; exit 1; }
          fi
          mkdir -p docs/knowledge docs/reports docs/research
          # 부모 docs/sources 공유 (PDF 재다운로드 방지)
          if [ -d "${SCRIPT_DIR}/docs/sources" ] && [ ! -d "docs/sources" ]; then
            ln -s "${SCRIPT_DIR}/docs/sources" docs/sources 2>/dev/null || \
              mkdir -p docs/sources
          fi
          bash "${SCRIPT_DIR}/ralph.sh" "$LEAF_TOPIC" --no-split --iterations "$MAX_ITERATIONS" \
            ${UNPAYWALL_EMAIL:+--email "$UNPAYWALL_EMAIL"} \
            --no-recovery \
            > "ralph-output.log" 2>&1
        ) < /dev/null &

        PIDS+=($!)
        BTOPICS+=("$LEAF_TOPIC")
        BPATHS+=("$leaf_line")
        RUNNING=$((RUNNING + 1))

        if [ "$RUNNING" -ge "$PARALLEL" ]; then
          BATCH_NUM=$((BATCH_NUM + 1))
          echo -e "${YELLOW}  ⏳ ${LABEL} 배치 ${BATCH_NUM} 대기 (${RUNNING}개 실행 중)...${NC}"
          for idx in "${!PIDS[@]}"; do
            EXIT_CODE=0
            wait "${PIDS[$idx]}" 2>/dev/null || EXIT_CODE=$?
            if [ "$EXIT_CODE" -eq 0 ]; then
              echo -e "${GREEN}  ✓ 완료: \"${BTOPICS[$idx]}\"${NC}"
              health_check "phase2-batch" "OK" "${BTOPICS[$idx]}"
              COMPLETED=$((COMPLETED + 1))
            else
              echo -e "${RED}  ✗ 실패: \"${BTOPICS[$idx]}\" (exit ${EXIT_CODE})${NC}"
              # 서브태스크 로그에서 에러 원인 추출
              local LEAF_P="${BPATHS[$idx]}"
              local LEAF_LOG="subtopics/${LEAF_P##*|||}/ralph-output.log"
              local ERR_DETAIL=""
              if [ -f "$LEAF_LOG" ]; then
                ERR_DETAIL=$(grep -iE "error|fatal|fail|exception|traceback|errno" "$LEAF_LOG" | tail -3 | tr '\n' ' ')
              fi
              health_check "phase2-batch" "FAIL" "${BTOPICS[$idx]} | exit=${EXIT_CODE} | ${ERR_DETAIL:-(로그 없음)}"
              FAILED=$((FAILED + 1))
              FAILED_LEAVES+=("${BPATHS[$idx]}")
            fi
          done
          # activity.md에 배치 진행상황 기록
          echo "- [$(date '+%Y-%m-%d %H:%M')] ${LABEL} 배치 ${BATCH_NUM}: ${COMPLETED} 성공, ${FAILED} 실패" >> activity.md
          PIDS=()
          BTOPICS=()
          BPATHS=()
          RUNNING=0
          # 배치 간 쿨다운 (rate limit 완화)
          echo -e "${YELLOW}  ⏳ 배치 간 쿨다운 30초...${NC}"
          sleep 30
        fi
      done 4<<< "$INPUT_LIST"

      # 마지막 배치 대기
      if [ "$RUNNING" -gt 0 ]; then
        BATCH_NUM=$((BATCH_NUM + 1))
        echo -e "${YELLOW}  ⏳ ${LABEL} 배치 ${BATCH_NUM} 대기 (${RUNNING}개 실행 중)...${NC}"
        for idx in "${!PIDS[@]}"; do
          EXIT_CODE=0
          wait "${PIDS[$idx]}" 2>/dev/null || EXIT_CODE=$?
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo -e "${GREEN}  ✓ 완료: \"${BTOPICS[$idx]}\"${NC}"
            health_check "phase2-batch" "OK" "${BTOPICS[$idx]}"
            COMPLETED=$((COMPLETED + 1))
          else
            echo -e "${RED}  ✗ 실패: \"${BTOPICS[$idx]}\" (exit ${EXIT_CODE})${NC}"
            local LEAF_P="${BPATHS[$idx]}"
            local LEAF_LOG="subtopics/${LEAF_P##*|||}/ralph-output.log"
            local ERR_DETAIL=""
            if [ -f "$LEAF_LOG" ]; then
              ERR_DETAIL=$(grep -iE "error|fatal|fail|exception|traceback|errno" "$LEAF_LOG" | tail -3 | tr '\n' ' ')
            fi
            health_check "phase2-batch" "FAIL" "${BTOPICS[$idx]} | exit=${EXIT_CODE} | ${ERR_DETAIL:-(로그 없음)}"
            FAILED=$((FAILED + 1))
            FAILED_LEAVES+=("${BPATHS[$idx]}")
          fi
        done
        echo "- [$(date '+%Y-%m-%d %H:%M')] ${LABEL} 배치 ${BATCH_NUM}: ${COMPLETED} 성공, ${FAILED} 실패" >> activity.md
      fi

      local _LS_STATUS="OK"; if [ "$FAILED" -gt 0 ]; then _LS_STATUS="WARN"; fi
      health_check "${LABEL}-summary" "$_LS_STATUS" \
        "완료=${COMPLETED} 실패=${FAILED} 총=${LEAF_COUNT:-?}"
    }

    # 1차 실행
    run_batches "$LEAF_LIST" "1차"

    echo ""
    echo -e "${GREEN}=== 1차 실행 완료: ${COMPLETED} 성공, ${FAILED} 실패 ===${NC}"

    # ── 리밋 감지 + 자동 대기 + 재시도 ──
    # Claude 사용량 리밋 체크: 간단한 호출로 테스트
    check_claude_available() {
      local TEST_RESULT
      TEST_RESULT=$(claude -p "ping" --model "$MODEL_LIGHT" --output-format text 2>&1) || true
      # 리밋 에러 키워드 감지
      if echo "$TEST_RESULT" | grep -qiE "rate.?limit|usage.?limit|quota|overloaded|capacity|429|529"; then
        return 1  # 리밋 걸림
      fi
      return 0  # 사용 가능
    }

    RETRY=0
    MAX_RETRY=50  # 5분 × 50 = 최대 ~4시간 대기
    while [ "${#FAILED_LEAVES[@]}" -gt 0 ] && [ "$RETRY" -lt "$MAX_RETRY" ]; do
      RETRY=$((RETRY + 1))
      RETRY_COUNT=${#FAILED_LEAVES[@]}
      echo ""
      echo -e "${YELLOW}=== ${RETRY_COUNT}개 실패 리프 감지 — 리밋 체크 중... ===${NC}"

      # 리밋 풀렸는지 폴링 (5분 간격)
      POLL=0
      while ! check_claude_available; do
        POLL=$((POLL + 1))
        echo -e "${YELLOW}  ⏳ 리밋 대기 중... (${POLL}번째 체크, 5분 후 재확인) [$(date '+%H:%M:%S')]${NC}"
        sleep 300
      done

      echo -e "${GREEN}  ✓ Claude 사용 가능 확인! 재시도 ${RETRY} 시작${NC}"

      # 실패 목록을 줄바꿈 문자열로 변환
      RETRY_LIST=""
      for fl in "${FAILED_LEAVES[@]}"; do
        RETRY_LIST="${RETRY_LIST}${fl}"$'\n'
      done
      FAILED_LEAVES=()
      FAILED=0

      run_batches "$RETRY_LIST" "재시도${RETRY}"

      echo ""
      echo -e "${GREEN}=== 재시도 ${RETRY} 완료: ${COMPLETED} 성공, ${FAILED} 실패 ===${NC}"
    done

    if [ "${#FAILED_LEAVES[@]}" -gt 0 ]; then
      echo -e "${RED}⚠️  최종 실패 리프 ${#FAILED_LEAVES[@]}개 (${MAX_RETRY}회 재시도 소진):${NC}"
      for fl in "${FAILED_LEAVES[@]}"; do
        echo -e "${RED}    - ${fl%%|||*}${NC}"
      done
    fi

    report_step "parallel-exec" "OK" "${COMPLETED}/${LEAF_COUNT} 완료, ${#FAILED_LEAVES[@]} 최종실패 (재시도 ${RETRY}회)"
    echo ""

    # Phase 3: 결과 합침
    echo -e "${CYAN}=== 서브토픽 결과 합침 ===${NC}"
    echo ""

    MERGE_COUNT=0
    # 리프 노드 다시 순회하며 docs/ 복사
    LEAF_LIST2=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - "$SUBTOPICS_JSON" << 'LL2EOF'
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    data = json.load(f)
for leaf in data['leaves']:
    print(leaf['path'])
LL2EOF
    )

    while IFS= read -r leaf_path <&5; do
      [ -z "$leaf_path" ] && continue
      leaf_path="$(echo "$leaf_path" | tr -d '\r')"
      LEAF_DIR="subtopics/${leaf_path}"

      # knowledge, reports 복사 (sources, research는 제외 — 용량 대비 가치 낮음)
      if [ -d "${LEAF_DIR}/docs/knowledge" ]; then
        cp -n "${LEAF_DIR}/docs/knowledge/"*.md docs/knowledge/ 2>/dev/null && \
          MERGE_COUNT=$((MERGE_COUNT + 1)) || true
      fi
      if [ -d "${LEAF_DIR}/docs/reports" ]; then
        cp -n "${LEAF_DIR}/docs/reports/"*.md docs/reports/ 2>/dev/null || true
      fi
      # research JSON도 합침 (캐시 재활용)
      if [ -d "${LEAF_DIR}/docs/research" ]; then
        cp -n "${LEAF_DIR}/docs/research/"*.json docs/research/ 2>/dev/null || true
      fi
    done 5<<< "$LEAF_LIST2"

    echo -e "${GREEN}✓ ${MERGE_COUNT}개 서브토픽 결과 → 부모 docs/ 병합 완료${NC}"
    report_step "merge-results" "OK" "${MERGE_COUNT}개 서브토픽 결과 병합"
    echo ""

    generate_index

    git_commit "mece: ${TOPIC} — ${LEAF_COUNT}개 서브토픽 분할 + 병렬 실행 완료"
    git_push
    report_step "git" "OK" "커밋 & 푸시"

    print_report
    exit 0
  fi
fi

# ── 학술 논문 자동 탐색 (research-engine) ─────────────────────
if [ -n "$TOPIC" ] && [ -f "${SCRIPT_DIR}/research-engine.sh" ]; then
  echo -e "${CYAN}=== 학술 논문 탐색 시작 ===${NC}"
  echo ""
  RESEARCH_RESULT=$(bash "${SCRIPT_DIR}/research-engine.sh" "$TOPIC" --max-results 30 --depth 1 2>&1) || true
  echo "$RESEARCH_RESULT"

  if echo "$RESEARCH_RESULT" | grep -q "RESEARCH_COMPLETE"; then
    PAPERS_FOUND=$(echo "$RESEARCH_RESULT" | grep "^PAPERS_FOUND=" | cut -d= -f2)
    PAPERS_QUEUED=$(echo "$RESEARCH_RESULT" | grep "^PAPERS_QUEUED=" | cut -d= -f2)
    echo ""
    echo -e "${GREEN}✓ 논문 탐색 완료: ${PAPERS_QUEUED}개 논문 queue에 추가${NC}"
    report_step "research-engine" "OK" "${PAPERS_FOUND}개 발견, ${PAPERS_QUEUED}개 queue 추가"
  else
    echo -e "${YELLOW}⚠️ 논문 탐색 실패 또는 결과 없음. 계속 진행합니다.${NC}"
    report_step "research-engine" "FAIL" "탐색 실패 또는 결과 없음"
  fi
  echo ""
fi

# ── PDF 자동 다운로드 ─────────────────────────────────────────
if [ -f "${SCRIPT_DIR}/fetch-sources.sh" ]; then
  echo -e "${CYAN}=== PDF 다운로드 시작 ===${NC}"
  echo ""
  PDF_BEFORE=$(find docs/sources -name "*.pdf" 2>/dev/null | wc -l)
  if [ -n "$UNPAYWALL_EMAIL" ]; then
    bash "${SCRIPT_DIR}/fetch-sources.sh" --email "$UNPAYWALL_EMAIL" || true
  else
    bash "${SCRIPT_DIR}/fetch-sources.sh" || true
  fi
  PDF_AFTER=$(find docs/sources -name "*.pdf" 2>/dev/null | wc -l)
  PDF_NEW=$((${PDF_AFTER// /} - ${PDF_BEFORE// /}))
  if [ "$PDF_NEW" -gt 0 ] 2>/dev/null; then
    report_step "fetch-sources" "OK" "PDF ${PDF_NEW}개 새로 다운로드 (총 ${PDF_AFTER// /}개)"
  else
    report_step "fetch-sources" "WARN" "새 PDF 0개 다운로드"
  fi
  echo ""
fi

# research-engine + fetch 완료 후 커밋
git_commit "research: ${TOPIC:-queue} — 논문 탐색 + PDF 다운로드"

echo -e "최대 반복 횟수: ${GREEN}$MAX_ITERATIONS${NC}"
echo ""

# PROMPT.md 절대 경로 캐싱
PROMPT_PATH="${PROMPTS_DIR}/PROMPT.md"

echo -e "${YELLOW}2초 후 시작... 중단하려면 Ctrl+C${NC}"
sleep 2
echo ""

# ── in_progress 복구: 이전 비정상 종료 대응 ──────────────────
STALE_RESULT=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 "$QUEUE_UTIL" reset-stale 2>/dev/null) || true
STALE_COUNT=$(echo "$STALE_RESULT" | grep -oE '[0-9]+' || echo "0")
if [ "${STALE_COUNT:-0}" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  이전 실행 잔여 in_progress ${STALE_COUNT}개 → pending으로 리셋${NC}"
  echo ""
fi

# ── 메인 루프 ────────────────────────────────────────────────
for ((i=1; i<=MAX_ITERATIONS; i++)); do
  echo -e "${BLUE}--- Iteration $i / $MAX_ITERATIONS ---${NC}"
  echo ""

  # 혹시 이전 루프에서 fetch 신호가 남아있으면 먼저 처리
  if has_fetch_signal; then
    echo -e "${CYAN}이전 fetch 신호 감지 — 다운로드 재시도${NC}"
    run_fetch
  fi

  # ── PDF 수집: research JSON 랭킹 순으로 매칭 — 배열 방식 ──
  FILE_ARGS=()
  PDF_COUNT=0

  # research JSON에서 랭킹 순으로 소스 매칭 (MD 우선, PDF 폴백)
  if [ -d "docs/research" ]; then
    RANKED_FILES=$(PYTHONIOENCODING=utf-8 PYTHONUTF8=1 $PYTHON3 -X utf8 - << 'RPYEOF' 2>/dev/null || true
import json, glob, os, re, sys
sys.stdout.reconfigure(encoding='utf-8', errors='replace')

titles = []
for jf in sorted(glob.glob("docs/research/*.json"), key=os.path.getmtime, reverse=True):
    try:
        with open(jf, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for p in data.get('papers', []):
            titles.append(p.get('title', ''))
    except:
        continue

# MD 파일 우선, PDF 폴백
mds = {os.path.splitext(os.path.basename(f))[0]: f for f in glob.glob("docs/sources_md/*.md")}
pdfs = {os.path.splitext(os.path.basename(f))[0]: f for f in glob.glob("docs/sources/*.pdf")}

matched = []
for title in titles:
    slug = re.sub(r'[^a-z0-9]', '-', title.lower())
    slug = re.sub(r'-+', '-', slug).strip('-')[:60]
    for name, path in list(mds.items()) + list(pdfs.items()):
        if name == slug or slug.startswith(name) or name.startswith(slug[:30]):
            if path not in matched:
                matched.append(path)
            break

# 매칭 안 된 파일도 추가 (MD 우선)
for path in list(mds.values()) + list(pdfs.values()):
    if path not in matched:
        matched.append(path)

for f in matched[:5]:
    print(f)
RPYEOF
    )

    while IFS= read -r file_path; do
      if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        FILE_ARGS+=(--file "$file_path")
        PDF_COUNT=$((PDF_COUNT + 1))
      fi
    done <<< "$RANKED_FILES"
  fi

  # 매칭 실패 시 폴백: sources_md/ → sources/ 순으로 최대 5개
  if [ "$PDF_COUNT" -eq 0 ]; then
    if [ -d "docs/sources_md" ]; then
      while IFS= read -r -d '' f; do
        if [ "$PDF_COUNT" -lt 5 ]; then
          FILE_ARGS+=(--file "$f")
          PDF_COUNT=$((PDF_COUNT + 1))
        fi
      done < <(find "docs/sources_md" -name "*.md" -print0 2>/dev/null)
    fi
    if [ "$PDF_COUNT" -eq 0 ] && [ -d "docs/sources" ]; then
      while IFS= read -r -d '' f; do
        if [ "$PDF_COUNT" -lt 5 ]; then
          FILE_ARGS+=(--file "$f")
          PDF_COUNT=$((PDF_COUNT + 1))
        fi
      done < <(find "docs/sources" -name "*.pdf" -print0 2>/dev/null)
    fi
  fi

  # 2. 개별 항목의 local_path 또는 pdf_dir (기존 호환)
  if [ "$PDF_COUNT" -eq 0 ]; then
    ITEM_INFO=$(get_current_item_info) || ITEM_INFO=$'\n'
    CURRENT_PDF=$(echo "$ITEM_INFO" | sed -n '1p')
    CURRENT_PDF_DIR=$(echo "$ITEM_INFO" | sed -n '2p')

    if [ -n "$CURRENT_PDF_DIR" ] && [ -d "$CURRENT_PDF_DIR" ]; then
      while IFS= read -r -d '' f; do
        if [ "$PDF_COUNT" -lt 5 ]; then
          FILE_ARGS+=(--file "$f")
          PDF_COUNT=$((PDF_COUNT + 1))
        fi
      done < <(find "$CURRENT_PDF_DIR" -name "*.pdf" -print0 2>/dev/null)
    elif [ -n "$CURRENT_PDF" ] && [ -f "$CURRENT_PDF" ]; then
      FILE_ARGS=(--file "$CURRENT_PDF")
      PDF_COUNT=1
    fi
  fi

  # 소스 첨부 상태 출력 + 리포트
  if [ "$PDF_COUNT" -gt 0 ]; then
    echo -e "${GREEN}📄 소스 ${PDF_COUNT}개 첨부${NC}"
    report_step "pdf-attach" "OK" "${PDF_COUNT}개 소스를 Claude에 첨부"
  else
    echo -e "${YELLOW}📄 소스 없음 — 웹 검색 + 초록 기반으로 진행${NC}"
    report_step "pdf-attach" "WARN" "소스 0개 — 초록+웹 기반"
  fi
  echo ""

  # Claude 실행 — 배열 방식 (eval 제거)
  result=$(claude -p "$(cat "${PROMPTS_DIR}/PROMPT.md")" \
    "${FILE_ARGS[@]}" \
    --model "$MODEL_HEAVY" \
    --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
    --output-format text 2>&1) || true

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
      result=$(claude -p "$(cat "${PROMPTS_DIR}/PROMPT.md")" \
        --file "$CURRENT_PDF" \
        --model "$MODEL_HEAVY" \
        --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
        --output-format text 2>&1) || true
    else
      result=$(claude -p "$(cat "${PROMPTS_DIR}/PROMPT.md")" \
        --model "$MODEL_HEAVY" \
        --allowedTools "Read,Write,Edit,WebSearch,WebFetch,Glob,Grep,Bash" \
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
    report_step "claude-iter-${i}" "OK" "COMPLETE 신호 수신"
    report_step "git" "OK" "커밋 & 푸시"
    generate_index
    git_commit "complete: iteration ${i} — 전체 완료"
    git_push
    print_report
    exit 0
  fi

  # Claude 결과에서 verify 점수 추출
  K_SCORE=$(echo "$result" | grep -oE 'knowledge:? (verify )?[0-9]+' | grep -oE '[0-9]+' | tail -1)
  R_SCORE=$(echo "$result" | grep -oE 'report:? (verify )?[0-9]+' | grep -oE '[0-9]+' | tail -1)
  if [ -n "$K_SCORE" ]; then
    report_step "claude-iter-${i}" "OK" "knowledge:${K_SCORE} report:${R_SCORE:-?}"
  else
    report_step "claude-iter-${i}" "WARN" "완료했으나 점수 추출 불가"
  fi

  git_commit "iteration ${i}: ${TOPIC:-queue} 처리"

  echo -e "${YELLOW}--- Iteration $i 완료 ---${NC}"
  echo ""
done

# ── 최대 반복 도달 ───────────────────────────────────────────
echo ""
echo -e "${RED}최대 반복 횟수 도달 ($MAX_ITERATIONS)${NC}"
report_step "max-iterations" "WARN" "${MAX_ITERATIONS}회 도달, pending 남아있을 수 있음"
generate_index
git_commit "session: ${MAX_ITERATIONS} iterations 완료"
git_push
report_step "git" "OK" "커밋 & 푸시"
print_report
echo ""
echo "남은 항목이 있으면:"
echo "  ./ralph.sh --run 20"
echo ""
exit 1
