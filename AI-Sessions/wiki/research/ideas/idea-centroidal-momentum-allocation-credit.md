---
type: idea
date: 2026-06-29
status: active
topics:
  - humanoid
  - centroidal-dynamics
  - multi-agent-rl
  - credit-assignment
source: AI-Sessions/wiki/research/ideas/idea-physical-feature-graph.md
---

# Centroidal Momentum Allocation Credit

## Hypothesis

CMM의 joint별 column contribution을 목표 momentum 오차 방향에 투영해 per-joint advantage prior로 사용하면, team return을 모든 joint에 복제하는 PPO/MAPPO보다 credit variance를 줄이면서 whole-body momentum tracking을 개선한다.

이 값은 별도 reward의 합이 아니라 shared return에서 각 action update가 받을 방향과 크기를 조절하는 advantage-level credit로 사용한다.

## Falsification

- shared advantage baseline 대비 seed 평균 CAM/CoM tracking, return variance, convergence speed가 개선되지 않는다.
- joint contribution의 합과 실제 momentum change가 frame·contact·numerical tolerance 안에서 일치하지 않는다.
- credit가 팔 action을 과도하게 억제하거나 locomotion/manipulation 성능을 희생한다.
- learned counterfactual advantage가 동일 계산 비용에서 일관되게 우세하다.

## Evidence For

- $A_G(q)\dot q$는 각 generalized velocity가 centroidal momentum에 더하는 항을 정확히 분해한다.
- 목표 오차 방향 투영은 단순 column norm보다 현재 task와 정렬된 부호 있는 credit를 제공한다.
- 계산된 mapping은 learned relevance graph보다 낮은 분산의 inductive bias가 될 수 있다.

## Evidence Against

- instantaneous kinematic contribution은 action이 미래 state와 contact에 미치는 인과 효과가 아니다.
- floating-base와 joint velocity의 상호작용 때문에 naive leave-one-out 해석이 실제 action counterfactual과 다를 수 있다.
- advantage scaling이 PPO clipping, normalization, entropy와 상호작용해 bias를 만들 수 있다.

## Related Experiments

- [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|G1 centroidal CMM ablation]]
- [[AI-Sessions/wiki/research/experiments/2026-07-08-g1-limb-marl-gcn-token-critic|G1 limb MARL credit baseline]]
- [[AI-Sessions/wiki/research/experiments/2026-07-10-isaac-mit-gcn-jacobian-early-screen|Jacobian/CMM feature early screen]]

## Relations

- formalizes: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]
- derives-from: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- policy-setting: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]
