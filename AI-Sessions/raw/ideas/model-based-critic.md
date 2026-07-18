---
type: raw-idea
date: 2026-07-18
status: active
source: 2026-07-18 세션 대화 (GPAE·dependence-graph credit 분석 후 사용자가 정식화한 메인 인사이트)
---

# Model-Based Critic — 신체 분할 multi-critic CTDE의 평가 신호를 MPC/QP가 만든다

> 사용자 본인의 **메인 연구 인사이트**다. 기존 아이디어들(physical-feature-graph, centroidal-momentum-allocation-credit과 그 파생)은 이 인사이트의 하위 축으로 재배치된다. 아래 5단계 논증이 원문이다.

## 논증 (사용자 원문 정리)

1. 단일 에이전트(단일 로봇)에 대한 RL에서 **단일 액터–멀티 크리틱, 멀티 액터–멀티 크리틱** 구조가 최근 많이 사용되며, 이미 우수한 성능을 입증했다.

2. 따라서 기존 CTDE 연구의 **중앙집중형 단일 크리틱**이 아니라, **중앙집중형 크리틱이 여러 개 있는 구조** 역시 설계 가능하다.

3. 그러나 중앙집중형 멀티 크리틱 구조의 문제는 **개별 크리틱에 대한 보상 자체를 설계해야 한다**는 것이다.

4. 가장 좋은 방법은 중앙집중형 단일 크리틱 기반으로 개별 에이전트에게 **크레딧/밸류 디컴포지션/어드밴티지 할당**을 해주는 것이겠지만, 이는 다수의 멀티 로봇이나 스타크래프트(SMAC)에서도 완벽히 연구되지 않은 영역이고, 심지어 단일 로봇에서는 신체 부위가 각각의 **role**을 가지므로 전체 task에 대한 기여 추정이 더욱 어렵다.

5. 따라서 내 의견은: 기존의 **MPC, QP 기반 방법으로 리워드를 생성해내는 접근**, 또는 **멀티 크리틱 구조에서 MPC/QP가 크리틱의 역할 자체를 할 수 있다면 어떠할까**라는 것이다.

## 두 갈래 (5번의 구체화)

- **(d1) MPC/QP → reward 생성기**: per-critic 보상을 손으로 설계하는 대신 model-based 최적화가 만들어낸다.
- **(d2) MPC/QP → critic 그 자체**: 학습된 value function의 자리를 model-based 평가(최적화의 cost-to-go 등)가 대신하거나 보강한다.

## 기존 아이디어와의 관계

- physical-feature-graph(표현 축: 물리를 관측/attention에 주입)와 centroidal-momentum-allocation-credit(계산된 credit 축: 물리로 advantage 분해)은 이 인사이트의 하위 축이다.
- 공통 원칙: **학습이 감당하던 것(표현의 coupling, credit 분배, 평가 신호)을 물리/모델 기반 계산으로 대체한다.**

## 보강 2026-07-18: 물리 매핑 = credit 할당의 Key

단일 로봇 기준으로는 Jacobian, Twist, Wrench와 같은, 그리고 Centroidal Dynamics(CMM)와 같은 어떤 **매핑**들이 존재한다. 이것이 결국 **Graph 또는 Transformer로써 크레딧 할당을 하려는 접근의 어떠한 Key**가 될 수 있다고 생각한다.

## 컴파일

- wiki 정본: AI-Sessions/wiki/research/idea-model-based-critic.md
