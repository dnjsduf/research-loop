# Research Loop

학술 논문 자동 탐색 → PDF 다운로드 → 지식DB/보고서 생성 파이프라인.
bash + embedded Python heredoc 패턴. Windows(Git Bash) 환경.

## 파이프라인 흐름

```mermaid
flowchart TD
    A["./ralph.sh '주제' --iterations N"] --> B[초기화]
    B --> B1[detect-python.sh]
    B --> B2[queue.md 생성]
    B --> B3[git init]
    B1 & B2 & B3 --> C[queue에 주제 추가<br/>queue-util.py]

    C --> D[research-engine.sh<br/>멀티홉 학술 탐색]

    subgraph RE ["research-engine.sh"]
        D1[HOP 1: 키워드 확장] --> D2{{"API 병렬 호출"}}
        D2 --> OA[OpenAlex]
        D2 --> SS[Semantic Scholar]
        D2 --> CR[CrossRef]
        OA & SS & CR --> D3[중복 제거 + 1차 랭킹]
        D3 --> D4[HOP 2: 갭 분석<br/>누락 키워드 → 재검색]
        D4 --> D5[인용 체인 탐색<br/>상위 5개 × refs+cites]
        D5 --> D6[GitHub 레포 탐색]
        D6 --> D7["최종 처리<br/>랭킹 · 클러스터링 · JSON 저장<br/>queue에 상위 논문 추가"]
    end
    D --> D1
    D7 --> E

    E[fetch-sources.sh<br/>PDF 다운로드]

    subgraph FS ["fetch-sources.sh"]
        E1[arXiv PDF] -->|실패| E2[Unpaywall OA]
        E2 -->|실패| E3[Semantic Scholar OA]
        E3 -->|실패| E4[inaccessible-papers.txt 기록]
        E1 -->|성공| E5["docs/sources/{slug}.pdf"]
        E2 -->|성공| E5
        E3 -->|성공| E5
    end
    E --> E1

    E4 & E5 --> F[git commit]
    F --> G[메인 루프]
```

## 모드 판별 & 처리

```mermaid
flowchart TD
    START[iteration 시작<br/>PDF 최대 5개 첨부] --> MODE{모드 판별}

    MODE -->|"p1 pending<br/>+ no knowledge"| A[모드 A: 종합 리서치]
    MODE -->|"p1 done<br/>+ knowledge 있음"| B[모드 B: 점검/보강]
    MODE -->|"p1 done<br/>+ p2+ pending"| C[모드 C: 잔여 일괄 done]
    MODE -->|"pending 0개"| DONE[COMPLETE]

    A --> A1[주제 선택] --> A2["소스 수집<br/>research JSON + PDF 원문"]
    A2 --> A3["문서 생성<br/>knowledge/ + reports/"]
    A3 --> A4["검증<br/>verify-knowledge<br/>verify-report"]
    A4 -->|Fail| A4FIX[1회 수정] --> A4
    A4 -->|Pass| A5[일괄 status: done]

    B --> B1[점검 대상 선택] --> B2[갭 분석]
    B2 --> B3["보강<br/>update.md 병합 정책"]
    B3 --> B4["재검증"]

    A5 & B4 & C --> COMMIT[git commit]
    COMMIT --> NEXT{pending 남음?}
    NEXT -->|Yes| START
    NEXT -->|No| PUSH[git push]
    DONE --> PUSH
```

## --update 모드

```mermaid
flowchart LR
    U1[캐시 삭제<br/>research JSON] --> U2[research-engine<br/>최신 논문 재검색]
    U2 --> U3[fetch-sources<br/>PDF 다운로드]
    U3 --> U4["Claude UPDATE<br/>기존 문서 + 새 논문 병합<br/>verify + Changelog"]
    U4 --> U5[git commit + push]
```

## 안전장치

```mermaid
flowchart TD
    SAFE[안전장치] --> EX[폭발 방지]
    SAFE --> QA[품질 보장]
    SAFE --> SEC[보안]

    EX --> EX1["priority ≥ 3 → 참조 금지"]
    EX --> EX2["pending ≥ 30 → 추가 중단"]
    EX --> EX3["회당 최대 3개, score ≥ 0.5"]
    EX --> EX4["24h 캐시, SS 429 보상"]

    QA --> QA1["verify Anti-Bias + 팩트체크"]
    QA --> QA2["inaccessible-papers.txt 기록"]
    QA --> QA3["모드 C 잔여 정리"]

    SEC --> SEC1["./ 내부만 Read/Write"]
    SEC --> SEC2["python3 -c / rm -rf 차단"]
    SEC --> SEC3["git --force 차단"]
    SEC --> SEC4["*.pdf git 제외"]
```

## 파일 구조

```mermaid
flowchart LR
    subgraph root["루트 (스크립트)"]
        ralph.sh
        research-engine.sh
        fetch-sources.sh
        detect-python.sh
        queue-util.py
    end

    subgraph prompts["prompts/ (Claude 지침)"]
        PROMPT.md
        add-knowledge.md
        verify-knowledge.md
        verify-report.md
        update.md
    end

    subgraph ref["ref/ (참조 문서)"]
        CONVENTIONS.md
        PIPELINE.md
        DEBUG.md
    end

    subgraph docs["docs/ (자동 생성)"]
        research/"JSON 24h 캐시"
        sources/"PDF 로컬만"
        knowledge/"AI 지식DB"
        reports/"사람용 보고서"
    end
```

## 필수 규칙
1. **인코딩**: 모든 python3 호출에 `PYTHONIOENCODING=utf-8 PYTHONUTF8=1 python3 -X utf8`. 파일 I/O에 `encoding="utf-8"`.
2. **파이프 서브쉘 금지**: `echo | while`에서 부모 함수 미상속 → 임시 파일 + `while read < file` 사용.
3. **bash 변수 대용량 텍스트 금지**: `$(cat file.md)` 직접 읽기. 변수 캐싱 X.
4. **heredoc exit**: `sys.exit()` 대신 `os._exit(0)` 사용.
5. **API None 방어**: SS 응답 모든 레벨에서 `isinstance` 체크 + 개별 `try/except`.
6. **Queue 폭발 방지**: priority≥3 금지, pending≥30 중단, 회당 최대 3개, score≥0.5 필터.

## 참조 문서
| 문서 | 내용 |
|------|------|
| [ref/CONVENTIONS.md](ref/CONVENTIONS.md) | 코딩 컨벤션, API 패턴, 안전장치 상세 (코드 예시 포함) |
| [ref/PIPELINE.md](ref/PIPELINE.md) | ASCII 아키텍처 다이어그램, 파일 생성 맵 |
| [ref/DEBUG.md](ref/DEBUG.md) | 환경/API/Queue/Git/Claude 문제 해결, 진단 체크리스트 |
| [README.md](README.md) | 실행 방법, 옵션, 요구사항 |

## 실행
```bash
./ralph.sh "주제" --iterations 3   # 새 리서치
./ralph.sh "주제" --update          # 최신화
./ralph.sh --run 5                  # queue 이어서
```
