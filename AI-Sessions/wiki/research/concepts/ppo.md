---
tags: [tier/mid]
type: concept
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2017-schulman-ppo.pdf
---

# PPO (Proximal Policy Optimization)

## 정의

PPO는 policy gradient를 여러 epoch의 minibatch SGD로 안정적으로 최적화하기 위한 on-policy 알고리즘이다. probability ratio

$$r_t(\theta) = \frac{\pi_\theta(a_t\mid s_t)}{\pi_{\theta_{old}}(a_t\mid s_t)}$$

를 정의하고, clipped surrogate objective

$$L^{CLIP}(\theta) = \hat{\mathbb{E}}_t\!\left[\min\!\big(r_t(\theta)\hat{A}_t,\ \text{clip}(r_t(\theta),1-\epsilon,1+\epsilon)\hat{A}_t\big)\right]$$

를 최대화한다($\epsilon$은 보통 0.2). clip은 ratio가 $[1-\epsilon,1+\epsilon]$ 밖으로 나가도록 만드는 업데이트의 incentive를 제거해, TRPO의 trust region을 1차 근사로 대체한다. min을 취하므로 unclipped objective의 pessimistic lower bound가 된다.

parameter를 공유하는 actor-critic에서는 value error와 entropy bonus를 더해

$$L^{CLIP+VF+S} = \hat{\mathbb{E}}_t\!\left[L^{CLIP} - c_1 L^{VF} + c_2 S[\pi_\theta]\right]$$

를 쓴다. advantage는 보통 GAE로 추정한다. 알고리즘은 $N$개 actor가 $T$ step을 모아 $NT$ 샘플로 $K$ epoch 최적화하는 구조다.

## 사용 논문

- [[AI-Sessions/wiki/research/papers/2017-schulman-ppo|2017-schulman-ppo]] — 원전. clipped surrogate objective
- [[AI-Sessions/wiki/research/papers/2025-rsl-rl-library|2025-rsl-rl-library]] — 로보틱스용 PPO 구현 라이브러리
- [[AI-Sessions/wiki/research/papers/2025-mjlab|2025-mjlab]] — MuJoCo Warp 기반 학습 프레임워크, PPO 학습 런타임

(footstep, arm-cam 논문도 PPO를 쓰지만 partition 원칙에 따라 각각 lipm·centroidal로 분류한다. graph 중복 방지.)

## 구현 포인트

- on-policy라 rollout 후 같은 데이터로 $K$ epoch만 재사용한다. ratio가 1에서 멀어지면 clip이 작동.
- value loss, entropy coefficient, GAE $\lambda$, clip $\epsilon$, max grad norm이 주요 하이퍼파라미터.
- 위키 모든 locomotion RL(footstep, CAM)의 학습 골격이 PPO다.

## 연결 아이디어

- [[idea-physical-feature-graph]] — stability language graph를 representation으로 제공해 actor/critic 양쪽의 상태 이해를 구조화
- [[idea-humanoid-arm-dual-role]] — 팔의 역할 구분(stabilizer/wrench source)을 token grouping으로 제공하면 critic의 return 추정 정확도 향상 가능

## Links

- raw: AI-Sessions/raw/papers/2017-schulman-ppo.pdf
