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
  - url: "https://link.springer.com/article/10.1007/s11044-025-10096-8"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-023-33643-9"
    accessed: "2026-03-19"
  - url: "https://www.sciencedirect.com/science/article/pii/S0021929023001549"
    accessed: "2026-03-19"
---

## 1. 핵심 요약 (TL;DR)

근건 단위(MTU)의 힘 생성은 Hill-type 모델의 세 가지 관계(force-length, force-velocity, activation dynamics)와 건의 직렬 탄성으로 결정되며, 건 탄성은 에너지 저장·반환을 통해 근섬유 작동 조건을 최적화하고 대사 비용을 절감한다.

## 2. 기초 개념 (Foundations)

**근건 단위(Muscle-Tendon Unit, MTU):** 근육과 건이 직렬로 연결된 기능 단위. 근육은 능동적 힘을 생성하고, 건은 수동적 탄성체로서 힘을 전달·저장한다. [기초 지식]

**사르코미어(Sarcomere):** 근섬유의 최소 수축 단위. 액틴-마이오신 교차결합(cross-bridge)이 ATP 에너지로 활주(sliding)하여 힘을 생성한다. 사르코미어 길이가 힘 생성 능력을 직접 결정한다. [기초 지식]

**흥분-수축 연계(Excitation-Contraction Coupling):** 운동 신경의 활동전위 → 신경근접합부 ACh 방출 → T-tubule 전파 → SR에서 Ca²⁺ 방출 → 트로포닌 결합 → 교차결합 형성의 연쇄 과정. Ca²⁺ 농도가 활성화 수준을 결정한다 [Rios et al., 2020, PMC7040155].

**이 주제가 중요한 이유:** 근건 역학은 보행·조작·재활 시뮬레이션의 핵심이며, 근력 추정 없이는 관절 하중, 운동 제어, 보조기기 설계가 불가능하다. 상지(upper extremity)에서는 수동 근 탄성 계수(passive muscle modulus)가 단일 근섬유 대비 10배 이상 높아 결합조직이 힘 전달에 크게 기여하며, 이는 정밀 조작 제어 모델링 시 건·결합조직 파라미터의 정확한 반영을 요구한다 [Lieber et al., 2004, J Hand Surg]. [기초 지식]

## 3. 코어 로직 (Core Mechanism)

### 3.1 Hill-Type 근건 모델 구조

Hill-type 모델은 세 요소로 구성된다 [Millard et al., 2013; Zajac, 1989]:

```
[신경 입력 u(t)] → [활성화 동역학 a(t)] → [수축 요소 CE] ─┐
                                                              ├── 직렬 탄성 요소 (SE/Tendon)
                                     [수동 탄성 요소 PE] ──┘
```

**평형 조건:** 근섬유 힘 = 건 힘 (직렬 연결이므로)

$$F_{MTU} = F_{tendon} = F_{CE} + F_{PE}$$

### 3.2 Force-Length Relationship

사르코미어에서 액틴-마이오신 중첩(overlap)이 최적일 때 최대 등척성 힘 발생:

$$F_{CE}^{active} = a(t) \cdot F_0^M \cdot f_L(\tilde{l}^M)$$

- $a(t)$: 활성화 수준 (0~1)
- $F_0^M$: 최대 등척성 힘
- $f_L$: 정규화된 force-length 곡선 (bell-shaped)
- $\tilde{l}^M = l^M / l_0^M$: 정규화 근섬유 길이

최적 길이($l_0^M$)에서 $f_L = 1.0$, 양쪽으로 벗어나면 감소 [Arnold et al., 2013, PMC3656509].

### 3.3 Force-Velocity Relationship

Hill의 쌍곡선 방정식으로 단축/신장 속도에 따른 힘 변화:

$$F_{CE} = a(t) \cdot F_0^M \cdot f_L(\tilde{l}^M) \cdot f_V(\tilde{v}^M)$$

- 단축(concentric): 속도 증가 → 힘 감소 (쌍곡선적 감소)
- 신장(eccentric): 속도 증가 → 힘 증가 (최대 ~1.8 × $F_0^M$)
- $\tilde{v}^M = v^M / v_{max}$: 정규화 수축 속도

[Alcazar et al., 2019, Frontiers in Physiology]

### 3.4 수동 탄성 요소 (Passive Element)

근섬유가 최적 길이 이상으로 늘어날 때 수동적 힘 발생:

$$F_{PE} = F_0^M \cdot f_{PE}(\tilde{l}^M)$$

지수 함수 형태로 길이가 늘어날수록 급격히 증가.

### 3.5 건 역학 (Tendon Mechanics)

건은 비선형 탄성체로 모델링 [Roberts & Azizi, 2011, PMC6514471]:

$$F_T = f_T(\epsilon_T) \cdot F_0^M$$

- $\epsilon_T = (l^T - l_{slack}^T) / l_{slack}^T$: 건 변형률
- $l_{slack}^T$: 건 유격 길이 (무부하 시 길이)
- 전형적 파단 변형률: ~6%, 작동 범위: 0~4%

**에너지 저장·반환:** 건의 탄성 에너지 용량은 교차결합 저장 에너지의 35~70배에 달한다. 건은 근력 발생 시 늘어나며 에너지를 저장하고, 근력 감소 시 반동(recoil)하여 에너지를 반환한다 [Roberts & Azizi, 2011].

### 3.6 활성화 동역학 (Activation Dynamics)

신경 흥분(excitation) → 근 활성화(activation) 변환:

$$\dot{a}(t) = f(u, a) = \frac{u - a}{\tau(u, a)}$$

- 활성화 시상수($\tau_{act}$): ~10-20 ms
- 비활성화 시상수($\tau_{deact}$): ~40-60 ms
- 비활성화가 활성화보다 느림

### 3.7 근육 기어링 (Architectural Gearing)

우상근(pennate muscle)에서 근섬유 회전이 근육 속도를 증폭:

$$AGR = \frac{v_{muscle}}{v_{fiber}} = \frac{\cos\alpha_0}{\cos\alpha}$$

- 저부하 시: AGR ≈ 1.4 (근육 속도 40% 증폭)
- 고부하 시: AGR ≈ 1.0 (힘 전달 최적화)

우각(pennation angle)이 클수록 단위 체적당 더 많은 근섬유를 배치할 수 있어 힘 증가, 단 속도 감소 [Azizi et al., 2008, PNAS].

### 3.8 전체 MTU 풀이 수도코드

```
Input: u(t), l_MTU(t), v_MTU(t)

1. activation dynamics:
   a(t) = solve_activation_ODE(u, a_prev, tau_act, tau_deact)

2. tendon-muscle equilibrium:
   l_T = l_MTU - l_M * cos(alpha)       # 기하학적 제약
   F_T = f_tendon(l_T, l_slack)          # 건 힘
   F_M = a * F0 * fL(l_M) * fV(v_M) + F_PE(l_M)  # 근섬유 힘
   solve: F_T == F_M * cos(alpha)        # 평형 조건

3. output: F_MTU = F_T
```

## 4. 프로젝트 적용 방안

### 적용 타겟
상지 역학·보행 분석에서의 근건 힘 추정, 재활 로봇/외골격 토크 산출.

### 뼈대 코드 (Python)

```python
import numpy as np

class HillTypeMTU:
    """Hill-type Muscle-Tendon Unit model."""

    def __init__(self, F0=1000.0, lM_opt=0.1, lT_slack=0.2,
                 vmax=10.0, alpha0=0.0):
        self.F0 = F0            # 최대 등척성 힘 [N]
        self.lM_opt = lM_opt    # 최적 근섬유 길이 [m]
        self.lT_slack = lT_slack  # 건 유격 길이 [m]
        self.vmax = vmax        # 최대 단축 속도 [lM_opt/s]
        self.alpha0 = alpha0    # 초기 우각 [rad]

    def force_length(self, lM_norm):
        """Gaussian force-length curve."""
        return np.exp(-((lM_norm - 1.0) / 0.45) ** 2)

    def force_velocity(self, vM_norm):
        """Hill hyperbolic force-velocity."""
        if vM_norm <= 0:  # concentric
            return (1 + vM_norm) / (1 - vM_norm / 0.25)
        else:  # eccentric
            return 1.8 - 0.8 * (1 + vM_norm) / (1 - 7.56 * vM_norm)

    def passive_force(self, lM_norm):
        """Exponential passive element."""
        if lM_norm > 1.0:
            return (np.exp(10 * (lM_norm - 1.0)) - 1) / (np.exp(10 * 0.6) - 1)
        return 0.0

    def tendon_force(self, lT):
        """Nonlinear tendon force-strain curve."""
        strain = (lT - self.lT_slack) / self.lT_slack
        if strain > 0:
            return self.F0 * 10 * strain ** 2  # 2차 근사
        return 0.0

    def compute_force(self, activation, lMTU, vM):
        """Compute MTU force via tendon-muscle equilibrium (Newton iteration)."""
        alpha = self.alpha0
        # 초기 추정: rigid tendon 가정
        lT = self.lT_slack
        lM = (lMTU - lT) / np.cos(alpha)

        # Newton iteration for equilibrium: F_tendon == F_muscle * cos(alpha)
        for _ in range(20):
            lM_norm = lM / self.lM_opt
            vM_norm = vM / (self.vmax * self.lM_opt)

            fL = self.force_length(lM_norm)
            fV = self.force_velocity(vM_norm)
            fPE = self.passive_force(lM_norm)

            F_muscle = self.F0 * (activation * fL * fV + fPE)
            F_m_proj = F_muscle * np.cos(alpha)
            F_t = self.tendon_force(lT)

            residual = F_m_proj - F_t
            if abs(residual) < 1e-4:
                break
            # 건 강성으로 lT 보정
            strain = (lT - self.lT_slack) / self.lT_slack
            dFt_dlT = self.F0 * 20 * max(strain, 1e-6) / self.lT_slack
            dlT = residual / dFt_dlT
            lT += dlT * 0.5  # damped update
            lM = (lMTU - lT) / np.cos(alpha)

        return F_t
```

## 5. 한계점 및 예외 처리

| 한계 | 설명 | 대응 |
|------|------|------|
| **파라미터 보정** | $F_0^M$, $l_0^M$, $l_{slack}^T$ 등 개인차가 크고 비침습 측정 어려움 | EMG-driven 보정, 최적화 기반 스케일링 |
| **준맥시멀 활성화** | 최대 활성화가 아닌 자연 동작에서 정확도 저하 [Validation study, 2025] | 활성화 동역학 정교화, EMG 기반 구동 |
| **수치 불안정성** | 강성(stiff) 건 모델에서 ODE 적분 시 발진 [Rienaecker et al., 2023] | 암시적(implicit) 적분기, rigid tendon 근사 |
| **단순화된 기어링** | 고정 우각 가정 시 동적 기어링 효과 무시 | 가변 우각 모델 적용 |
| **1D 모델 한계** | 근육 3D 형상, 근막 전달 무시 | FEM 기반 연속체 모델 (계산 비용 높음) |

## 6. 원문 포인터

| 주제 | 출처 | 위치 |
|------|------|------|
| Hill-type 모델 분류 체계 | Caillet et al., 2022 (bioRxiv) | Fig 1: 모델 구성요소 도식 |
| Force-length 곡선 | Arnold et al., 2013 (J Exp Biol) | Fig 3: 근섬유 길이별 힘 변화 |
| Force-velocity 쌍곡선 | Alcazar et al., 2019 (Front Physiol) | Fig 2: 단축/신장 영역 비교 |
| 건 에너지 저장 35-70× | Roberts & Azizi, 2011 (J Exp Biol) | Section: Tendon energy storage |
| 기어링 AGR ≈ 1.4 | Azizi et al., 2008 (PNAS) | Fig 2: 부하별 AGR 변화 |
| 수치 불안정성 분석 | Rienaecker et al., 2023 (J R Soc Interface) | Section 3: 강성 건 근사 |
| 건 순응도와 force-velocity | Nikolaidou et al., 2023 (Sci Rep) | Fig 4: 건 사전부하 효과 |
| MTU 설계와 에너지 | Uchida & Delp, 2023 (J Biomech) | Table 1: 설계 파라미터별 효과 |

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| [opensim-org/opensim-core](https://github.com/opensim-org/opensim-core) | C++/Python | 2.5k+ | ✅ | Millard2012EquilibriumMuscle 포함 |
| [opensim-org/opensim-models](https://github.com/opensim-org/opensim-models) | OpenSim | 200+ | ✅ | 다양한 근골격 모델 |
| [KULeuvenNeuromechanics/MuscleRedundancySolver](https://github.com/KULeuvenNeuromechanics/MuscleRedundancySolver) | MATLAB | 50+ | ❌ | 근 redundancy 최적 제어 |
| [stanfordnmbl/PassiveMuscleForceCalibration](https://github.com/stanfordnmbl/PassiveMuscleForceCalibration) | Python | 10+ | ❌ | 수동 근력 곡선 보정 |
| [modenaxe/awesome-biomechanics](https://github.com/modenaxe/awesome-biomechanics) | 목록 | 500+ | ❌ | 바이오역학 리소스 큐레이션 |

## 8. 출처

- [Hill-type computational models of muscle-tendon actuators: a systematic review](https://www.biorxiv.org/content/10.1101/2022.10.14.512218v2.full) — Caillet et al., 2022, 열람일 2026-03-19
- [Contribution of elastic tissues to the mechanics and energetics of muscle function during movement](https://pmc.ncbi.nlm.nih.gov/articles/PMC6514471/) — Roberts & Azizi, 2011 (review), 열람일 2026-03-19
- [How muscle fiber lengths and velocities affect muscle force generation as humans walk and run](https://pmc.ncbi.nlm.nih.gov/articles/PMC3656509/) — Arnold et al., 2013, 열람일 2026-03-19
- [Numerical instability of Hill-type muscle models](https://royalsocietypublishing.org/doi/10.1098/rsif.2022.0430) — Rienaecker et al., 2023, 열람일 2026-03-19
- [Variable gearing in pennate muscles](https://www.pnas.org/doi/10.1073/pnas.0709212105) — Azizi et al., 2008, 열람일 2026-03-19
- [OpenSim: Simulating musculoskeletal dynamics and neuromuscular control](https://pmc.ncbi.nlm.nih.gov/articles/PMC6061994/) — Seth et al., 2018, 열람일 2026-03-19
- [Validation of skeletal muscle models in multibody dynamics](https://link.springer.com/article/10.1007/s11044-025-10096-8) — Collaborative benchmark, 2025, 열람일 2026-03-19
- [Tendon compliance and preload must be considered for in vivo force-velocity](https://www.nature.com/articles/s41598-023-33643-9) — Nikolaidou et al., 2023, 열람일 2026-03-19
- [Muscle-tendon unit design and tuning for power enhancement](https://www.sciencedirect.com/science/article/pii/S0021929023001549) — Uchida & Delp, 2023, 열람일 2026-03-19
- [On the Shape of the Force-Velocity Relationship in Skeletal Muscles](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2019.00769/full) — Alcazar et al., 2019, 열람일 2026-03-19
