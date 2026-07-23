---
type: source
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - centroidal-dynamics
  - model-predictive-control
  - jax-solver
source: https://github.com/CheolMin-Yoon/mj_mpc
---

# 구현 분석: mj_mpc

## Summary

G1 보행용 NIPFM NMPC를 C++ 식과 대조 가능한 NumPy oracle에서 시작해 stagewise sparse JAX solver로 옮기는 구현 저장소다. 현재 공통 물리 seam은 `state, control → next_state/ZMP`이고, condensed prediction은 수식 검산, sparse SQP는 production solver 구조 검증을 담당한다.

## Provenance

- checked commit: `f959df38bc6ddd6be12d12e59fb88ce63c585916`
- checked files: `CONTEXT.md`, `docs/coding_style.md`, `docs/flywheel_inertia.md`, `src/mj_mpc/control/{dynamics,condensed_sqp}.py`, related tests

## Project Docs Boundary

- repo-local canonical contract: `CONTEXT.md`, `docs/coding_style.md`. 이름, shape, dtype, 코드 구조와 같은 규칙은 코드와 같은 commit에서 바뀌어야 한다.
- wiki canonical digest: 이 source note의 구현 구조와 NIPFM flywheel 해석. 여러 프로젝트에서 재사용할 concept/method 결론은 관련 typed note로 승격한다.
- migration candidate: `docs/flywheel_inertia.md`의 긴 derivation은 wiki 정본으로 승격한 뒤 repo에는 checked wiki revision과 구현 차이만 남긴다.

## Current Implementation

- `control/dynamics.py`: 10D state와 5D acceleration control의 단일-stage NIPFM dynamics, flywheel angular acceleration을 포함한 world-frame ZMP 식
- `control/condensed_sqp.py`: C++ `Pps/Ppu/Pvs/Pvu`와 대응하는 float64 NumPy prediction oracle, decision layout과 rollout parity 검증
- `control/sparse_sqp.py`: stagewise sparse SQP로 옮길 production seam
- `control/nmpc.py`: receding-horizon tick, trajectory와 첫 control 적용의 소유자
- `tests/control/`: input immutability, output ownership, prediction/rollout 및 원식 parity gate

## NIPFM Flywheel Finding

`centroidal_inertia_rp = [I_x, I_y]`는 torso link inertia도 configuration-dependent whole-body locked inertia도 아니다. 원 NIPFM에 충실한 의미는 whole-body CoM에 놓인 등가 flywheel의 constant effective roll/pitch inertia다. 현재 ZMP 식은 off-diagonal inertia와 gyroscopic term을 생략한 two-channel reduced model이므로 큰 3D 회전이나 자세별 inertia 변화를 표현하지 못한다. 이 한계를 실제 centroidal dynamics와 혼동하지 않는다.

## Cautions

- condensed NumPy 경로는 수식 oracle이고 batched production solver가 아니다.
- future foothold optimization variable을 reference parameter로 바꾸지 않는다.
- support height, current support foot, future foothold를 같은 용어로 합치지 않는다.
- JAX port는 float64 oracle parity를 먼저 고정한 뒤 float32와 fixed-sparsity runtime을 검증한다.

## Relations

- reduced dynamics boundary: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- controller family: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]
- production port target: [[AI-Sessions/wiki/research/methods/jax-solver|jax-solver]]
