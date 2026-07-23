---
type: concept
date: 2026-07-24
status: active
topics:
  - humanoid
  - morphology-aware-policy
  - graph-policy
---

# Morphology-Aware Representation

## Definition and Boundary

Morphology-aware representation은 robot의 kinematic topology, node type, symmetry 또는 dynamics structure를 policy input과 parameter sharing에 명시적으로 반영한다. morphology를 입력으로 넣는 것과 exact state-dependent physical coupling을 제공하는 것은 구분해야 한다.

## Why It Matters

휴머노이드 관절을 flat vector로만 처리할 때 사라지는 인접성, 대칭, limb 역할을 학습에 제공하며 다른 embodiment로의 일반화를 설계할 수 있다.

## Engineering Implications

- URDF adjacency, learned edge, attention bias, symmetry orbit의 의미를 구분한다.
- node ordering과 action ordering의 adapter를 명시한다.
- topology prior와 physical value prior의 ablation을 분리한다.

## Relations

- represented-by: [[AI-Sessions/wiki/research/methods/graph-policy|graph-policy]]
- evaluated-in: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Evidence

- Body Transformer 2024
- GCNT 2025
- MI/MS-HGNN and MS-PPO 2025
