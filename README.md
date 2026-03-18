# Research Loop Pipeline

학술 논문 자동 탐색 → 종합 리서치 → 검증 파이프라인.

## 빠른 시작

```bash
cd research-loop
./ralph.sh "주제"                    # 새 주제 리서치
./ralph.sh "주제" --iterations 3     # 3회 반복 (리서치 + 점검)
./ralph.sh "주제" --update           # 기존 주제 최신화
./ralph.sh --run 10                  # queue 이어서 처리
```

## 요구사항

- Python 3.10+ (자동 감지)
- Claude CLI (`claude` 명령)
- 인터넷 연결 (학술 API + 웹 검색)

## 파일 구조

```
research-loop/
├── ralph.sh              # 메인 오케스트레이터
├── research-engine.sh    # 학술 API 멀티홉 탐색
├── fetch-sources.sh      # PDF 병렬 다운로드
├── detect-python.sh      # Python 자동 감지
├── queue-util.py         # queue 안전 파싱
├── PROMPT.md             # Claude 마스터 프롬프트
├── add-knowledge.md      # 문서 생성 지침
├── update.md             # 문서 병합 정책
├── verify-knowledge.md   # 지식DB 검증
├── verify-report.md      # 보고서 검증
├── queue.md              # (자동 생성) 처리 대기열
├── activity.md           # (자동 생성) 실행 로그
└── docs/
    ├── research/         # 탐색 결과 JSON
    ├── knowledge/        # AI 지식DB
    ├── reports/          # 사람용 보고서
    └── sources/          # 원본 PDF
```

## 사용법

### 새 주제 리서치
```bash
./ralph.sh "transformer architecture"
```
1. research-engine이 OpenAlex/Semantic Scholar/CrossRef에서 논문 수집
2. 멀티홉 탐색 + 인용 체인 + 클러스터링
3. Claude가 종합 리서치 수행 → 통합 knowledge + report 생성
4. 팩트체크 + 검증

### 기존 주제 업데이트
```bash
./ralph.sh "transformer architecture" --update
```
캐시 삭제 → 최신 논문 재검색 → 기존 문서에 병합

### 옵션

| 옵션 | 설명 |
|------|------|
| `--iterations N` | 최대 반복 횟수 (기본: 10) |
| `--run N` | queue만 이어서 N회 처리 |
| `--update` | 기존 주제 최신 정보로 업데이트 |
| `--email user@email.com` | Unpaywall API용 이메일 |
