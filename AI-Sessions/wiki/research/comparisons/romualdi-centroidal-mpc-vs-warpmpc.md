---
type: comparison
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - centroidal-dynamics
  - model-predictive-control
  - jax-solver
---

# Romualdi Centroidal MPC vs WarpMPC

## Decision

WarpMPC의 stagewise JAX SQP는 Romualdi 2022 nonlinear centroidal multiple-shooting 문제를 표현할 수 있는 solver substrate다. 그러나 `jax_osqp` 하나로 source-exact 문제를 풀 수 없고, 표현 가능성은 objective/trajectory parity와 동일하지 않다.

## Mapping

| Romualdi element | Stagewise solver representation |
|---|---|
| measured initial state | first-stage equality and parameter |
| centroidal state/control | fixed decision layout per stage |
| dynamics integration | neighboring-stage nonlinear equality |
| contact force/torque/location | stage inputs with mode-dependent bounds |
| contact-position × force | nonlinear constraint linearized by SQP |
| step adjustment | contact location decision |

## Required Validation

1. source-equivalent dynamics and frame convention
2. IPOPT reference at small horizon
3. objective, constraint residual and trajectory parity
4. SQP convergence from controlled initial guesses
5. JIT/steady-state batch performance only after numeric parity

## Relations

- source-problem: [[AI-Sessions/wiki/research/papers/2022-romualdi-centroidal-mpc|2022-romualdi-centroidal-mpc]]
- solver-source: [[AI-Sessions/wiki/research/sources/warpmpc-code|warpmpc-code]]
- solver-method: [[AI-Sessions/wiki/research/methods/jax-solver|jax-solver]]

## Sources

- `mj_rl/scripts/mbc/romualdi_warpmpc/RESULTS.md` at the recorded WarpMPC commit
