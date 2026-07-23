---
type: paper
date: 2026-07-18
status: active
topics:
  - humanoid
  - loco-manipulation
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
source: "AI-Sessions/raw/papers/2026-yardimci-critic-architecture.pdf"
---

# Critic Architecture Matters: Dual vs. Unified Critics for Humanoid Loco-Manipulation (2026)

- 저자: Mehmet Turan Yardımcı (Çukurova University, 단독)
- venue/arXiv: arXiv:2606.11891 (4쪽, workshop급 preprint)
- source: "AI-Sessions/raw/papers/2026-yardimci-critic-architecture.pdf"

## Abstract (한국어)

휴머노이드 multi-objective RL에서 locomotion과 manipulation을 한 policy로 조정할 때, 모든 objective의 결합 가치를 추정하는 단일(unified) critic을 쓸지, 분리된(disjoint) reward 신호를 갖는 별도(dual) critic을 쓸지 통제 비교한다. Unitree G1(23 DoF), Isaac Lab, 13단계 순차 curriculum. 표준화 평가에서 dual-critic policy가 3.5× 빠른 도달(6.5 vs 22.6 step), 2× throughput(14.3 vs 7.0/1000step), 더 높은 검증 reach rate(65.2% vs 53.8%)를 달성했다. 반면 추가적인 anti-gaming reward 설계는 구조 변경 이상의 이득이 없었다(60.9% vs 65.2%). critic 구조가 reward engineering보다 큰 영향을 갖는 1차 설계 선택임을 보인다.

## 핵심 내용

- **구조**: dual actor(π_loco 12 leg / π_arm 5 arm) + frozen-branch transfer(locomotion 학습 후 동결, arm 신규). unified = 109-dim concat 관측의 단일 V가 합산 reward 평가, dual = loco critic(velocity tracking·balance·energy)과 arm critic(reach 거리·displacement)이 **disjoint reward group**을 각각 평가.
- **메커니즘 관찰**: unified critic에서 arm action magnitude가 절반(1.22 vs 2.54) — 초기 학습을 지배하는 locomotion reward가 arm 행동에 보수적 gradient를 주는 **objective 간 gradient 간섭**이 병목. dual critic은 각 branch에 자기 objective의 gradient만 흐르게 격리한다.
- **reward engineering 무력**: anti-gaming 장치 5종을 더해도(S7) dual 구조 자체(S6s)를 못 넘는다 — "구조 > 보상 설계".
- **훈련 지표가 차이를 가린다**: reward·curriculum 진행은 두 구조가 비슷해 보이고, 표준화 평가(time-to-reach, throughput)에서만 3.5×가 드러남.
- **IL+RL 미세조정 함의**: unified critic은 사전학습(IL) 행동을 경쟁 gradient로 억압할 위험 — dual critic이 gradient를 해당 branch로 격리해 IL 스킬 보존.
- **한계(저자 인정)**: 단일 seed, arm 5-DoF로 action 차원 confound(12 vs 5), 시뮬레이션 한정. future work가 29-DoF Triple Actor-Critic.

## 내 연구 연결

- **논증 1–3의 가장 직접적인 실증**: "multi-critic(분리 보상) 구조가 단일 중앙 critic보다 낫다"를 단일 휴머노이드 loco-manipulation에서 통제 비교로 보인 유일하게 알려진 사례 — 단, 근거 강도는 4쪽·단일 seed 수준이므로 인용 시 보조 증거로. 우리의 2A2C/Spot-1A3C 인프라(multi-seed, gamma sweep)가 이 질문을 더 강하게 실증할 수 있는 위치다.
- **reward group은 여전히 손 설계(설계공간 (a))**: loco/arm critic의 보상 분할이 수동이다 — (d1) "QP task 구조가 분해를 준다"가 채우는 자리가 이 논문에도 그대로 비어 있다.
- **"gradient 간섭" = coupling의 학습적 표현**: 언제 unified가 무너지는가에 대한 이들의 답은 사후 관찰(간섭 발생)뿐이다. 우리의 매핑 사전 block-구조 기준은 **언제 분리해야 하는지를 사전에 예측**하는 원리(off-diagonal coupling 크기)를 제공 — 이 논문의 관찰(loco↔arm 간섭)은 contact 없는 reach에서도 base 경유 hub 결합이 있다는 우리 가설과 부합.
- future work(29-DoF triple critic)가 우리 영역으로 접근 중 — 시간적 우선권 측면에서 (d1)/분할 기준 실험을 서두를 근거.

## Relations
