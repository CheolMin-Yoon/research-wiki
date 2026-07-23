---
type: paper
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - model-predictive-control
  - whole-body-control
source: https://arxiv.org/abs/2510.12717
---

# Jeon et al. 2025 — Residual MPC

## Citation

Se Hwan Jeon, Ho Jae Lee, Seungwoo Hong, Sangbae Kim. *Residual MPC: Blending Reinforcement Learning with GPU-Parallelized Model Predictive Control*. arXiv:2510.12717, 2025.

## Verified Contribution

GPU-parallel kinodynamic whole-body MPC와 PPO residual을 torque-control level에서 결합한다. MPC는 constraint-aware control prior로 배포 중에도 남고, RL은 model mismatch와 recovery를 보정한다. 논문은 병렬 training, sample efficiency, command range와 unseen gait/terrain adaptation을 평가한다.

## Research Use

MPC trajectory를 reward teacher로만 쓰는 방법과 deployment-time residual control을 구분하는 직접 비교군이다. MPC value observation이 raw value reward의 증거는 아니라는 점도 중요하다.

## Limitations

2026-07-24 기준 T-RO submission preprint다. torque blend의 성능을 training-only reference 또는 limb credit에 직접 일반화할 수 없다.

## Relations

- contrasts-with: [[AI-Sessions/wiki/research/papers/2026-li-mpc-guided-rl|2026-li-mpc-guided-rl]]
- evidence-for: [[AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures|mpc-guided-rl-architectures]]
- combines: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Sources

- [arXiv abstract](https://arxiv.org/abs/2510.12717)
