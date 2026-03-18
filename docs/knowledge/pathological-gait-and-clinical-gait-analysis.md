---
title: "Pathological Gait and Clinical Gait Analysis"
slug: "pathological-gait-and-clinical-gait-analysis"
date_created: "2026-03-19"
date_updated: "2026-03-19"
sources:
  - url: "https://www.mdpi.com/1424-8220/23/14/6566"
    accessed: "2026-03-19"
  - url: "https://www.sciencedirect.com/science/article/abs/pii/S0021929023003986"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC9800936/"
    accessed: "2026-03-19"
  - url: "https://pubmed.ncbi.nlm.nih.gov/32563727/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC5563001/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC5489760/"
    accessed: "2026-03-19"
  - url: "https://www.ncbi.nlm.nih.gov/books/NBK560610/"
    accessed: "2026-03-19"
  - url: "https://pmc.ncbi.nlm.nih.gov/articles/PMC1421413/"
    accessed: "2026-03-19"
---

## 1. 핵심 요약 (TL;DR)

병리적 보행(pathological gait)은 신경근골격계 질환으로 인해 정상 보행 패턴에서 벗어나는 현상이며, 임상 보행 분석(clinical gait analysis, CGA)은 3차원 운동학·운동역학·근전도·족저압 데이터를 통합하여 보행 이상을 정량화하고 치료 의사결정을 지원하는 진단 도구이다.

## 2. 기초 개념 (Foundations)

### 2.1 정상 보행 주기 [기초 지식]

보행 주기(gait cycle)는 한 발의 초기접지(initial contact)에서 같은 발의 다음 초기접지까지이며, **stance phase**(~60%)와 **swing phase**(~40%)로 나뉜다. Stance는 다시 loading response → mid-stance → terminal stance → pre-swing으로 세분화된다.

- **시공간 매개변수(spatiotemporal parameters):** 보행속도(walking speed), 보폭(stride length), 활보장(step length), 분속수(cadence), 단하지/양하지 지지기(single/double limb support)
- **운동학(kinematics):** 관절 각도 변위 — 시상면(sagittal), 관상면(frontal), 횡단면(transverse)
- **운동역학(kinetics):** 지면반력(GRF), 관절 모멘트, 관절 파워

### 2.2 병리적 보행의 정의와 원인 [기초 지식]

병리적 보행은 **1차 이상(primary deviation)**과 **보상 패턴(compensatory pattern)**의 조합으로 나타난다. 주요 원인 질환군:

| 범주 | 대표 질환 | 핵심 보행 이상 |
|------|----------|---------------|
| 상위운동신경원(UMN) | 뇌졸중, 뇌성마비, 다발성경화증 | 경직(spasticity), 근 약화, 공동운동(synergy) |
| 하위운동신경원(LMN) | 말초신경병증, 소아마비 | 이완성 마비, 족하수(foot drop) |
| 추체외로계 | 파킨슨병, 헌팅턴무도병 | 강직(rigidity), 운동완서(bradykinesia), 무도증 |
| 소뇌 | 소뇌 실조증 | 실조성 보행(ataxic gait), 넓은 지지기저면 |
| 근골격계 | 관절염, 근이영양증, 절단 | 통증성 파행, 근력 저하, 비대칭 |

### 2.3 왜 정량적 보행 분석이 필요한가 [기초 지식]

관찰적 보행 분석(observational gait analysis, OGA)은 검사자 간 신뢰도가 낮고(κ ≈ 0.3–0.6), 시상면 외 이상을 식별하기 어렵다. 3D 계측 보행 분석(3DGA)은 이를 보완하여 치료 계획 변경률 40–89%를 달성한다 [Baker, 2006; Wren et al., 2020].

## 3. 코어 로직 (Core Mechanism)

### 3.1 임상 보행 분석 파이프라인

```
Step 1: 데이터 수집
  ├─ Motion capture (marker-based 또는 markerless)
  │   → 관절 중심·세그먼트 좌표계 재구성
  ├─ Force plates (GRF Fx, Fy, Fz + CoP)
  ├─ EMG (표면 근전도, 8–16채널)
  └─ Foot pressure (pedobarography)

Step 2: 데이터 처리
  ├─ Marker labeling & gap-filling
  ├─ Low-pass filtering (Butterworth, 6–12 Hz kinematics / 25–50 Hz GRF)
  ├─ Joint angle computation (Euler/Cardan decomposition)
  └─ Inverse dynamics (Newton-Euler recursive)

Step 3: 보행 이벤트 검출
  ├─ Initial contact (IC): GRF vertical > threshold (typically 20 N)
  ├─ Toe-off (TO): GRF vertical < threshold
  └─ Time-normalize to 0–100% gait cycle

Step 4: 임상 해석
  ├─ 정상 범위 밴드(normative band) 대비 편차 시각화
  ├─ 요약 지표 산출 (GDI, GPS, EVGS 등)
  └─ 다학제 팀 회의 → 치료 의사결정
```

### 3.2 역동역학 (Inverse Dynamics) 수도코드

```python
# Newton-Euler 역동역학: 원위→근위 순차 계산
# 입력: segment kinematics, GRF, anthropometric params
# 출력: joint reaction forces & moments

for segment in [foot, shank, thigh]:  # distal → proximal
    # 선형 운동방정식
    F_proximal = m * a_com - F_distal - m * g

    # 각운동방정식 (세그먼트 질량중심 기준)
    M_proximal = (I * alpha + omega x (I * omega)
                  - M_distal
                  - r_distal x F_distal
                  - r_proximal x F_proximal)

    # 관절 파워
    P_joint = M_joint · omega_joint  # dot product
```

여기서:
- `F_distal`: 원위 관절 반력 (foot의 경우 GRF)
- `m, I`: 세그먼트 질량, 관성 텐서 (인체계측 데이터 기반)
- `a_com, alpha, omega`: 질량중심 선가속도, 각가속도, 각속도
- `r_proximal, r_distal`: 질량중심에서 각 관절까지의 위치벡터

### 3.3 주요 병리적 보행 패턴 분류

#### A. 뇌성마비 경직성 편마비 (Winters-Gage-Hicks 분류)

| Type | Ankle | Knee | Hip | 주요 원인 |
|------|-------|------|-----|----------|
| I | Equinus (swing only) | Normal | Normal | 전경골근 약화/타이밍 이상 |
| II | Equinus (전 주기) | Recurvatum 경향 | Normal | 비복근-가자미근 경직 |
| III | Equinus | Flexion (stiff) | Flexion | 슬굴곡근 경직 추가 |
| IV | Equinus | Flexion | Flexion + add/IR | 고관절 내전근·내회전근 경직 |

#### B. 뇌성마비 경직성 양마비 패턴

| 패턴 | 특징 | 운동학 |
|------|------|--------|
| True equinus | 발목 첨족, 무릎·고관절 정상 | 족관절 저굴 ↑ |
| Jump gait | 발목 첨족 + 무릎·고관절 굴곡 | 전반적 굴곡 자세 |
| Apparent equinus | 발목 정상 범위, 무릎·고관절 과굴곡 | 무릎 굴곡 ≥ 20° stance |
| Crouch gait | 전 관절 과도한 굴곡 | 무릎 굴곡 ≥ 30° stance |

#### C. 뇌졸중 편마비 보행

- **환측:** 고관절 외전·외회전 보상(circumduction), 족하수, 무릎 과신전(recurvatum), 골반 거상(hip hiking)
- **운동역학:** 환측 추진력(push-off) GRF 감소, 발목 파워 생성(A2) 저하, 무릎 흡수(K1) 비대칭
- **비대칭 지수:** stance time ratio, step length asymmetry → 예후 지표

#### D. 파킨슨병 보행

- **특징:** 보폭 감소, 분속수 상대적 유지(또는 증가), 동결(freezing of gait, FOG), 가속보행(festination)
- **운동학:** 고관절·무릎 ROM 감소, 팔 흔들림(arm swing) 감소, 전방 경사 자세
- **턴 분석:** 회전 시 보폭 수 증가(en bloc turning)

#### E. 소뇌 실조 보행

- **특징:** 넓은 지지기저면(wide base of support), 보행 변동성(stride-to-stride variability) ↑
- **정량화:** coefficient of variation(CoV) of stride time > 4% (정상 < 2%)

### 3.4 임상 요약 지표

| 지표 | 산출 방법 | MCID | 용도 |
|------|----------|------|------|
| **Gait Deviation Index (GDI)** | 15개 운동학 변수의 주성분 거리, 정상=100 | ~5 points | 전반적 보행 이상도 단일 수치 |
| **Gait Profile Score (GPS)** | 9개 운동학 변수의 RMS 편차(°) | ~1.6° (FAQ 1점 변화에 대응하는 gradient=1.5°, Robinson 2017) | GDI와 유사, 개별 변수 분해 가능 |
| **Edinburgh Visual Gait Score (EVGS)** | 17항목 관찰 점수(0–34) | ~2.4 points | 비디오 기반, 장비 불필요 |
| **Gillette Gait Index (GGI/NI)** | 16개 매개변수 다변량 거리 | - | 초기 통합 지표 |

**GDI 산출 수도코드:**

```python
# GDI (Gait Deviation Index) 계산
# 입력: 15개 kinematic waveforms (각 51 data points, 0–100% GC)

def compute_gdi(patient_data, control_database):
    """
    patient_data: shape (15, 51) — 15 kinematic variables × 51 time points
    control_database: shape (N_controls, 15, 51)
    """
    # 1. 모든 데이터를 1D 벡터로 flatten
    patient_vec = patient_data.flatten()  # (765,)
    control_vecs = control_database.reshape(N, -1)  # (N, 765)

    # 2. SVD로 주성분 추출 (상위 ~12개가 분산 99% 커버)
    mean_control = control_vecs.mean(axis=0)
    centered = control_vecs - mean_control
    U, S, Vt = np.linalg.svd(centered, full_matrices=False)
    n_components = np.argmax(np.cumsum(S**2) / np.sum(S**2) > 0.99) + 1

    # 3. 환자 데이터를 주성분 공간에 투영
    patient_centered = patient_vec - mean_control
    scores = Vt[:n_components] @ patient_centered

    # 4. Mahalanobis-like 거리 → GDI 스케일링
    control_scores = (Vt[:n_components] @ centered.T).T
    control_mean_dist = np.mean(np.linalg.norm(control_scores, axis=1))
    patient_dist = np.linalg.norm(scores)

    gdi = 100 - 10 * np.log(patient_dist / control_mean_dist)
    return gdi  # 100 = 정상, 낮을수록 이상
```

## 4. 프로젝트 적용 방안

### 4.1 보행 데이터 분석 파이프라인 구축

```
적용 대상: 보행 분석 데이터 처리 시스템
모듈 구조:
  gait_analysis/
  ├── preprocessing/
  │   ├── event_detection.py    # IC/TO 검출 (GRF threshold or kinematic)
  │   ├── filtering.py          # Butterworth low-pass
  │   └── normalization.py      # 0–100% GC time normalization
  ├── kinematics/
  │   ├── joint_angles.py       # Euler decomposition
  │   └── spatiotemporal.py     # speed, cadence, step length 등
  ├── kinetics/
  │   ├── inverse_dynamics.py   # Newton-Euler recursive
  │   └── joint_power.py        # M · omega 계산
  ├── indices/
  │   ├── gdi.py                # Gait Deviation Index
  │   ├── gps.py                # Gait Profile Score
  │   └── asymmetry.py          # 좌우 비대칭 지수
  └── classification/
      ├── cp_classifier.py      # CP 보행 패턴 분류
      └── pathology_detector.py # 일반 병리 보행 탐지
```

### 4.2 핵심 구현 고려사항

- **좌표계 표준화:** ISB 권장(Wu & Cavanagh, 1995) 사용 — 일관된 관절각 정의
- **정규화 데이터베이스:** 연령·성별·보행속도 매칭된 정상군 필요 (최소 20명 권장)
- **보행 이벤트 검출:** force plate 없는 환경에서는 가속도계 기반 알고리즘(Zeni et al., 2008) 적용
- **데이터 품질:** marker occlusion > 10 frames 연속 시 trial 제외 규칙
- **입력 데이터 형식:** C3D(업계 표준, BTK/ezc3d로 읽기), TSV/CSV(Vicon Nexus 내보내기), TRC+MOT(OpenSim 형식)

### 4.3 임상 의사결정 플로우 (뇌성마비 예시)

```
입력: 3DGA 데이터 (kinematics + kinetics + EMG)
  │
  ├─ 시상면 발목 각도 → equinus 판별
  │   ├─ stance equinus → 비복근/가자미근 경직 평가
  │   │   ├─ Silfverskiöld test (+) → 비복근 선택적 연장
  │   │   └─ Silfverskiöld test (-) → 아킬레스건 연장
  │   └─ swing-only equinus → 전경골근 약화 → AFO 처방 또는 건이전
  │
  ├─ 무릎 시상면 → crouch 판별
  │   ├─ stance knee flexion > 20° + 무릎 신전 모멘트 증가
  │   │   → 레버암 이상(lever arm dysfunction) → 대퇴골 회전 절골술 고려
  │   └─ 햄스트링 EMG 지속 활성 → 햄스트링 연장
  │
  └─ 횡단면 → 내회전 보행 판별
      ├─ 고관절 내회전 > 정상 + 족부 진행각(FPA) 내측
      │   → 대퇴 전염각(femoral anteversion) 평가 → 감염회전 절골술
      └─ 경골 내염전 → 경골 감염회전 절골술
```

### 4.4 GDI 동일 점수의 다른 병리 예시

GDI = 70일 때: (1) 뇌성마비 crouch gait — 시상면 무릎/고관절 과굴곡이 주 기여, (2) 뇌졸중 편마비 — 환측 circumduction + 건측 보상이 주 기여. 반드시 **Movement Analysis Profile(MAP)**로 개별 변수 편차를 분해하여 확인해야 한다.

## 5. 한계점 및 예외 처리

### 5.1 기술적 한계

- **Marker-based 시스템:** 연조직 아티팩트(STA)로 인한 bone tracking 오차 — 특히 대퇴부(최대 ~20mm), 횡단면 회전 데이터 신뢰성 낮음 [Leardini et al., 2005]
- **Inverse dynamics 오차 전파:** marker 오차 → 관절 중심 오차 → 모멘트 암 오차. 특히 무릎 내외반 모멘트 민감 [Stagni et al., 2000]
- **실험실 환경 제한:** 보행로 길이(~10m), force plate 수(2–4개) → steady-state 보행만 측정 가능
- **Markerless 시스템:** 건강인에서 RMSE 4–6° 수준이나 병리적 보행에서는 오차 증가 — Theia3D 연구(2024)에서 CP 환자의 무릎 시상면 RMSE가 건강인 대비 약 2–3° 증가, 특히 관상면·횡단면에서 편차 더 큼 [Kanko et al., 2024; Nat Sci Rep]

### 5.2 임상 적용 한계

- **Evidence 수준:** 3DGA의 치료 결과 개선 효과를 입증한 RCT는 2건에 불과 [Wren et al., 2020]
- **해석의 전문성:** 데이터 수집·해석에 고도 훈련 인력 필요, 표준화 부족
- **비용 장벽:** 전통적 보행 분석 실험실 구축비 $100K–$500K+, 검사 당 $1,000–$3,000
- **GDI/GPS 함정:** 단일 점수는 서로 다른 병리가 같은 수치를 산출할 수 있음 → 반드시 파형(waveform) 레벨 해석 병행

### 5.3 예외 처리 전략

| 상황 | 대응 |
|------|------|
| Foot drop으로 IC 시 GRF 패턴 비전형적 | Kinematic-based event detection으로 대체 |
| 양측 마비에서 정상 참조 비교 불가 | 좌우 비교 대신 연령별 정상군 비교 |
| 보조기(AFO) 착용 상태 분석 | 보조기 유무 조건 모두 측정, 차이 보고 |
| 인지 저하로 지시 따르기 어려움 | 습관적 보행만 측정, 최소 3 trial |

## 6. 원문 포인터

- **정상 보행 주기 정의 및 하위 단계:** Perry & Burnfield, "Gait Analysis: Normal and Pathological Function," Ch. 1–4 (stance/swing subdivisions, Table 1.1)
- **Winters-Gage-Hicks 분류:** Winters et al. (1987), "Gait patterns in spastic hemiplegia," Table 1 — 4-type 분류 체계
- **GDI 산출 알고리즘:** Schwartz & Rozumalski (2008), "The Gait Deviation Index," Figure 2 — SVD 기반 거리 메트릭
- **GPS 및 GVS:** Baker et al. (2009), "The Gait Profile Score and Movement Analysis Profile," Section 2 — 9개 kinematic variable 정의
- **EVGS MCID:** Robinson et al. (2017), Gait & Posture 52, Table 3 — MCID = 2.4 points
- **3DGA 임상 효용 체계적 문헌고찰:** Wren et al. (2020), Gait & Posture 80, Figure 1 — efficacy pyramid(기술→진단→예측→치료)
- **역동역학 방법론 오차:** Stagni et al. (2000), J Biomech 33(11), Table 2 — 관절 중심 오차가 무릎 모멘트에 미치는 영향
- **연조직 아티팩트 영향:** Leardini et al. (2005), Gait & Posture 21(2), Figure 3 — 대퇴부 STA 크기

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| [OpenSim](https://github.com/opensim-org/opensim-core) | C++/Python | 800+ | Yes | 근골격 모델링, 역동역학, 정적 최적화 |
| [Biomechanical-ToolKit (BTK)](https://github.com/Biomechanical-ToolKit/BTKCore) | C++/Python | 100+ | No | C3D 파일 I/O, 보행 이벤트 검출 |
| [pyomeca](https://github.com/pyomeca/pyomeca) | Python | 200+ | No | 생체역학 데이터 처리 (xarray 기반) |
| [GaitPy](https://github.com/matt002/GaitPy) | Python | 100+ | No | 가속도계 기반 보행 매개변수 추출 |
| [OpenCap](https://github.com/stanfordnmbl/opencap-core) | Python | 300+ | Yes (Stanford) | 스마트폰 기반 markerless 보행 분석 |
| [MOtoNMS](https://github.com/RehabEngGroup/MOtoNMS) | MATLAB | 80+ | No | C3D → OpenSim 변환 파이프라인 |

## 8. 출처

- [Clinical Gait Analysis: Characterizing Normal Gait and Pathological Deviations Due to Neurological Diseases](https://www.mdpi.com/1424-8220/23/14/6566) — Papagiannis et al., 2023, 열람일: 2026-03-19
- [Clinical gait analysis 1973–2023: Evaluating progress to guide the future](https://www.sciencedirect.com/science/article/abs/pii/S0021929023003986) — Baker et al., 2023, 열람일: 2026-03-19
- [Present and future of gait assessment in clinical practice](https://pmc.ncbi.nlm.nih.gov/articles/PMC9800936/) — Moissenet et al., 2022, 열람일: 2026-03-19
- [Clinical efficacy of instrumented gait analysis: Systematic review 2020 update](https://pubmed.ncbi.nlm.nih.gov/32563727/) — Wren et al., 2020, 열람일: 2026-03-19
- [Methodological factors affecting joint moments estimation in clinical gait analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC5563001/) — Camomilla et al., 2017, 열람일: 2026-03-19
- [Gait analysis in children with cerebral palsy](https://pmc.ncbi.nlm.nih.gov/articles/PMC5489760/) — Armand et al., 2016, 열람일: 2026-03-19
- [Gait Disturbances - StatPearls](https://www.ncbi.nlm.nih.gov/books/NBK560610/) — Pirker & Katzenschlager, 2023, 열람일: 2026-03-19
- [Gait analysis methods in rehabilitation](https://pmc.ncbi.nlm.nih.gov/articles/PMC1421413/) — Baker, 2006, 열람일: 2026-03-19
- [Explainable AI for gait analysis: systematic review](https://www.frontiersin.org/journals/bioengineering-and-biotechnology/articles/10.3389/fbioe.2025.1671344/full) — Frontiers, 2025, 열람일: 2026-03-19
