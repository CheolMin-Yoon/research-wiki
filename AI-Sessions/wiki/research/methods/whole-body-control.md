---
type: method
date: 2026-07-24
status: active
topics:
  - humanoid
  - whole-body-control
  - centroidal-dynamics
---

# Whole-Body Control

## Goal

Whole-Body Control(WBC)은 contact와 rigid-body dynamics를 만족하면서 CoM, momentum, end-effector, posture 같은 여러 task를 joint torque 또는 acceleration으로 조정한다.

## Inputs and Outputs

robot state, contact state, task reference, dynamics terms와 task priority를 받아 generalized acceleration, contact wrench와 torque를 계산한다.

## Mechanism

QP-WBC는 task를 하나의 weighted QP로 풀 수 있고, TSID/HQP는 우선순위 계층을 보존한다. centroidal plan은 WBC가 추종할 reference가 될 수 있지만 plan과 full-body feasibility는 별도 층이다.

## Failure Modes

- frame과 Jacobian convention 불일치
- contact rank 변화에서 고정 sparsity 계약 파손
- soft weight를 strict priority로 오해
- numerical solver를 symbolic graph로 직접 변환할 수 있다고 가정

## Relations

- uses: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- controls: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]
- controls: [[AI-Sessions/wiki/research/tasks/loco-manipulation|loco-manipulation]]

## Evidence

- Orin et al. 2013
- TSID implementation and task formulations
- Gao et al. 2023 momentum-based arm compensation
