# 문서 생성 지침

두 파일을 생성: `docs/knowledge/{slug}.md` + `docs/reports/{slug}_report.md`

## Slug 규칙
영문 소문자, 공백→`-`, 특수문자 제거. 한글은 영문 번역 후 적용.

## 리서치 → 생성 흐름
1. slug 확정 → `> 📁 slug: {slug}` 출력
2. 주제 심층 분석 (배경, 원리, 장단점)
3. 출처 수집 (URL, 논문명, 저자, 날짜). 불분명하면 `[출처 미확인]` 태그.
4. 파일 1 (knowledge) + 파일 2 (report) 동시 생성

## 참조 논문 추가 (조건부)
**추가 조건:** priority ≤ 2, pending < 30, queue에 미존재, 최대 3개.
**금지:** 10년 이상 된 논문, 간접 관련, 이미 존재하는 제목/URL.

---

# 파일 1: Knowledge (`docs/knowledge/{slug}.md`)

```yaml
---
title: {주제명}
slug: {slug}
date_created: {YYYY-MM-DD}
date_updated: {YYYY-MM-DD}
sources:
  - url: {URL}
    accessed: {YYYY-MM-DD}
---
```

코딩/아키텍처 설계 시 바로 참고할 핵심만 담을 것.

## 1. 핵심 요약 (TL;DR) — 1~2줄
## 2. 코어 로직 (Core Mechanism) — Step-by-Step, 수도코드, LaTeX 수식
## 3. 프로젝트 적용 방안 — 적용 타겟, 뼈대 코드
## 4. 한계점 및 예외 처리 — 병목, 충돌, 보안
## 5. 원문 포인터 — Section/Figure/Table/Appendix 단위 (모호한 "원문 참조" 금지)
## 6. 공개 구현 — `github_repos` 필드 확인. 없으면 `> 공개 구현 없음`

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|

## 7. 출처 — `[논문명](URL) — 저자, 연도, 열람일`

---

# 파일 2: Report (`docs/reports/{slug}_report.md`)

```yaml
---
title: {주제명}
slug: {slug}
date_created: {YYYY-MM-DD}
date_updated: {YYYY-MM-DD}
sources:
  - url: {URL}
    accessed: {YYYY-MM-DD}
---
```

비유와 예시로 비전문가도 이해할 수 있게 작성.

## 1. 배경 (Introduction) — 왜 등장했는가
## 2. 핵심 개념 (Deep Dive) — 비유 + 상호작용 서술
## 3. 수식 구현 (Key Formulas) — LaTeX 표기 + Python/PyTorch 코드

수식 없는 논문(서베이 등)이면 `> 해당 없음` 표시.
작성 형식: 수식 → 변수 설명 → 코드 (주석으로 변수 매핑)

## 4. 장점과 단점 (Pros & Cons)
## 5. 총평 (Conclusion) — 도입 가치 판단
## 6. 참고 문헌 (References) — 최소 1개 원문 출처 필수
