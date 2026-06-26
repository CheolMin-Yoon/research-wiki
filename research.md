# Research Index

research 지식의 읽기 라우터다. **연구 작업이 필요할 때만** 이 파일을 읽고, 여기서 가리키는 필요한 detail만 추가로 연다. (context 절약 Tier 2)

## 흐름

`idea → concept → paper`, 그리고 `resources → source/code 분석`. raw 원본은 `AI-Sessions/raw/`(읽기 전용).

## 작업할 때만 읽는 것

| 이런 작업이면 | 읽어라 |
|---|---|
| 연구·노트북·실험 반복 패턴 확인 | `AI-Sessions/wiki/harness/patterns/research-patterns.md` |
| 연구 방향·가설 확인 | `AI-Sessions/wiki/research/ideas/idea-*.md` |
| 핵심 개념 정리 (4개) | `AI-Sessions/wiki/research/concepts/{transformer,ppo,lipm,centroidal}.md` |
| 논문 근거 확인 | `AI-Sessions/wiki/research/papers/<slug>.md` |
| 구현/레퍼런스 코드 분석 | `AI-Sessions/wiki/research/sources/<slug>.md` (active: `mj-rl.md`) |
| 실험 사실 기록 | `AI-Sessions/wiki/research/experiments/` |

## Active

- active 구현 source: `AI-Sessions/wiki/research/sources/mj-rl.md` (Unitree G1 humanoid locomotion RL)
- concept whitelist: transformer / ppo / lipm / centroidal (규칙: `harness/policies/research-policy.md`)

## 전체 인벤토리

research 작업 때만 읽는 on-demand 인벤토리다. 새 paper/source/concept/idea를 추가하면 이 섹션을 갱신한다.

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
- 2026-shin-abd-net - ABD-NET: ABA forward dynamics 구조를 GNN policy actor에 임베드, G1/Go2 sim-to-real

### Sources

- mj-rl - active implementation: Unitree G1 humanoid locomotion RL
- 2024-lee-footstep-planning-rl-code
- 2025-lee-humanoid-arm-cam-marl-code
- rsl-rl-code
- mjlab-code
- body-transformer-code
- modern-robotics-code
- mj-control-code
- dl-gnn-transformer-code

### Concepts

- transformer
- ppo
- lipm
- centroidal

### Ideas

- idea-physical-feature-graph
- idea-humanoid-arm-dual-role

### Experiments

- 2026-06-25-g1-tracking-baseline - mjlab built-in Unitree G1 motion imitation/tracking PPO baseline before BoT actor comparison
