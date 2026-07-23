---
type: paper
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - loco-manipulation
  - reinforcement-learning
  - centroidal-dynamics
  - model-predictive-control
source: https://arxiv.org/abs/2606.05687
---

# Li et al. 2026 — Accelerating and Scaling MPC-Guided Reinforcement Learning

## Citation

Junheng Li, Liang Wu, Sergio A. Esteban, Lizhi Yang, Ján Drgoňa, Aaron D. Ames. *Accelerating and Scaling MPC-Guided Reinforcement Learning for Humanoid Locomotion and Manipulation*. arXiv:2606.05687, submitted 2026-06-04.

## Verified Contribution

이 논문은 centroidal-dynamics MPC trajectory를 training-time reward reference로 사용하고, 대규모 병렬 RL에서 solver construction과 horizon 계산 비용을 줄이는 GPU batched MPC를 제시한다. actor는 배포 가능한 관측만 받고 critic은 MPC reference를 privileged information으로 받을 수 있으며, 배포 시 MPC를 제거하는 구성을 평가한다.

핵심은 scalar optimum $J^*$를 reward로 반복하는 것이 아니라 CoM, momentum, contact force, foot/hand plan과 같은 해석 가능한 trajectory landmark를 학습 신호로 쓰는 것이다.

## Research Use

- humanoid MPC-guided reward의 직접 baseline
- actor/critic asymmetric information과 training-only teacher의 구현 근거
- 단순 “MPC plan을 reward로 사용”을 novelty로 주장할 수 없게 만드는 선행연구

## Limitations

- 2026-07-24 기준 arXiv preprint다.
- solver와 task integration의 성과가 raw scalar cost credit의 유효성을 입증하지는 않는다.
- limb별 credit assignment는 별도 연구 질문이다.

## Relations

- evidence-for: [[AI-Sessions/wiki/research/comparisons/mpc-guided-rl-architectures|mpc-guided-rl-architectures]]
- evidence-for: [[AI-Sessions/wiki/research/comparisons/humanoid-mbc-teacher-integration|humanoid-mbc-teacher-integration]]
- implements: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Sources

- [arXiv abstract](https://arxiv.org/abs/2606.05687)
- [Official implementation](https://github.com/junhengl/mpc-rl)
