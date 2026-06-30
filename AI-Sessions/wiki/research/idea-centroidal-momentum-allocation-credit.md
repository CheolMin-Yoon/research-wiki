---
tags: [tier/upper]
type: idea
date: 2026-06-29
status: active
source: AI-Sessions/wiki/research/idea-physical-feature-graph.md
---

# 아이디어: Centroidal Momentum Allocation Credit (per-joint dense credit via CMM)

## Thesis

Global centroidal reward(target tracking + CAM damping)는 **episode-level outcome**이고, 이를 **CMM exact decomposition으로 joint token마다 분해한 per-token credit**을 dense shaping으로 더한다. 핵심은 OPID식 "episode/step 2층 + outcome RL primary" framing을 차용하되, step-level 신호를 *학습된 근사*가 아니라 *물리적으로 정확한* $A_G[:,j]\dot q_j$로 준다는 것이다. [[AI-Sessions/wiki/research/idea-physical-feature-graph|Physical Feature Graph]]의 E2(centroidal 값을 reward로) 축을 정식화한 갈래이며, 그 note의 v0 node feature(=$A_G[:,j]\dot q_j$를 token content로 이미 보유)와 같은 물리량을 **표현이자 credit basis**로 동시에 쓴다.

## 물리적 근거 (Orin 2013, Eq.35 — raw 검증 2026-06-29)

centroidal momentum은 joint별로 **정확히 가산적**이다:

$$h_G = \begin{bmatrix}k_G\\ l_G\end{bmatrix} = \sum_{i=1}^{N}(A_G)_i\,\dot q_i$$

- $(A_G)_i$ = joint $i$에 해당하는 CMM 열 집합. $(h_G)_i = (A_G)_i\dot q_i$는 "joint $i$만 움직였을 때 생기는 centroidal momentum"이며, 그때 로봇은 joint $i$ 기준 두 CRB로 분리된다(Orin 2013 §7, Eq.35-39). 즉 attention의 weighted aggregation과 동형($h_G = \sum_j A_G[:,j]\dot q_j$).
- base 분리: $h_G = I_G v_G$ ($I_G$=CCRBI, $v_G$=average spatial velocity, Eq.23-25). floating-base 6열은 centroidal/base 몫, actuated joint 열만 per-joint credit 대상.
- rate: $\dot h_G = \sum_i \text{wrench}_i$ (Newton-Euler). target은 momentum-level, contact 단계 확장은 rate-level.
- 주의: $k_G$(CAM)는 non-integrable. credit은 momentum/rate에 대해서만 정의하고 position target으로 적분하지 않는다.

OPID는 dense per-token credit을 log-prob shift로 *근사*해야 하지만, 여기선 CMM(`casadi-on-gpu` GPU kernel로 이미 계산)이 **exact decomposition**을 준다. ABD-Net이 coupling 값을 학습하는 것과 달리 계산해서 주입한다([[AI-Sessions/wiki/research/idea-physical-feature-graph|본 note]]의 "관계 정답지로서의 CMM" 참조).

## OPID → centroidal 매핑

| OPID (LLM agentic RL) | 이 아이디어 (G1 humanoid) |
|---|---|
| episode-level skill (global workflow / 실패 회피) | global centroidal reward: $l_G\to l_G^*$(command), $k_G\to 0$(damping) |
| step-level skill (critical timestep 국소 결정) | per-joint credit $c_j = A_G[:,j]\dot q_j$ |
| critical-first routing | contact 전환·고 CAM 구간에 credit 가중 |
| self-distillation advantage (dense, distribution-matched, RL primary 유지) | per-joint physics-exact credit (dense, RL global reward primary 유지) |
| **신호 출처 = 학습된 log-prob shift (근사)** | **신호 출처 = CMM exact decomposition (계산)** ← 차별점 |

## 이론적 위치: 멀티에이전트 아님 (앵커 교정 2026-06-29)

이 셋업은 **단일 policy · 단일 observation(full state) · factored action(26 joint diagonal Gaussian)** 이다. MARL이 푸는 *decentralization*(에이전트별 policy·부분관측)은 **없다**. 따라서 COMA를 이론 앵커로 두는 건 과하다.

- **차용하는 개념 = difference rewards (Wolpert-Tumer)**: 성분 $j$의 기여 $= G - G_{-j}$. multi-agent에서 나온 게 아니라 그 위의 일반 원리. COMA는 이걸 MARL에서 critic으로 *근사*한 한 사례일 뿐이고, 당신은 $G_{-j}$를 CMM으로 **정확히 계산**한다(차별점).
- **per-joint advantage = MARL credit 수학만 차용**: credit을 advantage 수준까지 내리려면 factored action을 "obs 공유 협력 팀"으로 다룬다. 이는 *credit-assignment 수학*이지 *decentralized execution*이 아니다.
- **단일-agent 정조준 선행연구**: action-dependent factorized baselines (Wu et al. 2018) = "단일 policy·factored action의 성분별 baseline" = COMA의 single-agent 사촌. 반론 **Mirage of Action-Dependent Baselines (Tucker et al. 2018)**: 성분별 baseline의 분산감소 이득은 종종 구현 아티팩트. → per-joint를 *분산 감소*로 정당화하면 깨진다. 정당화는 **exact difference reward로 주는 dense credit 신호**여야 하고, 그러면 Mirage critique를 비껴간다.
- **읽기 우선순위(초보 기준, PPO만 앎)**: GAE §2-3(필수, per-joint return 구현용) > difference-reward 개념 한 줄(또는 COMA counterfactual 섹션만 스킴) > (S2 때) Wu 2018 + Tucker 2018 세트.

## credit 설계 (방향 투영이 핵심)

순수 크기 $|c_j|$를 보상하면 "많이 움직여라" reward hacking이 된다. credit은 **원하는 개선 방향으로의 투영**이어야 한다.

- **CAM error 투영 (분해가 깔끔)**: CAM error $e=k_G-k_{des}$에 대해 $r_j \propto -\langle A_G^{\text{ang}}[:,j]\dot q_j,\ \hat e\rangle$. $e$를 줄이는 방향으로 기여한 joint에 +, 키운 joint에 −. → 분산형 CAM regulation. **이 "방향 투영"은 difference reward $D_j=-2\langle e,c_j\rangle+\|c_j\|^2$의 선두항과 동일**(self-term까지 더하면 exact difference reward). xy는 regulate($k_{des}{\approx}0$), z는 track($k_{des}$=command) — 기존 `dCAM_xy_penalty`/`tracking_CAM` 의도를 한 식에 통합. **frame=base(`CM_bf`)** — obs `cmm_no_waist`·`CM_joint`와 같은 축. [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|arm CAM MARL]]의 per-limb 조정을 single-policy token-level로 내린 형태.
- **linear target (allocation은 under-determined)**: $l_G^*$를 joint들에 나누는 몫은 null-space가 넓다(WBC redundancy). 따라서 target tracking은 **global reward로 유지**하고, per-joint credit은 방향이 잘 정의되는 damping/regulation 위주로 건다. allocation 자체는 centroidal hub attention이 학습.
- **double-counting 방지**: per-joint는 독립 objective가 아니라 **potential-based shaping**(Ng 1999)으로 두어 global optimum 불변. global PPO reward가 primary(=OPID 정신).

## 아키텍처 결합 (표현=credit basis 일치)

[[AI-Sessions/wiki/research/idea-physical-feature-graph|v0 스펙]] node feature가 이미 $[q_j,\dot q_j,a^{prev}_j,A_G[:,j],A_G[:,j]\dot q_j]$를 담는다. 같은 $A_G[:,j]\dot q_j$가:

- **content(V)**: token이 무엇을 centroidal에 기여하는지.
- **credit basis**: 그 token이 받을 per-step reward의 근거.

즉 한 물리량이 token 표현과 credit 신호를 동시에 정의 → BoT joint-token 구조와 OPID step-level 신호가 CMM 한 점에서 만난다.

> **frame 일치 계약 (검증 2026-06-29)**: 이 "일치"는 두 경로가 같은 축일 때만 성립한다. obs 경로 `cmm_no_waist`(observations.py)는 per-joint CMM을 **base frame**으로 회전해 token V에 넣고, reward 경로 `CentroidalCache.CM_joint`도 **base frame**으로 회전(`R_BW`)해 credit basis로 쓴다. column 순서도 둘 다 leg(6:18)+arm(21:35)=26. world frame으로 두면 일치가 깨지므로 둘을 같은 frame/순서로 유지한다.

## 검증 설계 (기존 4-way에 직교 추가)

[[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|기존 실험]] H2(=CAM reward ablation: representation vs reward)와 직결. 추가 축:

- **R0**: global centroidal reward only (outcome). baseline.
- **R1**: + per-joint CAM-damping credit (potential-based).
- **R2**: + critical-first 가중(contact 전환 구간 credit↑).
- 측정: sample efficiency, CAM RMS, 불필요한 trunk/arm motion(Orin balance 예시 지표), credit on/off 시 attention saliency 변화.

## 구현 설계 (BoT 기반, mj_rl `graph_transformer`)

> 검증: 코드 직접 확인 2026-06-29 ([[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]]). 결정 = rsl_rl 통째 fork 아님 → mj_rl `source/algorithms/`에 rsl_rl `PPO`/`RolloutStorage` **subclass** + `algorithm.class_name` cfg 주입(아래 wiring). S0 코드 landing 시작됨.

### 핵심 통찰: spatial credit은 reward가 아니라 advantage에 산다

per-joint credit을 **스칼라 reward로 합치면** $\sum_j A_G[:,j]\dot q_j = h_G$로 **telescope**되어 기존 global CAM penalty와 동일해진다 — idea가 사라진다. 따라서 credit은 **per-joint advantage(gradient) 수준**까지 도달해야 한다. 이게 "시간축(OPID/PPO) vs 공간축(이 연구)" 구분의 구현적 귀결이다. mdp/rewards.py에 항 하나 추가하는 방식으로는 **구현되지 않는다**.

### 이미 있는 것 (forward는 거의 완성)

- per-joint 기여 $A_G[:,j]\dot q_j$: `source/modules/common/tokenizer.py:106` `contribution = node_obs.cmm * dq` (N, num_joints, 6). 같은 값이 token content(V)이자 credit basis.
- 전 joint 분해 원본: `source/tasks/graph_transformer/mdp/centroidal.py`의 `self.pin.CMM`(N,6,NV)·`pdq`. `CM_leg/CM_arm`는 합산형이라 per-joint는 합산 전 단계로 얻음.
- per-joint action head: `source/modules/common/detokenizer.py` `action_head_type="per_token"` 지원.

### wiring 결정 (검증 2026-06-29): rsl_rl 통째 fork 불필요

rsl_rl `OnPolicyRunner`가 `alg_class = resolve_callable(cfg["algorithm"]["class_name"])`로 PPO 클래스를 **동적 로드**한다(`construct_algorithm`). mjlab `RslRlPpoAlgorithmCfg.class_name` 기본값 `"PPO"`. 따라서 모델을 `modules.body_transformer:BodyTransformer`로 갈아끼우듯, **`algorithm.class_name="algorithms.graph_ppo:GraphPPO"`로 mj_rl 로컬 클래스 주입**으로 끝. rsl_rl을 워크스페이스에 fork하면 mjlab 1.4.0의 `rsl-rl-lib==5.2.0` 하드 핀과 충돌하므로 **금지**. 대신 mj_rl `source/algorithms/`에 rsl_rl `PPO`·`RolloutStorage`를 **subclass**한 `GraphPPO`/`GraphRolloutStorage`를 두고 cfg로 선택(기존 module 주입 패턴과 동일).

### S0 진행 상태 (구현 시작, 2026-06-29)

- `mdp/centroidal.py`: `CentroidalCache.CM_joint` (N,6,26) 노출 — per-joint `A_G[:,j]·dq_j`, **base frame**(`R_BW` 회전, obs `cmm_no_waist`·`CM_bf`와 같은 축). actuated 26열 = leg(6:18)∪arm(21:35); Σ_j = `CM_bf`의 actuated 몫(base/waist 제외).
- `mdp/credit.py`: `cam_joint_difference_reward`(N,26 = $D_j=-2\langle e,c_j\rangle+\|c_j\|^2$, $e=$`CM_bf−CM_des_bf`의 ang, per-joint PPO advantage 소스) + `cam_credit_dispersion`(N, telescoping-safe S0 진단). reward cfg 미연결(behavior 무변경). 컴파일 통과.
- 다음: S0 = dispersion 로깅으로 credit 분산·attention saliency 상관 확인 → S1 헤드 → S2 `source/algorithms/graph_ppo.py`.

### 빠진 것 (advantage 측, S2 — `source/algorithms/` subclass)

1. **per-joint reward = exact difference reward.** CAM penalty $G=-\|k_G\|^2$, joint $j$ 정지 counterfactual $k_{-j}=k_G-c_j$ ($c_j=A_G^{\text{ang}}[:,j]\dot q_j$):
   $$D_j = G - G_{-j} = -2\langle k_G, c_j\rangle + \|c_j\|^2$$
   = "방향 투영" credit의 closed form. difference reward($G-G_{-j}$, Wolpert-Tumer)를 CMM으로 정확히 계산(centroidal.py 보유) — COMA가 critic으로 *근사*하는 그 baseline의 exact 버전.
2. **per-joint value head**: detokenizer를 joint token마다 $V_j(s)$ 출력(현 hub 단일 value → per-joint baseline).
3. **PPO surrogate**: `(ratio * adv).mean()` → $\sum_j \text{ratio}_j\, A_j$ (diagonal Gaussian이라 log_prob 합산 전 per-joint 자연 분해). storage advantage `(T,N)` → `(T,N,num_joints)`. 단일 policy·factored action(MARL 아님)이라 정조준 선행 = action-dependent factorized baselines(Wu 2018); exact difference reward라 baseline 학습조차 불필요. ⚠️ Mirage(Tucker 2018) 경고대로 per-joint를 분산 감소가 아니라 dense credit으로 정당화.

### 단계

- **S0(검증)**: $D_j$ 로깅만 — joint별 credit 분산·attention saliency 상관 확인(헛수고 방지). reward/PPO 무변경.
- **S1**: detokenizer per_token action + per-joint value head로 구조 완성.
- **S2(핵심)**: vendor rsl_rl PPO를 per-joint advantage로. linear target은 telescoping/under-determined라 global 유지, per-joint는 CAM damping 위주.

## 피해야 할 주장

- per-joint credit을 스칼라 reward에 더하면 구현된다 → 아니다, $\sum_j$가 telescope되어 global term으로 환원. advantage 수준까지 가야 함.
- per-joint $|A_G[:,j]\dot q_j|$를 키우면 좋다 → 아니다, 방향 투영 없으면 motion-maximizing hacking.
- linear target도 joint마다 정확히 분해해 reward로 박는다 → 아니다, allocation은 under-determined라 global 유지 + hub attention 학습.
- OPID 메커니즘(log-prob re-scoring)을 그대로 이식한다 → 아니다, framing만 차용하고 신호는 CMM exact decomposition으로 대체.
- per-joint credit이 global reward를 대체한다 → 아니다, potential-based dense shaping이고 outcome RL이 primary.
- base DOF도 credit 대상 → 아니다, base 6열은 centroidal token 몫, actuated joint만.
- 이 방법은 멀티에이전트다 → 아니다, 단일 policy·factored action. MARL credit 수학만 차용, decentralization/부분관측은 없음. 앵커는 COMA가 아니라 difference rewards(일반).
- per-joint advantage를 분산 감소로 정당화 → Mirage(Tucker 2018)에 취약. 정당화는 exact difference reward의 dense credit 신호.

## Links

- 상위 아이디어: [[AI-Sessions/wiki/research/idea-physical-feature-graph|idea-physical-feature-graph]] (E2 축의 정식화)
- 관련 category: [[centroidal-wbc]] · [[dynamics-guided-rl]] · [[graph-transformer-rl]] · [[rl-algorithms-frameworks]] · [[novelty]]
- 근거 논문: [[AI-Sessions/wiki/research/papers/2013-orin-centroidal-dynamics|2013-orin-centroidal-dynamics]] (Eq.35 per-joint 분해) · [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]] (per-limb CAM)
- 외부 framing 참조: OPID — On-Policy Skill Distillation for Agentic RL (arXiv 2606.26790, LLM agentic RL; 메커니즘 아닌 episode/step 2층 framing만 차용)
- credit-assignment 선행연구(미ingest, 정확도 미검증): difference rewards (Wolpert-Tumer, 개념 앵커, $G-G_{-j}$) · action-dependent factorized baselines (Wu et al. 2018, 단일-agent factored action 정조준) · Mirage of Action-Dependent Baselines (Tucker et al. 2018, 반론·정당화 주의) · COMA (Foerster et al. 2018, MARL 사촌) · GAE (Schulman et al. 2015, per-joint return 구현 필수)
- 구현 정본: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] · [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]
- 실험 계획: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]]
