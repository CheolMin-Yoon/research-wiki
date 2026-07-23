---
type: task
date: 2026-07-24
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
---

# Humanoid Locomotion

## Objective

Humanoid locomotion은 contact를 전환하며 command velocity 또는 motion reference를 추종하고 균형, energy, joint/contact constraint를 유지하는 task다.

## Observations and Actions

proprioception, command, phase/contact state와 선택적인 privileged dynamics signal을 사용하며 action은 joint target, torque, residual 또는 policy-role별 action으로 구성한다.

## Constraints and Metrics

- command tracking, fall/survival, contact slip와 foot placement
- CoM/CLM/CAM 및 disturbance recovery
- energy/torque/action smoothness
- sample efficiency, solver overhead, sim-to-hardware robustness

## Baselines

flat PPO, morphology-aware graph policy, motion imitation policy, model-guided reward/critic, WBC/MPC controller를 같은 command와 asset 조건에서 비교한다.

## Relations

- modeled-by: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- learned-by: [[AI-Sessions/wiki/research/methods/ppo|ppo]]
- guided-by: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]

## Evidence

- 현재 humanoid paper/source/experiment corpus
