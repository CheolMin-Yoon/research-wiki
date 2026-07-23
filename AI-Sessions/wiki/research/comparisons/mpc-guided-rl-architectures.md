---
type: comparison
date: 2026-07-24
status: active
topics:
  - humanoid
  - reinforcement-learning
  - model-predictive-control
---

# MPC-Guided RL Architectures

## Decision

humanoid 첫 baseline은 MPC trajectory landmark를 detached reward reference와 critic-only information으로 제공한다. raw optimal cost, residual torque, learned MPC parameter와 differentiable optimization은 서로 다른 가설이므로 한 실험에서 동시에 도입하지 않는다.

## Comparison Axes

| Architecture | MPC→learning signal | Deployment MPC | First question |
|---|---|---:|---|
| trajectory-reference reward | CoM/momentum/feet/wrench plan | no | physical reference가 sample efficiency를 높이는가 |
| reference + residual action | plan과 learned correction | usually yes | simplified model gap을 action이 보정하는가 |
| residual controller | MPC control + learned residual | yes | model-based prior가 robustness를 높이는가 |
| learned parameterization | dynamics/cost/gait/constraint parameters | yes | adaptation target이 해석 가능한가 |
| MPC teacher/critic | action, trajectory, Hamiltonian/value | no/optional | distillation 또는 value supervision이 유효한가 |
| scalar optimal value | $J^*$ observation/potential/value target | optional | scalar가 trajectory보다 유용한가 |
| differentiable MPC actor | optimizer output and gradient | yes | end-to-end gradient가 비용을 정당화하는가 |
| RL value in planning | learned terminal value | yes | 짧은 planner horizon을 보완하는가 |

## Recommendation

1. Li et al. trajectory-reference baseline을 같은 reward regularization으로 재현한다.
2. actor observation은 바꾸지 않고 critic-only reference 효과를 분리한다.
3. reference reward와 scalar $J^*$를 별도 ablation한다.
4. 그 뒤에만 residual control, shared critic과 counterfactual credit을 추가한다.

## Risks and Open Questions

- $J^*$는 horizon, weights, command, contact mode와 solver convergence를 한 값에 섞는다.
- stale/invalid plan을 masking하지 않으면 teacher quality와 RL robustness를 분리할 수 없다.
- MPC reward와 기존 command/momentum reward를 중복하면 contribution을 과대평가한다.

## Relations

- framed-by: [[AI-Sessions/wiki/research/papers/2026-reiter-mpc-rl-survey|2026-reiter-mpc-rl-survey]]
- baseline: [[AI-Sessions/wiki/research/papers/2026-li-mpc-guided-rl|2026-li-mpc-guided-rl]]
- contrasts: [[AI-Sessions/wiki/research/papers/2025-jeon-residual-mpc|2025-jeon-residual-mpc]]

## Sources

- `mj_rl/docs/research/2026-07-21-mpc-guided-marl.md` at its recorded repository state
