---
title: "Walking Gait Kinematics and Kinetics"
slug: "walking-gait-kinematics-and-kinetics"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://now.aapmr.org/biomechanics-normal-gait/"
    accessed: "2026-03-19"
  - url: "https://systematicreviewsjournal.biomedcentral.com/articles/10.1186/s13643-019-1063-z"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11118041/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC5507211/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4397580/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC6262765/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC1664897/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC7502709/"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction)

사람은 하루 평균 6,000~10,000보를 걷는다. 이 단순해 보이는 동작 이면에는 200개 이상의 뼈, 600개 이상의 근육, 그리고 수십 개의 관절이 정밀하게 협응하는 역학 시스템이 작동한다. 보행 분석(gait analysis)은 이 복잡한 움직임을 **운동학(kinematics, "어떻게 움직이는가")**과 **운동역학(kinetics, "왜 그렇게 움직이는가")**이라는 두 축으로 정량화하는 학문이다.

보행 분석은 원래 뇌성마비 아동의 수술 계획을 위해 1970년대부터 임상에 도입되었고 [PM&R KnowledgeNow], 현재는 재활의학, 스포츠 과학, 로봇 보조 장치(exoskeleton) 설계, 그리고 근골격 시뮬레이션(OpenSim)의 핵심 검증 데이터로 활용된다.

## 2. 기초 개념 (Foundations)

### 2.1 보행 주기 — "걸음의 시계"

한 걸음을 시계에 비유하면:

- **0시(0%)**: 오른발 뒤꿈치가 바닥에 닿는 순간 (초기접지, Initial Contact)
- **0~6시(0~60%)**: 오른발이 땅에 붙어 있는 **입각기(Stance phase)** — 체중을 지탱하며 몸을 앞으로 밀어내는 구간
- **6~12시(60~100%)**: 오른발이 공중에 뜬 **유각기(Swing phase)** — 다리를 앞으로 옮기는 구간

입각기를 더 세분하면 다음과 같다 [기초 지식]:

| 하위 구간 | 시계 비유 | 하는 일 |
|-----------|-----------|---------|
| 초기접지(IC) | 0시 정각 | 뒤꿈치가 땅에 닿음 |
| 하중응답(LR) | 0~1시 | 충격 흡수, 양발이 땅에 |
| 중간입각(MSt) | 1~3시 | 한 발로 서서 몸이 넘어감 |
| 말기입각(TSt) | 3~5시 | 뒤꿈치 들림, 추진 시작 |
| 전유각(PSw) | 5~6시 | 발가락 떼기 직전, 발차기 |

### 2.2 운동학 vs 운동역학 — "카메라 vs 저울"

**운동학(Kinematics)**: 고속카메라로 찍은 사진과 같다. "관절이 몇 도 굽혀졌는가", "다리가 얼마나 빨리 움직이는가"만 본다. 힘은 고려하지 않는다.

**운동역학(Kinetics)**: 저울과 같다. "발이 바닥을 얼마나 세게 밟는가", "무릎을 펴는 데 얼마나 큰 힘(토크)이 필요한가"를 측정한다. [기초 지식]

### 2.3 역동역학 — "영상을 거꾸로 돌려서 힘 알아내기"

직접 관절 속의 힘을 측정하는 것은 (임플란트 삽입 없이는) 불가능하다. 대신 **역동역학(Inverse Dynamics)**을 쓴다:

> 움직임(운동학) + 외력(지면반력) → 뉴턴의 운동법칙 → 관절 내부 힘·모멘트 역추산

이는 마치 "자동차의 궤적과 도로 경사를 알면 엔진 출력을 역산할 수 있다"는 원리와 같다. [기초 지식]

## 3. 핵심 개념 (Deep Dive)

### 3.1 시상면 관절 각도 — "세 관절의 춤"

걸을 때 고관절·슬관절·족관절은 마치 오케스트라의 세 파트처럼 정확한 타이밍으로 굽혔다 펴진다:

**고관절(Hip)** — "진자의 왕복"
- 초기접지에서 ~20–30° 굽힘(굴곡) → 입각기 동안 서서히 펴짐(신전 ~10°) → 유각기에 다시 빠르게 굽힘
- 마치 시계추가 앞뒤로 흔들리듯 부드러운 사인파 곡선을 그린다
- 총 가동범위(ROM): ~40–45°

**슬관절(Knee)** — "이중 굴곡"
- 걷는 동안 무릎은 두 번 굽혀진다: (1) 하중응답 시 ~15–20° (충격 흡수), (2) 유각기 ~60–65° (발끌림 방지)
- 자동차의 서스펜션처럼 작동: 첫 번째 굴곡은 착지 충격을 흡수하고, 두 번째 굴곡은 다리를 접어 바닥에 걸리지 않게 한다

**족관절(Ankle)** — "세 로커(Rocker)"
1. **Heel rocker**: 뒤꿈치를 축으로 발이 내려옴 (저측굴곡 ~5–10°)
2. **Ankle rocker**: 족관절을 축으로 정강이가 앞으로 넘어감 (배측굴곡 ~10–15°)
3. **Forefoot rocker**: 발가락 관절을 축으로 뒤꿈치가 들림 (push-off, 저측굴곡 ~20°)

[PM&R KnowledgeNow; Physiopedia, Joint Range of Motion During Gait]

### 3.2 지면반력 — "걸을 때 지구가 밀어주는 힘"

뉴턴의 제3법칙: 발이 땅을 밀면, 땅도 같은 크기로 밀어올린다. 이것이 **지면반력(GRF)**이다.

**수직 성분 — "M자 곡선"**

그래프가 알파벳 M처럼 두 개의 봉우리를 그린다:
- 제1봉우리(~1.0–1.2 × 체중): 발 착지 시 몸이 아래로 가속 → 바닥이 더 세게 밀어올림
- 골짜기(~0.7–0.8 × 체중): 한 발 위에서 몸이 포물선 궤적의 꼭대기 → 중력 방향 가속도 감소
- 제2봉우리(~1.0–1.1 × 체중): push-off로 몸을 위로 밀어 올림

> 비유: 트램폴린 위를 걷는 것을 상상하라. 착지할 때와 밀어찰 때 매트가 가장 많이 눌리고, 중간에는 덜 눌린다.

**전후 성분 — "브레이크→액셀"**
- 전반부: 뒤로 미는 힘 (제동, braking) — 앞으로 달려오는 몸을 감속
- 후반부: 앞으로 미는 힘 (추진, propulsion) — 다음 걸음을 위해 가속

이 전환점이 중간입각(약 50% 입각기)에서 발생하며, 제동 임펄스 ≈ 추진 임펄스일 때 등속 보행이 유지된다.

[ScienceDirect, Ground Reaction Force; ResearchGate, Analysis of GRF in Normal Gait]

### 3.3 관절 모멘트와 파워 — "근육의 출력 그래프"

**관절 모멘트(Joint Moment)**: 관절을 돌리려는 회전력(토크). 예를 들어 계단을 오를 때 무릎을 펴는 슬관절 신전 모멘트는 대퇴사두근이 만든다.

**관절 파워(Joint Power)**: 모멘트 × 각속도. 양수이면 근육이 **에너지를 만들어내고**(동심성 수축), 음수이면 **에너지를 흡수한다**(편심성 수축, 브레이크).

보행의 에너지 경제학에서 가장 중요한 사건은 **A2 파워 버스트**(족관절 push-off)이다:
- 전체 보행 에너지의 **80–85%**를 공급 [Nuckols et al., 2018]
- 주로 비복근(gastrocnemius)과 가자미근(soleus)이 담당
- 이 힘이 감소하면(노화, 뇌졸중) 고관절이 보상적으로 더 큰 힘을 내야 하며, 이는 대사 에너지 소비를 증가시킨다 [PMC6262765]

> 비유: 족관절 push-off는 자동차의 엔진이고, 슬관절은 브레이크, 고관절은 조향장치에 해당한다. 엔진(발목)이 약해지면 조향장치(엉덩이)가 과부하된다.

### 3.4 근활성 패턴 — "릴레이 경주"

보행 중 근육 활성화는 마치 릴레이 선수의 바통 터치처럼 순차적으로 이루어진다:

1. **뒤꿈치 착지 직전**: 전경골근(tibialis anterior)이 발을 들어올려 뒤꿈치부터 닿게 준비 + 햄스트링이 유각 속도를 줄임
2. **하중응답**: 대퇴사두근(quadriceps)이 무릎 굴곡을 제어하며 충격 흡수 + 대둔근(gluteus maximus)이 고관절 신전
3. **중간~말기 입각**: 비복근+가자미근(calf muscles)이 점진적으로 활성화 → push-off 폭발
4. **유각기**: 다시 전경골근이 발을 들어올리고 장요근(iliopsoas)이 고관절 굴곡

이 전체 조율에서 단 5개의 기본 패턴(시너지 모듈)이 전체 근활성 변동의 ~90%를 설명한다는 것이 주목할 만하다 [Ivanenko et al., 2004].

### 3.5 보행 속도의 영향 — "기어 변속"

보행 속도가 올라가면 모든 것이 비선형적으로 변한다 [Fukuchi et al., 2019]:

| 매개변수 | 속도 증가 효과 |
|----------|---------------|
| 보폭(stride length) | 선형 증가 → 일정 속도 이상에서 포화 |
| 보행률(cadence) | 선형 증가 |
| 양하지 지지시간 | 감소 (달리기에서는 0) |
| 관절 ROM | 모든 관절에서 증가 (특히 고관절 굴곡·신전) |
| GRF 제1피크 | 비선형 증가 (~1.5 BW at fast walking) |
| 족관절 push-off 파워 | 이차함수적 증가 |
| 근활성 진폭 | 대둔근·대퇴사두근·비복근 순으로 급격히 증가 |

## 4. 수식 구현 (Key Formulas)

### 4.1 역동역학 기본 방정식

2D 시상면에서 단일 세그먼트(예: 정강이)에 대한 Newton-Euler 방정식:

**힘 평형:**

$$
F_{prox} = m \cdot a_{cm} - F_{dist} + m \cdot g
$$

- $F_{prox}$: 근위 관절(무릎)에서의 관절력 [N]
- $F_{dist}$: 원위 관절(발목)에서의 관절력 [N]
- $m$: 세그먼트 질량 [kg]
- $a_{cm}$: 질량중심 가속도 [m/s²]
- $g$: 중력가속도 벡터 [m/s²]

**모멘트 평형:**

$$
M_{prox} = I_{cm} \cdot \alpha - M_{dist} - r_{dist} \times F_{dist} - r_{prox} \times F_{prox}
$$

- $M_{prox}$: 근위 관절 모멘트 [N·m]
- $I_{cm}$: 질량중심 기준 관성모멘트 [kg·m²]
- $\alpha$: 각가속도 [rad/s²]
- $r_{dist}, r_{prox}$: 질량중심에서 원위/근위 관절까지의 위치벡터 [m]

**관절 파워:**

$$
P_j = M_j \cdot \omega_j
$$

- $P_j > 0$: 에너지 생성 (동심성 수축)
- $P_j < 0$: 에너지 흡수 (편심성 수축)

### 4.2 Python 구현

```python
import numpy as np

def inverse_dynamics_segment_2d(
    mass: float,        # 세그먼트 질량 (kg)
    I_cm: float,        # 관성모멘트 (kg·m²)
    a_cm: np.ndarray,   # 질량중심 가속도 [ax, ay] (m/s²)
    alpha: float,       # 각가속도 (rad/s²)
    pos_cm: np.ndarray, # 질량중심 위치 [x, y] (m)
    pos_prox: np.ndarray,  # 근위관절 위치 (m)
    pos_dist: np.ndarray,  # 원위관절 위치 (m)
    F_dist: np.ndarray,    # 원위 관절력 [Fx, Fy] (N)
    M_dist: float          # 원위 관절 모멘트 (N·m)
) -> tuple:
    """단일 세그먼트에 대한 2D 역동역학 계산.

    Returns:
        (F_prox, M_prox): 근위 관절력 [N]과 모멘트 [N·m]
    """
    g = np.array([0.0, -9.81])  # 중력 (아래 방향 음수)

    # Newton: F_prox + F_dist + m*g = m*a_cm
    F_prox = mass * a_cm - F_dist - mass * g

    # 질량중심 기준 위치벡터
    r_dist = pos_dist - pos_cm   # CM → 원위관절
    r_prox = pos_prox - pos_cm   # CM → 근위관절

    # 2D 외적: r × F = rx*Fy - ry*Fx
    cross_dist = r_dist[0] * F_dist[1] - r_dist[1] * F_dist[0]
    cross_prox = r_prox[0] * F_prox[1] - r_prox[1] * F_prox[0]

    # Euler: M_prox + M_dist + r_dist×F_dist + r_prox×F_prox = I*alpha
    M_prox = I_cm * alpha - M_dist - cross_dist - cross_prox

    return F_prox, M_prox


def joint_power(moment: float, omega: float) -> float:
    """관절 파워 계산: P = M · ω

    Args:
        moment: 관절 모멘트 (N·m)
        omega: 관절 각속도 (rad/s)

    Returns:
        파워 (W). 양수=생성, 음수=흡수
    """
    return moment * omega


def gait_cycle_inverse_dynamics(
    segments: list,     # [foot, shank, thigh] 각 세그먼트 데이터
    grf: np.ndarray,    # 지면반력 [Fx, Fy] (N)
) -> list:
    """발→정강이→대퇴 순으로 체인을 따라 역동역학 수행.

    각 segment dict: {mass, I_cm, a_cm, alpha, pos_cm, pos_prox, pos_dist}
    """
    results = []
    F_dist = grf.copy()   # 발의 원위력 = 지면반력
    M_dist = 0.0           # 발바닥에는 free moment ≈ 0 가정

    for seg in segments:
        F_prox, M_prox = inverse_dynamics_segment_2d(
            mass=seg['mass'],
            I_cm=seg['I_cm'],
            a_cm=seg['a_cm'],
            alpha=seg['alpha'],
            pos_cm=seg['pos_cm'],
            pos_prox=seg['pos_prox'],
            pos_dist=seg['pos_dist'],
            F_dist=F_dist,
            M_dist=M_dist
        )
        results.append({
            'joint': seg.get('name', 'unknown'),
            'force': F_prox,
            'moment': M_prox,
            'power': joint_power(M_prox, seg.get('omega', 0.0))
        })

        # 다음 세그먼트의 원위 = 현재의 근위 (작용-반작용)
        F_dist = -F_prox
        M_dist = -M_prox

    return results


# === 사용 예시: 정상 보행 중간입각의 간이 계산 ===
if __name__ == "__main__":
    # 70kg 성인, 정상 보행 (~1.3 m/s) 중간입각 근사값
    body_mass = 70.0  # kg

    # 지면반력 (중간입각 골짜기: ~0.75 BW)
    grf = np.array([0.0, 0.75 * body_mass * 9.81])  # [Fx, Fy] N

    # 간이 세그먼트 데이터 (de Leva, 1996 인체 매개변수 기준)
    foot = {
        'name': 'ankle', 'mass': 1.0,
        'I_cm': 0.003, 'a_cm': np.array([0.1, 0.0]),
        'alpha': 0.5, 'omega': 0.3,
        'pos_cm': np.array([0.25, 0.04]),
        'pos_prox': np.array([0.20, 0.08]),
        'pos_dist': np.array([0.25, 0.00]),
    }
    shank = {
        'name': 'knee', 'mass': 3.2,
        'I_cm': 0.035, 'a_cm': np.array([0.05, 0.1]),
        'alpha': -0.3, 'omega': -0.1,
        'pos_cm': np.array([0.18, 0.25]),
        'pos_prox': np.array([0.15, 0.45]),
        'pos_dist': np.array([0.20, 0.08]),
    }
    thigh = {
        'name': 'hip', 'mass': 7.5,
        'I_cm': 0.12, 'a_cm': np.array([0.02, 0.05]),
        'alpha': 0.1, 'omega': 0.2,
        'pos_cm': np.array([0.12, 0.60]),
        'pos_prox': np.array([0.10, 0.85]),
        'pos_dist': np.array([0.15, 0.45]),
    }

    results = gait_cycle_inverse_dynamics([foot, shank, thigh], grf)

    for r in results:
        print(f"{r['joint']:>5s}: moment={r['moment']:+7.2f} N·m, "
              f"power={r['power']:+7.2f} W")
```

### 4.3 GRF 수직 성분 정규화

보행 속도와 체중이 다른 피험자 간 비교를 위한 정규화:

$$
\hat{F}_z(t) = \frac{F_z(t)}{m \cdot g}
$$

여기서 $\hat{F}_z$는 체중 정규화된 수직 GRF (단위: BW).

시간축은 보행 주기 백분율로 정규화:

$$
\hat{t} = \frac{t - t_{IC}}{t_{next\_IC} - t_{IC}} \times 100\%
$$

## 5. 장점과 단점 (Pros & Cons)

### 장점

| 항목 | 설명 |
|------|------|
| **비침습적 정량화** | 센서를 몸에 붙이기만 하면 관절 내부 역학을 추정 가능 |
| **반복성** | 정상 보행의 관절 각도 ICC > 0.9 (시상면) — 높은 신뢰도 |
| **임상 의사결정 지원** | 수술 전후 비교, 보조기 처방, 재활 목표 설정에 객관적 근거 |
| **시뮬레이션 검증 데이터** | OpenSim 등 근골격 모델의 정확도를 검증하는 gold standard |
| **속도-파라미터 관계** | 자기선택 속도 기준 정규화로 집단 간 비교 가능 |

### 단점

| 항목 | 설명 |
|------|------|
| **피부 아티팩트** | 마커가 피부 위에서 미끄러짐 → 특히 대퇴부에서 최대 2cm 오차 |
| **실험실 제한** | 힘판+카메라 세팅 → 자연스러운 환경이 아님 (생태학적 타당성 ↓) |
| **순 모멘트 한계** | 역동역학은 길항근 동시수축(co-contraction)을 구분 못함 |
| **세그먼트 가정** | 강체(rigid body) 가정 → 실제 연부조직 변형 미반영 |
| **전두면·횡단면** | 시상면 대비 반복성이 낮음 (ICC ~0.5–0.7) |
| **비용** | 광학식 모션캡처 + 힘판 시스템: 수천만 원 이상 |

## 6. 총평 (Conclusion)

보행 운동학/운동역학은 근골격 시뮬레이션의 **입력이자 검증 기준**이다. 시상면 관절 각도의 높은 반복성(ICC > 0.9)은 모델 튜닝의 신뢰할 수 있는 타겟을 제공하며, 역동역학으로 산출된 관절 모멘트와 파워는 근육 구동 시뮬레이션의 정확도를 3% RMSE 수준에서 검증할 수 있게 한다.

특히 **족관절 push-off가 전체 보행 에너지의 80–85%를 공급**한다는 발견은 보행 보조 로봇(powered ankle-foot orthosis) 설계에서 족관절 액추에이터에 우선순위를 두어야 함을 시사한다. 또한 보행 속도에 대한 모든 매개변수의 비선형 의존성은 시뮬레이션에서 속도 정규화가 필수적임을 강조한다.

IMU와 마커리스 모션캡처(OpenCap 등)의 발전으로 실험실 밖 보행 분석이 가능해지고 있으며, 이는 임상 접근성을 크게 향상시킬 잠재력을 가진다. 근골격 모델링 프로젝트에서 본 주제의 데이터는 **모델 검증, 제어 전략 설계, 병리 보행 시뮬레이션**에 직접 활용 가능하다.

## 7. 참고 문헌 (References)

1. [Biomechanics of Normal Gait](https://now.aapmr.org/biomechanics-normal-gait/) — PM&R KnowledgeNow, 열람 2026-03-19
2. [Effects of walking speed on gait biomechanics: a systematic review and meta-analysis](https://systematicreviewsjournal.biomedcentral.com/articles/10.1186/s13643-019-1063-z) — Fukuchi et al., 2019, 열람 2026-03-19
3. [Biomechanical Analysis of Human Gait When Changing Velocity and Carried Loads: Simulation Study with OpenSim](https://pmc.ncbi.nlm.nih.gov/articles/PMC11118041/) — 2024, 열람 2026-03-19
4. [Full body musculoskeletal model for muscle-driven simulation of human gait](https://pmc.ncbi.nlm.nih.gov/articles/PMC5507211/) — Hamner et al., 2010, 열람 2026-03-19
5. [OpenSim: a musculoskeletal modeling and simulation framework](https://pmc.ncbi.nlm.nih.gov/articles/PMC4397580/) — Seth et al., 2011, 열람 2026-03-19
6. [Biomechanical effects of augmented ankle power output during human walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC6262765/) — Nuckols et al., 2018, 열람 2026-03-19
7. [Five basic muscle activation patterns account for muscle activity during human locomotion](https://pmc.ncbi.nlm.nih.gov/articles/PMC1664897/) — Ivanenko et al., 2004, 열람 2026-03-19
8. [Surface Electromyography Applied to Gait Analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC7502709/) — Papagiannis et al., 2020, 열람 2026-03-19
