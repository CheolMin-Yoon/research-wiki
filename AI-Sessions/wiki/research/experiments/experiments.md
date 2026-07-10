---
tags: [tier/upper]
type: map
date: 2026-06-24
status: active
---

# Experiments

## Graph

- [[AI-Sessions/wiki/research/experiments/2026-06-25-g1-tracking-baseline|2026-06-25-g1-tracking-baseline]]
- [[AI-Sessions/wiki/research/experiments/2026-06-27-cusadi-vs-casadi-on-gpu-g1|2026-06-27-cusadi-vs-casadi-on-gpu-g1]]
- [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|2026-06-28-g1-centroidal-cmm-vs-baselines]]
- [[AI-Sessions/wiki/research/experiments/2026-06-29-g1-29dof-vanilla-bot|2026-06-29-g1-29dof-vanilla-bot]]
- [[AI-Sessions/wiki/research/experiments/2026-07-08-g1-limb-marl-gcn-token-critic|2026-07-08-g1-limb-marl-gcn-token-critic]]
- [[AI-Sessions/wiki/research/experiments/2026-07-10-isaac-mit-gcn-jacobian-early-screen|2026-07-10-isaac-mit-gcn-jacobian-early-screen]]

## Summary

reward, observation, action space, terrain, termination, curriculum, policy architecture, seed/hyperparameter, sim-to-real 변경에서 얻은 실험 사실을 저장하는 research 하위 허브다.

단일 실험 사실은 여기에 두고, 다시 피해야 할 실패는 `harness/errors/`, 일반화된 접근은 `harness/patterns/`, 앞으로 따를 설계 결정은 `harness/decisions/`로 승격한다.

## Active

- `2026-06-25-g1-tracking-baseline`: mjlab built-in `Mjlab-Tracking-Flat-Unitree-G1` PPO motion imitation baseline을 먼저 재현한 뒤 BoT actor와 비교하는 첫 실험.
- `2026-06-27-cusadi-vs-casadi-on-gpu-g1`: G1 동역학 GPU 배치 평가에서 casadi-on-gpu가 cusadi보다 ~10–20× 빠름(done). 일반화 교훈은 `harness/patterns/research-patterns`.
- `2026-06-28-g1-centroidal-cmm-vs-baselines`: graph_centroidal task에서 CMM 주입 Transformer(v0) vs Topology/BoT/GCNT 4-way(planned). H1 limb attention 활성화 / H2 CAM reward ablation(representation vs reward) / H3 sample efficiency.
- `2026-06-29-g1-29dof-vanilla-bot`: CMM/centroidal-root 확장 전 gate. mjlab 29-DOF G1 velocity/locomotion surface에서 Vanilla BoT가 MLP 대비 유의미한지 확인(planned).
- `2026-07-08-g1-limb-marl-gcn-token-critic`: 22-DOF waist-locked G1에서 MASH식 4-limb MARL(독립 task 패키지) — limb-local obs GCN actor 4개 + BoT token-group critic(4-value). 설계 확정, 사용자 구현 예정(planned).
- `2026-07-10-isaac-mit-gcn-jacobian-early-screen`: RAL2025 MIT Humanoid IsaacLab baseline에 RAL 원본 leg actuator Jacobian coupling까지 맞춘 뒤, baseline MLP와 4개 GCN ablation을 각 1시간/1000iter 목표로 early-screen(active).
