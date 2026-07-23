---
type: idea
date: 2026-07-18
status: active
topics:
  - humanoid
  - imitation-learning
  - graph-policy
  - credit-assignment
source: AI-Sessions/wiki/research/ideas/idea-centroidal-momentum-allocation-credit.md
---

# Kinematic Dependence-Graph Credit

## Hypothesis

Humanoid imitation learning에서 reward term별 관여 joint 집합을 learned dependence graph 대신 kinematic reachability와 task Jacobian으로 계산해 advantage를 route하면, shared advantage와 learned graph credit보다 낮은 분산과 더 빠른 초기 학습을 얻는다.

## Falsification

- joint intervention으로 측정한 reward influence가 계산 graph의 reachable set과 일치하지 않는다.
- shared advantage 또는 learned dependence graph보다 tracking, convergence, variance에서 개선이 없다.
- contact와 dynamic coupling이 kinematic graph 밖의 장거리 credit를 지배해 distal joint 학습을 방해한다.

## Evidence For

- end-effector tracking reward는 해당 body Jacobian과 ancestor chain으로 직접 관여 joint 후보를 계산할 수 있다.
- known morphology를 다시 학습하지 않으면 early-stage graph estimation noise를 피할 수 있다.
- reward term별 overlapping joint set은 imitation task의 구조를 명시적으로 보존한다.

## Evidence Against

- kinematic reachability는 dynamic influence와 contact-mediated coupling을 포착하지 못한다.
- joint가 reward term에 reachable하다는 사실은 실제 marginal contribution의 크기나 부호를 주지 않는다.
- task Jacobian 계산 비용과 frame 오류가 단순 shared credit보다 큰 운영 복잡성을 만들 수 있다.

## Related Experiments

- [[AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic|G1 29-DoF graph mimic]]
- [[AI-Sessions/wiki/research/experiments/2026-07-10-isaac-mit-gcn-jacobian-early-screen|Jacobian GCN early screen]]

## Relations

- target: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]
- task-family: [[AI-Sessions/wiki/research/methods/imitation-learning|imitation-learning]]
- routing-prior: [[AI-Sessions/wiki/research/methods/graph-policy|graph-policy]]
