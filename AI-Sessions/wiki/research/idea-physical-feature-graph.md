---
tags: [tier/upper]
type: idea
date: 2026-06-27
status: active
source: AI-Sessions/raw/ideas/physical-feature-graph.md
---

# 아이디어: Physical Feature Graph (coupled whole-body graph transformer)

## Thesis

Heavy limb·payload가 있는 humanoid loco-manipulation은 본질적으로 **coupled whole-body dynamics** 문제다. robot body를 structured token(**morphology token**)으로 표현하고, 거기에 안정성 물리 언어를 담은 **centroidal token**을 더해, policy가 *morphology 구조*와 *whole-body dynamic coupling* 둘 다에 attend하게 하는 **graph Transformer policy**를 제안한다. locomotion과 manipulation을 분리하면 학습은 쉬워지지만, arm·leg·object가 centroidal을 통해 balance에 함께 작용하는 경로가 표현에서 지워진다.

## 왜 팔이 핵심 매개인가 (arm dual-role)

다리는 LIPM/ICP·DCM·ZMP·footstep 같은 강한 reduced-order 도구를 쌓아 왔지만, 팔이 *어떤 물리적 경로로* balance에 기여하는지는 덜 명시적이다. 팔은 두 역할을 가진다.

- **접촉 중 — manipulation wrench source**: 손이 밀고/당기고/짐을 들 때 그 wrench는 손끝에 머물지 않고 base·CoM·foot contact·CAM과 coupling된다.
- **비접촉 중 — centroidal stabilizer**: 팔 자세·swing이 질량 분포·관성·angular momentum을 바꿔 CAM을 보상한다.

두 역할은 분리되어 보여도 centroidal momentum $h_G$라는 공통 타깃에서 만난다. 단, 잘못 조율된 팔은 disturbance가 된다 — 핵심은 "팔을 움직인다"가 아니라 "팔이 centroidal에 어떤 방향으로 coupling되는지"를 표현에 드러내는 것이다.

## stability language

CoM·DCM·ZMP·CMM·CAM·contact·footstep은 hand-crafted feature가 아니라, 고전 안정성 해석과 centroidal dynamics에서 추출된 **물리 언어**다. reduced-order model은 full-body를 다 설명하지 못하지만(점질량·등고 CoM·angular momentum 무시) 안정성을 판단하는 **거시 좌표계**라 강력하다. 정답 dynamics model이 아니라 agent에게 줄 **구조적 guide**이며, 축소모델과 full-body의 차이는 RL이 학습할 영역으로 남는다.

이 아이디어가 보는 네 층위:

1. robot state: `q`, `dq`, base state, command
2. physical features: CoM, DCM/ICP, ZMP, CMM, CAM
3. contact information: stance/swing, support region, footstep, contact wrench, foothold feasibility
4. body anchors: pelvis/torso/leg/foot/arm/hand

## 두 결합이 CAM hub에서 만난다 (통합의 핵심)

centroidal momentum은 정의상 $h_G = A_G(q)\,\dot q$, $\dot h_G = \sum_i \text{wrench}_i$ 이고, CMM $A_G$의 column $j$ = joint $j$의 centroidal 기여다. 즉 $h_G = \sum_j A_G[:,j]\,\dot q_j$는 구조적으로 **attention의 weighted aggregation과 동형**이다.

- **비접촉**: joint/limb node ──(CMM $A_G$)──▶ **CAM hub token** (stabilizer 경로).
- **접촉**: hand/foot **site node**의 EE wrench ──▶ **CAM token rate $\dot h_G$** (wrench-source 경로). 물체를 쥐면 payload 반력이 hand site wrench로 자연 유입된다.

둘이 하나의 CAM hub token으로 모이고, 그 위에서 Transformer **global attention**이 whole-body coupling을 학습한다. morphology graph 위에 stability-language 층을 얹는다는 주장의 구체화다.

## 아키텍처 참조점

- **Body Transformer**: morphology token + adjacency hard/mixed mask. 구조 bias는 static kinematic adjacency이고 token화는 node-type별 Linear.
- **GCNT**: GCN+WL morphology extraction + full attention + learnable distance/SPD soft-bias. GCN+hard-mask 중복을 피하고 morphology feature를 q/k로 주입한다.
- **ABD-Net**: ABA forward-dynamics 구조(child→parent)를 GNN message passing에 임베드. 단 inertia/motion-subspace를 learnable($B_i, W_i$)로 두어 dynamics를 *학습*한다. node=link(ABA가 rigid-body 재귀라서), action=joint.
- **MI-HGNN → MS-HGNN → MS-PPO**: MI-HGNN은 kinematic topology를 heterogeneous graph(base/joint/foot)로 만드는 문법이고, MS-HGNN은 여기에 morphological symmetry group(node orbit + physical sign encoder/decoder)을 붙인다. MS-PPO는 그 contract를 RL actor-critic으로 올려 actor equivariance와 critic invariance를 만든다.
- **Graphormer**: attention logit에 spatial/edge/degree bias를 더하는 soft-bias 원형.
- **이 아이디어의 차별점**: 구조 bias의 출처를 static distance/adjacency가 아니라 **state-dependent physical quantity(CMM, wrench)**로 두고, morphology token에 **centroidal token**을 추가한다. 단일 G1 scope에서는 morphology-agnostic universality보다 물리 coupling 표현이 우선이다. 정밀 비교는 아래 "관계 정답지로서의 CMM" 참조.

## 관계 정답지로서의 CMM (핵심 novelty)

node 간 *관계를 무엇으로 정의하는가*로 선행연구를 가르면 이 아이디어의 자리가 분명해진다.

| 방법 | node 관계를 어떻게 두나 | coupling 값은 |
|---|---|---|
| BoT | static adjacency mask (connectivity만) | attention이 **학습** |
| GCNT | morphology+SPD (q/k 주입, soft-bias) | attention이 **학습** |
| ABD-Net | ABA forward-dynamics 구조 (child→parent) | inertia를 여전히 **학습**($B_i, W_i$) |
| **이 연구** | **CMM $A_G(q)$** (joint→centroid 정답지) | **exact·computed·state-dependent — 안 배움** |

- BoT/GCNT는 *위상*만 주고 *양적·동적 coupling*은 안 준다. ABD-Net은 ABA *모양*의 prior를 주지만 값은 학습한다. 이 연구는 남들이 학습하는 그 coupling을 **계산해서 주입**한다(ABD-Net보다 한 단계 더 exact).
- CMM이 정의하는 관계의 *종류*는 **joint↔centroid hub의 star/gather**다(joint↔joint pairwise가 아님). joint→centroidal token으로 모이는 star 아키텍처와 정확히 일치한다. pairwise joint coupling이 필요하면 같은 GPU 파이프라인의 **M(joint-space inertia, 35×35)**가 별도 정답지다.
- $h_G = \sum_j A_G[:,j]\,\dot q_j$ 는 attention의 weighted aggregation과 동형이므로 $A_G[:,j]$는 "joint→hub aggregation 계수의 정답지"다. 단 softmax 자리에 그대로 박지 않고 **q/k에 주입해 attention을 조건화**하며, attention은 **CMM이 못 담는 residual(축소모델↔full-body 간극)만 학습**한다.

## 2026-06-29 정제: centroidal-rooted token ontology

BoT는 kinematic tree를 가져가는 architecture이므로, 순수 BoT의 token은 원칙적으로 실제 body/link여야 한다. 기존 구현에서 `root`/`base` token이 global context처럼 쓰이면 morphology token과 task/physics token이 섞인다. 이 아이디어의 정본 ontology는 이를 분리한다.

| token 종류 | 의미 | action head |
|---|---|---|
| **centroidal root token** | CoM 기준 physical root. `h_G`, `k_G`, `l_G`, projected gravity, CoM/base aggregate state를 담는다. | 없음 |
| **kinematic body/link tokens** | 실제 robot link/body: torso, pelvis, waist, thigh, shin, foot, upper/lower arm, hand 등. | actuated joint/link에만 있음 |
| **contact/site tokens** | foot/hand contact interface. 접촉 상태, wrench estimate, friction/contact margin, object target을 담는 manipulation 확장 token. | 보통 없음 |
| **task/command token** | command, goal, phase 같은 task condition. body나 centroidal state와 분리 가능. | 없음 |

따라서 이 모델의 root는 pelvis/torso link가 아니라 **CoM/centroidal root**다. torso와 pelvis는 kinematic tree 안의 실제 body/link token으로 남아야 한다. 이 구조는 "BoT를 깨는 것"이 아니라 BoT의 body-token 순수성을 보존하면서, 그 위에 centroidal dynamics root를 추가하는 확장이다.

관계도 두 층으로 나뉜다.

| edge/관계 | 출처 | 역할 |
|---|---|---|
| morphology edge | kinematic tree adjacency | body/link token 간 구조 prior |
| centroidal edge | CMM $A_G(q)$ | body/joint token이 centroidal root에 주는 state-dependent coupling |
| contact edge | measured/estimated wrench, contact state | site token이 $\dot h_G$와 force redistribution에 주는 효과 |

이때 CMM과 dCMM은 예측 label이 아니라 계산해서 주는 physical context다. 학습 대상은 `A_G`나 `\dot A_G`를 맞히는 것이 아니라, 그 물리 좌표계를 보고 어떤 joint/contact/action이 centroidal burden을 부담할지 결정하는 policy다. 즉 QP/WBC가 명시적으로 푸는 contact wrench allocation을, morphology+CMM+contact-conditioned RL policy가 interaction과 task/centroidal reward로 암묵 학습하게 한다.

## 2026-07-09 정제: MS-style symmetry contract for G1 WBC

MS-PPO가 최종 참조점이면 단순 graph topology보다 **morphological symmetry contract**가 먼저다. rsl_rl식 mirror augmentation은 학습 데이터를 대칭으로 늘리는 장치이고, MS-style 구조는 네트워크 함수공간 자체를 다음처럼 제한한다.

| 구성 | 목표 |
|---|---|
| node orbit | left/right 또는 replicated body part의 graph permutation 정의 |
| physical sign mask | mirror 시 raw feature/action 좌표의 부호 변환 정의 |
| symmetry encoder | physical transform을 graph reindexing으로 바꾼다 |
| equivariant actor | `pi(mirror(obs)) = mirror(pi(obs))` |
| invariant critic | `V(mirror(obs)) = V(obs)` |

G1 WBC momentum에는 **2 actor upper/lower**가 4 actor limb 분할보다 MS-style 주장에 더 맞다.

```text
lower actor graph:
  pelvis
  left_hip, left_knee, left_ankle
  right_hip, right_knee, right_ankle

upper actor graph:
  torso
  left_shoulder, left_elbow, left_wrist
  right_shoulder, right_elbow, right_wrist
```

- `pelvis`는 lower locomotion/support core node.
- `torso`는 upper momentum/posture core node.
- left/right limb complex nodes define C2 orbits.
- node는 반드시 scalar joint 또는 physical link와 1:1일 필요가 없다. MS-PPO G1도 hip/knee/ankle joint-complex node를 사용한다.
- CMM/CAM contribution은 scalar joint별로만 넣기보다 hip/knee/ankle, shoulder/elbow/wrist complex별 sum/mean/projection으로 올리는 편이 해부학적 node와 더 잘 맞는다.
- critic은 upper/lower graph를 모두 읽되 invariant head를 써서 symmetric states에 같은 value를 주도록 한다.

이 방향의 차별점은 "MS-PPO 복제"가 아니라 **MS-style morphology-symmetry graph + CMM/CAM-conditioned WBC momentum feature**다.

실험 명명은 다음처럼 분리한다.

1. **Pure BoT**: body/link tokens only, morphology attention only.
2. **BoT + CMM feature**: body/link tokens only, $A_G[:,j]$ 또는 $A_G[:,j]\dot q_j$를 link/joint feature로 추가.
3. **Centroidal-root BoT**: body/link tokens + CoM/centroidal root token.
4. **Centroidal-root BoT + CMM bias/contact**: centroidal root↔body attention에 CMM bias를 넣고, manipulation 단계에서 contact/site token을 추가.

## 확정 v0 스펙 (2026-06-28 세션)

> 2026-06-29 ontology 정제 기준으로는 아래 v0의 "26 actuated joint + centroidal token"은 compact proxy다. 정본 개념은 centroidal root token과 실제 kinematic body/link tokens(torso, pelvis 포함)를 분리한다. 다만 초기 구현은 action-relevant joint token만으로 축약해 검증할 수 있다.

- **backbone**: full-attention Transformer(mask 없음; ~27 token이라 BoT mask 효율 명분 무효, global gather엔 full reach 필요). 정체성 = "GCNT topology의 q/k 자리에 GCN 대신 state-dependent CMM을 꽂은 single-G1 Transformer".
- **tokenizer**: node-type별 Linear(BoT식). WL drop(단일 morphology), GCN은 CMM과 중복이라 ablation으로만.
- **node 집합**: **26 actuated joint(no-waist)** + 1 **CoM-anchored centroidal/state token**(=root, global/unmasked gather). 초기 v0 state token은 pelvis/root rate와 task command를 섞지 않고 `projected_gravity(3) + l_G(3) + k_G(3) = 9D`로 둔다.
- **node feature (raw-concat, Fork 1a)**: $[q_j,\ \dot q_j,\ a^{prev}_j,\ A_G[:,j],\ A_G[:,j]\dot q_j]$ = 15D — projection이 map($A_G[:,j]$)은 q/k(routing), contribution($A_G[:,j]\dot q_j$)은 V(content)로 쓰도록 학습. rate($\ddot q_j/\tau_j,\ \dot A_G$ = wrench 경로)는 loco-manipulation 단계 확장.
- **CMM 주입**: raw-concat이 q/k·V를 자동 분담 + **hub soft-bias 공유 $g_\psi(A_G[:,j])\to$ scalar**를 centroidal↔joint logit에 가산(명시적 라우팅). 정확 $h_G$는 attention 합이 아니라 **sum-readout**(이미 가진 CM_lin/ang)으로 centroidal token에 직접; attention은 saliency/residual만.
- **state/query 분리 메모**: 단일 centroidal/state token을 active v0로 유지하되, `command(3)`는 state가 아니라 task condition이므로 필요 시 별도 command conditioning/token으로 분리한다. `base_ang_vel(3)`는 pelvis/root rate라 ablation 후보로만 둔다. `foot_to_com_w`, contact phase, base/CoM position, quaternion, contact-relative foot geometry는 초기 schema 밖의 후보 feature다.
- **scatter (확정)**: centroidal token은 **action head 없음** — joint가 attention으로 읽는 context + critic/value node. actor=joint detokenizer, critic=centroidal token. 단방향 인과(현재상태 t→action t; t+1 안 넣음, 예측 안 씀).
- **학습/scope**: single policy, **PPO**, **예측 head 없음(E1 obs-only)**, mjlab centroidal task의 reward/obs/hypers 물려받음. scope = limb attention 활성화 검증, GRF·contact wrench 제외.
- **구현 대상**: mj_rl `graph_centroidal` task. `rl/gcnt_limb_model.py:GCNTLimbModel`을 fork(full attn + `last_attention_maps` 재사용), obs에 per-joint CMM 열 추가. 정본: [[AI-Sessions/wiki/research/sources/mj-rl|mj-rl]] · [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]].
- **DOF 주의**: CMM 35열 중 joint = LEG_COLS(6:18)∪ARM_COLS(21:35), waist(18:21) 제외, base 6열은 centroidal token.

## 설계 공간 (미확정 옵션)

> **v0 확정 (2026-06-28)**: A=A1(CoM-anchored 병합) · C=raw-concat(Fork 1a)+hub soft-bias 공유 · D=node-type Linear · E=E1(obs-only). B(EE wrench node)·rate 채널·pairwise(Gram)·M-bias는 manipulation/ablation으로 보류. 상세는 위 "확정 v0 스펙".

### A. centroidal token 구성

- **A1. 단일 hub token**: $h_G$ 6D(CAM+linear)를 하나로 둔다. 비접촉·접촉 두 경로가 모두 $h_G$로 모이므로 물리적으로 자연스럽고 token 수가 적다.
- **A2. 분할 token**: CAM / linear momentum / contact wrench 등을 분리한다. 해석력과 표현력은 늘지만 coupling 설계가 복잡해진다.

현재 직관은 A1이 더 깔끔하지만, ablation 대상이다.

### B. EE wrench node

- **B1. 분리 site node**: hand/foot site node를 limb node와 별도로 둔다. kinematic limb와 contact interface의 의미가 달라 CMM 경로와 wrench 경로가 깔끔히 갈린다.
- **B2. limb node 증강**: 기존 hand/foot limb node observation에 wrench를 붙인다. token 수는 줄지만 두 역할이 한 node에 섞인다.

현재 선호는 B1이다.

### C. CMM coupling 주입 강도

- **C1. pure global attention**: CMM을 명시적으로 쓰지 않고 coupling을 attention이 학습한다.
- **C2. CMM soft-bias**: joint↔CAM-token attention logit에 $g_\phi(A_G[:,j])$를 더한다. Graphormer/GCNT식 soft-bias 자리지만, 출처가 state-dependent $A_G$다.
- **C3. CMM node feature**: 각 joint node embedding에 $A_G[:,j]$를 포함한다.

C1은 baseline, C2/C3는 structure guide 변이다.

### D. token화 방식

단일 G1에서는 node-type별 observation 차원이 다르다(limb, EE site, CAM 등). 따라서 GCNT식 uniform MLP보다 Body Transformer식 node-type별 Linear tokenizer가 더 자연스럽다.

### E. centroidal 값 사용처

- **E1. observation only**: representation guide로만 사용한다.
- **E2. auxiliary prediction/reward**: CAM prediction 또는 CAM reward/penalty까지 학습 신호로 쓴다. 정식화 갈래 = [[AI-Sessions/wiki/research/idea-centroidal-momentum-allocation-credit|centroidal momentum allocation credit]] (per-joint $A_G[:,j]\dot q_j$를 OPID식 step-level dense credit으로).

## 예시

- **Loco-manipulation**: 무거운 물체 운반·문 열기·이동 중 grasp에서는 손 wrench가 hand site → CAM rate로 전파된다. 좋은 policy는 hand trajectory뿐 아니라 그 wrench가 centroidal state에 미치는 효과까지 고려해야 한다.
- **Narrow terrain**: foot placement 자유도가 줄어 다리만으로 안정성 회복이 어려울수록 팔/상체 internal motion이 CMM 경유로 CAM을 보상하는 비중이 커진다.

## 피해야 할 주장

- Physical Feature Graph가 full-body dynamics의 정답 모델이다 → 아니다, 구조적 guide다.
- Attention이 물리 법칙을 새로 발견한다 → 아니다, 이미 알려진 coupling을 드러낼 뿐이다.
- Morphology graph는 필요 없다 → 아니다, 그 위에 stability-language 층을 더한다.
- `root/base token`은 항상 pelvis/torso link다 → 이 아이디어에서는 아니다. pelvis/torso는 body/link token이고, root는 CoM/centroidal token으로 재정의한다.
- CMM/dCMM을 prediction loss로 맞히는 것이 핵심이다 → 아니다. CMM/dCMM은 계산해서 주는 context이고, 학습 대상은 allocation/action 전략이다.
- Reward shaping이 완전히 사라진다 → 아니다, 일부 부담을 representation으로 옮길 뿐이다.
- 팔은 항상 안정성을 높인다 → 아니다, 잘못 조율되면 disturbance다.
- morphology-agnostic까지 노린다 → 아니다(현 scope), 추출·attention 메커니즘만 차용한다.

## Links

- 관련 category: [[centroidal-wbc]] · [[rl-algorithms-frameworks]] · [[morphology-aware-policy]] · [[graph-transformer-rl]] · [[loco-manipulation]] · [[dynamics-guided-rl]] · [[novelty]]
- 근거 논문: 2024-sferrazza-body-transformer · 2025-luo-gcnt · 2026-shin-abd-net · 2021-ying-graphormer · 2013-orin-centroidal-dynamics · 2023-gao-hybrid-momentum-arm-compensation · 2024-lee-footstep-planning-rl · 2025-lee-humanoid-arm-cam-marl · 2025-butterfield-mi-hgnn · 2025-xie-ms-hgnn · 2025-wei-ms-ppo
- 실험 계획: [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]] (4-way 비교, H2=CAM reward ablation으로 representation vs reward 검증)
- raw 원본: AI-Sessions/raw/ideas/physical-feature-graph.md
