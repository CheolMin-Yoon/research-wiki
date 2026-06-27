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
- 2021-ying-graphormer - Graphormer: SPD·degree·edge encoding으로 GNN을 Transformer special case로 포괄
- 2025-luo-gcnt - GCNT: GCN(local)+WL(global) morphology 추출 → q/k 주입 + full attention, morphology-agnostic RL
- 2026-shin-abd-net - ABD-NET: ABA forward dynamics 구조를 GNN policy actor에 임베드, G1/Go2 sim-to-real

### Sources

성격별 카테고리 sub-hub(`maps/resources-*`)으로 묶여 graph에 연결된다.

- frameworks: mj-rl (active implementation: Unitree G1 humanoid locomotion RL), mjlab-code, rsl-rl-code, mj-control-code
- dynamics/gpu: modern-robotics-code, casadi-on-gpu-code (mj_rl `source/assets/cuda` GPU 백엔드)
- policy/refs: body-transformer-code, graph-transformer-code, 2024-lee-footstep-planning-rl-code, 2025-lee-humanoid-arm-cam-marl-code

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

### Experiments

- 2026-06-25-g1-tracking-baseline - mjlab built-in Unitree G1 motion imitation/tracking PPO baseline before BoT actor comparison
