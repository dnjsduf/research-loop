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

## 1. 핵심 요약 (TL;DR)

보행 에너지 비용은 역진자(inverted pendulum) 메커니즘의 위치-운동 에너지 교환 효율, step-to-step transition에서의 기계적 일, 근육의 대사 효율(20–25%)에 의해 결정되며, 인간은 약 1.3 m/s에서 단위 거리당 에너지 비용(Cost of Transport)이 최소화되도록 자연스럽게 보행 속도를 선택한다.

## 2. 기초 개념 (Foundations)

[기초 지식]

### 2.1 대사 에너지와 기계적 일

생체 보행은 ATP 가수분해를 통해 화학 에너지를 기계적 일로 변환하는 과정이다. 근육의 대사 효율(metabolic efficiency)은 기계적 일/대사 비용의 비율로, 인간 보행에서 약 **20–25%**에 해당한다 [기초 지식]. 나머지 에너지는 열로 소산된다.

### 2.2 Cost of Transport (CoT)

$$
\text{CoT} = \frac{E_{\text{metabolic}}}{m \cdot g \cdot d}
$$

여기서 $E_{\text{metabolic}}$은 대사 에너지(J), $m$은 체중(kg), $g$는 중력가속도, $d$는 이동 거리(m)이다. 무차원량으로 종 간, 이동 모드 간 비교가 가능하다. 인간 보행 시 약 **0.39** [Cavagna et al., 1977].

### 2.3 역진자(Inverted Pendulum) 모델

보행의 단일 지지기(single support)에서 신체 질량 중심(CoM)은 지지발을 축으로 호를 그리며, 운동 에너지(KE)와 중력 위치 에너지(GPE)가 교환된다. 정상 보행 속도에서 이 에너지 교환율(recovery)은 최대 **65–70%**에 도달한다 [Cavagna et al., 1977].

### 2.4 왜 중요한가

보행 에너지 비용은 보조 장치(exoskeleton, prosthesis) 설계, 보행 재활, 로봇 보행 최적화의 핵심 목적함수다. 에너지 비용을 이해하면 병리적 보행(pathological gait)의 비효율 원인을 진단하고 개선 전략을 수립할 수 있다.

## 3. 코어 로직 (Core Mechanism)

### 3.1 에너지 교환 메커니즘: 역진자 회복률

보행 중 CoM의 KE와 GPE 교환을 정량화하는 **percent recovery** (%R):

$$
\%R = \frac{W_{\text{KE}} + W_{\text{GPE}} - W_{\text{ext}}}{W_{\text{KE}} + W_{\text{GPE}}} \times 100
$$

- $W_{\text{KE}}$: 운동 에너지의 양의 변화량 합
- $W_{\text{GPE}}$: 위치 에너지의 양의 변화량 합
- $W_{\text{ext}}$: CoM에 대한 외적 기계적 일

완벽한 진자라면 %R = 100%. 정상 보행 속도(~1.3 m/s)에서 인간은 약 65% 달성 [Cavagna et al., 1977].

**처리 흐름:**
```
1. 지면반력(GRF) 측정 → CoM 가속도 적분 → CoM 속도/위치
2. KE = 0.5 * m * v² 계산, GPE = m * g * h 계산
3. 외적 일(W_ext) = ∫F·v dt (양의 구간만 적분)
4. %Recovery 산출
```

### 3.2 Step-to-Step Transition Cost

역진자 모델에서 단일 지지기 동안에는 에너지가 보존되지만, **이중 지지기(double support)**에서 CoM 속도 벡터를 재지향(redirect)하는 데 기계적 일이 필요하다 [Kuo, 2005].

$$
W_{\text{transition}} \propto m \cdot v^2 \cdot \sin^2(\alpha)
$$

여기서 $\alpha$는 CoM 속도 벡터와 수평면 사이의 각도(보폭에 비례). 짧은 보폭 → 작은 $\alpha$ → 낮은 전환 비용.

**Push-off vs. Heel-strike 전략:**
- **Pre-emptive push-off** (뒤쪽 발의 발목 족저굴곡): CoM 속도를 미리 상향 조정하여 전환 비용 최소화
- **Heel-strike collision**: 에너지를 흡수(음의 일)하여 속도 재지향 → 비효율적
- 최적 전략: push-off 일 = collision 일. 에너지 비용은 순수 관절 토크만 사용할 때의 **1/4** [Kuo, 2002]

### 3.3 대사 비용의 4대 구성 요소

보행 대사 비용의 선형 분해 모델 [Kuo & Donelan, 2010, "Energetics of actively powered locomotion"; 비중 수치는 다수 연구의 종합 추정치]:

| 구성 요소 | 기여도 | 설명 |
|-----------|--------|------|
| 체중 지지 (Body Weight Support) | ~28% | 단일 지지기 동안 다리 근육의 등척성 수축 |
| CoM 속도 재지향 (Velocity Redirection) | ~45% | Step-to-step transition에서의 기계적 일 |
| 하지 스윙 (Leg Swing) | ~10% | 유각기 하지 가속/감속 |
| 지면 청소 (Ground Clearance) | ~17% | 유각기 발 들어올리기 |

### 3.4 최적 보행 속도

CoT의 U자형 속도-비용 관계:

$$
\text{CoT}(v) = \frac{P_{\text{metabolic}}(v)}{m \cdot g \cdot v}
$$

$P_{\text{metabolic}}$은 속도에 대해 대략 2차 이상으로 증가하므로, CoT는 약 **1.3 m/s** (~4.8 km/h)에서 최솟값을 가진다 [기초 지식]. 인간의 선호 보행 속도(~1.05–1.3 m/s)는 이 최적 속도에 근접한다 [Ralston, 1958; Selinger et al., 2015].

### 3.5 속도 변동의 추가 비용

일정 속도 대비 속도 진동 보행은 **6–20%** 추가 대사 비용이 발생한다. 진동 폭 ±0.13–0.27 m/s에 비례 [Seethapathi & Srinivasan, 2015]. 이는 일상 보행에서 가감속이 에너지 예산에 유의미하게 기여함을 의미한다.

### 3.6 경사 보행 에너지론

- **내리막**: ~10% 하강 경사에서 CoT 최소. 음의 일(eccentric contraction)로 에너지 흡수
- **오르막**: 15% 이상에서 CoT가 경사에 선형 비례 증가
- 15% 미만 경사에서는 비선형 관계: 역진자 에너지 회복률 변화가 주 원인 [Gottschall & Kram, 2006]

### 3.7 체격(Stature)과 에너지 비용

신장과 보행 역학의 긴밀한 결합으로, 질량 특이적 CoT와 신장 사이에 역비례 관계가 존재한다. 그러나 모든 인간은 **자신의 신장과 같은 수평 거리를 이동하는 데 동일한 질량 특이적 대사 비용**을 소비한다 [Pontzer, 2010].

## 4. 프로젝트 적용 방안

### 4.1 적용 타겟

- 보행 에너지 비용 추정 모델 구현
- 보조 장치(exoskeleton) 효과 평가를 위한 CoT 비교 파이프라인
- 보행 데이터에서 %Recovery 및 transition cost 자동 계산

### 4.2 뼈대 코드: CoT 및 %Recovery 계산

```python
import numpy as np

def cost_of_transport(metabolic_power_W: float, body_mass_kg: float,
                      speed_ms: float, g: float = 9.81) -> float:
    """무차원 Cost of Transport 계산."""
    return metabolic_power_W / (body_mass_kg * g * speed_ms)

def percent_recovery(ke: np.ndarray, gpe: np.ndarray) -> float:
    """
    역진자 에너지 회복률 계산.
    ke, gpe: 시간에 따른 KE, GPE 배열 (동일 길이).
    """
    # 외적 기계적 에너지
    total_mech = ke + gpe

    # 각 에너지의 양의 증분 합
    dke = np.diff(ke)
    dgpe = np.diff(gpe)
    dtotal = np.diff(total_mech)

    w_ke = np.sum(dke[dke > 0])
    w_gpe = np.sum(dgpe[dgpe > 0])
    w_ext = np.sum(dtotal[dtotal > 0])

    denom = w_ke + w_gpe
    if denom == 0:
        return 0.0
    return ((denom - w_ext) / denom) * 100.0

def transition_work(mass_kg: float, velocity_ms: float,
                    step_length_m: float, leg_length_m: float) -> float:
    """
    Step-to-step transition 기계적 일 추정 (simplified Kuo model).
    alpha ≈ step_length / (2 * leg_length)
    """
    alpha = step_length_m / (2.0 * leg_length_m)
    return mass_kg * velocity_ms**2 * np.sin(alpha)**2
```

## 5. 한계점 및 예외 처리

### 5.1 역진자 모델의 한계

- **매우 느린 속도**(<0.5 m/s): 에너지 교환율이 급격히 감소하며 모델 예측력 저하 [Cavagna et al., 2025 preprint]
- **병리적 보행**: 근골격 질환, 신경학적 장애에서 에너지 회복 메커니즘이 크게 변형
- **3D 운동**: 좌우 방향 CoM 이동은 단순 2D 역진자로 포착 불가

### 5.2 대사 비용 측정의 제약

- **정상 상태(steady-state) 가정**: 산소 소비량 기반 측정은 2–3분 이상 일정 속도 보행 필요
- **비정상 보행**: 가감속, 방향 전환 시 간접열량법(indirect calorimetry) 정확도 저하
- **근육 공활성(co-activation)**: 대사 비용을 증가시키지만 기계적 일에는 반영되지 않음 [Mian et al., 2006]

### 5.3 모델 간 불일치

- Bhargava et al. 모델과 Lichtwark-Wilson 모델이 실험 데이터와 가장 높은 상관(r=0.95)을 보이나, 모델 간 절대값 차이가 존재 [Koelewijn et al., 2019]

## 6. 원문 포인터

| 논문 | 핵심 위치 |
|------|----------|
| Cavagna et al., 1977 | Fig. 7 — %Recovery vs. 보행 속도 곡선; Table 1 — 종별 기계적 일 비교 |
| Kuo, 2005 | Fig. 2 — Step-to-step transition 역학 다이어그램; Eq. 1–3 — transition work 공식 |
| Donelan et al., 2018 (Nature Sci Rep) | Fig. 3 — 4대 구성 요소별 대사 비용 분해 |
| Pontzer, 2010 (JEB) | Fig. 3 — 신장 대비 질량 특이적 CoT 역비례 관계 |
| Seethapathi & Srinivasan, 2015 | Fig. 2 — 속도 진동 폭 vs. 대사 비용 증가율 |
| Peyré-Tartaruga & Coertjens, 2021 | Table 1 — 기계적 일과 에너지 비용 관계 정리 |
| Koelewijn et al., 2019 (PLOS ONE) | Table 2 — 대사 에너지 모델 간 비교 (상관 계수) |
| Mian et al., 2006 | Fig. 4 — 연령별 기계적 효율 및 근육 공활성 차이 |

## 7. 공개 구현

> 공개 구현 없음 (해당 연구 분야 특성상 범용 공개 라이브러리 부재)

참고할 수 있는 도구:

| 레포/도구 | 프레임워크 | 비고 |
|-----------|-----------|------|
| OpenSim (opensim.stanford.edu) | C++/Python | 근골격 시뮬레이션, 대사 비용 모델 내장 |
| Biomechanical ToolKit (BTK) | C++/Python | GRF/모션캡처 데이터 처리 |

## 8. 출처

- [Mechanical work in terrestrial locomotion: two basic mechanisms for minimizing energy expenditure](https://pubmed.ncbi.nlm.nih.gov/411381/) — Cavagna, Heglund & Taylor, 1977, 열람일: 2026-03-19
- [Energetic consequences of walking like an inverted pendulum: step-to-step transitions](https://pubmed.ncbi.nlm.nih.gov/15821430/) — Kuo, 2005, 열람일: 2026-03-19
- [A simple model of mechanical effects to estimate metabolic cost of human walking](https://www.nature.com/articles/s41598-018-29429-z) — Donelan et al., 2018, 열람일: 2026-03-19
- [The Energetic Cost of Walking: A Comparison of Predictive Methods](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0021290) — Browning et al., 2011, 열람일: 2026-03-19
- [Mechanical work as a (key) determinant of energy cost in human locomotion](https://physoc.onlinelibrary.wiley.com/doi/10.1113/EP089313) — Peyré-Tartaruga & Coertjens, 2021, 열람일: 2026-03-19
- [The metabolic cost of changing walking speeds is significant](https://royalsocietypublishing.org/doi/10.1098/rsbl.2015.0486) — Seethapathi & Srinivasan, 2015, 열람일: 2026-03-19
- [The mass-specific energy cost of human walking is set by stature](https://journals.biologists.com/jeb/article/213/23/3972/10061) — Pontzer, 2010, 열람일: 2026-03-19
- [Effects of aging on mechanical efficiency and muscle activation during level and uphill walking](https://pmc.ncbi.nlm.nih.gov/articles/PMC4306638/) — Mian et al., 2006, 열람일: 2026-03-19
- [Metabolic cost calculations of gait using musculoskeletal energy models, a comparison study](https://pmc.ncbi.nlm.nih.gov/articles/PMC6750598/) — Koelewijn et al., 2019, 열람일: 2026-03-19
- [Behavioural energetics in human locomotion](https://journals.biologists.com/jeb/article/228/Suppl_1/JEB248125/367009) — Selinger et al., 2025, 열람일: 2026-03-19
