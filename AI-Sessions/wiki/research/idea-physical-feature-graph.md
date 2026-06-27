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
- **Graphormer**: attention logit에 spatial/edge/degree bias를 더하는 soft-bias 원형.
- **이 아이디어의 차별점**: 구조 bias의 출처를 static distance/adjacency가 아니라 **state-dependent physical quantity(CMM, wrench)**로 두고, morphology token에 **centroidal token**을 추가한다. 단일 G1 scope에서는 morphology-agnostic universality보다 물리 coupling 표현이 우선이다.

## 설계 공간 (미확정 옵션)

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
- **E2. auxiliary prediction/reward**: CAM prediction 또는 CAM reward/penalty까지 학습 신호로 쓴다.

## 예시

- **Loco-manipulation**: 무거운 물체 운반·문 열기·이동 중 grasp에서는 손 wrench가 hand site → CAM rate로 전파된다. 좋은 policy는 hand trajectory뿐 아니라 그 wrench가 centroidal state에 미치는 효과까지 고려해야 한다.
- **Narrow terrain**: foot placement 자유도가 줄어 다리만으로 안정성 회복이 어려울수록 팔/상체 internal motion이 CMM 경유로 CAM을 보상하는 비중이 커진다.

## 피해야 할 주장

- Physical Feature Graph가 full-body dynamics의 정답 모델이다 → 아니다, 구조적 guide다.
- Attention이 물리 법칙을 새로 발견한다 → 아니다, 이미 알려진 coupling을 드러낼 뿐이다.
- Morphology graph는 필요 없다 → 아니다, 그 위에 stability-language 층을 더한다.
- Reward shaping이 완전히 사라진다 → 아니다, 일부 부담을 representation으로 옮길 뿐이다.
- 팔은 항상 안정성을 높인다 → 아니다, 잘못 조율되면 disturbance다.
- morphology-agnostic까지 노린다 → 아니다(현 scope), 추출·attention 메커니즘만 차용한다.

## Links

- 관련 category: [[centroidal-wbc]] · [[rl-algorithms-frameworks]] · [[morphology-aware-policy]] · [[graph-transformer-rl]] · [[loco-manipulation]] · [[dynamics-guided-rl]] · [[novelty]]
- 근거 논문: 2024-sferrazza-body-transformer · 2025-luo-gcnt · 2021-ying-graphormer · 2013-orin-centroidal-dynamics · 2024-lee-footstep-planning-rl · 2025-lee-humanoid-arm-cam-marl
- raw 원본: AI-Sessions/raw/ideas/physical-feature-graph.md
