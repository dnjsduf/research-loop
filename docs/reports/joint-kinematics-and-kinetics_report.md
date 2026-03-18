---
title: "Joint Kinematics and Kinetics"
slug: "joint-kinematics-and-kinetics"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC11452939/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC10688959/"
    accessed: "2026-03-19"
  - url: "https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011462"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC5550294/"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-025-89716-4"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC12228224/"
    accessed: "2026-03-19"
---

## 1. 배경 (Introduction)

사람이 걷거나 뛰거나 계단을 오를 때, 관절에서는 정확한 타이밍과 크기의 힘이 작용해야 한다. 이 움직임의 **"어떻게"**(각도, 속도)를 기술하는 것이 **운동학(kinematics)**, **"왜"**(어떤 힘이 작용했는가)를 밝히는 것이 **동역학(kinetics)** 이다.

스포츠 과학에서 부상 예방을 설계하고, 정형외과에서 인공관절의 수명을 예측하며, 재활 의학에서 환자의 회복 경과를 추적하려면 이 두 가지를 정밀하게 측정해야 한다. 문제는 **관절 내부의 힘은 직접 측정할 수 없다**는 점이다. 임플란트에 센서를 심지 않는 한, 피부 위의 마커와 발 밑의 힘판 데이터로부터 수학적으로 "역추적"해야 한다. 이것이 바로 **근골격 모델링과 시뮬레이션**이 존재하는 이유다 [Veerkamp et al., 2024].

## 2. 기초 개념 (Foundations)

[기초 지식]

### 운동학: "동작의 지도"

운동학은 **힘을 무시하고** 순수하게 위치·속도·가속도만 다룬다. 비유하자면, GPS 추적 앱이 경로와 속도는 알려주지만 차가 어떤 엔진 출력으로 달리는지는 모르는 것과 같다.

인체 관절은 **경첩**(무릎의 굴곡/신전), **볼-소켓**(고관절의 3축 회전), **안장**(엄지 손가락) 등 다양한 형태를 가진다. 각 관절의 **자유도(DOF)** 가 곧 운동학적 변수의 개수를 결정한다.

### 동역학: "동작의 원인 추적"

동역학은 뉴턴의 운동법칙($F = ma$)을 인체에 적용한다. 발이 지면을 밀면 지면이 발을 미는 **지면반력(GRF)** 이 발생하고, 이 힘이 세그먼트 체인(발→발목→무릎→고관절)을 따라 전달되면서 각 관절에서 **순 모멘트(net moment)** 를 만든다.

비유하자면, 여러 사람이 한 줄로 서서 양동이 릴레이를 하는 것과 같다. 각 사람(세그먼트)이 받는 무게(반력)와 넘기는 타이밍(모멘트)을 계산하면, 누가 가장 큰 부담을 지는지 알 수 있다.

### 역문제(Inverse Problem)

직접적으로 근력이나 관절 내부 하중을 측정할 수 없으므로, **관찰 가능한 결과(마커 위치, GRF)에서 원인(관절 각도, 모멘트, 근력)을 역으로 추정**하는 "역문제" 접근이 핵심이다. 이것은 범죄 현장의 흔적(결과)으로부터 사건의 경과(원인)를 추론하는 수사관의 논리와 유사하다.

## 3. 핵심 개념 (Deep Dive)

### 3.1 역운동학(IK): 마커에서 관절 각도로

모션캡처 카메라가 피부에 부착된 반사 마커의 3D 위치를 기록하면, 컴퓨터 모델의 "가상 마커"가 이를 최대한 따라가도록 관절 각도를 조정한다. 이는 **꼭두각시 인형의 실을 조정해서 인형이 실제 사람의 동작을 흉내내게 하는 것**과 같다 [Seth et al., 2018].

구체적으로, 가중 최소자승법으로 실험 마커와 모델 마커 간 거리 제곱합을 최소화한다:

$$\min_{\mathbf{q}} \sum_{i=1}^{N} w_i \|\mathbf{x}_i^{exp} - \mathbf{x}_i^{model}(\mathbf{q})\|^2$$

**잠재적 함정**: 피부가 뼈 위에서 미끄러지는 **소프트 조직 아티팩트(STA)** 로 인해, 마커가 실제 뼈의 움직임과 최대 30mm까지 다를 수 있다 [Leardini et al., 2005]. 이는 장갑 위에 스티커를 붙여 손가락 움직임을 추적하는 것처럼, 장갑이 미끄러지면 추적이 부정확해지는 원리다.

### 3.2 역동역학(ID): 관절 각도에서 힘·모멘트로

IK에서 얻은 관절 각도 궤적과 힘판에서 측정한 GRF를 결합하여, 뉴턴의 법칙을 각 세그먼트에 순차적으로 적용한다. **가장 먼 관절(발목)부터 시작해서 몸통 쪽(고관절)으로 올라가며** 각 관절의 순 모멘트를 계산한다 [Delp et al., 2007].

비유: 시소에서 한쪽 끝의 무게(GRF)와 시소 각도 변화(관절 각도)를 알면, 받침점(관절)에 걸리는 토크(모멘트)를 계산할 수 있다. 인체는 이러한 시소가 여러 개 직렬 연결된 체인이다.

### 3.3 근력 추정: "누가 얼마나 당기나"

역동역학은 관절의 **순** 모멘트만 알려준다. 하지만 무릎 주위만 해도 사두근, 햄스트링, 비복근 등 여러 근육이 동시에 작용한다. 하나의 모멘트 방정식에 미지수(근육)가 더 많은 **근력 중복성(muscle redundancy)** 문제가 발생한다 [Anderson & Pandy, 2001].

이를 해결하는 세 가지 전략:

| 방법 | 비유 | 장점 | 단점 |
|------|------|------|------|
| **정적 최적화(SO)** | "모든 근육의 노력을 최소화" — 팀원들이 일을 가장 공평하게 나누는 방식 | 빠름, 구현 용이 | 동시 수축(co-contraction) 과소평가 |
| **CMC** | SO에 "추적 피드백 루프" 추가 — 실시간으로 오차 보정하며 전방 시뮬레이션 | 동적 일관성 | 계산 비용 높음, 수렴 실패 가능 |
| **EMG-Driven** | 실제 근전도 신호를 "지휘봉"으로 사용 — 뇌가 보낸 실제 명령을 반영 | 동시 수축 포착, 개인화 | EMG 측정 필요, 깊은 근육 접근 어려움 |

### 3.4 관절 접촉력: 임플란트와 관절 건강의 열쇠

근력을 알면 관절면에 걸리는 실제 하중을 추정할 수 있다. 보행 시 무릎 관절 접촉력은 체중의 **2–4배**에 달한다. 이 정보는 인공관절 설계에서 재료 내구성을 결정하고, 골관절염 환자에서 질병 진행을 예측하는 데 핵심적이다.

최근 연구에서 EMG-informed 모델이 정적 최적화보다 인공관절 삽입 환자의 실측 접촉력(instrumented implant)을 더 정확하게 예측함이 확인되었다 [2025, Journal of Biomechanics].

### 3.5 실험실 밖으로: 최신 기술 혁신

#### OpenCap: 스마트폰으로 모션캡처

스마트폰 2대의 영상만으로 3D 관절 운동학과 동역학을 산출한다. 비전문가도 사용할 수 있으며, 평균 관절 각도 오차 3.85°로 전통적 마커리스 시스템과 동등한 정확도를 보인다 [Uhlrich et al., 2023].

핵심 혁신: **LSTM 마커 보정기**가 비디오 키포인트 20개에서 해부학적 마커 43개의 위치를 추정하여, 기존 키포인트만 사용할 때 대비 평균 4.2° 오차를 줄인다.

#### AddBiomechanics: "원버튼" 자동화

마커 데이터를 업로드하면 모델 스케일링, IK, ID를 자동으로 수행한다. 수동 조정 없이 재현 가능한 결과를 제공하여, 대규모 데이터셋 처리에 적합하다 [Werling et al., 2023].

#### IMU + 딥러닝: 어디서나 측정

관성 센서(IMU)와 딥러닝을 결합하여, 소수의 센서만으로 관절 각도와 모멘트를 추정한다. Transfer learning을 적용하면 새로운 사용자에 대해 소량의 데이터로도 정확도를 높일 수 있다 (RMSE < 5°) [Tan et al., 2025].

## 4. 수식 구현 (Key Formulas)

### 4.1 역운동학 목적함수

$$J(\mathbf{q}) = \sum_{i=1}^{N_m} w_i \|\mathbf{x}_i^{exp} - \mathbf{x}_i(\mathbf{q})\|^2$$

- $\mathbf{q}$: 일반화 좌표 벡터 (관절 각도)
- $\mathbf{x}_i^{exp}$: 실험 마커 위치
- $w_i$: 마커 가중치

```python
import numpy as np
from scipy.optimize import minimize

def ik_objective(q, exp_markers, model_fk, weights):
    """
    역운동학 목적함수
    q: 관절 각도 벡터 (N_joints,)
    exp_markers: 실험 마커 위치 (N_markers, 3)
    model_fk: forward kinematics 함수 — q → (N_markers, 3)
    weights: 마커 가중치 (N_markers,)
    """
    model_markers = model_fk(q)                       # 모델 마커 위치 계산
    diff = exp_markers - model_markers                 # 오차 벡터
    squared_dist = np.sum(diff**2, axis=1)             # 각 마커의 거리²
    return np.sum(weights * squared_dist)              # 가중 합

# 사용 예시
# result = minimize(ik_objective, q0, args=(exp_markers, fk_func, w))
# joint_angles = result.x
```

### 4.2 역동역학: 순 관절 모멘트

$$\tau_j = I_j \alpha_j + \omega_j \times (I_j \omega_j) - \mathbf{r}_{cm} \times m_j \mathbf{a}_{cm} + \tau_{distal}$$

- $I_j$: 세그먼트 관성 텐서
- $\alpha_j$: 각가속도, $\omega_j$: 각속도
- $m_j$: 세그먼트 질량, $\mathbf{a}_{cm}$: 질량 중심 가속도

```python
def inverse_dynamics_segment(I, alpha, omega, m, a_cm, r_cm, tau_distal, F_distal):
    """
    단일 세그먼트의 역동역학 계산
    I: 관성 텐서 (3, 3)
    alpha: 각가속도 (3,)
    omega: 각속도 (3,)
    m: 세그먼트 질량
    a_cm: 질량중심 가속도 (3,)
    r_cm: 관절→질량중심 벡터 (3,)
    tau_distal: 원위 관절 모멘트 합 (3,)
    F_distal: 원위 관절 반력 합 (3,)
    """
    # 오일러 방정식: τ = Iα + ω × (Iω)
    gyroscopic = np.cross(omega, I @ omega)            # 자이로스코프 항
    tau_inertial = I @ alpha + gyroscopic

    # 병진 평형에서 관절 반력
    g = np.array([0, -9.81, 0])                        # 중력
    F_joint = m * a_cm - m * g - F_distal              # 관절 반력

    # 관절 모멘트
    tau_joint = tau_inertial + np.cross(r_cm, m * a_cm) - tau_distal
    return tau_joint, F_joint
```

### 4.3 정적 최적화

$$\min_{\mathbf{a}} \sum_{m=1}^{M} a_m^2 \quad \text{s.t.} \quad \mathbf{R} \cdot \mathbf{f}(\mathbf{a}) = \boldsymbol{\tau}$$

- $a_m \in [0, 1]$: 근 활성도
- $\mathbf{R}$: 모멘트 암 행렬
- $\mathbf{f}(\mathbf{a})$: 힘-길이-속도 관계를 통한 근력

```python
from scipy.optimize import minimize

def static_optimization(moment_arms, max_forces, flv_factors, tau_target):
    """
    정적 최적화: 근 활성도² 합 최소화
    moment_arms: (N_dof, N_muscles) — 각 관절에 대한 모멘트 암
    max_forces: (N_muscles,) — 최대 등척성 근력
    flv_factors: (N_muscles,) — 힘-길이-속도 스케일링
    tau_target: (N_dof,) — 역동역학에서 구한 순 관절 모멘트
    """
    n_muscles = len(max_forces)

    def objective(a):
        return np.sum(a ** 2)                          # Σ a_m²

    def moment_constraint(a):
        forces = a * max_forces * flv_factors          # f_m = a_m · F_max · f(l,v)
        tau_produced = moment_arms @ forces            # R · f = τ
        return tau_produced - tau_target               # 제약: 0이어야 함

    bounds = [(0, 1)] * n_muscles
    result = minimize(
        objective,
        x0=np.full(n_muscles, 0.1),
        method='SLSQP',
        bounds=bounds,
        constraints={'type': 'eq', 'fun': moment_constraint}
    )
    return result.x  # 최적 근 활성도
```

## 5. 장점과 단점 (Pros & Cons)

### 장점

- **비침습적 내부 하중 추정**: 수술 없이 관절 내부 역학을 정량적으로 분석 가능
- **표준화된 도구 생태계**: OpenSim, AnyBody, SIMM 등 검증된 소프트웨어 생태계
- **임상 직결 응용**: 인공관절 설계, 보행 재활 프로토콜, 스포츠 부상 예방에 직접 활용
- **자동화·민주화 가속**: OpenCap, AddBiomechanics 등으로 전문가 아닌 사용자도 접근 가능
- **딥러닝 융합**: IMU+ML로 실험실 밖 환경에서도 관절 역학 추정 가능

### 단점

- **측정 오차 누적**: 스케일링→IK→ID→근력 추정까지 각 단계 오차가 연쇄적으로 전파
- **소프트 조직 아티팩트**: 피부 기반 마커의 원천적 한계 (최대 30mm 오차)
- **근력 중복성**: 생리학적으로 고유한 해가 존재하지 않음
- **모델 가정 의존**: 관절 형태, 인대 속성, 근건 파라미터 등 가정의 영향이 큼
- **EMG 측정 제약**: 심부 근육 접근 불가, 채널 간 cross-talk
- **계산 비용**: 환자 맞춤형 모델 + 동적 시뮬레이션은 여전히 시간 소모적

## 6. 총평 (Conclusion)

관절 운동학·동역학은 근골격 모델링의 **출력 계층**이자 임상·스포츠·재활의 **의사결정 데이터**를 제공하는 핵심 분야다. 전통적인 마커 기반 IK/ID 파이프라인은 수십 년간 검증되었으며, 정적 최적화와 EMG-driven 방법이 근력 중복성 문제를 각각 다른 관점에서 해결하고 있다.

2023–2025년의 가장 큰 변화는 **접근성 혁명**이다. OpenCap(스마트폰 영상 → 역학), AddBiomechanics(자동화), IMU+딥러닝(실험실 밖 측정)이 결합되면서, 이전에는 수백만 원 장비와 전문 인력이 필요했던 분석이 점차 보편화되고 있다. 다만 정확도-편의성 트레이드오프는 여전하며, 인공관절 설계와 같은 고정밀 응용에서는 마커 기반 + EMG-driven 파이프라인이 필수적이다.

**도입 판단**: 보행 분석, 재활 평가, 스포츠 성능 분석에 관여하는 프로젝트라면 즉시 도입 가치가 있다. OpenSim Python API를 통한 IK/ID/SO 파이프라인으로 시작하고, 데이터 접근 상황에 따라 OpenCap 또는 IMU+ML로 확장하는 전략이 합리적이다.

## 7. 참고 문헌 (References)

- [Multibody dynamics-based musculoskeletal modeling for gait analysis: a systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11452939/) — Veerkamp et al., 2024
- [AddBiomechanics: Automating model scaling, inverse kinematics, and inverse dynamics](https://pmc.ncbi.nlm.nih.gov/articles/PMC10688959/) — Werling et al., 2023
- [OpenCap: Human movement dynamics from smartphone videos](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011462) — Uhlrich et al., 2023
- [Real-time inverse kinematics and inverse dynamics using OpenSim](https://pmc.ncbi.nlm.nih.gov/articles/PMC5550294/) — Pizzolato et al., 2017
- [Learning based lower limb joint kinematic estimation using IMU data](https://www.nature.com/articles/s41598-025-89716-4) — Tan et al., 2025
- [A PRISMA systematic review on predictive musculoskeletal simulations](https://pmc.ncbi.nlm.nih.gov/articles/PMC12228224/) — 2024
- [EMG-driven musculoskeletal model calibration with synergy extrapolation](https://www.frontiersin.org/articles/10.3389/fbioe.2022.962959/full) — Pizzolato et al., 2022
- [A calibrated EMG-informed neuromusculoskeletal model for joint contact forces](https://www.sciencedirect.com/science/article/pii/S0021929025000971) — 2025
- [Comparison of kinematics and kinetics between OpenCap and marker-based system](https://pubmed.ncbi.nlm.nih.gov/40311466/) — 2025
