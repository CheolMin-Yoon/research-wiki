---
type: idea
date: 2026-06-27
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - centroidal-dynamics
  - morphology-aware-policy
  - graph-policy
source: AI-Sessions/raw/ideas/physical-feature-graph.md
---

# Physical Feature Graph

## Hypothesis

휴머노이드 정책의 graph/Transformer에 topology만 주는 대신 CMM column, task Jacobian, contact와 같은 계산 가능한 물리 mapping을 node·edge prior로 주입하면, 같은 파라미터와 학습 예산에서 topology-only graph 및 flat MLP보다 whole-body coordination과 sample efficiency가 좋아진다.

표현의 핵심은 pelvis/torso 같은 centroidal context와 limb token을 연결하되, 물리 feature가 action을 직접 결정하지 않고 attention/message passing의 key·bias·edge weight로 관계를 제한하도록 하는 것이다.

## Falsification

- topology-only GCN/BoT와 비교해 tracking, balance, CAM, success 또는 sample efficiency가 seed 범위에서 개선되지 않는다.
- CMM/Jacobian feature를 섞었을 때 frame·scale sensitivity가 커져 generalization이나 optimization stability가 나빠진다.
- 동일 효과가 단순 global-state broadcast나 더 큰 MLP로 재현돼 물리 graph prior의 독립 기여가 사라진다.
- attention/message pattern이 물리 coupling과 일치하지 않고 feature ablation에도 성능이 변하지 않는다.

## Evidence For

- $h_G=A_G(q)\dot q$와 $\dot x=J(q)\dot q$는 joint contribution을 column별로 제공하며 weighted aggregation이라는 graph attention과 같은 계산 형태를 가진다.
- 팔은 비접촉 시 CAM 보상, 접촉 시 wrench 전달이라는 두 역할을 가져 lower/upper body 결합을 시험하기 좋은 축이다.
- morphology-aware graph policies와 Body Transformer는 구조적 tokenization이 locomotion policy에서 작동할 수 있음을 보여 준다.

## Evidence Against

- CMM은 instantaneous aggregate momentum만 표현하고 contact intent, terrain, future value를 담지 않는다.
- dense physical prior가 잘못된 frame이나 normalization으로 주입되면 policy가 더 취약해질 수 있다.
- graph message passing의 큰 wall-clock 비용이 sample-efficiency 이득을 상쇄할 수 있다.
- 정확히 계산 가능한 mapping이 강한 inductive bias여도 task reward와 정렬되지 않으면 불필요한 feature가 된다.

## Related Experiments

- [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|G1 CMM graph baselines]]
- [[AI-Sessions/wiki/research/experiments/2026-07-10-isaac-mit-gcn-jacobian-early-screen|Jacobian GCN early screen]]
- [[AI-Sessions/wiki/research/experiments/2026-07-11-g1-29d-graph-mimic|G1 graph mimic]]

## Relations

- representation: [[AI-Sessions/wiki/research/concepts/morphology-aware-representation|morphology-aware-representation]]
- physical-state: [[AI-Sessions/wiki/research/concepts/centroidal-dynamics|centroidal-dynamics]]
- policy-family: [[AI-Sessions/wiki/research/methods/graph-policy|graph-policy]]
