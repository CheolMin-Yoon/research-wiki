---
type: paper
date: 2026-06-24
status: active
topics:
  - humanoid
  - centroidal-dynamics
  - whole-body-control
source: AI-Sessions/raw/papers/2013-orin-centroidal-dynamics.pdf
---

# Centroidal Dynamics of a Humanoid Robot (2013)

- 저자: David E. Orin, Ambarish Goswami, Sung-Hee Lee
- venue/arXiv: Autonomous Robots 35, 161-176
- source: AI-Sessions/raw/papers/2013-orin-centroidal-dynamics.pdf

## Abstract (한국어)

humanoid robot의 center of mass(CoM)는 동역학에서 특별한 위치를 차지한다. CoM은 effective total mass의 위치이자 중력 작용선의 결과점이며, robot의 aggregate linear momentum과 angular momentum이 자연스럽게 정의되는 지점이다. 이 논문의 목적은 humanoid robot의 dynamics를 CoM에 투영한 centroidal dynamics에 주목하는 것이다. 논문은 generalized velocity를 spatial centroidal momentum으로 사상하는 centroidal momentum matrix(CMM)의 성질, 구조, 계산법을 연구한다. 또한 CMM과 joint-space inertia matrix의 관계를 transformation diagram으로 보이고, linear/angular component를 포함하는 average spatial velocity 개념과 kinetic energy 분해를 제안한다. 마지막으로 CMM을 직접 사용하는 momentum-based balance controller가 외란에 대한 balance 유지 중 불필요한 trunk bending을 크게 줄일 수 있음을 보인다.

## 핵심 내용

논문은 humanoid dynamics를 joint space, system space, CoM space 사이의 velocity/momentum transformation으로 정리한다. CMM은 generalized velocity에서 CoM 기준 spatial momentum으로 가는 핵심 행렬이다.

centroidal quantity만으로 모든 kinetic energy를 설명할 수는 없지만, aggregate motion과 balance control을 해석하는 강한 축을 제공한다. 논문은 O(N) 형태의 계산 알고리즘과 CMM, centroidal momentum, centroidal inertia, average spatial velocity 관계를 정리한다.

제어 예시는 balance controller에서 CMM을 직접 사용해 momentum을 제어하면 trunk bending 같은 불필요한 보상 동작을 줄일 수 있음을 보여준다.

## 메커니즘

각 link의 spatial momentum을 공통 reference인 CoM에 모으면 $6\times1$ centroidal momentum vector

$$h_G = \begin{bmatrix} k_G \\ l_G \end{bmatrix} = A_G(q)\,\dot{q}$$

를 얻는다. $l_G$는 linear momentum, $k_G$는 centroidal angular momentum(CAM), $A_G(q)$는 generalized velocity(floating-base 6-DOF + 관절 속도 $n$)를 aggregate momentum으로 보내는 $6\times(n+6)$ Centroidal Momentum Matrix(CMM)다. 외력(중력, 지면반력, 손/팔 접촉 wrench)의 합력은 momentum rate $\dot{l}_G,\ \dot{k}_G$와 같다(Newton-Euler).

핵심 성질: linear momentum은 적분하면 CoM 위치를 주지만, **angular momentum은 적분해도 configuration의 의미 있는 orientation을 주지 못한다**(non-integrable). 그럼에도 CAM은 whole-body balance에서 trunk sway를 줄이는 등 강력한 제어 변수다. Orin et al.은 CMM·centroidal inertia·average spatial velocity를 $O(N)$으로 계산하는 알고리즘을 제시한다.

### 구현 포인트

- CAM/CMM은 Pinocchio 등에서 `computeAllTerms` 계열로 조회한다. frame·부호 convention을 asset builder와 대조.
- CAM reward와 dCAM penalty의 부호/프레임이 실제 angular momentum 변화와 맞는지 standing/walking play 로그로 검증.
- 팔은 비접촉 시 CAM/inertia distribution을 바꾸는 centroidal stabilizer, 접촉 시 wrench source로 centroidal state에 coupling된다.

## 내 연구 연결

이 논문은 centroidal dynamics의 원전 역할을 한다. humanoid arm motion, CAM reward, whole-body CoM/CAM feature를 모두 같은 centroidal language로 묶는 근거다.

Physical Feature Graph에서는 CoM, CMM, CAM을 raw joint state와 다른 안정성 해석 좌표로 취급하는 근거가 된다.

## Relations

- related papers: [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]]
