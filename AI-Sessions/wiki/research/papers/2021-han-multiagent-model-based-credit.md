---
type: paper
date: 2026-07-18
status: active
topics:
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
source: "AI-Sessions/raw/papers/2021-han-multiagent-model-based-credit.pdf"
---

# Multiagent Model-based Credit Assignment for Continuous Control (2021)

- 저자: Dongge Han, Chris Xiaoxuan Lu, Tomasz Michalak, Michael Wooldridge (Oxford/Edinburgh/Warsaw)
- venue/arXiv: AAMAS 2022, arXiv:2112.13937
- source: "AI-Sessions/raw/papers/2021-han-multiagent-model-based-credit.pdf"

## Abstract (한국어)

로봇을 분산 agent 시스템으로 정식화하고 연속제어를 위한 decentralized MARL framework를 제안한다. 먼저 CTDE 협력 multiagent PPO framework를 구성하는데, 시스템은 agent별로 귀속되지 않은 global reward만 받는다. 이를 해결하기 위해 agent별 reward 신호를 계산하는 일반적 game-theoretic credit assignment framework를 제안하고, 나아가 model-based RL 모듈을 credit assignment에 결합해 sample efficiency를 크게 높인다. MuJoCo locomotion 과제에서 효과를 검증한다.

## 핵심 내용

### 문제 설정: 로봇 joint = agent

kinematics tree(bodies/joints/actuators)로 로봇을 multiagent 시스템으로 정식화 — 각 agent는 body+연결 joint+actuator 하나(cheetah 7, ant). 각 actor는 local 관측(자기 joint 상태 등)만 보고 분산 실행, 팀은 global reward 하나(전진 속도 등)만 받는다.

### Game-theoretic credit: semivalue = 가중 marginal contribution

- coalition value: $v^C(s_t,\mathbf a_t) = Q^\pi(s_t, \tilde{\mathbf a}_t)$, 여기서 **coalition 밖 agent의 action은 default action(zero)으로 치환**. marginal contribution $\mathcal{MC}^i(C) = v^{C\cup\{i\}} - v^C$ = "agent $i$의 실제 action이 default 대비 만든 차이".
- **semivalue** $\psi^i = \sum_c p_c\,\overline{\mathcal{MC}^i}(c)$: coalition 크기 분포 $p_c$의 선택으로 Shapley($p_c=\frac1N$ 균등), Banzhaf(bell-shape), **Leave-one-out**($p_c=\mathbb 1_{c=N-1}$ — difference reward $G-G_{-i}$와 동일) 등을 포괄하는 일반형. 이 $\psi^i$를 PPO clip objective의 agent별 "pseudo advantage"로 사용.

### "Model-based"의 실체: 학습된 dynamics/reward 모델로 coalition 평가

- coalition value를 model-free Q-critic으로 추정(Q-Shapley)하면 고차원 연속공간에서 부정확 → **학습된 모델** $f_s, f_r$(supervised)과 상태가치 critic으로 1-step model expansion: $Q(s,\tilde{\mathbf a}) \approx f_r(s,\tilde{\mathbf a}) + \gamma V^\pi(s + f_s(s,\tilde{\mathbf a}))$. 모델은 중앙학습에만 쓰며 짧은 horizon 상상만으로 drift를 억제.
- 결과: MB-Shapley/Banzhaf/Loo 모두 MAPPO(공유 advantage)와 Q-Shapley를 크게 상회(Ant에서 MB-Banzhaf ~1400 vs MAPPO ~1100, 3배 빠른 도달). coalition당 1 sample로도 충분(전체 학습 스텝 수가 커버).
- coalition 크기 분석: cheetah는 joint 간 상호의존이 커 mid-size coalition이 필요, ant는 다리가 독립적 — **로봇 형태에 따라 결합 구조가 다르고 semivalue가 그걸 반영**해야 함. Shapley/Banzhaf 학습 로봇은 joint의 역할 분화(전진용 부분집합 + 조향용)도 관찰.

## 내 연구 연결

- **"model-based" 명칭 충돌 해소**: 이 논문의 model-based는 **학습된 neural world model**이다. idea-model-based-critic의 (d) — physics/최적화(MPC/QP) 기반 신호 — 와 다르며, 오히려 (b) learned 분해 계열의 joint=agent 연속제어 정본이다. novelty 문장은 "learned world model로 coalition을 평가하는 Han et al.과 달리, 우리는 물리 모델(CMM/QP)로 counterfactual을 계산한다"로 안전하게 쓸 수 있다.
- **CMM credit의 game-theoretic 정식화 발견**: 이들의 coalition 규약(비참여 joint→default action)은 credit note의 "joint $j$ 정지 counterfactual"($\dot q_j=0$ → $k_{-j}=k_G-c_j$)과 동일 구조다. 즉 **CMM credit = CAM 목적함수를 characteristic function으로 하는 exact Leave-one-out semivalue** — 학습 모델 없이 물리 항등식으로 $v^C$를 닫힌형 계산하는 특수 사례. semivalue 언어(Shapley/Banzhaf 가중)로 CMM credit의 변형 계열(pairwise 이상 coalition = JSIM 결합 반영)도 체계적으로 정의 가능.
- coalition 크기 분석(cheetah 상호의존 ↔ ant 독립)은 "critic/credit 분할 = coupling 구조 따라야" 주장의 독립 증거 — 우리는 그 결합 구조를 실험 대신 $A_G$/JSIM block으로 사전 계산한다.
- joint=agent + local 관측 + 분산 실행 셋업은 MASH/2A2C 계열의 선행 원형(2021)으로, 논증 1의 근거 목록에 추가.

## Relations
