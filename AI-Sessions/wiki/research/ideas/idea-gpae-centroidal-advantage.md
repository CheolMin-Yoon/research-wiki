---
type: idea
date: 2026-07-18
status: active
topics:
  - humanoid
  - reinforcement-learning
  - centroidal-dynamics
  - multi-agent-rl
  - credit-assignment
source: AI-Sessions/wiki/research/ideas/idea-centroidal-momentum-allocation-credit.md
---

# GPAE Counterfactual Centroidal Advantage

## Hypothesis

GPAE식 per-agent GAE 배관에서 learned counterfactual value를 CMM 기반 exact/analytic counterfactual prior와 결합하면, learned-only GPAE보다 초기 variance를 줄이면서 model bias는 residual critic이 보정할 수 있다.

## Falsification

- learned-only GPAE, shared GAE, analytic-only credit 대비 seed 평균 return이나 sample efficiency 이득이 없다.
- analytic prior가 residual critic의 학습을 방해해 최종 policy가 learned-only baseline보다 나빠진다.
- CMM counterfactual과 실제 action intervention의 순위 상관이 낮다.

## Evidence For

- GPAE는 per-agent advantage를 PPO 계열 update에 연결하는 검증 가능한 배관과 학습 대조군을 제공한다.
- CMM은 momentum objective에 한해 빠르고 deterministic한 joint contribution prior를 제공한다.
- prior + residual 구조는 초기 low-variance signal과 장기 model correction을 역할 분리할 수 있다.

## Evidence Against

- GPAE의 counterfactual은 expected return 차이지만 CMM contribution은 instantaneous physics라 의미가 같지 않다.
- analytic signal과 learned signal의 scale·normalization·mixing coefficient가 새로운 튜닝 축이 된다.
- 정책의 stochastic action과 contact transition 때문에 CMM prior가 misleading할 수 있다.

## Related Experiments

- [[AI-Sessions/wiki/research/experiments/2026-07-08-g1-limb-marl-gcn-token-critic|G1 limb MARL advantage baseline]]
- [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|G1 centroidal CMM ablation]]

## Relations

- target: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]
- setting: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]
- physical-prior: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
