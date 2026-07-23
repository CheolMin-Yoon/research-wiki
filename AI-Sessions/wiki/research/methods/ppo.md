---
type: method
date: 2026-07-24
status: active
topics:
  - reinforcement-learning
---

# Proximal Policy Optimization

## Goal

PPO는 on-policy rollout을 여러 minibatch epoch에 재사용하면서 policy update가 너무 멀리 이동하는 유인을 제한한다.

## Mechanism

$$r_t(\theta)=\frac{\pi_\theta(a_t\mid s_t)}{\pi_{\theta_{old}}(a_t\mid s_t)}$$

$$L^{CLIP}=\mathbb{E}_t\left[\min\left(r_t\hat A_t,\operatorname{clip}(r_t,1-\epsilon,1+\epsilon)\hat A_t\right)\right]$$

actor-critic 구현은 value loss, entropy bonus, GAE, gradient clipping과 rollout/update lifecycle을 함께 소유한다.

## Assumptions and Failure Modes

- rollout은 update 시점 정책과 가까워야 하며 오래된 replay를 임의로 섞지 않는다.
- advantage normalization, value clipping, termination bootstrapping 차이는 재현성에 직접 영향을 준다.
- multi-policy 시스템에서 PPO instance 여러 개는 자동으로 MAPPO가 아니다.

## Relations

- extended-by: [[AI-Sessions/wiki/research/methods/multi-agent-reinforcement-learning|multi-agent-reinforcement-learning]]
- applied-to: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Evidence

- Schulman et al. 2017
- RSL-RL and MJLab implementations
