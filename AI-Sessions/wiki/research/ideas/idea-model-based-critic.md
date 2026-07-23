---
type: idea
date: 2026-07-18
status: active
topics:
  - humanoid
  - locomotion
  - loco-manipulation
  - reinforcement-learning
  - model-predictive-control
  - multi-agent-rl
  - credit-assignment
source: AI-Sessions/raw/ideas/model-based-critic.md
---

# Model-Based Critic

## Hypothesis

신체 role별 multi-critic CTDE에서 사람이 나눈 reward group 대신 QP task 잔차나 MPC cost-to-go를 role별 평가 신호로 사용하면, 동일한 정책 용량과 환경 interaction budget에서 수동 reward 분해보다 안정적이고 재사용 가능한 credit을 얻을 수 있다.

약한 형태는 MPC/QP 신호를 reward shaping, critic auxiliary target 또는 baseline으로 쓰는 것이고, 강한 형태는 role별 finite-horizon cost-to-go가 critic을 일부 대체하는 것이다.

## Falsification

- 같은 task에서 모델 기반 신호가 수동 reward group보다 seed 평균 return, tracking, fall rate 또는 sample efficiency를 개선하지 못한다.
- 모델 mismatch 때문에 critic bias가 커져 learned critic 단독보다 policy update 분산이나 최종 성능이 나빠진다.
- task/contact 구성이 바뀔 때 QP/MPC objective를 다시 손으로 조정해야 해 reward engineering 비용을 실제로 줄이지 못한다.
- 계산 비용을 포함하면 wall-clock/sample trade-off가 단순 CTDE baseline보다 열등하다.

## Evidence For

- MPC는 미래를 포함한 optimal cost-to-go를 제공하고, WBC-QP는 CoM, contact, swing, posture처럼 이미 task별 residual을 분리한다.
- MPC-guided RL은 trajectory landmark와 privileged critic information을 training-time teacher로 활용할 수 있음을 보인다.
- 단일 humanoid를 limb/role agent로 보는 MARL과 multi-critic 선행연구는 구조 자체가 실행 가능함을 뒷받침한다.
- 계산된 Jacobian/CMM mapping은 어느 joint가 어느 task residual에 관여하는지 알려 주므로 learned credit의 prior로 사용할 수 있다.

## Evidence Against

- 축소 centroidal model의 value는 full-body contact와 actuator dynamics를 빠뜨려 systematic bias를 만든다.
- scalar MPC optimum은 어떤 body role이 기여했는지 직접 분해하지 않으며, task별 cost weight가 곧 올바른 credit이라는 보장은 없다.
- solver latency, failure, discontinuous contact schedule이 RL throughput과 target stationarity를 해칠 수 있다.
- learned critic이 model residual을 충분히 학습하지 못하면 model prior가 탐색을 잘못된 영역에 고정할 수 있다.

## Related Experiments

- [[AI-Sessions/wiki/research/experiments/2026-07-08-g1-limb-marl-gcn-token-critic|G1 limb MARL critic baseline]]
- [[AI-Sessions/wiki/research/experiments/2026-06-28-g1-centroidal-cmm-vs-baselines|G1 centroidal/CMM baselines]]

## Relations

- formalizes: [[AI-Sessions/wiki/research/concepts/credit-assignment|credit-assignment]]
- uses: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]
- uses: [[AI-Sessions/wiki/research/methods/whole-body-control|whole-body-control]]
- evidence-map: [[AI-Sessions/wiki/research/comparisons/humanoid-mbc-teacher-integration|humanoid-mbc-teacher-integration]]
