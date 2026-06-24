---
tags: [tier/low]
type: source
date: 2026-06-24
status: active
source: AI-Sessions/raw/repos/mj-control.md
---

# 구현 분석: mj_control

## Summary

사용자의 MuJoCo/Pinocchio classical control reference repo다. raw repo stub의 pinned commit `d0165a4e05ade5770dfc79d6eb752c6ffb234733`을 checkout해 확인했으며, manipulator impedance/DLS/IK, cartpole LQR/MPC, quadruped SRBD-MPC, humanoid WBC/centroidal MPC를 class 구조로 정리한 코드베이스다. mj_rl에서는 vectorized RL runtime이 아니라 controller oracle, debugging reference, teacher 후보로 본다.

## 핵심 파일

- `mj_sim/manipulator/core/`: MuJoCo wrapper, Pinocchio wrapper, fixed-base robot state.
- `mj_sim/manipulator/control/`: task-space controller, trajectory generator, model predictive controller, solver utilities.
- `mj_sim/cartpole/`: discretization, LQR/MPC 구현 노트와 notebook.
- `mj_sim/quadruped/control/`: gait scheduler, leg controller, SRBD dynamics, MPC controller, OSQP/ProxQP solver.
- `mj_sim/humanoid/core/`: floating-base robot state, MuJoCo kernel, Pinocchio wrapper.
- `mj_sim/humanoid/control/`: centroidal MPC, whole-body controller, task-space controller, gait scheduler, motion planner.
- `models/g1/`: Unitree G1 URDF/XML assets.

## 가져올 패턴

- Pinocchio wrapper와 MuJoCo kernel을 나눠 frame/dynamics 계산을 검증하는 구조.
- manipulator와 floating-base robot을 core/control/utils 계층으로 분리하는 class 설계.
- quadruped SRBD-MPC와 humanoid WBC/MPC는 RL policy 디버깅용 oracle이나 teacher rollout 후보가 된다.
- task-space controller와 DLS/IK/QP solver는 mj_rl action target 또는 low-level controller 검산에 유용하다.

## 주의점

- 병렬/vectorized RL 환경을 목표로 만든 구조가 아니므로 mjlab task runtime에 직접 넣으면 성능과 API가 맞지 않을 수 있다.
- Pinocchio, CasADi, QP solver 의존성이 있어 학습 loop 내부보다 offline validation 또는 controller oracle로 쓰는 편이 안전하다.
- 실행은 notebook/main script를 controller 검산용으로만 최소 참고한다.

## Links

- raw repo: AI-Sessions/raw/repos/mj-control.md
- checked commit: d0165a4e05ade5770dfc79d6eb752c6ffb234733
