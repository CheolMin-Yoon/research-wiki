---
type: method
date: 2026-07-24
status: active
topics:
  - humanoid
  - imitation-learning
---

# Imitation Learning

## Goal

Imitation learning은 demonstration이나 reference motion으로부터 행동 또는 occupancy를 학습해 원하는 motion distribution을 재현한다.

## Mechanism

behavior cloning은 action target을 직접 회귀하고, adversarial imitation은 expert occupancy와의 구분 신호를 사용하며, humanoid motion tracking RL은 reference state를 command로 두고 tracking reward로 policy를 최적화한다.

## Implementation Contract

- retargeting, phase/reference sampling, termination과 tracking metric을 분리한다.
- demonstration에 없는 recovery를 평가하기 위해 perturbation과 out-of-distribution motion을 둔다.
- morphology-aware policy 비교에서는 동일한 motion corpus와 reward를 유지한다.

## Failure Modes

- reference leakage를 deployable actor observation에 포함
- motion quality와 task robustness를 하나의 return으로만 평가
- retargeting artifact를 policy architecture 차이로 오해

## Relations

- trains: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]
- can-use: [[AI-Sessions/wiki/research/methods/graph-policy|graph-policy]]

## Evidence

- 현재 G1 tracking/mimic experiments
- graph mimic and morphology-aware policy baselines
