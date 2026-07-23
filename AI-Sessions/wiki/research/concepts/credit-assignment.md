---
type: concept
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
---

# Credit Assignment

## Definition and Boundary

Credit assignment는 공동 결과를 만든 행동, agent 또는 신체 부위에 학습 신호를 귀속하는 문제다. reward decomposition은 즉시 보상을 나누는 규칙이고, advantage/return credit은 시간과 정책 의존성을 포함하므로 같은 개념이 아니다.

## Why It Matters

휴머노이드 limb policy가 하나의 balance와 locomotion 결과를 만들 때 독립 reward partition만으로는 협응 기여를 구분하기 어렵다. 반대로 부정확한 centralized signal은 분산을 키우거나 부분관측 정책에 bias를 넣을 수 있다.

## Engineering Implications

- 비교 시 reward, value, advantage 중 어느 층의 credit인지 명시한다.
- joint/limb decomposition은 물리적 기여와 policy factorization을 혼동하지 않는다.
- counterfactual, dependence graph, vector critic은 서로 다른 가정을 가진 baseline으로 둔다.

## Relations

- learned-under: [[AI-Sessions/wiki/research/concepts/centralized-training-decentralized-execution|centralized-training-decentralized-execution]]
- implemented-by: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]

## Evidence

- Han et al. 2021, model-based semivalue credit
- Kim et al. 2026, generalized per-agent advantage estimation
- Le et al. 2026, dependence-graph policy-gradient credit
