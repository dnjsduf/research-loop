# Research Loop — 코딩 컨벤션 & 규칙 상세

## 1. 인코딩 (Windows CP949 문제)

Windows 기본 코덱 CP949가 한글/이모지와 충돌하여 `UnicodeEncodeError` 발생.

**Python 호출 시 (모든 곳에서):**
```bash
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8
```

**Python 파일 I/O:**
```python
# 파일 열 때
with open("file.md", "r", encoding="utf-8") as f:

# stdout/stderr 재설정 (스크립트 시작 부분)
sys.stdout.reconfigure(encoding='utf-8', errors='replace')
sys.stderr.reconfigure(encoding='utf-8', errors='replace')
```

**detect-python.sh:**
Windows Store의 가짜 `python3.exe`가 PATH에서 먼저 잡힐 수 있음.
`PYTHON3` 환경변수로 오버라이드 가능.

---

## 2. Bash + Embedded Python 패턴

### 파이프 서브쉘 함수 미상속
```bash
# BAD — 서브쉘에서 my_func 못 찾아서 조용히 죽음
echo "$DATA" | while read line; do
  my_func "$line"    # 에러 없이 실패
done

# GOOD — 임시 파일로 우회
echo "$DATA" > "$TMP_FILE"
while read line; do
  my_func "$line"
done < "$TMP_FILE"
```

### bash 변수 대용량 텍스트
```bash
# BAD — 특수문자/줄바꿈 깨짐
CONTENT=$(cat PROMPT.md)
claude -p "$CONTENT"

# GOOD — 매번 직접 읽기
claude -p "$(cat PROMPT.md)"
```

### heredoc 안 Python exit
```bash
python3 << 'PYEOF'
# BAD — SystemExit 예외만 발생, 후속 코드 실행됨
if cached:
    sys.exit(0)

# GOOD — 프로세스 즉시 종료
if cached:
    os._exit(0)
PYEOF
```

---

## 3. API 방어 코딩

### Semantic Scholar None 방어
```python
# BAD
for paper in response['data']:
    title = paper['citedPaper']['title']

# GOOD
for entry in response.get('data', []):
    if not isinstance(entry, dict):
        continue
    cited = entry.get('citedPaper')
    if not isinstance(cited, dict):
        continue
    title = cited.get('title', '')
```

### SS 429 Rate Limit 보상
무료 티어 100req/5min. 차단 시 OpenAlex/CrossRef 검색량 2배로 보상.
`adaptive_sleep(0.8)` 적용.

### GitHub Search API
10req/min 제한 → `adaptive_sleep(6.5)` 필수.
관련도 필터: 논문 제목 단어 2개+ 겹쳐야 매칭.

---

## 4. Queue 폭발 방지

참조 논문의 참조가 무한 체인 → 지수 폭발. 테스트에서 1주제 → 50+ pending 확인됨.

**3중 안전장치:**
| 규칙 | 위치 |
|------|------|
| `priority ≥ 3` → 참조 추가 금지 | research-engine.sh, PROMPT.md |
| `pending ≥ 30` → 추가 중단 | research-engine.sh, PROMPT.md |
| 회당 최대 3개 + `score ≥ 0.5` | PROMPT.md |

---

## 5. 주의사항

- PDF는 `.gitignore`에서 제외 — `docs/sources/`는 로컬에만 존재
- `fetch-signal.txt`는 ralph↔fetch-sources 통신용 임시 파일
- research JSON 캐시 24h — 강제 갱신: JSON 삭제 후 재실행
- PwC API 제거됨 → GitHub Search API로 완전 대체
- `queue-util.py`로 queue 조작 — 직접 정규식 파싱하지 말 것
