---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2025-lee-humanoid-arm-cam-marl.pdf
---

# Learning Humanoid Arm Motion via Centroidal Momentum Regularized Multi-Agent RL (2025)

- 저자: Ho Jae Lee, Se Hwan Jeon, Sangbae Kim
- venue/arXiv: IEEE RA-L 2025 / arXiv:2507.04140
- source: AI-Sessions/raw/papers/2025-lee-humanoid-arm-cam-marl.pdf

## Abstract (한국어)

인간은 locomotion 중 팔을 자연스럽게 흔들어 whole-body dynamics를 조절하고 angular momentum을 줄이며 balance 유지에 도움을 준다. 이 원리에서 출발해, 본 논문은 humanoid robot의 emergent arm motion을 통해 coordinated whole-body control을 가능하게 하는 limb-level multi-agent RL framework를 제안한다. 방법은 arm과 leg에 별도 actor-critic 구조를 두고, centralized critic과 decentralized actor로 학습한다. 각 actor는 base state와 centroidal angular momentum(CAM) observation만 공유해 task-relevant behavior에 특화된다. arm agent는 CAM tracking과 damping reward로 overall angular momentum과 vertical ground reaction moment를 줄이는 arm motion을 만들며, locomotion과 perturbation 상황에서 balance를 개선한다. single-agent 및 다른 multi-agent baseline과의 비교, 그리고 humanoid hardware 배포로 flat walking, rough terrain, stair climbing에서 성능을 검증한다.

## 핵심 내용

논문은 팔과 다리를 하나의 policy로 묶는 대신 limb-level agent로 나누고, 학습 때 critic은 global 정보를 보되 실행 때 actor는 분산 실행하는 CTDE 구조를 사용한다. arm/leg는 완전히 독립이 아니라 centroidal dynamics, 특히 CAM을 통해 연결된다.

arm agent는 stylistic arm swing을 흉내내는 것이 아니라 CAM tracking/damping reward로 angular momentum을 줄이는 방향을 학습한다. 결과 분석에서는 arm motion이 total CAM과 vertical ground reaction moment를 줄여 disturbance recovery와 locomotion stability에 기여함을 보인다.

코드와 논문 모두 MIT Humanoid 기반이며, IsaacLab, customized rsl_rl, cusadi/Pinocchio 기반 centroidal quantity 계산을 사용한다.

## 내 연구 연결

이 논문은 `centroidal` concept와 `ppo` concept의 직접 근거다. 또한 humanoid arm dual role 아이디어에서 팔을 단순 upper-body output이 아니라 centroidal stabilization 요소로 보는 핵심 선행근거다.

Physical Feature Graph 관점에서는 CAM이 observation/reward에 들어갈 때 arm-leg coupling이 더 해석 가능한 형태로 학습될 수 있음을 보여준다.

## Links

- raw repo: AI-Sessions/raw/repos/2025-lee-humanoid-arm-cam-marl.md
- source note: [[AI-Sessions/wiki/research/sources/2025-lee-humanoid-arm-cam-marl-code|2025-lee-humanoid-arm-cam-marl-code]]
- concepts: [[centroidal]], [[ppo]]
