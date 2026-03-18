---
title: "척추 및 몸통 생체역학 (Spine and Trunk Biomechanics)"
slug: spine-and-trunk-biomechanics
date_created: 2026-03-19
date_updated: 2026-03-19
sources:
  - url: https://link.springer.com/article/10.1007/s10439-025-03818-8
    accessed: 2026-03-19
  - url: https://www.frontiersin.org/journals/bioengineering-and-biotechnology/articles/10.3389/fbioe.2025.1646046/full
    accessed: 2026-03-19
  - url: https://www.tandfonline.com/doi/full/10.1080/07853890.2025.2453089
    accessed: 2026-03-19
  - url: https://pmc.ncbi.nlm.nih.gov/articles/PMC3512278/
    accessed: 2026-03-19
  - url: https://www.sciencedirect.com/science/article/abs/pii/S0021929015007460
    accessed: 2026-03-19
  - url: https://link.springer.com/article/10.1007/s10237-025-01983-2
    accessed: 2026-03-19
  - url: https://www.sciencedirect.com/science/article/abs/pii/S0268003312001830
    accessed: 2026-03-19
  - url: https://pmc.ncbi.nlm.nih.gov/articles/PMC12457458/
    accessed: 2026-03-19
---

## 1. 핵심 요약 (TL;DR)

척추-몸통 시스템은 압축·전단·굽힘 하중을 동시에 지탱하며, 능동적 근육 제어(active subsystem)와 수동적 인대/추간판 구조(passive subsystem), 신경 피드백(neural control)이 삼위일체로 안정성을 확보한다. 모델링 접근은 다체동역학(MBD), 유한요소(FE), 결합 모델로 분류되며, 최근 AI 기반 환자 맞춤 모델링이 급속히 발전하고 있다.

## 2. 기초 개념 (Foundations)

### 2.1 척추의 기능적 단위 (Functional Spinal Unit, FSU)
인접한 두 척추체(vertebrae)와 그 사이의 추간판(intervertebral disc), 후방 인대 복합체(posterior ligamentous complex)로 구성된 최소 운동 단위. 6 자유도(6-DOF) 움직임을 허용하되 수동 구조로 범위를 제한한다 [기초 지식].

### 2.2 삼주 안정성 모델 (Panjabi's Three-Column Stability Model)
Panjabi(1992)가 제안한 척추 안정성의 세 하위시스템:
- **수동적 하위시스템 (Passive)**: 척추체, 추간판, 인대, 관절낭 — 종말 범위에서 저항 제공
- **능동적 하위시스템 (Active)**: 근건 단위 — 힘과 강성 생성
- **신경 제어 하위시스템 (Neural control)**: 구심성/원심성 신호에 의한 실시간 근활성 조절

이 세 시스템의 상호작용 실패가 척추 불안정성과 요통(LBP)의 핵심 기전이다 [Panjabi, 1992].

### 2.3 척추 곡률과 하중 전달
- **경추(Cervical)**: 전만(lordosis) — 두개골 하중 지지, 최대 ROM
- **흉추(Thoracic)**: 후만(kyphosis) — 흉곽과 결합, 회전 제한
- **요추(Lumbar)**: 전만 — 체중의 60%를 지지, 굴곡-신전 주 운동
- **천추(Sacral)**: 골반과 융합, 하중 전달 브릿지 [기초 지식]

### 2.4 추간판 역학
추간판은 수핵(nucleus pulposus, NP)과 섬유륜(annulus fibrosus, AF)으로 구성:
- NP: 높은 수분 함량의 젤라틴 물질, 정수압으로 축방향 하중 분산
- AF: 콜라겐 섬유가 ±25–45° 교차 배열, 인장 및 전단 저항
- 비선형 점탄성(viscoelastic) 거동: 하중 속도 의존적 강성 변화 [기초 지식]

## 3. 코어 로직 (Core Mechanism)

### 3.1 척추 하중 분석

#### 3.1.1 압축 하중 (Compression)
정상 상태에서 가장 큰 크기의 하중. 직립 시 L4-L5 디스크에 약 500–800 N, 전방 굴곡 시 최대 6000 N 이상 [Nachemson, 1981; Wilke et al., 1999].

```
압축력 = 체중분력 + 근수축력 + 복강내압 보상
F_comp = W_upper × cos(θ) + Σ(F_muscle,i × cos(α_i)) - F_IAP
```

여기서:
- `W_upper`: 상체 중량 (체중의 ~60%)
- `θ`: 몸통 전방 기울기
- `F_muscle,i`: 개별 근육의 수축력
- `α_i`: 근육 작용선과 척추축 사이각
- `F_IAP`: 복강내압(intra-abdominal pressure) 보상력

#### 3.1.2 전단 하중 (Shear)
전방 굴곡 시 체중의 중력 분력으로 발생. 안전 기준: 단일 작업 최대 허용 한계(MPL) 1000 N, 행동 한계(AL) 500 N [Gallagher & Marras, 2012].

```
F_shear = W_upper × sin(θ) + Σ(F_muscle,i × sin(α_i))
```

#### 3.1.3 굽힘 모멘트 (Bending Moment)
```
M_L5S1 = W_upper × d_CoM + W_load × d_load
```
여기서 `d_CoM`은 상체 질량 중심까지의 모멘트 팔, `d_load`는 외부 하중의 모멘트 팔.

### 3.2 근육 제어 전략

#### 3.2.1 국소-전역 근육 분류 (Local vs. Global Muscles)
| 분류 | 근육 | 역할 | 활성 패턴 |
|------|------|------|-----------|
| Local (안정화) | 다열근(multifidus), 복횡근(TrA), 횡격막 | 분절 간 강성 제공 | 방향 무관, 선행 활성화 |
| Global (운동) | 복직근, 외복사근, 척추기립근 | 큰 토크 생성, 자세 제어 | 방향 의존적 |

최적 안정성을 위해 국소 근육의 활성 비율이 전역 근육보다 상대적으로 높아야 한다 [Richardson et al., 2004].

#### 3.2.2 EMG 기반 근력 추정
```
F_muscle = EMG_processed × f(l) × f(v) × F_max × PCSA
```
여기서:
- `EMG_processed`: 정규화된 EMG (화이트닝 + 고역 필터링 적용)
- `f(l)`: 근육 길이-힘 관계
- `f(v)`: 수축 속도-힘 관계 (Hill 모델)
- `F_max`: 최대 등척 응력 (25–100 N/cm², 근육별 상이; 척추기립근 ~60, 복횡근 ~30)
- `PCSA`: 생리적 횡단면적

EMG 처리 방법에 따라 근력 추정, 척추 하중, 안정성 예측에 상당한 차이가 발생함을 유의 [Staudenmann et al., 2006].

### 3.3 흉요근막 (Thoracolumbar Fascia, TLF)

TLF는 방추상근 주위의 건막(aponeurotic) 및 근막(fascial) 면의 복합체로:
- 광배근(latissimus dorsi) → 대둔근(gluteus maximus) 방향으로 힘 전달 경로 형성
- 완전 굴곡 시 중립 대비 약 30% 신장, 탄성 에너지 저장
- 요통 환자에서 TLF 강성 증가 및 척추기립근 이완 실패(flexion-relaxation 소실) 관찰 [Willard et al., 2012; Brandl et al., 2025]

### 3.4 모델링 접근법

#### 3.4.1 다체동역학 모델 (Multibody Dynamics, MBD)
- 척추체를 강체(rigid body)로 단순화, 관절은 비선형 스프링-댐퍼
- 역동역학(inverse dynamics)으로 관절 반력/모멘트 계산 후 최적화로 근력 분배
- 장점: 계산 효율, 전신 동작 시뮬레이션 가능
- 한계: 조직 수준 응력/변형 해석 불가

```pseudocode
// 역동역학 기반 근력 분배
Input: motion_capture_data, external_forces
1. inverse_kinematics → joint_angles(t)
2. inverse_dynamics → joint_moments(t)
3. muscle_optimization:
   minimize Σ(a_i^n)  // n=2 or 3, activation criterion
   subject to:
     Σ(F_i × r_i) = M_joint  // moment equilibrium
     0 ≤ a_i ≤ 1              // activation bounds
     F_i = a_i × f(l_i) × f(v_i) × F_max_i
Output: muscle_forces, spinal_loads
```

#### 3.4.2 유한요소 모델 (Finite Element, FE)
- 척추체, 추간판, 인대를 연속체 요소로 세밀하게 표현
- 추간판: NP는 비압축성 유체 또는 hyperelastic 물질, AF는 섬유 보강 복합재료
- 최근: 딥러닝 기반 자동 분절(segmentation, >94% 정확도)로 환자 맞춤 모델 구축 가속화 [Nature Scientific Reports, 2025]
- 주요 물성 파라미터: Young's modulus, Poisson's ratio, bulk modulus, shear modulus

```pseudocode
// 환자 맞춤 FE 파이프라인
Input: CT/MRI_images
1. deep_learning_segmentation → vertebrae_masks, disc_masks
2. mesh_generation (GIBBON/FEBio) → 3D_mesh
3. material_assignment:
   cortical_bone: E=12000 MPa, ν=0.3
   cancellous_bone: E=100-450 MPa, ν=0.2
   annulus_fibrosus: Holzapfel-Gasser-Ogden model
   nucleus_pulposus: Mooney-Rivlin hyperelastic
4. boundary_conditions + loading
5. solve → stress, strain, disc_pressure
Output: patient_specific_biomechanical_response
```

#### 3.4.3 결합 모델 (Coupled MBD-FE)
- MBD에서 근력/하중 조건 산출 → FE 모델에 경계 조건으로 입력
- EMG 보조 최적화(EMG-assisted optimization)로 개인화된 근활성 반영
- 기술적 과제: 두 모델 간 인터페이스 정합, 계산 비용 [Annals of Biomedical Engineering, 2025]

## 4. 프로젝트 적용 방안

### 4.1 적용 타겟
보행 분석(gait analysis)의 상위 지체-몸통 연동 모듈에서:
- **몸통 분절 동역학**: 보행 시 흉추-요추 회전 커플링 분석
- **척추 하중 추정**: 보행 중 L4-L5 압축/전단력 실시간 추정
- **안정성 지표**: Lyapunov 지수 또는 근활성 비율 기반 동적 안정성 평가

### 4.2 뼈대 코드

```python
import numpy as np

class SpinalLoadEstimator:
    """보행 중 요추 하중 간이 추정기"""

    def __init__(self, body_mass: float):
        self.body_mass = body_mass
        self.g = 9.81
        self.upper_body_ratio = 0.6  # 상체 질량 비율
        self.W_upper = body_mass * self.upper_body_ratio * self.g

    def compression_force(self, trunk_angle_rad: float,
                          muscle_forces: np.ndarray,
                          muscle_angles_rad: np.ndarray,
                          iap_force: float = 0.0) -> float:
        """L4-L5 압축력 추정"""
        gravity_comp = self.W_upper * np.cos(trunk_angle_rad)
        muscle_comp = np.sum(muscle_forces * np.cos(muscle_angles_rad))
        return gravity_comp + muscle_comp - iap_force

    def shear_force(self, trunk_angle_rad: float,
                    muscle_forces: np.ndarray,
                    muscle_angles_rad: np.ndarray) -> float:
        """L4-L5 전단력 추정"""
        gravity_shear = self.W_upper * np.sin(trunk_angle_rad)
        muscle_shear = np.sum(muscle_forces * np.sin(muscle_angles_rad))
        return gravity_shear + muscle_shear

    def check_safety(self, f_comp: float, f_shear: float) -> dict:
        """NIOSH/Gallagher 기준 안전성 판별"""
        return {
            "compression_safe": f_comp < 3400,  # NIOSH AL (N)
            "shear_safe": f_shear < 500,        # Gallagher AL (N)
            "compression_N": round(f_comp, 1),
            "shear_N": round(f_shear, 1),
        }
```

## 5. 한계점 및 예외 처리

- **모델 단순화**: 대부분의 MBD 모델이 30° 이하 굴곡, 정적/준정적 과제만 검증됨. 보행·스포츠 등 동적 시나리오에서의 검증 부족 [Annals of Biomedical Engineering, 2025]
- **EMG-힘 변환 오차**: EMG의 확률적 특성으로 개별 근력 추정에 상당한 오차 존재. 화이트닝/고역 필터링으로 개선 가능하나 근본적 한계 [Staudenmann et al., 2006]
- **추간판 퇴행 모델링**: 퇴행 등급별 물성 변화(수핵 탈수, 섬유륜 열상)의 개인화된 파라미터 설정이 어려움
- **신경근 제어 불확실성**: 최적화 기반 근력 분배는 실제 CNS 전략과 괴리 가능. EMG-assisted 방법이 대안이나 센서 수 제한

## 6. 원문 포인터

| 논문 | 핵심 참조 위치 |
|------|---------------|
| Advances in Musculoskeletal Modeling of the Thoraco-Lumbar Spine (2025) | Table 2: 모델링 방법론 비교, Fig. 3: 검증 과제 분류 |
| Finite element models of intervertebral disc (2025) | Section 3: AF/NP 물성 모델 비교, Table 1: 구성 방정식 요약 |
| Subject-specific integrated FE musculoskeletal model (2025) | Fig. 4: 결합 모델 아키텍처, Section 2.3: EMG-assisted 최적화 |
| Thoracolumbar fascia: anatomy, function (Willard et al., 2012) | Fig. 5: TLF 3층 구조, Section: Force transmission pathways |
| Tolerance of lumbar spine to shear (Gallagher & Marras, 2012) | Table 3: 전단 내성 한계치, Fig. 2: 용량-하중 관계 |
| Streamlined patient-specific modeling (2025) | Section 2: DL segmentation pipeline, Table 2: 물성 예측 정확도 |

## 7. 공개 구현

| 레포 | 프레임워크 | Stars | 공식 | 비고 |
|------|-----------|-------|------|------|
| OpenSim (opensim-org/opensim-core) | C++/Python | 800+ | 공식 | 근골격계 MBD 시뮬레이션, 척추 모델 포함 |
| FEBio (febiosoftware/FEBio) | C++ | 200+ | 공식 | 생체역학 특화 FE 솔버, 추간판 모델 |
| GIBBON (gibbonCode/GIBBON) | MATLAB | 400+ | 공식 | FE 전처리, 의료 영상→메쉬 변환 |
| myoSuite (MyoHub/myosuite) | Python/MuJoCo | 600+ | 공식 | 근골격 RL 환경, `myoLeg`/`myoChallenge` 태스크에서 몸통 안정성 포함 |

**OpenSim 적용 경로:** `Models/Spine/` 디렉토리의 Raabe2016 full-body lumbar spine 모델 또는 `Models/FullBody/` 시리즈에서 trunk actuator 포함 모델을 활용. `analyze()` 툴로 관절 반력(JointReaction) 분석 가능.

## 8. 출처

- [Advances in Musculoskeletal Modeling of the Thoraco-Lumbar Spine: A Comprehensive Systematic Review](https://link.springer.com/article/10.1007/s10439-025-03818-8) — Annals of Biomedical Engineering, 2025, 열람일 2026-03-19
- [Main elements of current spine biomechanics research: model, installation and test data](https://www.frontiersin.org/journals/bioengineering-and-biotechnology/articles/10.3389/fbioe.2025.1646046/full) — Frontiers in Bioengineering, 2025, 열람일 2026-03-19
- [Finite element models of intervertebral disc: recent advances and prospects](https://www.tandfonline.com/doi/full/10.1080/07853890.2025.2453089) — Annals of Medicine, 2025, 열람일 2026-03-19
- [Subject-specific integrated FE musculoskeletal model of human trunk](https://link.springer.com/article/10.1007/s10237-025-01983-2) — Biomechanics and Modeling in Mechanobiology, 2025, 열람일 2026-03-19
- [Streamlined patient-specific modeling for lumbar spine](https://www.nature.com/articles/s41598-025-19664-6) — Scientific Reports, 2025, 열람일 2026-03-19
- [The thoracolumbar fascia: anatomy, function and clinical considerations](https://pmc.ncbi.nlm.nih.gov/articles/PMC3512278/) — Willard et al., Journal of Anatomy, 2012, 열람일 2026-03-19
- [Estimation of loads on human lumbar spine: A review](https://www.sciencedirect.com/science/article/abs/pii/S0021929015007460) — Journal of Biomechanics, 2016, 열람일 2026-03-19
- [Tolerance of the lumbar spine to shear](https://www.sciencedirect.com/science/article/abs/pii/S0268003312001830) — Gallagher & Marras, Clinical Biomechanics, 2012, 열람일 2026-03-19
- [Fasciae and muscle interactions in low back pain](https://pmc.ncbi.nlm.nih.gov/articles/PMC12457458/) — Brandl et al., Frontiers in Physiology, 2025, 열람일 2026-03-19
- [EMG processing effects on biomechanical models](https://www.sciencedirect.com/science/article/abs/pii/S0021929006001205) — Staudenmann et al., Journal of Biomechanics, 2006, 열람일 2026-03-19
