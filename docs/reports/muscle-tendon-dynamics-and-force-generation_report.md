---
title: "Muscle-Tendon Dynamics and Force Generation"
slug: "muscle-tendon-dynamics-and-force-generation"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://www.biorxiv.org/content/10.1101/2022.10.14.512218v2.full"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC6514471/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC3656509/"
    accessed: "2026-03-19"
  - url: "https://royalsocietypublishing.org/doi/10.1098/rsif.2022.0430"
    accessed: "2026-03-19"
  - url: "https://www.pnas.org/doi/10.1073/pnas.0709212105"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC6061994/"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-023-33643-9"
    accessed: "2026-03-19"
  - url: "https://www.sciencedirect.com/science/article/pii/S0021929023001549"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction) — 왜 등장했는가

인간이 걷고, 뛰고, 물건을 잡는 모든 동작 뒤에는 근육과 건(힘줄)이라는 '엔진과 전동벨트'가 있다. 1930년대 영국의 생리학자 A.V. Hill은 근육이 얼마나 빨리 줄어드느냐에 따라 낼 수 있는 힘이 달라진다는 것을 발견하고, 이를 간단한 수학 모델로 정리했다. 이 모델은 이후 90년간 바이오역학, 재활공학, 로봇공학의 기본 도구로 발전해왔다 [Caillet et al., 2022].

현대에 이 모델이 중요한 이유는 명확하다: 살아있는 사람의 근육 힘을 직접 측정하는 것은 침습적이고 위험하다. 대신 수학적 모델을 통해 관절 운동과 근전도(EMG) 신호로부터 근력을 **추정**할 수 있다. 이는 재활 프로그램 설계, 수술 계획, 외골격 로봇 제어, 스포츠 성능 최적화 등에 직접 활용된다 [Seth et al., 2018].

## 2. 기초 개념 (Foundations)

### 사르코미어: 근육의 '피스톤'

근육 속에는 수천 개의 미세한 수축 단위인 **사르코미어(sarcomere)**가 직렬로 연결되어 있다. 이것은 마치 엔진의 피스톤과 같다. 사르코미어 안에서 **액틴(가는 필라멘트)**과 **마이오신(굵은 필라멘트)**이라는 두 종류의 단백질 끈이 서로 맞물려 미끄러지며(sliding) 힘을 만든다. [기초 지식]

비유하면: 양손으로 각각 빗을 잡고 이빨을 맞물린 상태에서 서로 당기는 것과 같다. 이빨이 많이 겹칠수록(최적 길이) 더 강하게 당길 수 있고, 너무 벌어지거나 너무 겹치면 힘이 약해진다.

### 건(腱): 스프링 같은 '전동벨트'

**건(tendon)**은 근육을 뼈에 연결하는 강인한 섬유 조직이다. 단순한 연결끈이 아니라 **에너지를 저장하고 반환하는 스프링** 역할을 한다. 걸을 때 아킬레스건은 체중의 충격을 흡수했다가 발을 밀어내는 데 그 에너지를 돌려준다. 건의 에너지 저장 능력은 근섬유 교차결합의 35~70배에 달한다 [Roberts & Azizi, 2011]. [기초 지식]

### 근건 단위(MTU): 엔진 + 전동벨트 시스템

근육(엔진)과 건(전동벨트)이 하나로 연결된 것을 **근건 단위(Muscle-Tendon Unit)**라 한다. 이 둘은 직렬로 연결되어 있으므로, 근육이 내는 힘과 건이 전달하는 힘은 항상 같아야 한다(평형 조건). 이 간단한 제약이 전체 모델의 핵심이다. [기초 지식]

### 활성화 과정: 뇌에서 근육까지의 '명령 전달'

뇌에서 "움직여!"라는 명령은 전기 신호(활동전위)로 척수를 타고 내려가 근섬유에 도달한다. 신경 끝에서 아세틸콜린이 방출되고, 이것이 방아쇠가 되어 근섬유 내부에 칼슘 이온(Ca²⁺)이 쏟아져 나온다. 칼슘이 트로포닌에 결합하면 액틴-마이오신 교차결합이 형성되어 힘이 발생한다. 마치 자동차의 시동 키(신경 신호) → 연료 분사(Ca²⁺) → 엔진 점화(교차결합)의 연쇄반응과 같다 [Rios et al., 2020]. [기초 지식]

## 3. 핵심 개념 (Deep Dive)

### 세 가지 근본 법칙: 근육이 힘을 내는 규칙

근육의 힘 출력은 세 가지 독립적인 관계에 의해 결정된다. 이 세 관계를 곱하면 최종 힘이 나온다.

#### 법칙 1: Force-Length — "최적 길이가 있다"

줄다리기를 상상해보자. 줄을 잡은 사람들이 최적의 간격으로 서 있을 때 가장 세게 당길 수 있다. 너무 다닥다닥 붙으면 서로 방해되고, 너무 멀리 떨어지면 줄을 잡을 수 없다.

사르코미어도 마찬가지다. 최적 길이에서 액틴-마이오신 중첩이 최대가 되어 $f_L = 1.0$(100% 힘)을 낸다. 이보다 짧거나 길면 힘이 줄어든다. 이 관계는 종 모양(bell-shaped) 곡선을 그린다 [Arnold et al., 2013].

#### 법칙 2: Force-Velocity — "천천히 들수록 무겁게"

헬스장에서 역기를 천천히 드는 것과 빨리 드는 것의 차이를 생각해보자. 천천히 들면(속도 낮음) 더 무거운 무게를 들 수 있고, 빨리 움직이려 하면 들 수 있는 무게가 줄어든다. 이것이 Hill의 쌍곡선 관계다.

반대로 **신장성 수축**(eccentric) — 역기가 내려오는 것을 버티는 동작 — 에서는 빠르게 늘어날수록 오히려 더 큰 힘(최대 ~1.8배)을 낼 수 있다. 이는 교차결합의 기계적 저항 때문이다 [Alcazar et al., 2019].

#### 법칙 3: Activation Dynamics — "명령과 실행 사이의 지연"

운전대를 돌리면 차가 즉시 방향을 바꾸지 않듯, 신경 명령에서 근육 힘까지는 시간 지연이 있다. 활성화(켜기)에 약 10~20ms, 비활성화(끄기)에 약 40~60ms 걸린다. 끄는 것이 켜는 것보다 2~3배 느리다 — 마치 형광등이 꺼질 때 잠시 깜빡이는 것처럼.

### 건의 스프링 효과: "에너지 재활용 시스템"

건이 단순한 밧줄이 아니라 스프링이라는 점이 핵심이다. 달리기를 예로 들면:

1. **착지** 시: 건이 늘어나며 충격 에너지를 저장 (마치 스프링을 누르는 것)
2. **도약** 시: 건이 되튕기며(recoil) 저장된 에너지를 방출

이 메커니즘 덕분에 근섬유는 실제보다 느린 속도로 작동할 수 있고(force-velocity 관계에서 유리), 대사 에너지도 절약된다. 캥거루가 거의 피로 없이 뛸 수 있는 비밀이 바로 이 건 탄성이다 [Roberts & Azizi, 2011].

### 근육 기어링: "자동 변속기"

자동차의 기어가 바퀴 속도와 엔진 속도를 조절하듯, **우상근(pennate muscle)**은 근섬유의 배열 각도(pennation angle)를 변화시켜 자동으로 '변속'한다.

- **저부하 고속 동작** (예: 빈손 휘두르기): 근섬유가 회전하며 근육 속도를 약 40% 증폭 (AGR ≈ 1.4)
- **고부하 저속 동작** (예: 무거운 물건 들기): 기어비가 1:1로 떨어지며 힘 전달에 집중

이 가변 기어링은 근육이 다양한 과제에 자동으로 적응하는 놀라운 설계다 [Azizi et al., 2008].

## 4. 수식 구현 (Key Formulas)

### 수식 1: Hill의 Force-Velocity 방정식

$$\frac{F - F_0}{F + a} = \frac{-v \cdot b}{v + b}$$

또는 등가 형태:

$$(F + a)(v + b) = (F_0 + a) \cdot b$$

| 변수 | 의미 | 단위 |
|------|------|------|
| $F$ | 근섬유가 내는 힘 | N |
| $F_0$ | 최대 등척성 힘 (velocity=0) | N |
| $v$ | 수축 속도 (단축: 양수) | m/s |
| $a, b$ | 형상 파라미터 (근육 특성에 따라 결정) | N, m/s |

```python
import numpy as np

def hill_force_velocity(v: float, F0: float, a: float, b: float) -> float:
    """
    Hill's hyperbolic force-velocity equation.

    Args:
        v:  shortening velocity (positive = concentric) [m/s]
        F0: peak isometric force [N]
        a:  shape parameter [N] (typically ~0.25 * F0)
        b:  shape parameter [m/s] (typically ~0.25 * v_max)
    Returns:
        Force [N]
    """
    # F = (F0 * b - a * v) / (v + b)
    return (F0 * b - a * v) / (v + b)

# 예시: F0=1000 N, a=250 N, b=2.5 m/s
velocities = np.linspace(0, 10, 50)  # 0 ~ v_max
forces = [hill_force_velocity(v, 1000, 250, 2.5) for v in velocities]
```

### 수식 2: 정규화된 MTU 힘 방정식

$$F_{MTU} = \left[ a(t) \cdot f_L(\tilde{l}^M) \cdot f_V(\tilde{v}^M) + f_{PE}(\tilde{l}^M) \right] \cdot F_0^M \cdot \cos\alpha$$

| 변수 | 의미 |
|------|------|
| $a(t)$ | 활성화 수준 (0~1) |
| $f_L$ | 정규화 force-length 곡선 |
| $f_V$ | 정규화 force-velocity 곡선 |
| $f_{PE}$ | 정규화 수동 탄성 힘 |
| $F_0^M$ | 최대 등척성 힘 |
| $\alpha$ | 우각 (pennation angle) |
| $\tilde{l}^M, \tilde{v}^M$ | 정규화된 근섬유 길이, 속도 |

```python
import numpy as np

def normalized_mtu_force(
    activation: float,
    lM_norm: float,        # l_M / l_M_opt
    vM_norm: float,        # v_M / v_max
    F0: float = 1000.0,    # peak isometric force [N]
    alpha: float = 0.0     # pennation angle [rad]
) -> float:
    """
    Compute MTU force from normalized muscle state.

    Returns: total force transmitted to tendon [N]
    """
    # Force-Length: Gaussian approximation
    fL = np.exp(-((lM_norm - 1.0) / 0.45) ** 2)

    # Force-Velocity: simplified Hill curve (concentric only)
    k = 0.25  # curvature parameter
    if vM_norm <= 0:  # concentric (shortening)
        fV = (1 + vM_norm) / (1 - vM_norm / k)
    else:  # eccentric (lengthening)
        fV = 1.8 - 0.8 * (1 + vM_norm) / (1 + 7.56 * vM_norm)

    # Passive Element: exponential
    if lM_norm > 1.0:
        kPE = 4.0  # stiffness shape factor
        fPE = (np.exp(kPE * (lM_norm - 1.0) / 0.6) - 1) / (np.exp(kPE) - 1)
    else:
        fPE = 0.0

    # Total force projected through pennation angle
    F_total = (activation * fL * fV + fPE) * F0 * np.cos(alpha)
    return F_total

# 사용 예시
force = normalized_mtu_force(
    activation=0.8,
    lM_norm=1.0,    # 최적 길이
    vM_norm=-0.1,   # 느린 단축
    F0=500.0,
    alpha=np.radians(15)  # 15도 우각
)
print(f"MTU Force: {force:.1f} N")
```

### 수식 3: 건 Force-Strain 관계

$$F_T = F_0^M \cdot k_T \cdot \epsilon_T^2, \quad \epsilon_T = \frac{l^T - l_{slack}^T}{l_{slack}^T}$$

```python
def tendon_force(lT: float, lT_slack: float, F0: float,
                 kT: float = 35.0) -> float:
    """
    Quadratic tendon force-strain model.

    Args:
        lT:       current tendon length [m]
        lT_slack: tendon slack length [m]
        F0:       peak isometric muscle force [N]
        kT:       tendon stiffness coefficient
    Returns:
        Tendon force [N]
    """
    strain = (lT - lT_slack) / lT_slack  # epsilon_T
    if strain > 0:
        return F0 * kT * strain ** 2
    return 0.0  # tendon cannot push (compression = 0)
```

### 수식 4: 활성화 동역학 ODE

$$\dot{a}(t) = \begin{cases} \frac{u - a}{\tau_{act}(0.5 + 1.5a)} & \text{if } u > a \\ \frac{u - a}{\tau_{deact}/(0.5 + 1.5a)} & \text{if } u \leq a \end{cases}$$

```python
def activation_dynamics(u: float, a: float, dt: float,
                        tau_act: float = 0.015,
                        tau_deact: float = 0.050) -> float:
    """
    First-order activation dynamics (forward Euler).

    Args:
        u:  neural excitation (0~1)
        a:  current activation (0~1)
        dt: time step [s]
        tau_act:   activation time constant [s]
        tau_deact: deactivation time constant [s]
    Returns:
        Updated activation level
    """
    if u > a:
        tau = tau_act * (0.5 + 1.5 * a)
    else:
        tau = tau_deact / (0.5 + 1.5 * a)

    da_dt = (u - a) / tau
    a_new = a + da_dt * dt
    return np.clip(a_new, 0.0, 1.0)
```

## 5. 장점과 단점 (Pros & Cons)

### 장점

| 항목 | 설명 |
|------|------|
| **계산 효율** | Hill-type 모델은 Huxley 교차결합 모델보다 파라미터가 적고 수백 배 빠름. 실시간 제어 가능 |
| **충분한 정확도** | 최대 활성화, 단일 관절 동작에서 실측 EMG/힘 데이터와 높은 일치 |
| **확장성** | OpenSim 등 플랫폼에서 수백 개 근육을 동시에 시뮬레이션 가능 |
| **건 탄성 반영** | 에너지 저장·반환 메커니즘을 통해 실제 보행/달리기 역학 재현 |
| **임상 적용** | 재활 계획, 수술 시뮬레이션, 보조기기 설계에 직접 활용 |

### 단점

| 항목 | 설명 |
|------|------|
| **파라미터 보정 어려움** | 최적 근섬유 길이, 건 유격 길이 등 개인차가 크고 비침습 측정이 어려움 |
| **준맥시멀 정확도** | 자연 동작(50~70% 활성화)에서 정확도가 최대 활성화 시보다 저하 |
| **수치 불안정성** | 강성 건 모델에서 미분방정식 적분 시 발산 위험. 작은 시간 간격 또는 암시적 적분기 필요 [Rienaecker et al., 2023] |
| **단순화** | 근막 힘 전달, 3D 형상, 혈류 효과 등 무시. 복잡한 동작에서 한계 |
| **이력(hysteresis) 무시** | 근육/건의 점탄성 이력 효과를 대부분의 모델이 반영하지 않음 |

## 6. 총평 (Conclusion)

Hill-type 근건 모델은 90년의 역사를 가진, 바이오역학 시뮬레이션의 "일꾼(workhorse)"이다. 세 가지 근본 관계(force-length, force-velocity, activation)와 건 탄성이라는 명확한 물리적 기반 위에 서 있으며, OpenSim 같은 오픈소스 도구를 통해 누구나 접근할 수 있다.

**도입 가치가 높은 경우:**
- 보행/운동 분석에서 근력 추정이 필요할 때
- 재활 로봇이나 외골격의 토크 명령을 설계할 때
- 상지 조작 시뮬레이션에서 건 탄성의 역할을 분석할 때

**주의할 점:** 파라미터 보정 없이 generic 모델을 그대로 사용하면 개인별 오차가 클 수 있다. EMG-driven 보정이나 최적화 기반 스케일링이 권장된다. 또한 준맥시멀 동작과 빠른 속도 조건에서는 모델 검증을 추가로 수행해야 한다 [Validation benchmark, 2025].

건 탄성 에너지가 교차결합의 35~70배에 달한다는 사실은, MTU 모델링에서 건을 "강체(rigid)"로 단순화하면 상당한 에너지 역학 정보를 잃게 됨을 의미한다. 특히 상지에서는 결합조직의 수동 탄성이 단일 근섬유 탄성의 10배 이상일 수 있어, 정밀 조작 제어 시뮬레이션에서 건 모델의 정확도가 핵심적이다.

## 7. 참고 문헌 (References)

1. [Hill-type computational models of muscle-tendon actuators: a systematic review](https://www.biorxiv.org/content/10.1101/2022.10.14.512218v2.full) — Caillet et al., 2022
2. [Contribution of elastic tissues to the mechanics and energetics of muscle function during movement](https://pmc.ncbi.nlm.nih.gov/articles/PMC6514471/) — Roberts & Azizi, 2011
3. [How muscle fiber lengths and velocities affect muscle force generation](https://pmc.ncbi.nlm.nih.gov/articles/PMC3656509/) — Arnold et al., 2013
4. [Numerical instability of Hill-type muscle models](https://royalsocietypublishing.org/doi/10.1098/rsif.2022.0430) — Rienaecker et al., 2023
5. [Variable gearing in pennate muscles](https://www.pnas.org/doi/10.1073/pnas.0709212105) — Azizi et al., 2008
6. [OpenSim: Simulating musculoskeletal dynamics and neuromuscular control](https://pmc.ncbi.nlm.nih.gov/articles/PMC6061994/) — Seth et al., 2018
7. [On the Shape of the Force-Velocity Relationship in Skeletal Muscles](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2019.00769/full) — Alcazar et al., 2019
8. [Tendon compliance and preload must be considered for in vivo force-velocity](https://www.nature.com/articles/s41598-023-33643-9) — Nikolaidou et al., 2023
9. [Muscle-tendon unit design and tuning for power enhancement](https://www.sciencedirect.com/science/article/pii/S0021929023001549) — Uchida & Delp, 2023
10. [Validation of skeletal muscle models in multibody dynamics](https://link.springer.com/article/10.1007/s11044-025-10096-8) — Collaborative benchmark, 2025
