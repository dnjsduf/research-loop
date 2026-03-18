# Research Loop — 디버그 가이드

파이프라인 실행 중 발생할 수 있는 모든 문제와 해결법.

---

## 1. 환경 문제

### Python을 찾을 수 없음
```
Error: Python 3를 찾을 수 없습니다.
```
**원인:** `detect-python.sh`가 python3를 못 찾음
**해결:**
```bash
# 방법 1: 환경변수 직접 설정
export PYTHON3=/path/to/python3
./ralph.sh "주제"

# 방법 2: detect-python.sh의 candidates에 경로 추가
# 방법 3: Python 설치
winget install Python.Python.3.12   # Windows
brew install python3                 # Mac
sudo apt install python3             # Linux
```

### Could not find platform independent libraries
```
Could not find platform independent libraries <prefix>
```
**원인:** Windows Python 설치 경로 문제 (동작에 영향 없음)
**해결:** 무시해도 됨. 정상 동작함.

### CP949 / UnicodeDecodeError
```
UnicodeDecodeError: 'cp949' codec can't decode byte 0xec
```
**원인:** Windows 기본 코덱이 CP949, 한글/이모지 충돌
**해결:** 모든 python3 호출에 아래 설정 확인:
```bash
PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8
```
파일 열 때:
```python
open("file.md", "r", encoding="utf-8")
```

### Claude CLI 없음
```
bash: claude: command not found
```
**원인:** Claude CLI 미설치
**해결:** https://claude.com/claude-code 에서 설치

---

## 2. API 문제

### Semantic Scholar 429 Rate Limit
```
[WARN] API 실패: https://api.semanticscholar.org/... (HTTP Error 429: )
```
**원인:** 무료 티어 100req/5min 초과
**해결:**
- 잠시 대기 후 재실행 (5분)
- `--depth 0`으로 인용 체인 탐색 비활성화 (API 호출 감소)
- Semantic Scholar API 키 발급: https://www.semanticscholar.org/product/api
```bash
# 인용 체인 없이 실행 (API 호출 절반)
./ralph.sh "주제" --depth 0
```

### OpenAlex 빈 결과
```
[주제] OA:0 SS:0 CR:0
```
**원인:** 키워드가 너무 특수하거나 한글만 사용
**해결:**
- 영어 키워드로 시도
- `kr_en_map` (research-engine.sh) 에 한글→영어 매핑 추가

### CrossRef 타임아웃
```
[WARN] API 실패: https://api.crossref.org/... (timed out)
```
**원인:** CrossRef 응답 느림 (간헐적)
**해결:** research-engine.sh의 `api_get` timeout을 30초로 증가:
```python
data = api_get(url, timeout=30)
```

### Papers With Code API 실패
```
[WARN] API 실패: https://paperswithcode.com/api/...
```
**원인:** Papers With Code 서버 문제 또는 해당 논문 미등록
**해결:** GitHub 레포 탐색 실패해도 나머지 파이프라인은 정상 진행. 무시해도 됨.

### 전체 API 실패 (네트워크 문제)
```
HOP 1 수집: 0개
```
**원인:** 인터넷 연결 끊김 또는 방화벽
**해결:**
```bash
# 네트워크 확인
curl -s https://api.openalex.org/works?search=test | head -1

# 방화벽 허용 필요 도메인:
# - api.openalex.org
# - api.semanticscholar.org
# - api.crossref.org
# - paperswithcode.com
```

---

## 3. Queue 문제

### queue.md 파싱 에러
```
json.decoder.JSONDecodeError
```
**원인:** queue.md에 특수문자(따옴표, 콜론 등)가 title에 있어 정규식 파싱 실패
**해결:**
```bash
# queue-util.py로 안전하게 조회
python3 queue-util.py list
python3 queue-util.py count-pending

# queue.md 수동 확인: title에 따옴표가 이스케이프 안 된 경우
# 잘못: title: "Paper "with" quotes"
# 올바른: title: "Paper \"with\" quotes"
```

### queue 무한 증식
```
pending: 50개 → 100개 → ...
```
**원인:** 참조 논문이 계속 추가되는 체인 폭발
**해결:** 이미 안전장치 적용됨. 수동 정리:
```bash
# pending 수 확인
python3 queue-util.py count-pending

# queue.md에서 priority 3 이상 항목을 status: dropped로 변경
python3 queue-util.py update-field "논문제목" "status" "dropped"
```

### DUPLICATE 계속 발생
```
⚠️ 이미 queue에 있는 주제입니다.
```
**원인:** 정상 동작. 같은 주제 재실행 시 중복 방지.
**해결:** 무시하고 진행하면 됨. 기존 항목으로 계속 처리.

### queue.md 손상
**원인:** 동시 실행, 비정상 종료 등
**해결:**
```bash
# 백업에서 복구
git checkout queue.md

# 또는 새로 생성 (기존 이력 손실)
rm queue.md
./ralph.sh "주제"  # 자동 생성됨
```

---

## 4. 리서치 품질 문제

### 검색 결과 관련도 낮음
```
1. ImageNet classification...  (주제: deep research)
2. Very Deep Convolutional...
```
**원인:**
- Semantic Scholar 429로 차단 → OpenAlex/CrossRef만 사용 → 고인용 일반 논문이 상위
- 갭 키워드가 너무 일반적

**해결:**
```bash
# Semantic Scholar가 정상일 때 재실행
rm docs/research/{slug}.json   # 캐시 삭제
./ralph.sh "주제"

# 또는 키워드를 더 구체적으로
./ralph.sh "deep research agents reinforcement learning"
```

### 갭 키워드 주제 이탈
```
→ 발견된 갭 키워드: ['mml mrow', 'deep convolutional']
```
**원인:** 초록에서 일반적 학술 용어가 갭으로 잡힘
**해결:** research-engine.sh의 `extract_gap_keywords` 함수에서 stopwords 추가:
```python
stopwords.update('추가할 단어들'.split())
```

### limited 모드 문서 품질 저하
```
> ⚠️ 원문 접근 불가: 메타데이터와 인용 정보만으로 작성된 문서입니다.
```
**원인:** PDF도 URL도 접근 불가
**해결:**
1. `inaccessible-papers.txt` 확인
2. 수동으로 PDF 확보 → `docs/sources/`에 저장
3. `queue.md`에서 `local_path` 업데이트
4. `./ralph.sh --run 1`로 재처리

### verify 점수가 계속 90점 이상
**원인:** Claude 자기 검증 편향 (자기가 쓴 글에 후한 점수)
**해결:** verify-knowledge.md / verify-report.md에 Anti-Bias Rules 적용됨.
추가 대응:
- 다른 모델로 검증 (haiku 등)
- 수동으로 문서 검토
- 압박 질문(Q1, Q2)에 직접 답해보기

### 수식 구현이 없는 report
**원인:** 서베이/벤치마크 논문이면 면제됨 (`> 해당 없음`)
**해결:** 수식 기반 논문인데 구현이 없으면 verify에서 H-4 Fail 처리됨. 수동 재작성 필요.

---

## 5. Git 문제

### git init 실패
```
fatal: not a git repository
```
**원인:** .git 디렉토리가 손상됨
**해결:**
```bash
rm -rf .git
./ralph.sh "주제"  # 자동 git init
```

### git push 실패
```
fatal: No configured push destination
```
**원인:** remote가 설정 안 됨
**해결:**
```bash
# GitHub 레포 생성 후 연결
gh repo create my-research --public --source=. --remote=origin --push

# 또는 수동
git remote add origin https://github.com/user/repo.git
git push -u origin master
```

### push 시 인증 실패
```
remote: Permission denied
```
**해결:**
```bash
# GitHub CLI 로그인
gh auth login

# 또는 SSH 키 설정
# 또는 Personal Access Token 사용
```

### 대용량 파일 push 거부
```
remote: error: File docs/sources/large.pdf is 123 MB
```
**원인:** .gitignore에 PDF 제외가 안 됨
**해결:**
```bash
# .gitignore 확인
cat .gitignore | grep pdf

# 이미 커밋된 PDF 제거
git rm --cached docs/sources/*.pdf
git commit -m "remove tracked PDFs"
git push
```

---

## 6. fetch-sources 문제

### PDF 다운로드 0개
```
다운로드할 새 항목 없음
```
**원인:** queue의 pending 항목에 URL이 없거나 이미 처리됨
**해결:**
```bash
# pending 항목 확인
python3 queue-util.py list

# 수동 다운로드 실행
bash fetch-sources.sh
```

### arXiv PDF 다운로드 실패
**원인:** arXiv URL이 /abs/ 형식이 아닌 경우
**해결:** fetch-sources.sh는 `/abs/XXXX.XXXXX` 패턴만 인식. HTML URL은 지원 안 됨.

### 병렬 다운로드 충돌
```
✗ paper-name — url/limited (여러 개 동시)
```
**원인:** MAX_PARALLEL=3에서 동시 curl 충돌
**해결:** fetch-sources.sh에서 `MAX_PARALLEL=1`로 변경하여 순차 실행

---

## 7. Claude 실행 문제

### Claude 권한 거부
```
Error: Tool "Write" is not allowed
```
**원인:** --allowedTools가 누락되었거나 .claude/settings.json이 없음
**해결:**
```bash
# settings.json 확인
cat .claude/settings.json

# 없으면 research-loop에서 복사
cp ~/Desktop/research-loop/.claude/settings.json .claude/
```

### Claude 입력 에러
```
Error: Input must be provided either through stdin or as a prompt argument
```
**원인:** `$(cat PROMPT.md)` 확장 실패 (PROMPT.md 없음 또는 경로 문제)
**해결:**
```bash
# PROMPT.md 존재 확인
ls -la PROMPT.md

# 작업 디렉토리 확인 (반드시 프로젝트 루트에서 실행)
pwd
```

### Claude 토큰 한도 초과
**원인:** 종합 리서치(모드 A)에서 논문 15개+ 소스가 너무 많음
**해결:**
- research-engine의 `--max-results`를 줄이기
- PROMPT.md의 토큰 효율 규칙이 적용되고 있는지 확인
- iteration을 나눠서 처리

### COMPLETE 신호 없이 종료
```
최대 반복 횟수 도달 (10)
```
**원인:** Claude가 `<promise>COMPLETE</promise>`를 출력하지 않음
**해결:**
```bash
# 더 많은 iteration으로 재실행
./ralph.sh --run 20

# 또는 queue 상태 확인 후 수동 처리
python3 queue-util.py count-pending
```

---

## 8. 빠른 진단 체크리스트

문제 발생 시 순서대로 확인:

```bash
# 1. Python 동작 확인
python3 --version

# 2. Claude CLI 확인
claude --version

# 3. 네트워크 확인
curl -s "https://api.openalex.org/works?search=test" | python3 -c "import json,sys; print(json.load(sys.stdin).get('meta',{}).get('count','FAIL'))"

# 4. queue 상태 확인
python3 queue-util.py count-pending

# 5. 파일 구조 확인
ls docs/knowledge/ docs/reports/ docs/research/ docs/sources/

# 6. git 상태 확인
git status

# 7. 최근 activity 확인
tail -20 activity.md

# 8. 접근 불가 논문 확인
cat inaccessible-papers.txt
```

---

## 9. 초기화 (전체 리셋)

모든 리서치 결과를 지우고 처음부터 시작:

```bash
# ⚠️ 주의: 모든 결과물 삭제
rm -f queue.md activity.md inaccessible-papers.txt
rm -rf docs/knowledge/ docs/reports/ docs/research/ docs/sources/
rm -f fetch-signal.txt

# git 이력도 리셋하려면
rm -rf .git
```

queue만 리셋 (문서는 보존):
```bash
rm queue.md
# 다음 실행 시 자동 생성됨
```
