---
type: comparison
date: 2026-07-24
status: active
topics:
  - humanoid
  - whole-body-control
  - model-predictive-control
  - jax-solver
---

# TSID vs Symbolic JAX Reimplementation

## Decision

TSID C++/Python library를 CasADi로 감싸 JAX 또는 CUDA graph로 직접 변환할 수 없다. contact 수, task, priority와 sparsity를 고정한 TSID-equivalent formulation을 Pinocchio-CasADi로 별도 구현하고 WarpMPC solver로 푸는 것은 가능하다.

## Boundary Matrix

| Boundary | Direct conversion | Separate symbolic implementation |
|---|---:|---:|
| TSID task/formulation C++ | no | yes, selected fixed tasks |
| Pinocchio rigid-body terms | not through TSID | yes, custom scalar/CasADi model |
| TSID numeric HQP solver | no | replaceable |
| complete controller | no | conditional, new implementation |

## Target Data Path

```text
(q, v, references, contacts)
  -> Pinocchio-CasADi rigid-body terms
  -> fixed TSID task/contact equations
  -> fixed-pattern (H, g, A, l, u)
  -> CasADi-to-JAX export
  -> batched GPU QP solve
  -> (dv, contact force) -> torque
```

CasADi 공식 code generator는 C/C++를 생성한다. 이 경로의 GPU 실행은 JAX/XLA와 Warp kernel이 소유한다.

## Minimum Validation

1. one fixed contact and one posture/CoM task
2. TSID numeric matrix and solution parity
3. frame, mask, sign and force-generator parity
4. contact/task activation without sparsity drift
5. batch/JIT benchmark after correctness

## Relations

- analyzed-source: [[AI-Sessions/wiki/research/sources/tsid-code|tsid-code]]
- symbolic-source: [[AI-Sessions/wiki/research/sources/casadi-on-gpu-code|casadi-on-gpu-code]]
- solver-source: [[AI-Sessions/wiki/research/sources/warpmpc-code|warpmpc-code]]

## Sources

- `mj_rl/docs/research/2026-07-23-tsid-casadi-jax-cuda-feasibility.md`
