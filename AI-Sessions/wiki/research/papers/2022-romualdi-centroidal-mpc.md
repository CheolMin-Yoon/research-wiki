---
type: paper
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - centroidal-dynamics
  - model-predictive-control
source: https://arxiv.org/abs/2203.04489
---

# Romualdi et al. 2022 — Online Nonlinear Centroidal MPC

## Citation

Giulio Romualdi, Stefano Dafarra, Giuseppe L'Erario, Ines Sorrentino, Silvio Traversaro, Daniele Pucci. *Online Non-linear Centroidal MPC for Humanoid Robot Locomotion with Step Adjustment*. ICRA 2022, arXiv:2203.04489.

## Verified Contribution

contact force, torque와 contact location을 decision으로 두는 nonlinear centroidal MPC를 제시한다. single/double support에서 step location을 조정하며 simulation과 iCub push-recovery walking으로 검증한다.

angular momentum equality의 contact-position–force cross product는 bilinear이므로 source-exact 문제는 하나의 고정 convex QP가 아니다. SQP에서 stage nonlinear constraints를 반복 선형화하거나 contact location을 외부에서 고정한 근사 문제로 구분해야 한다.

## Research Use

humanoid centroidal nonlinear MPC와 WarpMPC stagewise SQP 표현력의 직접 feasibility 기준이다.

## Limitations

solver substrate가 문제를 표현할 수 있다는 것과 source-exact optimum/trajectory parity는 별도 검증이다. iCub controller 결과도 G1 dynamics와 actuator feasibility를 보장하지 않는다.

## Relations

- evidence-for: [[AI-Sessions/wiki/research/comparisons/romualdi-centroidal-mpc-vs-warpmpc|romualdi-centroidal-mpc-vs-warpmpc]]
- models: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- uses: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Sources

- [arXiv abstract](https://arxiv.org/abs/2203.04489)
