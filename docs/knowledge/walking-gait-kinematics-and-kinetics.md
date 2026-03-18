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

## 1. 핵심 요약 (TL;DR)

보행 운동학(kinematics)은 관절 각도·각속도·시공간 매개변수로 기술되고, 운동역학(kinetics)은 지면반력(GRF)·관절 모멘트·관절 파워로 정량화된다. 이 두 축의 통합이 정상/병리 보행 평가, 근골격 모델 검증, 보조 장치 설계의 기반이다.

## 2. 기초 개념 (Foundations)

### 2.1 보행 주기(Gait Cycle) 정의 [기초 지식]

한쪽 발의 초기접지(initial contact)에서 같은 발의 다음 초기접지까지를 1주기(stride)로 정의한다. 입각기(stance phase, ~60%)와 유각기(swing phase, ~40%)로 구분되며, 입각기는 다시 초기접지·하중응답·중간입각·말기입각·전유각의 5개 하위 구간으로 나뉜다 [Perry & Burnfield, 2010].

### 2.2 운동학 vs 운동역학 [기초 지식]

- **운동학(Kinematics)**: 힘을 고려하지 않고 운동 자체를 기술 — 관절 각도(joint angles), 각속도, 시공간 매개변수(보폭, 보행속도, 양하지 지지시간 등).
- **운동역학(Kinetics)**: 운동을 일으키는 힘과 모멘트 — 지면반력(GRF), 관절 모멘트(joint moments), 관절 파워(joint power).

### 2.3 주요 측정 도구 [기초 지식]

| 도구 | 측정 대상 | 출력 |
|------|-----------|------|
| 광학식 모션 캡처 (Vicon, OptiTrack) | 마커 3D 좌표 | 관절 각도, 세그먼트 속도 |
| 힘판 (Force plate) | 지면반력 3성분 + COP | GRF, free moment |
| 표면 근전도 (sEMG) | 근활성도 | 근육 on/off 타이밍, 진폭 |
| IMU (가속도계+자이로) | 가속도, 각속도 | 보행 이벤트 검출, 관절 각 추정 |

## 3. 코어 로직 (Core Mechanism)

### 3.1 시상면(Sagittal Plane) 관절 운동학

**고관절(Hip)**
- 초기접지: 굴곡 ~20–30°
- 말기입각: 신전 ~10–15° (최대 신전)
- 유각기: 굴곡으로 복귀 (~35°)
- 총 ROM: ~40–45°

**슬관절(Knee)**
- 초기접지: 완전 신전 ~0°
- 하중응답: 굴곡 ~15–20° (충격 흡수)
- 중간입각: 재신전 ~5°
- 전유각~유각 초기: 최대 굴곡 ~60–65°
- 총 ROM: ~60–65°

**족관절(Ankle)**
- 초기접지: 중립 ~0°
- 하중응답: 저측굴곡 ~5–10° (heel rocker)
- 중간입각→말기입각: 배측굴곡 ~10–15°
- 전유각: 저측굴곡 ~20° (push-off)
- 총 ROM: ~25–30°

[Physiopedia, Joint Range of Motion During Gait; PM&R KnowledgeNow, Biomechanics of Normal Gait]

### 3.2 지면반력(Ground Reaction Force) 패턴

**수직 성분 (Fz)** — M자형 이중 피크
- 제1피크(loading response): ~1.0–1.2 BW
- 골(mid-stance trough): ~0.7–0.8 BW
- 제2피크(terminal stance): ~1.0–1.1 BW

**전후 성분 (Fy)** — 제동→추진
- 초기접지~중간입각: 후방 제동력 (peak ~0.15–0.25 BW)
- 중간입각~이지(toe-off): 전방 추진력 (peak ~0.15–0.25 BW)

**내외측 성분 (Fx)**
- 크기 작음 (~0.05 BW), 단하지 지지기에 내측으로 작용

[ScienceDirect, Ground Reaction Force overview; ResearchGate, Analysis and Interpretation of GRF in Normal Gait]

### 3.3 관절 모멘트와 파워

역동역학(inverse dynamics) Newton-Euler 방정식으로 산출:

$$
\mathbf{M}_j = I_j \dot{\boldsymbol{\omega}}_j + \boldsymbol{\omega}_j \times (I_j \boldsymbol{\omega}_j) - \mathbf{r}_{j} \times \mathbf{F}_{GRF} - \sum \mathbf{r}_{k} \times \mathbf{F}_{k}
$$

관절 파워:

$$
P_j = \mathbf{M}_j \cdot \boldsymbol{\omega}_j
$$

- $P > 0$: 에너지 생성(동심성 수축, generation)
- $P < 0$: 에너지 흡수(편심성 수축, absorption)

**주요 파워 버스트:**

| 레이블 | 관절 | 시기 | 유형 | 기능 |
|--------|------|------|------|------|
| H1 | Hip | 초기입각 | 생성 | 체중 지지, 전방 추진 |
| H3 | Hip | 전유각 | 생성 | 하지 풀-오프 |
| K1 | Knee | 하중응답 | 흡수 | 충격 감쇠 |
| K3 | Knee | 전유각~유각초기 | 흡수 | 유각 속도 제어 |
| A1 | Ankle | 하중응답 | 흡수 | 전족부 하강 제어 |
| A2 | Ankle | 말기입각~전유각 | 생성 | **Push-off** (전체 에너지의 ~80–85%) |

[PM&R KnowledgeNow; PMC6262765, Biomechanical effects of augmented ankle power]

### 3.4 근활성 패턴 (EMG)

5개 기본 시너지 모듈(synergy modules)이 보행 근활성 분산의 ~90%를 설명한다 [Ivanenko et al., 2004, PMC1664897].

| 근육 | 주요 활성 구간 | 기능 |
|------|---------------|------|
| Tibialis anterior | 초기접지~하중응답 + 유각기 | 배측굴곡 (발 들기, 발뒤꿈치 착지 제어) |
| Gastrocnemius/Soleus | 중간입각~말기입각 | 저측굴곡 push-off |
| Vastus lateralis/medialis | 하중응답~중간입각 | 슬관절 신전 (체중 지지) |
| Hamstrings (biceps femoris) | 말기유각~초기접지 | 유각 감속, 고관절 신전 보조 |
| Gluteus maximus | 초기접지~하중응답 | 고관절 신전 (체중 지지) |
| Gluteus medius | 입각기 전반 | 골반 안정화 (전두면) |

[Physiopedia, Muscle Activity During Gait; PMC7502709, sEMG Applied to Gait Analysis]

### 3.5 역동역학(Inverse Dynamics) 계산 파이프라인

```
1. 모션 캡처 → 마커 3D 좌표
2. 역운동학(Inverse Kinematics) → 관절 각도 q(t)
3. 수치 미분 → 각속도 ω(t), 각가속도 α(t)
4. 힘판 데이터 → GRF + COP
5. Newton-Euler 역동역학 → 관절 모멘트 M(t)
6. P(t) = M(t) · ω(t) → 관절 파워
```

OpenSim 기반 워크플로우:
1. Generic model scaling → 피험자 체형 맞춤
2. Inverse Kinematics (IK) → 실험 마커 추적
3. Residual Reduction Algorithm (RRA) → 동역학 일관성 보정
4. Computed Muscle Control (CMC) → 근흥분 추정 + 전방 시뮬레이션
5. 검증: 역동역학 vs 근육 생성 모멘트 오차 3% RMSE 이내 [PMC5507211, Hamner et al.]

## 4. 프로젝트 적용 방안

### 4.1 역동역학 계산 (Python 수도코드)

```python
import numpy as np

def inverse_dynamics_2d(segments, grf, cop):
    """
    단순화된 2D 시상면 역동역학
    segments: list of dict {mass, Icm, pos_cm, pos_prox, pos_dist, acc_cm, alpha}
    grf: (Fx, Fy) 지면반력
    cop: (x, y) 압력중심
    """
    # 원위(발)부터 근위(대퇴)로 순차 계산
    F_dist = np.array(grf)  # 발의 원위 = 지면반력
    M_dist = 0.0

    results = []
    for seg in segments:  # foot → shank → thigh 순서
        m = seg['mass']
        a_cm = seg['acc_cm']      # 질량중심 가속도
        alpha = seg['alpha']       # 각가속도
        I = seg['Icm']            # 관성모멘트

        # Newton 2법칙: F_prox + F_dist - mg = ma
        F_prox = m * a_cm - F_dist + np.array([0, m * 9.81])

        # Euler 방정식: M_prox + M_dist + r_dist×F_dist + r_prox×F_prox = Iα
        r_dist = seg['pos_dist'] - seg['pos_cm']
        r_prox = seg['pos_prox'] - seg['pos_cm']
        M_prox = (I * alpha
                  - M_dist
                  - np.cross(r_dist, F_dist)
                  - np.cross(r_prox, F_prox))

        results.append({
            'joint_force': F_prox,
            'joint_moment': M_prox
        })

        # 다음 세그먼트의 원위력 = -현재 근위력
        F_dist = -F_prox
        M_dist = -M_prox

    return results

def joint_power(moment, angular_velocity):
    """P = M · ω"""
    return moment * angular_velocity
```

### 4.2 OpenSim 연동

OpenSim 입출력 파일 형식:

| 파일 | 형식 | 용도 |
|------|------|------|
| `*.osim` | XML (모델 정의) | 근골격 모델 (관절, 근육, 접촉면 정의) |
| `*.trc` | TSV (마커 좌표) | 모션캡처 마커 3D 좌표 시계열 |
| `*.mot` | TSV (모션 데이터) | 관절 각도 또는 외력 시계열 |
| `*.sto` | TSV (결과) | 역동역학 출력 (관절 모멘트, 근활성 등) |
| `*_Setup.xml` | XML (도구 설정) | IK/ID/RRA/CMC 각 도구의 설정 파일 |

```python
import opensim as osim

# 모델 로드 (gait2392: 23 DOF, 92 musculotendon actuators)
model = osim.Model("gait2392_simbody.osim")
state = model.initSystem()

# Inverse Kinematics: .trc(마커) → .mot(관절 각도)
ik_tool = osim.InverseKinematicsTool("ik_setup.xml")
ik_tool.run()

# Inverse Dynamics: .mot(관절 각도) + GRF(.mot) → .sto(관절 모멘트)
id_tool = osim.InverseDynamicsTool("id_setup.xml")
id_tool.run()
# 출력: joint_moments.sto (시간×관절 모멘트 행렬)
```

## 5. 한계점 및 예외 처리

| 한계 | 설명 | 대응 |
|------|------|------|
| 피부 아티팩트(Soft tissue artifact) | 마커가 뼈가 아닌 피부 위에 부착 → 최대 2cm 오차 | 클러스터 마커 + 보정 알고리즘(STA 모델) |
| 역동역학 잔차(Residual forces) | 모델-실험 불일치로 비물리적 힘 발생 | RRA로 보정, 잔차 < 5% peak GRF 권장 |
| 근육 공동수축(Co-contraction) | 역동역학은 순 모멘트만 산출 → 길항근 동시수축 미반영 | EMG-informed 최적화 또는 CMC |
| 보행 속도 의존성 | 모든 매개변수가 속도에 비선형 의존 | 속도 정규화 필수, 자기선택속도(self-selected speed) 기준 |
| 전두면/횡단면 운동학 | 시상면 대비 신뢰도·반복성 낮음 | 3D 근골격 모델 + 다축 힘판 |

## 6. 원문 포인터

| 주제 | 출처 | 위치 |
|------|------|------|
| 시상면 관절 각도 정상범위 | PM&R KnowledgeNow | Section: Joint Kinematics, Table 1 |
| GRF 이중피크 패턴 | ResearchGate, Analysis of GRF in Normal Gait | Figure 1–3 |
| 관절 파워 버스트 분류 | OUHSC Gait Analysis | Section: Power Analysis |
| 5개 근시너지 모듈 | Ivanenko et al. (2004), PMC1664897 | Figure 2, Table 1 |
| OpenSim 검증 (3% RMSE) | Hamner et al. (2010), PMC5507211 | Results Section |
| 족관절 push-off 80–85% 에너지 | Nuckols et al. (2018), PMC6262765 | Figure 3 |
| 보행 속도 효과 메타분석 | Fukuchi et al. (2019), Systematic Reviews | Table 2–4 |

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| [opensim-org/opensim-core](https://github.com/opensim-org/opensim-core) | C++/Python | ~2.5k | 공식 | 역운동학, 역동역학, CMC 전체 파이프라인 |
| [stanfordnmbl/opencap-processing](https://github.com/stanfordnmbl/opencap-processing) | Python/OpenSim | ~200 | 공식 | 마커리스 모션캡처 → OpenSim 파이프라인 |
| [BMClab/BMC](https://github.com/BMClab/BMC) | Python/Jupyter | ~200 | 비공식 | 생체역학 교육용 노트북 (역동역학 예제 포함) |

## 8. 출처

- [Biomechanics of Normal Gait](https://now.aapmr.org/biomechanics-normal-gait/) — PM&R KnowledgeNow, 열람 2026-03-19
- [Effects of walking speed on gait biomechanics: a systematic review and meta-analysis](https://systematicreviewsjournal.biomedcentral.com/articles/10.1186/s13643-019-1063-z) — Fukuchi et al., 2019, 열람 2026-03-19
- [Biomechanical Analysis of Human Gait When Changing Velocity and Carried Loads: Simulation Study with OpenSim](https://pmc.ncbi.nlm.nih.gov/articles/PMC11118041/) — 2024, 열람 2026-03-19
- [Full body musculoskeletal model for muscle-driven simulation of human gait](https://pmc.ncbi.nlm.nih.gov/articles/PMC5507211/) — Hamner et al., 2010, 열람 2026-03-19
- [OpenSim: a musculoskeletal modeling and simulation framework](https://pmc.ncbi.nlm.nih.gov/articles/PMC4397580/) — Seth et al., 2011, 열람 2026-03-19
- [Biomechanical effects of augmented ankle power output during human walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC6262765/) — Nuckols et al., 2018, 열람 2026-03-19
- [Five basic muscle activation patterns account for muscle activity during human locomotion](https://pmc.ncbi.nlm.nih.gov/articles/PMC1664897/) — Ivanenko et al., 2004, 열람 2026-03-19
- [Surface Electromyography Applied to Gait Analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC7502709/) — Papagiannis et al., 2020, 열람 2026-03-19
