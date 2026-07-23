---
type: source
date: 2026-07-24
status: active
topics:
  - humanoid
  - whole-body-control
  - jax-solver
source: https://github.com/stack-of-tasks/tsid
checked_commit: 7b1c416e80d68f24fc016407cb1ffb6e4a8d4914
---

# TSID Code

## Scope

TSID는 Pinocchio 기반 optimization inverse-dynamics C++ library다. task/contact formulation, HQP data construction, 여러 numeric QP solver와 Python bindings를 제공한다.

## Checked Boundary

- release `v1.10.0`: `591f737`, 2026-04-14
- checked `devel`: `7b1c416`, 2026-07-20
- license: BSD-2-Clause

## Implementation Findings

- core scalar와 Pinocchio model/data가 `double`에 고정돼 있어 CasADi `SX` model을 기존 TSID object에 주입할 수 없다.
- task `compute()`와 formulation은 virtual method, mutable container와 `pinocchio::Data`를 사용하므로 CasADi가 실행을 symbolic trace하는 interface가 없다.
- SE(3), CoM, contact와 inverse-dynamics constraint 수식 자체는 명시적 선형대수이므로 고정 task/contact layout으로 별도 구현할 수 있다.
- TSID의 numeric HQP/QP solver는 symbolic graph에 포함하지 않고 GPU fixed-pattern solver로 교체해야 한다.

## Relations

- implements: [[AI-Sessions/wiki/research/methods/whole-body-control|whole-body-control]]
- assessed-by: [[AI-Sessions/wiki/research/comparisons/tsid-vs-symbolic-jax-reimplementation|tsid-vs-symbolic-jax-reimplementation]]

## Provenance

- [TSID repository](https://github.com/stack-of-tasks/tsid/tree/7b1c416e80d68f24fc016407cb1ffb6e4a8d4914)
- reusable findings distilled from `mj_rl/docs/research/2026-07-23-tsid-casadi-jax-cuda-feasibility.md`
