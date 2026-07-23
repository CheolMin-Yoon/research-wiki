---
type: method
date: 2026-07-24
status: active
topics:
  - model-predictive-control
  - centroidal-dynamics
---

# Model Predictive Control

## Goal

Model Predictive Control(MPC)은 현재 상태에서 유한 horizon 최적제어 문제를 반복해서 풀고 첫 제어 또는 plan 일부만 적용한다.

## Inputs and Outputs

입력은 dynamics, initial state, reference, cost, constraints와 horizon이며 출력은 predicted state/control trajectory, objective, constraint/solver status다.

## Mechanism

receding-horizon update, state-dependent linearization, contact schedule과 warm start가 runtime contract를 이룬다. 휴머노이드에서는 LIPM/ALIP, SRBD, centroidal dynamics, kinodynamic whole-body model의 선택이 계산량과 표현력을 결정한다.

## Failure Modes

- solver 성공 여부를 확인하지 않은 stale plan 소비
- scalar objective를 물리적으로 해석 가능한 reference와 혼동
- contact frame, friction, force sign과 support schedule 불일치
- simplified model의 plan을 full-order feasibility 보장으로 해석

## Relations

- models: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- guides: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]
- compared-with: [[AI-Sessions/wiki/research/methods/ppo|ppo]]

## Evidence

- Romualdi et al. 2022
- Li et al. 2026
- Reiter et al. 2026 survey
