---
title: "Postural Control and Balance Dynamics"
slug: "postural-control-and-balance-dynamics"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10440942/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11960994/"
    accessed: "2026-03-19"
  - url: "https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2024.1393749/full"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC9713939/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC2704954/"
    accessed: "2026-03-19"
  - url: "https://pubmed.ncbi.nlm.nih.gov/40030396/"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-025-97637-5"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction) — 왜 등장했는가

사람이 가만히 서 있는 행위는 언뜻 단순해 보이지만, 실제로는 매 순간 뇌가 200개 이상의 근육을 조율하며 수행하는 극도로 복잡한 제어 과제다. 세계보건기구(WHO)에 따르면 낙상은 전 세계적으로 연간 68만 명 이상의 사망 원인이 되며, 특히 65세 이상 노인에서 가장 흔한 비의도적 상해 원인이다. 이러한 현실이 "사람은 어떻게 균형을 유지하는가?"라는 질문에 공학적·의학적 긴급성을 부여했다.

1990년대부터 생체역학자들은 인체를 역진자(inverted pendulum)로 모델링하여 자세 제어를 수학적으로 분석하기 시작했고, 2020년대에 이르러서는 18개 이상의 근육을 포함한 전체 근골격 모델에 강화학습(RL)을 결합하는 단계까지 발전했다 [Wochner et al., 2023; Refai et al., 2025].

## 2. 기초 개념 (Foundations)

[기초 지식]

### 우리 몸은 "거꾸로 세운 막대"다

일상에서 막대기를 손바닥 위에 세워본 경험을 떠올려보자. 조금이라도 기울면 즉시 손을 움직여 보정해야 한다. 인체의 직립 자세도 정확히 이 원리다. 발바닥이라는 작은 면적 위에 약 170cm 높이의 "막대"가 올려져 있고, 중력은 끊임없이 이 막대를 쓰러뜨리려 한다.

핵심적인 차이는 **반응 속도**다. 손으로 막대를 잡을 때는 수십 밀리초면 충분하지만, 뇌에서 발목 근육까지 신호가 도달하는 데는 약 **200밀리초(0.2초)**가 걸린다. 마치 0.2초 지연이 있는 리모컨으로 막대를 조종하는 것과 같다 — 이것이 자세 제어 연구의 핵심 난제다.

### 세 가지 "센서"

우리 몸은 균형을 잡기 위해 세 가지 감각 시스템을 동시에 사용한다:

1. **체성감각(Somatosensory)** — 발바닥의 압력 감지, 근육의 길이/힘 감지. 비유하자면 "발바닥에 깔린 체중계"와 "근육 속에 내장된 스프링 센서"
2. **전정감각(Vestibular)** — 귀 안쪽의 반고리관과 이석기관이 머리의 기울기와 가속도를 측정. "귓속에 장착된 자이로스코프"
3. **시각(Visual)** — 주변 환경의 움직임을 통해 자신의 흔들림을 감지. "눈으로 읽는 수평계"

눈을 감으면 균형이 어려워지는 이유가 바로 시각 채널이 차단되기 때문이다.

### COM vs COP — 균형의 두 주인공

- **질량 중심(Center of Mass, COM)**: 신체 전체 질량의 가중 평균 위치. 대략 배꼽 높이
- **압력 중심(Center of Pressure, COP)**: 발바닥에 가해지는 힘의 합력 작용점

COP가 COM을 "쫓아다니며" 제어하는 것이 균형의 본질이다. COP가 COM보다 앞에 있으면 몸을 뒤로 밀고, 뒤에 있으면 앞으로 밀어 복원한다. 이 관계는 시소의 받침점(COP)과 아이의 위치(COM)에 비유할 수 있다.

## 3. 핵심 개념 (Deep Dive)

### 3.1 발목 전략과 엉덩이 전략 — "작은 바람"과 "큰 밀침"

버스에서 가만히 서 있을 때 살짝 흔들리는 정도의 작은 동요에는 **발목 전략(ankle strategy)**이 작동한다. 발목 근육(비복근·가자미근)이 미세하게 수축하여 몸 전체를 하나의 막대처럼 앞뒤로 조정한다. 마치 나무가 바람에 뿌리 쪽에서부터 천천히 흔들리는 것과 같다 [Suzuki et al., 2023].

누군가 등을 세게 밀면 발목만으로는 부족하다. 이때 **엉덩이 전략(hip strategy)**이 발동한다. 상체를 빠르게 굽히거나 펴서 관성을 이용해 COM을 재배치한다. 비유하자면, 줄타기 곡예사가 긴 막대를 흔드는 것과 유사한 원리다 [Suzuki et al., 2023; Nguyen et al., 2025].

| 상황 | 전략 | 비유 |
|------|------|------|
| 조용히 서 있기 | 발목 전략 | 뿌리에서 흔들리는 나무 |
| 강한 외부 힘 | 엉덩이 전략 | 줄타기 곡예사의 막대 흔들기 |
| 좁은 지지면 | 엉덩이 전략 우세 | 외나무다리 위의 팔 벌리기 |
| 혼합 상황 | 발목+엉덩이 | 서핑보드 위의 전신 조정 |

### 3.2 간헐적 제어 — "필요할 때만 개입하는 뇌"

전통적 공학 제어기는 매 순간 오차를 계산하고 보정 신호를 보낸다(연속 제어). 그러나 인체의 뇌는 다르게 작동한다.

Asai et al. (2009)의 간헐적 제어 이론에 따르면, COM이 "안전 구역" 안에 있을 때 뇌는 **아무것도 하지 않는다**. 몸이 가진 수동적 강성(근육·인대의 탄성)만으로 자연스럽게 감쇠되도록 내버려둔다. COM이 안전 경계를 벗어나려 할 때만 능동적으로 제어 신호를 보낸다.

이것은 고속도로 운전과 비슷하다: 도로 한가운데를 달릴 때는 핸들에서 손을 느슨하게 잡고, 차선 경계에 가까워질 때만 확실하게 조향하는 것이다. 이 전략이 200ms 지연 환경에서 연속 제어보다 더 안정적인 이유는, 지연된 정보로 지속적으로 보정하면 오히려 과보정(overshoot)이 발생하기 때문이다 [Asai et al., 2009].

### 3.3 삼중 역진자와 COM 집중 제어

Sun et al. (2025)은 발목·무릎·엉덩이 세 관절을 모두 포함한 **삼중 역진자(Hybrid Triple Inverted Pendulum, HTIP)** 모델을 제안했다. 핵심 혁신은 각 관절을 개별적으로 제어하는 대신, **COM 하나만을 안정화 목표로 삼는다**는 것이다.

비유: 세 개의 관절이 달린 로봇 팔이 펜을 잡고 글을 쓸 때, 각 관절 각도를 일일이 계산하는 대신 "펜 끝이 여기로 가면 된다"라고 목표를 주는 것과 같다. 개별 관절 제어보다 계산 효율이 높으면서도 실험 데이터와 일치하는 흔들림 패턴을 재현했다 [Sun et al., 2025].

### 3.4 다중 감각 통합 — "세 명의 항해사가 합의하기"

Pasma et al. (2024)의 감각운동 강화 모델은 체성감각·전정·시각 세 채널을 모두 구현한 최초의 본격적 근골격 모델 중 하나다. 9개 DOF, 18개 근육을 포함하며, 각 감각 채널에 서로 다른 신경 지연 시간을 부여했다.

세 감각의 역할을 항해에 비유하면:
- **체성감각** = GPS (현재 위치 정밀 측정, 그러나 울퉁불퉁한 바닥에서는 노이즈)
- **전정감각** = 나침반 (방향 안정적, 그러나 정밀도 제한)
- **시각** = 등대 (원거리 기준점, 그러나 어두우면 무용)

건강한 사람은 이 세 "항해사"의 정보를 상황에 따라 가중치를 바꿔가며 최적으로 결합한다. 예를 들어 눈을 감으면 시각 가중치를 0으로 낮추고 체성감각·전정 가중치를 높인다. 이 적응적 재가중(adaptive reweighting)이 칼만 필터(Kalman filter)로 모델링된다 [Pasma et al., 2024].

### 3.5 강화학습이 가져온 변화 — "시행착오로 배우는 가상 인간"

Refai et al. (2025)는 MuJoCo 물리 엔진 위에 10 DOF, 18개 근육의 근골격 모델을 구축하고, **PPO(Proximal Policy Optimization)** 알고리즘으로 균형 제어를 학습시켰다. 5만 번의 학습 반복(~40시간 GPU 연산) 끝에, 에이전트는 전방·후방 기울기에서 발목 전략과 엉덩이 전략을 자동으로 전환하는 법을 터득했다.

가장 흥미로운 발견은 **균형 영역(Balance Region)** 분석이다. COM의 위치-속도 평면에서 "여기서 출발하면 넘어지지 않고 복원 가능한 영역"을 시각화했는데, 이 영역이 이론적 역진자 한계보다 작았다. 원인은 근육의 최대 힘 한계, 관절 가동 범위 제약, 단순화된 접촉 모델이다 [Refai et al., 2025, Fig 5].

노화 시뮬레이션(근력 30% 감소)에서는 균형 영역이 축소되었고, 편마비(한쪽 근력 완전 상실) 시뮬레이션에서는 정적 균형 영역 전체에서 복원이 불가능해졌다 — 낙상 위험의 정량적 근거를 제공한다 [Refai et al., 2025, Fig 7].

## 4. 수식 구현 (Key Formulas)

### 4.1 단일 역진자 운동 방정식

$$I\ddot{\theta} = mgh\sin\theta - \tau_{ankle}$$

- $I$: 신체 관성 모멘트 (발목 기준)
- $m$: 체질량, $h$: COM 높이, $g$: 중력가속도
- $\theta$: 기울기 각도 (직립=0)
- $\tau_{ankle}$: 발목 제어 토크

```python
import numpy as np

def single_inverted_pendulum(t, state, params, controller):
    """
    단일 역진자 운동 방정식
    state: [theta, theta_dot]
    params: dict with m, h, g, I
    """
    theta, theta_dot = state
    m, h, g, I = params['m'], params['h'], params['g'], params['I']

    # 제어 토크 계산
    tau = controller.compute_torque(theta, theta_dot)

    # 운동 방정식: I * theta_ddot = mgh*sin(theta) - tau
    theta_ddot = (m * g * h * np.sin(theta) - tau) / I

    return [theta_dot, theta_ddot]
```

### 4.2 PD 제어기 + 신경 지연

$$\tau(t) = K_p \cdot [\theta_{ref} - \theta(t-\delta)] + K_d \cdot [0 - \dot{\theta}(t-\delta)]$$

- $\delta$: 신경 전달 지연 (~200ms)
- $K_p$: 비례 이득 (발목 전략 안정 범위: 408–2562 Nm/rad)
- $K_d$: 미분 이득 (0–1110 Nms/rad)

```python
from scipy.integrate import solve_ivp
from collections import deque

class DelayedPDSimulator:
    """신경 지연을 포함한 PD 제어 시뮬레이션"""

    def __init__(self, m=70, h=0.9, I=65, g=9.81,
                 Kp=800, Kd=300, delay=0.2, dt=0.001):
        self.m, self.h, self.I, self.g = m, h, I, g
        self.Kp, self.Kd = Kp, Kd
        self.delay = delay
        self.dt = dt
        self.delay_steps = int(delay / dt)

    def simulate(self, theta0=0.03, duration=10.0):
        """
        theta0: 초기 기울기 (rad), ~1.7도
        returns: time, theta, theta_dot, torque arrays
        """
        n_steps = int(duration / self.dt)
        theta = np.zeros(n_steps)
        theta_dot = np.zeros(n_steps)
        torque = np.zeros(n_steps)
        theta[0] = theta0

        for i in range(1, n_steps):
            # 지연된 상태 인덱스
            delayed_i = max(0, i - self.delay_steps)

            # PD 제어 토크 (지연된 상태 기반)
            tau = (self.Kp * (0 - theta[delayed_i])
                   + self.Kd * (0 - theta_dot[delayed_i]))
            torque[i] = tau

            # 오일러 적분
            theta_ddot = (self.m * self.g * self.h * np.sin(theta[i-1])
                          - tau) / self.I
            theta_dot[i] = theta_dot[i-1] + theta_ddot * self.dt
            theta[i] = theta[i-1] + theta_dot[i] * self.dt

        time = np.arange(n_steps) * self.dt
        return time, theta, theta_dot, torque
```

### 4.3 이중 역진자 라그랑주 역학

$$M(q)\ddot{q} + C(q,\dot{q})\dot{q} + G(q) = \tau$$

- $q = [\theta_1, \theta_2]^T$: 발목, 엉덩이 관절 각도
- $M$: 관성 행렬, $C$: 코리올리/원심력 행렬, $G$: 중력 벡터

```python
def double_inverted_pendulum_dynamics(q, q_dot, params):
    """
    이중 역진자 운동 방정식 (라그랑주)
    q: [theta_ankle, theta_hip]
    params: 각 세그먼트의 m, l, lc, I
    """
    t1, t2 = q       # 발목 각도, 엉덩이 각도
    t1d, t2d = q_dot

    # 세그먼트 파라미터 (다리: 1, HAT: 2)
    m1, l1, lc1, I1 = params['leg']    # 다리
    m2, l2, lc2, I2 = params['hat']    # Head-Arm-Trunk
    g = 9.81

    # 관성 행렬 M(q)
    M11 = I1 + I2 + m1*lc1**2 + m2*(l1**2 + lc2**2 + 2*l1*lc2*np.cos(t2))
    M12 = I2 + m2*(lc2**2 + l1*lc2*np.cos(t2))
    M21 = M12
    M22 = I2 + m2*lc2**2
    M = np.array([[M11, M12], [M21, M22]])

    # 코리올리/원심력 벡터 C(q,q_dot)*q_dot
    h = m2 * l1 * lc2 * np.sin(t2)
    C = np.array([-h*t2d*(2*t1d + t2d),
                   h*t1d**2])

    # 중력 벡터 G(q)
    G_vec = np.array([
        -(m1*lc1 + m2*l1)*g*np.sin(t1) - m2*lc2*g*np.sin(t1+t2),
        -m2*lc2*g*np.sin(t1+t2)
    ])

    return M, C, G_vec

    # 가속도: q_ddot = M^{-1} @ (tau - C - G)
```

### 4.4 Extrapolated COM (XcoM) 안정성 지표

$$XcoM = x_{com} + \frac{\dot{x}_{com}}{\omega_0}, \quad \omega_0 = \sqrt{\frac{g}{L}}$$

- $\omega_0$: 역진자 고유 진동수 (~3.3 rad/s for L=0.9m)
- 안정 조건: $XcoM \in BoS$ (지지면 내부)

```python
def compute_xcom(com_pos, com_vel, com_height=0.9, g=9.81):
    """
    Extrapolated Center of Mass 계산
    com_pos: COM 수평 위치 (m)
    com_vel: COM 수평 속도 (m/s)
    com_height: COM 높이 (m)
    returns: XcoM 위치 (m)
    """
    omega0 = np.sqrt(g / com_height)  # 고유 진동수
    xcom = com_pos + com_vel / omega0
    return xcom

def check_stability(xcom, bos_anterior=0.15, bos_posterior=-0.05):
    """
    XcoM이 BoS 내에 있는지 확인
    bos_anterior: 발끝 위치 (m), bos_posterior: 발뒤꿈치 위치 (m)
    """
    return bos_posterior <= xcom <= bos_anterior
```

### 4.5 RL 보상 함수 구조

$$r_t = w_p \cdot r_t^{posture} + w_\tau \cdot r_t^{torque} + w_{up} \cdot r_t^{up} + w_{xcom} \cdot r_t^{xcom}$$

- 가중치: $w_p=1.0, w_\tau=0.1, w_{up}=0.1, w_{xcom}=0.1$

```python
def compute_balance_reward(state, action, weights=None):
    """
    RL 균형 제어 보상 함수 (Refai et al., 2025)
    state: 관절 각도, COM 위치/속도 등
    action: 근육 활성화 (18개)
    """
    if weights is None:
        weights = {'posture': 1.0, 'torque': 0.1,
                   'upright': 0.1, 'xcom': 0.1}

    # 목표 자세와의 차이 (직립 = 0)
    r_posture = np.exp(-2.0 * np.sum(state['joint_angles']**2))

    # 토크 최소화 (에너지 효율)
    r_torque = np.exp(-0.1 * np.sum(action**2))

    # 상체 수직 유지
    trunk_angle = state['trunk_angle']
    r_upright = np.exp(-5.0 * trunk_angle**2)

    # XcoM이 BoS 내 유지
    xcom = compute_xcom(state['com_x'], state['com_vx'])
    margin = min(xcom - state['bos_post'], state['bos_ant'] - xcom)
    r_xcom = np.clip(margin / 0.1, 0, 1)

    reward = (weights['posture'] * r_posture
              + weights['torque'] * r_torque
              + weights['upright'] * r_upright
              + weights['xcom'] * r_xcom)
    return reward
```

## 5. 장점과 단점 (Pros & Cons)

### 장점

| 관점 | 장점 |
|------|------|
| **의학적** | 낙상 위험을 정량적으로 예측 — 균형 영역(BR) 크기로 개인별 위험도 평가 가능 [Refai et al., 2025] |
| **공학적** | 인체 제어 원리를 로봇·외골격에 전이 가능 — 간헐적 제어는 에너지 효율적 [Asai et al., 2009] |
| **신경과학적** | 감각 통합 메커니즘의 정량적 검증 프레임워크 제공 [Pasma et al., 2024] |
| **재활** | 환자별 파라미터로 시뮬레이션하여 맞춤형 치료 프로토콜 설계 가능 |
| **RL 접근** | 제어기 설계 없이 데이터 기반으로 전략 발견, 발목↔엉덩이 전환을 자동 학습 [Nguyen et al., 2025] |

### 단점

| 관점 | 단점 |
|------|------|
| **검증 어려움** | "인간과 비슷한 동작"이 "인간과 같은 내부 과정"을 의미하지 않음 — 동일 출력, 다른 메커니즘 가능 [Wochner et al., 2023] |
| **파라미터 폭발** | 근골격 모델 + 다중 감각 = 수십~수백 개 파라미터, 과적합 위험 |
| **계산 비용** | RL 학습 ~40시간(GPU), 실시간 임상 적용 어려움 [Refai et al., 2025] |
| **3D 한계** | 대부분의 연구가 시상면(전후방)에 한정, 관상면(좌우) 및 3D 결합 동역학 미비 |
| **감각 모델 단순화** | CNS의 실제 감각 통합 과정은 여전히 "블랙박스" [Wochner et al., 2023] |

## 6. 총평 (Conclusion)

자세 제어와 균형 역학 분야는 **이론적 성숙기에서 실용적 전환기**로 이행 중이다.

- **모델링**: 단일 역진자 → 삼중 역진자 → 전체 근골격 모델로 복잡도가 증가하면서, PD 제어에서 간헐적 제어, 나아가 RL 기반 제어로 패러다임이 전환되고 있다.
- **임상 가치**: RL 기반 근골격 시뮬레이션은 근력 저하(노화)·신경 지연 증가·편마비 등의 조건에서 균형 영역 축소를 정량적으로 보여주어, 낙상 위험 평가의 객관적 도구가 될 잠재력이 있다.
- **도입 권장**: 근골격 모델링·시뮬레이션 파이프라인에 자세 제어 모듈을 통합할 때, (1) 초기에는 PD 기반 발목 제어기로 프로토타이핑하고, (2) 간헐적 제어로 강건성을 확보한 뒤, (3) RL 기반 제어기로 확장하는 3단계 접근이 현실적이다.

연구 격차로는 3D 전신 모델에서의 다중 감각 통합, 환자별 자동 캘리브레이션, 실시간 시뮬레이션 기술이 남아 있다.

## 7. 참고 문헌 (References)

1. [Methods for integrating postural control into biomechanical human simulations: a systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC10440942/) — Wochner, I. et al., J NeuroEngineering Rehabil, 2023
2. [Characterization of Human Balance through a Reinforcement Learning-based Muscle Controller](https://pmc.ncbi.nlm.nih.gov/articles/PMC11960994/) — Refai, M.I.M. et al., PLOS ONE, 2025
3. [A sensorimotor enhanced neuromusculoskeletal model for simulating postural control of upright standing](https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2024.1393749/full) — Pasma, J.H. et al., Front Neurosci, 2024
4. [Integrating ankle and hip strategies for the stabilization of upright standing: An intermittent control model](https://pmc.ncbi.nlm.nih.gov/articles/PMC9713939/) — Suzuki, Y. et al., Front Comput Neurosci, 2023
5. [A Model of Postural Control in Quiet Standing: Robust Compensation of Delay-Induced Instability](https://pmc.ncbi.nlm.nih.gov/articles/PMC2704954/) — Asai, Y. et al., PLoS Comput Biol, 2009
6. [Neuromechanical Simulation of Human Postural Sway Based on Hybrid Triple Inverted Pendulum](https://pubmed.ncbi.nlm.nih.gov/40030396/) — Sun, J. et al., IEEE Trans Neural Syst Rehabil Eng, 2025
7. [Biomechanical optimization and RL provide insight into ankle to hip strategy transition](https://www.nature.com/articles/s41598-025-97637-5) — Nguyen, K. et al., Sci Rep, 2025
