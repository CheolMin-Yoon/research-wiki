---
type: concept
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
---

# Centralized Training, Decentralized Execution

## Definition and Boundary

Centralized Training, Decentralized Execution(CTDE)은 학습 중 critic이나 learner가 공동 상태·행동 정보를 사용하되 실행 actor는 각자의 배포 가능한 관측만 사용하는 factorization이다. 여러 독립 PPO learner에 privileged observation을 주는 것만으로는 shared centralized value나 cooperative advantage가 생기지 않는다.

## Why It Matters

limb별 actor를 유지하면서 전신 협응 정보를 학습에만 사용할 수 있다. 그러나 centralized critic이 항상 더 낮은 분산이나 더 정확한 policy gradient를 보장하지는 않는다.

## Engineering Implications

- actor observation, critic observation, reward, storage, optimizer의 공유 여부를 각각 명시한다.
- checkpoint identity와 execution action order는 training topology와 분리한다.
- independent learners, shared critic MAPPO, counterfactual critic을 별도 baseline으로 비교한다.

## Relations

- frames: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]
- addresses: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]

## Evidence

- Lee et al. 2025, humanoid arm/leg CTDE configurations
- Lyu et al. 2024, centralized critic limitations
- MASH 2025, limb agents with a global critic
