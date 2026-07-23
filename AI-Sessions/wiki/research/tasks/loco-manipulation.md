---
type: task
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - loco-manipulation
---

# Humanoid Loco-Manipulation

## Objective

Loco-manipulation은 이동, balance와 물체·환경 상호작용을 하나의 coupled whole-body task로 해결한다. manipulation을 고정 base 위의 별도 문제로 취급하지 않는다.

## Observations and Actions

locomotion proprioception과 command에 object/hand target, contact wrench 또는 payload state가 추가된다. action은 전신 단일 policy, limb policy factorization, WBC/MPC reference 또는 residual로 구성할 수 있다.

## Constraints and Metrics

- base/velocity stability와 task completion
- hand/object pose·force tracking
- CAM/CoM/contact wrench와 foot slip
- limb coordination, disturbance/payload generalization

## Baselines

whole-body PPO, limb MARL, MPC-guided policy, residual MPC/WBC와 staged locomotion-plus-manipulation을 비교한다.

## Relations

- couples: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- learned-by: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]
- controlled-by: [[AI-Sessions/wiki/research/methods/whole-body-control|whole-body-control]]

## Evidence

- Lee et al. 2025 arm/CAM MARL
- Li et al. 2026 MPC-guided locomotion and manipulation
- local MPC-RL push-box source analysis
