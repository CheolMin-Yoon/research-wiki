---
tags: [tier/upper]
type: map
date: 2026-06-24
status: active
---

# Experiments

## Graph

- [[AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline|2026-06-25-g1-tracking-baseline]]

## Summary

reward, observation, action space, terrain, termination, curriculum, policy architecture, seed/hyperparameter, sim-to-real 변경에서 얻은 실험 사실을 저장하는 research 하위 허브다.

단일 실험 사실은 여기에 두고, 다시 피해야 할 실패는 `harness/errors/`, 일반화된 접근은 `harness/patterns/`, 앞으로 따를 설계 결정은 `harness/decisions/`로 승격한다.

## Active

- `2026-06-25-g1-tracking-baseline`: mjlab built-in `Mjlab-Tracking-Flat-Unitree-G1` PPO motion imitation baseline을 먼저 재현한 뒤 BoT actor와 비교하는 첫 실험.
