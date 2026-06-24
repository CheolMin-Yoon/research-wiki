---
tags: [tier/upper]
type: idea
date: 2026-06-24
status: active
source: AI-Sessions/raw/ideas/physical-feature-graph.md
---

# 아이디어: Physical Feature Graph

## Summary

부유 동역학 로봇의 locomotion을 raw `q`, `dq`, target velocity의 상태 문제로 보지 않고, CoM·DCM·ZMP·CMM·CAM·contact·footstep·body relation처럼 이미 물리적으로 정의된 feature들의 **coupling**으로 해석하려는 관점이다. 고전 안정성 해석과 WBC/centroidal control이 쓰던 물리 언어를 현대 RL에서 버리지 말고, graph 구조와 [[transformer|attention]]을 통해 policy에 구조적 가이드로 남기자는 것이 핵심 주장이다.

## 핵심 인사이트

raw state RL은 agent에게 "관절 상태와 목표 속도는 이렇다, 알아서 안정적으로 걸어라"를 던지는 것과 비슷하다. 그러나 humanoid 안정성은 관절 상태의 단순 조합이 아니라 CoM·DCM·CAM 같은 거시적 물리량으로 해석된다. 이 물리량들은 hand-crafted feature가 아니라 [[lipm|reduced-order model]]과 [[centroidal|centroidal dynamics]]에서 추출된 **stability language**다. 이들은 full-body dynamics의 정답 모델이라서가 아니라 안정성을 판단하는 거시 좌표계이기 때문에 강력하다.

stability language는 서로 커플링되어 있다. 팔과 다리의 움직임은 분리되어 보여도 CAM·base state·contact stability 같은 공통 변수 위에서 다시 결합된다. 따라서 morphology graph(몸이 어떻게 연결되는가)와는 다른 층위로, **물리 특징들이 어떻게 커플링되는가**를 graph로 표현할 수 있다.

## 네 가지 관점

1. 로봇 상태: `q`, `dq`, base state, command (기존 raw observation)
2. 물리적 특징: CoM, DCM/ICP, ZMP, CMM, CAM (stability language)
3. 접촉 정보: stance/swing, support region, footstep, contact wrench
4. body 정보: pelvis/torso/leg/foot/arm/hand (물리량의 anchor)

## 연구적 함의

목표는 feature를 더 넣는 것이 아니라 **WBC의 해석성과 RL의 적응성을 연결**하는 것이다. reward에 흩어져 있던 안정성 힌트를 representation 수준에서도 제공해, agent가 raw state에서 안정성 개념을 처음부터 발견하는 부담을 줄인다. 이는 footstep partial guidance나 CAM coordination 같은 기존 흐름을 stability language 전체의 coupling 구조로 확장하는 관점이다.

## 피해야 할 주장

- "Physical Feature Graph가 full-body dynamics의 정답 모델이다." → 아니다. reduced-order physics를 구조적 guide로 쓰는 것.
- "Attention이 물리 법칙을 새로 발견한다." → 아니다. 이미 알려진 물리 언어의 coupling을 표현에 드러내는 것.
- "Morphology graph는 필요 없다." → 아니다. body graph 위에 stability language graph라는 다른 층위를 추가하는 것.
- "Reward shaping이 완전히 사라진다." → 아니다. 일부 안정성 shaping 부담을 representation으로 옮길 가능성일 뿐.

## Links

- 핵심 개념: [[lipm]] · [[centroidal]] · [[transformer]] · [[ppo]]
- raw 원본: AI-Sessions/raw/ideas/physical-feature-graph.md
- 근거 논문: [[AI-Sessions/wiki/research/papers/2024-lee-footstep-planning-rl|2024-lee-footstep-planning-rl]] · [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]] · [[AI-Sessions/wiki/research/papers/2024-sferrazza-body-transformer|2024-sferrazza-body-transformer]]
