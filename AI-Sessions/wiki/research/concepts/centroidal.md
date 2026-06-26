---
tags: [tier/mid]
type: concept
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2013-orin-centroidal-dynamics.pdf
---

# Centroidal

## 정의

Centroidal dynamics는 휴머노이드의 dynamics를 CoM(centroid)에 사영해 기술하는 관점이다. 각 link의 spatial momentum을 공통 reference인 CoM에 모으면 $6\times1$ centroidal momentum vector

$$h_G = \begin{bmatrix} k_G \\ l_G \end{bmatrix} = A_G(q)\,\dot{q}$$

를 얻는다. $l_G$는 linear momentum, $k_G$는 centroidal angular momentum(CAM), $A_G(q)$는 joint velocity를 aggregate momentum으로 보내는 $6\times n$ Centroidal Momentum Matrix(CMM)다. 외력(중력, 지면반력, 손/팔 접촉 wrench)의 합력은 momentum rate $\dot{l}_G,\ \dot{k}_G$와 같다(Newton-Euler).

핵심 성질: linear momentum은 적분하면 CoM 위치를 주지만, **angular momentum은 적분해도 configuration의 의미 있는 orientation을 주지 못한다**(non-integrable). 그럼에도 CAM은 whole-body balance에서 trunk sway를 줄이는 등 강력한 제어 변수다. Orin et al.은 CMM·centroidal inertia·average spatial velocity를 $O(N)$으로 계산하는 알고리즘을 제시한다.

## 사용 논문

- [[AI-Sessions/wiki/research/papers/2013-orin-centroidal-dynamics|2013-orin-centroidal-dynamics]] — 원전. centroidal momentum, CMM($A_G$) 정의와 계산
- [[AI-Sessions/wiki/research/papers/2025-lee-humanoid-arm-cam-marl|2025-lee-humanoid-arm-cam-marl]] — CAM을 reward/observation에 넣어 팔-다리 coordination 유도
- [[AI-Sessions/wiki/research/papers/2026-shin-abd-net|2026-shin-abd-net]] — ABA forward dynamics 구조를 GNN policy에 내재화. child→parent 전파를 learnable parameter로 대체

## 구현 포인트

- CAM/CMM은 Pinocchio 등에서 `computeAllTerms` 계열로 조회한다. frame·부호 convention을 asset builder와 대조.
- CAM reward와 dCAM penalty의 부호/프레임이 실제 angular momentum 변화와 맞는지 standing/walking play 로그로 검증.
- 팔은 비접촉 시 CAM/inertia distribution을 바꾸는 centroidal stabilizer, 접촉 시 wrench source로 centroidal state에 coupling된다.

## Links

- raw: AI-Sessions/raw/papers/2013-orin-centroidal-dynamics.pdf
