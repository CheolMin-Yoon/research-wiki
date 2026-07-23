---
type: paper
date: 2026-07-24
status: active
topics:
  - locomotion
  - model-predictive-control
source: https://arxiv.org/abs/2411.03481
---

# Trivedi et al. 2025 — Chance-Constrained Convex MPC

## Citation

Ananya Trivedi, Sarvesh Prajapati, Mark Zolotas, Michael Everett, Taşkın Padır. *Chance-Constrained Convex MPC for Robust Quadruped Locomotion Under Parametric and Additive Uncertainties*. IEEE Robotics and Automation Letters 10(8), 8388–8395, 2025. DOI: 10.1109/LRA.2025.3585315.

## Verified Contribution

SRBD의 mass/inertia/contact-position uncertainty와 additive residual을 확률분포로 모델링하고, horizon covariance propagation과 friction/unilateral-force chance constraints를 deterministic bound tightening으로 바꿔 QP 구조를 유지한다. Unitree Go1에서 unknown payload와 uneven terrain을 평가한다.

## Research Use

fixed-pattern SRBD QP에 uncertainty baseline을 추가할 때 가장 작은 확장이다. 먼저 수동 uncertainty와 covariance/tightening parity를 검증한 뒤 learned uncertainty를 붙이는 순서의 근거가 된다.

## Limitations

quadruped와 fixed contact schedule 실험이므로 humanoid contact switching으로 직접 일반화할 수 없다. 공개 artifact의 license와 hardware stack 범위도 코드 재사용 전에 별도로 확인해야 한다.

## Relations

- evidence-for: [[AI-Sessions/wiki/research/comparisons/srbd-mpc-robustness-priorities|srbd-mpc-robustness-priorities]]
- extends: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Sources

- [arXiv](https://arxiv.org/abs/2411.03481)
- [Project page](https://cc-mpc.github.io/)
- [DOI](https://doi.org/10.1109/LRA.2025.3585315)
