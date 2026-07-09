# Research Index

research 지식의 읽기 라우터다. **연구 작업이 필요할 때만** 이 파일을 읽고, 여기서 가리키는 필요한 detail만 추가로 연다. (context 절약 Tier 2)

## 흐름

`research-map → idea → category → paper`와 `research-map → resources → source/code 분석`. category는 research-map에 직접 붙이지 않고 idea의 근거 축으로 연결한다. raw 원본은 `AI-Sessions/raw/`(읽기 전용).

## 작업할 때만 읽는 것

| 이런 작업이면 | 읽어라 |
|---|---|
| 연구·노트북·실험 반복 패턴 확인 | `AI-Sessions/wiki/harness/patterns/research-patterns.md` |
| 연구 방향·가설 확인 | `AI-Sessions/wiki/research/idea-physical-feature-graph.md` |
| 연구 카테고리 (7개, A–G) | `AI-Sessions/wiki/research/categories/*.md` |
| 논문 근거 확인 | `AI-Sessions/wiki/research/papers/<slug>.md` |
| 구현/레퍼런스 코드 분석 | `AI-Sessions/wiki/research/sources/<slug>.md` (active: `mj-rl.md`) |
| 실험 사실 기록 | `AI-Sessions/wiki/research/experiments/` |

## Active

- active 구현 source: `AI-Sessions/wiki/research/sources/mj-rl.md` (Unitree G1 humanoid locomotion RL)
- category whitelist (7): centroidal-wbc / rl-algorithms-frameworks / morphology-aware-policy / graph-transformer-rl / loco-manipulation / dynamics-guided-rl / novelty (규칙: `harness/policies/research-policy.md`)

## 전체 인벤토리

research 작업 때만 읽는 on-demand 인벤토리다. 새 paper/source/category를 추가하거나 단일 idea note를 갱신하면 이 섹션을 갱신한다.

### Papers

- 2024-lee-footstep-planning-rl - 모델기반 footstep(3D-LIP) + 모델프리 RL, MIT Humanoid
- 2025-lee-humanoid-arm-cam-marl - CAM 정규화 멀티에이전트 RL 팔 동작
- 2017-schulman-ppo - Proximal Policy Optimization
- 2025-rsl-rl-library - 로보틱스용 경량 RL 라이브러리
- 2025-mjlab - Isaac Lab manager + MuJoCo Warp 학습 프레임워크
- 2017-vaswani-attention - Attention Is All You Need
- 2024-sferrazza-body-transformer - Body Transformer, embodiment graph masked attention
- 2013-orin-centroidal-dynamics - Centroidal dynamics & CMM
- 2023-gao-hybrid-momentum-arm-compensation - 팔 swing의 angular+linear momentum으로 biped dynamic walking disturbance를 보상하는 WBC/QP
- 2021-ying-graphormer - Graphormer: SPD·degree·edge encoding으로 GNN을 Transformer special case로 포괄
- 2025-luo-gcnt - GCNT: GCN(local)+WL(global) morphology 추출 → q/k 주입 + full attention, morphology-agnostic RL
- 2026-shin-abd-net - ABD-NET: ABA forward dynamics 구조를 GNN policy actor에 임베드, G1/Go2 sim-to-real
- 2025-zhou-hyper-gcn - Hyper-GCN: adaptive non-uniform hyper-graph(multi-joint synergy) + virtual hyper-joint(global hub) + Divergence Loss, skeleton HAR
- 2025-liu-mash - MASH: limb(팔/다리)=agent MARL(MAPPO)+shared-parameter actor+global critic, 단일 휴머노이드 locomotion coordination
- 2026-miao-gt-td3 - GT-TD3: GCN(local)+kinematic-aware biased-attention Transformer(global) actor + 무수정 TD3, 7-DoF manipulator 궤적 추종
- 2025-butterfield-mi-hgnn - MI-HGNN: URDF/kinematic topology 기반 heterogeneous graph(base/joint/foot)로 contact/GRF supervised learning
- 2025-xie-ms-hgnn - MS-HGNN: MI-HGNN에 morphological symmetry group, node orbit, physical sign encoder/decoder를 결합한 dynamics HGNN
- 2025-wei-ms-ppo - MS-PPO: MS-style symmetry graph representation을 PPO actor-critic에 적용, equivariant actor + invariant critic

### Sources

성격별 카테고리 sub-hub(`maps/resources-*`)으로 묶여 graph에 연결된다.

- frameworks: mj-rl (active implementation: Unitree G1 humanoid locomotion RL), isaac-humanoid-code (mj_rl morphology GCN을 RAL2025 MIT Humanoid IsaacLab baseline에 이식하는 실험 레포), mjlab-code, rsl-rl-code, mj-control-code
- dynamics/gpu: modern-robotics-code, casadi-on-gpu-code (mj_rl `source/assets/cuda` GPU 백엔드)
- policy/refs: body-transformer-code, graph-transformer-code, 2024-lee-footstep-planning-rl-code, 2025-lee-humanoid-arm-cam-marl-code, mpc-rl-code (mjlab push-box loco-manipulation reference), mi-hgnn-code, ms-hgnn-code

### Categories

- centroidal-wbc - Centroidal Dynamics & Model-Based WBC
- rl-algorithms-frameworks - RL Algorithms, Benchmarks & Library
- morphology-aware-policy - Morphology-Aware Policy & GNN Limits
- graph-transformer-rl - Graph Transformer for Embodied RL
- loco-manipulation - Loco-Manipulation as Coupled Whole-Body
- dynamics-guided-rl - Dynamics-Guided RL for Heavy Limbs & Payload
- novelty - Novelty Positioning

### Idea

- idea-physical-feature-graph - coupled whole-body graph transformer (morphology+centroidal token); arm dual-role 통합본
- idea-centroidal-momentum-allocation-credit - per-joint $A_G[:,j]\dot q_j$를 OPID식 step-level dense credit으로 (physical-feature-graph E2 정식화)

### Experiments

- 2026-06-25-g1-tracking-baseline - mjlab built-in Unitree G1 motion imitation/tracking PPO baseline before BoT actor comparison
- 2026-06-28-g1-centroidal-cmm-vs-baselines - graph_centroidal task에서 CMM 주입 Transformer(v0) vs Topology/BoT/GCNT 4-way (planned)
- 2026-06-29-g1-29dof-vanilla-bot - CMM/centroidal-root 확장 전 gate: mjlab 29-DOF G1 task에서 Vanilla BoT가 유의미한지 확인 (planned)
- 2026-07-08-g1-limb-marl-gcn-token-critic - 22-DOF 4-limb MARL: limb-local GCN actor ×4 + BoT token-group critic, MASH식 독립 task 설계 (planned)
