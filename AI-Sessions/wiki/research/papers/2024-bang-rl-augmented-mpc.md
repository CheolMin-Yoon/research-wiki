---
type: paper
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - centroidal-dynamics
  - model-predictive-control
source: https://arxiv.org/abs/2407.17683
---

# Bang et al. 2024 — RL-Augmented MPC for Bipedal Footsteps

## Citation

Seung Hyeon Bang, Carlos Arribalzaga Jové, Luis Sentis. *RL-augmented MPC Framework for Agile and Robust Bipedal Footstep Locomotion Planning and Control*. arXiv:2407.17683, 2024.

## Verified Contribution

ALIP-based MPC가 sub-optimal footstep을 만들고 learned policy가 3-D footstep adjustment를 보정한다. simplified model의 predictive structure와 full-body behavior에서 학습한 residual을 결합해 DRACO 3의 속도 추종, turning과 terrain traversal을 평가한다.

## Research Use

이 논문은 biped에서 MPC reference reward와 residual action이 함께 쓰일 수 있음을 보여준다. 따라서 reference tracking, residual control, scalar MPC value는 분리된 ablation이어야 한다.

## Limitations

ALIP footstep controller의 결과를 centroidal whole-body teacher나 training-only critic reference와 동일시할 수 없다. robot, action interface와 deployment-time MPC ownership도 다르다.

## Relations

- evidence-for: [[AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures|mpc-guided-rl-architectures]]
- uses: [[AI-Sessions/wiki/research/concepts/lipm-icp|lipm-icp]]
- targets: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Sources

- [arXiv abstract](https://arxiv.org/abs/2407.17683)
