---
tags: [tier/upper]
type: idea
date: 2026-06-24
status: active
source: AI-Sessions/raw/ideas/humanoid-arm-dual-role.md
---

# 아이디어: 휴머노이드 팔의 이중 역할

## Summary

휴머노이드의 팔은 단순한 manipulation module이나 보행 중 스타일 요소가 아니다. 접촉 상황에서는 물체·환경과 상호작용하는 **manipulation wrench source**이고, 비접촉 상황에서는 whole-body inertia distribution과 [[centroidal|CAM]]을 바꾸는 **centroidal stabilization 요소**다. 팔은 locomotion과 manipulation을 잇는 물리적 매개이며, floating-base robot의 centroidal dynamics에 직접 들어가는 능동 요소로 봐야 한다.

## 핵심 인사이트

다리는 [[lipm|LIPM/ICP]], DCM, ZMP, footstep planning 같은 강한 해석 도구를 쌓아 왔지만, 팔은 흔히 별도 end-effector, arm swing style, 추가 관절, CAM 감소 reward 대상 중 하나로만 다뤄진다. 정작 팔이 **어떤 물리적 경로로** balance에 기여하는지는 덜 명시적이다.

- **첫 번째 역할 (접촉 중) — manipulation wrench source**: 손이 물체를 밀고 당기고 문을 열고 짐을 들 때 그 wrench는 손끝에 머물지 않고 base motion·CoM·foot contact·CAM과 coupling된다. manipulation은 upper-body task로 분리될 수 없다.
- **두 번째 역할 (비접촉 중) — centroidal stabilizer**: 팔의 자세·swing은 질량 분포·관성·angular momentum을 바꾼다. balance margin이 줄어드는 빠른 전진/회전/외란 회복/좁은 지형에서 발 위치만으로 부족할 때 CAM을 보상하는 보조 안정화 수단이 된다.

## 예시

- **Loco-manipulation**: 무거운 물체 운반·문 열기·이동 중 grasp는 팔의 task-space motion과 보행 안정성이 분리되지 않는다. 좋은 정책은 hand trajectory뿐 아니라 팔 wrench가 centroidal state에 미치는 효과까지 고려한다.
- **Narrow terrain**: foot placement 자유도가 줄어들수록 arm posture/swing의 internal motion이 stability margin에 기여할 여지가 커진다.

## 연구적 함의

팔을 locomotion 정책의 부속 출력이 아니라 whole-body dynamics의 일부로 본다. 팔은 contact 전에는 centroidal stabilizer, contact 중에는 wrench source이며, 두 역할 모두 centroidal dynamics를 통해 locomotion stability와 연결된다.

## 피해야 할 주장

- "팔은 항상 안정성을 높인다." → 잘못된 움직임은 disturbance가 될 수 있다.
- "CAM만 보면 팔의 역할을 다 설명한다." → inertia distribution, contact wrench, torso/base motion도 함께 봐야 한다.
- "팔/다리를 분리하면 충분하다." → 분리 학습은 구현 선택일 뿐, 물리적 경로를 설명하지 않는다.
- "학습 구조가 곧 물리 해석이다." → 주장은 네트워크 구조가 아니라 팔의 물리적 역할에 있다.

## Links

- 핵심 개념: [[centroidal]] · [[lipm]] · [[transformer]] · [[ppo]]
- raw 원본: AI-Sessions/raw/ideas/humanoid-arm-dual-role.md
- 근거 논문(plaintext): 2025-lee-humanoid-arm-cam-marl, 2013-orin-centroidal-dynamics
