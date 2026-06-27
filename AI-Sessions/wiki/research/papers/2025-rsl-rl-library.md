---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2025-rsl-rl-library.pdf
---

# RSL-RL: A Learning Library for Robotics Research (2025)

- 저자: Clemens Schwarke, Mayank Mittal, Nikita Rudin, David Hoeller, Marco Hutter
- venue/arXiv: arXiv:2509.10771
- source: AI-Sessions/raw/papers/2025-rsl-rl-library.pdf

## Abstract (한국어)

RSL-RL은 robotics community의 필요에 맞춘 open-source reinforcement learning library다. 일반 목적 framework와 달리 compact하고 쉽게 수정 가능한 codebase를 우선해 연구자가 알고리즘을 적은 overhead로 수정하고 확장할 수 있게 한다. 이 라이브러리는 robotics에서 널리 쓰이는 알고리즘과 robotics-specific challenge를 다루는 auxiliary technique에 집중한다. GPU-only training에 최적화되어 large-scale simulation environment에서 high-throughput 성능을 달성하며, simulation benchmark와 real-world robot experiment에서 lightweight, extensible, practical framework로서의 유용성을 검증했다.

## 핵심 내용

논문은 RSL-RL을 Runner, Algorithm, Network의 세 구성요소로 설명한다. 주요 알고리즘은 PPO와 DAgger-style behavior cloning이며, symmetry augmentation, Random Network Distillation, multi-GPU training, logging backend를 제공한다.

Robotics 환경에 맞춰 VecEnv interface, TensorDict observation, timeout handling, large-batch rollout 다양화 같은 구현 세부를 강조한다. 목표는 많은 알고리즘을 모으는 것이 아니라, 로봇 학습에서 자주 바꾸는 부분을 작고 읽기 쉽게 유지하는 것이다.

## 내 연구 연결

이 논문은 `rl-algorithms-frameworks` category에서 PPO 구현 계층의 근거다. mj_rl에서 PPO runner/model을 바꾸거나 graph actor-critic을 넣을 때, rsl_rl의 Runner/Algorithm/Network 분리를 기준 인터페이스로 삼을 수 있다.

## Links

- raw repo: AI-Sessions/raw/repos/2025-rsl-rl-library.md
- source note: rsl-rl-code
- category: rl-algorithms-frameworks
