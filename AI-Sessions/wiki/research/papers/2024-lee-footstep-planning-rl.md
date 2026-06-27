---
tags: [tier/low]
type: paper
date: 2026-06-24
status: active
source: AI-Sessions/raw/papers/2024-lee-footstep-planning-rl.pdf
---

# Integrating Model-Based Footstep Planning with Model-Free RL (2024)

- 저자: Ho Jae Lee, Seungwoo Hong, Sangbae Kim
- venue/arXiv: IROS 2024 / arXiv:2408.02662
- source: AI-Sessions/raw/papers/2024-lee-footstep-planning-rl.pdf

## Abstract (한국어)

이 연구는 Linear Inverted Pendulum(LIP) 동역학에서 얻은 desired footstep pattern을 사용해 model-based footstep planning과 reinforcement learning을 결합하는 제어 프레임워크를 제안한다. LIP 모델은 속도 명령에 따라 로봇 상태를 전방 예측하고 원하는 발 위치를 정한다. 이후 RL policy는 LIP 모델에서 나온 전체 reference motion을 따르지 않고 foot placement만 추종하도록 학습된다. 이러한 부분적 물리 가이드는 policy가 template model에 과적합되지 않으면서도 physics-informed dynamics의 예측성과 RL controller의 적응성을 함께 활용하게 한다. MIT Humanoid에서 walking과 turning을 포함한 안정적이고 동적인 locomotion을 보였고, unseen uneven terrain으로 확장해 적응성과 일반화를 검증했다. 하드웨어에서는 treadmill 위 1.5 m/s 전진 보행과 90도/180도 회전을 달성했다.

## 핵심 내용

이 논문은 단순 LIPM 전체 궤적을 policy가 모방하게 하지 않고, LIPM이 가장 잘 설명하는 desired footstep 위치만 저차원 목표로 제공한다. policy는 full-body dynamics와 terrain 적응은 model-free RL로 학습한다.

핵심 수식 흐름은 CoM 상태 전방 예측, ICP/eICP 계산, desired velocity에 따른 step offset, lateral foot offset을 결합해 다음 foothold를 정하는 방식이다. RL 쪽은 residual joint PD action, phase clock, contact schedule reward, velocity/heading/base-height reward와 regularization을 사용한다.

결과적으로 평지 velocity tracking뿐 아니라 rough/gapped terrain에서 swing 중 desired step을 동적으로 바꿔 적응하는 모습을 보였다. 결론에서는 향후 vision으로 terrain height를 감지하고, LIP dynamics를 whole-body dynamics + MPC로 바꾸는 방향을 제시한다.

## 메커니즘

LIPM은 이족보행을 단순화한 reduced-order model로, 지지발과 CoM을 무게 없는 telescopic leg로 연결한 도립진자다. CoM의 z축 속도를 일정하게 두고 ankle joint가 없는 point-foot를 가정하면 3D-LIPM의 운동방정식은 선형이 된다.

$$\ddot{r} = \omega_0^2 (r - p),\qquad \omega_0 = \sqrt{g/z_0}$$

여기서 $r=(r_x,r_y)$는 CoM 수평 위치, $p$는 지지발 위치, $\omega_0$는 진자의 natural frequency다. (1)을 적분한 "orbital energy"에서 Instantaneous Capture Point(ICP)가 유도된다.

$$\xi = r + \frac{\dot{r}}{\omega_0}$$

ICP는 그 자리에 발을 디디면 시스템이 정지하는 지면상의 점이며, ICP dynamics는 $\dot{\xi} = \omega_0(\xi - p)$로 unstable하게 발산한다. 해는 $\xi(t) = e^{\omega_0 t}\xi(0) + (1-e^{\omega_0 t})p$. 이 예측성을 이용해 desired velocity로부터 step length·width offset을 계산하고 final ICP에 더해 다음 foothold를 정한다.

### 구현 포인트

- LIPM은 정답 dynamics가 아니라 **저차원 안정성 가이드**다. full CoM trajectory를 강제 추종시키지 말고 desired footstep만 RL에 주는 것이 핵심(과적합 방지).
- $\omega_0 = \sqrt{g/z_0}$의 $z_0$(CoM 높이)는 일정 가정. base height reward로 가정을 유지시킨다.
- ⚠️ ICP 계산에 들어가는 CoM 속도 $\dot{r}$를 pelvis 강체 속도와 혼동하면 footstep에 직접 오차가 들어간다 (harness/errors/mjlab-errors).

## 내 연구 연결

이 논문은 `dynamics-guided-rl` category에서 LIPM/ICP 기반 footstep guidance의 핵심 근거다. mj_rl의 eICP/LIPM footstep task를 raw state RL이 아니라 reduced-order physics가 제공하는 저차원 안정성 힌트를 RL에 넣는 구조로 해석하게 해준다.

Physical Feature Graph 관점에서는 CoM, velocity, ICP, footstep이 raw observation 이상의 stability language가 될 수 있음을 보여주는 직접 근거다.

## Links

- raw repo: AI-Sessions/raw/repos/2024-lee-footstep-planning-rl.md
- source note: 2024-lee-footstep-planning-rl-code
- category: dynamics-guided-rl
