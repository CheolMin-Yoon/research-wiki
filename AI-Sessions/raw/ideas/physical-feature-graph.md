---
type: raw-idea
date: 2026-06-23
status: active
source: 2026-06-23 세션 대화; 기존 raw idea PDF 2개 정리 후 삭제
---

# 부유 동역학 로봇을 위한 Physical Feature Graph 인사이트

> 사용자 본인의 순수 연구 아이디어. 이 문서는 구현 계획이 아니라, 고전 안정성 해석과 현대 RL 사이를 잇는 물리 표현 관점을 정리한다.

## Summary

부유 동역학 로봇의 locomotion은 raw `q`, `dq`, target velocity만으로 주어지는 상태 공간보다, CoM, DCM, ZMP, CMM, CAM, contact, footstep, body relation처럼 이미 물리적으로 정의된 feature들의 coupling으로 더 잘 해석될 수 있다.

기존 GNN 기반 로봇 정책은 주로 joint-link 구조를 node-edge로 표현하거나, 다양한 morphology에 일반화되는 body graph를 목표로 했다. 반면 이 아이디어는 로봇의 기구학적 구조뿐 아니라, **안정성과 거시적 task 수행을 설명하는 물리학적·동역학적 특징 자체**를 graph/token 구조로 보려는 관점이다.

최종 인사이트는 다음과 같다.

> 고전 안정성 해석과 WBC/centroidal control이 사용하던 물리 언어는 현대 RL에서도 사라지면 안 된다. 이 언어는 기구학적·동역학적으로 서로 커플링되어 있으므로, graph 구조와 Transformer attention 구조를 통해 RL policy에 구조적 가이드로 접목할 수 있다.

## 출발점: Raw State RL의 한계

일반적인 locomotion RL은 로봇의 관절 상태 `q`, 관절 속도 `dq`, base state, target velocity 같은 raw observation을 주고, reward function으로 원하는 행동을 유도한다. 이 방식은 강력하지만, agent에게 사실상 다음과 같은 문제를 던지는 것과 비슷하다.

> 현재 관절 상태와 목표 속도는 이렇다. 이제 알아서 안정적으로 걸어라.

그러나 humanoid locomotion의 안정성은 단순한 관절 상태의 조합이 아니다. CoM이 어디에 있는지, DCM이 support 영역에 대해 어떻게 움직이는지, ZMP와 contact가 어떤 제약을 만드는지, CAM이 팔과 다리의 움직임으로 어떻게 변하는지 같은 물리적 의미가 중요하다.

따라서 이 아이디어의 문제의식은 raw state를 더 크게 만들자는 것이 아니라, agent가 안정성을 해석할 때 필요한 **stability language**를 구조화해 제공하자는 것이다.

## Stability Language

CoM, DCM, ZMP, CMM, CAM, contact, footstep은 단순한 hand-crafted feature가 아니다. 이들은 부유 동역학 로봇의 안정성을 설명하기 위해 고전 안정성 해석과 centroidal dynamics에서 추출된 물리 언어다.

예를 들어 [[3d-lipm-icp|LIPM/ICP]] 계열의 모델은 full-body humanoid를 완전히 설명하지 않는다. CoM 높이를 일정하게 두고, 로봇을 점질량처럼 보며, 다리 질량이나 swing leg dynamics를 직접 보지 않고, angular momentum도 제한하거나 무시한다. 이런 강한 제약 속에서 나온 것이 CoM, ZMP, DCM/ICP 같은 안정성 개념이다.

이 개념들은 현실을 완전히 담지 못하지만, 여전히 humanoid locomotion에서 강력하다. 이유는 이들이 full-body dynamics의 정답 모델이라서가 아니라, 안정성을 판단하는 거시적 좌표계이기 때문이다.

마찬가지로 CMM과 CAM은 whole-body angular momentum과 limb coupling을 해석하는 centroidal language다. 팔과 다리의 움직임은 서로 분리되어 보여도, 결국 CAM과 base state, contact stability 같은 공통 물리 변수 위에서 다시 결합된다.

## 고전 안정성 해석과 현대 RL 사이

고전 WBC와 최적화 제어는 CoM, ZMP, DCM, contact wrench, CAM 같은 물리량을 objective나 constraint로 두고 매 control step에서 안정한 움직임을 계산한다. 이 방식은 해석 가능하지만, 복잡한 contact-rich whole-body task에서는 설계와 계산 부담이 크다.

현대 RL은 이 복잡한 제어 판단을 학습된 policy로 대체할 수 있다. 하지만 raw `q`, `dq`, command 중심으로만 policy를 학습하면, 고전 안정성 해석이 제공하던 물리 언어가 관측과 reward 속에 흩어지거나 사라질 수 있다. 그러면 policy는 강력하지만 black-box에 가까워진다.

Physical Feature Graph 아이디어는 WBC/최적화 제어를 부정하는 것이 아니다. 오히려 고전 안정성 해석이 사용하던 물리 언어를 RL policy가 볼 수 있는 구조적 가이드로 남기려는 시도다.

## Lee 계열 연구와의 연결

[[2024-lee-footstep-planning-rl]]은 3D-LIPM/ICP 기반 footstep을 RL에 partial guidance로 제공한다. 핵심은 full CoM trajectory를 강제 추종시키는 것이 아니라, reduced-order model이 잘 설명하는 desired footstep을 저차원 물리 가이드로 주고, 실제 full-body dynamics의 나머지는 RL이 학습하게 하는 데 있다.

[[2025-lee-humanoid-arm-cam-marl]]은 CAM을 reward와 observation에 넣어 팔과 다리의 coordination을 유도한다. 팔과 다리를 별도 actor/critic 관점으로 나누더라도, 그 둘이 성립하는 이유는 서로 무관해서가 아니라 CAM이라는 공통 coupling variable 위에서 다시 연결되기 때문이다.

이 두 연구는 중요한 힌트를 준다.

- reduced-order physics는 버릴 대상이 아니라 RL에 줄 수 있는 좋은 guide다.
- 물리 feature는 reward function이나 observation으로 들어가면 학습을 더 해석 가능하고 안정적인 방향으로 유도할 수 있다.
- limb를 나누더라도 whole-body stability는 공통 물리 변수들의 coupling 위에서 결정된다.

Physical Feature Graph는 이 흐름을 footstep 하나나 CAM 하나에 머무르게 하지 않고, CoM/DCM/ZMP/CMM/CAM/contact/footstep/body relation 같은 stability language 전체의 coupling 구조로 확장하려는 관점이다.

## Body Graph와 Physical Feature Graph의 차이

[[2024-sferrazza-body-transformer|Body Transformer]] 같은 구조는 로봇의 joint, link, limb, sensor, actuator를 node로 보고, kinematic tree나 morphology를 edge로 둔다. 이 방식은 로봇의 몸 구조가 정책 표현에 들어간다는 점에서 중요하다.

하지만 humanoid locomotion에서 안정성을 설명하는 구조는 morphology만으로 충분하지 않다. CoM, DCM, ZMP, CMM, CAM, contact, footstep 같은 물리 특징은 body graph와는 다른 층위의 관계를 가진다.

따라서 이 아이디어는 morphology graph를 부정하지 않는다. 대신 다음 관점을 추가한다.

> 로봇의 몸이 어떻게 연결되어 있는가뿐 아니라, 안정성을 설명하는 물리 특징들이 어떻게 커플링되어 있는가도 graph로 표현할 수 있다.

## 네 가지 관점

Physical Feature Graph는 구현 스키마가 아니라 인사이트 수준에서 다음 네 관점을 함께 본다.

1. **로봇의 상태**
   - `q`, `dq`, base state, command 같은 기본 상태.
   - 기존 RL이 주로 받는 raw observation에 해당한다.

2. **물리적 특징**
   - CoM, DCM/ICP, ZMP, CMM, CAM, centroidal momentum 같은 stability language.
   - agent가 안정성을 해석하는 핵심 물리 의미 단위다.

3. **접촉정보**
   - stance/swing contact, support region, footstep, contact wrench, foothold feasibility.
   - floating-base robot에서 세계와 동역학이 연결되는 통로다.

4. **body 정보**
   - pelvis, torso, leg, foot, arm, hand/end-effector 같은 body relation.
   - 물리량이 어느 body part와 연결되는지 알려주는 anchor다.

중요한 것은 이 네 범주를 구체적으로 어떻게 구현할지가 아니라, humanoid locomotion을 raw state/action 문제가 아니라 **상태, 물리 특징, 접촉, body relation이 커플링된 안정성 해석 문제**로 본다는 점이다.

## 구조적 가이드

Physical Feature Graph는 정답 dynamics model이 아니다. LIPM, ZMP, DCM 같은 축소모델은 강한 가정을 가지고 있고, centroidal dynamics도 full-body contact-rich behavior를 모두 설명하지는 못한다.

그럼에도 이들은 agent에게 중요한 가이드를 제공한다.

> 이런 방식으로 움직이면 어떤 물리량이 자극되고, 그 자극은 안정성이나 거시적 task 수행에 이런 경로로 영향을 줄 수 있다.

즉 이 graph는 full-body dynamics를 닫힌 형태로 풀기 위한 모델이 아니라, RL이 어떤 물리적 관계를 참고해야 하는지 알려주는 guideline이다. 축소모델과 실제 full-body humanoid 사이의 차이는 RL이 학습해야 할 영역으로 남는다.

## 기대하는 방향

이 아이디어의 기대는 단순히 더 많은 feature를 넣는 것이 아니다. 목표는 WBC의 해석성과 RL의 적응성을 연결하는 것이다.

- 고전 안정성 해석의 물리 언어를 RL policy 안에 남긴다.
- reward function에 흩어져 있던 안정성 힌트를 representation 수준에서도 제공한다.
- agent가 raw state에서 안정성 개념을 처음부터 발견해야 하는 부담을 줄인다.
- 세부 reward shaping의 일부 부담을 줄이고, 더 거시적인 goal 중심 task로 갈 가능성을 만든다.
- arm-leg coordination, loco-manipulation, narrow terrain처럼 단순 footstep tracking을 넘어서는 상황에서 물리적 coupling을 더 잘 드러낼 수 있다.

## 피해야 할 주장

- "Physical Feature Graph가 full-body dynamics의 정답 모델이다." → 아니다. reduced-order physics와 centroidal language를 구조적 guide로 쓰는 것이다.
- "Attention이 물리 법칙을 새로 발견한다." → 아니다. 이미 알려진 물리 언어의 coupling을 학습 표현에 드러내는 것이다.
- "Morphology graph는 필요 없다." → 아니다. body graph는 중요하지만, stability language graph라는 다른 층위가 추가로 필요하다는 주장이다.
- "Reward shaping이 완전히 사라진다." → 아니다. 다만 일부 안정성 관련 shaping 부담을 representation으로 옮길 가능성이 있다.

## Links

- 연결 아이디어: [[humanoid-arm-dual-role]]
- 고전 안정성 언어: [[3d-lipm-icp]]
- centroidal language: [[centroidal-angular-momentum]] · [[2013-orin-centroidal-dynamics]]
- partial guidance 예시: [[2024-lee-footstep-planning-rl]]
- CAM coupling 예시: [[2025-lee-humanoid-arm-cam-marl]]
- morphology graph 비교 대상: [[2024-sferrazza-body-transformer]] · [[transformer]]
