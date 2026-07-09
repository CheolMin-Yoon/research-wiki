---
tags: [tier/mid]
type: category
date: 2026-06-27
status: active
---

# Morphology-Aware Policy & GNN Limits

## 범위
morphology-aware/modular policy 학습과 순수 GNN(message-passing) 방식의 한계를 묶는다.

## 소속 논문 (ingested)
- [[AI-Sessions/wiki/research/papers/2025-liu-mash|2025-liu-mash]] — limb(팔/다리)=agent 분해 + shared-parameter actor + global critic MARL(MAPPO)로 humanoid locomotion coordination 확보. graph/attention 없이 모듈 분해로 협응.
- [[AI-Sessions/wiki/research/papers/2025-butterfield-mi-hgnn|2025-butterfield-mi-hgnn]] — URDF/kinematic topology에서 base/joint/foot heterogeneous graph를 구성하는 topology-aware baseline.
- [[AI-Sessions/wiki/research/papers/2025-xie-ms-hgnn|2025-xie-ms-hgnn]] — topology-aware HGNN에 morphological symmetry group, node orbit, sign encoder/decoder를 결합한 MS-HGNN.
- [[AI-Sessions/wiki/research/papers/2025-wei-ms-ppo|2025-wei-ms-ppo]] — MS-HGNN식 symmetry graph contract를 locomotion PPO에 적용한 equivariant actor + invariant critic.

## To-ingest backlog (미수록 — raw/wiki에 아직 없음)
- NerveNet
- My Body is a Cage: The Role of Morphology in Graph-Based Incompatible Control 2021
- Shared Modular Policies / One Policy to Control Them All (Huang et al.) 2020
- Transform2Act (Yuan et al., ICLR) 2022
- MetaMorph (Gupta et al., ICLR) 2022
