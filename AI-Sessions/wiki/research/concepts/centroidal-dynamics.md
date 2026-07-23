---
type: concept
date: 2026-07-24
status: active
topics:
  - humanoid
  - centroidal-dynamics
---

# Centroidal Dynamics

## Definition and Boundary

Centroidal dynamics는 다물체 로봇의 질량중심(CoM)에 전체 선형·각운동량을 모아 외력과 운동량 변화의 관계를 기술한다. joint configuration을 직접 제어하는 whole-body dynamics와 달리, 전신 운동이 만드는 aggregate momentum을 낮은 차원에서 다룬다.

Centroidal momentum은

$$h_G = \begin{bmatrix} k_G \\ l_G \end{bmatrix} = A_G(q)\dot q$$

로 쓰며 $A_G(q)$는 Centroidal Momentum Matrix(CMM), $k_G$는 centroidal angular momentum(CAM), $l_G$는 linear momentum이다. 선형운동량은 CoM 속도와 직접 연결되지만 각운동량은 적분해 configuration orientation을 만들 수 없는 non-integrable quantity다.

## Why It Matters

휴머노이드의 balance, contact wrench, 팔-다리 coupling을 같은 물리 언어로 표현한다. MPC/WBC의 reduced model이자 RL observation·reward·credit signal의 후보가 된다.

## Engineering Implications

- CMM column과 joint velocity의 곱은 joint별 momentum contribution을 제공한다.
- frame, reference point, spatial-vector ordering과 부호를 asset/backend 사이에서 검증해야 한다.
- CAM 값만 줄이는 reward는 동작 표현력을 억제할 수 있으므로 command와 contact phase를 함께 고려한다.

## Relations

- used-by: [[AI-Sessions/wiki/research/methods/model-predictive-control|model-predictive-control]]
- used-by: [[AI-Sessions/wiki/research/methods/whole-body-control|whole-body-control]]
- defines-task-state: [[AI-Sessions/wiki/research/tasks/humanoid-locomotion|humanoid-locomotion]]

## Evidence

- Orin et al. 2013, centroidal dynamics and CMM
- Romualdi et al. 2022, nonlinear centroidal MPC
