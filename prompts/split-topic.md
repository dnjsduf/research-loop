# MECE 주제 분할

주어진 주제를 **MECE(Mutually Exclusive, Collectively Exhaustive)** 원칙으로 하위 주제로 분할하라.

## 규칙

1. **겹침 없이, 합치면 전체 커버** — 서브토픽 간 중복 영역 불허.
2. **개수 자유** — 주제 특성에 따라 3개든 12개든 적절히.
3. **이미 충분히 구체적이면 분할하지 마라** — "하나의 리서치 문서로 커버 가능"하면 빈 배열 `[]` 반환.
4. **논문 검색에 적합한 구체성** — 각 서브토픽은 학술 API(OpenAlex, Semantic Scholar)에서 의미 있는 검색 결과가 나올 수준.
5. **영어로 출력** — 학술 검색 최적화를 위해 서브토픽명은 영어.

## 판단 기준: 분할 vs 스킵

| 분할 O | 분할 X (빈 배열) |
|--------|------------------|
| "semiconductor" → 여러 하위 분야 | "EUV lithography" → 단일 문서 커버 가능 |
| "reinforcement learning" → 알고리즘/환경/응용 등 | "PPO algorithm" → 충분히 구체적 |
| "natural language processing" → 여러 태스크 | "BERT fine-tuning for NER" → 좁은 주제 |

## 입력

```
TOPIC: {{TOPIC}}
```

## 출력 형식

**반드시 JSON 배열만 출력하라. 다른 텍스트 금지.**

구체적 주제 (분할 불필요):
```json
[]
```

넓은 주제 (분할 필요):
```json
["sub-topic 1", "sub-topic 2", "sub-topic 3"]
```

## 예시

입력: `TOPIC: semiconductor`
```json
["semiconductor materials", "semiconductor fabrication process", "semiconductor circuit design", "semiconductor packaging", "semiconductor testing and verification"]
```

입력: `TOPIC: PPO algorithm`
```json
[]
```

입력: `TOPIC: reinforcement learning`
```json
["model-free reinforcement learning", "model-based reinforcement learning", "multi-agent reinforcement learning", "reinforcement learning for robotics", "reinforcement learning theory and convergence"]
```
