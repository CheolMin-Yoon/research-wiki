---
type: method
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
  - morphology-aware-policy
  - graph-policy
---

# Graph Policy

## Goal

Graph policy는 robot morphology나 physical relation을 node/edge 구조로 표현해 actor 또는 critic의 정보 전달을 제어한다.

## Mechanism

message-passing GNN은 local aggregation을 반복하고, graph Transformer는 attention mask/bias 또는 q/k feature로 topology를 주입한다. heterogeneous graph와 symmetry-equivariant model은 node/edge type과 group action을 추가한다.

## Implementation Contract

- node와 action/observation slice의 대응을 한 adapter가 소유한다.
- adjacency, learned edge, physical feature edge를 별도 input으로 둔다.
- flat MLP, topology-only, full-attention, physical-feature 조건을 ablation한다.

## Failure Modes

- graph node ordering과 simulator joint ordering drift
- binary topology와 state-dependent dynamics coupling 혼동
- attention visualization을 causal credit로 해석

## Relations

- represents: [[AI-Sessions/wiki/research/concepts/morphology-aware-representation|morphology-aware-representation]]
- applied-to: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Evidence

- Body Transformer 2024
- Graphormer 2021 and GCNT 2025
- MI/MS-HGNN and MS-PPO 2025
