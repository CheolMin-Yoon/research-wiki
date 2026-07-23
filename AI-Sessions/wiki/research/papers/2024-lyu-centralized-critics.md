---
type: paper
date: 2026-07-18
status: active
topics:
  - reinforcement-learning
  - multi-agent-rl
  - credit-assignment
source: "AI-Sessions/raw/papers/2024-lyu-centralized-critics.pdf"
---

# On Centralized Critics in Multi-Agent Reinforcement Learning (2023)

- 저자: Xueguang Lyu, Andrea Baisero, Yuchen Xiao, Brett Daley, Christopher Amato (Northeastern)
- venue/arXiv: JAIR 77:295–354 (2023), arXiv:2408.14597
- source: "AI-Sessions/raw/papers/2024-lyu-centralized-critics.pdf" (60쪽 — 서론·주장부 정독, 증명부는 필요 시 참조)

## Abstract (한국어)

CTDE에서 centralized critic(전체 시스템 정보·true state 접근)으로 분산 actor를 학습하는 것이 MARL의 사실상 표준이 됐지만, 그 효과는 이론적·실증적으로 충분히 분석된 적이 없다. 본 논문은 centralized/decentralized critic과 state-based critic의 부분관측 환경 효과를 형식적으로 분석한다. 통념과 반대되는 이론을 유도한다: critic 중앙화는 엄밀히 이득이 아니며, state value 사용은 해로울 수 있다. 특히 state-based critic은 history-based critic 대비 예상치 못한 bias와 variance를 유발할 수 있음을 증명한다. 광범위한 벤치마크 비교로 이론의 실제 적용을 보이며, 부분관측 하 표현 학습의 어려움 같은 실무 문제가 이 이론적 문제를 문헌에서 가려온 이유임을 강조한다.

## 핵심 내용 (주장 5개)

1. **중앙화는 이론적 이득이 없다**: history-based critic 기준, centralized와 decentralized critic은 **기대 policy gradient가 동일** — 중앙 critic은 값 학습이 쉬울 뿐, 분산 policy 집합의 협력 문제(action shadowing 등)를 해결해주지 않는다(중앙 *policy*와 혼동된 통념 교정).
2. **state-based critic의 bias**: 부분관측 환경에서 state 조건 critic은 provably correct한 history 기반 대비 **unbounded bias** 가능 — 점근 수렴성 자체가 깨질 수 있다. 정보 수집(active information gathering)이 필요한 과제에서 특히 위험.
3. **중앙화는 variance를 높인다**: centralized critic은 policy gradient 분산을 늘리며, unbiased여도 state 조건화가 이를 악화.
4. **권고 = history-state critic**: history와 state를 함께 조건화하면 bias 없이 state 정보를 활용(이론 분산은 더 높아도 실무 trade-off 유리).
5. **실증**: 다수 벤치마크에서 critic 유형 간 큰 성능 차가 없는 경우가 많음 — 흔한 벤치마크가 부분관측성이 약하기 때문. 안정적 policy가 유리한 환경에선 decentralized critic이 우세하기도. **critic 선택은 과제 의존적·의식적 결정이어야 한다.**

## 내 연구 연결

- **논증 2·4의 이론 근거**: "중앙집중 단일 critic이 이상적"이라는 전제 자체가 이론적으로 특권이 없다 — 단일 중앙 critic 고수보다 multi-critic/분해 신호 탐색(idea-model-based-critic)의 명분을 강화. 특히 "critic 중앙화 ≠ credit 문제 해결"(주장 1)은 논증 4(단일 critic에서의 분해가 미해결)와 정합.
- **role-local critic의 정당화**: limb/role별 critic이 좁은 입력(role-local obs)을 봐도 기대 gradient 손해가 없다는 방향의 근거(주장 1·3) — 2A2C/1A3C에서 critic 입력을 role별로 좁히는 설계 선택의 이론 참조.
- **주의: 우리 셋업의 state-based critic**: 2A2C·GCN CTDE의 critic은 state 기반이고 actor는 의도적 부분관측(leg/arm obs group)이다. 시뮬레이션 proprioception은 거의 완전관측이라 bias 위험이 작지만, 관측 노이즈·sim-to-real·정보수집형 과제로 가면 주장 2가 적용되므로 history(-state) critic 전환을 검토해야 한다.
- 벤치마크의 부분관측성 부족이 이론 문제를 가린다는 지적은 ΔA류 진단(2026-kim-gpae)처럼 **표준 지표 밖의 평가 설계**가 필요하다는 우리 관찰과 공명.

## Relations
