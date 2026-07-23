---
type: paper
date: 2026-07-06
status: active
topics:
  - humanoid
  - locomotion
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
  - morphology-aware-policy
source: "AI-Sessions/raw/papers/MASH_ Cooperative-Heterogeneous Multi-Agent Reinforcement Learning for Single Humanoid Robot Locomotion.pdf"
---

# MASH: Cooperative-Heterogeneous Multi-Agent RL for Single Humanoid Robot Locomotion (2025)

- 저자: Qi Liu, Xiaopeng Zhang, Mingshan Tan, Shuaikang Ma, Jinliang Ding, Yanjie Li
- venue/arXiv: arXiv:2508.10423 (Aug 2025)
- source: "AI-Sessions/raw/papers/MASH_ Cooperative-Heterogeneous Multi-Agent Reinforcement Learning for Single Humanoid Robot Locomotion.pdf"

## Abstract (한국어)

단일 휴머노이드 로봇의 locomotion을 single-agent RL이 아니라 **cooperative-heterogeneous MARL 문제**로 재정식화한다. 각 팔·다리(limb)를 독립 agent로 두고 MAPPO(CTDE)로 학습하며, 두 다리는 하나의 shared-parameter actor를, 두 팔은 또 다른 shared-parameter actor를 공유하고, 전신 global critic이 협응을 조율한다. BanXing 휴머노이드 시뮬레이션·실물 실험에서 single-agent PPO 대비 수렴 속도, action smoothness, torso stability, limb coordination 전 지표에서 우위를 보였고 sim-to-real도 검증했다.

## 핵심 내용

### 문제 정식화

- decPOMDP $G=(S,A,P,r,Z,O,N,\gamma,T)$: 4개 agent(좌/우 다리, 좌/우 팔)가 각자 관측 $z_t^n$과 정책 $\pi^n$을 갖고 공유 보상 $r(s_t,a_t)$로 학습.
- MAPPO objective(식 7): agent별 clipped surrogate를 합산, advantage $\hat A_t$는 global critic에서 공유.

### Actor/Critic 구조

- **Actor**: bipedal(다리 2개)과 dual-arm(팔 2개) 각각 shared-parameter 네트워크. 다리 agent obs 32차원(모터 6+6 vel+6 last action+gait phase 2+torso Euler 3+angular vel 3+command 4+one-hot ID 2) × 2 = 64차원 입력. 팔 agent obs 26차원 × 2 = 52차원. output은 관절 torque(다리 12, 팔 8).
- **Critic**: 전신 global observation(모터 pos/vel/action/deviation 20×4, gait phase, command, torso 상태, 외란 force/torque, friction/mass, contact mask 등) → $o_t^{critic}\in\mathbb{R}^{106}$, value $V_t\in\mathbb{R}^4$.
- **Temporal director** $T_i(t)=\sin(2\pi(kt+\Delta_i))$: limb별 phase offset으로 gait 동기화를 shared observation에 주입(agent ID one-hot과 함께).
- shared-parameter 선택 근거: 좌우 대칭 limb 쌍이 물리적으로 대칭·기구적으로 coupling되어 있어 파라미터 공유가 자연스럽고 계산량도 줄어든다(reasoning은 StarCraft류 독립 multi-agent와 대비).

### 평가 지표 (single-agent PPO 대비, 모두 개선)

- $T_{Conv}$(수렴 반복 수): bipedal ~1306 vs ~1661, whole-body ~1017 vs ~1238.
- $S_{action}$(2차 action 차분 L2): 0.107 vs 0.547 (bipedal).
- $S_{torso}$(높이/자세 분산): $8.24\times10^{-4}$ vs $3.4\times10^{-3}$ (bipedal).
- $C_{limb}$(좌우 phase 오차): 0.612 vs 0.974 (bipedal).
- Isaac Gym → MuJoCo sim-to-sim → 실물(BanXing) 순서로 검증, domain randomization(질량/마찰/딜레이/외란 등) 사용.

### 관련 선행연구

- 같은 저자 그룹의 MASQ(arXiv:2408.13759, 2024)가 단일 사족보행 로봇에 동일 paradigm(limb=agent MARL)을 먼저 적용; MASH는 이를 휴머노이드(양팔+양다리, heterogeneous agent)로 확장한 버전.

## 내 연구 연결

- MASH는 **morphology를 명시적 그래프/attention으로 인코딩하지 않고**, "limb = agent + shared-parameter + global critic"이라는 MARL 분해로 관절 간 협응을 얻는다. Physical Feature Graph 아이디어([[AI-Sessions/wiki/research/ideas/idea-physical-feature-graph|idea-physical-feature-graph]])의 CMM-conditioned attention 접근과는 다른 축의 solution(알고리즘/학습 구조 vs representation)이라 직접 baseline은 아니지만, "팔-다리 coupling을 어떻게 정책 구조에 반영하는가"라는 동일 문제의식을 공유한다.
- global critic이 전신 상태(모터+외란+접촉+CoM 관련 항)를 관측하는 방식은 우리 idea의 centroidal token 주입과 목적은 비슷하나(전신 정보를 학습 신호로), MASH는 이를 critic에만 주고 actor는 limb-local observation만 쓴다는 점이 다르다(우리는 actor 쪽 attention에 CMM을 직접 주입).
- shared-parameter actor(좌우 대칭 pair 공유)는 GCNT/BoT류 morphology-aware 인코더의 대안적/저비용 baseline으로 참고할 수 있다.

## Relations
