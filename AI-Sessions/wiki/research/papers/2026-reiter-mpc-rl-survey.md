---
type: paper
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
  - model-predictive-control
source: https://arxiv.org/abs/2502.02133
---

# Reiter et al. 2026 — Synthesis of MPC and Reinforcement Learning

## Citation

Rudolf Reiter, Jasper Hoffmann, Dirk Reinhardt, Florian Messerer, Katrin Baumgärtner, Shamburaj Sawant, Joschka Boedecker, Moritz Diehl, Sebastien Gros. *Synthesis of Model Predictive Control and Reinforcement Learning: Survey and Classification*. Annual Reviews in Control 61 (2026), arXiv:2502.02133.

## Verified Contribution

MPC와 RL의 공통 기반과 서로 다른 model/optimization 가정을 정리하고, actor-critic 관점에서 두 방법의 결합 위치를 분류한다. reward guidance, residual control, learned model/cost, MPC teacher, differentiable actor와 RL value inside planning을 같은 이름으로 섞지 않게 하는 taxonomy를 제공한다.

## Research Use

새 MPC–RL 아이디어는 먼저 어떤 신호가 어느 방향으로 흐르는지 분류한다. “MPC를 쓴다”보다 actor, critic, reward, dynamics, action, terminal value 중 어느 interface가 바뀌는지를 비교 축으로 삼는다.

## Limitations

survey의 taxonomy는 구현 feasibility나 humanoid-specific 성능을 직접 보장하지 않는다. 개별 시스템의 solver rate, contact model, actor observability는 원 논문과 code에서 별도로 확인해야 한다.

## Relations

- frames: [[AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures|mpc-guided-rl-architectures]]
- contrasts: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]
- contrasts: [[AI-Sessions/wiki/research/methods/ppo|ppo]]

## Sources

- [arXiv abstract](https://arxiv.org/abs/2502.02133)
- [Journal DOI](https://doi.org/10.1016/j.arcontrol.2026.101045)
