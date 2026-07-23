---
type: method
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
---

# Multi-Agent Reinforcement Learning

## Goal

Multi-Agent Reinforcement Learning(MARL)은 여러 policy factor가 공동 환경에서 행동할 때 협력, 분산 관측과 credit assignment를 함께 학습한다.

## Mechanism

휴머노이드에서는 limb 또는 physical policy role을 agent로 둘 수 있다. independent learner, shared-parameter actor, centralized critic, MAPPO, counterfactual baseline은 서로 다른 training semantics다.

## Implementation Contract

- agent identity와 action concatenation order를 고정한다.
- actor/critic observation, reward, return, storage, optimizer 공유 여부를 명시한다.
- global performance와 agent별 credit metric을 함께 측정한다.

## Failure Modes

- 단순 reward partition을 cooperative advantage로 오해
- privileged critic observation을 shared centralized critic으로 오해
- agent 수 증가에 따른 variance와 non-stationarity를 통제하지 않음

## Relations

- framed-by: [[AI-Sessions/wiki/research/concepts/centralized-training-decentralized-execution|centralized-training-decentralized-execution]]
- addresses: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]
- applied-to: [[AI-Sessions/wiki/research/tasks/loco-manipulation|loco-manipulation]]

## Evidence

- MASH 2025
- Lee et al. 2025
- MAPPO/credit-assignment literature in the paper corpus
