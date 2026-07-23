---
type: method
date: 2026-07-24
status: active
topics:
  - model-predictive-control
  - whole-body-control
  - jax-solver
---

# JAX Solver Path

## Goal

JAX solver path는 고정된 수식과 sparsity를 JAX/XLA에서 batch·JIT 실행할 수 있는 numeric optimization interface로 구성한다.

## Mechanism

CasADi/Pinocchio symbolic stage function을 JAX로 export하고, fixed-pattern QP 또는 stagewise SQP가 numeric values만 갱신한다. plan/compile/runtime/result를 분리해 symbolic construction과 반복 solve를 격리한다.

## Implementation Contract

- horizon, decision layout, constraint row와 CSC sparsity를 compile 전에 고정한다.
- runtime은 numeric parameter, warm start와 result status만 소유한다.
- dtype, device, allocator와 JIT boundary를 benchmark에 명시한다.

## Failure Modes

- 기존 명령형 C++ solver를 symbolic trace할 수 있다고 가정
- sparse index와 packed value ordering drift
- compile time, steady-state latency, batch throughput을 혼합
- solver status를 무시하고 primal result만 소비

## Relations

- solves: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]
- can-solve: [[AI-Sessions/wiki/research/methods/whole-body-control|whole-body-control]]

## Evidence

- WarpMPC source analysis
- CasADi-on-GPU source analysis
- TSID symbolic reimplementation feasibility study
