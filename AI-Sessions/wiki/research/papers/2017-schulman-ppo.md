---
type: paper
date: 2026-06-24
status: active
topics:
  - reinforcement-learning
source: AI-Sessions/raw/papers/2017-schulman-ppo.pdf
---

# Proximal Policy Optimization Algorithms (2017)

- 저자: John Schulman, Filip Wolski, Prafulla Dhariwal, Alec Radford, Oleg Klimov
- venue/arXiv: arXiv:1707.06347
- source: AI-Sessions/raw/papers/2017-schulman-ppo.pdf

## Abstract (한국어)

이 논문은 environment interaction으로 데이터를 샘플링하고 stochastic gradient ascent로 surrogate objective를 최적화하는 policy gradient method 계열을 제안한다. 표준 policy gradient가 샘플 하나당 한 번의 gradient update를 수행하는 것과 달리, 새로운 objective는 여러 epoch의 minibatch update를 가능하게 한다. Proximal Policy Optimization(PPO)은 TRPO의 장점 일부를 가지면서 구현이 훨씬 단순하고, 더 일반적이며, 경험적으로 더 좋은 sample complexity를 보인다. simulated robotic locomotion과 Atari task에서 PPO는 다른 online policy gradient method보다 좋은 성능을 보이고, sample complexity, simplicity, wall-time 사이의 균형이 좋다.

## 핵심 내용

PPO의 핵심은 old policy 대비 probability ratio를 사용하되, ratio를 clip한 surrogate objective를 최적화해 너무 큰 policy update를 억제하는 것이다. 논문은 TRPO의 trust region 아이디어를 1차 최적화로 단순화하면서도 안정성을 유지하려 한다.

학습 루프는 policy로 rollout을 수집하고, 수집된 batch에 대해 여러 epoch/minibatch SGD를 수행한다. continuous control과 Atari 실험에서 clipped objective variant가 안정성과 성능 면에서 좋은 선택임을 보인다.

## 메커니즘

probability ratio

$$r_t(\theta) = \frac{\pi_\theta(a_t\mid s_t)}{\pi_{\theta_{old}}(a_t\mid s_t)}$$

를 정의하고, clipped surrogate objective

$$L^{CLIP}(\theta) = \hat{\mathbb{E}}_t\!\left[\min\!\big(r_t(\theta)\hat{A}_t,\ \text{clip}(r_t(\theta),1-\epsilon,1+\epsilon)\hat{A}_t\big)\right]$$

를 최대화한다($\epsilon$은 보통 0.2). clip은 ratio가 $[1-\epsilon,1+\epsilon]$ 밖으로 나가도록 만드는 업데이트의 incentive를 제거해, TRPO의 trust region을 1차 근사로 대체한다. min을 취하므로 unclipped objective의 pessimistic lower bound가 된다.

parameter를 공유하는 actor-critic에서는 value error와 entropy bonus를 더해

$$L^{CLIP+VF+S} = \hat{\mathbb{E}}_t\!\left[L^{CLIP} - c_1 L^{VF} + c_2 S[\pi_\theta]\right]$$

를 쓴다. advantage는 보통 GAE로 추정한다. 알고리즘은 $N$개 actor가 $T$ step을 모아 $NT$ 샘플로 $K$ epoch 최적화하는 구조다.

### 구현 포인트

- on-policy라 rollout 후 같은 데이터로 $K$ epoch만 재사용한다. ratio가 1에서 멀어지면 clip이 작동.
- value loss, entropy coefficient, GAE $\lambda$, clip $\epsilon$, max grad norm이 주요 하이퍼파라미터.

## 내 연구 연결

이 논문은 PPO의 원전이며, Lee 계열 humanoid locomotion 논문, rsl_rl, mj_rl의 on-policy 학습 구조를 이해하는 기본 축이다.

구현 측면에서는 clipping, value loss, entropy, GAE, KL monitoring, timeout handling 같은 실무 디테일이 rsl_rl/mj_rl의 안정성에 직접 연결된다.

## Relations

- related papers: [[AI-Sessions/wiki/research/papers/2025-rsl-rl-library|2025-rsl-rl-library]], [[AI-Sessions/wiki/research/papers/2024-lee-footstep-planning-rl|2024-lee-footstep-planning-rl]], [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]]
