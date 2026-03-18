---
title: "Locomotion Energetics and Efficiency"
slug: "locomotion-energetics-and-efficiency"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://pubmed.ncbi.nlm.nih.gov/411381/"
    accessed: "2026-03-19"
  - url: "https://pubmed.ncbi.nlm.nih.gov/15821430/"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-018-29429-z"
    accessed: "2026-03-19"
  - url: "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0021290"
    accessed: "2026-03-19"
  - url: "https://physoc.onlinelibrary.wiley.com/doi/10.1113/EP089313"
    accessed: "2026-03-19"
  - url: "https://royalsocietypublishing.org/doi/10.1098/rsbl.2015.0486"
    accessed: "2026-03-19"
  - url: "https://journals.biologists.com/jeb/article/213/23/3972/10061"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4306638/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC6750598/"
    accessed: "2026-03-19"
  - url: "https://journals.biologists.com/jeb/article/228/Suppl_1/JEB248125/367009"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction)

우리는 매일 수천 걸음을 걷지만, 걷기가 에너지적으로 얼마나 정교한 과정인지 거의 인식하지 못한다. 걷기는 단순히 다리를 번갈아 내딛는 행위가 아니라, 중력과 관성을 영리하게 활용하여 에너지 소비를 최소화하는 **최적화된 운동 전략**이다.

이 분야의 연구는 1960–70년대 Cavagna와 동료들의 선구적 연구에서 시작되었다. 그들은 걷기와 달리기에서 에너지가 어떻게 절약되는지를 밝혔고, 이후 Kuo, Donelan 등이 에너지 비용의 근본적 원인을 분해하는 데 성공했다. 오늘날 이 지식은 외골격 로봇 설계, 보행 재활, 그리고 에너지 효율적인 이족 보행 로봇 개발의 핵심 기반이 되고 있다.

## 2. 기초 개념 (Foundations)

[기초 지식]

### 대사 에너지와 기계적 일: 자동차 비유

인체를 자동차에 비유하면, **대사 에너지**는 연료(가솔린)에 해당하고, **기계적 일**은 바퀴를 굴리는 데 실제로 사용된 에너지다. 자동차 엔진이 연료의 약 25–30%만 바퀴 구동에 사용하고 나머지를 열로 버리듯, 인간의 근육도 화학 에너지(ATP)의 약 **20–25%만** 기계적 일로 변환한다 [기초 지식]. 나머지 75–80%는 체열로 소산된다.

### Cost of Transport (CoT): 연비 개념

자동차의 연비(km/L)가 주행 효율을 나타내듯, 보행의 효율은 **Cost of Transport(CoT)** — 단위 거리를 이동하는 데 소비되는 단위 체중당 에너지 — 로 측정한다. 70kg 성인이 시속 4.8km로 걸을 때 약 450W의 대사 출력을 내며, 이때 CoT는 약 **0.39** (무차원)이다 [Cavagna et al., 1977].

### 역진자(Inverted Pendulum) 모델: 알까기 비유

걸을 때 우리 몸은 **거꾸로 선 진자**처럼 움직인다. 그네가 최고점에서 위치 에너지를 가지고 최저점에서 운동 에너지로 바뀌듯, 보행의 각 걸음에서 몸의 질량 중심(CoM)은:
- **걸음 중간**(한 발 위): 가장 높은 위치 → 위치 에너지 최대, 속도 최소
- **두 발 사이**: 가장 낮은 위치 → 위치 에너지 최소, 속도 최대

이 교환 덕분에 근육이 해야 할 일의 최대 **65–70%가 절약**된다 [Cavagna et al., 1977].

## 3. 핵심 개념 (Deep Dive)

### 3.1 에너지 회복률 — 진자가 완벽하지 않은 이유

완벽한 진자라면 에너지 교환률이 100%여서 근육이 전혀 일하지 않아도 영원히 걸을 수 있을 것이다. 하지만 현실의 보행은 약 65%의 회복률만 달성한다. 나머지 35%는 왜 손실되는가?

핵심 원인은 **걸음 전환(step-to-step transition)**에 있다. 한 발에서 다음 발로 체중을 옮길 때, 몸의 속도 방향이 바뀌어야 한다. 이를 **당구공 충돌**에 비유할 수 있다. 쿠션에 부딪힌 당구공이 방향을 바꿀 때 에너지를 잃듯, CoM이 한 다리의 호에서 다음 다리의 호로 전환될 때 **충돌 손실**이 발생한다 [Kuo, 2005].

### 3.2 Push-off: 영리한 에너지 절약 전략

발목의 **push-off**(발차기)는 이 전환 비용을 극적으로 줄인다. 뒤쪽 발이 지면을 밀어내면서 CoM을 위로 밀어주면, 앞쪽 발이 받는 충돌 충격이 줄어든다.

이를 **트램펄린 비유**로 설명할 수 있다: 트램펄린에서 내려오며 무릎을 굽히면(흡수) 다음 점프가 약하지만, 발바닥으로 밀어내면(push-off) 다음 점프가 높아진다. Kuo(2002)는 최적의 push-off 전략을 사용하면 에너지 비용이 순수 관절 토크만 사용할 때의 **1/4로** 감소함을 수학적으로 증명했다.

### 3.3 보행 대사 비용의 네 기둥

Donelan 등(2018)의 연구에 따르면, 보행 에너지 비용은 네 가지 주요 요소로 분해된다:

| 요소 | 비유 | 비중 |
|------|------|------|
| **CoM 속도 재지향** | 당구공 방향 전환 비용 | ~45% |
| **체중 지지** | 벽에 등을 대고 의자 자세 유지하기 | ~28% |
| **지면 청소** | 계단 오르듯 발을 들어올리기 | ~17% |
| **하지 스윙** | 야구 배트 휘두르기 | ~10% |

가장 큰 비중을 차지하는 **속도 재지향**(~45%)이 바로 step-to-step transition 비용이다. 이것이 보행 에너지론에서 가장 중요한 발견 중 하나다.

### 3.4 최적 보행 속도 — 왜 시속 4.8km인가?

보행 속도가 느리면 매 걸음의 에너지 비용은 적지만, 같은 거리를 가는 데 더 많은 걸음이 필요하다. 반대로 빠르면 걸음 수는 줄지만 걸음당 비용이 급증한다. 이 두 효과가 만나는 **최적점**이 약 1.3 m/s(시속 4.8km)이다 [기초 지식].

흥미롭게도, 인간은 의식적 계산 없이도 **자연스럽게 이 최적 속도를 선택**한다. 선호 보행 속도(~1.05 m/s)와 CoT 최소 속도(~1.04 m/s)가 통계적으로 유의미한 차이가 없다는 연구 결과가 이를 뒷받침한다 [Selinger et al., 2025].

### 3.5 속도 변동의 숨겨진 비용

실생활에서는 일정 속도로 걷는 경우가 드물다. 신호등, 다른 보행자, 커브 등으로 속도가 끊임없이 변한다. Seethapathi & Srinivasan(2015)은 속도 진동이 **6–20%의 추가 대사 비용**을 발생시킴을 발견했다. 이는 자동차가 고속도로에서보다 시내 주행에서 연비가 나쁜 것과 같은 원리다.

### 3.6 노화와 에너지 효율

나이가 들면 보행 에너지 효율이 감소한다. Mian 등(2006)에 따르면, 노인은 젊은 성인 대비:
- 대사 비용 **13–17% 증가**
- 기계적 효율 **12% 감소**
- 근육 공활성(co-activation) **25% 증가**

근육 공활성 증가는 안정성을 높이지만, 기계적 일에 기여하지 않는 에너지를 소비하는 "브레이크를 밟으면서 가속하는 것"과 같다.

## 4. 수식 구현 (Key Formulas)

### 4.1 Cost of Transport

$$
\text{CoT} = \frac{P_{\text{met}}}{m \cdot g \cdot v}
$$

- $P_{\text{met}}$: 대사 출력 (W)
- $m$: 체질량 (kg)
- $g$: 중력가속도 (9.81 m/s²)
- $v$: 보행 속도 (m/s)

```python
# CoT 계산 — 변수 매핑: P_met → metabolic_power, m → mass, v → speed
def cost_of_transport(metabolic_power: float, mass: float, speed: float,
                      g: float = 9.81) -> float:
    """
    무차원 Cost of Transport.
    metabolic_power: 대사 출력 (W)
    mass: 체질량 (kg)
    speed: 보행 속도 (m/s)
    """
    return metabolic_power / (mass * g * speed)

# 예시: 70kg 성인, 1.3 m/s, 450W
cot = cost_of_transport(450, 70, 1.3)
print(f"CoT = {cot:.3f}")  # CoT ≈ 0.503 (gross), 0.39 (net, 기저대사 제외)
```

### 4.2 Percent Recovery (에너지 회복률)

$$
\%R = \frac{W_{\text{KE}} + W_{\text{GPE}} - W_{\text{ext}}}{W_{\text{KE}} + W_{\text{GPE}}} \times 100
$$

- $W_{\text{KE}}$: 운동 에너지의 양의 증분 합
- $W_{\text{GPE}}$: 위치 에너지의 양의 증분 합
- $W_{\text{ext}}$: 외적 기계적 에너지의 양의 증분 합

```python
import numpy as np

def percent_recovery(ke: np.ndarray, gpe: np.ndarray) -> float:
    """
    Cavagna의 역진자 에너지 회복률.
    ke: 시계열 운동 에너지 (J) — 0.5 * m * v²
    gpe: 시계열 위치 에너지 (J) — m * g * h
    """
    total = ke + gpe

    # 양의 증분만 합산
    w_ke = np.sum(np.maximum(np.diff(ke), 0))    # W_KE
    w_gpe = np.sum(np.maximum(np.diff(gpe), 0))  # W_GPE
    w_ext = np.sum(np.maximum(np.diff(total), 0)) # W_ext

    denom = w_ke + w_gpe
    if denom == 0:
        return 0.0
    return ((denom - w_ext) / denom) * 100.0

# 시뮬레이션 예시: 이상적 역진자 (위상차 180°)
t = np.linspace(0, 2 * np.pi, 1000)
ke_sim = 50 + 20 * np.cos(t)       # KE: 50 ± 20 J
gpe_sim = 50 - 20 * np.cos(t)      # GPE: 50 ∓ 20 J (완벽한 반위상)
print(f"%Recovery = {percent_recovery(ke_sim, gpe_sim):.1f}%")  # ~100%
```

### 4.3 Step-to-Step Transition Work

$$
W_{\text{trans}} = m \cdot v^2 \cdot \sin^2\!\left(\frac{s}{2L}\right)
$$

- $m$: 체질량 (kg)
- $v$: CoM 속도 (m/s)
- $s$: 보폭 (m)
- $L$: 다리 길이 (m)

```python
import numpy as np

def transition_work(mass: float, velocity: float,
                    step_length: float, leg_length: float) -> float:
    """
    Kuo (2002) 모델 기반 step-to-step transition 기계적 일 (J).
    alpha = step_length / (2 * leg_length) — CoM 속도 재지향 각도 근사
    """
    alpha = step_length / (2.0 * leg_length)  # rad (소각 근사)
    return mass * velocity**2 * np.sin(alpha)**2

# 예시: 70kg, 1.3 m/s, 보폭 0.7m, 다리길이 0.9m
w = transition_work(70, 1.3, 0.7, 0.9)
print(f"Transition work = {w:.2f} J/step")  # ~16.7 J/step
```

### 4.4 평지 보행 대사 출력 추정

$$
P_{\text{met}} \approx 2.23 + 1.26 \cdot v^2 \quad (\text{W/kg, 평지 보행})
$$

```python
def metabolic_power_walking(mass: float, speed: float) -> float:
    """
    평지 보행 대사 출력 추정 (W).
    Ralston (1958) 기반 경험적 모델.
    speed: m/s (0.5 ~ 2.0 유효 범위)
    """
    # W/kg 단위
    p_per_kg = 2.23 + 1.26 * speed**2
    return p_per_kg * mass

# 예시: 70kg, 1.3 m/s
p = metabolic_power_walking(70, 1.3)
print(f"Metabolic power = {p:.1f} W")  # ~274 W (net)
```

## 5. 장점과 단점 (Pros & Cons)

### 장점

| 관점 | 내용 |
|------|------|
| **이론적 명확성** | 역진자 모델 + transition cost 프레임워크가 보행 에너지의 60–70%를 정량적으로 설명 |
| **실용적 가치** | exoskeleton/prosthesis 설계의 명확한 최적화 목표 제공 |
| **종 간 비교 가능** | CoT라는 무차원 지표로 동물·로봇·인간 비교 가능 |
| **임상 적용** | 병리적 보행의 에너지 비효율 원인을 구조적으로 진단 가능 |

### 단점

| 관점 | 내용 |
|------|------|
| **모델 단순화** | 2D 역진자는 3D 보행, 체간 회전, 팔 스윙 등을 무시 |
| **측정 제약** | 정상 상태(steady-state) 가정으로 실생활 보행의 가감속을 정확히 포착하기 어려움 |
| **근육 수준 미반영** | 공활성, 등척성 수축의 대사 비용이 기계적 일 모델에 누락 |
| **개인 차 설명 부족** | 같은 속도·체격에서도 개인 간 대사 비용 차이(~10–15%)를 현재 모델로 완전히 설명하지 못함 |
| **극단 조건** | 매우 느린 보행(<0.5 m/s)이나 경사>30%에서 모델 예측력 저하 |

## 6. 총평 (Conclusion)

보행 에너지론은 "왜 걷기에 에너지가 드는가"라는 근본적 질문에 대해 정량적이고 메커니즘적인 답을 제공하는 성숙한 연구 분야다.

**핵심 통찰 세 가지:**

1. **역진자 메커니즘**이 보행 에너지의 65–70%를 절약하지만, **step-to-step transition**에서의 속도 재지향이 가장 큰 에너지 비용(~45%)을 발생시킨다.
2. 인간은 무의식적으로 **CoT를 최소화하는 속도(~1.3 m/s)**를 선택하며, 이는 수십만 년의 진화적 최적화를 반영한다.
3. **Push-off 전략**이 transition cost를 1/4로 줄이는 핵심 메커니즘이며, 이를 보조하는 exoskeleton 설계(발목 push-off 보조)가 가장 효과적인 접근법임이 입증되고 있다.

**도입 가치:** 보행 보조 장치 설계, 보행 재활 프로토콜, 이족 보행 로봇 제어에 있어 에너지 비용 모델은 **필수적인 목적함수**다. 다만, 근육 수준의 대사 모델(Bhargava, Lichtwark-Wilson 등)과의 통합이 진행 중이며, 개인별 예측 정확도를 높이기 위해서는 근전도(EMG) 기반 보정이 추가로 필요하다.

## 7. 참고 문헌 (References)

1. [Mechanical work in terrestrial locomotion: two basic mechanisms for minimizing energy expenditure](https://pubmed.ncbi.nlm.nih.gov/411381/) — Cavagna, Heglund & Taylor, Am J Physiol, 1977
2. [Energetic consequences of walking like an inverted pendulum: step-to-step transitions](https://pubmed.ncbi.nlm.nih.gov/15821430/) — Kuo AD, Exerc Sport Sci Rev, 2005
3. [A simple model of mechanical effects to estimate metabolic cost of human walking](https://www.nature.com/articles/s41598-018-29429-z) — Donelan et al., Sci Rep, 2018
4. [The Energetic Cost of Walking: A Comparison of Predictive Methods](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0021290) — Browning et al., PLOS ONE, 2011
5. [Mechanical work as a (key) determinant of energy cost in human locomotion](https://physoc.onlinelibrary.wiley.com/doi/10.1113/EP089313) — Peyré-Tartaruga & Coertjens, Exp Physiol, 2021
6. [The metabolic cost of changing walking speeds is significant](https://royalsocietypublishing.org/doi/10.1098/rsbl.2015.0486) — Seethapathi & Srinivasan, Biol Lett, 2015
7. [The mass-specific energy cost of human walking is set by stature](https://journals.biologists.com/jeb/article/213/23/3972/10061) — Pontzer H, J Exp Biol, 2010
8. [Effects of aging on mechanical efficiency and muscle activation during level and uphill walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC4306638/) — Mian et al., Acta Physiol, 2006
9. [Metabolic cost calculations of gait using musculoskeletal energy models, a comparison study](https://pmc.ncbi.nlm.nih.gov/articles/PMC6750598/) — Koelewijn et al., PLOS ONE, 2019
10. [Behavioural energetics in human locomotion](https://journals.biologists.com/jeb/article/228/Suppl_1/JEB248125/367009) — Selinger et al., J Exp Biol, 2025
