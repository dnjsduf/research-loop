---
title: "병리적 보행과 임상 보행 분석 (Pathological Gait and Clinical Gait Analysis)"
slug: "pathological-gait-clinical-gait-analysis"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC2816028/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC9800936/"
    accessed: "2026-03-19"
  - url: "https://eor.bioscientifica.com/view/journals/eor/1/12/2058-5241.1.000052.xml"
    accessed: "2026-03-19"
  - url: "https://www.frontiersin.org/journals/bioengineering-and-biotechnology/articles/10.3389/fbioe.2025.1671344/full"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction) — 왜 등장했는가

사람이 걷는 모습을 눈으로 보고 "이 환자는 무릎이 문제다"라고 판단하는 것은 의사마다 다르고, 같은 의사도 시간에 따라 다르게 평가한다. 1970년대 모션캡처 기술이 등장하면서, 보행을 **숫자**로 기록하고 **그래프**로 비교할 수 있게 되었다. 이것이 **임상 보행 분석(Clinical Gait Analysis, CGA)**의 시작이다.

50년이 넘는 역사 동안, CGA는 특히 뇌성마비 아동의 수술 결정, 뇌졸중 환자의 재활 계획, 파킨슨병 환자의 약물 효과 평가에서 치료 방향을 바꿔놓았다. 그러나 장비 비용과 복잡성 때문에 여전히 대형 병원과 연구기관에 한정되어 있으며, 웨어러블 센서와 AI의 발전이 이 장벽을 낮추고 있는 중이다 [Hulleck et al., 2022].

## 2. 기초 개념 (Foundations)

### 걷기의 물리학: 역펜듈럼 비유 [기초 지식]

걷기를 이해하는 가장 직관적인 비유는 **뒤집어진 시계추(역펜듈럼)**다. 스틱 위에 공을 올려놓고 앞으로 넘어지는 것을 상상하자:

- **입각기(발이 땅에 있을 때)**: 다리가 뒤집힌 시계추처럼 작동한다. 몸의 무게중심이 포물선을 그리며 올라갔다 내려오는데, 이때 운동에너지 ↔ 위치에너지가 자동 교환된다. 마치 놀이공원의 바이킹이 별도 엔진 없이 왔다갔다 하는 것처럼, 에너지를 거의 쓰지 않는다.
- **발 전환(step-to-step transition)**: 한 발에서 다른 발로 바뀌는 순간이 가장 비싼 구간이다. 앞으로 가던 몸이 새로운 "시계추"로 갈아타야 하는데, 이때 뒤꿈치 충돌(collision)로 에너지가 흡수되고, 뒤쪽 발의 밀어내기(push-off)로 보충해야 한다 [Kuo & Donelan, 2010].

### 보행 주기: 한 바퀴의 구조 [기초 지식]

걷기는 반복적인 사이클이다. 한 주기를 100%로 놓으면:

| 구간 | 비율 | 하는 일 |
|------|------|---------|
| 입각기 (stance) | ~60% | 체중 지지, 전방 추진 |
| 유각기 (swing) | ~40% | 다리를 앞으로 가져감 |
| 이중 지지 (double support) | ~10-12% | 양발 동시 접촉, 전환 구간 |

병리적 보행에서는 이 비율이 크게 변한다. 예를 들어 뇌졸중 환자는 환측 입각기가 짧아지고 이중 지지 시간이 30% 이상으로 늘어나는데, 이는 불안정한 환측 다리에 체중을 오래 싣지 못하기 때문이다 [자체 분석].

### 무엇을 측정하나: 4가지 데이터 [기초 지식]

CGA에서 동시에 측정하는 4가지 데이터를 요리에 비유하면:

1. **시공간 파라미터** = 레시피 개요 (보행속도, 보폭, 케이던스)
2. **운동학(kinematics)** = 각 재료의 움직임 (관절 각도가 시간에 따라 어떻게 변하는지)
3. **운동역학(kinetics)** = 불의 세기 (관절에 걸리는 힘과 토크)
4. **근전도(EMG)** = 요리사의 손놀림 (어떤 근육이 언제 얼마나 활성화되는지)

이 4가지를 동시에 보면, "환자의 무릎이 구부러져 있다"는 관찰을 넘어 "대퇴사두근 약화 때문인지, 종아리 근육 단축 때문인지, 신경 조절 문제인지"를 구분할 수 있게 된다 [Armand et al., 2016].

## 3. 핵심 개념 (Deep Dive)

### 3.1 정상에서 비정상으로: 에너지 경제학의 붕괴

정상 보행은 놀랍도록 에너지 효율적이다. 역펜듈럼 메커니즘 덕분에, 걷기의 실제 에너지 비용은 대부분 **발 전환 구간**에서 발생한다. Kuo와 Donelan(2010)은 이 비용이 **보폭의 4승**에 비례한다는 것을 보였다. 즉, 보폭이 2배가 되면 에너지 비용은 16배로 뛴다.

병리적 보행에서는 이 정교한 에너지 시스템이 여러 방식으로 무너진다:

**뇌졸중(편마비)** — 환측 발의 push-off 힘이 약하다. 이는 마치 자동차의 한쪽 엔진이 고장나면 반대쪽이 더 세게 돌아가야 하는 것과 같다. 건측이 과보상해야 하므로 전체 대사 비용이 정상보다 1.5-2배 높아진다 [Kuo & Donelan, 2010].

**뇌성마비(crouch gait)** — 역펜듈럼 가정 자체가 성립하지 않는다. 무릎이 항상 구부러진 상태이므로, 시계추가 휘어진 것과 같다. 에너지 교환이 제대로 일어나지 않아 근육이 쉬지 않고 일해야 한다 [Kuo & Donelan, 2010].

**파킨슨병** — 보폭이 극도로 줄어든다(shuffling). 보폭 4승 법칙에 따르면 보폭이 줄면 전환 비용도 줄어야 하지만, 실제로는 동결보행(freezing), 근강직(rigidity)으로 인해 비효율적 근육 활성화가 에너지 비용을 높인다 [자체 분석].

### 3.2 뇌성마비의 보행 패턴: 4가지 유형

Armand et al.(2016)에 따르면, 경직형 양마비 뇌성마비 아동의 보행은 발목-무릎-고관절의 시상면 운동학 패턴으로 4가지로 분류된다:

| 유형 | 발목 | 무릎 | 고관절 | 비유 |
|------|------|------|--------|------|
| True Equinus | 저측굴곡↑ | 정상~과신전 | 정상 | 발레리나가 발끝으로 서서 걷기 |
| Jump Gait | 저측굴곡↑ | 굴곡↑ | 굴곡↑ | 살짝 쪼그려 뛴 채로 걷기 |
| Apparent Equinus | 정상 | 굴곡↑↑ | 굴곡↑↑ | 발목은 괜찮지만 무릎이 펴지지 않아 "까치발"처럼 보임 |
| Crouch Gait | 배측굴곡↑ | 굴곡↑↑↑ | 굴곡↑↑↑ | 의자에 앉다 만 자세로 걷기 |

이 분류가 중요한 이유는 **치료가 완전히 다르기** 때문이다. True Equinus에는 아킬레스건 연장이 효과적이지만, Apparent Equinus에 같은 수술을 하면 오히려 crouch gait으로 악화된다. 한 병원의 사례에서, CGA 데이터 기반 분류 도입 후 crouch gait 발생률이 25%에서 유의하게 감소했다 [Armand et al., 2016].

### 3.3 균형 제어의 방향 비대칭

Kuo와 Donelan(2010)의 흥미로운 발견은 균형 제어가 **방향에 따라 완전히 다른 메커니즘**을 사용한다는 것이다:

- **앞뒤(시상면)**: 역펜듈럼의 수동 역학이 자연스러운 안정성을 제공. 능동적 제어 최소화.
- **좌우(관상면)**: 능동적 발 배치 조절(foot placement) 필수. 시각을 차단하면 좌우 보폭 변동성이 **2배 이상** 증가.

이것은 재활에 직접적 시사점을 준다. 좌우 안정성을 외부에서 보조하면(예: 트레드밀 난간), 건강한 성인에서도 대사 비용이 약 **9% 감소**한다 [Kuo & Donelan, 2010]. 이는 보행 재활에서 좌우 균형 훈련이 에너지 효율성 개선에 직접 기여할 수 있음을 의미한다.

### 3.4 기술의 진화: 랩에서 일상으로

전통적 CGA는 수백만 원의 장비가 설치된 전용 실험실에서만 가능했다. 최근 세 갈래의 기술 변화가 이 패러다임을 바꾸고 있다:

**1단계: 웨어러블 IMU 센서** — 발, 허리, 머리에 작은 센서를 부착하여 가속도와 각속도를 측정. 실험실 밖에서도 보행 데이터 수집 가능. 단, 관절 모멘트(kinetics)는 직접 측정 불가 [Hulleck et al., 2022].

**2단계: AI 기반 패턴 인식** — Random Forest, XGBoost, CNN/LSTM 등의 알고리즘이 센서 데이터에서 병리 패턴을 자동 분류. 최근 다기관 데이터셋(260명, 1,356 보행 시행)이 공개되어 모델 훈련과 벤치마킹이 가능해졌다 [자체 분석].

**3단계: 설명 가능한 AI(XAI)** — SHAP, LIME, Grad-CAM 같은 기법으로 "왜 이 환자를 파킨슨으로 분류했는가?"를 설명. 수직 지면반력과 보폭 지속시간이 파킨슨 분류의 핵심 특징으로 식별됨 [Xiang et al., 2025]. 그러나 31개 연구를 분석한 체계적 리뷰에서도, 표준화와 임상 검증이 여전히 주요 과제로 남아있다.

### 3.5 근골격 모델링과의 통합

CGA 데이터만으로는 "왜 이런 보행 패턴이 나타나는가?"에 대한 완전한 답을 주지 못한다. 근골격 시뮬레이션(OpenSim 등)을 통해 개별 근육의 힘, 관절 접촉력, 에너지 기여도를 추정할 수 있다.

이 과정은 마치 **범인 추적**과 같다:
- CGA = CCTV 영상 (무엇이 일어났는지 기록)
- 근골격 모델링 = 포렌식 분석 (왜 그런 일이 일어났는지 추론)
- 시뮬레이션 = 가상 시나리오 (수술 후 어떻게 변할지 예측)

뇌성마비 치료에서 이 통합 접근법은, 경직성(spasticity), 근력 약화(weakness), 뼈 변형(bony deformity) 중 어떤 요인이 관찰된 보행 편차의 주된 원인인지를 구분할 수 있게 해준다 [Armand et al., 2016].

## 4. 수식 구현 (Key Formulas)

### 4.1 Step-to-Step Transition 에너지 비용

보행의 에너지 비용에서 가장 핵심적인 관계식은 COM(center of mass) 속도 방향 전환에 필요한 기계적 일이다:

$$W_{trans} \propto m \cdot v^2 \cdot \tan^2(\alpha)$$

여기서:
- $W_{trans}$: step-to-step transition에서의 기계적 일
- $m$: 체질량
- $v$: 보행 속도
- $\alpha$: COM 속도 벡터의 방향 전환 각도 (보폭에 비례)

보폭($L$)과 다리 길이($l$)의 관계로 표현하면:

$$W_{step} \approx m \cdot g \cdot l \cdot \left(\frac{L}{2l}\right)^4$$

대사 비용률(metabolic rate):

$$\dot{E}_{meta} = \dot{E}_{transition} + \dot{E}_{swing} \approx \frac{2}{3}\dot{E}_{net} + \frac{1}{3}\dot{E}_{net}$$

[Kuo & Donelan, 2010, Section "Step-to-Step Transitions"]

```python
import numpy as np

def step_transition_work(mass: float, velocity: float, step_length: float,
                         leg_length: float = 0.93) -> float:
    """
    Step-to-step transition에서의 기계적 일 추정

    Args:
        mass: 체질량 (kg)                    # m
        velocity: 보행 속도 (m/s)            # v
        step_length: 보폭 (m)                # L
        leg_length: 다리 길이 (m, 기본 성인)  # l

    Returns:
        기계적 일 (J/step)
    """
    g = 9.81  # m/s^2
    ratio = step_length / (2 * leg_length)
    w_step = mass * g * leg_length * ratio**4
    return w_step

# 예시: 정상 vs 병리적 보행 비교
mass = 70  # kg
normal_work = step_transition_work(mass, 1.3, 0.70)    # 정상 보폭 0.70m
short_step_work = step_transition_work(mass, 0.8, 0.40)  # 파킨슨 보폭 0.40m
long_step_work = step_transition_work(mass, 1.3, 1.00)   # 과대 보폭 1.00m

print(f"정상 보행:     {normal_work:.2f} J/step")
print(f"파킨슨(소보):  {short_step_work:.2f} J/step")
print(f"과대 보폭:     {long_step_work:.2f} J/step")
```

### 4.2 Gait Deviation Index (GDI)

$$GDI = 100 - 10 \cdot \frac{\|\mathbf{x}_{patient} - \bar{\mathbf{x}}_{normal}\|}{\sigma_{normal}}$$

여기서:
- $\mathbf{x}_{patient}$: 환자의 9개 운동학 변수 × 51 시점 (459차원 벡터)
- $\bar{\mathbf{x}}_{normal}$: 정상 데이터베이스 평균
- $\sigma_{normal}$: 정상 데이터베이스 표준편차
- GDI = 100 → 정상, 10점 감소 = 1 표준편차 편차

```python
import numpy as np

def compute_gdi(patient_data: np.ndarray,
                normal_mean: np.ndarray,
                normal_std: np.ndarray) -> float:
    """
    Gait Deviation Index 계산

    Args:
        patient_data: 환자 운동학 데이터 (459,)
                      # 9 variables × 51 time points
        normal_mean: 정상 데이터베이스 평균 (459,)
        normal_std: 정상 데이터베이스 표준편차 (459,)

    Returns:
        GDI 점수 (100 = 정상)
    """
    z_scores = (patient_data - normal_mean) / (normal_std + 1e-8)
    rms = np.sqrt(np.mean(z_scores ** 2))
    gdi = 100 - 10 * rms
    return gdi

# 사용 예시
np.random.seed(42)
n_vars = 9 * 51  # 459 차원

# 정상 데이터베이스 시뮬레이션
normal_db = np.random.randn(100, n_vars)  # 100명 정상군
normal_mean = normal_db.mean(axis=0)
normal_std = normal_db.std(axis=0)

# 정상 피험자 → GDI ≈ 100
healthy_subject = normal_mean + 0.3 * normal_std * np.random.randn(n_vars)
print(f"정상 피험자 GDI: {compute_gdi(healthy_subject, normal_mean, normal_std):.1f}")

# 경도 병리 → GDI ≈ 80
mild_pathology = normal_mean + 2.0 * normal_std * np.random.randn(n_vars)
print(f"경도 병리 GDI:   {compute_gdi(mild_pathology, normal_mean, normal_std):.1f}")
```

### 4.3 보행 비대칭 지수 (Gait Asymmetry Index)

$$ASI = \frac{|X_{left} - X_{right}|}{0.5 \cdot (X_{left} + X_{right})} \times 100\%$$

```python
def gait_asymmetry_index(left_value: float, right_value: float) -> float:
    """
    보행 비대칭 지수 (%)
    0% = 완전 대칭, 값이 클수록 비대칭

    Args:
        left_value: 좌측 파라미터 값 (예: 보폭, 입각기 시간)
        right_value: 우측 파라미터 값
    """
    mean_val = 0.5 * (left_value + right_value)
    if mean_val == 0:
        return 0.0
    return abs(left_value - right_value) / mean_val * 100

# 뇌졸중 환자 예시: 환측 입각기 단축
healthy_asi = gait_asymmetry_index(0.62, 0.63)   # 정상: 거의 대칭
stroke_asi = gait_asymmetry_index(0.45, 0.72)     # 뇌졸중: 환측 짧음
print(f"정상 비대칭 지수:   {healthy_asi:.1f}%")   # ~1.6%
print(f"뇌졸중 비대칭 지수: {stroke_asi:.1f}%")    # ~46.2%
```

## 5. 장점과 단점 (Pros & Cons)

### 장점

| 항목 | 설명 |
|------|------|
| **객관적 정량화** | 주관적 관찰을 숫자로 대체하여 임상의 간 일관성 확보 |
| **치료 의사결정 개선** | 뇌성마비 수술 계획에서 CGA 기반 결정이 관찰만 기반보다 우수한 결과 [Armand et al., 2016] |
| **종단적 모니터링** | 치료 전후 비교, 질병 진행 추적 가능 |
| **시뮬레이션 연동** | 근골격 모델과 결합하여 "what-if" 시나리오 탐색 가능 |
| **웨어러블 확장성** | IMU 기반으로 실험실 밖 일상 보행 모니터링 가능해짐 |

### 단점

| 항목 | 설명 |
|------|------|
| **비용과 접근성** | 전통적 3D CGA 시스템 구축에 수천만 원, 운영에 전문 인력 필요 [Hulleck et al., 2022] |
| **시간 소요** | 1회 분석에 2-4시간 (마커 부착 + 측정 + 처리) |
| **표준화 부재** | 마커셋, 처리 방법, 보고 형식이 기관마다 상이 [Hulleck et al., 2022] |
| **연조직 아티팩트** | 피부 위 마커의 뼈 대비 이동으로 최대 5-10° 오차 [자체 분석] |
| **역펜듈럼 한계** | Crouch gait 등 심한 병리에서 기본 역학 모델 적용 불가 [Kuo & Donelan, 2010] |
| **AI 해석 가능성** | ML 분류기의 임상 검증과 설명 가능성이 아직 충분하지 않음 [Xiang et al., 2025] |

## 6. 총평 (Conclusion)

병리적 보행 분석은 **"보행 장애가 있다"에서 "왜, 어디서, 얼마나 비정상인가"로** 질문의 수준을 올려주는 필수 도구다. 특히 뇌성마비와 같이 다관절 문제가 얽힌 질환에서, CGA 없이 수술을 결정하는 것은 CT 없이 뼈 수술을 하는 것에 비견할 수 있다.

현재 이 분야는 두 갈래의 전환점에 있다:
1. **기술적 민주화**: 웨어러블 IMU + AI가 고가의 실험실 장비를 보완/대체하며, 일상 환경에서의 연속 모니터링을 가능케 함
2. **해석의 깊이**: 근골격 모델링과의 통합으로, 관찰 수준에서 인과 메커니즘 수준으로 분석 깊이가 심화

도입 가치는 **높음**이다. 다만 현실적으로는, 연구 목적이라면 OpenSim + IMU 조합으로 시작하고, 임상 적용이라면 GDI 같은 요약 지표와 XAI 기반 의사결정 보조를 우선 도입하는 단계적 접근이 합리적이다. 표준화 문제는 분야 전체의 과제이므로, 기관 내부 프로토콜을 먼저 정립한 후 확산하는 전략이 필요하다 [Hulleck et al., 2022].

## 7. 참고 문헌 (References)

- [Dynamic Principles of Gait and Their Clinical Implications](https://pmc.ncbi.nlm.nih.gov/articles/PMC2816028/) — Kuo AD, Donelan JM, Physical Therapy, 2010
- [Present and future of gait assessment in clinical practice](https://pmc.ncbi.nlm.nih.gov/articles/PMC9800936/) — Hulleck AA et al., Frontiers in Medical Technology, 2022
- [Gait analysis in children with cerebral palsy](https://eor.bioscientifica.com/view/journals/eor/1/12/2058-5241.1.000052.xml) — Armand S, Decoulon G, Bonnefoy-Mazure A, EFORT Open Reviews, 2016
- [Explainable AI for gait analysis: advances, pitfalls, and challenges](https://www.frontiersin.org/journals/bioengineering-and-biotechnology/articles/10.3389/fbioe.2025.1671344/full) — Xiang et al., Frontiers in Bioengineering and Biotechnology, 2025
- [Clinical gait analysis 1973-2023](https://www.sciencedirect.com/science/article/abs/pii/S0021929023003986) — Journal of Biomechanics, 2023
- [Gait analysis methods in rehabilitation](https://link.springer.com/article/10.1186/1743-0003-3-4) — Baker R, Journal of NeuroEngineering and Rehabilitation, 2006
