---
tags: [tier/mid]
type: category
date: 2026-06-27
status: active
---

# RL Algorithms, Benchmarks & Library

## 범위
RL 알고리즘 원전과 벤치마크, 그리고 학습 라이브러리/프레임워크를 묶는다.

## 소속 논문 (ingested)
- [[AI-Sessions/wiki/research/papers/2017-schulman-ppo|2017-schulman-ppo]] — PPO 알고리즘 원전.
- [[AI-Sessions/wiki/research/papers/2025-rsl-rl-library|2025-rsl-rl-library]] — 대규모 병렬 RL 학습 라이브러리.
- [[AI-Sessions/wiki/research/papers/2025-mjlab|2025-mjlab]] — MuJoCo 기반 RL 학습 프레임워크/벤치마크.
- [[AI-Sessions/wiki/research/papers/2025-zhao-mg2l|2025-zhao-mg2l]] — MG2L: MIO 기반 global-to-local task 표현 학습으로 CTDE meta-MARL(MAMRL)의 partial observability를 다룸.
- [[AI-Sessions/wiki/research/papers/2026-kim-gpae|2026-kim-gpae]] — GPAE: counterfactual state-value의 GAE(λ) 일반화(n-step per-agent credit, policy invariant) + DT-ISR off-policy 보정, MABrax per-joint 검증.
- [[AI-Sessions/wiki/research/papers/2026-le-dependence-graph-credit|2026-le-dependence-graph-credit]] — local reward를 state-dependent dependence graph의 meeting time으로 절단하는 policy gradient; local↔global 매끄러운 보간과 근사 graph bias bound(Lemma 4.6).
- [[AI-Sessions/wiki/research/papers/2021-han-multiagent-model-based-credit|2021-han-multiagent-model-based-credit]] — 로봇 joint=agent에 game-theoretic semivalue(Shapley/Banzhaf/LOO) credit; coalition value를 학습된 world model로 평가.
- [[AI-Sessions/wiki/research/papers/2024-lyu-centralized-critics|2024-lyu-centralized-critics]] — centralized critic은 이론적 이득이 없고 state-based critic은 부분관측에서 bias 유발 가능(JAIR); critic 선택은 과제 의존적 결정.
- [[AI-Sessions/wiki/research/papers/2024-kapoor-prd-mappo|2024-kapoor-prd-mappo]] — PRD-MAPPO: critic attention으로 relevant set을 추정해 무관 advantage 항 제거(soft 재가중 > hard 이진); credit 분산의 팀 크기 스케일링 정식화.
- [[AI-Sessions/wiki/research/papers/2025-alegre-amor|2025-alegre-amor]] — AMOR: 신체 그룹별 7-objective vector critic + weight-conditioned MOPPO로 Pareto front를 단일 policy에; 학습 후 실시간 가중 조정과 HLP.
- [[AI-Sessions/wiki/research/papers/2025-zhao-mla|2025-zhao-mla]] — MACA: credit level(k-부분집합) 정식화, joint/individual/CorrSet(attention 추정) 다층 counterfactual baseline의 상태 의존 가중합.
- [[AI-Sessions/wiki/research/papers/2026-yardimci-critic-architecture|2026-yardimci-critic-architecture]] — G1 loco-manipulation에서 dual(분리 reward) vs unified critic 통제 비교: dual이 3.5× 빠른 reach(단일 seed 소품).

## To-ingest backlog (미수록 — raw/wiki에 아직 없음)
- POLO — Lowrey et al. 2019 (MPC cost-to-go + value learning; idea-model-based-critic (d2) 정조준 앵커, 정확도 미검증)
- TD-MPC / TD-MPC2 — Hansen et al. (model-based value + planning, 정확도 미검증)
- Blending MPC & Value Function Approximation — Bhardwaj et al. 2021 (정확도 미검증)
- Xu et al. 2023 — 신체 그룹별 독립 value function의 고정 가중 MORL (AMOR related work가 지목, 정확도 미검증)
- HumanoidBench 2024
- MuJoCo Warp
- Rudin et al. "Learning to Walk in Minutes Using Massively Parallel Deep RL" 2021
- (참고: Cusadi 2024 / CasADi 2019는 이미 sources에 있음 — casadi-on-gpu-code)
