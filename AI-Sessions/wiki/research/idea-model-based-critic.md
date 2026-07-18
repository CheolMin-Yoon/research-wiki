---
tags: [tier/upper]
type: idea
date: 2026-07-18
status: active
source: AI-Sessions/raw/ideas/model-based-critic.md
---

# 아이디어: Model-Based Critic (신체 분할 multi-critic CTDE의 평가 신호를 MPC/QP가 만든다)

## Thesis (메인 인사이트 — 5단계 논증)

1. 단일 로봇 RL에서 **단일 액터–멀티 크리틱 / 멀티 액터–멀티 크리틱** 구조는 이미 우수한 성능을 입증했다 (RAL2025 Lee 계열 arm-CAM MARL, MASH limb-agent, 자체 MIT-2A2C·Spot-1A3C 라인).
2. 따라서 CTDE의 정통인 **중앙집중형 단일 크리틱** 대신 **중앙집중형 멀티 크리틱** 구조도 설계 가능하다.
3. 그러나 멀티 크리틱의 병목은 **개별 크리틱의 보상 자체를 설계해야 한다**는 것 — 지금은 사람이 reward group을 손으로 나눈다.
4. 이상적 대안은 단일 크리틱에서 **credit/value decomposition/advantage 할당**을 학습으로 얻는 것이지만, 이는 멀티 로봇·SMAC에서도 미완의 영역이고, 단일 로봇은 신체 부위가 각자 **role**을 가져 전체 task 기여 추정이 더 어렵다.
5. **제안**: model-based 최적화(MPC/QP)가 그 자리를 채운다 — **(d1) MPC/QP 기반 reward 생성**, 또는 **(d2) 멀티 크리틱 구조에서 MPC/QP가 critic의 역할 자체를 수행**.

## 분해된 평가 신호의 설계공간 (이 인사이트의 지도)

| 접근 | per-critic/per-agent 신호 출처 | 상태 |
|---|---|---|
| (a) hand-designed reward group | 사람 | 현재 MIT-2A2C(2 critic)·Spot-1A3C(3 critic)·RAL2025 계열 — 작동하나 수동, task마다 재설계 |
| (b) 학습된 분해 (value decomposition, counterfactual, learned credit) | 학습 | SMAC/멀티로봇에서도 미완 (4번). GPAE·dependence-graph가 이 계열 — 대조군 |
| (c) 계산된 분해 (CMM credit, kinematic dependence) | 물리 계산 | 기존 하위 아이디어 — 순간 물리량 기반, advantage-level |
| **(d) model-based 신호 생성 (MPC/QP)** | **최적화/모델** | **이 인사이트의 새 축** — (d1) reward 생성기, (d2) critic 그 자체 |

(c)와 (d)는 같은 원칙("학습이 감당하던 것을 물리/모델로 대체")의 두 단계다: (c)는 **순간 물리량의 분해**(CMM은 지금 이 순간의 momentum 기여), (d)는 **horizon을 가진 최적화의 평가**(MPC cost-to-go는 미래까지 본 가치)다.

## (d1) 구체화: QP task 구조가 곧 reward 분해다

WBC-QP는 이미 task별로 분해된 최적화다 — CoM/DCM tracking, angular momentum regulation, contact wrench cone, swing foot, posture 같은 **task 행마다 잔차/비용**이 나온다. 핵심 관찰:

- **QP task 행 ↔ 신체 role ↔ critic이 자연 대응**한다: lower body(support/locomotion) ← CoM·contact·swing task들, upper body(momentum/manipulation) ← angular momentum·EE·posture task들.
- 따라서 3번의 "개별 크리틱 보상 설계" 문제를 정면으로 푼다: **분해를 사람이 아니라 optimizer의 task 구조가 준다.** reward group 수동 설계(현재 (a))를 QP task 잔차 기반으로 교체.
- telescoping 주의(credit note의 원칙)는 여기선 다르게 작동한다: critic이 분리되어 각자 자기 return을 학습하므로 합산 소실 문제는 없다. 대신 **actor가 여러 critic의 advantage를 섞는 가중**이 새 설계 지점이 된다 — 2A2C의 advantage mixing이 이미 이 지점에 있다.

## (d2) 구체화: MPC cost-to-go는 이미 value function이다

MPC는 finite-horizon 최적제어를 풀므로 **optimal cost-to-go $V_{MPC}(s)$가 그 자체로 model-based value 추정**이다.

- 사용 형태(약→강): ① potential-based shaping $\Phi(s) = -V_{MPC}(s)$ (optimal policy 불변 — credit note의 Ng 1999 원칙 재사용), ② learned critic의 baseline/초기화/보조 target, ③ critic 대체(bootstrap을 $V_{MPC}$로).
- **멀티 크리틱 버전**: role별 sub-objective로 horizon 문제를 나눠 풀면 critic마다 $V^{role}_{MPC}$ — lower는 centroidal/LIPM MPC(이미 강한 축소모델 보유), upper는 momentum/EE MPC.
- **model mismatch가 본질적 한계이자 여지**: $V_{MPC}$는 축소모델(centroidal/LIPM) 기준이라 biased다. 그래서 ground truth가 아니라 **prior/baseline**로 쓰고, RL은 축소모델 밖 영역(full-body 간극)을 학습한다 — [[AI-Sessions/wiki/research/idea-physical-feature-graph|physical feature graph]]의 "attention은 CMM이 못 담는 residual만 학습"과 정확히 같은 원칙의 critic-측 버전.

## 2026-07-18 보강: 물리 매핑 사전 — Graph/Transformer credit의 Key

단일 로봇에는 joint↔task 공간을 잇는 **정확히 계산되는 매핑의 사전**이 이미 존재한다:

| 매핑 | 구조 | 연결 |
|---|---|---|
| task/body Jacobian $J(q)$ | $\dot x = J\dot q = \sum_j J[:,j]\dot q_j$ | joint rate → EE/body twist |
| Jacobian transpose | $\tau = J^\top F$ | task wrench → joint torque (쌍대) |
| twist/wrench transform ($\mathrm{Ad}$) | 좌표 변환·전파 | kinematic chain 위 운동·힘 전파 |
| CMM $A_G(q)$ | $h_G = A_G\dot q$ | joint rate → centroidal momentum ("centroidal Jacobian") |
| JSIM $M(q)$ | pairwise coupling | joint↔joint 관성 결합 |

세 가지 관찰:

1. **공통 구조 = weighted aggregation**: 모든 매핑이 $\dot y=\sum_j M[:,j]\dot q_j$ 꼴이라 attention의 가중 합과 동형이다(physical-feature-graph가 CMM에 대해 이미 지적한 동형성의 일반화). 따라서 각 매핑의 column은 (i) attention **Key**/bias(표현 축), (ii) graph **edge weight**(dependence/credit 라우팅), (iii) credit **분해 basis**(advantage 축) 어디에나 꽂힌다. 기존 하위 아이디어들은 이 사전의 특수 사례다 — CMM credit = $A_G$ 항목, kinematic dependence credit = $J$의 sparsity(도달성) 항목.
2. **2단 분해가 같은 사전에서 나온다**: (d1)의 QP task마다 자기 task Jacobian이 있으므로, **task-level 분해**(critic ↔ QP task/role)와 **joint-level 분해**(그 task Jacobian의 column별 기여)가 하나의 mapping 사전으로 통일된다. Graph/Transformer는 이 Key들을 받아 credit을 흘리는 기계이고, Key는 학습되지 않고 계산되어 주입된다.
3. **twist/wrench 쌍대성 = arm dual-role의 수학**: 운동 경로($J$, $A_G$ — 비접촉 stabilizer credit)와 힘 경로($J^\top$, wrench — 접촉 manipulation credit)가 같은 $J$의 쌍대라서, physical-feature-graph의 arm dual-role(비접촉 CAM 보상 ↔ 접촉 wrench source)이 credit 축에서도 같은 사전의 두 면으로 정식화된다.

## 2026-07-18 논문 근거 보강 (credit/multi-critic 서재 8편 ingest 후)

### 선행연구 격자 — "computed vs learned"의 완성

이 서재의 모든 **학습된 부품**마다 매핑 사전에 **계산된 대응물**이 있다. 상세는 각 paper note를 본다(2021-han-multiagent-model-based-credit, 2026-kim-gpae, 2024-kapoor-prd-mappo, 2026-le-dependence-graph-credit, 2025-zhao-mla, 2025-alegre-amor).

| 학습되는 부품 | 논문 | 우리의 계산 대응물 |
|---|---|---|
| coalition value 평가 (learned world model) | 2021-han | CMM 항등식 — 물리로 닫힌형 |
| counterfactual value $\overline{EQ}^i$ (learned critic) | 2026-kim-gpae | $A_G$ difference reward / $V_{MPC}$ |
| relevant set (critic attention) | 2024-kapoor-prd-mappo | kinematic reachability + CMM column |
| dependence graph (reverse-model MI) | 2026-le-dependence-graph-credit | kinematic tree ($\varepsilon\approx0$, Lemma 4.6이 라이선스) |
| 중간 협력 집합 CorrSet (attention) | 2025-zhao-mla | limb subtree / QP task 관여 joint 집합 |
| critic 가중·mixing (Dirichlet 조건화·CMA-ES) | 2025-alegre-amor · 2025-zhao-mla | contact 상태·모델 신뢰도 조건화 (설계 지점) |

### 얻은 정식화 도구

1. **CMM credit = exact Leave-one-out semivalue**: Han의 coalition 규약(비참여 joint→default action)이 CMM credit의 "joint 정지 counterfactual"과 동일 구조 — CAM 목적함수를 characteristic function으로 하는 game-theoretic 정식화가 성립하고, Shapley/Banzhaf 가중 변형 계열도 체계적으로 정의 가능.
2. **QP task 분해의 형식 언어**: MACA의 $r=\sum_{\mathcal G}r_{\mathcal G}$(겹침 허용 level 정식화)가 (d1)을 정확히 서술한다 — QP task = 관여 joint 부분집합 $\mathcal G$가 알려진 $r_{\mathcal G}$ 성분.
3. **per-joint advantage 배관과 비용함수**: GPAE operator(γ-contraction, λ=1 policy invariance) + DT-ISR이 S2 배관의 증명 틀·기성 해법이고, 공유 advantage의 분산이 팀 크기에 선형으로 커진다는 PRD의 명제가 분해의 필요성을 정량화한다.

### 논증 근거 갱신

- **논증 1–2 (구조 선례)**: AMOR(신체그룹 7-objective vector critic + weight conditioning), Yardımcı(dual>unified 3.5× — 단일 seed 소품이라 보조 근거), 기존 Lee arm-CAM MARL·MASH.
- **논증 2·4 (이론)**: Lyu JAIR — centralized 단일 critic은 이론적 특권이 없고 state-based critic은 부분관측 bias 위험. "단일 중앙 critic이 이상"이라는 전제 자체를 약화.
- **가설 지지**: PRD의 soft 재가중 > hard 이진 → **가중 dependence graph**(CMM column norm edge weight) 확장의 실증 지원. AMOR의 "upper↔lower tracking 충돌" 관찰(미설명)은 centroidal hub 결합의 실증 흔적 — 우리 렌즈가 설명을 제공.
- **경쟁 신호**: Yardımcı future work가 29-DoF triple critic — 분할 기준·(d1) 실험을 서두를 근거.

## 보유 자산과의 연결 (실험 진입점)

- **아키텍처 (a)가 이미 구현·학습됨**: isaac_rl MIT-2A2C(2 critic, gamma sweep 완료)·Spot-1A3C(3 critic, 5000-iter run). (d1) 검증의 즉시 실험장 — 같은 구조에서 reward group만 QP-생성으로 교체하는 A/B가 최소 실험.
- **MPC/QP 인프라 보유**: mj_rl `scripts/mpc` + sparse MPC warm-start benchmark, casadi-on-gpu GPU kernel(4096-env 스케일에서 per-step 최적화 비용이 최대 장벽인데 이를 공격할 경로), mjlab push-box MPC 참조(sources/mpc-rl-code).
- 계산 비용 완화 옵션: 저주기 평가(N step마다 $V_{MPC}$ 갱신), offline distillation($V_{MPC}$를 network로 증류해 critic 초기화), GPU 병렬 QP.

## 하위 아이디어 재배치 (이 인사이트 아래로)

- **표현 축**: [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]] — 물리를 **actor의 관측/attention**에 주입 (평가 축인 이 인사이트와 상보; 원칙 공유).
- **계산된 credit 축 (c)**: [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]] — 그 아래 [[AI-Sessions/wiki/research/idea-gpae-centroidal-advantage|idea-gpae-centroidal-advantage]]((b) 계열 대조군)·[[AI-Sessions/wiki/research/idea-kinematic-dependence-credit|idea-kinematic-dependence-credit]](mimic IL 축).

## 피해야 할 주장

- MPC를 expert로 imitation한다 → 아니다, action supervision이 아니라 **평가 신호**(reward/value)로 쓴다.
- $V_{MPC}$가 참 value다 → 아니다, 축소모델 bias — prior/baseline/shaping으로 쓰고 RL이 residual을 학습한다.
- 멀티 크리틱 구조 자체가 novelty다 → 아니다(1번 전제, 이미 입증됨). novelty는 **분해된 평가 신호의 출처**다.
- 학습된 분해 (b)는 필요 없다 → 아니다, (d)의 가치를 입증할 대조군이다 (GPAE 축).
- QP task 분해가 유일한 정답 분해다 → 아니다, 물리적으로 근거 있는 사전 구조 중 하나다.
- MPC 신호가 강할수록 좋다 → 아니다, 너무 강하면 policy가 MPC 흉내에 갇혀 축소모델 한계를 넘지 못한다.
- 매핑 사전이 credit의 전부다 → 아니다, 매핑($J$, $A_G$ 등)은 순간·국소 구조이고 horizon을 본 평가는 (d)의 MPC 몫이다 — 둘은 층위가 다르다.

## Links

- raw 원본: AI-Sessions/raw/ideas/model-based-critic.md
- 하위 아이디어: [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]] · [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|idea-centroidal-momentum-allocation-credit]]
- 관련 category: [[centroidal-wbc]] · [[rl-algorithms-frameworks]] · [[morphology-aware-policy]] · [[graph-transformer-rl]] · [[loco-manipulation]] · [[dynamics-guided-rl]] · [[novelty]]
- 근거 논문(ingested): 2025-lee-humanoid-arm-cam-marl(멀티 크리틱 per-limb 선례) · 2025-liu-mash(limb=agent MARL) · 2017-schulman-ppo · 2026-kim-gpae · 2026-le-dependence-graph-credit · 2021-han-multiagent-model-based-credit · 2024-lyu-centralized-critics · 2024-kapoor-prd-mappo · 2025-alegre-amor · 2025-zhao-mla · 2026-yardimci-critic-architecture
- 선행연구 앵커(미ingest, 정확도 미검증): POLO — Lowrey et al. 2019 (MPC cost-to-go + value learning, (d2) 정조준) · TD-MPC/TD-MPC2 — Hansen et al. (model-based value + planning) · Blending MPC & Value Function Approximation — Bhardwaj et al. 2021 · GPS — Levine & Koltun 2013 (OC as teacher, imitation 계열이라 차별점 대조용)
- 구현 자산: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] (scripts/mpc, sparse MPC warm-start) · [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]] · [[AI-Sessions/wiki/research/sources/mpc-rl-code|mpc-rl-code]]
