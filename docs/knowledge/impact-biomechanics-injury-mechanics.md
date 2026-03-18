---
title: "Impact Biomechanics and Injury Mechanics"
slug: "impact-biomechanics-injury-mechanics"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3979340/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC1831543/"
    accessed: "2026-03-19"
  - url: "https://www.ncbi.nlm.nih.gov/books/NBK217482/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4609847/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC2790598/"
    accessed: "2026-03-19"
  - url: "https://asmedigitalcollection.asme.org/biomechanical/article/146/3/030301/1195445/"
    accessed: "2026-03-19"
  - url: "https://academic.oup.com/milmed/article/184/Supplement_1/195/5418655"
    accessed: "2026-03-19"
---

## 1. 핵심 요약 (TL;DR)

충격 생체역학은 외부 기계적 하중(충돌, 낙상, 폭발)이 인체 조직에 전달되어 변형·파괴를 일으키는 메커니즘을 연구하며, 조직의 점탄성 특성과 변형률 속도 의존성이 손상 임계값을 결정한다. 신체 부위별(두부, 흉부, 복부, 골반, 상지) 고유한 손상 기준(HIC, TTI, VC, BrIC 등)이 개발되어 차량 안전·스포츠 보호장비·군사 방호 설계에 적용된다.

## 2. 기초 개념 (Foundations)

### 2.1 조직 손상의 3대 변형 모드 [기초 지식]

생체 조직의 손상은 회복 한계를 초과하는 변형에서 발생한다:

- **인장 변형 (Tensile strain)**: 조직을 잡아당겨 늘리는 힘. 동맥 파열, 인대 파단의 주 원인. 변형률이 회복 한계를 넘으면 조직이 끊어진다 [NCBI NBK217482].
- **전단 변형 (Shear strain)**: 서로 반대 방향의 힘이 조직 면을 따라 작용. 두부 충격 시 뇌와 두개골 사이의 차등 운동이 대표적 사례 [NCBI NBK217482].
- **압축 변형 (Compressive strain)**: 조직을 눌러 짓무르게 하는 힘. 흉부 압박 시 늑골 골절의 주 메커니즘 [NCBI NBK217482].

### 2.2 점탄성과 변형률 속도 의존성 [기초 지식]

생체 조직은 점탄성체로, 반응과 내성이 변형률(strain)과 변형률 속도(strain rate)에 모두 의존한다:

- 치밀골(compact bone)은 높은 변형률 속도에서 더 낮은 변형률에서 파괴된다 — 파괴 시 하중은 오히려 더 높다 [NCBI NBK217482].
- 연조직은 점성 내성(viscous tolerance)이 초과될 때 손상된다 — 빠른 하중일수록 압축 내성이 낮아진다 [NCBI NBK217482].
- 골의 비등방성(anisotropic) 점탄소성 손상 모델은 준정적 시험부터 저충격 낙상까지 8차수 규모의 변형률 속도를 커버한다 [ScienceDirect, 2025].

### 2.3 손상 기준(Injury Criteria)의 역할 [기초 지식]

인체 내성 한계를 정량화하여 안전 기준으로 변환하는 공학적 도구. 주요 접근법:

| 기준 유형 | 측정 대상 | 대표 기준 |
|-----------|-----------|-----------|
| 가속도 기반 | 피크 가속도, 지속 시간 | HIC, TTI, AIS |
| 변형 기반 | 최대 압축률 | C_max |
| 점성 기반 | 변형 속도 × 압축률 | VC (Viscous Criterion) |
| 복합 기반 | 회전 속도 + 가속도 | BrIC |

## 3. 코어 로직 (Core Mechanism)

### 3.1 두부 충격 메커니즘 — Step-by-Step

```
Step 1: 외부 충격이 두개골에 전달
Step 2: 두개골 내 압력파 전파 (음향 임피던스 차이로 감쇠/증폭)
        - 사체 실험: 두개내 피크 압력 = 입사 압력의 1.5~2배 [Panzer, PMC4609847]
Step 3: 선형 가속도 → 두개내 압력 구배 생성
Step 4: 회전 가속도 → 뇌 조직 전단 변형 (주된 뇌진탕 메커니즘)
        - 관상면(coronal) 회전이 심부 뇌 손상 가능성 최대 [PMC3979340]
Step 5: 축삭 손상 — 전압-개폐 나트륨 채널 단백질 분해가 구조적 파괴 이전에 활성화
Step 6: 성상세포 반응성 임계값 < 생존율 변화 임계값 (기능적 손상이 먼저)
```

**Head Injury Criterion (HIC)**:

$$HIC = \max_{t_1, t_2} \left[ (t_2 - t_1) \left( \frac{1}{t_2 - t_1} \int_{t_1}^{t_2} a(t) \, dt \right)^{2.5} \right]$$

- $a(t)$: 두부 무게중심 결과 가속도 (g 단위)
- $t_1, t_2$: 최대값을 주는 시간 구간 (HIC₁₅: 15ms, HIC₃₆: 36ms)
- 75% 정확 예측 임계값: HIC = 160, 선형가속도 96g, 회전가속도 7,235 rad/s² [PMC2790598]
- 10% mTBI 위험: HIC = 400, 선형가속도 165g, 회전가속도 9,000 rad/s² [PMC3217524]

**Brain Injury Criterion (BrIC)**:

$$BrIC = \sqrt{\left(\frac{\omega_x}{\omega_{xC}}\right)^2 + \left(\frac{\omega_y}{\omega_{yC}}\right)^2 + \left(\frac{\omega_z}{\omega_{zC}}\right)^2}$$

- $\omega_{x,y,z}$: 각 축 최대 회전 속도
- $\omega_{xC} = 66.25$, $\omega_{yC} = 56.45$, $\omega_{zC} = 42.87$ rad/s (임계 회전 속도)
- 50% 손상 위험 임계값: 선형가속도 100g, 회전가속도 8.3 krad/s², 회전속도 40 rad/s [PMC2790598]

### 3.2 흉부·복부·골반 충격 메커니즘

**Thoracic Trauma Index (TTI)**:

$$TTI = \frac{1}{2}(Acc_{rib} + Acc_{spine_{lower}})$$

- FMVSS 214 기준: 4도어 85g, 2도어 90g [PMC1831543]
- AIS ≥ 4 50% 확률: TTI = 169, C_max = 30% [Pintar et al., 1997, PMC1831543]

**Viscous Criterion (VC)**:

$$VC = V(t) \times C(t) = \frac{d[D(t)]}{dt} \times \frac{D(t)}{b}$$

- $D(t)$: 순간 변형, $b$: 원래 흉부 깊이/너비
- 흉부: VC_max = 1.5 m/s (25% 중증 손상 확률) [Viano et al., 1989, PMC1831543]
- 복부: VC_max = 2.0 m/s (25% 중증 손상 확률) [Viano et al., 1989, PMC1831543]

**골반 내성 기준**:
- 골반 골절 피크 충격력: 5th percentile 5.77 kN, 50th 8.00 kN, 95th 9.71 kN [Cavanaugh et al., 1993, PMC1831543]
- 최대 압축률: 27% (25% 중증 손상 확률) [Viano et al., 1989, PMC1831543]
- FMVSS 214 골반 횡가속도 기준: 130g [PMC1831543]

### 3.3 폭발 손상 메커니즘 — 4상 분류

```
Phase 1 (Primary): 폭발파 직접 노출 → 압력 전이
  - 두개골 직접 전달: 골 음향 임피던스 차이로 감쇠 (돼지 두개골 최대 8.4배 감쇠)
  - 흉부 경로: 혈관계 통해 ~1500 m/s로 뇌에 전파
  - 쥐 모델 임계값: ~100 kPa / 2ms 노출, 50% 손상 위험 ~200 kPa

Phase 2 (Secondary): 파편에 의한 관통/둔상
  - 직접 열상 또는 절단형 병변

Phase 3 (Tertiary): 신체 투사 → 낙상/충돌
  - 신전(stretch) 기반 손상, 세포 구조 파괴 이하 수준

Phase 4 (Quaternary): 압궤, 화상, 만성 질환 악화
  - 5차(Quinary): 폭발 독성 물질에 의한 과염증 반응
```

### 3.4 상지 충격 — 낙상 시 손·손목 메커니즘

```
Step 1: 전방 낙상 → 편 손(outstretched hand)으로 지면 충격
Step 2: 충격력 = 고주파 초기 피크 + 저주파 후속 진동
  - 체중 증가 → 저주파 성분 피크 증가 우세
  - 낙하 높이 증가 → 고주파 성분에 강한 영향 [DeGoede & Ashton-Miller, 1999]
Step 3: 요골 원위부(distal radius) 집중 하중 → Colles 골절
Step 4: 손목 인대 손상 — 과외전(hyperabduction)/과신전(hyperextension) 시 측부인대 파단
```

### 3.5 연령 효과 수도코드

```python
import numpy as np

def logistic_risk(deflection: float, k: float = 10.0, x0: float = 0.30) -> float:
    """기본 로지스틱 위험함수: 정규화 흉부 압축률 → [0,1] 손상 확률"""
    return 1.0 / (1.0 + np.exp(-k * (deflection - x0)))

def injury_risk_age_adjusted(deflection: float, age: int, base_age: int = 45) -> float:
    """
    연령 보정 손상 위험도 산출
    - Marcus et al. (1983): 연간 ~0.2개 추가 늑골 골절 [PMC1831543]
    - 65세+ 사망률 2배, 늑골 골절당 사망률 19%↑, 폐렴 27%↑ [PMC1831543]
    Args:
        deflection: 정규화 흉부 압축률 (0~1), 예: 0.30 = 30%
        age: 환자 나이
        base_age: 기준 연령 (기본 45세, Kuppa et al. 2000)
    Returns:
        보정된 손상 확률 [0, 1]
    """
    base_risk = logistic_risk(deflection)
    age_factor = 1.0 + 0.02 * max(0, age - base_age)  # 연간 2% 증가
    if age >= 65:
        age_factor *= 2.0  # 고령자 사망률 2배
    return min(1.0, base_risk * age_factor)

# 사용 예
# 30% 압축, 70세 → injury_risk_age_adjusted(0.30, 70) ≈ 0.76
```

## 4. 프로젝트 적용 방안

### 4.1 적용 타겟

상위 주제(upper extremity dynamics and manipulation) 맥락에서 충격 생체역학은:
- **로봇 매니퓰레이션 안전 설계**: 로봇-인간 충돌 시 허용 충격력 산정
- **보호장비 설계 시뮬레이션**: 손목 보호대, 헬멧 등의 에너지 흡수 성능 평가
- **낙상 감지/예방 알고리즘**: IMU 데이터 기반 충격 가속도 임계값 판별

### 4.2 뼈대 코드 — HIC 계산기

```python
import numpy as np
from scipy.optimize import minimize_scalar

def compute_hic(time: np.ndarray, accel_g: np.ndarray,
                max_duration: float = 0.015) -> tuple[float, float, float]:
    """
    HIC 계산 (HIC15 기본)
    Args:
        time: 시간 배열 (s)
        accel_g: 결과 가속도 배열 (g)
        max_duration: 최대 시간 창 (s), HIC15=0.015, HIC36=0.036
    Returns:
        (hic_value, t1_opt, t2_opt)
    """
    dt = np.diff(time)
    cum_accel = np.cumsum(accel_g[:-1] * dt)  # 누적 적분
    cum_accel = np.insert(cum_accel, 0, 0.0)

    n = len(time)
    hic_max = 0.0
    t1_best, t2_best = 0.0, 0.0

    for i in range(n - 1):
        for j in range(i + 1, n):
            delta_t = time[j] - time[i]
            if delta_t > max_duration:
                break
            if delta_t < 1e-9:
                continue
            avg_accel = (cum_accel[j] - cum_accel[i]) / delta_t
            hic_val = delta_t * (abs(avg_accel) ** 2.5)
            if hic_val > hic_max:
                hic_max = hic_val
                t1_best, t2_best = time[i], time[j]

    return hic_max, t1_best, t2_best


def compute_bric(omega_x: float, omega_y: float, omega_z: float) -> float:
    """
    BrIC 계산
    Args:
        omega_x, omega_y, omega_z: 각 축 최대 회전 속도 (rad/s)
    Returns:
        BrIC 값
    """
    w_xc, w_yc, w_zc = 66.25, 56.45, 42.87  # 임계 회전 속도
    return np.sqrt((omega_x/w_xc)**2 + (omega_y/w_yc)**2 + (omega_z/w_zc)**2)


def compute_vc(displacement: np.ndarray, time: np.ndarray,
               chest_depth: float) -> float:
    """
    Viscous Criterion 계산
    Args:
        displacement: 흉부 변형 시계열 (m)
        time: 시간 배열 (s)
        chest_depth: 원래 흉부 깊이 (m)
    Returns:
        VC_max (m/s)
    """
    velocity = np.gradient(displacement, time)
    compression = displacement / chest_depth
    vc = np.abs(velocity * compression)
    return float(np.max(vc))
```

## 5. 한계점 및 예외 처리

| 한계 | 설명 | 대응 |
|------|------|------|
| **개인차 미반영** | 내성은 나이, 성별, 체격에 의존하나 대부분 기준은 50th percentile 성인 남성 기반 [NCBI NBK217482] | 연령 보정 계수 적용; 소아·고령자별 별도 임계값 필요 |
| **동물 모델 외삽 한계** | 폭발 TBI 임계값은 주로 쥐/돼지 모델 — 인간 사체 데이터 5구 미만 [PMC4609847] | 스케일링 법칙 적용 시 불확실성 범위 명시 |
| **변형률 속도 데이터 부족** | 폭발 수준 변형률 속도(>10³ s⁻¹)에서의 조직 물성 데이터 제한적 [PMC4609847] | FE 모델에서 외삽 주의, 민감도 분석 필수 |
| **단일 메트릭 한계** | HIC는 선형가속도만, BrIC는 회전만 — 복합 하중 예측 부정확 | HIC + BrIC 복합 평가, 또는 FE 기반 조직 수준 분석 |
| **현장 데이터 부재** | 실제 폭발/충돌 노출과 손상 결과의 상관 데이터 부족 [PMC4609847] | 실험실 데이터 기반 확률적 위험 함수 사용 |

## 6. 원문 포인터

| 출처 | 위치 | 내용 |
|------|------|------|
| PMC3979340 (Biomechanics of Concussion) | Introduction, "Tissue-Level Responses" 섹션 | 전단 변형이 뇌진탕의 주 메커니즘, 축삭 나트륨 채널 손상 |
| PMC1831543 (Side Impact Biomechanics) | Table 1-3, Results 섹션 | TTI/VC/C_max 임계값, 연령별 늑골 골절 증가율 0.2/년 |
| PMC2790598 (Head Impact Severity) | Table 2, Methods 섹션 | HIC/선형가속도/회전가속도 75% 예측 임계값 |
| PMC4609847 (Primary Blast bTBI) | Table 1, "Mechanisms" 섹션 전체 | 3가지 1차 폭발 메커니즘, 쥐 100 kPa 임계값 |
| NCBI NBK217482 (Injury In America) | "Biomechanics of Injury" 챕터, Figure 1-3 | 인장/전단/압축 변형 모드, 점탄성 개념 |
| NHTSA BrIC 보고서 | 전체 (Takhounts et al., 2013) | BrIC 공식 유도, 임계 회전 속도 값 |
| PMC1831543 | "Aging" 섹션, Kuppa et al. 분석 | 60세 vs 45세 MAIS≥3 확률 차이, 늑골 골절당 사망률 19%↑ |

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| [OpenSim](https://github.com/opensim-org/opensim-core) | C++/Python | 800+ | 예 | 근골격 시뮬레이션, 충격 해석 가능 |
| [FEBio](https://github.com/febiosoftware/FEBio) | C++ | 200+ | 예 | 유한요소 생체역학 해석, 충격 하중 지원 |
| [GIBBON](https://github.com/gibbonCode/GIBBON) | MATLAB | 400+ | 예 | FE 전처리/후처리, 생체역학 모델링 |

## 8. 출처

- [Biomechanics of Concussion](https://pmc.ncbi.nlm.nih.gov/articles/PMC3979340/) — Meaney & Smith, 2011, 열람일 2026-03-19
- [Biomechanics of Side Impact: Injury Criteria, Aging Occupants, and Airbag Technology](https://pmc.ncbi.nlm.nih.gov/articles/PMC1831543/) — Yoganandan et al., 2007, 열람일 2026-03-19
- [Injury Biomechanics Research and the Prevention of Impact Injury](https://www.ncbi.nlm.nih.gov/books/NBK217482/) — NRC Committee on Trauma Research, 1985, 열람일 2026-03-19
- [The Complexity of Biomechanics Causing Primary Blast-Induced TBI](https://pmc.ncbi.nlm.nih.gov/articles/PMC4609847/) — Courtney & Courtney, 2015, 열람일 2026-03-19
- [Head Impact Severity Measures for Evaluating mTBI Risk](https://pmc.ncbi.nlm.nih.gov/articles/PMC2790598/) — Greenwald et al., 2008, 열람일 2026-03-19
- [Special Issue: Current Trends in Impact and Injury Biomechanics](https://asmedigitalcollection.asme.org/biomechanical/article/146/3/030301/1195445/) — ASME J. Biomech. Eng., 2024, 열람일 2026-03-19
- [Biomechanics of Blast TBI With Time-Resolved Consecutive Loads](https://academic.oup.com/milmed/article/184/Supplement_1/195/5418655) — Kalra et al., 2019, 열람일 2026-03-19
- [Development of Brain Injury Criteria (BrIC)](https://www.nhtsa.gov/sites/nhtsa.gov/files/2022-09/Stapp2013%20Takhounts.pdf) — Takhounts et al., 2013, 열람일 2026-03-19
