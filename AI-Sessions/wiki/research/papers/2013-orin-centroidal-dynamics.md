---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
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

## 내 연구 연결

이 논문은 `centroidal` concept의 원전 역할을 한다. humanoid arm motion, CAM reward, whole-body CoM/CAM feature를 모두 같은 centroidal language로 묶는 근거다.

Physical Feature Graph에서는 CoM, CMM, CAM을 raw joint state와 다른 안정성 해석 좌표로 취급하는 근거가 된다.

## Links

- concepts: centroidal
- related papers: 2025-lee-humanoid-arm-cam-marl

