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
  - url: "https://www.frontiersin.org/articles/10.3389/fbioe.2024.1285845/full"
    accessed: "2026-03-19"
  - url: "https://www.nature.com/articles/s41598-025-89716-4"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC12228224/"
    accessed: "2026-03-19"
  - url: "https://www.frontiersin.org/articles/10.3389/fbioe.2022.962959/full"
    accessed: "2026-03-19"
---

## 1. 핵심 요약 (TL;DR)

관절 운동학(kinematics)은 관절 각도·각속도·변위를 기술하고, 관절 동역학(kinetics)은 그 운동을 유발하는 힘·모멘트·파워를 규명한다. 근골격 모델링에서 **역운동학(IK) → 역동역학(ID) → 근력 추정(SO/CMC/EMG-driven)** 파이프라인이 표준이며, 최근 마커리스 캡처(OpenCap), 자동화(AddBiomechanics), IMU+딥러닝 기반 접근이 실험실 밖으로의 확장을 가속화하고 있다.

## 2. 기초 개념 (Foundations)

[기초 지식]

### 2.1 운동학 vs 동역학

- **운동학(Kinematics)**: 힘을 고려하지 않고 운동 자체를 기술. 관절 각도(θ), 각속도(ω), 각가속도(α), 병진 변위.
- **동역학(Kinetics)**: 운동을 발생시키는 원인. 지면반력(GRF), 관절 반력, 순 관절 모멘트(net joint moment), 관절 파워.

### 2.2 자유도(DOF)와 관절 좌표계

인체 주요 관절의 회전 자유도:

| 관절 | 자유도 | 주요 회전축 |
|------|--------|------------|
| 고관절 | 3 DOF | 굴곡/신전, 내전/외전, 내회전/외회전 |
| 슬관절 | 1–3 DOF | 주: 굴곡/신전 (6-DOF 모델에서 병진 포함) |
| 족관절 | 2 DOF | 배굴/저굴, 내번/외번 |
| 견관절 | 3 DOF | 굴곡/신전, 외전/내전, 내회전/외회전 |

관절 좌표계(JCS)는 ISB 권고안(Grood & Suntay, Wu et al.)에 따라 정의하며, 부모 세그먼트와 자식 세그먼트 각각에 고정된 축으로 Euler/Cardan 분해를 적용한다.

### 2.3 뉴턴-오일러 역동역학

뉴턴의 제2법칙을 세그먼트 체인에 적용하여 원위→근위(distal-to-proximal) 순서로 관절 반력과 순 모멘트를 계산한다:

$$\sum \mathbf{F} = m\mathbf{a}_{cm}, \quad \sum \mathbf{M} = I\boldsymbol{\alpha} + \boldsymbol{\omega} \times I\boldsymbol{\omega}$$

### 2.4 근골격 시뮬레이션 계층

1. **모델 스케일링**: 신체 계측 → 제네릭 모델 개인화
2. **역운동학(IK)**: 마커 위치 → 관절 각도 (가중 최소자승 최적화)
3. **역동역학(ID)**: IK 결과 + GRF → 순 관절 모멘트
4. **근력 분해**: 정적 최적화(SO) / CMC / EMG-driven → 개별 근력
5. **관절 접촉력**: 근력 + 외력 → 관절면 하중

## 3. 코어 로직 (Core Mechanism)

### 3.1 역운동학 (Inverse Kinematics)

**목적**: 실험 마커 좌표와 모델 가상 마커 간 오차 최소화 [Seth et al., 2018]

$$\min_{\mathbf{q}} \left[ \sum_{i=1}^{N_m} w_i \|\mathbf{x}_i^{exp} - \mathbf{x}_i^{model}(\mathbf{q})\|^2 + \sum_{j=1}^{N_c} \omega_j (q_j^{exp} - q_j)^2 \right]$$

여기서:
- $\mathbf{q}$: 일반화 좌표(관절 각도) 벡터
- $\mathbf{x}_i^{exp}$: 실험 마커 i의 3D 위치
- $\mathbf{x}_i^{model}$: 모델 마커 i의 위치 (q의 함수)
- $w_i$: 마커 가중치, $\omega_j$: 좌표 가중치

```
# 수도코드: IK 한 프레임 솔버
function solve_IK(experimental_markers, model, q_prev):
    q = q_prev  # 이전 프레임 해를 초기값으로 사용
    for iteration in range(max_iter):
        model_markers = forward_kinematics(model, q)
        error = experimental_markers - model_markers
        J = compute_marker_jacobian(model, q)  # ∂x/∂q
        delta_q = solve_weighted_least_squares(J, error, weights)
        q = q + delta_q
        if norm(delta_q) < tolerance:
            break
    return q
```

### 3.2 역동역학 (Inverse Dynamics)

**목적**: IK로 얻은 관절 각도 궤적 + 외력(GRF) → 순 관절 모멘트 [Delp et al., 2007]

재귀적 뉴턴-오일러 알고리즘:
1. **전방 패스**: 근위→원위, 각 세그먼트의 선가속도·각가속도 계산
2. **후방 패스**: 원위→근위, 관절 반력·모멘트 계산

$$\boldsymbol{\tau}_j = I_j \boldsymbol{\alpha}_j + \boldsymbol{\omega}_j \times I_j \boldsymbol{\omega}_j - \mathbf{r}_{j \to cm} \times m_j \mathbf{a}_{cm,j} + \sum_{children} (\boldsymbol{\tau}_{child} + \mathbf{r}_{j \to child} \times \mathbf{F}_{child})$$

### 3.3 근력 추정: 세 가지 접근법

#### (a) 정적 최적화 (Static Optimization)

$$\min_{\mathbf{a}} \sum_{m=1}^{M} a_m^p \quad \text{s.t.} \quad \sum_{m=1}^{M} r_m(\mathbf{q}) \cdot F_m^{max} \cdot f(l_m, v_m) \cdot a_m = \tau_j, \quad 0 \le a_m \le 1$$

- $a_m$: 근 활성도, $p$: 지수 (보통 2–3)
- $r_m$: 모멘트 암, $F_m^{max}$: 최대 등척성 근력
- $f(l_m, v_m)$: 힘-길이-속도 관계

#### (b) CMC (Computed Muscle Control)

정적 최적화의 동적 확장. 전방 시뮬레이션 + PD 피드백 제어로 추적 오차를 보상하며 근 활성도를 최적화한다 [Thelen et al., 2003].

#### (c) EMG-Driven 모델

실측 EMG 신호 → 근 활성도 → Hill-type 근건 모델 → 근력 산출. 신경 제어 패턴을 직접 반영하므로 co-contraction 등을 포착 가능 [Lloyd & Besier, 2003; Pizzolato et al., 2015].

**Hill-type 근건 모델 수식:**

$$F_m = a_m \cdot f_{act}(l_m) \cdot f_v(v_m) \cdot F_m^{max} + F_{passive}(l_m)$$

- $f_{act}(l_m)$: 활성 힘-길이 관계 (가우시안형, 최적 섬유 길이에서 최대)
- $f_v(v_m)$: 힘-속도 관계 (단축 시 감소, 신장 시 증가)
- $F_{passive}(l_m)$: 수동 탄성력 (섬유가 최적 길이 초과 시 지수적 증가)

근건 평형 조건: $F_m \cdot \cos\alpha = F_t$ (근 섬유력의 건 방향 성분 = 건 장력)

### 3.4 관절 접촉력 (Joint Contact Forces)

근력 벡터를 알면 JointReaction 분석으로 관절면 하중 산출:

$$\mathbf{F}_{contact} = \mathbf{F}_{external} + \sum_{m} \mathbf{F}_{muscle,m} - m \mathbf{a}_{segment}$$

임플란트 설계, 골관절염 진행 예측에 활용 [DeLuca et al., 2024].

### 3.5 최신 자동화 파이프라인

| 도구 | 입력 | 산출 | 특징 |
|------|------|------|------|
| **OpenCap** | 스마트폰 영상 2+ | IK + ID + SO | LSTM 마커 보정, 평균 오차 3.85° [Uhlrich et al., 2023] |
| **AddBiomechanics** | C3D 마커 데이터 | 스케일링 + IK + ID 자동화 | 순차 최적화, 수동 조정 최소화 [Werling et al., 2023] |
| **IMU+딥러닝** | IMU 가속도·자이로 | 관절 각도·모멘트 | Transfer learning, RMSE < 5° [Tan et al., 2025] |

## 4. 프로젝트 적용 방안

### 4.1 적용 타겟

보행 분석(gait analysis)에서의 하지 관절 운동학·동역학 산출 파이프라인 구축.

### 4.2 뼈대 코드: OpenSim Python API 기반 IK→ID 파이프라인

```python
import opensim as osim

# 1. 모델 로드 및 스케일링
model = osim.Model("gait2392_simbody.osim")
scale_tool = osim.ScaleTool("scale_setup.xml")
scale_tool.run()

# 2. 역운동학
ik_tool = osim.InverseKinematicsTool("ik_setup.xml")
ik_tool.setModel(model)
ik_tool.setMarkerDataFileName("markers.trc")
ik_tool.setOutputMotionFileName("ik_results.mot")
ik_tool.run()

# 3. 역동역학
id_tool = osim.InverseDynamicsTool("id_setup.xml")
id_tool.setModel(model)
id_tool.setCoordinatesFileName("ik_results.mot")
id_tool.setExternalLoadsFileName("grf.xml")
id_tool.setOutputGenForceFileName("id_results.sto")
id_tool.run()

# 4. 정적 최적화 (선택)
so_tool = osim.StaticOptimization()
model.addAnalysis(so_tool)
analyze_tool = osim.AnalyzeTool("analyze_setup.xml")
analyze_tool.run()
```

### 4.3 마커리스 대안: OpenCap 워크플로우

1. 스마트폰 2대로 동작 영상 촬영 → OpenCap 웹 업로드
2. OpenPose/HRNet → 2D 키포인트 → 삼각측량 → 3D 키포인트
3. LSTM marker enhancer → 43개 가상 해부학 마커 추정
4. OpenSim IK → 관절 각도, 최적 제어 시뮬레이션 → 관절 모멘트·힘

## 5. 한계점 및 예외 처리

| 한계 | 영향 | 대응 |
|------|------|------|
| **소프트 조직 아티팩트(STA)** | 마커 기반 IK에서 2–30mm 오차 [Leardini et al., 2005] | 클러스터 마커, 최적화 가중치 조정 |
| **근력 중복성(muscle redundancy)** | SO 해가 유일하지 않음 | EMG-informed 방법으로 보완 |
| **모델 단순화** | 인대·연골 무시, 관절면 기하학 근사 | FE 모델 결합 또는 subject-specific 영상 기반 모델 |
| **스케일링 오차** | 관절 중심·모멘트 암 부정확 | 기능적 관절 중심 계산, 의료영상 기반 개인화 |
| **실시간 처리 지연** | 31.5ms 지연(OpenSim RT) | GPU 가속, 경량 모델 사용 |
| **마커리스 정확도** | OpenCap 평균 3.85° 오차 | 보행 실험실 수준 요구 시 마커 기반 사용 |

## 6. 원문 포인터

- **IK/ID 수학적 정식화**: Seth et al. (2018), OpenSim: Simulating musculoskeletal dynamics — Section 2.2–2.4 (Kinematics/Dynamics formulation)
- **정적 최적화 목적함수**: Anderson & Pandy (2001), Static and dynamic optimization solutions — Eq. 1–3
- **CMC 알고리즘**: Thelen et al. (2003), Generating dynamic simulations of movement — Figure 2 (control loop diagram)
- **EMG-driven 모델 구조**: Lloyd & Besier (2003), An EMG-driven musculoskeletal model — Figure 1, Table 1
- **OpenCap 마커 보정 아키텍처**: Uhlrich et al. (2023), OpenCap — Figure 2 (LSTM marker enhancer pipeline)
- **AddBiomechanics 순차 최적화**: Werling et al. (2023) — Section 2 (Sequential optimization), Figure 3
- **IMU 기반 관절각 추정 정확도**: Tan et al. (2025), Learning based lower limb joint kinematic estimation — Table 2 (RMSE by joint)
- **MBD 기반 보행 분석 리뷰**: Veerkamp et al. (2024), Multibody dynamics-based musculoskeletal modeling for gait analysis — Table 3 (solver comparison)

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| [opensim-org/opensim-core](https://github.com/opensim-org/opensim-core) | C++/Python | ~2.5k | 공식 | IK, ID, SO, CMC, JointReaction 포함 |
| [stanfordnmbl/opencap-processing](https://github.com/stanfordnmbl/opencap-processing) | Python | ~200 | 공식 | OpenCap 후처리 파이프라인 |
| [keenon/AddBiomechanics](https://github.com/keenon/AddBiomechanics) | Python/C++ | ~100 | 공식 | 자동 스케일링+IK+ID |
| [modenaxe/msk-STAPLE](https://github.com/modenaxe/msk-STAPLE) | MATLAB | ~100 | 연구 | 의료영상→OpenSim 모델 자동 생성 |
| [CEINMS](https://github.com/CEINMS/CEINMS) | C++ | ~50 | 연구 | EMG-informed 신경근골격 모델 |

## 8. 출처

- [Multibody dynamics-based musculoskeletal modeling for gait analysis: a systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC11452939/) — Veerkamp et al., 2024, 열람일 2026-03-19
- [AddBiomechanics: Automating model scaling, inverse kinematics, and inverse dynamics](https://pmc.ncbi.nlm.nih.gov/articles/PMC10688959/) — Werling et al., 2023, 열람일 2026-03-19
- [OpenCap: Human movement dynamics from smartphone videos](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011462) — Uhlrich et al., 2023, 열람일 2026-03-19
- [Real-time inverse kinematics and inverse dynamics for lower limb applications using OpenSim](https://pmc.ncbi.nlm.nih.gov/articles/PMC5550294/) — Pizzolato et al., 2017, 열람일 2026-03-19
- [Estimating 3D kinematics and kinetics from virtual IMU data through musculoskeletal simulations](https://www.frontiersin.org/articles/10.3389/fbioe.2024.1285845/full) — Frontiers, 2024, 열람일 2026-03-19
- [Learning based lower limb joint kinematic estimation using open source IMU data](https://www.nature.com/articles/s41598-025-89716-4) — Tan et al., 2025, 열람일 2026-03-19
- [A PRISMA systematic review on predictive musculoskeletal simulations](https://pmc.ncbi.nlm.nih.gov/articles/PMC12228224/) — 2024, 열람일 2026-03-19
- [EMG-driven musculoskeletal model calibration with synergy extrapolation](https://www.frontiersin.org/articles/10.3389/fbioe.2022.962959/full) — Pizzolato et al., 2022, 열람일 2026-03-19
- [A calibrated EMG-informed neuromusculoskeletal model for hip and knee joint contact forces](https://www.sciencedirect.com/science/article/pii/S0021929025000971) — 2025, 열람일 2026-03-19
