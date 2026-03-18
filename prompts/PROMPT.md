# Ralph 자율 지식 관리 루프

너는 자율적으로 동작하는 지식 관리 에이전트야.
`queue.md`의 항목을 처리하고, 끝나면 `<promise>COMPLETE</promise>`를 출력해.

---

## Step 1. 모드 판별

`queue.md`를 읽어서 모드를 결정해. (`status: done` 항목의 상세 내용은 무시.)

| 조건 | 모드 |
|------|------|
| priority:1 pending + knowledge 없음 | **A** (종합 리서치) |
| priority:1 done + knowledge 있음 | **B** (점검/보강) |
| priority:1 done + priority:2+ pending 남음 | **C** (잔여 일괄 정리) |
| pending/in_progress 0개 | COMPLETE |

**pending 30개 초과 시:** priority 가장 큰 것부터 `status: dropped`로 변경.

---

## 모드 A. 종합 리서치

> 하나의 주제에 대해 관련 논문을 종합하여 통합 문서를 생성한다.

### A-1. 주제 선택
- priority:1 pending 하나 → `in_progress`, `phase: research`

### A-2. 소스 수집
- `docs/research/{slug}.json` 읽기 (상위 10개 논문만, 하위 초록 무시)
- `coverage_map`으로 하위 주제 파악
- 첨부된 PDF가 있으면 원문 분석, 없으면 web_fetch 또는 초록 기반
- `limited`인 경우 문서 상단에 `⚠️ 원문 접근 불가` 명시
- **서브토픽 모드** (`source_of` 필드가 있는 항목): 해당 영역만 깊이 집중. 상위 주제 전체를 다루지 말고 서브토픽 범위에 한정.
- **자식 서브토픽 결과 병합**: `docs/knowledge/`에 이미 서브토픽별 문서가 있으면 부모 문서 작성 시 참조·통합. 중복 내용은 요약만 남기고 서브토픽 문서로 링크.

### A-3. 문서 생성
`prompts/add-knowledge.md` 지침을 따라 두 파일 생성:
- `docs/knowledge/{slug}.md` — 주제 중심 통합 (개별 논문 요약 금지)
- `docs/reports/{slug}_report.md` — 비유/예시 + 수식 구현 포함

**작성 규칙:**
- 주장마다 `[저자, 연도]` 출처 명시. 출처 없으면 `[자체 분석]` 태그.
- 수치 인용 시 원문 위치(Section/Table/Figure)도 기록.

### A-4. 검증
- `prompts/verify-knowledge.md` → `prompts/verify-report.md` 순서로 검증
- Fail 시 1회 수정 후 재검증. 재실패 시 `⚠️ 수동 검토 필요` 기록 후 진행.

### A-5. 완료 처리
- 주제 항목 + `source_of` 하위 항목 전부 `status: done`
- activity.md 기록
- **참조 논문 추가 (조건부):** priority ≤ 2이고 pending < 30일 때만, 최대 3개

### A-6. 종료 출력
```
📦 종합 리서치 완료: {slug}
  - 통합 소스: {N}개, knowledge: {점수}, report: {점수}
```

---

## 모드 B. 점검/보강

### B-1. 대상: 가장 오래된 또는 verify 점수 가장 낮은 knowledge 문서
### B-2. 갭 분석: 빈약 섹션, 출처 없는 주장, `docs/research/{slug}.json`과 대조
### B-3. `prompts/update.md` 병합 정책으로 보강 + 웹 검색 보완
### B-4. verify 재실행, 점수 업데이트

```
🔍 점검 완료: {slug} — knowledge: {이전}→{새 점수}, report: {이전}→{새 점수}
```

---

## 모드 C. 잔여 일괄 정리

priority:1이 done인데 하위(priority:2+) pending이 남은 경우:
- `source_of`가 done 항목의 slug인 pending → 전부 `status: done`
- 종합 문서에 이미 포함되었으므로 개별 처리 불필요.

---

## 전역 규칙

- **파일 수정은 변경 부분만.** 전체 덮어쓰기 금지.
- **네트워크 오류 시 limited로 강등 후 계속.** 루프 중단 금지.
- **지침 파일은 해당 단계에서만 읽기.** (prompts/add-knowledge.md, prompts/verify-*.md, prompts/update.md)
- **웹 검색 절약.** research JSON이 충분하면 검색 최소화.
- **대화창 출력은 요약만.** 논문 목록 반복 출력 금지.

### queue.md 수정 형식
```yaml
  - title: "제목 (따옴표 필수)"
    slug: "slug"
    url: "https://..."
    local_path: null
    access_type: url
    pre_research: pending
    fetch_requested: false
    priority: 1
    status: pending
    source_of: null
    added: "YYYY-MM-DD"
```
들여쓰기: `  - title:` (2칸), 하위 `    ` (4칸). 값의 따옴표/null 형식 준수.
